import 'dart:math' as math;

import 'periods.dart';

/// Supported recurrence frequencies, stored as lowercase text.
enum RecurringFrequency {
  daily,
  weekly,
  monthly,
  yearly;

  String get storageValue => name;

  static RecurringFrequency? parse(String? value) {
    for (final frequency in values) {
      if (frequency.name == value) return frequency;
    }
    return null;
  }
}

/// Returns the next occurrence strictly after [date], clamping the day when
/// the target month is shorter (Jan 31 + 1 month -> Feb 28/29).
DateTime nextOccurrence(
  DateTime date,
  RecurringFrequency frequency,
  int interval,
) {
  final step = math.max(1, interval);
  final base = DateTime(date.year, date.month, date.day);
  switch (frequency) {
    case RecurringFrequency.daily:
      return DateTime(base.year, base.month, base.day + step);
    case RecurringFrequency.weekly:
      return DateTime(base.year, base.month, base.day + 7 * step);
    case RecurringFrequency.monthly:
      final target = base.month - 1 + step;
      final year = base.year + target ~/ 12;
      final month = target % 12 + 1;
      final day = math.min(base.day, _daysInMonth(year, month));
      return DateTime(year, month, day);
    case RecurringFrequency.yearly:
      final year = base.year + step;
      final day = math.min(base.day, _daysInMonth(year, base.month));
      return DateTime(year, base.month, day);
  }
}

/// Parses a `YYYY-MM-DD` key into a local midnight date.
DateTime? parseDateKey(String? value) {
  if (value == null || value.length < 10) return null;
  final parsed = DateTime.tryParse(value.substring(0, 10));
  if (parsed == null) return null;
  return DateTime(parsed.year, parsed.month, parsed.day);
}

/// A rule is due when it is active, its next date is today or earlier, and it
/// has not run past an optional end date.
bool isRecurringDue({
  required bool active,
  required String nextDate,
  String? endDate,
  required DateTime today,
}) {
  if (!active) return false;
  final next = parseDateKey(nextDate);
  if (next == null) return false;
  final day = DateTime(today.year, today.month, today.day);
  if (next.isAfter(day)) return false;

  final end = parseDateKey(endDate);
  return end == null || !next.isAfter(end);
}

String nextDateKey(
  String currentKey,
  RecurringFrequency frequency,
  int interval,
) {
  final current = parseDateKey(currentKey);
  if (current == null) return currentKey;
  return Periods.dateKey(nextOccurrence(current, frequency, interval));
}

int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
