import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xzifra/core/locale_settings.dart';

void main() {
  test('parses stored locales', () {
    expect(parseAppLocale('en'), AppLocale.english);
    expect(parseAppLocale('es'), AppLocale.spanish);
    expect(parseAppLocale('system'), AppLocale.system);
    expect(parseAppLocale(null), AppLocale.system);
    expect(parseAppLocale('fr'), AppLocale.system);
  });

  test('maps to Flutter locales', () {
    expect(AppLocale.system.locale, isNull);
    expect(AppLocale.english.locale, const Locale('en'));
    expect(AppLocale.spanish.locale, const Locale('es'));
  });

  test('storage values round-trip', () {
    for (final value in AppLocale.values) {
      expect(parseAppLocale(value.storageValue), value);
    }
  });
}
