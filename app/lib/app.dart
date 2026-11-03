import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_shortcuts.dart';
import 'core/locale_settings.dart';
import 'core/theme.dart';
import 'core/theme_settings.dart';
import 'core/widget_data_sync.dart';
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
      builder: (context, child) => _ShortcutLabelSync(
        child: WidgetDataSync(child: child ?? const SizedBox.shrink()),
      ),
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    );
  }
}

/// Keeps the launcher shortcut labels in sync with the resolved app language
/// and releases shortcut navigation after the router's first frame.
class _ShortcutLabelSync extends StatefulWidget {
  const _ShortcutLabelSync({required this.child});

  final Widget child;

  @override
  State<_ShortcutLabelSync> createState() => _ShortcutLabelSyncState();
}

class _ShortcutLabelSyncState extends State<_ShortcutLabelSync> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppShortcuts.markReady();
      WidgetDataSync.markReady();
      if (mounted) _syncLabels();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncLabels();
  }

  void _syncLabels() {
    final locale = Localizations.localeOf(context);
    if (_locale == locale) return;
    _locale = locale;
    AppShortcuts.updateLabels(AppLocalizations.of(context));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
