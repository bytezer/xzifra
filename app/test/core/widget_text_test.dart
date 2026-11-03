import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:xzifra/core/widget_text.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  group('WidgetTextFormatter', () {
    const emptyMessage = 'Open Xzifra to see this month';

    test('formats the month and amount in English', () {
      final text = WidgetTextFormatter.format(
        month: DateTime(2026, 11),
        totalCents: 123456,
        currency: 'PEN',
        locale: 'en',
        emptyMessage: emptyMessage,
      );

      expect(text.monthLabel, 'November 2026');
      expect(text.amountLabel, 'S/ 1,234.56');
      expect(text.isEmpty, isFalse);
    });

    test('formats the month and amount in Spanish', () {
      final text = WidgetTextFormatter.format(
        month: DateTime(2026, 11),
        totalCents: 123456,
        currency: 'PEN',
        locale: 'es',
        emptyMessage: emptyMessage,
      );

      expect(text.monthLabel, 'noviembre de 2026');
      expect(text.amountLabel, 'S/ 1.234,56');
      expect(text.isEmpty, isFalse);
    });

    test('uses the empty message until widget data is available', () {
      final text = WidgetTextFormatter.format(
        month: DateTime(2026, 11),
        totalCents: null,
        currency: 'USD',
        locale: 'en',
        emptyMessage: emptyMessage,
      );

      expect(text.monthLabel, emptyMessage);
      expect(text.amountLabel, isEmpty);
      expect(text.isEmpty, isTrue);
    });

    test('shows zero spending once the month total is loaded', () {
      final text = WidgetTextFormatter.format(
        month: DateTime(2026, 11),
        totalCents: 0,
        currency: 'USD',
        locale: 'en',
        emptyMessage: emptyMessage,
      );

      expect(text.monthLabel, 'November 2026');
      expect(text.amountLabel, r'$0.00');
      expect(text.isEmpty, isFalse);
    });
  });
}
