import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Floating Gold Island Navigation
/// A premium circular FAB centered on a dark glass bottom bar
/// Features subtle breathing glow animation
class CenterIslandNav extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavItem> items;
  final ValueChanged<int> onTap;
  final double islandSize;
  final double barHeight;

  const CenterIslandNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.islandSize = 64,
    this.barHeight = 70,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassBottomBar(
      islandSize: islandSize,
      barHeight: barHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Bottom bar with left and right items
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: barHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Left item (Home)
                  _NavItem(
                    icon: items[0].icon,
                    label: items[0].label,
                    isActive: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  // Spacer for center island
                  SizedBox(width: islandSize + 20),
                  // Right item (Library)
                  _NavItem(
                    icon: items[2].icon,
                    label: items[2].label,
                    isActive: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                ],
              ),
            ),
          ),

          // Center floating island
          Positioned(
            bottom: barHeight - islandSize / 2,
            child: _FloatingIsland(
              icon: items[1].icon,
              isActive: currentIndex == 1,
              size: islandSize,
              onTap: () => onTap(1),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark glass bottom bar with gold accent
class _GlassBottomBar extends StatelessWidget {
  final double islandSize;
  final double barHeight;
  final Widget child;

  const _GlassBottomBar({
    required this.islandSize,
    required this.barHeight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: barHeight + 32,
          decoration: BoxDecoration(
            color: AppColors.bgCardDark.withValues(alpha: 0.85),
            border: const Border(
              top: BorderSide(
                color: AppColors.goldSoft,
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldStart.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Individual navigation item (for left/right positions)
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive
                  ? AppColors.goldStart
                  : AppColors.textGray,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppColors.goldStart
                    : AppColors.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating center island with subtle breathing glow animation
class _FloatingIsland extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final double size;
  final VoidCallback onTap;

  const _FloatingIsland({
    required this.icon,
    required this.isActive,
    required this.size,
    required this.onTap,
  });

  @override
  State<_FloatingIsland> createState() => _FloatingIslandState();
}

class _FloatingIslandState extends State<_FloatingIsland>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.35, end: 0.55).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isActive ? _scaleAnimation.value : 1.0,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldStart.withValues(
                    alpha: widget.isActive ? _glowAnimation.value : 0.35,
                  ),
                  blurRadius: widget.isActive ? 32 : 20,
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
                width: 4,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                customBorder: const CircleBorder(),
                child: Icon(
                  widget.icon,
                  size: widget.size * 0.42,
                  color: AppColors.bgBase,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Model class for bottom navigation items
class BottomNavItem {
  final IconData icon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.label,
  });
}
