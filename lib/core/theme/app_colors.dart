import 'package:flutter/material.dart';

/// Dignity Theme — Color constants
///
/// Palette: Premium black & gold with glassmorphism accents.
/// Derived from: design_templates/template-blackgold-dignity.html
class AppColors {
  // ------------------------------------------------------------------------
  // Backgrounds
  // ------------------------------------------------------------------------
  static const Color bgBase = Color(0xFF0A0A0A); // Page background
  static const Color bgPhone = Color(0xFF0D0D0D); // Phone screen
  static const Color bgCardDark = Color(0xFF1A1A1A); // Card background (outer)
  static const Color bgCardInner = Color(0xFF141414); // Card background (inner)

  // ------------------------------------------------------------------------
  // Gold palette
  // ------------------------------------------------------------------------
  static const Color goldStart = Color(0xFFC9A84C); // Gold gradient start
  static const Color goldEnd = Color(0xFFE8D48B); // Gold gradient end
  static const Color goldSoft = Color(0x33C9A84C); // 19% opacity gold border
  static const Color goldMuted = Color(0x99C9A84C); // 60% opacity gold text
  static const Color goldHover = Color(0x1FC9A84C); // 12% opacity gold shadow

  // ------------------------------------------------------------------------
  // Text
  // ------------------------------------------------------------------------
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF888888);

  // ------------------------------------------------------------------------
  // Gradients
  // ------------------------------------------------------------------------
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

  // ----------------------------------------------------------------------
  // Lottie animation fill
  // ----------------------------------------------------------------------
  static const Color lottieFill = Color(0x00C9A84C); // Transparent gold — inherits stroke
  static const Color lottieGold = Color(0xFFC9A84C); // Primary gold stroke
  static const Color lottieOpacityHigh = Color(0x80C9A84C); // 50% gold for subtle elements
  static const Color lottieOpacityLow = Color(0x33C9A84C); // 20% gold for faint accents
  static const Color lottieComplete = Color(0xFF4CAF50); // Subtle green for completion accent
  static const Color lottieCompletionGold = Color(0xFFE8D48B); // Light gold for completed glow

  // Private constructor — no instances
  AppColors._();
}
