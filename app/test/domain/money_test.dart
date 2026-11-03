import 'package:flutter_test/flutter_test.dart';
import 'package:xzifra/domain/money.dart';

void main() {
  group('Money.format', () {
    test('formats soles with a space after the symbol', () {
      expect(Money.format(1250, 'PEN'), 'S/ 12.50');
      expect(Money.format(0, 'PEN'), 'S/ 0.00');
      expect(Money.format(123456, 'PEN'), 'S/ 1,234.56');
    });

    test('formats dollars without a space', () {
      expect(Money.format(1250, 'USD'), r'$12.50');
      expect(Money.format(5, 'USD'), r'$0.05');
    });

    test('compact format shortens large amounts', () {
      expect(Money.formatCompact(1250, 'PEN'), 'S/ 13');
      expect(Money.formatCompact(123456, 'PEN'), 'S/ 1.23K');
      expect(Money.formatCompact(123456789, 'USD'), r'$1.23M');
    });

    test('formats numbers for Spanish', () {
      expect(Money.format(123456, 'PEN', locale: 'es'), 'S/ 1.234,56');
      expect(Money.format(1250, 'USD', locale: 'es'), r'$12,50');
      expect(
        Money.formatCompact(123456, 'PEN', locale: 'es'),
        'S/ 1,23\u00A0mil',
      );
    });

    test('decimal returns the plain amount', () {
      expect(Money.decimal(1250), '12.50');
      expect(Money.decimal(5), '0.05');
    });
  });

  group('AmountInput', () {
    test('builds cents from keypad input', () {
      final input = const AmountInput()
          .appendDigit('1')
          .appendDigit('2')
          .appendDecimal()
          .appendDigit('5');
      expect(input.raw, '12.5');
      expect(input.cents, 1250);
    });

    test('replaces a leading zero', () {
      final input = const AmountInput().appendDigit('0').appendDigit('5');
      expect(input.raw, '5');
      expect(input.cents, 500);
    });

    test('ignores a third decimal digit', () {
      final input = const AmountInput()
          .appendDigit('1')
          .appendDecimal()
          .appendDigit('2')
          .appendDigit('3')
          .appendDigit('4');
      expect(input.raw, '1.23');
      expect(input.cents, 123);
    });

    test('allows only one decimal point', () {
      final input = const AmountInput()
          .appendDigit('1')
          .appendDecimal()
          .appendDecimal();
      expect(input.raw, '1.');
      expect(input.cents, 100);
    });

    test('backspace and clear', () {
      final input = const AmountInput().appendDigit('1').appendDigit('2');
      expect(input.backspace().raw, '1');
      expect(input.backspace().backspace().raw, '');
      expect(input.clear().raw, '');
    });

    test('round-trips from cents', () {
      expect(AmountInput.fromCents(1250).raw, '12.50');
      expect(AmountInput.fromCents(1200).raw, '12');
      expect(AmountInput.fromCents(5).raw, '0.05');
      expect(AmountInput.fromCents(1250).cents, 1250);
    });

    test('caps the integer part', () {
      var input = const AmountInput();
      for (var i = 0; i < 15; i++) {
        input = input.appendDigit('9');
      }
      expect(input.raw.length, AmountInput.maxIntegerDigits);
    });
  });
}
