import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/notifications.dart';
import '../../core/recurrence_labels.dart';
import '../../core/tags.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/tag_chips.dart';
import '../../data/database.dart';
import '../../domain/attachments.dart';
import '../../providers.dart';

class RemindersTab extends ConsumerStatefulWidget {
  const RemindersTab({super.key});

  @override
  ConsumerState<RemindersTab> createState() => _RemindersTabState();
}

class _RemindersTabState extends ConsumerState<RemindersTab> {
  String? _tag;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final all =
        ref.watch(remindersProvider).asData?.value ?? const <Reminder>[];
    final visible = _tag == null
        ? all
        : all.where((reminder) => hasTag(reminder.tags, _tag!)).toList();
    final tags = collectTags(all.map((reminder) => parseTags(reminder.tags)));

    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day + 1);
    final overdue = <Reminder>[];
    final today = <Reminder>[];
    final upcoming = <Reminder>[];
    final done = <Reminder>[];
    for (final reminder in visible) {
      if (reminder.doneAt != null) {
        done.add(reminder);
      } else if (reminder.dueAt.isBefore(now)) {
        overdue.add(reminder);
      } else if (reminder.dueAt.isBefore(endOfToday)) {
        today.add(reminder);
      } else {
        upcoming.add(reminder);
      }
    }

    return SafeArea(
      top: false,
      child: Column(
        children: [
          if (tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TagFilterBar(
                tags: tags,
                selected: _tag,
                onSelected: (value) => setState(() => _tag = value),
              ),
            ),
          Expanded(
            child: all.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: EmptyState(
                        icon: Icons.notifications_none,
                        title: l10n.remindersEmptyTitle,
                        message: l10n.remindersEmptyMessage,
                        action: FilledButton.icon(
                          onPressed: () => context.push('/reminders/new'),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.remindersNewTitle),
                        ),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    children: [
                      if (overdue.isEmpty &&
                          today.isEmpty &&
                          upcoming.isEmpty &&
                          done.isEmpty)
                        EmptyState(
                          icon: Icons.filter_alt_off_outlined,
                          title: l10n.remindersNoMatchesTitle,
                          message: l10n.remindersNoMatchesMessage,
                        ),
                      _section(
                        context,
                        l10n.remindersOverdue,
                        overdue,
                        overdueStyle: true,
                      ),
                      _section(context, l10n.remindersToday, today),
                      _section(context, l10n.remindersUpcoming, upcoming),
                      _section(context, l10n.remindersDone, done),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    List<Reminder> items, {
    bool overdueStyle = false,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final attachmentCounts =
        ref
            .watch(attachmentCountsProvider(AttachmentOwnerType.reminder))
            .asData
            ?.value ??
        const <String, int>{};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
          child: Text(
            '$title · ${items.length}',
            style: theme.textTheme.labelLarge?.copyWith(
              color: overdueStyle
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        for (final reminder in items) ...[
          _ReminderTile(
            reminder: reminder,
            overdue: overdueStyle,
            attachmentCount: attachmentCounts[reminder.id] ?? 0,
            onToggleDone: () => _toggleDone(reminder),
            onTap: () => context.push('/reminders/${reminder.id}/edit'),
            onAction: (action) => _handleAction(reminder, action),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Future<void> _toggleDone(Reminder reminder) async {
    final database = ref.read(databaseProvider);
    final done = reminder.doneAt == null;
    await database.setReminderDone(reminder.id, done: done);
    final updated = await database.getReminder(reminder.id);
    if (updated == null) return;
    if (done) {
      await NotificationService.instance.cancelReminder(reminder.id);
    } else {
      await NotificationService.instance.scheduleReminder(updated);
    }
  }

  Future<void> _handleAction(Reminder reminder, _ReminderAction action) async {
    switch (action) {
      case _ReminderAction.edit:
        if (mounted) context.push('/reminders/${reminder.id}/edit');
      case _ReminderAction.delete:
        final confirmed = await _confirmDelete(reminder);
        if (!confirmed) return;
        final database = ref.read(databaseProvider);
        await NotificationService.instance.cancelReminder(reminder.id);
        await ref
            .read(attachmentServiceProvider)
            .deleteForOwner(AttachmentOwnerType.reminder, reminder.id);
        await database.deleteReminder(reminder.id);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.remindersDeleted)));
    }
  }

  Future<bool> _confirmDelete(Reminder reminder) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.remindersDeleteTitle),
        content: Text(context.l10n.remindersDeleteMessage(reminder.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.actionDelete),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

enum _ReminderAction { edit, delete }

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.reminder,
    required this.overdue,
    required this.attachmentCount,
    required this.onToggleDone,
    required this.onTap,
    required this.onAction,
  });

  final Reminder reminder;
  final bool overdue;
  final int attachmentCount;
  final VoidCallback onToggleDone;
  final VoidCallback onTap;
  final ValueChanged<_ReminderAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final done = reminder.doneAt != null;
    final note = reminder.note?.trim() ?? '';
    final tags = parseTags(reminder.tags);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: onToggleDone,
                tooltip: done
                    ? l10n.remindersMarkUndone
                    : l10n.remindersMarkDone,
                icon: Icon(
                  done ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: done ? scheme.primary : scheme.outline,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: done ? TextDecoration.lineThrough : null,
                          color: done ? scheme.onSurfaceVariant : null,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        reminderDueLabel(
                          context,
                          reminder.dueAt,
                          today: l10n.today,
                          yesterday: l10n.yesterday,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: overdue
                              ? scheme.error
                              : scheme.onSurfaceVariant,
                          fontWeight: overdue
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      if (note.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          note,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        TagChips(tags: tags),
                      ],
                    ],
                  ),
                ),
              ),
              PopupMenuButton<_ReminderAction>(
                tooltip: context.l10n.remindersActions,
                onSelected: onAction,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _ReminderAction.edit,
                    child: Text(context.l10n.actionEdit),
                  ),
                  PopupMenuItem(
                    value: _ReminderAction.delete,
                    child: Text(
                      context.l10n.actionDelete,
                      style: TextStyle(color: scheme.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
