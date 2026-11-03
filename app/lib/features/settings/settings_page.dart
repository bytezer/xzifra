import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/section_card.dart';
import '../../data/export_service.dart';
import '../../providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final defaultCurrency =
        ref.watch(defaultCurrencyProvider).asData?.value ?? 'PEN';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          children: [
            const _SectionLabel('Preferences'),
            Card(
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: const Icon(Icons.payments_outlined),
                title: const Text('Default currency'),
                subtitle: Text(
                  defaultCurrency == 'PEN' ? 'Soles (PEN)' : 'Dollars (USD)',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    _pickDefaultCurrency(context, ref, defaultCurrency),
              ),
            ),
            const _SectionLabel('Manage'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const Icon(Icons.category_outlined),
                    title: const Text('Categories'),
                    subtitle: const Text('Create, edit, reorder or archive'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/settings/categories'),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const Icon(Icons.credit_card_outlined),
                    title: const Text('Payment methods'),
                    subtitle: const Text('Cash, cards, Yape, Plin and more'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/settings/payment-methods'),
                  ),
                ],
              ),
            ),
            const _SectionLabel('Backup'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const Icon(Icons.ios_share_outlined),
                    title: const Text('Export JSON backup'),
                    subtitle: const Text('Full backup you can import later'),
                    onTap: () => _exportJson(context, ref),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const Icon(Icons.table_chart_outlined),
                    title: const Text('Export CSV'),
                    subtitle: const Text('Open your expenses in a spreadsheet'),
                    onTap: () => _exportCsv(context, ref),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const Icon(Icons.file_download_outlined),
                    title: const Text('Import JSON backup'),
                    subtitle: const Text('Merge a backup into this device'),
                    onTap: () => _importJson(context, ref),
                  ),
                ],
              ),
            ),
            const _SectionLabel('About'),
            SectionCard(
              title: 'Xzifra',
              child: Text(
                'Version 0.1.0\nA local-first expense tracker. All data stays on this device.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDefaultCurrency(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Default currency'),
        children: [
          for (final currency in ['PEN', 'USD'])
            ListTile(
              title: Text(currency == 'PEN' ? 'Soles (PEN)' : 'Dollars (USD)'),
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
    try {
      final service = ExportService(ref.read(databaseProvider));
      final file = await service.createJsonBackup();
      await service.shareFile(file, subject: 'Xzifra JSON backup');
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not export the backup.')),
      );
    }
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final service = ExportService(ref.read(databaseProvider));
      final file = await service.createCsvExport();
      await service.shareFile(file, subject: 'Xzifra CSV export');
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not export the CSV.')),
      );
    }
  }

  Future<void> _importJson(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final service = ExportService(ref.read(databaseProvider));
      final summary = await service.importJsonBackup();
      if (summary == null) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Processed ${summary.total} records '
            '(${summary.expenses} expenses).',
          ),
        ),
      );
    } on FormatException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not import this backup.')),
      );
    }
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
