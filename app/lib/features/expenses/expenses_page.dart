import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/widgets/currency_selector.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/month_selector.dart';
import '../../data/database.dart';
import '../../domain/money.dart';
import '../../domain/periods.dart';
import '../../domain/reports.dart';
import '../../providers.dart';
import '../templates/expense_template_action.dart';

class ExpensesPage extends ConsumerStatefulWidget {
  const ExpensesPage({super.key});

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  String? _categoryId;
  String? _paymentMethodId;

  @override
  Widget build(BuildContext context) {
    final month = ref.watch(selectedMonthProvider);
    final currency = ref.watch(selectedCurrencyProvider);
    final categories =
        ref.watch(categoriesProvider).asData?.value ?? const <Category>[];
    final paymentMethods =
        ref.watch(paymentMethodsProvider).asData?.value ??
        const <PaymentMethod>[];

    final items =
        ref
            .watch(
              monthExpensesProvider((
                start: Periods.startKey(month),
                endExclusive: Periods.endKeyExclusive(month),
                currency: currency,
                categoryId: _categoryId,
                paymentMethodId: _paymentMethodId,
              )),
            )
            .asData
            ?.value ??
        const <ExpenseView>[];

    final categoriesById = {for (final item in categories) item.id: item};
    final methodsById = {for (final item in paymentMethods) item.id: item};
    final hasFilters = _categoryId != null || _paymentMethodId != null;

    final grouped = <String, List<ExpenseView>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.expense.date, () => []).add(item);
    }
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.expensesTitle),
        actions: [
          if (hasFilters)
            TextButton(
              onPressed: () => setState(() {
                _categoryId = null;
                _paymentMethodId = null;
              }),
              child: Text(context.l10n.actionClear),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                children: [
                  const MonthSelector(alignStart: true),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const CurrencySelector(),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Row(
                            children: [
                              FilterChip(
                                label: Text(
                                  _categoryId == null
                                      ? context.l10n.expensesFilterCategory
                                      : categoriesById[_categoryId]?.name ??
                                            context.l10n.expensesFilterCategory,
                                ),
                                selected: _categoryId != null,
                                onSelected: (_) => _pickCategory(categories),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: Text(
                                  _paymentMethodId == null
                                      ? context.l10n.expensesFilterPayment
                                      : methodsById[_paymentMethodId]?.name ??
                                            context.l10n.expensesFilterPayment,
                                ),
                                selected: _paymentMethodId != null,
                                onSelected: (_) =>
                                    _pickPaymentMethod(paymentMethods),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: EmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: hasFilters
                              ? context.l10n.expensesNoMatchesTitle
                              : context.l10n.expensesEmptyTitle,
                          message: hasFilters
                              ? context.l10n.expensesNoMatchesMessage
                              : context.l10n.expensesEmptyMessage,
                          action: hasFilters
                              ? OutlinedButton(
                                  onPressed: () => setState(() {
                                    _categoryId = null;
                                    _paymentMethodId = null;
                                  }),
                                  child: Text(
                                    context.l10n.expensesClearFilters,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                      children: [
                        for (final date in dates) ...[
                          _DayHeader(
                            date: date,
                            total: TotalsMath.sum(
                              grouped[date]!.map(
                                (item) => item.expense.amountCents,
                              ),
                            ),
                            currency: currency,
                          ),
                          for (final item in grouped[date]!)
                            _ExpenseTile(
                              item: item,
                              currency: currency,
                              onDelete: () => _delete(item),
                              onLongPress: () => _showActions(item),
                            ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCategory(List<Category> categories) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => _OptionSheet(
        title: context.l10n.expensesFilterByCategory,
        allLabel: context.l10n.expensesAllCategories,
        options: [
          for (final item in categories)
            (value: item.id, label: '${item.icon}  ${item.name}'),
        ],
        selected: _categoryId,
      ),
    );
    if (selected == null) return;
    setState(() => _categoryId = selected.isEmpty ? null : selected);
  }

  Future<void> _pickPaymentMethod(List<PaymentMethod> methods) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => _OptionSheet(
        title: context.l10n.expensesFilterByPayment,
        allLabel: context.l10n.expensesAllPaymentMethods,
        options: [
          for (final item in methods) (value: item.id, label: item.name),
        ],
        selected: _paymentMethodId,
      ),
    );
    if (selected == null) return;
    setState(() => _paymentMethodId = selected.isEmpty ? null : selected);
  }

  Future<void> _showActions(ExpenseView item) async {
    final action = await showModalBottomSheet<_ExpenseAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(context.l10n.actionEdit),
              onTap: () => Navigator.of(context).pop(_ExpenseAction.edit),
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: Text(context.l10n.actionDuplicate),
              onTap: () => Navigator.of(context).pop(_ExpenseAction.duplicate),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_add_outlined),
              title: Text(context.l10n.templatesSaveAsTemplate),
              onTap: () =>
                  Navigator.of(context).pop(_ExpenseAction.saveAsTemplate),
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                context.l10n.actionDelete,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () => Navigator.of(context).pop(_ExpenseAction.delete),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;

    switch (action) {
      case _ExpenseAction.edit:
        context.push('/expenses/${item.expense.id}/edit');
      case _ExpenseAction.duplicate:
        context.push('/expenses/${item.expense.id}/duplicate');
      case _ExpenseAction.saveAsTemplate:
        await saveExpenseAsTemplate(context, ref, item);
      case _ExpenseAction.delete:
        await _delete(item);
    }
  }

  Future<void> _delete(ExpenseView item) async {
    await ref.read(databaseProvider).deleteExpense(item.expense.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.expensesDeleted(item.category.name)),
        action: SnackBarAction(
          label: context.l10n.actionUndo,
          onPressed: () {
            ref
                .read(databaseProvider)
                .addExpense(
                  amountCents: item.expense.amountCents,
                  currency: item.expense.currency,
                  date: item.expense.date,
                  categoryId: item.expense.categoryId,
                  paymentMethodId: item.expense.paymentMethodId,
                  note: item.expense.note,
                );
          },
        ),
      ),
    );
  }
}

enum _ExpenseAction { edit, duplicate, saveAsTemplate, delete }

class _OptionSheet extends StatelessWidget {
  const _OptionSheet({
    required this.title,
    required this.allLabel,
    required this.options,
    required this.selected,
  });

  final String title;
  final String allLabel;
  final List<({String value, String label})> options;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ListTile(
            title: Text(allLabel),
            trailing: selected == null ? const Icon(Icons.check) : null,
            onTap: () => Navigator.of(context).pop(''),
          ),
          for (final option in options)
            ListTile(
              title: Text(option.label),
              trailing: selected == option.value
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.of(context).pop(option.value),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.date,
    required this.total,
    required this.currency,
  });

  final String date;
  final int total;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              Periods.dayLabel(
                date,
                locale: localeNameOf(context),
                today: context.l10n.today,
                yesterday: context.l10n.yesterday,
              ),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            Money.format(total, currency, locale: localeNameOf(context)),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.item,
    required this.currency,
    required this.onDelete,
    required this.onLongPress,
  });

  final ExpenseView item;
  final String currency;
  final VoidCallback onDelete;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final note = item.expense.note?.trim();
    final subtitleParts = [
      if (item.paymentMethod != null) item.paymentMethod!.name,
      if (note != null && note.isNotEmpty) note,
    ];

    return Dismissible(
      key: ValueKey(item.expense.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(context.l10n.expensesDeleteTitle),
                content: Text(
                  '${Money.format(item.expense.amountCents, currency, locale: localeNameOf(context))} · ${item.category.name}',
                ),
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
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
      ),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: CircleAvatar(
              backgroundColor: Color(item.category.color)
                  .withValues(alpha: 0.15),
              child: Text(item.category.icon),
            ),
            title: Text(item.category.name),
            subtitle: subtitleParts.isEmpty
                ? null
                : Text(
                    subtitleParts.join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            trailing: Text(
              Money.format(
                item.expense.amountCents,
                currency,
                locale: localeNameOf(context),
              ),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => context.push('/expenses/${item.expense.id}/edit'),
          ),
        ),
      ),
    );
  }
}
