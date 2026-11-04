import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
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
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('switches to Spanish and persists it', (tester) async {
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

    await tester.tap(find.text('Settings'));
    await _settle(tester);
    expect(find.text('Language'), findsOneWidget);

    await tester.tap(find.text('Language'));
    await _settle(tester);
    await tester.tap(find.text('Español'));
    await _settle(tester);

    expect(await database.getSetting('locale'), 'es');
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Registros'), findsOneWidget);
    expect(find.text('Reportes'), findsOneWidget);
    expect(find.text('Ajustes'), findsWidgets);
    expect(find.text('Idioma'), findsOneWidget);

    await tester.tap(find.text('Registros'));
    await _settle(tester);
    expect(find.text('Gastos'), findsOneWidget);
    expect(find.text('Notas'), findsOneWidget);
    expect(find.text('Marcadores'), findsOneWidget);
    expect(find.text('Recordatorios'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  });
}
