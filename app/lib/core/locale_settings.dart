import 'package:flutter/widgets.dart';

enum AppLocale { system, english, spanish }

extension AppLocaleInfo on AppLocale {
  String get storageValue => switch (this) {
    AppLocale.system => 'system',
    AppLocale.english => 'en',
    AppLocale.spanish => 'es',
  };

  /// `null` means "follow the device locale".
  Locale? get locale => switch (this) {
    AppLocale.system => null,
    AppLocale.english => const Locale('en'),
    AppLocale.spanish => const Locale('es'),
  };
}

AppLocale parseAppLocale(String? value) => switch (value) {
  'en' => AppLocale.english,
  'es' => AppLocale.spanish,
  _ => AppLocale.system,
};
