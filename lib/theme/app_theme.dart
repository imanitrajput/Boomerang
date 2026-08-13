import 'package:flutter/material.dart';

class AppTheme {
  static const _primary = Color(0xFF24389C);
  static const _onPrimary = Color(0xFFFFFFFF);
  static const _primaryContainer = Color(0xFF3F51B5);
  static const _onPrimaryContainer = Color(0xFFCACFFF);

  static const _secondary = Color(0xFF1B6B51);
  static const _onSecondary = Color(0xFFFFFFFF);
  static const _secondaryContainer = Color(0xFFA6F2D1);
  static const _onSecondaryContainer = Color(0xFF237157);

  static const _tertiary = Color(0xFF8A002D);
  static const _onTertiary = Color(0xFFFFFFFF);
  static const _tertiaryContainer = Color(0xFFAD1F42);
  static const _onTertiaryContainer = Color(0xFFFFC3C8);

  static const _error = Color(0xFFBA1A1A);
  static const _onError = Color(0xFFFFFFFF);
  static const _errorContainer = Color(0xFFFFDAD6);
  static const _onErrorContainer = Color(0xFF93000A);

  static const _surface = Color(0xFFF8F9FC);
  static const _onSurface = Color(0xFF191C1E);
  static const _surfaceVariant = Color(0xFFE1E2E5);
  static const _onSurfaceVariant = Color(0xFF454652);
  
  static const _outline = Color(0xFF757684);
  static const _outlineVariant = Color(0xFFC5C5D4);

  // Dark Mode Adjustments (Simplified for now, can be expanded based on full MD3 dark token mapping)
  static const _darkSurface = Color(0xFF191C1E);
  static const _darkOnSurface = Color(0xFFE1E2E5);
  static const _darkSurfaceVariant = Color(0xFF454652);
  static const _darkOnSurfaceVariant = Color(0xFFC5C5D4);
  static const _darkPrimary = Color(0xFFBAC3FF); // inverse-primary
  static const _darkOnPrimary = Color(0xFF00105C);

  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(fontFamily: 'Roboto Flex', fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25, height: 64/57),
    headlineLarge: TextStyle(fontFamily: 'Roboto Flex', fontSize: 32, fontWeight: FontWeight.w400, letterSpacing: 0, height: 40/32),
    titleLarge: TextStyle(fontFamily: 'Roboto Flex', fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: 0, height: 28/22),
    bodyLarge: TextStyle(fontFamily: 'Roboto Flex', fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5, height: 24/16),
    bodyMedium: TextStyle(fontFamily: 'Roboto Flex', fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, height: 20/14),
    labelLarge: TextStyle(fontFamily: 'Roboto Flex', fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, height: 20/14),
    labelMedium: TextStyle(fontFamily: 'Roboto Flex', fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 16/12),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: _primary,
        onPrimary: _onPrimary,
        primaryContainer: _primaryContainer,
        onPrimaryContainer: _onPrimaryContainer,
        secondary: _secondary,
        onSecondary: _onSecondary,
        secondaryContainer: _secondaryContainer,
        onSecondaryContainer: _onSecondaryContainer,
        tertiary: _tertiary,
        onTertiary: _onTertiary,
        tertiaryContainer: _tertiaryContainer,
        onTertiaryContainer: _onTertiaryContainer,
        error: _error,
        onError: _onError,
        errorContainer: _errorContainer,
        onErrorContainer: _onErrorContainer,
        surface: _surface,
        onSurface: _onSurface,
        surfaceContainerHighest: _surfaceVariant,
        onSurfaceVariant: _onSurfaceVariant,
        outline: _outline,
        outlineVariant: _outlineVariant,
      ),
      textTheme: _textTheme,
      scaffoldBackgroundColor: _surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: _surface,
        foregroundColor: _primary,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _secondaryContainer,
        foregroundColor: _onSecondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), // Rounded XL
      ),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 1, // Level 1 Card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white, // Surface Container Lowest usually
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: _outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: _outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        labelStyle: const TextStyle(color: _onSurfaceVariant),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: _darkPrimary,
        onPrimary: _darkOnPrimary,
        primaryContainer: _primary,
        onPrimaryContainer: _onPrimaryContainer,
        secondary: _secondaryContainer,
        onSecondary: _onSecondaryContainer,
        secondaryContainer: _secondary,
        onSecondaryContainer: _onSecondary,
        tertiary: _tertiaryContainer,
        onTertiary: _onTertiaryContainer,
        tertiaryContainer: _tertiary,
        onTertiaryContainer: _onTertiary,
        error: _errorContainer,
        onError: _onErrorContainer,
        errorContainer: _error,
        onErrorContainer: _onError,
        surface: _darkSurface,
        onSurface: _darkOnSurface,
        surfaceContainerHighest: _darkSurfaceVariant,
        onSurfaceVariant: _darkOnSurfaceVariant,
        outline: _outlineVariant,
        outlineVariant: _outline,
      ),
      textTheme: _textTheme,
      scaffoldBackgroundColor: _darkSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _secondaryContainer,
        foregroundColor: _onSecondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      cardTheme: CardThemeData(
        color: _darkSurfaceVariant,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: _outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: _outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        labelStyle: const TextStyle(color: _darkOnSurfaceVariant),
      ),
    );
  }
}
