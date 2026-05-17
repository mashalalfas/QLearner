import 'package:flutter/material.dart';
import 'package:qlearner/core/theme/app_colors.dart';

/// A custom seek bar (slider) with gold gradient fill and a gold thumb
/// indicator.
///
/// Features:
/// - Gold gradient fill (goldStart → goldEnd)
/// - Gold thumb indicator with subtle glow
/// - Customizable value and onChanged callback
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
    const double trackHeight = 6.0;
    const double thumbRadius = 12.0;

    return SizedBox(
      height: thumbRadius * 2 + 12, // 36px — ample room for 24px thumb
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Track background
          Center(
            child: Container(
              width: double.infinity,
              height: trackHeight,
              decoration: BoxDecoration(
                color: AppColors.bgCardDark,
                borderRadius: BorderRadius.circular(trackHeight / 2),
              ),
            ),
          ),
          // Filled portion with gold gradient
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: _currentValue,
              child: Container(
                height: trackHeight,
                decoration: const BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ),
          ),
          // Draggable thumb (Slider handles gestures + visual gold thumb)
          if (widget.onChanged != null)
            SliderTheme(
              data: SliderThemeData(
                trackHeight: trackHeight,
                trackShape: const RectangularSliderTrackShape(),
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: thumbRadius,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: thumbRadius + 4,
                ),
                thumbColor: AppColors.goldEnd,
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
        ],
      ),
    );
  }
}
