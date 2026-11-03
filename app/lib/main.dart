import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/theme_settings.dart';
import 'data/database.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerLicenses();

  // Read the theme before the first frame so a Cyber Red user never sees an
  // indigo flash while the database opens.
  var initialTheme = const AppThemeSettings();
  AppDatabase? preloaded;
  try {
    preloaded = AppDatabase();
    initialTheme = AppThemeSettings(
      preset: parseThemePreset(await preloaded.getSetting('themePreset')),
      mode: parseThemeMode(await preloaded.getSetting('themeMode')),
    );
  } catch (_) {
    await preloaded?.close();
    preloaded = null;
  }

  runApp(
    ProviderScope(
      overrides: [
        if (preloaded != null) databaseProvider.overrideWithValue(preloaded),
        initialThemeProvider.overrideWithValue(initialTheme),
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
