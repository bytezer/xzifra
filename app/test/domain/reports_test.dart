import 'package:flutter_test/flutter_test.dart';
import 'package:xzifra/domain/periods.dart';
import 'package:xzifra/domain/reports.dart';

void main() {
  group('TotalsMath', () {
    test('sum', () {
      expect(TotalsMath.sum([100, 250, 50]), 400);
      expect(TotalsMath.sum(const <int>[]), 0);
    });

    test('share handles an empty total', () {
      expect(TotalsMath.share(50, 100), 0.5);
      expect(TotalsMath.share(50, 0), 0);
    });

    test('changeRatio', () {
      expect(
        TotalsMath.changeRatio(current: 150, previous: 100),
        closeTo(0.5, 1e-9),
      );
      expect(
        TotalsMath.changeRatio(current: 50, previous: 100),
        closeTo(-0.5, 1e-9),
      );
      expect(TotalsMath.changeRatio(current: 0, previous: 0), 0);
      expect(TotalsMath.changeRatio(current: 100, previous: 0), isNull);
    });

    test('percent', () {
      expect(TotalsMath.percent(0.25), '25%');
      expect(TotalsMath.percent(0.256, decimals: 1), '25.6%');
    });

    test('fillMonths fills gaps in order', () {
      final months = Periods.lastMonths(DateTime(2026, 3), 3);
      final filled = TotalsMath.fillMonths(months, const [
        MonthlyTotal(month: '2026-01', totalCents: 100),
        MonthlyTotal(month: '2026-03', totalCents: 300),
      ]);

      expect(filled.length, 3);
      expect(filled[0].month, '2026-01');
      expect(filled[0].totalCents, 100);
      expect(filled[1].month, '2026-02');
      expect(filled[1].totalCents, 0);
      expect(filled[2].month, '2026-03');
      expect(filled[2].totalCents, 300);
    });
  });
}
