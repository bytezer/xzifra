import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/locale_labels.dart';
import '../../core/locale_settings.dart';
import '../../core/theme_labels.dart';
import '../../core/theme_settings.dart';
import '../../data/export_service.dart';
import '../../providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final defaultCurrency =
        ref.watch(defaultCurrencyProvider).asData?.value ?? 'PEN';
    final initialTheme = ref.watch(initialThemeProvider);
    final preset =
        ref.watch(themePresetProvider).asData?.value ?? initialTheme.preset;
    final storedMode =
        ref.watch(themeModeProvider).asData?.value ?? initialTheme.mode;
    final initialLocale = ref.watch(initialLocaleProvider);
    final localeSetting =
        ref.watch(localeSettingProvider).asData?.value ?? initialLocale;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          children: [
            _SectionLabel(l10n.settingsAppearance),
            Card(
              child: Column(
                children: [
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const Icon(Icons.palette_outlined),
                    title: Text(l10n.settingsTheme),
                    subtitle: Text(themePresetLabel(l10n, preset)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _pickThemePreset(context, ref, preset),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    enabled: preset.supportsLight,
                    leading: const Icon(Icons.brightness_6_outlined),
                    title: Text(l10n.settingsThemeMode),
                    subtitle: Text(
                      preset.supportsLight
                          ? themeModeLabel(l10n, storedMode)
                          : l10n.settingsThemeModeFixed,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: preset.supportsLight
                        ? () => _pickThemeMode(context, ref, storedMode)
                        : null,
                  ),
                ],
              ),
            ),
            _SectionLabel(l10n.settingsPreferences),
            Card(
              child: Column(
                children: [
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const Icon(Icons.language),
                    title: Text(l10n.settingsLanguage),
                    subtitle: Text(languageLabel(l10n, localeSetting)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _pickLanguage(context, ref, localeSetting),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const Icon(Icons.payments_outlined),
                    title: Text(l10n.settingsDefaultCurrency),
                    subtitle: Text(
                      defaultCurrency == 'PEN'
                          ? l10n.settingsCurrencyPEN
                          : l10n.settingsCurrencyUSD,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        _pickDefaultCurrency(context, ref, defaultCurrency),
                  ),
                ],
              ),
            ),
            _SectionLabel(l10n.settingsManage),
            Card(
              child: Column(
                children: [
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const Icon(Icons.category_outlined),
                    title: Text(l10n.settingsCategories),
                    subtitle: Text(l10n.settingsCategoriesSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/settings/categories'),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const Icon(Icons.credit_card_outlined),
                    title: Text(l10n.settingsPaymentMethods),
                    subtitle: Text(l10n.settingsPaymentMethodsSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/settings/payment-methods'),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const Icon(Icons.bookmark_border),
                    title: Text(l10n.settingsTemplates),
                    subtitle: Text(l10n.settingsTemplatesSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/settings/templates'),
                  ),
                ],
              ),
            ),
            _SectionLabel(l10n.settingsBackup),
            Card(
              child: Column(
                children: [
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const Icon(Icons.ios_share_outlined),
                    title: Text(l10n.settingsExportJson),
                    subtitle: Text(l10n.settingsExportJsonSubtitle),
                    onTap: () => _exportJson(context, ref),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const Icon(Icons.table_chart_outlined),
                    title: Text(l10n.settingsExportCsv),
                    subtitle: Text(l10n.settingsExportCsvSubtitle),
                    onTap: () => _exportCsv(context, ref),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const Icon(Icons.file_download_outlined),
                    title: Text(l10n.settingsImportJson),
                    subtitle: Text(l10n.settingsImportJsonSubtitle),
                    onTap: () => _importJson(context, ref),
                  ),
                ],
              ),
            ),
            _SectionLabel(l10n.aboutTitle),
            Card(
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.settingsAbout),
                subtitle: Text(l10n.settingsAboutSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/about'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    AppLocale current,
  ) async {
    final l10n = context.l10n;
    final selected = await showModalBottomSheet<AppLocale>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                l10n.settingsLanguage,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final option in const [
              AppLocale.system,
              AppLocale.english,
              AppLocale.spanish,
            ])
              ListTile(
                title: Text(languageLabel(l10n, option)),
                trailing: option == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(option),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (selected == null || selected == current) return;
    await ref
        .read(databaseProvider)
        .setSetting('locale', selected.storageValue);
  }

  Future<void> _pickThemePreset(
    BuildContext context,
    WidgetRef ref,
    AppThemePreset current,
  ) async {
    final l10n = context.l10n;
    final selected = await showModalBottomSheet<AppThemePreset>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                l10n.settingsTheme,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final preset in AppThemePreset.values)
              _ThemePresetTile(
                preset: preset,
                selected: preset == current,
                onTap: () => Navigator.of(context).pop(preset),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (selected == null || selected == current) return;
    await ref
        .read(databaseProvider)
        .setSetting('themePreset', selected.storageValue);
  }

  Future<void> _pickThemeMode(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    final l10n = context.l10n;
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                l10n.settingsThemeMode,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final mode in const [
              ThemeMode.system,
              ThemeMode.light,
              ThemeMode.dark,
            ])
              ListTile(
                title: Text(themeModeLabel(l10n, mode)),
                subtitle: Text(themeModeDescription(l10n, mode)),
                trailing: mode == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(mode),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (selected == null || selected == current) return;
    await ref
        .read(databaseProvider)
        .setSetting('themeMode', themeModeStorageValue(selected));
  }

  Future<void> _pickDefaultCurrency(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final l10n = context.l10n;
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.settingsDefaultCurrency),
        children: [
          for (final currency in ['PEN', 'USD'])
            ListTile(
              title: Text(
                currency == 'PEN'
                    ? l10n.settingsCurrencyPEN
                    : l10n.settingsCurrencyUSD,
              ),
              trailing: current == currency ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(context).pop(currency),
            ),
        ],
      ),
    );
    if (picked == null) return;
    await ref.read(databaseProvider).setSetting('defaultCurrency', picked);
    ref.read(selectedCurrencyProvider.notifier).set(picked);
  }

  Future<void> _exportJson(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final service = ExportService(ref.read(databaseProvider));
      final file = await service.createJsonBackup();
      await service.shareFile(file, subject: 'Xzifra JSON backup');
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsExportError)));
    }
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final service = ExportService(ref.read(databaseProvider));
      final file = await service.createCsvExport();
      await service.shareFile(file, subject: 'Xzifra CSV export');
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsCsvError)));
    }
  }

  Future<void> _importJson(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final service = ExportService(ref.read(databaseProvider));
      final summary = await service.importJsonBackup();
      if (summary == null) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.settingsImportProcessed(
              summary.total,
              summary.expenses,
              summary.notes,
              summary.bookmarks,
            ),
          ),
        ),
      );
    } on FormatException {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsImportInvalid)),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsImportError)));
    }
  }
}

class _ThemePresetTile extends StatelessWidget {
  const _ThemePresetTile({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final AppThemePreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Expanded(child: Text(themePresetLabel(l10n, preset))),
            for (final color in preset.swatches)
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: scheme.outlineVariant),
                ),
              ),
            if (selected)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.check_circle,
                  size: 20,
                  color: scheme.primary,
                ),
              ),
          ],
        ),
        subtitle: Text(themePresetDescription(l10n, preset)),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
