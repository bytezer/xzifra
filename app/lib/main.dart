import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/app_shortcuts.dart';
import 'core/locale_settings.dart';
import 'core/notifications.dart';
import 'core/theme_settings.dart';
import 'core/widget_data_sync.dart';
import 'data/database.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  _registerLicenses();

  // Read the theme and locale before the first frame so a Cyber Red or Spanish
  // user never sees an indigo/English flash while the database opens.
  var initialTheme = const AppThemeSettings();
  var initialLocale = AppLocale.system;
  AppDatabase? preloaded;
  try {
    preloaded = AppDatabase();
    initialTheme = AppThemeSettings(
      preset: parseThemePreset(await preloaded.getSetting('themePreset')),
      mode: parseThemeMode(await preloaded.getSetting('themeMode')),
    );
    initialLocale = parseAppLocale(await preloaded.getSetting('locale'));
  } catch (_) {
    await preloaded?.close();
    preloaded = null;
  }

  // Read the launch shortcut before the first frame. Actions that arrive
  // before the router is mounted are kept pending by AppShortcuts.
  await AppShortcuts.initialize();

  // Prepare local notifications and restore pending reminder schedules. Any
  // notification tap that launched the app is kept pending until the router is
  // mounted.
  await NotificationService.instance.initialize();
  if (preloaded != null) {
    await NotificationService.instance.reschedulePending(preloaded);
  }

  // Widget taps can arrive before or after the router mounts; WidgetDataSync
  // holds an early action until the first frame.
  await WidgetDataSync.initialize();

  runApp(
    ProviderScope(
      overrides: [
        if (preloaded != null) databaseProvider.overrideWithValue(preloaded),
        initialThemeProvider.overrideWithValue(initialTheme),
        initialLocaleProvider.overrideWithValue(initialLocale),
      ],
      child: const XzifraApp(),
    ),
  );
}

void _registerLicenses() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/icon/LICENSE-icon.txt');
    yield LicenseEntryWithLineBreaks(['xzifra icon'], license);
  });
}
