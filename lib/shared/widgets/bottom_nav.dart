import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qlearner/core/theme/app_colors.dart';
import 'package:qlearner/core/theme/app_spacing.dart';
import 'package:qlearner/core/theme/app_typography.dart';

/// A 4-tab bottom navigation bar with gold underline indicator for active tab.
///
/// Features:
/// - 4 tabs: Home, Library, Reciters, Settings
/// - Active: white text + gold underline bar (40px wide, 2px tall)
/// - Inactive: gray text
/// - Dark gradient background with 20px blur
/// - Height: 80px, bottom padding: 24px
class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final List<BottomNavItem> items;

  const BottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
    required this.items,
  }) : assert(items.length == 4, 'BottomNav requires exactly 4 items');

  @override
  Widget build(BuildContext context) {
    return Container(
      height: bottomNavHeight,
      decoration: const BoxDecoration(
        gradient: AppColors.bottomNavGradient,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.bottomNavGradient,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (index) {
                final item = items[index];
                final isActive = index == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: onTap != null ? () => onTap!(index) : null,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          color: isActive
                              ? AppColors.textWhite
                              : AppColors.textGray,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: navItem.copyWith(
                            color: isActive
                                ? AppColors.textWhite
                                : AppColors.textGray,
                          ),
                        ),
                        if (isActive)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 40,
                            height: 2,
                            decoration: const BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(1)),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

/// Data class for bottom navigation items.
class BottomNavItem {
  final IconData icon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.label,
  });
}
