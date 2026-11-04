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
  // A bottom sheet closes before the follow-up action runs, so give the
  // remaining database streams another slice of real async time.
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

TextField _fieldWithLabel(WidgetTester tester, String label) {
  return tester
      .widgetList<TextField>(find.byType(TextField))
      .firstWhere((field) => field.decoration?.labelText == label);
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

  testWidgets('saves an expense as a template without changing it', (
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

    await tester.tap(find.text('Expenses'));
    await _settle(tester);

    await tester.longPress(find.textContaining('Lunch'));
    await _settle(tester);

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Duplicate'), findsOneWidget);
    expect(find.text('Save as template'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.text('Save as template'));
    await _settle(tester);

    // The template editor opens prefilled; the expense edit form never does.
    expect(find.text('New template'), findsOneWidget);
    expect(find.text('Edit expense'), findsNothing);
    expect(
      find.text("This only creates a template. Your expense won't change."),
      findsOneWidget,
    );
    expect(_fieldWithLabel(tester, 'Name').controller?.text, 'Lunch');
    expect(_fieldWithLabel(tester, 'Amount').controller?.text, '12.50');
    expect(_fieldWithLabel(tester, 'Note').controller?.text, 'Lunch');

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

    // The original expense is untouched.
    final unchanged = (await database.allExpenses()).single;
    expect(unchanged.expense.id, original.expense.id);
    expect(unchanged.expense.amountCents, original.expense.amountCents);
    expect(unchanged.expense.currency, original.expense.currency);
    expect(unchanged.expense.date, today);
    expect(unchanged.expense.categoryId, category.id);
    expect(unchanged.expense.paymentMethodId, method.id);
    expect(unchanged.expense.note, 'Lunch');
    expect(unchanged.expense.updatedAt, original.expense.updatedAt);
    expect(unchanged.category.name, 'Food');
    expect(unchanged.paymentMethod?.name, 'Cash');

    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  });

  testWidgets(
    'creates a template from an expense picked on the templates page',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final categories = await database.select(database.categories).get();
      final food = categories.firstWhere((item) => item.name == 'Food');
      final transport = categories.firstWhere(
        (item) => item.name == 'Transport',
      );
      final method = (await database.select(database.paymentMethods).get())
          .firstWhere((item) => item.name == 'Cash');
      final today = Periods.dateKey(DateTime.now());
      await database.addExpense(
        amountCents: 1250,
        currency: 'PEN',
        date: today,
        categoryId: food.id,
        paymentMethodId: method.id,
        note: 'Lunch',
      );
      await database.addExpense(
        amountCents: 500,
        currency: 'USD',
        date: today,
        categoryId: transport.id,
        paymentMethodId: method.id,
        note: 'Bus',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(database)],
          child: const XzifraApp(),
        ),
      );
      await _settle(tester);

      await tester.tap(find.text('Settings'));
      await _settle(tester);
      await _scrollTo(tester, find.text('Templates'));
      await tester.tap(find.text('Templates'));
      await _settle(tester);

      await tester.tap(find.byTooltip('From an expense'));
      await _settle(tester);

      // Both currencies are offered in the picker.
      expect(find.text('Pick an expense'), findsOneWidget);
      expect(find.text('S/ 12.50'), findsOneWidget);
      expect(find.text(r'$5.00'), findsOneWidget);

      await tester.tap(find.text('Food'));
      await _settle(tester);

      expect(find.text('New template'), findsOneWidget);
      expect(
        find.text("This only creates a template. Your expense won't change."),
        findsOneWidget,
      );
      expect(_fieldWithLabel(tester, 'Name').controller?.text, 'Lunch');
      expect(_fieldWithLabel(tester, 'Amount').controller?.text, '12.50');

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await _settle(tester);

      expect(find.text('Template saved.'), findsOneWidget);

      final templates = await database.select(database.templates).get();
      expect(templates.length, 1);
      expect(templates.single.name, 'Lunch');
      expect(templates.single.amountCents, 1250);
      expect(templates.single.currency, 'PEN');
      expect(templates.single.categoryId, food.id);
      expect(templates.single.paymentMethodId, method.id);
      expect(templates.single.note, 'Lunch');

      // Picking an expense never modifies it.
      final expenses = await database.allExpenses();
      expect(expenses.length, 2);
      expect(
        expenses
            .firstWhere((item) => item.category.name == 'Food')
            .expense
            .note,
        'Lunch',
      );

      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 20));
    },
  );
}
