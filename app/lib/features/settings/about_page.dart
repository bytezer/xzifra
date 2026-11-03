import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme_settings.dart';
import '../../core/widgets/section_card.dart';
import '../../providers.dart';

const _repoUrl = 'https://github.com/bytezer/xzifra';
const _releasesUrl = 'https://github.com/bytezer/xzifra/releases';
const _issuesUrl = 'https://github.com/bytezer/xzifra/issues/new';
const _licenseUrl = 'https://github.com/bytezer/xzifra/blob/main/LICENSE';
const _lucideUrl = 'https://lucide.dev/icons/x';

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
    final info = ref.watch(packageInfoProvider);
    final initialTheme = ref.watch(initialThemeProvider);
    final preset =
        ref.watch(themePresetProvider).asData?.value ?? initialTheme.preset;
    final mode =
        ref.watch(themeModeProvider).asData?.value ?? initialTheme.mode;
    final currency = ref.watch(selectedCurrencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: info.when(
        data: (package) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _Header(package: package),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Data & privacy',
              child: Text(
                'All expenses, categories and settings live in a SQLite '
                'database on this device. Xzifra has no accounts, no analytics '
                'and no network access. Export a JSON backup before '
                'uninstalling the app.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Project',
              child: Column(
                children: [
                  _LinkTile(
                    icon: Icons.code,
                    title: 'Source code',
                    subtitle: 'github.com/bytezer/xzifra',
                    onTap: () => _open(context, _repoUrl),
                  ),
                  const Divider(height: 1),
                  _LinkTile(
                    icon: Icons.new_releases_outlined,
                    title: 'Releases & updates',
                    subtitle: 'Download the latest beta',
                    onTap: () => _open(context, _releasesUrl),
                  ),
                  const Divider(height: 1),
                  _LinkTile(
                    icon: Icons.bug_report_outlined,
                    title: 'Report an issue',
                    subtitle: 'Open a GitHub issue',
                    onTap: () => _open(context, _issuesUrl),
                  ),
                  const Divider(height: 1),
                  _LinkTile(
                    icon: Icons.share_outlined,
                    title: 'Share app',
                    subtitle: 'Send the release link',
                    trailingIcon: Icons.share,
                    onTap: _share,
                  ),
                  const Divider(height: 1),
                  _LinkTile(
                    icon: Icons.description_outlined,
                    title: 'MIT License',
                    subtitle: 'View the license on GitHub',
                    onTap: () => _open(context, _licenseUrl),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Diagnostics',
              child: Column(
                children: [
                  _LinkTile(
                    icon: Icons.copy_all_outlined,
                    title: 'Copy debug info',
                    subtitle: 'Version, build, commit and settings',
                    trailingIcon: Icons.copy,
                    onTap: () => _copyDebugInfo(
                      context,
                      package,
                      preset,
                      mode,
                      currency,
                    ),
                  ),
                  const Divider(height: 1),
                  _LinkTile(
                    icon: Icons.policy_outlined,
                    title: 'Open source licenses',
                    subtitle: 'Flutter, packages and the Lucide icon',
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: 'Xzifra',
                      applicationVersion:
                          '${package.version} (${package.buildNumber})',
                      applicationLegalese: 'MIT License · Made by xzero',
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
              title: 'Build',
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Version',
                    value: '${package.version} (${package.buildNumber})',
                  ),
                  _InfoRow(
                    label: 'Commit',
                    value: '$_buildCommit · $_buildBranch',
                  ),
                  _InfoRow(label: 'Built', value: _buildDate),
                  _InfoRow(
                    label: 'Theme',
                    value: preset.supportsLight
                        ? '${preset.label} · ${themeModeLabel(mode)}'
                        : '${preset.label} · Dark',
                  ),
                  _InfoRow(label: 'Currency', value: currency),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Made by xzero',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            TextButton.icon(
              onPressed: () => _open(context, _lucideUrl),
              icon: const Icon(Icons.brush_outlined, size: 16),
              label: const Text('Icon based on Lucide x (ISC/MIT)'),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('Could not read app information.')),
      ),
    );
  }

  Future<void> _open(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Could not open the link.')),
        );
      }
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open the link.')),
      );
    }
  }

  Future<void> _share() async {
    await SharePlus.instance.share(
      ShareParams(
        text:
            'Xzifra — a local-first expense tracker for Android.\n'
            '$_releasesUrl',
        subject: 'Xzifra',
      ),
    );
  }

  Future<void> _copyDebugInfo(
    BuildContext context,
    PackageInfo package,
    AppThemePreset preset,
    ThemeMode mode,
    String currency,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final themeLabel = preset.supportsLight
        ? '${preset.label} / ${themeModeLabel(mode)}'
        : '${preset.label} / dark';
    final text =
        '''
Xzifra ${package.version} (${package.buildNumber})
Commit: $_buildCommit ($_buildBranch)
Built: $_buildDate
Theme: $themeLabel
Currency: $currency
Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}
''';
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(const SnackBar(content: Text('Debug info copied.')));
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
          'Version ${package.version} (${package.buildNumber})',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A local-first expense tracker for Android.',
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
