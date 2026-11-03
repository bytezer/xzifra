import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../data/database.dart';
import '../../domain/money.dart';
import '../../domain/periods.dart';
import '../../providers.dart';
import 'widgets/amount_keypad.dart';

class ExpenseFormPage extends ConsumerWidget {
  const ExpenseFormPage({super.key, this.expenseId});

  final String? expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = expenseId;
    if (id == null) {
      return ref
          .watch(expenseDefaultsProvider)
          .when(
            data: (defaults) => _ExpenseFormBody(
              initial: null,
              defaultCategoryId: defaults.categoryId,
              defaultPaymentMethodId: defaults.paymentMethodId,
            ),
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => const _ExpenseFormBody(initial: null),
          );
    }

    return ref
        .watch(expenseByIdProvider(id))
        .when(
          data: (view) => view == null
              ? _LoadError(message: context.l10n.expenseNotFound)
              : _ExpenseFormBody(initial: view),
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) =>
              _LoadError(message: context.l10n.expenseLoadError),
        );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text(message)),
    );
  }
}

class _ExpenseFormBody extends ConsumerStatefulWidget {
  const _ExpenseFormBody({
    required this.initial,
    this.defaultCategoryId,
    this.defaultPaymentMethodId,
  });

  final ExpenseView? initial;
  final String? defaultCategoryId;
  final String? defaultPaymentMethodId;

  @override
  ConsumerState<_ExpenseFormBody> createState() => _ExpenseFormBodyState();
}

class _ExpenseFormBodyState extends ConsumerState<_ExpenseFormBody> {
  late AmountInput _amount;
  late String _currency;
  String? _categoryId;
  String? _paymentMethodId;
  late DateTime _date;
  late final TextEditingController _noteController;
  bool _saving = false;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial == null) {
      _amount = const AmountInput();
      _currency = ref.read(selectedCurrencyProvider);
      _categoryId = widget.defaultCategoryId;
      _paymentMethodId = widget.defaultPaymentMethodId;
      _date = DateTime.now();
      _noteController = TextEditingController();
    } else {
      _amount = AmountInput.fromCents(initial.expense.amountCents);
      _currency = initial.expense.currency;
      _categoryId = initial.expense.categoryId;
      _paymentMethodId = initial.expense.paymentMethodId;
      _date = DateTime.tryParse(initial.expense.date) ?? DateTime.now();
      _noteController = TextEditingController(text: initial.expense.note ?? '');
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final locale = localeNameOf(context);

    final allCategories =
        ref.watch(allCategoriesProvider).asData?.value ?? const <Category>[];
    final allMethods =
        ref.watch(allPaymentMethodsProvider).asData?.value ??
        const <PaymentMethod>[];

    final categories = allCategories
        .where((item) => item.archivedAt == null || item.id == _categoryId)
        .toList();
    final methods = allMethods
        .where((item) => item.archivedAt == null || item.id == _paymentMethodId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.expenseEditTitle : l10n.expenseNewTitle),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Card(
              color: scheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.expenseAmount,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      child: Text(
                        '${Money.symbolFor(_currency)} ${_amount.display}',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            AmountKeypad(
              onDigit: (digit) =>
                  setState(() => _amount = _amount.appendDigit(digit)),
              onDecimal: () =>
                  setState(() => _amount = _amount.appendDecimal()),
              onBackspace: () => setState(() => _amount = _amount.backspace()),
            ),
            const SizedBox(height: 20),
            Text(l10n.expenseCurrency, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'PEN', label: Text('PEN · S/')),
                ButtonSegment(value: 'USD', label: Text(r'USD · $')),
              ],
              selected: {_currency},
              onSelectionChanged: (selection) {
                setState(() => _currency = selection.first);
              },
            ),
            const SizedBox(height: 20),
            Text(l10n.expenseCategory, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (categories.isEmpty)
              Text(
                l10n.expenseNoCategories,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in categories)
                    ChoiceChip(
                      selected: _categoryId == item.id,
                      avatar: Text(item.icon),
                      label: Text(item.name),
                      onSelected: (_) => setState(() => _categoryId = item.id),
                    ),
                ],
              ),
            const SizedBox(height: 20),
            Text(l10n.expensePaymentMethod, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  selected: _paymentMethodId == null,
                  label: Text(l10n.labelNone),
                  onSelected: (_) => setState(() => _paymentMethodId = null),
                ),
                for (final item in methods)
                  ChoiceChip(
                    selected: _paymentMethodId == item.id,
                    label: Text(item.name),
                    onSelected: (_) =>
                        setState(() => _paymentMethodId = item.id),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(l10n.expenseDate, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(Periods.fullDateLabel(_date, locale: locale)),
                trailing: const Icon(Icons.edit_outlined, size: 18),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 20),
            Text(l10n.expenseNote, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 2,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: l10n.labelOptional,
                counterText: '',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? l10n.expenseSaveChanges : l10n.expenseSave),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, now.month, now.day),
      helpText: context.l10n.expenseDateHelp,
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    final cents = _amount.cents;
    if (cents <= 0) {
      _showMessage(context.l10n.expenseAmountError);
      return;
    }
    final categoryId = _categoryId;
    if (categoryId == null) {
      _showMessage(context.l10n.expenseCategoryError);
      return;
    }
    final categories =
        ref.read(allCategoriesProvider).asData?.value ?? const <Category>[];
    if (!categories.any((item) => item.id == categoryId)) {
      _showMessage(context.l10n.expenseCategoryError);
      return;
    }
    final methods =
        ref.read(allPaymentMethodsProvider).asData?.value ??
        const <PaymentMethod>[];
    final paymentMethodId = methods.any((item) => item.id == _paymentMethodId)
        ? _paymentMethodId
        : null;

    setState(() => _saving = true);
    final note = _noteController.text.trim();
    final database = ref.read(databaseProvider);

    try {
      if (_isEditing) {
        await database.updateExpense(
          widget.initial!.expense.id,
          amountCents: cents,
          currency: _currency,
          date: Periods.dateKey(_date),
          categoryId: categoryId,
          paymentMethodId: paymentMethodId,
          note: note.isEmpty ? null : note,
        );
      } else {
        await database.addExpense(
          amountCents: cents,
          currency: _currency,
          date: Periods.dateKey(_date),
          categoryId: categoryId,
          paymentMethodId: paymentMethodId,
          note: note.isEmpty ? null : note,
        );
      }
      if (!mounted) return;
      context.pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage(context.l10n.expenseSaveError);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
