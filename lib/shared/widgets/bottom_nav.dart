import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qlearner/core/theme/app_colors.dart';
import 'package:qlearner/core/theme/app_spacing.dart';
import 'package:qlearner/core/theme/app_typography.dart';

/// A 4-tab bottom navigation bar with pill-shaped active indicator
/// and spring animation for the Dignity theme.
///
/// Features:
/// - 4 tabs: Home, Library, Reciters, Settings
/// - Active: white text + animated pill-shaped gold highlight
/// - Inactive: gray text
/// - Dark gradient background with 20px blur
/// - Height: 80px, bottom padding: 24px
class BottomNav extends StatefulWidget {
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
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnim;

  @override
  void initState() {
    super.initState();
    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _indicatorAnim = CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.elasticOut,
    );
    _indicatorController.forward();
  }

  @override
  void didUpdateWidget(covariant BottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _indicatorController.reset();
      _indicatorController.forward();
    }
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }

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
                final item = widget.items[index];
                final isActive = index == widget.currentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: widget.onTap != null
                        ? () => widget.onTap!(index)
                        : null,
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
                        const SizedBox(height: 4),
                        // Pill indicator
                        AnimatedBuilder(
                          animation: _indicatorAnim,
                          builder: (context, _) {
                            return Container(
                              width: isActive ? 40 * _indicatorAnim.value : 0,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: isActive
                                    ? AppColors.goldGradient
                                    : null,
                                borderRadius: BorderRadius.circular(1.5),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: AppColors.goldStart
                                              .withValues(alpha: 0.4 * _indicatorAnim.value),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                            );
                          },
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
