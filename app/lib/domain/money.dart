import 'package:intl/intl.dart';

/// Currency helpers. Amounts are always stored as integer cents.
class Money {
  const Money._();

  static const List<String> supportedCurrencies = ['PEN', 'USD'];

  static String symbolFor(String currency) => currency == 'PEN' ? 'S/' : r'$';

  /// Formats [cents] for display, e.g. `S/ 12.50` or `$12.50`.
  static String format(int cents, String currency, {String locale = 'en_US'}) {
    final number = NumberFormat('#,##0.00', locale).format(cents / 100);
    final symbol = symbolFor(currency);
    return currency == 'PEN' ? '$symbol $number' : '$symbol$number';
  }

  /// Short format for chart axes, e.g. `S/ 1.2K`.
  static String formatCompact(
    int cents,
    String currency, {
    String locale = 'en_US',
  }) {
    final amount = cents / 100;
    final symbol = symbolFor(currency);
    final prefix = currency == 'PEN' ? '$symbol ' : symbol;
    if (amount.abs() >= 1000) {
      final compact = NumberFormat.compact(locale: locale).format(amount);
      return '$prefix$compact';
    }
    return '$prefix${amount.toStringAsFixed(0)}';
  }

  static String decimal(int cents) => (cents / 100).toStringAsFixed(2);

  /// Parses a user-entered amount such as `12.50` or `12,50` into cents.
  ///
  /// Returns `null` when the text is not a positive amount with at most two
  /// decimal places.
  static int? parseCents(String input) {
    final text = input.trim().replaceAll(' ', '').replaceAll(',', '.');
    if (text.isEmpty) return null;
    final parts = text.split('.');
    if (parts.length > 2) return null;

    final wholeText = parts.first.isEmpty ? '0' : parts.first;
    if (!_digitsOnly.hasMatch(wholeText)) return null;
    final whole = int.tryParse(wholeText);
    if (whole == null) return null;

    var fraction = 0;
    if (parts.length == 2) {
      final fractionText = parts[1];
      if (fractionText.length > 2) return null;
      if (fractionText.isNotEmpty) {
        if (!_digitsOnly.hasMatch(fractionText)) return null;
        fraction = int.parse(fractionText.padRight(2, '0'));
      }
    }

    final cents = whole * 100 + fraction;
    return cents > 0 ? cents : null;
  }

  static final RegExp _digitsOnly = RegExp(r'^\d+$');
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
