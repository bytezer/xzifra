import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xzifra/app.dart';
import 'package:xzifra/data/database.dart';
import 'package:xzifra/domain/periods.dart';
import 'package:xzifra/providers.dart';

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  await tester.dragUntilVisible(
    target,
    find.byType(ListView).last,
    const Offset(0, -140),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('duplicates an expense as a new expense dated today', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database.select(database.categories).get();

    final category = (await database.select(database.categories).get())
        .firstWhere((item) => item.name == 'Food');
    final method = (await database.select(database.paymentMethods).get())
        .firstWhere((item) => item.name == 'Cash');
    final today = Periods.dateKey(DateTime.now());
    await database.addExpense(
      amountCents: 1250,
      currency: 'PEN',
      date: today,
      categoryId: category.id,
      paymentMethodId: method.id,
      note: 'Lunch',
    );
    final original = (await database.allExpenses()).single;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const XzifraApp(),
      ),
    );
    await _settle(tester);

    await tester.tap(find.text('Records'));
    await _settle(tester);
    await tester.tap(find.text('Expenses'));
    await _settle(tester);

    await tester.longPress(find.textContaining('Lunch'));
    await _settle(tester);

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Duplicate'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.text('Duplicate'));
    await _settle(tester);

    expect(find.text('Duplicate expense'), findsOneWidget);
    expect(find.textContaining('S/ 12.50'), findsWidgets);

    await _scrollTo(tester, find.widgetWithText(ChoiceChip, 'Food'));
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Food'))
          .selected,
      isTrue,
    );

    await _scrollTo(tester, find.widgetWithText(ChoiceChip, 'Cash'));
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Cash'))
          .selected,
      isTrue,
    );

    await _scrollTo(tester, find.widgetWithText(ChoiceChip, 'Today'));
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Today'))
          .selected,
      isTrue,
    );

    await _scrollTo(tester, find.byType(TextField));
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'Lunch',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Save expense'));
    await _settle(tester);

    final items = await database.allExpenses();
    expect(items.length, 2);

    final unchanged = items.firstWhere(
      (item) => item.expense.id == original.expense.id,
    );
    expect(unchanged.expense.amountCents, 1250);
    expect(unchanged.expense.note, 'Lunch');
    expect(unchanged.expense.date, today);

    final copy = items.firstWhere(
      (item) => item.expense.id != original.expense.id,
    );
    expect(copy.expense.amountCents, 1250);
    expect(copy.expense.currency, 'PEN');
    expect(copy.expense.date, Periods.dateKey(DateTime.now()));
    expect(copy.expense.note, 'Lunch');
    expect(copy.category.name, 'Food');
    expect(copy.paymentMethod?.name, 'Cash');

    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  });
}
