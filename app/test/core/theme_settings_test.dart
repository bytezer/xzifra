import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xzifra/core/theme.dart';
import 'package:xzifra/core/theme_settings.dart';

void main() {
  group('parseThemePreset', () {
    test('parses known values', () {
      expect(parseThemePreset('indigo'), AppThemePreset.indigo);
      expect(parseThemePreset('cyberRed'), AppThemePreset.cyberRed);
    });

    test('defaults null and unknown values to indigo', () {
      expect(parseThemePreset(null), AppThemePreset.indigo);
      expect(parseThemePreset('nope'), AppThemePreset.indigo);
    });
  });

  group('parseThemeMode', () {
    test('parses known values', () {
      expect(parseThemeMode('system'), ThemeMode.system);
      expect(parseThemeMode('light'), ThemeMode.light);
      expect(parseThemeMode('dark'), ThemeMode.dark);
    });

    test('defaults null and unknown values to system', () {
      expect(parseThemeMode(null), ThemeMode.system);
      expect(parseThemeMode('nope'), ThemeMode.system);
    });
  });

  test('theme mode storage round-trips', () {
    for (final mode in ThemeMode.values) {
      expect(parseThemeMode(themeModeStorageValue(mode)), mode);
    }
  });

  test('cyber red is dark-only', () {
    expect(AppThemePreset.indigo.supportsLight, isTrue);
    expect(AppThemePreset.cyberRed.supportsLight, isFalse);
  });

  test('cyber red builds a dark scheme even when asked for light', () {
    final theme = buildAppTheme(
      preset: AppThemePreset.cyberRed,
      brightness: Brightness.light,
    );

    expect(theme.colorScheme.brightness, Brightness.dark);
    expect(theme.colorScheme.primary, const Color(0xFFFF1744));
    expect(theme.scaffoldBackgroundColor, const Color(0xFF050506));
  });

  test('indigo keeps the requested brightness', () {
    final light = buildAppTheme(
      preset: AppThemePreset.indigo,
      brightness: Brightness.light,
    );
    final dark = buildAppTheme(
      preset: AppThemePreset.indigo,
      brightness: Brightness.dark,
    );

    expect(light.colorScheme.brightness, Brightness.light);
    expect(dark.colorScheme.brightness, Brightness.dark);
  });
}
