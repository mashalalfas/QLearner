import 'package:flutter/material.dart';
import 'package:qlearner/core/theme/app_colors.dart';
import 'package:qlearner/core/theme/app_spacing.dart';

/// A custom seek bar (slider) with gold gradient fill and a gold dot indicator.
///
/// Features:
/// - Gold gradient fill (goldStart → goldEnd)
/// - Gold dot indicator with glow effect
/// - Customizable value and onChanged callback
class SeekBarGold extends StatefulWidget {
  final double value; // 0.0 to 1.0
  final ValueChanged<double>? onChanged;
  final double height;
  final double dotSize;

  const SeekBarGold({
    super.key,
    required this.value,
    this.onChanged,
    this.height = seekBarHeight,
    this.dotSize = seekBarDotSize,
  });

  @override
  State<SeekBarGold> createState() => _SeekBarGoldState();
}

class _SeekBarGoldState extends State<SeekBarGold> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant SeekBarGold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final dotPosition = _currentValue * (trackWidth - widget.dotSize);

        return SizedBox(
          height: widget.dotSize + 8,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Track background
              Container(
                width: double.infinity,
                height: widget.height,
                decoration: BoxDecoration(
                  color: AppColors.bgCardDark,
                  borderRadius: BorderRadius.circular(widget.height / 2),
                ),
              ),
              // Filled portion with gold gradient
              FractionallySizedBox(
                widthFactor: _currentValue,
                child: Container(
                  height: widget.height,
                  decoration: const BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
              // Draggable thumb (invisible full-width slider for interaction)
              if (widget.onChanged != null)
                Positioned.fill(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: widget.height + 20,
                      trackShape: const RectangularSliderTrackShape(),
                      thumbShape: SliderComponentShape.noThumb,
                      overlayShape: SliderComponentShape.noOverlay,
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                    ),
                    child: Slider(
                      value: _currentValue,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (val) {
                        setState(() => _currentValue = val);
                        widget.onChanged?.call(val);
                      },
                    ),
                  ),
                ),
              // Gold dot indicator
              Positioned(
                left: dotPosition,
                top: (widget.dotSize + 8 - widget.dotSize) / 2,
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: AppColors.goldEnd,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldStart.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
