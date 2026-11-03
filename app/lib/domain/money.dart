import 'package:intl/intl.dart';

/// Currency helpers. Amounts are always stored as integer cents.
class Money {
  const Money._();

  static const List<String> supportedCurrencies = ['PEN', 'USD'];

  static String symbolFor(String currency) => currency == 'PEN' ? 'S/' : r'$';

  /// Formats [cents] for display, e.g. `S/ 12.50` or `$12.50`.
  static String format(int cents, String currency) {
    final number = NumberFormat('#,##0.00', 'en_US').format(cents / 100);
    final symbol = symbolFor(currency);
    return currency == 'PEN' ? '$symbol $number' : '$symbol$number';
  }

  /// Short format for chart axes, e.g. `S/ 1.2k`.
  static String formatCompact(int cents, String currency) {
    final amount = cents / 100;
    final symbol = symbolFor(currency);
    final prefix = currency == 'PEN' ? '$symbol ' : symbol;
    if (amount.abs() >= 1000000) {
      return '$prefix${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount.abs() >= 1000) {
      return '$prefix${(amount / 1000).toStringAsFixed(1)}k';
    }
    return '$prefix${amount.toStringAsFixed(0)}';
  }

  static String decimal(int cents) => (cents / 100).toStringAsFixed(2);
}

/// Incremental amount input used by the custom numeric keypad.
class AmountInput {
  const AmountInput([this.raw = '']);

  final String raw;

  static const int maxIntegerDigits = 9;

  int get cents {
    if (raw.isEmpty || raw == '.') return 0;
    final normalized = raw.endsWith('.') ? '${raw}0' : raw;
    final parts = normalized.split('.');
    final whole = int.tryParse(parts.first) ?? 0;
    final fraction = parts.length > 1
        ? parts[1].padRight(2, '0').substring(0, 2)
        : '00';
    return whole * 100 + (int.tryParse(fraction) ?? 0);
  }

  String get display => raw.isEmpty ? '0' : raw;

  bool get isEmpty => cents == 0;

  AmountInput appendDigit(String digit) {
    assert(digit.length == 1 && int.tryParse(digit) != null);
    final dot = raw.indexOf('.');
    if (dot >= 0) {
      if (raw.length - dot > 2) return this;
      return AmountInput('$raw$digit');
    }
    if (raw == '0') return AmountInput(digit);
    if (raw.length >= maxIntegerDigits) return this;
    return AmountInput('$raw$digit');
  }

  AmountInput appendDecimal() {
    if (raw.contains('.')) return this;
    return AmountInput(raw.isEmpty ? '0.' : '$raw.');
  }

  AmountInput backspace() {
    if (raw.isEmpty) return this;
    return AmountInput(raw.substring(0, raw.length - 1));
  }

  AmountInput clear() => const AmountInput();

  static AmountInput fromCents(int cents) {
    final whole = cents ~/ 100;
    final fraction = cents % 100;
    if (fraction == 0) return AmountInput('$whole');
    return AmountInput('$whole.${fraction.toString().padLeft(2, '0')}');
  }
}
