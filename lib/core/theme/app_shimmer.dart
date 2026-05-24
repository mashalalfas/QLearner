import 'package:flutter/material.dart';
import 'package:qlearner/core/theme/app_colors.dart';

/// Gold shimmer skeleton loading effect for the Dignity theme.
///
/// Provides a reusable shimmer widget that animates a gold highlight
/// across a dark placeholder, used instead of CircularProgressIndicator.
class GoldShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const GoldShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<GoldShimmer> createState() => _GoldShimmerState();
}

class _GoldShimmerState extends State<GoldShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
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
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(-0.5 + 2.0 * _controller.value, 0),
              colors: const [
                AppColors.bgCardDark,
                AppColors.goldSoft,
                AppColors.bgCardDark,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// A shimmer placeholder that mimics a surah card layout.
class GoldShimmerCard extends StatelessWidget {
  const GoldShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCardDark,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GoldShimmer(width: 24, height: 12, borderRadius: 4),
          const Spacer(),
          const GoldShimmer(width: 60, height: 20, borderRadius: 6),
          const Spacer(),
          const GoldShimmer(width: 80, height: 10, borderRadius: 4),
          const SizedBox(height: 4),
          const GoldShimmer(width: 50, height: 8, borderRadius: 4),
        ],
      ),
    );
  }
}

/// A row shimmer placeholder for list items.
class GoldShimmerRow extends StatelessWidget {
  const GoldShimmerRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const GoldShimmer(width: 40, height: 12, borderRadius: 4),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GoldShimmer(width: double.infinity, height: 14, borderRadius: 4),
                const SizedBox(height: 6),
                const GoldShimmer(width: 100, height: 10, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
