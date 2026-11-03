import 'package:flutter/material.dart';

import 'theme_settings.dart';

const Color xzifraSeed = Color(0xFF4F46E5);
const Color cyberRedSeed = Color(0xFFFF1744);

ThemeData buildAppTheme({
  required AppThemePreset preset,
  required Brightness brightness,
}) {
  return switch (preset) {
    AppThemePreset.indigo => _buildTheme(
      ColorScheme.fromSeed(seedColor: xzifraSeed, brightness: brightness),
      cyber: false,
    ),
    // Cyber Red is dark by design; both slots receive the dark scheme so a
    // light system mode never produces a washed-out variant.
    AppThemePreset.cyberRed => _buildTheme(_cyberScheme(), cyber: true),
  };
}

ColorScheme _cyberScheme() {
  final base = ColorScheme.fromSeed(
    seedColor: cyberRedSeed,
    brightness: Brightness.dark,
  );

  return base.copyWith(
    primary: const Color(0xFFFF1744),
    onPrimary: Colors.black,
    primaryContainer: const Color(0xFF4A0A14),
    onPrimaryContainer: const Color(0xFFFFD9DE),
    secondary: const Color(0xFFFF8A9B),
    onSecondary: Colors.black,
    secondaryContainer: const Color(0xFF3A1018),
    onSecondaryContainer: const Color(0xFFFFD9DE),
    surface: const Color(0xFF050506),
    onSurface: const Color(0xFFF5F5F7),
    surfaceContainerLowest: const Color(0xFF000000),
    surfaceContainerLow: const Color(0xFF0C0C0E),
    surfaceContainer: const Color(0xFF121216),
    surfaceContainerHigh: const Color(0xFF1A1A1F),
    surfaceContainerHighest: const Color(0xFF24242B),
    onSurfaceVariant: const Color(0xFFB8B8C2),
    outline: const Color(0xFF4A4A55),
    outlineVariant: const Color(0xFF2A2A33),
    error: const Color(0xFFFF6E6E),
    onError: Colors.black,
    errorContainer: const Color(0xFF5C0A12),
    onErrorContainer: const Color(0xFFFFD9DE),
    inverseSurface: const Color(0xFFF5F5F7),
    onInverseSurface: const Color(0xFF111114),
    inversePrimary: const Color(0xFFB00020),
    shadow: Colors.black,
    scrim: Colors.black,
  );
}

ThemeData _buildTheme(ColorScheme scheme, {required bool cyber}) {
  final radius = cyber ? 12.0 : 16.0;
  final cardSide = cyber
      ? BorderSide(color: scheme.primary.withValues(alpha: 0.18))
      : BorderSide.none;

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      iconTheme: cyber ? IconThemeData(color: scheme.primary) : null,
      shape: cyber
          ? Border(
              bottom: BorderSide(color: scheme.primary.withValues(alpha: 0.2)),
            )
          : null,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: cardSide,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: cyber
          ? scheme.primary.withValues(alpha: 0.18)
          : scheme.primaryContainer,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: cyber
          ? WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
                color: states.contains(WidgetState.selected)
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
              ),
            )
          : null,
    ),
    floatingActionButtonTheme: cyber
        ? FloatingActionButtonThemeData(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
          )
        : null,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      filled: true,
      fillColor: scheme.surfaceContainerLowest,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cyber ? 10 : 14),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      selectedColor: cyber ? scheme.primary.withValues(alpha: 0.18) : null,
      side: cyber ? BorderSide(color: scheme.outlineVariant) : null,
    ),
    dividerTheme: cyber
        ? DividerThemeData(color: scheme.outlineVariant, space: 1)
        : null,
    dialogTheme: cyber
        ? DialogThemeData(
            backgroundColor: scheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: scheme.primary.withValues(alpha: 0.18)),
            ),
          )
        : null,
    bottomSheetTheme: cyber
        ? BottomSheetThemeData(
            backgroundColor: scheme.surfaceContainerLow,
            surfaceTintColor: Colors.transparent,
          )
        : null,
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: cyber ? scheme.surfaceContainerHigh : null,
      contentTextStyle: cyber ? TextStyle(color: scheme.onSurface) : null,
    ),
  );

  if (!cyber) return base;

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      labelLarge: base.textTheme.labelLarge?.copyWith(letterSpacing: 0.4),
      labelMedium: base.textTheme.labelMedium?.copyWith(letterSpacing: 0.4),
      titleSmall: base.textTheme.titleSmall?.copyWith(letterSpacing: 0.3),
    ),
  );
}
