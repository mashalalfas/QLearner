import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cotton Cloud Theme 2026 — Glassmorphism 2.0
/// Soft, organic, breathable UI with frosted glass effects
class CottonCloudTheme {
  // ===== Cotton Cloud Palette =====
  static const Color lavender = Color(0xFFC4B5D6);
  static const Color lavenderDark = Color(0xFFA899C7);
  static const Color cream = Color(0xFFFFFDF5);
  static const Color creamDark = Color(0xFFF5F0E4);
  static const Color mint = Color(0xFFB8E4D1);
  static const Color mintDark = Color(0xFF95D4B0);
  static const Color pink = Color(0xFFFFD6E0);
  static const Color pinkDark = Color(0xFFFFBDCB);
  static const Color accent = Color(0xFF8B7BB8);
  static const Color accentDark = Color(0xFF7C6FAF);

  // Neutrals
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // Text colors
  static const Color text = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF5A5A5A);
  static const Color textMuted = Color(0xFF9CA3AF);

  // ===== Glass Colors =====
  // Glass surfaces: 60-70% opacity white with subtle tint
  static const Color glassWhite = Color(0x99FFFFFF); // 60% opacity
  static const Color glassCream = Color(0x99FFFDF5); // 60% opacity cream
  static const Color glassLavender = Color(0x99C4B5D6); // 60% opacity lavender
  static const Color glassMint = Color(0x99B8E4D1); // 60% opacity mint

  // Dark glass (for dark theme)
  static const Color glassDark = Color(0x99373745); // 60% opacity dark gray
  static const Color glassDarkSurface = Color(0x992D2D3A); // 60% opacity surface

  // Hairline border color (subtle)
  static const Color hairlineBorder = Color(0x40FFFFFF); // 25% opacity white
  static const Color hairlineBorderDark = Color(0x20000000); // 12% opacity black

  // ===== Shadows =====
  static const List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Color(0x8C7B58C0), // 0x8C = ~55% opacity of accent
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> glassGlow = [
    BoxShadow(
      color: Color(0x408B7BB8), // 25% opacity accent for glow
      blurRadius: 40,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> floatShadow = [
    BoxShadow(
      color: Color(0x2E8B7BB8), // ~18% opacity
      blurRadius: 12,
      spreadRadius: 0,
      offset: Offset(0, 12),
    ),
  ];

  // ===== Gradients =====
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE6E6FA), Color(0xFF7C6FAF)],
  );

  static const LinearGradient mintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB8E4D1), Color(0xFF95D4B0)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B7BB8), Color(0xFF7C6FAF)],
  );

  // Mesh gradient for background
  static const List<Color> meshGradientColors = [
    Color(0x40C4B5D6), // 25% lavender
    Color(0x33B8E4D1), // 20% mint
    Color(0x26FFD6E0), // 15% pink
  ];

  // ===== Animation Curves =====
  static const Curve slowEase = Cubic(0.25, 0.46, 0.45, 0.94);
  static const Curve calmEase = Cubic(0.4, 0.0, 0.2, 1);
  static const Curve organicEase = Cubic(0.34, 1.56, 0.64, 1);

  // ===== Durations =====
  static const Duration slowDuration = Duration(seconds: 3);
  static const Duration mediumDuration = Duration(seconds: 5);
  static const Duration organicDuration = Duration(seconds: 10);
  static const Duration breathingDuration = Duration(seconds: 6);

  // ===== Glass Surface Definitions =====
  static BoxDecoration glassDecoration({
    Color? color,
    double borderRadius = 24,
    List<BoxShadow>? shadows,
    Border? border,
  }) {
    return BoxDecoration(
      color: color ?? glassWhite,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: shadows ?? glassShadow,
      border: border ??
          Border.all(
            color: hairlineBorder,
            width: 0.5,
          ),
    );
  }

  static BoxDecoration glassCardDecoration({
    Color? color,
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      color: color ?? glassWhite,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: glassShadow,
      border: Border.all(
        color: hairlineBorder,
        width: 0.5,
      ),
    );
  }

  static BoxDecoration glassNavIslandDecoration() {
    return BoxDecoration(
      gradient: mintGradient,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: mint.withValues(alpha: 0.45),
          blurRadius: 24,
          spreadRadius: 0,
        ),
      ],
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.9),
        width: 5,
      ),
    );
  }

  // ===== Theme Data Builders =====

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: accentDark,
        surface: cream,
        error: Color(0xFFB00020),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: text,
      ),
      scaffoldBackgroundColor: cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: lavender,
        foregroundColor: text,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Google Sans',
        ),
      ),
      cardTheme: CardThemeData(
        color: glassWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Google Sans',
          ),
        ),
      ),
      textTheme: GoogleFonts.notoSansArabicTextTheme(
        ThemeData.light().textTheme,
      ).copyWith(
        headlineLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: text,
          fontFamily: 'Google Sans',
        ),
        headlineMedium: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: text,
          fontFamily: 'Google Sans',
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          color: text,
          fontFamily: 'Google Sans',
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          color: textSecondary,
          fontFamily: 'Google Sans',
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassCream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        hintStyle: const TextStyle(color: textSecondary),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: mint,
        secondary: lavender,
        surface: Color(0xFF2D2D3A),
        error: Color(0xFFCF6679),
        onPrimary: text,
        onSecondary: text,
        onSurface: cream,
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2D2D3A),
        foregroundColor: cream,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: cream,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Google Sans',
        ),
      ),
      cardTheme: CardThemeData(
        color: glassDarkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mint,
          foregroundColor: text,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Google Sans',
          ),
        ),
      ),
      textTheme: GoogleFonts.notoSansArabicTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        headlineLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: cream,
          fontFamily: 'Google Sans',
        ),
        headlineMedium: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: cream,
          fontFamily: 'Google Sans',
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          color: cream,
          fontFamily: 'Google Sans',
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          color: lavender,
          fontFamily: 'Google Sans',
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: mint, width: 2),
        ),
        hintStyle: const TextStyle(color: textSecondary),
      ),
    );
  }
}

/// Extension for Glass Effects
extension GlassEffects on Widget {
  Widget glass({
    double borderRadius = 20,
    Color? color,
    List<BoxShadow>? shadows,
    Border? border,
  }) {
    return Container(
      decoration: CottonCloudTheme.glassDecoration(
        color: color,
        borderRadius: borderRadius,
        shadows: shadows,
        border: border,
      ),
      child: this,
    );
  }

  Widget glassCard({double borderRadius = 20}) {
    return Container(
      decoration: CottonCloudTheme.glassCardDecoration(
        borderRadius: borderRadius,
      ),
      child: this,
    );
  }
}
