import '../l10n/app_localizations.dart';
import 'locale_settings.dart';

String languageLabel(AppLocalizations l10n, AppLocale setting) =>
    switch (setting) {
      AppLocale.system => l10n.settingsLanguageSystem,
      AppLocale.english => 'English',
      AppLocale.spanish => 'Español',
    };
