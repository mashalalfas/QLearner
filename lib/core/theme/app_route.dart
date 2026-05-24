import 'package:flutter/material.dart';
import 'package:qlearner/core/theme/app_colors.dart';

/// Custom page route with a gold curtain transition effect.
///
/// Slides the new page up while revealing it through a gold-tinted
/// gradient overlay, creating a premium "unveiling" feel.
class GoldCurtainRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  GoldCurtainRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return Stack(
              children: [
                // Slide-up page
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: const Interval(0.2, 1.0),
                      ),
                    ),
                    child: child,
                  ),
                ),
                // Gold curtain overlay that fades out
                Positioned.fill(
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.6, end: 0.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: const Interval(0.0, 0.5),
                      ),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.goldStart,
                            AppColors.goldEnd,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
}
