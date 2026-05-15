import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/cotton_cloud_theme.dart';

/// Floating Mint Island Navigation
/// A glassmorphic circular FAB centered on a glass bottom bar
/// Features breathing glow animation and organic hover effects
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

/// Glassmorphic bottom bar with backdrop blur
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
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: barHeight + 32,
          decoration: BoxDecoration(
            color: CottonCloudTheme.glassWhite.withOpacity(0.6),
            border: const Border(
              top: BorderSide(
                color: CottonCloudTheme.hairlineBorder,
                width: 0.5,
              ),
            ),
            boxShadow: CottonCloudTheme.glassShadow,
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
                  ? CottonCloudTheme.accent
                  : CottonCloudTheme.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? CottonCloudTheme.accent
                    : CottonCloudTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating center island with breathing glow animation
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
      duration: CottonCloudTheme.breathingDuration,
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: CottonCloudTheme.calmEase,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.45, end: 0.65).animate(
      CurvedAnimation(
        parent: _controller,
        curve: CottonCloudTheme.calmEase,
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
              gradient: CottonCloudTheme.mintGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CottonCloudTheme.mint.withOpacity(
                    widget.isActive ? _glowAnimation.value : 0.45,
                  ),
                  blurRadius: widget.isActive ? 36 : 24,
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.9),
                width: 5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                customBorder: const CircleBorder(),
                child: Icon(
                  widget.icon,
                  size: widget.size * 0.45,
                  color: Colors.white,
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
