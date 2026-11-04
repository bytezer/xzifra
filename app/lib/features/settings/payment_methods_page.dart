import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/emoji_palette.dart';
import '../../core/l10n.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/database.dart';
import '../../providers.dart';

class PaymentMethodsPage extends ConsumerWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final all =
        ref.watch(allPaymentMethodsProvider).asData?.value ??
        const <PaymentMethod>[];
    final active = all.where((item) => item.archivedAt == null).toList();
    final archived = all.where((item) => item.archivedAt != null).toList();
    final database = ref.read(databaseProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentMethodsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.actionAdd),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          if (all.isEmpty)
            EmptyState(
              icon: Icons.credit_card_outlined,
              title: l10n.paymentMethodsEmptyTitle,
              message: l10n.paymentMethodsEmptyMessage,
            ),
          for (var index = 0; index < active.length; index++) ...[
            _PaymentMethodTile(
              method: active[index],
              onEdit: () => _openEditor(context, ref, method: active[index]),
              onMoveUp: index == 0
                  ? null
                  : () => _move(database, active, index, -1),
              onMoveDown: index == active.length - 1
                  ? null
                  : () => _move(database, active, index, 1),
              onArchive: () => database.setPaymentMethodArchived(
                active[index].id,
                archived: true,
              ),
              onDelete: () => _delete(context, database, active[index]),
            ),
            const SizedBox(height: 8),
          ],
          if (archived.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
              child: Text(
                l10n.labelArchived,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            for (final item in archived) ...[
              _PaymentMethodTile(
                method: item,
                archived: true,
                onEdit: () => _openEditor(context, ref, method: item),
                onRestore: () =>
                    database.setPaymentMethodArchived(item.id, archived: false),
                onDelete: () => _delete(context, database, item),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _move(
    AppDatabase database,
    List<PaymentMethod> active,
    int index,
    int delta,
  ) async {
    final ids = [for (final item in active) item.id];
    final target = index + delta;
    if (target < 0 || target >= ids.length) return;
    final moved = ids.removeAt(index);
    ids.insert(target, moved);
    await database.reorderPaymentMethods(ids);
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    PaymentMethod? method,
  }) async {
    final l10n = context.l10n;
    final database = ref.read(databaseProvider);
    final controller = TextEditingController(text: method?.name ?? '');
    var icon = method?.icon ?? '💳';

    final result = await showDialog<({String name, String icon})>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            return AlertDialog(
              title: Text(
                method == null
                    ? l10n.paymentMethodsNewTitle
                    : l10n.paymentMethodsEditTitle,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      maxLength: 40,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.paymentMethodsName,
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.categoriesIcon,
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final emoji in emojiPalette)
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => setDialogState(() => icon = emoji),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: icon == emoji
                                    ? theme.colorScheme.primaryContainer
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.actionCancel),
                ),
                FilledButton(
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isEmpty) return;
                    Navigator.of(dialogContext).pop((name: name, icon: icon));
                  },
                  child: Text(l10n.actionSave),
                ),
              ],
            );
          },
        );
      },
    );

    try {
      if (result == null) return;
      if (method == null) {
        await database.addPaymentMethod(name: result.name, icon: result.icon);
      } else {
        await database.updatePaymentMethod(
          method.id,
          name: result.name,
          icon: result.icon,
        );
      }
    } finally {
      controller.dispose();
    }
  }

  Future<void> _delete(
    BuildContext context,
    AppDatabase database,
    PaymentMethod method,
  ) async {
    final expenseCount = await database.countExpensesForPaymentMethod(
      method.id,
    );
    final templateCount = await database.countTemplatesForPaymentMethod(
      method.id,
    );
    final recurringCount = await database.countRecurringForPaymentMethod(
      method.id,
    );
    if (!context.mounted) return;
    final l10n = context.l10n;

    if (expenseCount > 0 || templateCount > 0 || recurringCount > 0) {
      final message = expenseCount > 0
          ? l10n.paymentMethodsArchiveDialogMessage(method.name, expenseCount)
          : templateCount > 0
          ? l10n.paymentMethodsArchiveTemplatesMessage(
              method.name,
              templateCount,
            )
          : l10n.paymentMethodsArchiveRecurringMessage(
              method.name,
              recurringCount,
            );
      final archive = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.paymentMethodsArchiveDialogTitle),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.actionArchive),
            ),
          ],
        ),
      );
      if (archive == true) {
        await database.setPaymentMethodArchived(method.id, archived: true);
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.paymentMethodsDeleteDialogTitle),
        content: Text(l10n.paymentMethodsDeleteDialogMessage(method.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await database.deletePaymentMethod(method.id);
    }
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.method,
    this.archived = false,
    this.onEdit,
    this.onMoveUp,
    this.onMoveDown,
    this.onArchive,
    this.onRestore,
    this.onDelete,
  });

  final PaymentMethod method;
  final bool archived;
  final VoidCallback? onEdit;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onArchive;
  final VoidCallback? onRestore;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer
              .withValues(alpha: 0.5),
          child: Text(method.icon, style: const TextStyle(fontSize: 18)),
        ),
        title: Text(method.name),
        subtitle: archived ? Text(l10n.paymentMethodArchived) : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit?.call();
              case 'up':
                onMoveUp?.call();
              case 'down':
                onMoveDown?.call();
              case 'archive':
                onArchive?.call();
              case 'restore':
                onRestore?.call();
              case 'delete':
                onDelete?.call();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Text(l10n.actionEdit)),
            if (!archived && onMoveUp != null)
              PopupMenuItem(value: 'up', child: Text(l10n.actionMoveUp)),
            if (!archived && onMoveDown != null)
              PopupMenuItem(value: 'down', child: Text(l10n.actionMoveDown)),
            if (archived)
              PopupMenuItem(value: 'restore', child: Text(l10n.actionRestore))
            else
              PopupMenuItem(value: 'archive', child: Text(l10n.actionArchive)),
            PopupMenuItem(value: 'delete', child: Text(l10n.actionDelete)),
          ],
        ),
      ),
    );
  }
}
