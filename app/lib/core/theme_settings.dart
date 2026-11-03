import 'package:flutter/material.dart';

enum AppThemePreset { indigo, cyberRed }

extension AppThemePresetInfo on AppThemePreset {
  String get storageValue => name;

  String get label => switch (this) {
    AppThemePreset.indigo => 'Indigo',
    AppThemePreset.cyberRed => 'Cyber Red',
  };

  String get description => switch (this) {
    AppThemePreset.indigo => 'Calm indigo accents on Material 3 surfaces.',
    AppThemePreset.cyberRed => 'Black surfaces with neon red accents.',
  };

  List<Color> get swatches => switch (this) {
    AppThemePreset.indigo => const [
      Color(0xFF4F46E5),
      Color(0xFFC7D2FE),
      Color(0xFFF8FAFC),
    ],
    AppThemePreset.cyberRed => const [
      Color(0xFFFF1744),
      Color(0xFF0C0C0E),
      Color(0xFFF5F5F7),
    ],
  };

  /// Cyber Red is dark by design.
  bool get supportsLight => this == AppThemePreset.indigo;
}

class AppThemeSettings {
  const AppThemeSettings({
    this.preset = AppThemePreset.indigo,
    this.mode = ThemeMode.system,
  });

  final AppThemePreset preset;
  final ThemeMode mode;

  AppThemeSettings copyWith({AppThemePreset? preset, ThemeMode? mode}) {
    return AppThemeSettings(
      preset: preset ?? this.preset,
      mode: mode ?? this.mode,
    );
  }
}

AppThemePreset parseThemePreset(String? value) => switch (value) {
  'cyberRed' => AppThemePreset.cyberRed,
  _ => AppThemePreset.indigo,
};

ThemeMode parseThemeMode(String? value) => switch (value) {
  'light' => ThemeMode.light,
  'dark' => ThemeMode.dark,
  _ => ThemeMode.system,
};

String themeModeStorageValue(ThemeMode mode) => switch (mode) {
  ThemeMode.light => 'light',
  ThemeMode.dark => 'dark',
  ThemeMode.system => 'system',
};

String themeModeLabel(ThemeMode mode) => switch (mode) {
  ThemeMode.light => 'Light',
  ThemeMode.dark => 'Dark',
  ThemeMode.system => 'System',
};
