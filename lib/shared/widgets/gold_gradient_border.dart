import 'package:flutter/material.dart';
import 'package:qlearner/core/theme/app_colors.dart';

/// A CustomPainter that paints a gold gradient border with configurable radius.
///
/// Usage:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: BorderRadius.circular(radius),
///   ),
///   child: CustomPaint(
///     painter: GoldGradientBorder(
///       radius: radius,
///       strokeWidth: 1.0,
///     ),
///     child: child,
///   ),
/// )
/// ```
class GoldGradientBorder extends CustomPainter {
  final double radius;
  final double strokeWidth;

  const GoldGradientBorder({
    this.radius = 18,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const gradient = LinearGradient(
      colors: [AppColors.goldStart, AppColors.goldEnd, AppColors.goldStart],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant GoldGradientBorder oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Extension widget that wraps any child with a gold gradient border.
class GoldBordered extends StatelessWidget {
  final Widget child;
  final double radius;
  final double strokeWidth;

  const GoldBordered({
    super.key,
    required this.child,
    this.radius = 18,
    this.strokeWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GoldGradientBorder(radius: radius, strokeWidth: strokeWidth),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}
