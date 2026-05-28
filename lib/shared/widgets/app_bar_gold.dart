import 'package:flutter/material.dart';
import 'package:quranaudio/core/theme/app_colors.dart';
import 'package:quranaudio/core/theme/app_typography.dart';

/// An AppBar with a centered title and a gold underline decoration.
///
/// Features:
/// - Centered title with appbarTitle style
/// - 2px gold gradient underline, 60px wide
/// - Positioned below title
class AppBarGold extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double underlineWidth;
  final double underlineHeight;
  final double underlineBottomOffset;
  final List<Widget>? actions;

  const AppBarGold({
    super.key,
    required this.title,
    this.underlineWidth = 60,
    this.underlineHeight = 2,
    this.underlineBottomOffset = -8,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Text(
              title,
              style: appbarTitle,
            ),
            Positioned(
              bottom: underlineBottomOffset,
              child: Container(
                width: underlineWidth,
                height: underlineHeight,
                decoration: const BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.all(Radius.circular(1)),
                ),
              ),
            ),
          ],
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: actions,
    );
  }
}
