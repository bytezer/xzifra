import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/locale_settings.dart';
import 'core/theme_settings.dart';
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
    final license = await rootBundle.loadString(
      'assets/icon/LICENSE-lucide.txt',
    );
    yield LicenseEntryWithLineBreaks(['xzifra icon'], license);
  });
}
