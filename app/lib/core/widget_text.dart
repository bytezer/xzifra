import 'package:intl/intl.dart';

import '../domain/money.dart';
import '../domain/periods.dart';

/// Text shown by the Android home-screen widget.
class WidgetText {
  const WidgetText({
    required this.monthLabel,
    required this.amountLabel,
    required this.isEmpty,
    this.nextUpLabel = '',
  });

  /// Localized month name, or the empty-state message when there is no data.
  final String monthLabel;

  /// Formatted amount in the default currency, or an empty string.
  final String amountLabel;

  /// Whether the widget has no synchronized data to show yet.
  final bool isEmpty;

  /// Localized "Next: …" footer, or an empty string to hide it.
  final String nextUpLabel;

  bool get hasNextUp => nextUpLabel.isNotEmpty;
}

/// The next recurring rule or pending reminder shown in the widget footer.
class WidgetUpcoming {
  const WidgetUpcoming({
    required this.title,
    required this.date,
    this.amountCents,
    this.currency,
    this.isRecurring = false,
  });

  final String title;
  final DateTime date;
  final int? amountCents;
  final String? currency;
  final bool isRecurring;
}

/// Builds the widget labels using the same date, money and locale rules as the
/// app UI.
class WidgetTextFormatter {
  const WidgetTextFormatter._();

  static const int _maxFooterLength = 34;

  static WidgetText format({
    required DateTime month,
    required int? totalCents,
    required String currency,
    required String locale,
    required String emptyMessage,
    WidgetUpcoming? upcoming,
    String nextUpPrefix = 'Next',
  }) {
    final nextUpLabel = upcoming == null
        ? ''
        : _formatUpcoming(upcoming, locale, nextUpPrefix);

    if (totalCents == null) {
      return WidgetText(
        monthLabel: emptyMessage,
        amountLabel: '',
        isEmpty: true,
        nextUpLabel: nextUpLabel,
      );
    }
    return WidgetText(
      monthLabel: Periods.monthLabel(month, locale: locale),
      amountLabel: Money.format(totalCents, currency, locale: locale),
      isEmpty: false,
      nextUpLabel: nextUpLabel,
    );
  }

  static String _formatUpcoming(
    WidgetUpcoming upcoming,
    String locale,
    String prefix,
  ) {
    final date = DateFormat.MMMd(locale).format(upcoming.date);
    final base = '$prefix: ${upcoming.title} · $date';
    if (!upcoming.isRecurring ||
        upcoming.amountCents == null ||
        upcoming.currency == null) {
      return base;
    }

    final amount = Money.formatCompact(
      upcoming.amountCents!,
      upcoming.currency!,
      locale: locale,
    );
    final withAmount = '$prefix: ${upcoming.title} · $amount · $date';
    return withAmount.length <= _maxFooterLength ? withAmount : base;
  }
}
