import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'theme_settings.dart';

String themePresetLabel(AppLocalizations l10n, AppThemePreset preset) =>
    switch (preset) {
      AppThemePreset.indigo => l10n.themeIndigo,
      AppThemePreset.cyberRed => l10n.themeCyberRed,
    };

String themePresetDescription(AppLocalizations l10n, AppThemePreset preset) =>
    switch (preset) {
      AppThemePreset.indigo => l10n.themeIndigoDescription,
      AppThemePreset.cyberRed => l10n.themeCyberRedDescription,
    };

String themeModeLabel(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
  ThemeMode.system => l10n.settingsThemeSystem,
  ThemeMode.light => l10n.settingsThemeLight,
  ThemeMode.dark => l10n.settingsThemeDark,
};

String themeModeDescription(AppLocalizations l10n, ThemeMode mode) =>
    switch (mode) {
      ThemeMode.system => l10n.settingsThemeSystemDescription,
      ThemeMode.light => l10n.settingsThemeLightDescription,
      ThemeMode.dark => l10n.settingsThemeDarkDescription,
    };
