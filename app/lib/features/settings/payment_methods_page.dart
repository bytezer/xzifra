import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/payment_types.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/database.dart';
import '../../providers.dart';

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
      appBar: AppBar(title: Text(context.l10n.paymentMethodsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.actionAdd),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          if (all.isEmpty)
            EmptyState(
              icon: Icons.credit_card_outlined,
              title: context.l10n.paymentMethodsEmptyTitle,
              message: context.l10n.paymentMethodsEmptyMessage,
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
                context.l10n.labelArchived,
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
    var type = method?.type ?? 'cash';

    final result = await showDialog<({String name, String type})>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                method == null
                    ? l10n.paymentMethodsNewTitle
                    : l10n.paymentMethodsEditTitle,
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
                      decoration: InputDecoration(
                        labelText: l10n.paymentMethodsName,
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: type,
                      decoration: InputDecoration(
                        labelText: l10n.paymentMethodsType,
                      ),
                      items: [
                        for (final typeKey in paymentTypes)
                          DropdownMenuItem(
                            value: typeKey,
                            child: Text(paymentTypeLabel(l10n, typeKey)),
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
                  child: Text(l10n.actionCancel),
                ),
                FilledButton(
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isEmpty) return;
                    Navigator.of(dialogContext).pop((name: name, type: type));
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
    final l10n = context.l10n;

    if (count > 0) {
      final archive = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.paymentMethodsArchiveDialogTitle),
          content: Text(
            l10n.paymentMethodsArchiveDialogMessage(method.name, count),
          ),
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
    final typeLabel = paymentTypeLabel(l10n, method.type);
    final englishLabel = paymentTypeEnglishLabel(method.type);
    final nameMatchesType =
        method.name.toLowerCase() == typeLabel.toLowerCase() ||
        method.name.toLowerCase() == englishLabel.toLowerCase();
    final subtitle = archived
        ? (nameMatchesType
              ? l10n.paymentMethodArchived
              : '${l10n.paymentMethodArchived} · $typeLabel')
        : (nameMatchesType ? null : typeLabel);

    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer
              .withValues(alpha: 0.5),
          child: Icon(_iconFor(method.type), size: 20),
        ),
        title: Text(method.name),
        subtitle: subtitle == null ? null : Text(subtitle),
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
