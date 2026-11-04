import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/tags.dart';
import '../domain/money.dart';
import 'database.dart';

class ExportService {
  ExportService(this._database);

  final AppDatabase _database;

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
    final directory = await getTemporaryDirectory();
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    return File(p.join(directory.path, '$prefix-$stamp.$extension'));
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
