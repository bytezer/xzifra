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

Future<void> _scrollTo(
  WidgetTester tester,
  Finder target, {
  bool up = false,
}) async {
  await tester.dragUntilVisible(
    target,
    find.byType(ListView).last,
    Offset(0, up ? 300 : -140),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('saves and keeps the form ready for another expense', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database.select(database.categories).get();

    final today = Periods.dateKey(DateTime.now());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const XzifraApp(),
      ),
    );
    await _settle(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await _settle(tester);
    await tester.tap(find.text('Expense'));
    await _settle(tester);

    expect(find.text('New expense'), findsOneWidget);
    expect(find.text('Save & add another'), findsOneWidget);
    expect(find.text('Save changes'), findsNothing);

    for (final key in ['1', '2', '.', '5']) {
      await tester.tap(find.widgetWithText(TextButton, key));
      await tester.pump();
    }

    await _scrollTo(tester, find.widgetWithText(ChoiceChip, 'Food'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Food'));
    await tester.pump();

    await _scrollTo(tester, find.widgetWithText(ChoiceChip, 'Cash'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Cash'));
    await tester.pump();

    await _scrollTo(tester, find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Lunch');
    await tester.pump();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Save & add another'));
    await _settle(tester);

    expect(find.text('New expense'), findsOneWidget);
    expect(find.text('Expense saved. Add another.'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      isEmpty,
    );

    final firstItems = await database.allExpenses();
    expect(firstItems.length, 1);
    expect(firstItems.single.expense.amountCents, 1250);
    expect(firstItems.single.expense.date, today);
    expect(firstItems.single.expense.currency, 'PEN');
    expect(firstItems.single.expense.note, 'Lunch');
    expect(firstItems.single.category.name, 'Food');
    expect(firstItems.single.paymentMethod?.name, 'Cash');

    // The amount is cleared and the keypad stays usable for the next entry.
    await _scrollTo(tester, find.text('Amount'), up: true);
    for (final key in ['2', '5']) {
      await tester.tap(find.widgetWithText(TextButton, key));
      await tester.pump();
    }
    expect(find.textContaining('S/ 25'), findsWidgets);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Save & add another'));
    await _settle(tester);

    final items = await database.allExpenses();
    expect(items.length, 2);
    expect(items.every((item) => item.expense.date == today), isTrue);
    expect(items.every((item) => item.expense.currency == 'PEN'), isTrue);
    expect(items.every((item) => item.category.name == 'Food'), isTrue);
    expect(items.every((item) => item.paymentMethod?.name == 'Cash'), isTrue);
    expect(items.map((item) => item.expense.amountCents).toSet(), {1250, 2500});

    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  });
}
