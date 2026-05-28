import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:qlearner/core/theme/app_spacing.dart';
import 'package:qlearner/src/core/services/audio_player_service.dart';

/// PlayerLottie — renders a Lottie animation mapped to [PlayerStateEnum].
///
/// Each state maps to a dignity-themed (black & gold) Lottie asset:
/// | State       | Animation                 |
/// |-------------|---------------------------|
/// | `playing`   | Expanding gold ring pulse |
/// | `paused`    | Two gold bars (breathing) |
/// | `buffering` | Rotating gold arc spinner |
/// | `stopped`   | Static gold rounded square|
/// | `completed` | Draw-in gold checkmark    |
///
/// Default dimensions are pulled from [lottiePlayerSize] (160×160).
class PlayerLottie extends StatelessWidget {
  /// The player state to visualise.
  final PlayerStateEnum state;

  /// Width of the animation. Defaults to [lottiePlayerSize].
  final double? width;

  /// Height of the animation. Defaults to [lottiePlayerSize].
  final double? height;

  /// Box fit for the Lottie composition. Defaults to [BoxFit.contain].
  final BoxFit fit;

  /// Whether the animation loops. Defaults to true for most states.
  ///
  /// Note: [PlayerStateEnum.stopped] and [PlayerStateEnum.completed]
  /// are static or one-shot animations and will not repeat regardless.
  final bool repeat;

  /// Whether the animation auto-plays. Defaults to true.
  final bool animate;

  const PlayerLottie({
    super.key,
    required this.state,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.animate = true,
  });

  // ---------------------------------------------------------------------------
  // Asset path resolution
  // ---------------------------------------------------------------------------

  /// Maps [PlayerStateEnum] to the dignity-themed Lottie JSON asset path.
  static String _assetPathForState(PlayerStateEnum state) {
    switch (state) {
      case PlayerStateEnum.playing:
        return 'assets/lottie/player_playing.json';
      case PlayerStateEnum.paused:
        return 'assets/lottie/player_paused.json';
      case PlayerStateEnum.buffering:
        return 'assets/lottie/player_buffering.json';
      case PlayerStateEnum.stopped:
        return 'assets/lottie/player_stopped.json';
      case PlayerStateEnum.completed:
        return 'assets/lottie/player_completed.json';
    }
  }

  // ---------------------------------------------------------------------------
  // Animation behaviour per state
  // ---------------------------------------------------------------------------

  /// Whether the Lottie composition should loop for this state.
  static bool _shouldRepeat(PlayerStateEnum state) {
    switch (state) {
      case PlayerStateEnum.playing:
      case PlayerStateEnum.paused:
      case PlayerStateEnum.buffering:
        return true;
      case PlayerStateEnum.stopped:
      case PlayerStateEnum.completed:
        return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final effectiveRepeat = repeat && _shouldRepeat(state);
    final effectiveWidth = width ?? lottiePlayerSize;
    final effectiveHeight = height ?? lottiePlayerSize;

    return Lottie.asset(
      _assetPathForState(state),
      width: effectiveWidth,
      height: effectiveHeight,
      fit: fit,
      repeat: effectiveRepeat,
      animate: animate,
      // Cache rasterized frames for smooth gold-stroke rendering
      renderCache: RenderCache.raster,
    );
  }
}
