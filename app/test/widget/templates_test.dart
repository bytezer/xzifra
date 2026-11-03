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
  testWidgets('fills and saves an expense from a template', (tester) async {
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
    await database.addTemplate(
      name: 'Coffee',
      amountCents: 1250,
      currency: 'PEN',
      categoryId: category.id,
      paymentMethodId: method.id,
      note: 'Morning coffee',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const XzifraApp(),
      ),
    );
    await _settle(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await _settle(tester);

    expect(find.text('New expense'), findsOneWidget);
    expect(find.text('Use template'), findsOneWidget);

    await tester.tap(find.text('Use template'));
    await _settle(tester);

    expect(find.text('Choose a template'), findsOneWidget);
    await tester.tap(find.text('Coffee'));
    await _settle(tester);

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
      'Morning coffee',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Save expense'));
    await _settle(tester);

    final items = await database.allExpenses();
    expect(items.length, 1);
    expect(items.single.expense.amountCents, 1250);
    expect(items.single.expense.note, 'Morning coffee');
    expect(items.single.expense.date, Periods.dateKey(DateTime.now()));
    expect(items.single.category.name, 'Food');
    expect(items.single.paymentMethod?.name, 'Cash');

    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  });

  testWidgets('saves an edited expense as a template', (tester) async {
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
    await tester.tap(find.byTooltip('Save as template'));
    await _settle(tester);

    expect(find.text('New template'), findsOneWidget);
    final fields = tester.widgetList<TextField>(find.byType(TextField));
    expect(fields.any((field) => field.controller?.text == 'Lunch'), isTrue);
    expect(fields.any((field) => field.controller?.text == '12.50'), isTrue);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await _settle(tester);

    expect(find.text('Template saved.'), findsOneWidget);

    final templates = await database.select(database.templates).get();
    expect(templates.length, 1);
    expect(templates.single.name, 'Lunch');
    expect(templates.single.amountCents, 1250);
    expect(templates.single.currency, 'PEN');
    expect(templates.single.categoryId, category.id);
    expect(templates.single.paymentMethodId, method.id);
    expect(templates.single.note, 'Lunch');

    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  });
}
