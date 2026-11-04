import 'package:flutter_test/flutter_test.dart';
import 'package:xzifra/domain/recurrence.dart';

void main() {
  group('nextOccurrence', () {
    test('adds daily and weekly intervals', () {
      expect(
        nextOccurrence(DateTime(2026, 11, 3), RecurringFrequency.daily, 3),
        DateTime(2026, 11, 6),
      );
      expect(
        nextOccurrence(DateTime(2026, 11, 3), RecurringFrequency.weekly, 2),
        DateTime(2026, 11, 17),
      );
    });

    test('clamps month-end dates to the target month', () {
      expect(
        nextOccurrence(DateTime(2026, 1, 31), RecurringFrequency.monthly, 1),
        DateTime(2026, 2, 28),
      );
      expect(
        nextOccurrence(DateTime(2028, 1, 31), RecurringFrequency.monthly, 1),
        DateTime(2028, 2, 29),
      );
      expect(
        nextOccurrence(DateTime(2026, 8, 31), RecurringFrequency.monthly, 1),
        DateTime(2026, 9, 30),
      );
      expect(
        nextOccurrence(DateTime(2026, 12, 31), RecurringFrequency.monthly, 1),
        DateTime(2027, 1, 31),
      );
    });

    test('supports multi-month intervals without drifting', () {
      expect(
        nextOccurrence(DateTime(2026, 1, 31), RecurringFrequency.monthly, 2),
        DateTime(2026, 3, 31),
      );
      expect(
        nextOccurrence(DateTime(2026, 11, 30), RecurringFrequency.monthly, 3),
        DateTime(2027, 2, 28),
      );
    });

    test('clamps leap-day yearly occurrences', () {
      expect(
        nextOccurrence(DateTime(2028, 2, 29), RecurringFrequency.yearly, 1),
        DateTime(2029, 2, 28),
      );
      expect(
        nextOccurrence(DateTime(2028, 2, 29), RecurringFrequency.yearly, 4),
        DateTime(2032, 2, 29),
      );
    });

    test('treats intervals below one as one', () {
      expect(
        nextOccurrence(DateTime(2026, 11, 3), RecurringFrequency.daily, 0),
        DateTime(2026, 11, 4),
      );
    });
  });

  group('nextDateKey', () {
    test('round-trips date keys across a year boundary', () {
      expect(
        nextDateKey('2026-12-31', RecurringFrequency.weekly, 1),
        '2027-01-07',
      );
      expect(
        nextDateKey('2026-01-31', RecurringFrequency.monthly, 1),
        '2026-02-28',
      );
      expect(
        nextDateKey('not-a-date', RecurringFrequency.daily, 1),
        'not-a-date',
      );
    });
  });

  group('isRecurringDue', () {
    final today = DateTime(2026, 11, 3);

    test('is due when active and next date is today or earlier', () {
      expect(
        isRecurringDue(active: true, nextDate: '2026-11-03', today: today),
        isTrue,
      );
      expect(
        isRecurringDue(active: true, nextDate: '2026-11-02', today: today),
        isTrue,
      );
      expect(
        isRecurringDue(active: true, nextDate: '2026-11-04', today: today),
        isFalse,
      );
    });

    test('respects paused rules and end dates', () {
      expect(
        isRecurringDue(active: false, nextDate: '2026-11-01', today: today),
        isFalse,
      );
      expect(
        isRecurringDue(
          active: true,
          nextDate: '2026-11-01',
          endDate: '2026-10-31',
          today: today,
        ),
        isFalse,
      );
      expect(
        isRecurringDue(
          active: true,
          nextDate: '2026-11-01',
          endDate: '2026-11-30',
          today: today,
        ),
        isTrue,
      );
    });
  });
}
