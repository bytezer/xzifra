import '../domain/money.dart';
import '../domain/periods.dart';

/// Text shown by the Android home-screen widget.
class WidgetText {
  const WidgetText({
    required this.monthLabel,
    required this.amountLabel,
    required this.isEmpty,
  });

  /// Localized month name, or the empty-state message when there is no data.
  final String monthLabel;

  /// Formatted amount in the default currency, or an empty string.
  final String amountLabel;

  /// Whether the widget has no synchronized data to show yet.
  final bool isEmpty;
}

/// Builds the widget labels using the same date, money and locale rules as the
/// app UI.
class WidgetTextFormatter {
  const WidgetTextFormatter._();

  static WidgetText format({
    required DateTime month,
    required int? totalCents,
    required String currency,
    required String locale,
    required String emptyMessage,
  }) {
    if (totalCents == null) {
      return WidgetText(
        monthLabel: emptyMessage,
        amountLabel: '',
        isEmpty: true,
      );
    }
    return WidgetText(
      monthLabel: Periods.monthLabel(month, locale: locale),
      amountLabel: Money.format(totalCents, currency, locale: locale),
      isEmpty: false,
    );
  }
}
