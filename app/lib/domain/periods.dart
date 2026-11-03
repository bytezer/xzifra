import 'package:intl/intl.dart';

/// Date helpers. Expense dates are stored as `YYYY-MM-DD` text so that
/// lexicographic comparison matches chronological order and no timezone
/// conversion is involved.
class Periods {
  const Periods._();

  static String dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String monthKey(DateTime date) => dateKey(date).substring(0, 7);

  static DateTime monthStart(DateTime date) => DateTime(date.year, date.month);

  static DateTime addMonths(DateTime date, int months) =>
      DateTime(date.year, date.month + months);

  static String startKey(DateTime month) => '${monthKey(month)}-01';

  static String endKeyExclusive(DateTime month) =>
      '${monthKey(addMonths(month, 1))}-01';

  /// Returns [count] month starts ending at [endMonth], ascending.
  static List<DateTime> lastMonths(DateTime endMonth, int count) {
    final end = monthStart(endMonth);
    return List<DateTime>.generate(
      count,
      (index) => addMonths(end, index - count + 1),
    );
  }

  static String monthLabel(DateTime month) =>
      DateFormat.yMMMM('en_US').format(month);

  static String shortMonthLabel(DateTime month) =>
      DateFormat.MMM('en_US').format(month);

  static String fullDateLabel(DateTime date) =>
      DateFormat('EEEE, MMM d, y', 'en_US').format(date);

  static String dayLabel(String isoDate) {
    final now = DateTime.now();
    if (isoDate == dateKey(now)) return 'Today';
    if (isoDate == dateKey(now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return isoDate;
    return DateFormat('EEE, MMM d', 'en_US').format(parsed);
  }

  static bool isCurrentMonth(DateTime month) {
    final now = DateTime.now();
    return month.year == now.year && month.month == now.month;
  }
}
