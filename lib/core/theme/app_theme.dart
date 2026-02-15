import 'package:flutter/material.dart';

/// Theme matching the reference: warm orange-yellow accent, dark bars/buttons,
/// white cards, rounded corners, subtle shadows.
class AppTheme {
  AppTheme._();

  // Reference palette: warm accent, dark primary, white surfaces
  static const Color _accentOrange = Color(0xFFF5A623);
  static const Color _accentOrangeLight = Color(0xFFFFC857);
  static const Color _darkGray = Color(0xFF1A1A1A);
  static const Color _darkGraySoft = Color(0xFF2D2D2D);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF6B6B6B);
  static const Color _surfaceWhite = Color(0xFFFFFFFF);
  static const Color _backgroundWarm = Color(0xFFFFF8F0);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: _darkGray,
          onPrimary: _surfaceWhite,
          primaryContainer: _darkGraySoft,
          onPrimaryContainer: _surfaceWhite,
          secondary: _accentOrange,
          onSecondary: _textPrimary,
          surface: _surfaceWhite,
          onSurface: _textPrimary,
          onSurfaceVariant: _textSecondary,
          outline: const Color(0xFFE0E0E0),
          shadow: Colors.black26,
          surfaceContainerHighest: const Color(0xFFF5F5F5),
        ),
        scaffoldBackgroundColor: _backgroundWarm,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: _surfaceWhite,
          foregroundColor: _textPrimary,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: _surfaceWhite,
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surfaceWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _darkGray,
            foregroundColor: _surfaceWhite,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _textPrimary,
            side: const BorderSide(color: Color(0xFFE0E0E0)),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: const TextStyle(
            fontWeight: FontWeight.bold,
            color: _textPrimary,
            letterSpacing: -0.5,
          ),
          headlineMedium: const TextStyle(
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
          titleLarge: const TextStyle(
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
          bodyLarge: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w500,
          ),
          bodyMedium: const TextStyle(
            color: _textSecondary,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _darkGraySoft,
          elevation: 8,
          height: 72,
          indicatorColor: _accentOrange.withValues(alpha: 0.2),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: _accentOrange,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              );
            }
            return const TextStyle(
              color: _surfaceWhite,
              fontSize: 12,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: _accentOrange, size: 26);
            }
            return const IconThemeData(color: _surfaceWhite, size: 26);
          }),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: _darkGraySoft,
          selectedColor: _darkGray,
          labelStyle: const TextStyle(color: _surfaceWhite),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: _darkGraySoft,
          onPrimary: _surfaceWhite,
          primaryContainer: _darkGray,
          onPrimaryContainer: _surfaceWhite,
          secondary: _accentOrangeLight,
          onSecondary: _textPrimary,
          surface: const Color(0xFF1E1E1E),
          onSurface: _surfaceWhite,
          onSurfaceVariant: const Color(0xFFB0B0B0),
          outline: const Color(0xFF404040),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: _surfaceWhite,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _darkGray,
          elevation: 8,
          height: 72,
          indicatorColor: _accentOrangeLight.withValues(alpha: 0.2),
          iconTheme: WidgetStateProperty.all(
            const IconThemeData(color: _surfaceWhite, size: 26),
          ),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
}
