import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import '../domain/money.dart';
import '../domain/reports.dart';

part 'database.g.dart';

@TableIndex(name: 'idx_expenses_date', columns: {#date})
@TableIndex(name: 'idx_expenses_category', columns: {#categoryId})
@TableIndex(name: 'idx_expenses_payment_method', columns: {#paymentMethodId})
class Expenses extends Table {
  TextColumn get id => text()();
  IntColumn get amountCents => integer()();
  TextColumn get currency => text().withLength(min: 3, max: 3)();

  /// Local calendar date as `YYYY-MM-DD`.
  TextColumn get date => text().withLength(min: 10, max: 10)();

  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get paymentMethodId =>
      text().nullable().references(PaymentMethods, #id)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => const ['CHECK (amount_cents > 0)'];
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get icon => text().withDefault(const Constant('📦'))();
  IntColumn get color => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class PaymentMethods extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 60)();

  /// Legacy type, kept for backups and backwards compatibility. The UI no
  /// longer exposes it: payment methods are user-defined like categories.
  TextColumn get type => text()();
  TextColumn get icon => text().withDefault(const Constant('💳'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Templates extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  IntColumn get amountCents => integer()();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get paymentMethodId =>
      text().nullable().references(PaymentMethods, #id)();
  TextColumn get note => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => const ['CHECK (amount_cents > 0)'];
}

class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get body => text().withDefault(const Constant(''))();

  /// Comma-separated tag list.
  TextColumn get tags => text().withDefault(const Constant(''))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Bookmarks extends Table {
  TextColumn get id => text()();
  TextColumn get url => text()();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();

  /// Comma-separated tag list.
  TextColumn get tags => text().withDefault(const Constant(''))();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class SettingsEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class ExpenseView {
  const ExpenseView({
    required this.expense,
    required this.category,
    required this.paymentMethod,
  });

  final Expense expense;
  final Category category;
  final PaymentMethod? paymentMethod;
}

class ImportSummary {
  const ImportSummary({
    required this.categories,
    required this.paymentMethods,
    required this.expenses,
    required this.templates,
    required this.notes,
    required this.bookmarks,
  });

  final int categories;
  final int paymentMethods;
  final int expenses;
  final int templates;
  final int notes;
  final int bookmarks;

  int get total =>
      categories + paymentMethods + expenses + templates + notes + bookmarks;
}

@DriftDatabase(
  tables: [
    Categories,
    PaymentMethods,
    Expenses,
    Templates,
    Notes,
    Bookmarks,
    SettingsEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  static const _uuid = Uuid();

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seed();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(paymentMethods, paymentMethods.icon);
        await _backfillPaymentMethodIcons();
      }
      if (from < 3) {
        await m.createTable(templates);
      }
      if (from < 4) {
        await m.createTable(notes);
        await m.createTable(bookmarks);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  Stream<List<ExpenseView>> watchExpenses({
    required String start,
    required String endExclusive,
    required String currency,
    String? categoryId,
    String? paymentMethodId,
  }) {
    final query = select(expenses).join([
      innerJoin(categories, categories.id.equalsExp(expenses.categoryId)),
      leftOuterJoin(
        paymentMethods,
        paymentMethods.id.equalsExp(expenses.paymentMethodId),
      ),
    ]);

    var predicate =
        expenses.currency.equals(currency) &
        expenses.date.isBiggerOrEqualValue(start) &
        expenses.date.isSmallerThanValue(endExclusive);
    if (categoryId != null) {
      predicate = predicate & expenses.categoryId.equals(categoryId);
    }
    if (paymentMethodId != null) {
      predicate = predicate & expenses.paymentMethodId.equals(paymentMethodId);
    }

    query
      ..where(predicate)
      ..orderBy([
        OrderingTerm.desc(expenses.date),
        OrderingTerm.desc(expenses.createdAt),
      ]);

    return query.watch().map(_mapRows);
  }

  Stream<List<ExpenseView>> watchRecentExpenses({
    required String currency,
    int limit = 5,
  }) {
    final query =
        select(expenses).join([
            innerJoin(categories, categories.id.equalsExp(expenses.categoryId)),
            leftOuterJoin(
              paymentMethods,
              paymentMethods.id.equalsExp(expenses.paymentMethodId),
            ),
          ])
          ..where(expenses.currency.equals(currency))
          ..orderBy([
            OrderingTerm.desc(expenses.date),
            OrderingTerm.desc(expenses.createdAt),
          ])
          ..limit(limit);

    return query.watch().map(_mapRows);
  }

  Future<List<ExpenseView>> allExpenses() async {
    final query = select(expenses).join([
      innerJoin(categories, categories.id.equalsExp(expenses.categoryId)),
      leftOuterJoin(
        paymentMethods,
        paymentMethods.id.equalsExp(expenses.paymentMethodId),
      ),
    ])..orderBy([OrderingTerm.desc(expenses.date)]);
    final rows = await query.get();
    return _mapRows(rows);
  }

  /// Most recent expenses across both currencies, newest first.
  Future<List<ExpenseView>> recentExpenses({int limit = 30}) async {
    final query =
        select(expenses).join([
            innerJoin(categories, categories.id.equalsExp(expenses.categoryId)),
            leftOuterJoin(
              paymentMethods,
              paymentMethods.id.equalsExp(expenses.paymentMethodId),
            ),
          ])
          ..orderBy([
            OrderingTerm.desc(expenses.date),
            OrderingTerm.desc(expenses.createdAt),
          ])
          ..limit(limit);
    final rows = await query.get();
    return _mapRows(rows);
  }

  Future<ExpenseView?> getExpenseView(String id) async {
    final query = select(expenses).join([
      innerJoin(categories, categories.id.equalsExp(expenses.categoryId)),
      leftOuterJoin(
        paymentMethods,
        paymentMethods.id.equalsExp(expenses.paymentMethodId),
      ),
    ])..where(expenses.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return ExpenseView(
      expense: row.readTable(expenses),
      category: row.readTable(categories),
      paymentMethod: row.readTableOrNull(paymentMethods),
    );
  }

  Stream<int> watchMonthTotal({
    required String start,
    required String endExclusive,
    required String currency,
  }) {
    return customSelect(
      'SELECT COALESCE(SUM(amount_cents), 0) AS total_cents '
      'FROM expenses WHERE currency = ? AND date >= ? AND date < ?',
      variables: [
        Variable.withString(currency),
        Variable.withString(start),
        Variable.withString(endExclusive),
      ],
      readsFrom: {expenses},
    ).watchSingle().map((row) => row.read<int>('total_cents'));
  }

  Stream<List<CategoryTotal>> watchCategoryTotals({
    required String start,
    required String endExclusive,
    required String currency,
  }) {
    return customSelect(
      'SELECT category_id AS category_id, '
      'SUM(amount_cents) AS total_cents, COUNT(*) AS entry_count '
      'FROM expenses WHERE currency = ? AND date >= ? AND date < ? '
      'GROUP BY category_id ORDER BY total_cents DESC',
      variables: [
        Variable.withString(currency),
        Variable.withString(start),
        Variable.withString(endExclusive),
      ],
      readsFrom: {expenses},
    ).watch().map(
      (rows) => [
        for (final row in rows)
          CategoryTotal(
            categoryId: row.read<String>('category_id'),
            totalCents: row.read<int>('total_cents'),
            count: row.read<int>('entry_count'),
          ),
      ],
    );
  }

  Stream<List<PaymentMethodTotal>> watchPaymentMethodTotals({
    required String start,
    required String endExclusive,
    required String currency,
  }) {
    return customSelect(
      'SELECT payment_method_id AS payment_method_id, '
      'SUM(amount_cents) AS total_cents, COUNT(*) AS entry_count '
      'FROM expenses WHERE currency = ? AND date >= ? AND date < ? '
      'GROUP BY payment_method_id ORDER BY total_cents DESC',
      variables: [
        Variable.withString(currency),
        Variable.withString(start),
        Variable.withString(endExclusive),
      ],
      readsFrom: {expenses},
    ).watch().map(
      (rows) => [
        for (final row in rows)
          PaymentMethodTotal(
            paymentMethodId: row.read<String?>('payment_method_id'),
            totalCents: row.read<int>('total_cents'),
            count: row.read<int>('entry_count'),
          ),
      ],
    );
  }

  Stream<List<MonthlyTotal>> watchMonthlyTotals({
    required String start,
    required String endExclusive,
    required String currency,
  }) {
    return customSelect(
      'SELECT substr(date, 1, 7) AS month, SUM(amount_cents) AS total_cents '
      'FROM expenses WHERE currency = ? AND date >= ? AND date < ? '
      'GROUP BY month ORDER BY month ASC',
      variables: [
        Variable.withString(currency),
        Variable.withString(start),
        Variable.withString(endExclusive),
      ],
      readsFrom: {expenses},
    ).watch().map(
      (rows) => [
        for (final row in rows)
          MonthlyTotal(
            month: row.read<String>('month'),
            totalCents: row.read<int>('total_cents'),
          ),
      ],
    );
  }

  Stream<List<Category>> watchCategories({bool includeArchived = false}) {
    final query = select(categories)
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.name),
      ]);
    if (!includeArchived) {
      query.where((t) => t.archivedAt.isNull());
    }
    return query.watch();
  }

  Stream<List<PaymentMethod>> watchPaymentMethods({
    bool includeArchived = false,
  }) {
    final query = select(paymentMethods)
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.name),
      ]);
    if (!includeArchived) {
      query.where((t) => t.archivedAt.isNull());
    }
    return query.watch();
  }

  Stream<List<Template>> watchTemplates({bool includeArchived = false}) {
    final query = select(templates)
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.name),
      ]);
    if (!includeArchived) {
      query.where((t) => t.archivedAt.isNull());
    }
    return query.watch();
  }

  Stream<List<Note>> watchNotes({bool includeArchived = false}) {
    final query = select(notes)
      ..orderBy([
        (t) => OrderingTerm.desc(t.pinned),
        (t) => OrderingTerm.desc(t.updatedAt),
      ]);
    if (!includeArchived) {
      query.where((t) => t.archivedAt.isNull());
    }
    return query.watch();
  }

  Stream<List<Note>> watchRecentNotes({int limit = 3}) {
    final query = (select(notes)..where((t) => t.archivedAt.isNull()))
      ..orderBy([
        (t) => OrderingTerm.desc(t.pinned),
        (t) => OrderingTerm.desc(t.updatedAt),
      ])
      ..limit(limit);
    return query.watch();
  }

  Future<Note?> getNote(String id) {
    return (select(notes)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<List<Bookmark>> watchBookmarks({bool includeArchived = false}) {
    final query = select(bookmarks)
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    if (!includeArchived) {
      query.where((t) => t.archivedAt.isNull());
    }
    return query.watch();
  }

  Stream<List<Bookmark>> watchRecentBookmarks({int limit = 3}) {
    final query = (select(bookmarks)..where((t) => t.archivedAt.isNull()))
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
      ..limit(limit);
    return query.watch();
  }

  Future<Bookmark?> getBookmark(String id) {
    return (select(bookmarks)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Case-insensitive [LIKE] search across notes, bookmarks and expenses.
  ///
  /// Archived records are intentionally excluded from global search.
  Future<List<ExpenseView>> searchExpenses(String query, {int limit = 50}) {
    final pattern = _likePattern(query);
    final statement = select(expenses).join([
      innerJoin(categories, categories.id.equalsExp(expenses.categoryId)),
      leftOuterJoin(
        paymentMethods,
        paymentMethods.id.equalsExp(expenses.paymentMethodId),
      ),
    ]);

    statement
      ..where(
        expenses.note.like(pattern, escapeChar: r'\') |
            categories.name.like(pattern, escapeChar: r'\') |
            paymentMethods.name.like(pattern, escapeChar: r'\') |
            expenses.date.like(pattern, escapeChar: r'\'),
      )
      ..orderBy([
        OrderingTerm.desc(expenses.date),
        OrderingTerm.desc(expenses.createdAt),
      ])
      ..limit(limit);

    return statement.get().then(_mapRows);
  }

  Future<List<Note>> searchNotes(String query, {int limit = 50}) {
    final pattern = _likePattern(query);
    return (select(notes)
          ..where(
            (t) =>
                t.archivedAt.isNull() &
                (t.title.like(pattern, escapeChar: r'\') |
                    t.body.like(pattern, escapeChar: r'\') |
                    t.tags.like(pattern, escapeChar: r'\')),
          )
          ..orderBy([
            (t) => OrderingTerm.desc(t.pinned),
            (t) => OrderingTerm.desc(t.updatedAt),
          ])
          ..limit(limit))
        .get();
  }

  Future<List<Bookmark>> searchBookmarks(String query, {int limit = 50}) {
    final pattern = _likePattern(query);
    return (select(bookmarks)
          ..where(
            (t) =>
                t.archivedAt.isNull() &
                (t.title.like(pattern, escapeChar: r'\') |
                    t.url.like(pattern, escapeChar: r'\') |
                    t.note.like(pattern, escapeChar: r'\') |
                    t.tags.like(pattern, escapeChar: r'\')),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
          ..limit(limit))
        .get();
  }

  Stream<String?> watchSetting(String key) {
    return (select(settingsEntries)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  Future<String?> getSetting(String key) async {
    final row = await (select(
      settingsEntries,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  // ---------------------------------------------------------------------------
  // Expense mutations
  // ---------------------------------------------------------------------------

  Future<void> addExpense({
    required int amountCents,
    required String currency,
    required String date,
    required String categoryId,
    String? paymentMethodId,
    String? note,
  }) async {
    final now = DateTime.now();
    await into(expenses).insert(
      ExpensesCompanion.insert(
        id: _uuid.v4(),
        amountCents: amountCents,
        currency: currency,
        date: date,
        categoryId: categoryId,
        paymentMethodId: Value(paymentMethodId),
        note: Value(note),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await _rememberLastUsed(categoryId, paymentMethodId);
  }

  Future<void> updateExpense(
    String id, {
    required int amountCents,
    required String currency,
    required String date,
    required String categoryId,
    String? paymentMethodId,
    String? note,
  }) async {
    await (update(expenses)..where((t) => t.id.equals(id))).write(
      ExpensesCompanion(
        amountCents: Value(amountCents),
        currency: Value(currency),
        date: Value(date),
        categoryId: Value(categoryId),
        paymentMethodId: Value(paymentMethodId),
        note: Value(note),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _rememberLastUsed(categoryId, paymentMethodId);
  }

  Future<void> deleteExpense(String id) async {
    await (delete(expenses)..where((t) => t.id.equals(id))).go();
  }

  Future<void> _rememberLastUsed(String categoryId, String? paymentMethodId) {
    return batch((b) {
      b.insert(
        settingsEntries,
        SettingsEntriesCompanion.insert(
          key: 'lastUsedCategoryId',
          value: categoryId,
        ),
        mode: InsertMode.insertOrReplace,
      );
      if (paymentMethodId != null) {
        b.insert(
          settingsEntries,
          SettingsEntriesCompanion.insert(
            key: 'lastUsedPaymentMethodId',
            value: paymentMethodId,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Category mutations
  // ---------------------------------------------------------------------------

  Future<void> addCategory({
    required String name,
    required String icon,
    required int color,
  }) async {
    final order = await _nextCategoryOrder();
    await into(categories).insert(
      CategoriesCompanion.insert(
        id: _uuid.v4(),
        name: name,
        icon: Value(icon),
        color: color,
        sortOrder: Value(order),
      ),
    );
  }

  Future<void> updateCategory(
    String id, {
    required String name,
    required String icon,
    required int color,
  }) async {
    await (update(categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(
        name: Value(name),
        icon: Value(icon),
        color: Value(color),
      ),
    );
  }

  Future<void> setCategoryArchived(String id, {required bool archived}) async {
    await (update(categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(archivedAt: Value(archived ? DateTime.now() : null)),
    );
  }

  Future<int> countExpensesForCategory(String id) async {
    final count = expenses.id.count();
    final row =
        await (selectOnly(expenses)
              ..addColumns([count])
              ..where(expenses.categoryId.equals(id)))
            .getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> countTemplatesForCategory(String id) async {
    final count = templates.id.count();
    final row =
        await (selectOnly(templates)
              ..addColumns([count])
              ..where(templates.categoryId.equals(id)))
            .getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> deleteCategory(String id) async {
    final expenseCount = await countExpensesForCategory(id);
    if (expenseCount > 0) {
      throw StateError(
        'Category has $expenseCount expenses; archive it instead.',
      );
    }
    final templateCount = await countTemplatesForCategory(id);
    if (templateCount > 0) {
      throw StateError(
        'Category has $templateCount templates; archive it instead.',
      );
    }
    await (delete(categories)..where((t) => t.id.equals(id))).go();
  }

  Future<void> reorderCategories(List<String> orderedIds) async {
    await batch((b) {
      for (var i = 0; i < orderedIds.length; i++) {
        b.update(
          categories,
          CategoriesCompanion(sortOrder: Value(i)),
          where: (t) => t.id.equals(orderedIds[i]),
        );
      }
    });
  }

  Future<int> _nextCategoryOrder() async {
    final maxOrder = categories.sortOrder.max();
    final row = await (selectOnly(
      categories,
    )..addColumns([maxOrder])).getSingle();
    return (row.read(maxOrder) ?? -1) + 1;
  }

  // ---------------------------------------------------------------------------
  // Payment method mutations
  // ---------------------------------------------------------------------------

  Future<void> addPaymentMethod({
    required String name,
    required String icon,
  }) async {
    final order = await _nextPaymentMethodOrder();
    await into(paymentMethods).insert(
      PaymentMethodsCompanion.insert(
        id: _uuid.v4(),
        name: name,
        type: 'custom',
        icon: Value(icon),
        sortOrder: Value(order),
      ),
    );
  }

  Future<void> updatePaymentMethod(
    String id, {
    required String name,
    required String icon,
  }) async {
    await (update(paymentMethods)..where((t) => t.id.equals(id))).write(
      PaymentMethodsCompanion(name: Value(name), icon: Value(icon)),
    );
  }

  Future<void> setPaymentMethodArchived(
    String id, {
    required bool archived,
  }) async {
    await (update(paymentMethods)..where((t) => t.id.equals(id))).write(
      PaymentMethodsCompanion(
        archivedAt: Value(archived ? DateTime.now() : null),
      ),
    );
  }

  Future<int> countExpensesForPaymentMethod(String id) async {
    final count = expenses.id.count();
    final row =
        await (selectOnly(expenses)
              ..addColumns([count])
              ..where(expenses.paymentMethodId.equals(id)))
            .getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> countTemplatesForPaymentMethod(String id) async {
    final count = templates.id.count();
    final row =
        await (selectOnly(templates)
              ..addColumns([count])
              ..where(templates.paymentMethodId.equals(id)))
            .getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> deletePaymentMethod(String id) async {
    final expenseCount = await countExpensesForPaymentMethod(id);
    if (expenseCount > 0) {
      throw StateError(
        'Payment method has $expenseCount expenses; archive it.',
      );
    }
    final templateCount = await countTemplatesForPaymentMethod(id);
    if (templateCount > 0) {
      throw StateError(
        'Payment method has $templateCount templates; archive it.',
      );
    }
    await (delete(paymentMethods)..where((t) => t.id.equals(id))).go();
  }

  Future<void> reorderPaymentMethods(List<String> orderedIds) async {
    await batch((b) {
      for (var i = 0; i < orderedIds.length; i++) {
        b.update(
          paymentMethods,
          PaymentMethodsCompanion(sortOrder: Value(i)),
          where: (t) => t.id.equals(orderedIds[i]),
        );
      }
    });
  }

  Future<int> _nextPaymentMethodOrder() async {
    final maxOrder = paymentMethods.sortOrder.max();
    final row = await (selectOnly(
      paymentMethods,
    )..addColumns([maxOrder])).getSingle();
    return (row.read(maxOrder) ?? -1) + 1;
  }

  // ---------------------------------------------------------------------------
  // Template mutations
  // ---------------------------------------------------------------------------

  Future<void> addTemplate({
    required String name,
    required int amountCents,
    required String currency,
    required String categoryId,
    String? paymentMethodId,
    String? note,
  }) async {
    final order = await _nextTemplateOrder();
    await into(templates).insert(
      TemplatesCompanion.insert(
        id: _uuid.v4(),
        name: name,
        amountCents: amountCents,
        currency: currency,
        categoryId: categoryId,
        paymentMethodId: Value(paymentMethodId),
        note: Value(note),
        sortOrder: Value(order),
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> updateTemplate(
    String id, {
    required String name,
    required int amountCents,
    required String currency,
    required String categoryId,
    String? paymentMethodId,
    String? note,
  }) async {
    await (update(templates)..where((t) => t.id.equals(id))).write(
      TemplatesCompanion(
        name: Value(name),
        amountCents: Value(amountCents),
        currency: Value(currency),
        categoryId: Value(categoryId),
        paymentMethodId: Value(paymentMethodId),
        note: Value(note),
      ),
    );
  }

  Future<void> setTemplateArchived(String id, {required bool archived}) async {
    await (update(templates)..where((t) => t.id.equals(id))).write(
      TemplatesCompanion(archivedAt: Value(archived ? DateTime.now() : null)),
    );
  }

  Future<void> deleteTemplate(String id) async {
    await (delete(templates)..where((t) => t.id.equals(id))).go();
  }

  Future<void> reorderTemplates(List<String> orderedIds) async {
    await batch((b) {
      for (var i = 0; i < orderedIds.length; i++) {
        b.update(
          templates,
          TemplatesCompanion(sortOrder: Value(i)),
          where: (t) => t.id.equals(orderedIds[i]),
        );
      }
    });
  }

  Future<int> _nextTemplateOrder() async {
    final maxOrder = templates.sortOrder.max();
    final row = await (selectOnly(
      templates,
    )..addColumns([maxOrder])).getSingle();
    return (row.read(maxOrder) ?? -1) + 1;
  }

  // ---------------------------------------------------------------------------
  // Note mutations
  // ---------------------------------------------------------------------------

  Future<void> addNote({
    required String title,
    required String body,
    required String tags,
    bool pinned = false,
  }) async {
    final now = DateTime.now();
    await into(notes).insert(
      NotesCompanion.insert(
        id: _uuid.v4(),
        title: title,
        body: Value(body),
        tags: Value(tags),
        pinned: Value(pinned),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> updateNote(
    String id, {
    required String title,
    required String body,
    required String tags,
    required bool pinned,
  }) async {
    await (update(notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(
        title: Value(title),
        body: Value(body),
        tags: Value(tags),
        pinned: Value(pinned),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setNotePinned(String id, {required bool pinned}) {
    return (update(notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(pinned: Value(pinned), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> setNoteArchived(String id, {required bool archived}) {
    return (update(notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(archivedAt: Value(archived ? DateTime.now() : null)),
    );
  }

  Future<void> deleteNote(String id) async {
    await (delete(notes)..where((t) => t.id.equals(id))).go();
  }

  // ---------------------------------------------------------------------------
  // Bookmark mutations
  // ---------------------------------------------------------------------------

  Future<void> addBookmark({
    required String url,
    required String title,
    String? note,
    required String tags,
  }) async {
    final now = DateTime.now();
    await into(bookmarks).insert(
      BookmarksCompanion.insert(
        id: _uuid.v4(),
        url: url,
        title: title,
        note: Value(note),
        tags: Value(tags),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> updateBookmark(
    String id, {
    required String url,
    required String title,
    String? note,
    required String tags,
  }) async {
    await (update(bookmarks)..where((t) => t.id.equals(id))).write(
      BookmarksCompanion(
        url: Value(url),
        title: Value(title),
        note: Value(note),
        tags: Value(tags),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setBookmarkArchived(String id, {required bool archived}) {
    return (update(bookmarks)..where((t) => t.id.equals(id))).write(
      BookmarksCompanion(archivedAt: Value(archived ? DateTime.now() : null)),
    );
  }

  Future<void> deleteBookmark(String id) async {
    await (delete(bookmarks)..where((t) => t.id.equals(id))).go();
  }

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------

  Future<void> setSetting(String key, String value) async {
    await into(settingsEntries).insertOnConflictUpdate(
      SettingsEntriesCompanion.insert(key: key, value: value),
    );
  }

  // ---------------------------------------------------------------------------
  // Backup
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> exportJson() async {
    final categoryRows = await select(categories).get();
    final methodRows = await select(paymentMethods).get();
    final expenseRows = await select(expenses).get();
    final templateRows = await select(templates).get();
    final noteRows = await select(notes).get();
    final bookmarkRows = await select(bookmarks).get();
    final settingRows = await select(settingsEntries).get();

    return {
      'app': 'xzifra',
      'schemaVersion': schemaVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'categories': [
        for (final row in categoryRows)
          {
            'id': row.id,
            'name': row.name,
            'icon': row.icon,
            'color': row.color,
            'sortOrder': row.sortOrder,
            'archivedAt': row.archivedAt?.toUtc().toIso8601String(),
          },
      ],
      'paymentMethods': [
        for (final row in methodRows)
          {
            'id': row.id,
            'name': row.name,
            'type': row.type,
            'icon': row.icon,
            'sortOrder': row.sortOrder,
            'archivedAt': row.archivedAt?.toUtc().toIso8601String(),
          },
      ],
      'expenses': [
        for (final row in expenseRows)
          {
            'id': row.id,
            'amountCents': row.amountCents,
            'currency': row.currency,
            'date': row.date,
            'categoryId': row.categoryId,
            'paymentMethodId': row.paymentMethodId,
            'note': row.note,
            'createdAt': row.createdAt.toUtc().toIso8601String(),
            'updatedAt': row.updatedAt.toUtc().toIso8601String(),
          },
      ],
      'settings': [
        for (final row in settingRows) {'key': row.key, 'value': row.value},
      ],
      'templates': [
        for (final row in templateRows)
          {
            'id': row.id,
            'name': row.name,
            'amountCents': row.amountCents,
            'currency': row.currency,
            'categoryId': row.categoryId,
            'paymentMethodId': row.paymentMethodId,
            'note': row.note,
            'sortOrder': row.sortOrder,
            'archivedAt': row.archivedAt?.toUtc().toIso8601String(),
            'createdAt': row.createdAt.toUtc().toIso8601String(),
          },
      ],
      'notes': [
        for (final row in noteRows)
          {
            'id': row.id,
            'title': row.title,
            'body': row.body,
            'tags': row.tags,
            'pinned': row.pinned,
            'archivedAt': row.archivedAt?.toUtc().toIso8601String(),
            'createdAt': row.createdAt.toUtc().toIso8601String(),
            'updatedAt': row.updatedAt.toUtc().toIso8601String(),
          },
      ],
      'bookmarks': [
        for (final row in bookmarkRows)
          {
            'id': row.id,
            'url': row.url,
            'title': row.title,
            'note': row.note,
            'tags': row.tags,
            'archivedAt': row.archivedAt?.toUtc().toIso8601String(),
            'createdAt': row.createdAt.toUtc().toIso8601String(),
            'updatedAt': row.updatedAt.toUtc().toIso8601String(),
          },
      ],
    };
  }

  /// Merges a backup into the current database. Existing records win.
  Future<ImportSummary> importJson(Map<String, dynamic> json) async {
    if (json['app'] != 'xzifra') {
      throw const FormatException('This file is not an Xzifra backup.');
    }

    final categoryList = (json['categories'] as List?) ?? const [];
    final methodList = (json['paymentMethods'] as List?) ?? const [];
    final expenseList = (json['expenses'] as List?) ?? const [];
    final templateList = (json['templates'] as List?) ?? const [];
    final noteList = (json['notes'] as List?) ?? const [];
    final bookmarkList = (json['bookmarks'] as List?) ?? const [];
    final settingList = (json['settings'] as List?) ?? const [];
    var importedTemplates = 0;

    await transaction(() async {
      for (final raw in categoryList) {
        final map = Map<String, dynamic>.from(raw as Map);
        await into(categories).insert(
          CategoriesCompanion.insert(
            id: map['id'] as String,
            name: map['name'] as String,
            icon: Value(map['icon'] as String? ?? '📦'),
            color: map['color'] as int,
            sortOrder: Value(map['sortOrder'] as int? ?? 0),
            archivedAt: Value(_parseDate(map['archivedAt'])),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }

      for (final raw in methodList) {
        final map = Map<String, dynamic>.from(raw as Map);
        await into(paymentMethods).insert(
          PaymentMethodsCompanion.insert(
            id: map['id'] as String,
            name: map['name'] as String,
            type: map['type'] as String? ?? 'custom',
            icon: Value(map['icon'] as String? ?? '💳'),
            sortOrder: Value(map['sortOrder'] as int? ?? 0),
            archivedAt: Value(_parseDate(map['archivedAt'])),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }

      final categoryIds = {
        for (final row in await select(categories).get()) row.id,
      };
      final methodIds = {
        for (final row in await select(paymentMethods).get()) row.id,
      };

      for (final raw in templateList) {
        final map = Map<String, dynamic>.from(raw as Map);
        final categoryId = map['categoryId'] as String?;
        if (categoryId == null || !categoryIds.contains(categoryId)) {
          // Skip templates that point at categories missing from this backup.
          continue;
        }
        final paymentMethodId = map['paymentMethodId'] as String?;
        if (paymentMethodId != null && !methodIds.contains(paymentMethodId)) {
          continue;
        }
        final currency = map['currency'] as String?;
        if (currency == null || !Money.supportedCurrencies.contains(currency)) {
          // The app only models PEN and USD.
          continue;
        }
        await into(templates).insert(
          TemplatesCompanion.insert(
            id: map['id'] as String,
            name: map['name'] as String,
            amountCents: map['amountCents'] as int,
            currency: currency,
            categoryId: categoryId,
            paymentMethodId: Value(paymentMethodId),
            note: Value(map['note'] as String?),
            sortOrder: Value(map['sortOrder'] as int? ?? 0),
            archivedAt: Value(_parseDate(map['archivedAt'])),
            createdAt: _parseDate(map['createdAt']) ?? DateTime.now(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
        importedTemplates++;
      }

      for (final raw in expenseList) {
        final map = Map<String, dynamic>.from(raw as Map);
        final createdAt = _parseDate(map['createdAt']) ?? DateTime.now();
        await into(expenses).insert(
          ExpensesCompanion.insert(
            id: map['id'] as String,
            amountCents: map['amountCents'] as int,
            currency: map['currency'] as String,
            date: map['date'] as String,
            categoryId: map['categoryId'] as String,
            paymentMethodId: Value(map['paymentMethodId'] as String?),
            note: Value(map['note'] as String?),
            createdAt: createdAt,
            updatedAt: _parseDate(map['updatedAt']) ?? createdAt,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }

      for (final raw in noteList) {
        final map = Map<String, dynamic>.from(raw as Map);
        final createdAt = _parseDate(map['createdAt']) ?? DateTime.now();
        await into(notes).insert(
          NotesCompanion.insert(
            id: map['id'] as String,
            title: map['title'] as String,
            body: Value(map['body'] as String? ?? ''),
            tags: Value(map['tags'] as String? ?? ''),
            pinned: Value(map['pinned'] as bool? ?? false),
            archivedAt: Value(_parseDate(map['archivedAt'])),
            createdAt: createdAt,
            updatedAt: _parseDate(map['updatedAt']) ?? createdAt,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }

      for (final raw in bookmarkList) {
        final map = Map<String, dynamic>.from(raw as Map);
        final createdAt = _parseDate(map['createdAt']) ?? DateTime.now();
        await into(bookmarks).insert(
          BookmarksCompanion.insert(
            id: map['id'] as String,
            url: map['url'] as String,
            title: map['title'] as String? ?? '',
            note: Value(map['note'] as String?),
            tags: Value(map['tags'] as String? ?? ''),
            archivedAt: Value(_parseDate(map['archivedAt'])),
            createdAt: createdAt,
            updatedAt: _parseDate(map['updatedAt']) ?? createdAt,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }

      for (final raw in settingList) {
        final map = Map<String, dynamic>.from(raw as Map);
        await into(settingsEntries).insert(
          SettingsEntriesCompanion.insert(
            key: map['key'] as String,
            value: map['value'] as String,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });

    return ImportSummary(
      categories: categoryList.length,
      paymentMethods: methodList.length,
      expenses: expenseList.length,
      templates: importedTemplates,
      notes: noteList.length,
      bookmarks: bookmarkList.length,
    );
  }

  // ---------------------------------------------------------------------------
  // Seed
  // ---------------------------------------------------------------------------

  List<ExpenseView> _mapRows(List<TypedResult> rows) {
    return [
      for (final row in rows)
        ExpenseView(
          expense: row.readTable(expenses),
          category: row.readTable(categories),
          paymentMethod: row.readTableOrNull(paymentMethods),
        ),
    ];
  }

  Future<void> _backfillPaymentMethodIcons() async {
    const icons = {
      'cash': '💵',
      'yape': '📱',
      'plin': '📱',
      'debit': '💳',
      'credit': '💳',
      'transfer': '🏦',
    };
    for (final entry in icons.entries) {
      await (update(paymentMethods)..where((t) => t.type.equals(entry.key)))
          .write(PaymentMethodsCompanion(icon: Value(entry.value)));
    }
  }

  Future<void> _seed() async {
    const seedCategories = [
      ('Food', '🍔', 0xFFE53935),
      ('Transport', '🚌', 0xFF1E88E5),
      ('Home', '🏠', 0xFF6D4C41),
      ('Utilities', '💡', 0xFFF9A825),
      ('Health', '🩺', 0xFF43A047),
      ('Leisure', '🎬', 0xFF8E24AA),
      ('Shopping', '🛍️', 0xFFD81B60),
      ('Education', '📚', 0xFF00897B),
      ('Other', '📦', 0xFF546E7A),
    ];

    const seedPaymentMethods = [
      ('Cash', 'cash', '💵'),
      ('Yape', 'yape', '📱'),
      ('Plin', 'plin', '📱'),
      ('Debit card', 'debit', '💳'),
      ('Credit card', 'credit', '💳'),
      ('Bank transfer', 'transfer', '🏦'),
    ];

    await batch((b) {
      for (var i = 0; i < seedCategories.length; i++) {
        final (name, icon, color) = seedCategories[i];
        b.insert(
          categories,
          CategoriesCompanion.insert(
            id: _uuid.v4(),
            name: name,
            icon: Value(icon),
            color: color,
            sortOrder: Value(i),
          ),
        );
      }
      for (var i = 0; i < seedPaymentMethods.length; i++) {
        final (name, type, icon) = seedPaymentMethods[i];
        b.insert(
          paymentMethods,
          PaymentMethodsCompanion.insert(
            id: _uuid.v4(),
            name: name,
            type: type,
            icon: Value(icon),
            sortOrder: Value(i),
          ),
        );
      }
      b.insert(
        settingsEntries,
        SettingsEntriesCompanion.insert(key: 'defaultCurrency', value: 'PEN'),
      );
    });
  }
}

DateTime? _parseDate(Object? value) {
  if (value is! String) return null;
  return DateTime.tryParse(value)?.toLocal();
}

String _likePattern(String query) {
  final escaped = query
      .trim()
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
  return '%$escaped%';
}

QueryExecutor _openConnection() => driftDatabase(name: 'xzifra');
