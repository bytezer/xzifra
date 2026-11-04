import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xzifra/data/attachment_service.dart';
import 'package:xzifra/data/attachment_storage.dart';
import 'package:xzifra/data/database.dart';
import 'package:xzifra/data/export_service.dart';
import 'package:xzifra/domain/attachments.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory firstTemp;
  late Directory secondTemp;
  late AppDatabase first;
  late AppDatabase second;
  late AttachmentStorage firstStorage;
  late AttachmentStorage secondStorage;

  setUp(() async {
    firstTemp = await Directory.systemTemp.createTemp('xzifra-backup-a-');
    secondTemp = await Directory.systemTemp.createTemp('xzifra-backup-b-');
    first = AppDatabase(NativeDatabase.memory());
    second = AppDatabase(NativeDatabase.memory());
    await first.select(first.categories).get();
    await second.select(second.categories).get();
    firstStorage = AttachmentStorage(documentsDirectory: () async => firstTemp);
    secondStorage = AttachmentStorage(
      documentsDirectory: () async => secondTemp,
    );
  });

  tearDown(() async {
    await first.close();
    await second.close();
    if (await firstTemp.exists()) await firstTemp.delete(recursive: true);
    if (await secondTemp.exists()) await secondTemp.delete(recursive: true);
  });

  Future<ExpenseView> addExpense(AppDatabase database) async {
    final category = (await database.select(database.categories).get())
        .firstWhere((item) => item.name == 'Food');
    await database.addExpense(
      amountCents: 1250,
      currency: 'PEN',
      date: '2026-11-02',
      categoryId: category.id,
      note: 'Lunch',
    );
    return (await database.allExpenses()).single;
  }

  test('full ZIP backup restores attachment rows and files', () async {
    final expense = await addExpense(first);
    final attachment = await AttachmentService(first, firstStorage).addBytes(
      ownerType: AttachmentOwnerType.expense,
      ownerId: expense.expense.id,
      fileName: 'receipt.jpg',
      bytes: [10, 20, 30, 40],
      mimeType: 'image/jpeg',
    );

    final exporter = ExportService(
      first,
      storage: firstStorage,
      temporaryDirectory: () async => firstTemp,
    );
    final zipFile = await exporter.createFullBackup();
    final archive = ZipDecoder().decodeBytes(await zipFile.readAsBytes());
    final names = archive.files.map((file) => file.name).toSet();
    expect(names, contains('xzifra-backup.json'));
    expect(names, contains(attachment.relativePath));

    final jsonEntry = archive.files.firstWhere(
      (file) => file.name == 'xzifra-backup.json',
    );
    final json =
        jsonDecode(utf8.decode(jsonEntry.content)) as Map<String, dynamic>;
    expect((json['attachments'] as List).length, 1);

    final importer = ExportService(
      second,
      storage: secondStorage,
      temporaryDirectory: () async => secondTemp,
    );
    final summary = await importer.importFullBackupFile(zipFile);

    expect(summary.expenses, 1);
    final restored = (await second.select(second.attachments).get()).single;
    expect(restored.fileName, 'receipt.jpg');
    expect(restored.ownerType, 'expense');
    expect(restored.relativePath, startsWith('attachments/'));
    final restoredFile = await secondStorage.resolve(restored.relativePath);
    expect(await restoredFile.exists(), isTrue);
    expect(await restoredFile.readAsBytes(), [10, 20, 30, 40]);
  });

  test('plain JSON backups exclude attachments and ignore metadata', () async {
    final expense = await addExpense(first);
    await AttachmentService(first, firstStorage).addBytes(
      ownerType: AttachmentOwnerType.expense,
      ownerId: expense.expense.id,
      fileName: 'receipt.jpg',
      bytes: [1, 2],
      mimeType: 'image/jpeg',
    );

    final json = await first.exportJson();
    expect(json.containsKey('attachments'), isFalse);

    json['attachments'] = [
      {
        'id': 'orphan-attachment',
        'ownerType': 'expense',
        'ownerId': expense.expense.id,
        'relativePath': 'attachments/orphan.jpg',
        'fileName': 'orphan.jpg',
        'mimeType': 'image/jpeg',
        'sizeBytes': 2,
      },
    ];
    final summary = await second.importJson(json);
    expect(summary.expenses, 1);
    expect(await second.select(second.attachments).get(), isEmpty);
  });

  test('full ZIP import skips attachment metadata without a file', () async {
    final expense = await addExpense(first);
    final json = await first.exportJson(includeAttachments: true);
    json['attachments'] = [
      {
        'id': 'missing-file',
        'ownerType': 'expense',
        'ownerId': expense.expense.id,
        'relativePath': 'attachments/missing-file.jpg',
        'fileName': 'missing-file.jpg',
        'mimeType': 'image/jpeg',
        'sizeBytes': 2,
      },
    ];

    final archive = Archive();
    archive.addFile(
      ArchiveFile.string(
        'xzifra-backup.json',
        const JsonEncoder.withIndent('  ').convert(json),
      ),
    );
    final zipFile = File('${firstTemp.path}/missing-file.zip');
    await zipFile.writeAsBytes(ZipEncoder().encode(archive));

    final importer = ExportService(
      second,
      storage: secondStorage,
      temporaryDirectory: () async => secondTemp,
    );
    final summary = await importer.importFullBackupFile(zipFile);

    expect(summary.expenses, 1);
    expect(await second.select(second.attachments).get(), isEmpty);
  });
}
