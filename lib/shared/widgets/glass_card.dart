import 'dart:ui';
import 'package:flutter/material.dart';
import 'gold_gradient_border.dart';
import 'package:qlearner/core/theme/app_colors.dart';
import 'package:qlearner/core/theme/app_spacing.dart';

/// A glassmorphism card with dark gradient background, gold border,
/// and backdrop blur effect.
///
/// Features:
/// - Dark gradient (bgCardDark → bgCardInner)
/// - 0.5px gold border at 19% opacity
/// - 10px backdrop blur
/// - Configurable border radius
/// - Wraps any child content
class GlassCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.radius = cardBorderRadius,
    this.borderWidth = goldBorderWidth,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: padding ??
            const EdgeInsets.symmetric(
              vertical: cardPaddingV,
              horizontal: cardPaddingH,
            ),
        child: child,
      ),
    );

    // Apply gold border using CustomPaint
    card = GoldBordered(
      radius: radius,
      strokeWidth: borderWidth,
      child: card,
    );

    // Apply backdrop blur
    card = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: card,
      ),
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: onTap != null
                ? [
                    BoxShadow(
                      color: AppColors.goldStart.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: card,
        ),
      );
    }

    return card;
  }
}
