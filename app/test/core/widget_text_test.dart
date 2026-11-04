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

    test('formats a recurring footer with a compact amount in English', () {
      final text = WidgetTextFormatter.format(
        month: DateTime(2026, 12),
        totalCents: 1000,
        currency: 'PEN',
        locale: 'en',
        emptyMessage: emptyMessage,
        nextUpPrefix: 'Next',
        upcoming: WidgetUpcoming(
          title: 'Rent',
          date: DateTime(2026, 12, 1),
          amountCents: 12000,
          currency: 'PEN',
          isRecurring: true,
        ),
      );

      expect(text.nextUpLabel, 'Next: Rent · S/ 120 · Dec 1');
      expect(text.hasNextUp, isTrue);
    });

    test('formats a reminder footer without an amount in Spanish', () {
      final text = WidgetTextFormatter.format(
        month: DateTime(2026, 12),
        totalCents: 1000,
        currency: 'PEN',
        locale: 'es',
        emptyMessage: emptyMessage,
        nextUpPrefix: 'Próximo',
        upcoming: WidgetUpcoming(
          title: 'Llamar al dentista',
          date: DateTime(2026, 12, 1),
        ),
      );

      expect(text.nextUpLabel, 'Próximo: Llamar al dentista · 1 dic');
      expect(text.hasNextUp, isTrue);
    });

    test('drops the recurring amount when the footer would be too long', () {
      final text = WidgetTextFormatter.format(
        month: DateTime(2026, 12),
        totalCents: 1000,
        currency: 'PEN',
        locale: 'en',
        emptyMessage: emptyMessage,
        nextUpPrefix: 'Next',
        upcoming: WidgetUpcoming(
          title: 'Very long subscription name',
          date: DateTime(2026, 12, 1),
          amountCents: 1200000,
          currency: 'PEN',
          isRecurring: true,
        ),
      );

      expect(text.nextUpLabel, 'Next: Very long subscription name · Dec 1');
      expect(text.nextUpLabel, isNot(contains('S/')));
    });

    test('hides the footer when there is nothing upcoming', () {
      final text = WidgetTextFormatter.format(
        month: DateTime(2026, 12),
        totalCents: 1000,
        currency: 'PEN',
        locale: 'en',
        emptyMessage: emptyMessage,
      );

      expect(text.nextUpLabel, isEmpty);
      expect(text.hasNextUp, isFalse);
    });

    test('shows the footer even before the monthly total loads', () {
      final text = WidgetTextFormatter.format(
        month: DateTime(2026, 12),
        totalCents: null,
        currency: 'PEN',
        locale: 'en',
        emptyMessage: emptyMessage,
        nextUpPrefix: 'Next',
        upcoming: WidgetUpcoming(title: 'Rent', date: DateTime(2026, 12, 1)),
      );

      expect(text.isEmpty, isTrue);
      expect(text.nextUpLabel, 'Next: Rent · Dec 1');
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
