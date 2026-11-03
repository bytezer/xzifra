import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
}
