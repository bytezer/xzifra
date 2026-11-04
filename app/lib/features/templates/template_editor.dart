import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n.dart';
import '../../data/database.dart';
import '../../domain/money.dart';

/// Values collected by the template editor.
class TemplateEditorResult {
  const TemplateEditorResult({
    required this.name,
    required this.amountCents,
    required this.currency,
    required this.categoryId,
    this.paymentMethodId,
    this.note,
  });

  final String name;
  final int amountCents;
  final String currency;
  final String categoryId;
  final String? paymentMethodId;
  final String? note;
}

/// Opens the add/edit template dialog.
///
/// [template] is set when editing an existing template. [initial] pre-fills a
/// new template (used when saving an expense as a template). [fromExpense]
/// adds a note clarifying that the source expense will not be modified. Only
/// active categories and payment methods are offered, except the ones already
/// chosen by the template being edited.
Future<TemplateEditorResult?> showTemplateEditor(
  BuildContext context, {
  required List<Category> categories,
  required List<PaymentMethod> methods,
  Template? template,
  TemplateEditorResult? initial,
  String defaultCurrency = 'PEN',
  bool fromExpense = false,
}) async {
  final l10n = context.l10n;
  final seed = template == null
      ? initial
      : TemplateEditorResult(
          name: template.name,
          amountCents: template.amountCents,
          currency: template.currency,
          categoryId: template.categoryId,
          paymentMethodId: template.paymentMethodId,
          note: template.note,
        );

  final selectedCategoryId = seed?.categoryId;
  final categoryOptions = categories
      .where((item) => item.archivedAt == null || item.id == selectedCategoryId)
      .toList();
  if (categoryOptions.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.expenseNoCategories)));
    return null;
  }

  final selectedMethodId = seed?.paymentMethodId;
  final methodOptions = methods
      .where((item) => item.archivedAt == null || item.id == selectedMethodId)
      .toList();

  return showDialog<TemplateEditorResult>(
    context: context,
    builder: (dialogContext) => _TemplateEditorDialog(
      isEditing: template != null,
      initial: seed,
      defaultCurrency: defaultCurrency,
      categories: categoryOptions,
      methods: methodOptions,
      fromExpense: fromExpense,
    ),
  );
}

class _TemplateEditorDialog extends StatefulWidget {
  const _TemplateEditorDialog({
    required this.isEditing,
    required this.initial,
    required this.defaultCurrency,
    required this.categories,
    required this.methods,
    this.fromExpense = false,
  });

  final bool isEditing;
  final TemplateEditorResult? initial;
  final String defaultCurrency;
  final List<Category> categories;
  final List<PaymentMethod> methods;
  final bool fromExpense;

  @override
  State<_TemplateEditorDialog> createState() => _TemplateEditorDialogState();
}

class _TemplateEditorDialogState extends State<_TemplateEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late String _currency;
  late String _categoryId;
  String? _paymentMethodId;
  String? _nameError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    final seed = widget.initial;
    _nameController = TextEditingController(text: seed?.name ?? '');
    _amountController = TextEditingController(
      text: seed == null ? '' : Money.decimal(seed.amountCents),
    );
    _noteController = TextEditingController(text: seed?.note ?? '');
    _currency = seed?.currency ?? widget.defaultCurrency;

    final seedCategoryId = seed?.categoryId;
    _categoryId = widget.categories.any((item) => item.id == seedCategoryId)
        ? seedCategoryId!
        : widget.categories.first.id;

    final seedMethodId = seed?.paymentMethodId;
    _paymentMethodId = widget.methods.any((item) => item.id == seedMethodId)
        ? seedMethodId
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(
        widget.isEditing ? l10n.templatesEditTitle : l10n.templatesNewTitle,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.fromExpense) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.templatesFromExpenseNote,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _nameController,
              autofocus: true,
              maxLength: 60,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.templatesName,
                counterText: '',
                errorText: _nameError,
              ),
              onChanged: (_) {
                if (_nameError != null) {
                  setState(() => _nameError = null);
                }
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: InputDecoration(
                labelText: l10n.templatesAmount,
                errorText: _amountError,
                prefixText: '${Money.symbolFor(_currency)} ',
              ),
              onChanged: (_) {
                if (_amountError != null) {
                  setState(() => _amountError = null);
                }
              },
            ),
            const SizedBox(height: 16),
            Text(l10n.templatesCurrency, style: theme.textTheme.labelLarge),
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.templatesCategory),
              items: [
                for (final item in widget.categories)
                  DropdownMenuItem(
                    value: item.id,
                    child: Text('${item.icon} ${item.name}'),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _categoryId = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _paymentMethodId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.templatesPaymentMethod,
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n.labelNone),
                ),
                for (final item in widget.methods)
                  DropdownMenuItem<String?>(
                    value: item.id,
                    child: Text('${item.icon} ${item.name}'),
                  ),
              ],
              onChanged: (value) {
                setState(() => _paymentMethodId = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 2,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.templatesNote,
                hintText: l10n.labelOptional,
                counterText: '',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.actionSave)),
      ],
    );
  }

  void _submit() {
    final l10n = context.l10n;
    final name = _nameController.text.trim();
    final cents = Money.parseCents(_amountController.text);
    if (name.isEmpty) {
      setState(() => _nameError = l10n.templatesNameError);
      return;
    }
    if (cents == null) {
      setState(() => _amountError = l10n.expenseAmountError);
      return;
    }
    final note = _noteController.text.trim();
    Navigator.of(context).pop(
      TemplateEditorResult(
        name: name,
        amountCents: cents,
        currency: _currency,
        categoryId: _categoryId,
        paymentMethodId: _paymentMethodId,
        note: note.isEmpty ? null : note,
      ),
    );
  }
}
