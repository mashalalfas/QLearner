import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cotton Cloud Theme - QLearner App
/// Primary colors: Lavender header, Cream body, Purple accent
class AppTheme {
  // Color palette
  static const Color lavender = Color(0xFFE6E6FA);
  static const Color cream = Color(0xFFFFFDD0);
  static const Color accentPurple = Color(0xFF7C6FAF);
  static const Color darkPurple = Color(0xFF5A4A8F);
  static const Color lightLavender = Color(0xFFF5F5FF);
  static const Color darkText = Color(0xFF2D2D3A);
  static const Color secondaryText = Color(0xFF6B6B80);

  // Light theme with Arabic font support
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: accentPurple,
        secondary: darkPurple,
        surface: cream,
        background: cream,
        error: Color(0xFFB00020),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkText,
        onBackground: darkText,
      ),
      scaffoldBackgroundColor: cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: lavender,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: GoogleFonts.notoSansArabicTextTheme(
        ThemeData.light().textTheme,
      ).copyWith(
        headlineLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        headlineMedium: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          color: darkText,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          color: secondaryText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightLavender,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentPurple, width: 2),
        ),
        hintStyle: const TextStyle(color: secondaryText),
      ),
    );
  }

  // Dark theme (optional future extension)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      // Dark theme colors would go here
    );
  }
}

/// Custom gradient for special UI elements
class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE6E6FA), Color(0xFF7C6FAF)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C6FAF), Color(0xFF5A4A8F)],
  );
}
