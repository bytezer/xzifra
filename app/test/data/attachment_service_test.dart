import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xzifra/data/attachment_service.dart';
import 'package:xzifra/data/attachment_storage.dart';
import 'package:xzifra/data/database.dart';
import 'package:xzifra/domain/attachments.dart';

void main() {
  late AppDatabase database;
  late Directory temp;
  late AttachmentStorage storage;
  late AttachmentService service;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await database.select(database.categories).get();
    temp = await Directory.systemTemp.createTemp('xzifra-attachments-');
    storage = AttachmentStorage(documentsDirectory: () async => temp);
    service = AttachmentService(database, storage);
  });

  tearDown(() async {
    await database.close();
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  Future<ExpenseView> createExpense() async {
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

  test('stores relative paths and deletes rows and files', () async {
    final expense = await createExpense();
    final attachment = await service.addBytes(
      ownerType: AttachmentOwnerType.expense,
      ownerId: expense.expense.id,
      fileName: 'receipt.pdf',
      bytes: [1, 2, 3, 4],
      mimeType: 'application/pdf',
    );

    expect(attachment.relativePath, startsWith('attachments/'));
    expect(attachment.relativePath, endsWith('.pdf'));
    expect(attachment.sizeBytes, 4);
    final file = await storage.resolve(attachment.relativePath);
    expect(await file.exists(), isTrue);
    expect(await file.readAsBytes(), [1, 2, 3, 4]);
    expect(
      (await database
              .watchAttachments(AttachmentOwnerType.expense, expense.expense.id)
              .first)
          .single
          .id,
      attachment.id,
    );

    await service.deleteAttachment(attachment);
    expect(await database.getAttachment(attachment.id), isNull);
    expect(await file.exists(), isFalse);
  });

  test('tolerates files that are already missing', () async {
    final expense = await createExpense();
    final attachment = await service.addBytes(
      ownerType: AttachmentOwnerType.expense,
      ownerId: expense.expense.id,
      fileName: 'photo.jpg',
      bytes: [9, 9],
      mimeType: 'image/jpeg',
    );
    final file = await storage.resolve(attachment.relativePath);
    await file.delete();

    expect(await service.resolveFile(attachment), isNull);
    await service.deleteAttachment(attachment);
    expect(await database.getAttachment(attachment.id), isNull);
  });

  test('deleteForOwner removes every attachment and file', () async {
    final expense = await createExpense();
    final first = await service.addBytes(
      ownerType: AttachmentOwnerType.expense,
      ownerId: expense.expense.id,
      fileName: 'one.jpg',
      bytes: [1],
    );
    final second = await service.addBytes(
      ownerType: AttachmentOwnerType.expense,
      ownerId: expense.expense.id,
      fileName: 'two.jpg',
      bytes: [2],
    );

    await service.deleteForOwner(
      AttachmentOwnerType.expense,
      expense.expense.id,
    );
    expect(
      await database.attachmentsForOwner(
        AttachmentOwnerType.expense,
        expense.expense.id,
      ),
      isEmpty,
    );
    expect(await storage.exists(first.relativePath), isFalse);
    expect(await storage.exists(second.relativePath), isFalse);
  });

  test('rejects unsigned owners and oversized files', () async {
    await expectLater(
      service.addBytes(
        ownerType: AttachmentOwnerType.note,
        ownerId: 'missing-note',
        fileName: 'note.txt',
        bytes: [1],
      ),
      throwsA(isA<StateError>()),
    );

    final expense = await createExpense();
    await expectLater(
      service.addBytes(
        ownerType: AttachmentOwnerType.expense,
        ownerId: expense.expense.id,
        fileName: 'huge.bin',
        bytes: List<int>.filled(AttachmentService.maxAttachmentBytes + 1, 0),
      ),
      throwsA(isA<AttachmentTooLargeException>()),
    );
  });

  test('imports attachment metadata only when owner and bytes exist', () async {
    final expense = await createExpense();
    final metadata = {
      'id': 'imported-attachment',
      'ownerType': 'expense',
      'ownerId': expense.expense.id,
      'relativePath': 'attachments/imported-attachment.pdf',
      'fileName': 'imported.pdf',
      'mimeType': 'application/pdf',
      'sizeBytes': 3,
    };

    final missingOwner = await service.importAttachment(
      {...metadata, 'id': 'missing-owner', 'ownerId': 'missing-expense'},
      [1, 2, 3],
    );
    expect(missingOwner, isNull);

    final imported = await service.importAttachment(metadata, [1, 2, 3]);
    expect(imported?.id, 'imported-attachment');
    expect(imported?.relativePath, endsWith('.pdf'));
    expect(await storage.exists(imported!.relativePath), isTrue);

    // Existing attachment ids are never duplicated.
    expect(await service.importAttachment(metadata, [1, 2, 3]), isNull);
  });
}
