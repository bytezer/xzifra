import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:xzifra/data/database.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    // Opening the database runs the migration and the seed.
    await database.select(database.categories).get();
  });

  tearDown(() async {
    await database.close();
  });

  Future<Category> categoryNamed(String name) async {
    final rows = await database.select(database.categories).get();
    return rows.firstWhere((row) => row.name == name);
  }

  Future<PaymentMethod> methodNamed(String name) async {
    final rows = await database.select(database.paymentMethods).get();
    return rows.firstWhere((row) => row.name == name);
  }

  Future<Template> templateNamed(String name) async {
    final rows = await database.select(database.templates).get();
    return rows.firstWhere((row) => row.name == name);
  }

  test('seeds default categories, payment methods and settings', () async {
    expect((await database.select(database.categories).get()).length, 9);
    final methods = await database.select(database.paymentMethods).get();
    expect(methods.length, 6);
    expect(methods.firstWhere((m) => m.name == 'Cash').icon, '💵');
    expect(methods.firstWhere((m) => m.name == 'Bank transfer').icon, '🏦');
    expect(await database.getSetting('defaultCurrency'), 'PEN');
  });

  test('payment methods are user-defined with a name and emoji', () async {
    await database.addPaymentMethod(name: 'BCP', icon: '🏦');
    final bcp = await methodNamed('BCP');
    expect(bcp.icon, '🏦');
    expect(bcp.type, 'custom');

    await database.updatePaymentMethod(bcp.id, name: 'Interbank', icon: '💳');
    final updated = await methodNamed('Interbank');
    expect(updated.icon, '💳');
  });

  test('migrates v1 payment methods and backfills icons', () async {
    final raw = sqlite.sqlite3.openInMemory();
    raw.execute('''
      CREATE TABLE payment_methods (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        archived_at INTEGER NULL
      );
    ''');
    raw.execute(
      "INSERT INTO payment_methods (id, name, type, sort_order) "
      "VALUES ('cash-id', 'Cash', 'cash', 0)",
    );
    raw.execute(
      "INSERT INTO payment_methods (id, name, type, sort_order) "
      "VALUES ('yape-id', 'Yape', 'yape', 1)",
    );
    raw.execute(
      "INSERT INTO payment_methods (id, name, type, sort_order) "
      "VALUES ('debit-id', 'Debit card', 'debit', 2)",
    );
    raw.execute('PRAGMA user_version = 1;');

    final migrated = AppDatabase(NativeDatabase.opened(raw));
    addTearDown(migrated.close);

    final methods = await migrated.select(migrated.paymentMethods).get();
    expect(methods.firstWhere((item) => item.name == 'Cash').icon, '💵');
    expect(methods.firstWhere((item) => item.name == 'Yape').icon, '📱');
    expect(methods.firstWhere((item) => item.name == 'Debit card').icon, '💳');
  });

  test('migrates v1 to v3 with icon backfill and templates', () async {
    final raw = sqlite.sqlite3.openInMemory();
    raw.execute('''
      CREATE TABLE categories (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL DEFAULT '📦',
        color INTEGER NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        archived_at INTEGER NULL
      );
    ''');
    raw.execute('''
      CREATE TABLE payment_methods (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        archived_at INTEGER NULL
      );
    ''');
    raw.execute('''
      CREATE TABLE settings_entries (
        key TEXT NOT NULL PRIMARY KEY,
        value TEXT NOT NULL
      );
    ''');
    raw.execute(
      "INSERT INTO categories (id, name, icon, color, sort_order) "
      "VALUES ('food-id', 'Food', '🍔', 0, 0)",
    );
    raw.execute(
      "INSERT INTO payment_methods (id, name, type, sort_order) "
      "VALUES ('cash-id', 'Cash', 'cash', 0)",
    );
    raw.execute('PRAGMA user_version = 1;');

    final migrated = AppDatabase(NativeDatabase.opened(raw));
    addTearDown(migrated.close);

    expect(await migrated.select(migrated.templates).get(), isEmpty);
    final cash = (await migrated.select(migrated.paymentMethods).get())
        .firstWhere((item) => item.id == 'cash-id');
    expect(cash.icon, '💵');

    await migrated.addTemplate(
      name: 'Coffee',
      amountCents: 550,
      currency: 'PEN',
      categoryId: 'food-id',
      paymentMethodId: 'cash-id',
    );
    final templates = await migrated.select(migrated.templates).get();
    expect(templates.single.name, 'Coffee');
    expect(templates.single.amountCents, 550);
  });

  test('migrates v2 to v3 by adding the templates table', () async {
    final raw = sqlite.sqlite3.openInMemory();
    raw.execute('''
      CREATE TABLE categories (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL DEFAULT '📦',
        color INTEGER NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        archived_at INTEGER NULL
      );
    ''');
    raw.execute('''
      CREATE TABLE payment_methods (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL DEFAULT '💳',
        sort_order INTEGER NOT NULL DEFAULT 0,
        archived_at INTEGER NULL
      );
    ''');
    raw.execute('''
      CREATE TABLE settings_entries (
        key TEXT NOT NULL PRIMARY KEY,
        value TEXT NOT NULL
      );
    ''');
    raw.execute(
      "INSERT INTO categories (id, name, icon, color, sort_order) "
      "VALUES ('food-id', 'Food', '🍔', 0, 0)",
    );
    raw.execute(
      "INSERT INTO payment_methods (id, name, type, icon, sort_order) "
      "VALUES ('card-id', 'Card', 'custom', '💳', 0)",
    );
    raw.execute('PRAGMA user_version = 2;');

    final migrated = AppDatabase(NativeDatabase.opened(raw));
    addTearDown(migrated.close);

    expect(await migrated.select(migrated.templates).get(), isEmpty);
    final card = (await migrated.select(migrated.paymentMethods).get())
        .firstWhere((item) => item.id == 'card-id');
    expect(card.icon, '💳');

    await migrated.addTemplate(
      name: 'Groceries',
      amountCents: 3500,
      currency: 'PEN',
      categoryId: 'food-id',
      paymentMethodId: 'card-id',
      note: 'Weekly',
    );
    final templates = await migrated.select(migrated.templates).get();
    expect(templates.single.name, 'Groceries');
    expect(templates.single.note, 'Weekly');
  });

  test('migrates v3 to v4 by adding notes and bookmarks', () async {
    final raw = sqlite.sqlite3.openInMemory();
    raw.execute('''
      CREATE TABLE categories (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL DEFAULT '📦',
        color INTEGER NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        archived_at INTEGER NULL
      );
    ''');
    raw.execute('''
      CREATE TABLE payment_methods (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL DEFAULT '💳',
        sort_order INTEGER NOT NULL DEFAULT 0,
        archived_at INTEGER NULL
      );
    ''');
    raw.execute('''
      CREATE TABLE settings_entries (
        key TEXT NOT NULL PRIMARY KEY,
        value TEXT NOT NULL
      );
    ''');
    raw.execute('PRAGMA user_version = 3;');

    final migrated = AppDatabase(NativeDatabase.opened(raw));
    addTearDown(migrated.close);

    expect(await migrated.select(migrated.notes).get(), isEmpty);
    expect(await migrated.select(migrated.bookmarks).get(), isEmpty);

    await migrated.addNote(title: 'First note', body: 'Hello', tags: 'test');
    await migrated.addBookmark(
      url: 'https://example.com',
      title: 'Example',
      tags: 'test',
    );
    expect(
      (await migrated.select(migrated.notes).get()).single.title,
      'First note',
    );
    expect(
      (await migrated.select(migrated.bookmarks).get()).single.url,
      'https://example.com',
    );
  });

  test('creates, pins, archives, searches and deletes notes', () async {
    await database.addNote(
      title: 'Groceries list',
      body: 'milk and bread',
      tags: 'home, shopping',
    );
    await database.addNote(
      title: 'Idea',
      body: 'Write about Markdown',
      tags: 'writing',
      pinned: true,
    );

    var notes = await database.watchNotes().first;
    expect(notes.map((note) => note.title).toList(), [
      'Idea',
      'Groceries list',
    ]);
    expect(notes.first.pinned, isTrue);

    final groceries = notes.firstWhere(
      (note) => note.title == 'Groceries list',
    );
    final idea = notes.firstWhere((note) => note.title == 'Idea');
    expect((await database.searchNotes('markdown')).single.title, 'Idea');
    expect(
      (await database.searchNotes('shopping')).single.title,
      'Groceries list',
    );
    expect((await database.searchNotes('milk')).single.title, 'Groceries list');

    await database.setNotePinned(idea.id, pinned: false);
    notes = await database.watchNotes().first;
    expect(notes.first.title, 'Groceries list');

    await database.updateNote(
      idea.id,
      title: 'Idea v2',
      body: 'Updated body',
      tags: 'writing, ideas',
      pinned: true,
    );
    final updated = await database.getNote(idea.id);
    expect(updated?.title, 'Idea v2');
    expect(updated?.tags, 'writing, ideas');
    expect(updated?.pinned, isTrue);

    await database.setNoteArchived(groceries.id, archived: true);
    expect((await database.watchNotes().first).length, 1);
    expect((await database.watchNotes(includeArchived: true).first).length, 2);
    expect(await database.searchNotes('milk'), isEmpty);

    await database.deleteNote(groceries.id);
    expect(await database.getNote(groceries.id), isNull);
    expect((await database.watchNotes(includeArchived: true).first).length, 1);
  });

  test('creates, archives, searches and deletes bookmarks', () async {
    await database.addBookmark(
      url: 'https://example.com/flutter',
      title: 'Flutter docs',
      note: 'Widgets and layouts',
      tags: 'dev, flutter',
    );
    await database.addBookmark(
      url: 'https://news.example.com',
      title: 'Daily news',
      tags: 'reading',
    );

    final bookmarks = await database.watchBookmarks().first;
    expect(bookmarks.length, 2);
    expect(
      (await database.searchBookmarks('flutter')).single.title,
      'Flutter docs',
    );
    expect(
      (await database.searchBookmarks('layouts')).single.title,
      'Flutter docs',
    );
    expect(
      (await database.searchBookmarks('reading')).single.title,
      'Daily news',
    );

    final docs = bookmarks.firstWhere(
      (bookmark) => bookmark.title == 'Flutter docs',
    );
    await database.updateBookmark(
      docs.id,
      url: 'https://docs.flutter.dev',
      title: 'Flutter',
      note: 'Official documentation',
      tags: 'dev',
    );
    final updated = await database.getBookmark(docs.id);
    expect(updated?.url, 'https://docs.flutter.dev');
    expect(updated?.note, 'Official documentation');

    await database.setBookmarkArchived(docs.id, archived: true);
    expect((await database.watchBookmarks().first).length, 1);
    expect(
      (await database.watchBookmarks(includeArchived: true).first).length,
      2,
    );
    expect(await database.searchBookmarks('flutter'), isEmpty);

    await database.deleteBookmark(docs.id);
    expect(await database.getBookmark(docs.id), isNull);
    expect(
      (await database.watchBookmarks(includeArchived: true).first).length,
      1,
    );
  });

  test('search expenses by note, category and date', () async {
    final food = await categoryNamed('Food');
    final cash = await methodNamed('Cash');
    await database.addExpense(
      amountCents: 1250,
      currency: 'PEN',
      date: '2026-11-02',
      categoryId: food.id,
      paymentMethodId: cash.id,
      note: 'Lunch with Ana',
    );

    expect(
      (await database.searchExpenses('ana')).single.expense.note,
      'Lunch with Ana',
    );
    expect(
      (await database.searchExpenses('food')).single.category.name,
      'Food',
    );
    expect(
      (await database.searchExpenses('cash')).single.paymentMethod?.name,
      'Cash',
    );
    expect((await database.searchExpenses('2026-11-02')).length, 1);
    expect(await database.searchExpenses('nothing'), isEmpty);
  });

  test('aggregates totals by category, month and payment method', () async {
    final food = await categoryNamed('Food');
    final cash = await methodNamed('Cash');

    await database.addExpense(
      amountCents: 1250,
      currency: 'PEN',
      date: '2026-11-02',
      categoryId: food.id,
      paymentMethodId: cash.id,
    );
    await database.addExpense(
      amountCents: 800,
      currency: 'PEN',
      date: '2026-11-15',
      categoryId: food.id,
      paymentMethodId: cash.id,
    );
    await database.addExpense(
      amountCents: 500,
      currency: 'USD',
      date: '2026-11-20',
      categoryId: food.id,
    );

    final categoryTotals = await database
        .watchCategoryTotals(
          start: '2026-11-01',
          endExclusive: '2026-12-01',
          currency: 'PEN',
        )
        .first;
    expect(categoryTotals.length, 1);
    expect(categoryTotals.single.categoryId, food.id);
    expect(categoryTotals.single.totalCents, 2050);
    expect(categoryTotals.single.count, 2);

    final monthTotal = await database
        .watchMonthTotal(
          start: '2026-11-01',
          endExclusive: '2026-12-01',
          currency: 'PEN',
        )
        .first;
    expect(monthTotal, 2050);

    final usdTotal = await database
        .watchMonthTotal(
          start: '2026-11-01',
          endExclusive: '2026-12-01',
          currency: 'USD',
        )
        .first;
    expect(usdTotal, 500);

    final methodTotals = await database
        .watchPaymentMethodTotals(
          start: '2026-11-01',
          endExclusive: '2026-12-01',
          currency: 'PEN',
        )
        .first;
    expect(methodTotals.single.paymentMethodId, cash.id);
    expect(methodTotals.single.totalCents, 2050);
  });

  test('monthly totals are grouped by YYYY-MM', () async {
    final food = await categoryNamed('Food');

    await database.addExpense(
      amountCents: 1000,
      currency: 'PEN',
      date: '2026-09-10',
      categoryId: food.id,
    );
    await database.addExpense(
      amountCents: 2000,
      currency: 'PEN',
      date: '2026-10-10',
      categoryId: food.id,
    );
    await database.addExpense(
      amountCents: 3000,
      currency: 'PEN',
      date: '2026-10-20',
      categoryId: food.id,
    );

    final totals = await database
        .watchMonthlyTotals(
          start: '2026-09-01',
          endExclusive: '2026-11-01',
          currency: 'PEN',
        )
        .first;

    expect(totals.length, 2);
    expect(totals[0].month, '2026-09');
    expect(totals[0].totalCents, 1000);
    expect(totals[1].month, '2026-10');
    expect(totals[1].totalCents, 5000);
  });

  test('expenses are joined with category and payment method', () async {
    final food = await categoryNamed('Food');
    final cash = await methodNamed('Cash');

    await database.addExpense(
      amountCents: 1250,
      currency: 'PEN',
      date: '2026-11-02',
      categoryId: food.id,
      paymentMethodId: cash.id,
      note: 'Lunch',
    );

    final items = await database
        .watchExpenses(
          start: '2026-11-01',
          endExclusive: '2026-12-01',
          currency: 'PEN',
        )
        .first;

    expect(items.single.category.name, 'Food');
    expect(items.single.paymentMethod?.name, 'Cash');
    expect(items.single.expense.note, 'Lunch');
  });

  test('update and delete an expense', () async {
    final food = await categoryNamed('Food');
    await database.addExpense(
      amountCents: 1000,
      currency: 'PEN',
      date: '2026-11-02',
      categoryId: food.id,
    );

    final before = await database
        .watchExpenses(
          start: '2026-11-01',
          endExclusive: '2026-12-01',
          currency: 'PEN',
        )
        .first;

    await database.updateExpense(
      before.single.expense.id,
      amountCents: 1500,
      currency: 'PEN',
      date: '2026-11-03',
      categoryId: food.id,
    );

    final after = await database.getExpenseView(before.single.expense.id);
    expect(after?.expense.amountCents, 1500);
    expect(after?.expense.date, '2026-11-03');

    await database.deleteExpense(before.single.expense.id);
    expect(await database.getExpenseView(before.single.expense.id), isNull);
  });

  test('archiving hides a category but keeps its expenses', () async {
    final food = await categoryNamed('Food');
    await database.addExpense(
      amountCents: 1000,
      currency: 'PEN',
      date: '2026-11-02',
      categoryId: food.id,
    );

    await database.setCategoryArchived(food.id, archived: true);

    final active = await database.watchCategories().first;
    expect(active.any((item) => item.id == food.id), isFalse);

    final all = await database.watchCategories(includeArchived: true).first;
    expect(all.any((item) => item.id == food.id), isTrue);

    final total = await database
        .watchMonthTotal(
          start: '2026-11-01',
          endExclusive: '2026-12-01',
          currency: 'PEN',
        )
        .first;
    expect(total, 1000);
  });

  test('a category with expenses cannot be deleted', () async {
    final food = await categoryNamed('Food');
    await database.addExpense(
      amountCents: 1000,
      currency: 'PEN',
      date: '2026-11-02',
      categoryId: food.id,
    );

    expect(() => database.deleteCategory(food.id), throwsA(isA<StateError>()));
  });

  test('reorders categories', () async {
    final before = await database.watchCategories().first;
    final reversed = before.reversed.map((item) => item.id).toList();

    await database.reorderCategories(reversed);

    final after = await database.watchCategories().first;
    expect(after.map((item) => item.id).toList(), reversed);
  });

  test('creates, updates, reorders, archives and deletes templates', () async {
    final food = await categoryNamed('Food');
    final cash = await methodNamed('Cash');

    await database.addTemplate(
      name: 'Coffee',
      amountCents: 550,
      currency: 'PEN',
      categoryId: food.id,
      paymentMethodId: cash.id,
      note: 'Morning',
    );
    await database.addTemplate(
      name: 'Bus',
      amountCents: 200,
      currency: 'PEN',
      categoryId: food.id,
    );

    var active = await database.watchTemplates().first;
    expect(active.map((item) => item.name).toList(), ['Coffee', 'Bus']);
    expect(active.first.note, 'Morning');
    expect(await database.countTemplatesForCategory(food.id), 2);
    expect(await database.countTemplatesForPaymentMethod(cash.id), 1);

    await database.reorderTemplates([active[1].id, active[0].id]);
    active = await database.watchTemplates().first;
    expect(active.map((item) => item.name).toList(), ['Bus', 'Coffee']);

    final coffee = await templateNamed('Coffee');
    await database.updateTemplate(
      coffee.id,
      name: 'Flat white',
      amountCents: 650,
      currency: 'USD',
      categoryId: food.id,
      paymentMethodId: cash.id,
      note: 'Large',
    );
    final updated = await templateNamed('Flat white');
    expect(updated.amountCents, 650);
    expect(updated.currency, 'USD');
    expect(updated.note, 'Large');

    await database.setTemplateArchived(updated.id, archived: true);
    expect((await database.watchTemplates().first).length, 1);
    final all = await database.watchTemplates(includeArchived: true).first;
    expect(all.length, 2);
    expect(
      all.firstWhere((item) => item.id == updated.id).archivedAt,
      isNotNull,
    );

    await database.setTemplateArchived(updated.id, archived: false);
    expect((await database.watchTemplates().first).length, 2);

    await database.deleteTemplate(updated.id);
    expect((await database.watchTemplates().first).length, 1);
    expect(await database.countTemplatesForCategory(food.id), 1);
  });

  test(
    'a category or payment method used by a template cannot be deleted',
    () async {
      final food = await categoryNamed('Food');
      final cash = await methodNamed('Cash');
      await database.addTemplate(
        name: 'Coffee',
        amountCents: 550,
        currency: 'PEN',
        categoryId: food.id,
        paymentMethodId: cash.id,
      );

      expect(
        () => database.deleteCategory(food.id),
        throwsA(isA<StateError>()),
      );
      expect(
        () => database.deletePaymentMethod(cash.id),
        throwsA(isA<StateError>()),
      );
    },
  );

  test('export and import round-trip', () async {
    final food = await categoryNamed('Food');
    final cash = await methodNamed('Cash');
    await database.addExpense(
      amountCents: 1250,
      currency: 'PEN',
      date: '2026-11-02',
      categoryId: food.id,
      paymentMethodId: cash.id,
      note: 'Lunch',
    );
    await database.addTemplate(
      name: 'Lunch template',
      amountCents: 1250,
      currency: 'PEN',
      categoryId: food.id,
      paymentMethodId: cash.id,
      note: 'Lunch',
    );

    final backup = await database.exportJson();
    expect(backup['app'], 'xzifra');
    expect((backup['templates'] as List).length, 1);

    final restored = AppDatabase(NativeDatabase.memory());
    addTearDown(restored.close);

    final summary = await restored.importJson(backup);
    expect(summary.expenses, 1);
    expect(summary.templates, 1);
    expect(
      summary.total,
      summary.categories + summary.paymentMethods + summary.expenses + 1,
    );

    final total = await restored
        .watchMonthTotal(
          start: '2026-11-01',
          endExclusive: '2026-12-01',
          currency: 'PEN',
        )
        .first;
    expect(total, 1250);

    final items = await restored
        .watchExpenses(
          start: '2026-11-01',
          endExclusive: '2026-12-01',
          currency: 'PEN',
        )
        .first;
    expect(items.single.expense.note, 'Lunch');
    expect(items.single.category.name, 'Food');
    expect(items.single.paymentMethod?.icon, '💵');

    final templates = await restored.select(restored.templates).get();
    expect(templates.single.name, 'Lunch template');
    expect(templates.single.amountCents, 1250);
    expect(templates.single.paymentMethodId, cash.id);
    expect(templates.single.note, 'Lunch');
  });

  test('export and import round-trip includes notes and bookmarks', () async {
    await database.addNote(
      title: 'Packing list',
      body: 'Passport and charger',
      tags: 'travel, personal',
      pinned: true,
    );
    await database.addBookmark(
      url: 'https://example.com/guide',
      title: 'Travel guide',
      note: 'Read before the trip',
      tags: 'travel',
    );

    final backup = await database.exportJson();
    expect(backup['schemaVersion'], 4);
    expect((backup['notes'] as List).length, 1);
    expect((backup['bookmarks'] as List).length, 1);

    final restored = AppDatabase(NativeDatabase.memory());
    addTearDown(restored.close);

    final summary = await restored.importJson(backup);
    expect(summary.notes, 1);
    expect(summary.bookmarks, 1);
    expect(summary.notes + summary.bookmarks, 2);

    final notes = await restored.select(restored.notes).get();
    expect(notes.single.title, 'Packing list');
    expect(notes.single.body, 'Passport and charger');
    expect(notes.single.tags, 'travel, personal');
    expect(notes.single.pinned, isTrue);

    final bookmarks = await restored.select(restored.bookmarks).get();
    expect(bookmarks.single.url, 'https://example.com/guide');
    expect(bookmarks.single.title, 'Travel guide');
    expect(bookmarks.single.note, 'Read before the trip');
    expect(bookmarks.single.tags, 'travel');
  });

  test('imports an old backup without notes or bookmarks', () async {
    final backup = await database.exportJson();
    backup.remove('notes');
    backup.remove('bookmarks');
    backup['expenses'] = const [];

    final restored = AppDatabase(NativeDatabase.memory());
    addTearDown(restored.close);

    final summary = await restored.importJson(backup);
    expect(summary.notes, 0);
    expect(summary.bookmarks, 0);
    expect(await restored.select(restored.notes).get(), isEmpty);
    expect(await restored.select(restored.bookmarks).get(), isEmpty);
  });

  test('imports an old backup without templates', () async {
    final backup = await database.exportJson();
    backup.remove('templates');
    backup['expenses'] = const [];

    final restored = AppDatabase(NativeDatabase.memory());
    addTearDown(restored.close);

    final summary = await restored.importJson(backup);
    expect(summary.templates, 0);
    expect(await restored.select(restored.templates).get(), isEmpty);
  });

  test('skips imported templates that reference missing rows', () async {
    final food = await categoryNamed('Food');
    final cash = await methodNamed('Cash');
    final backup = await database.exportJson();
    backup['templates'] = [
      {
        'id': 'template-valid',
        'name': 'Coffee',
        'amountCents': 550,
        'currency': 'PEN',
        'categoryId': food.id,
        'paymentMethodId': cash.id,
      },
      {
        'id': 'template-bad-category',
        'name': 'Broken',
        'amountCents': 550,
        'currency': 'PEN',
        'categoryId': 'missing-category',
      },
      {
        'id': 'template-bad-method',
        'name': 'Broken method',
        'amountCents': 550,
        'currency': 'PEN',
        'categoryId': food.id,
        'paymentMethodId': 'missing-method',
      },
      {
        'id': 'template-bad-currency',
        'name': 'Euros',
        'amountCents': 550,
        'currency': 'EUR',
        'categoryId': food.id,
      },
    ];

    final restored = AppDatabase(NativeDatabase.memory());
    addTearDown(restored.close);

    final summary = await restored.importJson(backup);
    expect(summary.templates, 1);
    final templates = await restored.select(restored.templates).get();
    expect(templates.single.name, 'Coffee');
  });

  test('import rejects files that are not Xzifra backups', () async {
    expect(
      () => database.importJson({'app': 'something-else'}),
      throwsA(isA<FormatException>()),
    );
  });

  test('imports a v1 backup without payment icons', () async {
    await database.importJson({
      'app': 'xzifra',
      'schemaVersion': 1,
      'paymentMethods': [
        {'id': 'pm-old', 'name': 'Old wallet', 'type': 'cash', 'sortOrder': 9},
      ],
    });

    final imported = (await database.select(database.paymentMethods).get())
        .firstWhere((item) => item.id == 'pm-old');
    expect(imported.type, 'cash');
    expect(imported.icon, '💳');
  });
}
