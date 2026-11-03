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

    final backup = await database.exportJson();
    expect(backup['app'], 'xzifra');

    final restored = AppDatabase(NativeDatabase.memory());
    addTearDown(restored.close);

    final summary = await restored.importJson(backup);
    expect(summary.expenses, 1);

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
