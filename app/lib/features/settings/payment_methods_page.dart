import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/empty_state.dart';
import '../../data/database.dart';
import '../../providers.dart';

const Map<String, String> _typeLabels = {
  'cash': 'Cash',
  'yape': 'Yape',
  'plin': 'Plin',
  'debit': 'Debit card',
  'credit': 'Credit card',
  'transfer': 'Bank transfer',
};

IconData _iconFor(String type) => switch (type) {
  'cash' => Icons.payments_outlined,
  'yape' || 'plin' => Icons.phone_android_outlined,
  'debit' => Icons.credit_card_outlined,
  'credit' => Icons.credit_score_outlined,
  'transfer' => Icons.account_balance_outlined,
  _ => Icons.account_balance_wallet_outlined,
};

class PaymentMethodsPage extends ConsumerWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final all =
        ref.watch(allPaymentMethodsProvider).asData?.value ??
        const <PaymentMethod>[];
    final active = all.where((item) => item.archivedAt == null).toList();
    final archived = all.where((item) => item.archivedAt != null).toList();
    final database = ref.read(databaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment methods')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          if (all.isEmpty)
            const EmptyState(
              icon: Icons.credit_card_outlined,
              title: 'No payment methods yet',
              message: 'Add cash, cards or wallets to track how you pay.',
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
                'Archived',
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
    final database = ref.read(databaseProvider);
    final controller = TextEditingController(text: method?.name ?? '');
    var type = method?.type ?? 'cash';

    final result = await showDialog<({String name, String type})>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                method == null ? 'New payment method' : 'Edit payment method',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      maxLength: 40,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: type,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: [
                        for (final entry in _typeLabels.entries)
                          DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => type = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isEmpty) return;
                    Navigator.of(dialogContext).pop((name: name, type: type));
                  },
                  child: const Text('Save'),
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
        await database.addPaymentMethod(name: result.name, type: result.type);
      } else {
        await database.updatePaymentMethod(
          method.id,
          name: result.name,
          type: result.type,
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
    final count = await database.countExpensesForPaymentMethod(method.id);
    if (!context.mounted) return;

    if (count > 0) {
      final archive = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Archive payment method?'),
          content: Text(
            '"${method.name}" is used by $count '
            '${count == 1 ? 'expense' : 'expenses'}. '
            'Archiving keeps the history intact.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Archive'),
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
        title: const Text('Delete payment method?'),
        content: Text('Delete "${method.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
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
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer
              .withValues(alpha: 0.5),
          child: Icon(_iconFor(method.type), size: 20),
        ),
        title: Text(method.name),
        subtitle: Text(
          archived
              ? 'Archived · ${_typeLabels[method.type] ?? method.type}'
              : _typeLabels[method.type] ?? method.type,
        ),
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
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            if (!archived && onMoveUp != null)
              const PopupMenuItem(value: 'up', child: Text('Move up')),
            if (!archived && onMoveDown != null)
              const PopupMenuItem(value: 'down', child: Text('Move down')),
            if (archived)
              const PopupMenuItem(value: 'restore', child: Text('Restore'))
            else
              const PopupMenuItem(value: 'archive', child: Text('Archive')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
