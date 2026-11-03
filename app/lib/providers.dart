import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'core/locale_settings.dart';
import 'core/theme_settings.dart';
import 'data/database.dart';
import 'domain/reports.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

typedef RangeQuery = ({String start, String endExclusive, String currency});

typedef ExpenseQuery = ({
  String start,
  String endExclusive,
  String currency,
  String? categoryId,
  String? paymentMethodId,
});

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(databaseProvider).watchCategories();
});

final allCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(databaseProvider).watchCategories(includeArchived: true);
});

final paymentMethodsProvider = StreamProvider<List<PaymentMethod>>((ref) {
  return ref.watch(databaseProvider).watchPaymentMethods();
});

final allPaymentMethodsProvider = StreamProvider<List<PaymentMethod>>((ref) {
  return ref.watch(databaseProvider).watchPaymentMethods(includeArchived: true);
});

final monthExpensesProvider =
    StreamProvider.family<List<ExpenseView>, ExpenseQuery>((ref, query) {
      return ref
          .watch(databaseProvider)
          .watchExpenses(
            start: query.start,
            endExclusive: query.endExclusive,
            currency: query.currency,
            categoryId: query.categoryId,
            paymentMethodId: query.paymentMethodId,
          );
    });

final recentExpensesProvider = StreamProvider.family<List<ExpenseView>, String>(
  (ref, currency) {
    return ref.watch(databaseProvider).watchRecentExpenses(currency: currency);
  },
);

final monthTotalProvider = StreamProvider.family<int, RangeQuery>((ref, query) {
  return ref
      .watch(databaseProvider)
      .watchMonthTotal(
        start: query.start,
        endExclusive: query.endExclusive,
        currency: query.currency,
      );
});

final categoryTotalsProvider =
    StreamProvider.family<List<CategoryTotal>, RangeQuery>((ref, query) {
      return ref
          .watch(databaseProvider)
          .watchCategoryTotals(
            start: query.start,
            endExclusive: query.endExclusive,
            currency: query.currency,
          );
    });

final paymentMethodTotalsProvider =
    StreamProvider.family<List<PaymentMethodTotal>, RangeQuery>((ref, query) {
      return ref
          .watch(databaseProvider)
          .watchPaymentMethodTotals(
            start: query.start,
            endExclusive: query.endExclusive,
            currency: query.currency,
          );
    });

final monthlyTotalsProvider =
    StreamProvider.family<List<MonthlyTotal>, RangeQuery>((ref, query) {
      return ref
          .watch(databaseProvider)
          .watchMonthlyTotals(
            start: query.start,
            endExclusive: query.endExclusive,
            currency: query.currency,
          );
    });

final expenseByIdProvider = FutureProvider.family<ExpenseView?, String>((
  ref,
  id,
) {
  return ref.watch(databaseProvider).getExpenseView(id);
});

final defaultCurrencyProvider = StreamProvider<String>((ref) {
  return ref
      .watch(databaseProvider)
      .watchSetting('defaultCurrency')
      .map((value) => value ?? 'PEN');
});

class ExpenseDefaults {
  const ExpenseDefaults({this.categoryId, this.paymentMethodId});

  final String? categoryId;
  final String? paymentMethodId;
}

final expenseDefaultsProvider = FutureProvider<ExpenseDefaults>((ref) async {
  final database = ref.watch(databaseProvider);
  final categoryId = await database.getSetting('lastUsedCategoryId');
  final paymentMethodId = await database.getSetting('lastUsedPaymentMethodId');
  return ExpenseDefaults(
    categoryId: categoryId,
    paymentMethodId: paymentMethodId,
  );
});

class SelectedMonth extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void previous() => state = DateTime(state.year, state.month - 1);

  void next() {
    final candidate = DateTime(state.year, state.month + 1);
    final now = DateTime.now();
    if (candidate.isAfter(DateTime(now.year, now.month))) return;
    state = candidate;
  }

  void reset() {
    final now = DateTime.now();
    state = DateTime(now.year, now.month);
  }

  bool get canGoNext {
    final now = DateTime.now();
    return DateTime(
      state.year,
      state.month,
    ).isBefore(DateTime(now.year, now.month));
  }
}

final selectedMonthProvider = NotifierProvider<SelectedMonth, DateTime>(
  SelectedMonth.new,
);

class SelectedCurrency extends Notifier<String> {
  @override
  String build() => 'PEN';

  void set(String currency) => state = currency;
}

final selectedCurrencyProvider = NotifierProvider<SelectedCurrency, String>(
  SelectedCurrency.new,
);

final initialThemeProvider = Provider<AppThemeSettings>(
  (ref) => const AppThemeSettings(),
);

final initialLocaleProvider = Provider<AppLocale>((ref) => AppLocale.system);

final localeSettingProvider = StreamProvider<AppLocale>((ref) {
  return ref.watch(databaseProvider).watchSetting('locale').map(parseAppLocale);
});

final themePresetProvider = StreamProvider<AppThemePreset>((ref) {
  return ref
      .watch(databaseProvider)
      .watchSetting('themePreset')
      .map(parseThemePreset);
});

final themeModeProvider = StreamProvider<ThemeMode>((ref) {
  return ref
      .watch(databaseProvider)
      .watchSetting('themeMode')
      .map(parseThemeMode);
});

final packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});
