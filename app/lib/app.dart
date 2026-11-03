import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/locale_settings.dart';
import 'core/theme.dart';
import 'core/theme_settings.dart';
import 'l10n/app_localizations.dart';
import 'providers.dart';
import 'routing/router.dart';

class XzifraApp extends ConsumerWidget {
  const XzifraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(defaultCurrencyProvider, (previous, next) {
      final currency = next.asData?.value;
      if (currency != null) {
        ref.read(selectedCurrencyProvider.notifier).set(currency);
      }
    });

    final initialTheme = ref.watch(initialThemeProvider);
    final preset =
        ref.watch(themePresetProvider).asData?.value ?? initialTheme.preset;
    final storedMode =
        ref.watch(themeModeProvider).asData?.value ?? initialTheme.mode;
    final effectiveMode = preset.supportsLight ? storedMode : ThemeMode.dark;

    final initialLocale = ref.watch(initialLocaleProvider);
    final localeSetting =
        ref.watch(localeSettingProvider).asData?.value ?? initialLocale;

    return MaterialApp.router(
      title: 'Xzifra',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(preset: preset, brightness: Brightness.light),
      darkTheme: buildAppTheme(preset: preset, brightness: Brightness.dark),
      themeMode: effectiveMode,
      routerConfig: appRouter,
      locale: localeSetting.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    );
  }
}
