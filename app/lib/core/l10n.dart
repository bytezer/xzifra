import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// The `intl` locale name to use for dates and numbers.
String localeNameOf(BuildContext context) =>
    Localizations.localeOf(context).languageCode;
