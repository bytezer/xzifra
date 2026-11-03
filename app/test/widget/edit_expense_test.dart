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
  testWidgets('opens an existing expense in edit mode', (tester) async {
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
    await database.addExpense(
      amountCents: 1250,
      currency: 'PEN',
      date: Periods.dateKey(DateTime.now()),
      categoryId: category.id,
      paymentMethodId: method.id,
      note: 'Lunch',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const XzifraApp(),
      ),
    );
    await _settle(tester);

    await tester.tap(find.text('Expenses'));
    await _settle(tester);

    await tester.tap(find.textContaining('Lunch'));
    await _settle(tester);

    expect(find.text('Edit expense'), findsOneWidget);
    expect(find.textContaining('S/ 12.50'), findsWidgets);
    expect(find.text('Save changes'), findsOneWidget);
    expect(find.text('Save & add another'), findsNothing);

    await _scrollTo(tester, find.widgetWithText(ChoiceChip, 'Food'));
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Food'))
          .selected,
      isTrue,
    );

    await _scrollTo(tester, find.byType(TextField));
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'Lunch',
    );

    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  });
}
