import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../data/database.dart';
import '../../providers.dart';
import 'template_editor.dart';

/// Opens the template editor prefilled from [expense].
///
/// This only creates a template: the expense is never opened in edit mode and
/// is never modified.
Future<void> saveExpenseAsTemplate(
  BuildContext context,
  WidgetRef ref,
  ExpenseView expense,
) async {
  final l10n = context.l10n;
  final categories = await _loadCategories(ref);
  final methods = await _loadPaymentMethods(ref);
  if (!context.mounted) return;

  final note = expense.expense.note?.trim() ?? '';
  var suggestedName = note.isNotEmpty ? note : expense.category.name;
  if (suggestedName.length > 60) {
    suggestedName = suggestedName.substring(0, 60);
  }

  final result = await showTemplateEditor(
    context,
    categories: categories,
    methods: methods,
    initial: TemplateEditorResult(
      name: suggestedName,
      amountCents: expense.expense.amountCents,
      currency: expense.expense.currency,
      categoryId: expense.expense.categoryId,
      paymentMethodId: expense.expense.paymentMethodId,
      note: note.isEmpty ? null : note,
    ),
    defaultCurrency: expense.expense.currency,
    fromExpense: true,
  );
  if (result == null || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref
        .read(databaseProvider)
        .addTemplate(
          name: result.name,
          amountCents: result.amountCents,
          currency: result.currency,
          categoryId: result.categoryId,
          paymentMethodId: result.paymentMethodId,
          note: result.note,
        );
    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(l10n.templatesSaved)));
  } catch (_) {
    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(l10n.templatesSaveError)));
  }
}

/// Returns the current categories, waiting for the first stream value when the
/// provider has not loaded yet (for example, on the expenses page).
Future<List<Category>> _loadCategories(WidgetRef ref) async {
  final current = ref.read(allCategoriesProvider).asData?.value;
  if (current != null) return current;

  final completer = Completer<List<Category>>();
  final subscription = ref.listenManual<AsyncValue<List<Category>>>(
    allCategoriesProvider,
    (previous, next) {
      final value = next.asData?.value;
      if (value != null && !completer.isCompleted) {
        completer.complete(value);
      } else if (next.hasError && !completer.isCompleted) {
        completer.complete(const <Category>[]);
      }
    },
    fireImmediately: true,
  );
  try {
    return await completer.future;
  } finally {
    subscription.close();
  }
}

/// Same as [_loadCategories], for payment methods.
Future<List<PaymentMethod>> _loadPaymentMethods(WidgetRef ref) async {
  final current = ref.read(allPaymentMethodsProvider).asData?.value;
  if (current != null) return current;

  final completer = Completer<List<PaymentMethod>>();
  final subscription = ref.listenManual<AsyncValue<List<PaymentMethod>>>(
    allPaymentMethodsProvider,
    (previous, next) {
      final value = next.asData?.value;
      if (value != null && !completer.isCompleted) {
        completer.complete(value);
      } else if (next.hasError && !completer.isCompleted) {
        completer.complete(const <PaymentMethod>[]);
      }
    },
    fireImmediately: true,
  );
  try {
    return await completer.future;
  } finally {
    subscription.close();
  }
}
