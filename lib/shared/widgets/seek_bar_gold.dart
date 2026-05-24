import 'package:flutter/material.dart';
import 'package:qlearner/core/theme/app_colors.dart';

/// A custom seek bar (slider) with gold gradient fill and a gold glow thumb
/// indicator.
///
/// Built with standard Flutter Slider + SliderTheme to avoid release-build
/// rendering artifacts from custom-painted alternatives.
class SeekBarGold extends StatefulWidget {
  final double value; // 0.0 to 1.0
  final ValueChanged<double>? onChanged;

  const SeekBarGold({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  State<SeekBarGold> createState() => _SeekBarGoldState();
}

class _SeekBarGoldState extends State<SeekBarGold> {
  late double _currentValue;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant SeekBarGold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging && oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    const double trackHeight = 6.0;
    const double thumbRadius = 14.0;
    const double glowRadius = 22.0;

    return SizedBox(
      height: glowRadius * 2 + 8,
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: trackHeight,
          activeTrackColor: AppColors.goldStart,
          inactiveTrackColor: AppColors.bgCardDark,
          thumbColor: AppColors.goldEnd,
          thumbShape: _GoldGlowThumbShape(
            thumbRadius: thumbRadius,
            glowRadius: glowRadius,
          ),
          overlayShape: SliderComponentShape.noOverlay,
          trackShape: const RoundedRectSliderTrackShape(),
        ),
        child: Slider(
          value: _currentValue.clamp(0.0, 1.0),
          onChanged: widget.onChanged == null
              ? null
              : (val) {
                  setState(() => _currentValue = val);
                },
          onChangeEnd: widget.onChanged,
          onChangeStart: (_) {
            _isDragging = true;
          },
        ),
      ),
    );
  }
}

/// Custom thumb shape with a gold glow halo around the thumb.
class _GoldGlowThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final double glowRadius;

  const _GoldGlowThumbShape({
    required this.thumbRadius,
    required this.glowRadius,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(glowRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Outer glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.goldStart.withValues(alpha: 0.4),
          AppColors.goldStart.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: glowRadius),
      );
    canvas.drawCircle(center, glowRadius, glowPaint);

    // Thumb body
    final thumbPaint = Paint()
      ..shader = AppColors.goldGradient.createShader(
        Rect.fromCircle(center: center, radius: thumbRadius),
      );
    canvas.drawCircle(center, thumbRadius, thumbPaint);

    // Inner highlight
    final highlightPaint = Paint()
      ..color = AppColors.goldEnd.withValues(alpha: 0.5);
    canvas.drawCircle(center, thumbRadius * 0.4, highlightPaint);
  }
}
