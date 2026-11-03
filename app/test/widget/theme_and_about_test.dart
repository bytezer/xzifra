import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xzifra/app.dart';
import 'package:xzifra/data/database.dart';
import 'package:xzifra/features/settings/about_page.dart';
import 'package:xzifra/features/settings/settings_page.dart';
import 'package:xzifra/providers.dart';

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    PackageInfo.setMockInitialValues(
      appName: 'Xzifra',
      packageName: 'dev.xzero.xzifra',
      version: '0.1.0',
      buildNumber: '2',
      buildSignature: '',
    );
  });

  testWidgets('switches to Cyber Red and opens About', (tester) async {
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
    expect(find.text('Appearance'), findsOneWidget);

    await tester.tap(find.text('Theme'));
    await _settle(tester);
    expect(find.text('Cyber Red'), findsOneWidget);

    await tester.tap(find.text('Cyber Red'));
    await _settle(tester);

    expect(await database.getSetting('themePreset'), 'cyberRed');
    final settingsContext = tester.element(find.text('Appearance'));
    expect(Theme.of(settingsContext).brightness, Brightness.dark);
    expect(tester.takeException(), isNull);

    await tester.dragUntilVisible(
      find.text('About Xzifra'),
      find.descendant(
        of: find.byType(SettingsPage),
        matching: find.byType(Scrollable),
      ),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('About Xzifra'));
    await _settle(tester);

    expect(find.text('Source code'), findsOneWidget);
    expect(find.textContaining('0.1.0'), findsWidgets);

    await tester.dragUntilVisible(
      find.text('Copy debug info'),
      find.descendant(
        of: find.byType(AboutPage),
        matching: find.byType(Scrollable),
      ),
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    expect(find.text('Copy debug info'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  });
}
