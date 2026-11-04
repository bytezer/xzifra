import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../data/database.dart';
import '../../domain/money.dart';
import '../../domain/periods.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import 'widgets/amount_keypad.dart';

/// The three ways the expense form can be opened.
enum ExpenseFormMode { create, edit, duplicate }

class ExpenseFormPage extends ConsumerWidget {
  const ExpenseFormPage({super.key, this.expenseId, this.duplicate = false});

  final String? expenseId;
  final bool duplicate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = expenseId;
    if (id == null) {
      return ref
          .watch(expenseDefaultsProvider)
          .when(
            data: (defaults) => _ExpenseFormBody(
              mode: ExpenseFormMode.create,
              initial: null,
              defaultCategoryId: defaults.categoryId,
              defaultPaymentMethodId: defaults.paymentMethodId,
            ),
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => const _ExpenseFormBody(
              mode: ExpenseFormMode.create,
              initial: null,
            ),
          );
    }

    final mode = duplicate ? ExpenseFormMode.duplicate : ExpenseFormMode.edit;
    return ref
        .watch(expenseByIdProvider(id))
        .when(
          data: (view) => view == null
              ? _LoadError(message: context.l10n.expenseNotFound)
              : _ExpenseFormBody(mode: mode, initial: view),
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
    required this.mode,
    required this.initial,
    this.defaultCategoryId,
    this.defaultPaymentMethodId,
  });

  final ExpenseFormMode mode;
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

  bool get _isEditing => widget.mode == ExpenseFormMode.edit;
  bool get _canAddAnother => !_isEditing;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    // Edit and duplicate both start from the source expense values. Only edit
    // keeps the original date; duplicate and create start dated today.
    final source = widget.mode == ExpenseFormMode.create ? null : initial;
    _amount = source == null
        ? const AmountInput()
        : AmountInput.fromCents(source.expense.amountCents);
    _currency = source?.expense.currency ?? ref.read(selectedCurrencyProvider);
    _categoryId = source?.expense.categoryId ?? widget.defaultCategoryId;
    _paymentMethodId =
        source?.expense.paymentMethodId ?? widget.defaultPaymentMethodId;
    _date = widget.mode == ExpenseFormMode.edit
        ? DateTime.tryParse(initial!.expense.date) ?? DateTime.now()
        : DateTime.now();
    _noteController = TextEditingController(text: source?.expense.note ?? '');
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final todaySelected = Periods.dateKey(_date) == Periods.dateKey(today);
    final yesterdaySelected =
        Periods.dateKey(_date) == Periods.dateKey(yesterday);

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

    final templates =
        ref.watch(templatesProvider).asData?.value ?? const <Template>[];

    return Scaffold(
      appBar: AppBar(title: Text(_title(l10n))),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (!_isEditing && templates.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _saving
                      ? null
                      : () =>
                            _pickTemplate(templates, allCategories, allMethods),
                  icon: const Icon(Icons.bookmark_border, size: 18),
                  label: Text(l10n.templatesUseTemplate),
                ),
              ),
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
              onDigit: (digit) {
                HapticFeedback.selectionClick();
                setState(() => _amount = _amount.appendDigit(digit));
              },
              onDecimal: () {
                HapticFeedback.selectionClick();
                setState(() => _amount = _amount.appendDecimal());
              },
              onBackspace: () {
                HapticFeedback.selectionClick();
                setState(() => _amount = _amount.backspace());
              },
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
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.today),
                  selected: todaySelected,
                  onSelected: (_) => setState(() => _date = today),
                ),
                ChoiceChip(
                  label: Text(l10n.yesterday),
                  selected: yesterdaySelected,
                  onSelected: (_) => setState(() => _date = yesterday),
                ),
              ],
            ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _isEditing ? l10n.expenseSaveChanges : l10n.expenseSave,
                    ),
            ),
            if (_canAddAnother) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _saving ? null : () => _save(addAnother: true),
                child: Text(l10n.expenseSaveAndAddAnother),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _title(AppLocalizations l10n) {
    return switch (widget.mode) {
      ExpenseFormMode.create => l10n.expenseNewTitle,
      ExpenseFormMode.edit => l10n.expenseEditTitle,
      ExpenseFormMode.duplicate => l10n.expenseDuplicateTitle,
    };
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

  Future<void> _pickTemplate(
    List<Template> templates,
    List<Category> categories,
    List<PaymentMethod> methods,
  ) async {
    final l10n = context.l10n;
    final categoriesById = {for (final item in categories) item.id: item};
    final methodsById = {for (final item in methods) item.id: item};
    final selected = await showModalBottomSheet<Template>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                l10n.templatesChooseTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final template in templates)
              ListTile(
                leading: CircleAvatar(
                  child: Text(
                    categoriesById[template.categoryId]?.icon ?? '🔖',
                  ),
                ),
                title: Text(template.name),
                subtitle: Text(
                  [
                    Money.format(
                      template.amountCents,
                      template.currency,
                      locale: localeNameOf(context),
                    ),
                    if (categoriesById[template.categoryId] != null)
                      categoriesById[template.categoryId]!.name,
                    if (methodsById[template.paymentMethodId] != null)
                      methodsById[template.paymentMethodId]!.name,
                  ].join(' · '),
                ),
                onTap: () => Navigator.of(context).pop(template),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (selected == null || !mounted) return;

    final now = DateTime.now();
    setState(() {
      _amount = AmountInput.fromCents(selected.amountCents);
      _currency = Money.supportedCurrencies.contains(selected.currency)
          ? selected.currency
          : _currency;
      _categoryId = selected.categoryId;
      _paymentMethodId = selected.paymentMethodId;
      _date = DateTime(now.year, now.month, now.day);
      _noteController.text = selected.note ?? '';
    });
  }

  Future<void> _save({bool addAnother = false}) async {
    if (_saving) return;
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
    final date = Periods.dateKey(_date);
    final database = ref.read(databaseProvider);

    try {
      if (_isEditing) {
        await database.updateExpense(
          widget.initial!.expense.id,
          amountCents: cents,
          currency: _currency,
          date: date,
          categoryId: categoryId,
          paymentMethodId: paymentMethodId,
          note: note.isEmpty ? null : note,
        );
      } else {
        await database.addExpense(
          amountCents: cents,
          currency: _currency,
          date: date,
          categoryId: categoryId,
          paymentMethodId: paymentMethodId,
          note: note.isEmpty ? null : note,
        );
      }
      await HapticFeedback.lightImpact();
      if (!mounted) return;
      if (addAnother) {
        _noteController.clear();
        setState(() {
          _saving = false;
          _amount = const AmountInput();
        });
        _showMessage(context.l10n.expenseSavedAnother);
      } else {
        context.pop();
      }
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
