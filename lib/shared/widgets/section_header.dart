import 'package:flutter/material.dart';
import 'package:quranaudio/core/theme/app_colors.dart';
import 'package:quranaudio/core/theme/app_typography.dart';

/// A gold text section title with an underline decoration.
///
/// Features:
/// - Gold text color (goldStart)
/// - Gold underline below (gradient, 2px height)
/// - Uses sectionHeader text style
class SectionHeader extends StatelessWidget {
  final String title;
  final double underlineWidth;
  final double underlineHeight;
  final double spacing;

  const SectionHeader({
    super.key,
    required this.title,
    this.underlineWidth = double.infinity,
    this.underlineHeight = 2,
    this.spacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: sectionHeader,
        ),
        SizedBox(
          height: spacing,
        ),
        Container(
          width: underlineWidth,
          height: underlineHeight,
          decoration: const BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.all(Radius.circular(1)),
          ),
        ),
      ],
    );
  }
}
