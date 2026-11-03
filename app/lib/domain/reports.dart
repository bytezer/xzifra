import 'periods.dart';

class CategoryTotal {
  const CategoryTotal({
    required this.categoryId,
    required this.totalCents,
    required this.count,
  });

  final String categoryId;
  final int totalCents;
  final int count;
}

class PaymentMethodTotal {
  const PaymentMethodTotal({
    required this.paymentMethodId,
    required this.totalCents,
    required this.count,
  });

  /// `null` means the expense has no payment method assigned.
  final String? paymentMethodId;
  final int totalCents;
  final int count;
}

class MonthlyTotal {
  const MonthlyTotal({required this.month, required this.totalCents});

  /// `YYYY-MM`
  final String month;
  final int totalCents;
}

/// Pure aggregation helpers, kept free of Flutter and database imports.
class TotalsMath {
  const TotalsMath._();

  static int sum(Iterable<int> values) => values.fold(0, (a, b) => a + b);

  static double share(int part, int total) => total <= 0 ? 0 : part / total;

  /// Relative change from [previous] to [current].
  ///
  /// Returns `null` when there is no previous data to compare against.
  static double? changeRatio({required int current, required int previous}) {
    if (previous <= 0) return current == 0 ? 0 : null;
    return (current - previous) / previous;
  }

  static String percent(double value, {int decimals = 0}) =>
      '${(value * 100).toStringAsFixed(decimals)}%';

  /// Fills gaps so every month in [months] has an entry, in order.
  static List<MonthlyTotal> fillMonths(
    List<DateTime> months,
    List<MonthlyTotal> data,
  ) {
    final byMonth = {for (final item in data) item.month: item.totalCents};
    return [
      for (final month in months)
        MonthlyTotal(
          month: Periods.monthKey(month),
          totalCents: byMonth[Periods.monthKey(month)] ?? 0,
        ),
    ];
  }
}
