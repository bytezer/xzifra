import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Resolves attachment paths under the app documents directory.
///
/// The database stores paths relative to that directory, so moving the app
/// data directory does not break existing attachments.
class AttachmentStorage {
  AttachmentStorage({Future<Directory> Function()? documentsDirectory})
    : _documentsDirectory =
          documentsDirectory ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _documentsDirectory;

  static const String directoryName = 'attachments';

  Future<Directory> attachmentsDirectory() async {
    final documents = await _documentsDirectory();
    final directory = Directory(p.join(documents.path, directoryName));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<File> resolve(String relativePath) async {
    final documents = await _documentsDirectory();
    final safe = _safeRelative(relativePath);
    return File(p.join(documents.path, safe));
  }

  Future<File> write(String relativePath, List<int> bytes) async {
    final file = await resolve(relativePath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<bool> exists(String relativePath) async {
    try {
      final file = await resolve(relativePath);
      return await file.exists();
    } catch (_) {
      return false;
    }
  }

  Future<void> delete(String relativePath) async {
    try {
      final file = await resolve(relativePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Missing or unreadable files must never block deleting the record.
    }
  }

  String _safeRelative(String relativePath) {
    final normalized = p.normalize(relativePath);
    if (p.isAbsolute(normalized) ||
        normalized == '..' ||
        normalized.startsWith('../')) {
      throw ArgumentError.value(relativePath, 'relativePath');
    }
    return normalized;
  }
}
