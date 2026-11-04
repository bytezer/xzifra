import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/database.dart';
import '../../domain/money.dart';
import '../../domain/periods.dart';
import '../../providers.dart';
import 'expense_template_action.dart';
import 'template_editor.dart';

class TemplatesPage extends ConsumerWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final all =
        ref.watch(allTemplatesProvider).asData?.value ?? const <Template>[];
    final categories =
        ref.watch(allCategoriesProvider).asData?.value ?? const <Category>[];
    final methods =
        ref.watch(allPaymentMethodsProvider).asData?.value ??
        const <PaymentMethod>[];
    final active = all.where((item) => item.archivedAt == null).toList();
    final archived = all.where((item) => item.archivedAt != null).toList();
    final database = ref.read(databaseProvider);
    final categoriesById = {for (final item in categories) item.id: item};

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.templatesTitle),
        actions: [
          IconButton(
            tooltip: l10n.templatesFromExpense,
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => _pickExpense(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _openEditor(context, ref, categories: categories, methods: methods),
        icon: const Icon(Icons.add),
        label: Text(l10n.actionAdd),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          if (all.isEmpty)
            EmptyState(
              icon: Icons.bookmark_border,
              title: l10n.templatesEmptyTitle,
              message: l10n.templatesEmptyMessage,
            ),
          for (var index = 0; index < active.length; index++) ...[
            _TemplateTile(
              template: active[index],
              category: categoriesById[active[index].categoryId],
              onEdit: () => _openEditor(
                context,
                ref,
                template: active[index],
                categories: categories,
                methods: methods,
              ),
              onMoveUp: index == 0
                  ? null
                  : () => _move(database, active, index, -1),
              onMoveDown: index == active.length - 1
                  ? null
                  : () => _move(database, active, index, 1),
              onArchive: () => database.setTemplateArchived(
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
              _TemplateTile(
                template: item,
                category: categoriesById[item.categoryId],
                archived: true,
                onEdit: () => _openEditor(
                  context,
                  ref,
                  template: item,
                  categories: categories,
                  methods: methods,
                ),
                onRestore: () =>
                    database.setTemplateArchived(item.id, archived: false),
                onDelete: () => _delete(context, database, item),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _pickExpense(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final expenses = await ref.read(databaseProvider).recentExpenses();
    if (!context.mounted) return;

    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.templatesNoExpenses)));
      return;
    }

    final selected = await showModalBottomSheet<ExpenseView>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final locale = localeNameOf(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.templatesPickExpense,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final item in expenses)
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(item.category.color)
                              .withValues(alpha: 0.15),
                          child: Text(item.category.icon),
                        ),
                        title: Text(item.category.name),
                        subtitle: Text(
                          [
                            Periods.dayLabel(
                              item.expense.date,
                              locale: locale,
                              today: l10n.today,
                              yesterday: l10n.yesterday,
                            ),
                            if (item.expense.note?.trim().isNotEmpty ?? false)
                              item.expense.note!.trim(),
                          ].join(' · '),
                        ),
                        trailing: Text(
                          Money.format(
                            item.expense.amountCents,
                            item.expense.currency,
                            locale: locale,
                          ),
                        ),
                        onTap: () => Navigator.of(context).pop(item),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
    if (selected == null || !context.mounted) return;
    await saveExpenseAsTemplate(context, ref, selected);
  }

  Future<void> _move(
    AppDatabase database,
    List<Template> active,
    int index,
    int delta,
  ) async {
    final ids = [for (final item in active) item.id];
    final target = index + delta;
    if (target < 0 || target >= ids.length) return;
    final moved = ids.removeAt(index);
    ids.insert(target, moved);
    await database.reorderTemplates(ids);
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    Template? template,
    required List<Category> categories,
    required List<PaymentMethod> methods,
  }) async {
    final database = ref.read(databaseProvider);
    final result = await showTemplateEditor(
      context,
      categories: categories,
      methods: methods,
      template: template,
      defaultCurrency: ref.read(selectedCurrencyProvider),
    );
    if (result == null) return;
    if (template == null) {
      await database.addTemplate(
        name: result.name,
        amountCents: result.amountCents,
        currency: result.currency,
        categoryId: result.categoryId,
        paymentMethodId: result.paymentMethodId,
        note: result.note,
      );
    } else {
      await database.updateTemplate(
        template.id,
        name: result.name,
        amountCents: result.amountCents,
        currency: result.currency,
        categoryId: result.categoryId,
        paymentMethodId: result.paymentMethodId,
        note: result.note,
      );
    }
  }

  Future<void> _delete(
    BuildContext context,
    AppDatabase database,
    Template template,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.templatesDeleteDialogTitle),
        content: Text(l10n.templatesDeleteDialogMessage(template.name)),
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
      await database.deleteTemplate(template.id);
    }
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    required this.template,
    this.category,
    this.archived = false,
    this.onEdit,
    this.onMoveUp,
    this.onMoveDown,
    this.onArchive,
    this.onRestore,
    this.onDelete,
  });

  final Template template;
  final Category? category;
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
    final detail = [
      Money.format(
        template.amountCents,
        template.currency,
        locale: localeNameOf(context),
      ),
      if (category != null) category!.name,
    ].join(' · ');
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer
              .withValues(alpha: 0.5),
          child: Text(
            category?.icon ?? '🔖',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        title: Text(template.name),
        subtitle: Text(
          archived ? '$detail · ${l10n.templateArchived}' : detail,
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
