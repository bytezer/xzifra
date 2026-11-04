import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/tags.dart';
import '../domain/money.dart';
import 'attachment_service.dart';
import 'attachment_storage.dart';
import 'database.dart';

class ExportService {
  ExportService(
    this._database, {
    AttachmentStorage? storage,
    Future<Directory> Function()? temporaryDirectory,
  }) : _storage = storage ?? AttachmentStorage(),
       _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  final AppDatabase _database;
  final AttachmentStorage _storage;
  final Future<Directory> Function() _temporaryDirectory;

  Future<File> createJsonBackup() async {
    final data = await _database.exportJson();
    final file = await _tempFile('xzifra-backup', 'json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return file;
  }

  Future<File> createCsvExport() async {
    final expenses = await _database.allExpenses();
    final buffer = StringBuffer(
      'date,amount,currency,category,payment_method,note\n',
    );
    for (final item in expenses) {
      buffer.writeln(
        [
          item.expense.date,
          Money.decimal(item.expense.amountCents),
          item.expense.currency,
          item.category.name,
          item.paymentMethod?.name ?? '',
          item.expense.note ?? '',
        ].map(_escapeCsv).join(','),
      );
    }
    final file = await _tempFile('xzifra-expenses', 'csv');
    await file.writeAsString(buffer.toString());
    return file;
  }

  Future<void> shareFile(File file, {required String subject}) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: subject),
    );
  }

  /// Exports a single note as an Obsidian-compatible Markdown document.
  Future<File> createNoteMarkdown(Note note) async {
    final file = await _tempFile('xzifra-note-${_slug(note.title)}', 'md');
    await file.writeAsString(noteMarkdown(note));
    return file;
  }

  /// Exports every note as Markdown files inside a ZIP for Obsidian.
  Future<File> createNotesZip(List<Note> notes) async {
    final archive = Archive();
    final names = <String>{};
    for (final note in notes) {
      var name = _slug(note.title);
      if (name.isEmpty) name = 'note';
      var fileName = '$name.md';
      var suffix = 2;
      while (!names.add(fileName)) {
        fileName = '$name-${suffix++}.md';
      }
      archive.addFile(
        ArchiveFile.string('Xzifra Notes/$fileName', noteMarkdown(note)),
      );
    }
    final file = await _tempFile('xzifra-notes', 'zip');
    await file.writeAsBytes(ZipEncoder().encode(archive));
    return file;
  }

  /// Creates a ZIP with the JSON backup (including attachment metadata) and
  /// every attachment file under `attachments/`.
  Future<File> createFullBackup() async {
    final data = await _database.exportJson(includeAttachments: true);
    final archive = Archive();
    archive.addFile(
      ArchiveFile.string(
        'xzifra-backup.json',
        const JsonEncoder.withIndent('  ').convert(data),
      ),
    );

    final attachments = await _database.allAttachments();
    for (final attachment in attachments) {
      try {
        final file = await _storage.resolve(attachment.relativePath);
        if (!await file.exists()) continue;
        archive.addFile(
          ArchiveFile.bytes(attachment.relativePath, await file.readAsBytes()),
        );
      } catch (_) {
        // Metadata is kept in the JSON; a missing file is skipped.
      }
    }

    final file = await _tempFile('xzifra-full-backup', 'zip');
    await file.writeAsBytes(ZipEncoder().encode(archive));
    return file;
  }

  /// Imports a full ZIP backup: data first, then attachments whose files and
  /// owners are present. Invalid or missing entries are skipped.
  Future<ImportSummary> importFullBackupFile(File file) async {
    return importFullBackupBytes(await file.readAsBytes());
  }

  Future<ImportSummary> importFullBackupBytes(List<int> bytes) async {
    final base = await _temporaryDirectory();
    final directory = await base.createTemp('xzifra-import-');
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final entry in archive) {
        if (!entry.isFile) continue;
        final relative = _safeArchivePath(entry.name);
        if (relative == null) continue;
        final file = File(p.join(directory.path, relative));
        await file.parent.create(recursive: true);
        await file.writeAsBytes(entry.content, flush: true);
      }

      final jsonFile = File(p.join(directory.path, 'xzifra-backup.json'));
      if (!await jsonFile.exists()) {
        throw const FormatException('Full backup is missing its JSON file.');
      }
      final decoded = jsonDecode(await jsonFile.readAsString());
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Backup must be a JSON object.');
      }
      final summary = await _database.importJson(decoded);

      final metadata = decoded['attachments'];
      if (metadata is List) {
        final service = AttachmentService(_database, _storage);
        for (final raw in metadata) {
          if (raw is! Map) continue;
          final map = Map<String, dynamic>.from(raw);
          final relative = map['relativePath'] as String?;
          if (relative == null) continue;
          final safe = _safeArchivePath(relative);
          if (safe == null) continue;
          final file = File(p.join(directory.path, safe));
          if (!await file.exists()) continue;
          await service.importAttachment(map, await file.readAsBytes());
        }
      }
      return summary;
    } finally {
      try {
        await directory.delete(recursive: true);
      } catch (_) {
        // Temporary data is best-effort cleanup.
      }
    }
  }

  /// Returns `null` when the user cancels the file picker.
  Future<ImportSummary?> importFullBackup() async {
    final files = await FilePicker.pickFiles(
      dialogTitle: 'Select an Xzifra full backup',
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (files.isEmpty) return null;
    return importFullBackupBytes(await files.first.readAsBytes());
  }

  /// Returns `null` when the user cancels the file picker.
  Future<ImportSummary?> importJsonBackup() async {
    final files = await FilePicker.pickFiles(
      dialogTitle: 'Select an Xzifra backup',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (files.isEmpty) return null;

    final text = utf8.decode(await files.first.readAsBytes());
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Backup must be a JSON object.');
    }
    return _database.importJson(decoded);
  }

  Future<File> _tempFile(String prefix, String extension) async {
    final directory = await _temporaryDirectory();
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    return File(p.join(directory.path, '$prefix-$stamp.$extension'));
  }

  String? _safeArchivePath(String name) {
    final normalized = p.normalize(name);
    if (p.isAbsolute(normalized) ||
        normalized == '..' ||
        normalized.startsWith('../')) {
      return null;
    }
    return normalized;
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String noteMarkdown(Note note) {
    final buffer = StringBuffer('---\n');
    buffer.writeln('title: ${jsonEncode(note.title)}');
    final tags = parseTags(note.tags);
    buffer.writeln('tags: [${tags.map(jsonEncode).join(', ')}]');
    buffer.writeln('pinned: ${note.pinned}');
    if (note.archivedAt != null) {
      buffer.writeln('archived: true');
    }
    buffer.writeln('created: ${note.createdAt.toUtc().toIso8601String()}');
    buffer.writeln('updated: ${note.updatedAt.toUtc().toIso8601String()}');
    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln('# ${note.title}');
    final body = note.body.trimRight();
    if (body.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(body);
    }
    return buffer.toString();
  }

  String _slug(String value) {
    const accents = {
      'á': 'a',
      'à': 'a',
      'ä': 'a',
      'â': 'a',
      'é': 'e',
      'è': 'e',
      'ë': 'e',
      'ê': 'e',
      'í': 'i',
      'ì': 'i',
      'ï': 'i',
      'î': 'i',
      'ó': 'o',
      'ò': 'o',
      'ö': 'o',
      'ô': 'o',
      'ú': 'u',
      'ù': 'u',
      'ü': 'u',
      'û': 'u',
      'ñ': 'n',
      'ç': 'c',
    };
    var text = value.toLowerCase();
    for (final entry in accents.entries) {
      text = text.replaceAll(entry.key, entry.value);
    }
    final slug = text
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '')
        .split('-')
        .take(8)
        .join('-');
    return slug.length > 60 ? slug.substring(0, 60) : slug;
  }
}
