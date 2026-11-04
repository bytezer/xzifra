import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/recurrence_labels.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/database.dart';
import '../../domain/money.dart';
import '../../domain/periods.dart';
import '../../domain/recurrence.dart';
import '../../providers.dart';

class RecurringPage extends ConsumerWidget {
  const RecurringPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = localeNameOf(context);
    final rules =
        ref.watch(recurringExpensesProvider).asData?.value ??
        const <RecurringExpense>[];
    final categories =
        ref.watch(allCategoriesProvider).asData?.value ?? const <Category>[];
    final categoriesById = {for (final item in categories) item.id: item};
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recurringTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/recurring/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.actionAdd),
      ),
      body: rules.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: EmptyState(
                  icon: Icons.event_repeat,
                  title: l10n.recurringEmptyTitle,
                  message: l10n.recurringEmptyMessage,
                  action: FilledButton.icon(
                    onPressed: () => context.push('/recurring/new'),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.recurringNewTitle),
                  ),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                for (final rule in rules) ...[
                  _RecurringTile(
                    rule: rule,
                    category: categoriesById[rule.categoryId],
                    due: isRecurringDue(
                      active: rule.active,
                      nextDate: rule.nextDate,
                      endDate: rule.endDate,
                      today: today,
                    ),
                    nextLabel: Periods.dayLabel(
                      rule.nextDate,
                      locale: locale,
                      today: l10n.today,
                      yesterday: l10n.yesterday,
                    ),
                    onEdit: () => context.push('/recurring/${rule.id}/edit'),
                    onRegister: () => _register(context, ref, rule),
                    onSkip: () => _skip(context, ref, rule),
                    onAction: (action) =>
                        _handleAction(context, ref, rule, action),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }

  Future<void> _register(
    BuildContext context,
    WidgetRef ref,
    RecurringExpense rule,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.recurringRegistered(rule.name);
    await ref.read(databaseProvider).registerRecurringExpense(rule.id);
    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _skip(
    BuildContext context,
    WidgetRef ref,
    RecurringExpense rule,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.recurringSkipped(rule.name);
    await ref.read(databaseProvider).skipRecurringExpense(rule.id);
    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    RecurringExpense rule,
    _RecurringAction action,
  ) async {
    final database = ref.read(databaseProvider);
    switch (action) {
      case _RecurringAction.edit:
        if (context.mounted) context.push('/recurring/${rule.id}/edit');
      case _RecurringAction.toggle:
        await database.setRecurringActive(rule.id, active: !rule.active);
      case _RecurringAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(dialogContext.l10n.recurringDeleteTitle),
            content: Text(dialogContext.l10n.recurringDeleteMessage(rule.name)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(dialogContext.l10n.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(dialogContext.l10n.actionDelete),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        await database.deleteRecurringExpense(rule.id);
    }
  }
}

enum _RecurringAction { edit, toggle, delete }

class _RecurringTile extends StatelessWidget {
  const _RecurringTile({
    required this.rule,
    required this.category,
    required this.due,
    required this.nextLabel,
    required this.onEdit,
    required this.onRegister,
    required this.onSkip,
    required this.onAction,
  });

  final RecurringExpense rule;
  final Category? category;
  final bool due;
  final String nextLabel;
  final VoidCallback onEdit;
  final VoidCallback onRegister;
  final VoidCallback onSkip;
  final ValueChanged<_RecurringAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final frequency =
        RecurringFrequency.parse(rule.frequency) ?? RecurringFrequency.monthly;
    final details = [
      Money.format(
        rule.amountCents,
        rule.currency,
        locale: localeNameOf(context),
      ),
      category?.name ?? l10n.labelUnknownCategory,
      recurrenceDescription(l10n, frequency, rule.interval),
    ].join(' · ');

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 10),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: category == null
                        ? scheme.surfaceContainerHighest
                        : Color(category!.color).withValues(alpha: 0.15),
                    child: Text(
                      category?.icon ?? '🔁',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rule.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        details,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.recurringNextLabel(nextLabel),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<_RecurringAction>(
                  tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                  onSelected: onAction,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _RecurringAction.edit,
                      child: Text(context.l10n.actionEdit),
                    ),
                    PopupMenuItem(
                      value: _RecurringAction.toggle,
                      child: Text(
                        rule.active
                            ? context.l10n.recurringPause
                            : context.l10n.recurringResume,
                      ),
                    ),
                    PopupMenuItem(
                      value: _RecurringAction.delete,
                      child: Text(
                        context.l10n.actionDelete,
                        style: TextStyle(color: scheme.error),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (due)
                  Chip(
                    label: Text(l10n.recurringDueNow),
                    labelStyle: TextStyle(color: scheme.onErrorContainer),
                    backgroundColor: scheme.errorContainer,
                    side: BorderSide.none,
                    visualDensity: VisualDensity.compact,
                  )
                else if (!rule.active)
                  Chip(
                    label: Text(l10n.recurringPaused),
                    visualDensity: VisualDensity.compact,
                  ),
                if (due) ...[
                  FilledButton.tonal(
                    onPressed: onRegister,
                    child: Text(l10n.recurringRegister),
                  ),
                  TextButton(
                    onPressed: onSkip,
                    child: Text(l10n.recurringSkip),
                  ),
                ] else
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(l10n.actionEdit),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
