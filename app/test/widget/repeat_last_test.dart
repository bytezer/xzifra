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

void main() {
  testWidgets('repeats the most recent expense from the dashboard', (
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
    await database.addExpense(
      amountCents: 1250,
      currency: 'PEN',
      date: Periods.dateKey(DateTime.now()),
      categoryId: category.id,
      note: 'Lunch',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const XzifraApp(),
      ),
    );
    await _settle(tester);

    await tester.dragUntilVisible(
      find.text('Repeat last'),
      find.byType(ListView).first,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Repeat last'));
    await _settle(tester);

    expect(find.text('Duplicate expense'), findsOneWidget);
    expect(find.textContaining('S/ 12.50'), findsWidgets);

    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  });
}
