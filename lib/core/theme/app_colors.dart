import 'package:flutter/material.dart';

/// Dignity theme color palette — premium black & gold
class AppColors {
  AppColors._();

  // Background Colors
  static const Color bgBase = Color(0xFF0A0A0A);
  static const Color bgPhone = Color(0xFF0D0D0D);
  static const Color bgCardDark = Color(0xFF1A1A1A);
  static const Color bgCardInner = Color(0xFF141414);

  // Gold Colors
  static const Color goldStart = Color(0xFFC9A84C);
  static const Color goldEnd = Color(0xFFE8D48B);
  static const Color goldSoft = Color(0x33C9A84C);
  static const Color goldMuted = Color(0x99C9A84C);
  static const Color goldHover = Color(0x1FC9A84C);

  // Text Colors
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF888888);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldStart, goldEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [bgCardDark, bgCardInner],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient bottomNavGradient = LinearGradient(
    colors: [Color(0xCC0D0D0D), Color(0xF20D0D0D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
