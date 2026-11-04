import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xzifra/app.dart';
import 'package:xzifra/data/database.dart';
import 'package:xzifra/domain/periods.dart';
import 'package:xzifra/domain/recurrence.dart';
import 'package:xzifra/providers.dart';
import 'package:xzifra/routing/router.dart';

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

TextField _fieldWithLabel(WidgetTester tester, String label) {
  return tester
      .widgetList<TextField>(find.byType(TextField))
      .firstWhere((field) => field.decoration?.labelText == label);
}

Future<AppDatabase> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);
  await database.select(database.categories).get();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const XzifraApp(),
    ),
  );
  await _settle(tester);
  appRouter.go('/');
  await _settle(tester);
  return database;
}

void main() {
  testWidgets('creates and registers a recurring expense', (tester) async {
    final database = await _pumpApp(tester);

    await tester.tap(find.text('Records'));
    await _settle(tester);
    await tester.tap(find.text('Expenses'));
    await _settle(tester);
    await tester.tap(find.byTooltip('Recurring'));
    await _settle(tester);

    expect(find.text('No recurring expenses yet'), findsOneWidget);
    await tester.tap(
      find.widgetWithText(FilledButton, 'New recurring expense'),
    );
    await _settle(tester);
    expect(find.text('New recurring expense'), findsOneWidget);

    await tester.enterText(
      find.byWidget(_fieldWithLabel(tester, 'Name')),
      'Rent',
    );
    await tester.enterText(
      find.byWidget(_fieldWithLabel(tester, 'Amount')),
      '500.00',
    );
    await tester.tap(find.widgetWithText(ChoiceChip, 'Food'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await _settle(tester);

    var rules = await database.select(database.recurringExpenses).get();
    expect(rules.single.name, 'Rent');
    expect(rules.single.amountCents, 50000);
    expect(rules.single.categoryId, isNotEmpty);
    expect(find.text('Rent'), findsOneWidget);
    expect(find.text('Due now'), findsWidgets);

    final firstNextDate = rules.single.nextDate;
    await tester.tap(find.text('Register'));
    await _settle(tester);

    final expenses = await database.allExpenses();
    expect(expenses.length, 1);
    expect(expenses.single.expense.amountCents, 50000);
    expect(expenses.single.expense.date, firstNextDate);
    expect(expenses.single.expense.recurringId, rules.single.id);

    rules = await database.select(database.recurringExpenses).get();
    expect(rules.single.nextDate, isNot(firstNextDate));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  });

  testWidgets('quick capture saves a reminder and marks it done', (
    tester,
  ) async {
    final database = await _pumpApp(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await _settle(tester);
    expect(find.text('Reminder'), findsOneWidget);
    await tester.tap(find.text('Reminder'));
    await _settle(tester);
    expect(find.text('New reminder'), findsOneWidget);

    await tester.enterText(
      find.byWidget(_fieldWithLabel(tester, 'Title')),
      'Pay rent',
    );
    await tester.enterText(
      find.byWidget(_fieldWithLabel(tester, 'Tags')),
      'home, bills',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await _settle(tester);

    final reminders = await database.select(database.reminders).get();
    expect(reminders.single.title, 'Pay rent');
    expect(reminders.single.tags, 'home, bills');
    expect(reminders.single.doneAt, isNull);
    expect(reminders.single.dueAt.isAfter(DateTime.now()), isTrue);

    await tester.tap(find.text('Records'));
    await _settle(tester);
    await tester.ensureVisible(find.text('Reminders'));
    await tester.tap(find.text('Reminders'));
    await _settle(tester);
    expect(find.text('Pay rent'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'bills'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'bills'));
    await _settle(tester);
    expect(find.text('Pay rent'), findsOneWidget);

    await tester.tap(find.byTooltip('Mark as done'));
    await _settle(tester);
    final done = (await database.select(database.reminders).get()).single;
    expect(done.doneAt, isNotNull);
    expect(find.text('Done · 1'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  });

  testWidgets('home shows due recurring payments and upcoming reminders', (
    tester,
  ) async {
    final database = await _pumpApp(tester);
    final category = (await database.select(database.categories).get())
        .firstWhere((item) => item.name == 'Food');
    final yesterday = Periods.dateKey(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    await database.addRecurringExpense(
      name: 'Internet',
      amountCents: 9900,
      currency: 'PEN',
      categoryId: category.id,
      frequency: RecurringFrequency.monthly,
      interval: 1,
      nextDate: yesterday,
    );
    await database.addReminder(
      title: 'Water the plants',
      dueAt: DateTime.now().add(const Duration(hours: 3)),
      tags: '',
    );
    await _settle(tester);

    await tester.dragUntilVisible(
      find.text('Upcoming payments'),
      find.byType(ListView).first,
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    expect(find.text('Internet'), findsOneWidget);
    expect(find.textContaining('Due now'), findsOneWidget);

    await tester.tap(find.text('Register'));
    await _settle(tester);
    expect((await database.allExpenses()).length, 1);

    await tester.dragUntilVisible(
      find.text('Upcoming reminders'),
      find.byType(ListView).first,
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    expect(find.text('Water the plants'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  });
}
