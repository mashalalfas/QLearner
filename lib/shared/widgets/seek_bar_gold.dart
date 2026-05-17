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
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant SeekBarGold oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only sync from parent stream when NOT dragging
    if (!_isDragging && oldWidget.value != widget.value) {
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
          // Draggable thumb with gesture detection
          if (widget.onChanged != null)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: (_) => setState(() => _isDragging = true),
                onPanUpdate: (details) {
                  final box = context.findRenderObject() as RenderBox;
                  final localX = box.globalToLocal(details.globalPosition).dx;
                  // Track is centered horizontally
                  final trackWidth = box.size.width * 0.9;
                  final trackLeft = (box.size.width - trackWidth) / 2;
                  final relativeX = (localX - trackLeft).clamp(0.0, trackWidth);
                  final newValue = relativeX / trackWidth;
                  
                  setState(() {
                    _isDragging = true;
                    _currentValue = newValue;
                  });
                },
                onPanEnd: (details) {
                  widget.onChanged?.call(_currentValue);
                  setState(() => _isDragging = false);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Thumb glow
                    Container(
                      width: thumbRadius * 2 + 8,
                      height: thumbRadius * 2 + 8,
                      decoration: BoxDecoration(
                        color: AppColors.goldEnd.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Thumb
                    Container(
                      width: thumbRadius * 2,
                      height: thumbRadius * 2,
                      decoration: BoxDecoration(
                        color: AppColors.goldEnd,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.goldStart,
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
