import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n.dart';
import '../../core/locale_labels.dart';
import '../../core/locale_settings.dart';
import '../../core/theme_labels.dart';
import '../../core/theme_settings.dart';
import '../../core/widgets/section_card.dart';
import '../../providers.dart';

const _repoUrl = 'https://github.com/bytezer/xzifra';
const _releasesUrl = 'https://github.com/bytezer/xzifra/releases';
const _issuesUrl = 'https://github.com/bytezer/xzifra/issues/new';
const _licenseUrl = 'https://github.com/bytezer/xzifra/blob/main/LICENSE';

const _buildCommit = String.fromEnvironment(
  'BUILD_COMMIT',
  defaultValue: 'dev',
);
const _buildBranch = String.fromEnvironment(
  'BUILD_BRANCH',
  defaultValue: 'main',
);
const _buildDate = String.fromEnvironment('BUILD_DATE', defaultValue: 'dev');

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final info = ref.watch(packageInfoProvider);
    final initialTheme = ref.watch(initialThemeProvider);
    final preset =
        ref.watch(themePresetProvider).asData?.value ?? initialTheme.preset;
    final mode =
        ref.watch(themeModeProvider).asData?.value ?? initialTheme.mode;
    final initialLocale = ref.watch(initialLocaleProvider);
    final localeSetting =
        ref.watch(localeSettingProvider).asData?.value ?? initialLocale;
    final currency = ref.watch(selectedCurrencyProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: info.when(
        data: (package) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _Header(package: package),
            const SizedBox(height: 20),
            SectionCard(
              title: l10n.aboutDataPrivacyTitle,
              child: Text(
                l10n.aboutDataPrivacy,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: l10n.aboutProject,
              child: Column(
                children: [
                  _LinkTile(
                    icon: Icons.code,
                    title: l10n.aboutSourceCode,
                    subtitle: l10n.aboutSourceCodeSubtitle,
                    onTap: () => _open(context, _repoUrl),
                  ),
                  const Divider(height: 1),
                  _LinkTile(
                    icon: Icons.new_releases_outlined,
                    title: l10n.aboutReleases,
                    subtitle: l10n.aboutReleasesSubtitle,
                    onTap: () => _open(context, _releasesUrl),
                  ),
                  const Divider(height: 1),
                  _LinkTile(
                    icon: Icons.bug_report_outlined,
                    title: l10n.aboutReportIssue,
                    subtitle: l10n.aboutReportIssueSubtitle,
                    onTap: () => _open(context, _issuesUrl),
                  ),
                  const Divider(height: 1),
                  _LinkTile(
                    icon: Icons.share_outlined,
                    title: l10n.aboutShareApp,
                    subtitle: l10n.aboutShareAppSubtitle,
                    trailingIcon: Icons.share,
                    onTap: () => _share(context),
                  ),
                  const Divider(height: 1),
                  _LinkTile(
                    icon: Icons.description_outlined,
                    title: l10n.aboutMitLicense,
                    subtitle: l10n.aboutMitLicenseSubtitle,
                    onTap: () => _open(context, _licenseUrl),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: l10n.aboutDiagnostics,
              child: Column(
                children: [
                  _LinkTile(
                    icon: Icons.copy_all_outlined,
                    title: l10n.aboutCopyDebugInfo,
                    subtitle: l10n.aboutCopyDebugInfoSubtitle,
                    trailingIcon: Icons.copy,
                    onTap: () => _copyDebugInfo(
                      context,
                      package,
                      preset,
                      mode,
                      localeSetting,
                      currency,
                    ),
                  ),
                  const Divider(height: 1),
                  _LinkTile(
                    icon: Icons.policy_outlined,
                    title: l10n.aboutLicenses,
                    subtitle: l10n.aboutLicensesSubtitle,
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: 'Xzifra',
                      applicationVersion: l10n.aboutVersionValue(
                        package.version,
                        package.buildNumber,
                      ),
                      applicationLegalese: l10n.aboutLegalese,
                      applicationIcon: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/icon/icon.png',
                          width: 48,
                          height: 48,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: l10n.aboutBuild,
              child: Column(
                children: [
                  _InfoRow(
                    label: l10n.aboutVersion,
                    value: l10n.aboutVersionValue(
                      package.version,
                      package.buildNumber,
                    ),
                  ),
                  _InfoRow(
                    label: l10n.aboutCommit,
                    value: '$_buildCommit · $_buildBranch',
                  ),
                  _InfoRow(label: l10n.aboutBuilt, value: _buildDate),
                  _InfoRow(
                    label: l10n.aboutTheme,
                    value: preset.supportsLight
                        ? '${themePresetLabel(l10n, preset)} · '
                              '${themeModeLabel(l10n, mode)}'
                        : '${themePresetLabel(l10n, preset)} · '
                              '${l10n.settingsThemeDark}',
                  ),
                  _InfoRow(
                    label: l10n.aboutLanguage,
                    value: languageLabel(l10n, localeSetting),
                  ),
                  _InfoRow(label: l10n.aboutCurrency, value: currency),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.aboutMadeBy,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.aboutIconCredit,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(l10n.aboutLoadError)),
      ),
    );
  }

  Future<void> _open(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.aboutLinkError)));
      }
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.aboutLinkError)));
    }
  }

  Future<void> _share(BuildContext context) async {
    final l10n = context.l10n;
    await SharePlus.instance.share(
      ShareParams(text: l10n.aboutShareText(_releasesUrl), subject: 'Xzifra'),
    );
  }

  Future<void> _copyDebugInfo(
    BuildContext context,
    PackageInfo package,
    AppThemePreset preset,
    ThemeMode mode,
    AppLocale localeSetting,
    String currency,
  ) async {
    final l10n = context.l10n;
    final themeValue = preset.supportsLight
        ? '${preset.storageValue} / ${themeModeStorageValue(mode)}'
        : '${preset.storageValue} / dark';
    final text =
        '''
Xzifra ${package.version} (${package.buildNumber})
Commit: $_buildCommit ($_buildBranch)
Built: $_buildDate
Theme: $themeValue
Language: ${localeSetting.storageValue}
Currency: $currency
Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}
''';
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.aboutDebugCopied)));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.package});

  final PackageInfo package;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset('assets/icon/icon.png', width: 88, height: 88),
        ),
        const SizedBox(height: 12),
        Text(
          'Xzifra',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.aboutVersionValue(package.version, package.buildNumber),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.aboutTagline,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingIcon = Icons.open_in_new,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyMedium),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(trailingIcon, size: 16, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
