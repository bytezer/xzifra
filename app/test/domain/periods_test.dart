import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:xzifra/domain/periods.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  group('Periods keys', () {
    test('dateKey pads month and day', () {
      expect(Periods.dateKey(DateTime(2026, 1, 5)), '2026-01-05');
      expect(Periods.dateKey(DateTime(2026, 11, 30)), '2026-11-30');
    });

    test('monthKey keeps year and month', () {
      expect(Periods.monthKey(DateTime(2026, 11, 30)), '2026-11');
    });

    test('start and exclusive end keys', () {
      expect(Periods.startKey(DateTime(2026, 11)), '2026-11-01');
      expect(Periods.endKeyExclusive(DateTime(2026, 11)), '2026-12-01');
      expect(Periods.endKeyExclusive(DateTime(2026, 12)), '2027-01-01');
    });
  });

  group('Periods arithmetic', () {
    test('addMonths rolls over years in both directions', () {
      expect(Periods.addMonths(DateTime(2026, 1), -1), DateTime(2025, 12));
      expect(Periods.addMonths(DateTime(2026, 12), 1), DateTime(2027, 1));
    });

    test('lastMonths returns ascending month starts', () {
      final months = Periods.lastMonths(DateTime(2026, 2), 3);
      expect(months, [
        DateTime(2025, 12),
        DateTime(2026, 1),
        DateTime(2026, 2),
      ]);
    });

    test('lastMonths normalizes a mid-month date', () {
      final months = Periods.lastMonths(DateTime(2026, 3, 17), 2);
      expect(months, [DateTime(2026, 2), DateTime(2026, 3)]);
    });
  });

  group('Periods labels', () {
    test('dayLabel recognizes today and yesterday', () {
      final now = DateTime.now();
      expect(Periods.dayLabel(Periods.dateKey(now)), 'Today');
      expect(
        Periods.dayLabel(
          Periods.dateKey(now.subtract(const Duration(days: 1))),
        ),
        'Yesterday',
      );
    });

    test('dayLabel falls back to a formatted date', () {
      expect(Periods.dayLabel('2026-03-07'), 'Sat, Mar 7');
    });

    test('dayLabel accepts localized today/yesterday labels', () {
      final now = DateTime.now();
      expect(
        Periods.dayLabel(
          Periods.dateKey(now),
          locale: 'es',
          today: 'Hoy',
          yesterday: 'Ayer',
        ),
        'Hoy',
      );
    });

    test('formats Spanish dates and months', () {
      expect(Periods.dayLabel('2026-03-07', locale: 'es'), 'sáb, 7 mar');
      expect(
        Periods.monthLabel(DateTime(2026, 11), locale: 'es'),
        'noviembre de 2026',
      );
      expect(
        Periods.fullDateLabel(DateTime(2026, 3, 7), locale: 'es'),
        'sábado, 7 de marzo de 2026',
      );
    });

    test('isCurrentMonth', () {
      final now = DateTime.now();
      expect(Periods.isCurrentMonth(DateTime(now.year, now.month)), isTrue);
      expect(
        Periods.isCurrentMonth(DateTime(now.year, now.month - 1)),
        isFalse,
      );
    });
  });
}
