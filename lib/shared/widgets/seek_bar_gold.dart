import 'package:flutter/material.dart';
import 'package:qlearner/core/theme/app_colors.dart';

/// A premium gold seek bar using SliderTheme for a polished look.
///
/// Features:
/// - Gold active track and gold thumb indicator
/// - Clean drag handling via the underlying Slider widget
/// - Fully themed for the Dignity design language
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

    return SliderTheme(
      data: const SliderThemeData(
        trackHeight: trackHeight,
        trackShape: RoundedRectSliderTrackShape(),
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: thumbRadius,
        ),
        overlayShape: RoundSliderOverlayShape(
          overlayRadius: thumbRadius + 6,
        ),
        activeTrackColor: AppColors.goldEnd,
        inactiveTrackColor: AppColors.bgCardDark,
        thumbColor: AppColors.goldEnd,
        overlayColor: AppColors.goldSoft,
        disabledActiveTrackColor: AppColors.goldMuted,
        disabledInactiveTrackColor: AppColors.bgCardDark,
        disabledThumbColor: AppColors.goldMuted,
      ),
      child: Slider(
        value: _currentValue,
        min: 0.0,
        max: 1.0,
        onChanged: widget.onChanged != null
            ? (val) {
                setState(() => _currentValue = val);
                widget.onChanged?.call(val);
              }
            : null,
      ),
    );
  }
}
