import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/recurrence_labels.dart';
import '../../data/database.dart';
import '../../domain/money.dart';
import '../../domain/recurrence.dart';
import '../../domain/periods.dart';
import '../../providers.dart';

class RecurringEditorPage extends ConsumerWidget {
  const RecurringEditorPage({super.key, this.recurringId});

  final String? recurringId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = recurringId;
    if (id == null) {
      return const _RecurringForm(initial: null);
    }
    return ref
        .watch(recurringExpenseByIdProvider(id))
        .when(
          data: (rule) => rule == null
              ? _RecurringLoadError(message: context.l10n.recurringNotFound)
              : _RecurringForm(initial: rule),
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) =>
              _RecurringLoadError(message: context.l10n.recurringLoadError),
        );
  }
}

class _RecurringLoadError extends StatelessWidget {
  const _RecurringLoadError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text(message)),
    );
  }
}

class _RecurringForm extends ConsumerStatefulWidget {
  const _RecurringForm({required this.initial});

  final RecurringExpense? initial;

  @override
  ConsumerState<_RecurringForm> createState() => _RecurringFormState();
}

class _RecurringFormState extends ConsumerState<_RecurringForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _intervalController;
  late final TextEditingController _noteController;
  late String _currency;
  String? _categoryId;
  String? _paymentMethodId;
  late RecurringFrequency _frequency;
  late DateTime _nextDate;
  DateTime? _endDate;
  late bool _active;
  bool _saving = false;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final rule = widget.initial;
    final now = DateTime.now();
    _nameController = TextEditingController(text: rule?.name ?? '');
    _amountController = TextEditingController(
      text: rule == null ? '' : Money.decimal(rule.amountCents),
    );
    _intervalController = TextEditingController(
      text: (rule?.interval ?? 1).toString(),
    );
    _noteController = TextEditingController(text: rule?.note ?? '');
    _currency = rule?.currency ?? ref.read(selectedCurrencyProvider);
    _categoryId = rule?.categoryId;
    _paymentMethodId = rule?.paymentMethodId;
    _frequency =
        RecurringFrequency.parse(rule?.frequency) ?? RecurringFrequency.monthly;
    _nextDate =
        parseDateKey(rule?.nextDate) ?? DateTime(now.year, now.month, now.day);
    _endDate = parseDateKey(rule?.endDate);
    _active = rule?.active ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _intervalController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = localeNameOf(context);
    final categories =
        ref.watch(allCategoriesProvider).asData?.value ?? const <Category>[];
    final methods =
        ref.watch(allPaymentMethodsProvider).asData?.value ??
        const <PaymentMethod>[];
    final visibleCategories = categories
        .where((item) => item.archivedAt == null || item.id == _categoryId)
        .toList();
    final visibleMethods = methods
        .where((item) => item.archivedAt == null || item.id == _paymentMethodId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.recurringEditTitle : l10n.recurringNewTitle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          TextField(
            controller: _nameController,
            autofocus: !_isEditing,
            maxLength: 100,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.recurringName,
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
            ],
            decoration: InputDecoration(
              labelText: l10n.recurringAmount,
              prefixText: '${Money.symbolFor(_currency)} ',
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.recurringCurrency, style: theme.textTheme.titleSmall),
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
          Text(l10n.recurringCategory, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          if (visibleCategories.isEmpty)
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
                for (final item in visibleCategories)
                  ChoiceChip(
                    selected: _categoryId == item.id,
                    avatar: Text(item.icon),
                    label: Text(item.name),
                    onSelected: (_) => setState(() => _categoryId = item.id),
                  ),
              ],
            ),
          const SizedBox(height: 20),
          Text(l10n.recurringPaymentMethod, style: theme.textTheme.titleSmall),
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
              for (final item in visibleMethods)
                ChoiceChip(
                  selected: _paymentMethodId == item.id,
                  label: Text(item.name),
                  onSelected: (_) => setState(() => _paymentMethodId = item.id),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(l10n.recurringFrequency, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final frequency in RecurringFrequency.values)
                ChoiceChip(
                  selected: _frequency == frequency,
                  label: Text(frequencyLabel(l10n, frequency)),
                  onSelected: (_) => setState(() => _frequency = frequency),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(l10n.recurringInterval, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _intervalController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(hintText: '1'),
          ),
          const SizedBox(height: 20),
          Text(l10n.recurringNextDate, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              leading: const Icon(Icons.event_outlined),
              title: Text(Periods.fullDateLabel(_nextDate, locale: locale)),
              trailing: const Icon(Icons.edit_outlined, size: 18),
              onTap: () => _pickDate(end: false),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              leading: const Icon(Icons.event_busy_outlined),
              title: Text(
                _endDate == null
                    ? l10n.recurringNoEndDate
                    : Periods.fullDateLabel(_endDate!, locale: locale),
              ),
              subtitle: Text(l10n.recurringEndDate),
              trailing: _endDate == null
                  ? const Icon(Icons.add, size: 18)
                  : IconButton(
                      tooltip: l10n.actionClear,
                      onPressed: () => setState(() => _endDate = null),
                      icon: const Icon(Icons.close, size: 18),
                    ),
              onTap: () => _pickDate(end: true),
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.recurringNote, style: theme.textTheme.titleSmall),
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
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _active,
            onChanged: (value) => setState(() => _active = value),
            title: Text(l10n.recurringActive),
            secondary: const Icon(Icons.play_circle_outline),
          ),
        ],
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
              : Text(_isEditing ? l10n.expenseSaveChanges : l10n.actionSave),
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool end}) async {
    final now = DateTime.now();
    final initial = end ? (_endDate ?? _nextDate) : _nextDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 50),
      helpText: end
          ? context.l10n.recurringEndDate
          : context.l10n.recurringNextDate,
    );
    if (picked == null) return;
    setState(() {
      if (end) {
        _endDate = picked;
      } else {
        _nextDate = picked;
      }
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = context.l10n;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage(l10n.recurringNameError);
      return;
    }
    final amountCents = Money.parseCents(_amountController.text);
    if (amountCents == null) {
      _showMessage(l10n.expenseAmountError);
      return;
    }
    final categoryId = _categoryId;
    if (categoryId == null) {
      _showMessage(l10n.expenseCategoryError);
      return;
    }
    final interval = int.tryParse(_intervalController.text.trim());
    if (interval == null || interval < 1) {
      _showMessage(l10n.recurringIntervalError);
      return;
    }
    if (_endDate != null &&
        Periods.dateKey(_endDate!).compareTo(Periods.dateKey(_nextDate)) < 0) {
      _showMessage(l10n.recurringEndDateError);
      return;
    }

    final note = _noteController.text.trim();
    final database = ref.read(databaseProvider);
    final rule = widget.initial;
    setState(() => _saving = true);
    try {
      if (rule == null) {
        await database.addRecurringExpense(
          name: name,
          amountCents: amountCents,
          currency: _currency,
          categoryId: categoryId,
          paymentMethodId: _paymentMethodId,
          frequency: _frequency,
          interval: interval,
          nextDate: Periods.dateKey(_nextDate),
          endDate: _endDate == null ? null : Periods.dateKey(_endDate!),
          active: _active,
          note: note.isEmpty ? null : note,
        );
      } else {
        await database.updateRecurringExpense(
          rule.id,
          name: name,
          amountCents: amountCents,
          currency: _currency,
          categoryId: categoryId,
          paymentMethodId: _paymentMethodId,
          frequency: _frequency,
          interval: interval,
          nextDate: Periods.dateKey(_nextDate),
          endDate: _endDate == null ? null : Periods.dateKey(_endDate!),
          active: _active,
          note: note.isEmpty ? null : note,
        );
      }
      await HapticFeedback.lightImpact();
      if (!mounted) return;
      context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage(l10n.recurringSaveError);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
