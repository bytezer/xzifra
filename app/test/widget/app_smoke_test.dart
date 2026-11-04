import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xzifra/app.dart';
import 'package:xzifra/data/database.dart';
import 'package:xzifra/providers.dart';

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('records an expense and shows it on the dashboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    // Make sure the schema exists and the seed has been written before the
    // widget tree subscribes to the database streams.
    await database.select(database.categories).get();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const XzifraApp(),
      ),
    );
    await _settle(tester);

    expect(find.text('Spent this month'), findsOneWidget);
    expect(find.text('No expenses this month'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(FloatingActionButton));
    await _settle(tester);
    await tester.tap(find.text('Expense'));
    await _settle(tester);
    expect(find.text('New expense'), findsOneWidget);

    for (final key in ['1', '2', '.', '5']) {
      await tester.tap(find.widgetWithText(TextButton, key));
      await tester.pump();
    }

    await tester.dragUntilVisible(
      find.widgetWithText(ChoiceChip, 'Food'),
      find.byType(ListView).last,
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Food'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save expense'));
    await _settle(tester);

    expect(find.text('Spent this month'), findsOneWidget);
    expect(find.textContaining('S/ 12.50'), findsWidgets);
    expect(tester.takeException(), isNull);

    // Dispose the provider scope while the test is still running so Drift can
    // flush the zero-duration timers it schedules when a stream is cancelled.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  });
}
