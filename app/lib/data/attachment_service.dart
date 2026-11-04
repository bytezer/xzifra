import 'dart:io';

import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../domain/attachments.dart';
import 'attachment_picker.dart';
import 'attachment_storage.dart';
import 'database.dart';

class AttachmentTooLargeException implements Exception {
  const AttachmentTooLargeException(this.sizeBytes);

  final int sizeBytes;
}

/// Stores attachment bytes and their database metadata.
class AttachmentService {
  AttachmentService(this._database, this._storage);

  final AppDatabase _database;
  final AttachmentStorage _storage;

  static const int maxAttachmentBytes = 25 * 1024 * 1024;
  static const _uuid = Uuid();

  Future<Attachment> addPicked({
    required AttachmentOwnerType ownerType,
    required String ownerId,
    required PickedAttachment picked,
  }) {
    return addBytes(
      ownerType: ownerType,
      ownerId: ownerId,
      fileName: picked.fileName,
      bytes: picked.bytes,
      mimeType: picked.mimeType,
    );
  }

  Future<Attachment> addBytes({
    required AttachmentOwnerType ownerType,
    required String ownerId,
    required String fileName,
    required List<int> bytes,
    String? mimeType,
  }) async {
    if (bytes.length > maxAttachmentBytes) {
      throw AttachmentTooLargeException(bytes.length);
    }
    if (!await _database.attachmentOwnerExists(ownerType, ownerId)) {
      throw StateError('Attachment owner does not exist.');
    }

    final id = _uuid.v4();
    final extension = _extensionFor(fileName, mimeType);
    final relativePath = '${AttachmentStorage.directoryName}/$id$extension';
    final resolvedMime = _resolveMime(fileName, mimeType);

    await _storage.write(relativePath, bytes);
    try {
      await _database.addAttachmentRecord(
        id: id,
        ownerType: ownerType,
        ownerId: ownerId,
        relativePath: relativePath,
        fileName: fileName,
        mimeType: resolvedMime,
        sizeBytes: bytes.length,
      );
    } catch (_) {
      await _storage.delete(relativePath);
      rethrow;
    }

    final attachment = await _database.getAttachment(id);
    if (attachment == null) {
      throw StateError('Could not persist attachment metadata.');
    }
    return attachment;
  }

  Future<File?> resolveFile(Attachment attachment) async {
    try {
      final file = await _storage.resolve(attachment.relativePath);
      return await file.exists() ? file : null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> openExternally(Attachment attachment) async {
    final file = await resolveFile(attachment);
    if (file == null) return false;
    try {
      final result = await OpenFilex.open(file.path, type: attachment.mimeType);
      return result.type == ResultType.done;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteAttachment(Attachment attachment) async {
    await _database.deleteAttachmentRecord(attachment.id);
    await _storage.delete(attachment.relativePath);
  }

  Future<void> deleteForOwner(
    AttachmentOwnerType ownerType,
    String ownerId,
  ) async {
    final attachments = await _database.attachmentsForOwner(ownerType, ownerId);
    for (final attachment in attachments) {
      await _database.deleteAttachmentRecord(attachment.id);
      await _storage.delete(attachment.relativePath);
    }
  }

  /// Imports one metadata entry from a full backup, skipping duplicates,
  /// missing owners, invalid types and oversized files.
  Future<Attachment?> importAttachment(
    Map<String, dynamic> metadata,
    List<int> bytes,
  ) async {
    final id = metadata['id'] as String?;
    final ownerType = AttachmentOwnerType.parse(
      metadata['ownerType'] as String?,
    );
    final ownerId = metadata['ownerId'] as String?;
    if (id == null ||
        id.isEmpty ||
        ownerType == null ||
        ownerId == null ||
        ownerId.isEmpty) {
      return null;
    }
    if (bytes.length > maxAttachmentBytes) return null;
    if (await _database.getAttachment(id) != null) return null;
    if (!await _database.attachmentOwnerExists(ownerType, ownerId)) {
      return null;
    }

    final fileName =
        (metadata['fileName'] as String?)?.trim().isNotEmpty == true
        ? metadata['fileName'] as String
        : 'attachment';
    final mimeType = metadata['mimeType'] as String?;
    final originalPath = metadata['relativePath'] as String?;
    final extension = _extensionFor(fileName, mimeType, originalPath);
    final relativePath = '${AttachmentStorage.directoryName}/$id$extension';

    try {
      await _storage.write(relativePath, bytes);
      await _database.addAttachmentRecord(
        id: id,
        ownerType: ownerType,
        ownerId: ownerId,
        relativePath: relativePath,
        fileName: fileName,
        mimeType: _resolveMime(fileName, mimeType),
        sizeBytes: bytes.length,
      );
    } catch (_) {
      await _storage.delete(relativePath);
      return null;
    }
    return _database.getAttachment(id);
  }

  String _resolveMime(String fileName, String? mimeType) {
    if (mimeType != null && mimeType.isNotEmpty) return mimeType;
    return lookupMimeType(fileName) ?? 'application/octet-stream';
  }

  String _extensionFor(
    String fileName,
    String? mimeType, [
    String? fallbackPath,
  ]) {
    var extension = p.extension(fileName).toLowerCase();
    if (extension.isEmpty && fallbackPath != null) {
      extension = p.extension(fallbackPath).toLowerCase();
    }
    if (RegExp(r'^\.[a-z0-9]{1,8}$').hasMatch(extension)) return extension;
    return switch (mimeType) {
      'image/jpeg' => '.jpg',
      'image/png' => '.png',
      'image/webp' => '.webp',
      'image/gif' => '.gif',
      'image/heic' || 'image/heif' => '.heic',
      'application/pdf' => '.pdf',
      _ => '.bin',
    };
  }
}
