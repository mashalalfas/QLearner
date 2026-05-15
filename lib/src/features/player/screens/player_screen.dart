import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlearner/core/theme/app_colors.dart';
import 'package:qlearner/core/theme/app_typography.dart';
import 'package:qlearner/core/theme/app_spacing.dart';
import 'package:qlearner/shared/widgets/seek_bar_gold.dart';
import 'package:qlearner/src/core/providers/service_providers.dart';
import 'package:qlearner/src/features/library/providers/library_providers.dart';
import 'package:qlearner/src/core/services/audio_player_service.dart';
import 'package:qlearner/src/features/player/providers/player_providers.dart';
import 'package:qlearner/src/features/player/providers/current_surah_provider.dart';
import 'package:qlearner/src/data/models/bookmark.dart';

/// Player screen — Dignity theme: premium black & gold with animated circle
///
/// This widget is a pure consumer of [currentSurahProvider].  It carries NO
/// local surah state — no `_overrideTitle`, no `_overrideSubtitle`.  Any change
/// to the current surah flows from the provider and triggers a rebuild automatically.
class PlayerScreen extends ConsumerWidget {
  /// The surah ID used for the initial load.  All subsequent navigation
  /// (Prev / Next) comes from [currentSurahProvider].
  final String surahId;

  const PlayerScreen({
    super.key,
    required this.surahId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the single source of truth for the currently playing surah
    final currentSurah = ref.watch(currentSurahProvider);
    final currentSurahNotifier = ref.read(currentSurahProvider.notifier);
    final isLoading = currentSurahNotifier.isLoading;

    final playerStateAsync = ref.watch(playerStateProvider);
    final positionAsync = ref.watch(positionProvider);

    // Resolve display values from the provider — no local override state
    final displayTitle = currentSurah?.englishName ?? '';
    final displayArabic = currentSurah?.name ?? '';
    final displayNumber = currentSurah?.surahId ?? '';

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Color(0x26C9A84C),
                  AppColors.bgBase,
                ],
                stops: [0.0, 0.7],
              ),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    _PlayerSurahNumber(surahNumber: displayNumber),

                    const Spacer(flex: 2),

                    _PlayerCircle(arabicName: displayArabic),

                    const Spacer(flex: 2),

                    Text(
                      displayTitle,
                      style: playerEnglish.copyWith(
                        color: AppColors.textWhite,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 32),

                    // Controls row: Prev | Play/Pause | Next
                    _PlayerControls(
                      playerStateAsync: playerStateAsync,
                      onPrev: currentSurahNotifier.canGoPrev
                          ? () async {
                              await currentSurahNotifier.playPrevious();
                            }
                          : null,
                      onPlay: () async {
                        final state = playerStateAsync.value;
                        if (state?.isPlaying == true) {
                          await ref.read(audioPlayerProvider).pause();
                        } else {
                          await ref.read(audioPlayerProvider).resume();
                        }
                      },
                      onNext: currentSurahNotifier.canGoNext
                          ? () async {
                              await currentSurahNotifier.playNext();
                            }
                          : null,
                    ),

                    const SizedBox(height: 24),

                    _PlayerSeekBar(
                      playerStateAsync: playerStateAsync,
                      positionAsync: positionAsync,
                      onSeek: (positionMs) {
                        ref.read(audioPlayerProvider).seek(positionMs);
                      },
                    ),

                    const SizedBox(height: 16),

                    _PlayerMeta(
                      playerStateAsync: playerStateAsync,
                      positionAsync: positionAsync,
                      onSave: () async {
                        final positionMs = positionAsync.value ?? 0;
                        final bookmark = Bookmark.create(
                          surahId: displayNumber,
                          verseId: 1,
                          positionMs: positionMs,
                        );
                        final messenger = ScaffoldMessenger.of(context);
                        final bookmarkService = ref.read(bookmarkServiceProvider);
                        await bookmarkService.addBookmark(bookmark);
                        ref.invalidate(bookmarksProvider);
                        if (context.mounted) {
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Bookmark saved')),
                          );
                        }
                      },
                    ),

                    const Spacer(flex: 3),
                  ],
                ),
                if (isLoading) const _LoadingOverlay(),
              ],
            ),
          ),
        ),
    );
  }
}

/// Surah number at top: 52px, gold gradient text with ShaderMask
class _PlayerSurahNumber extends StatelessWidget {
  final String surahNumber;

  const _PlayerSurahNumber({required this.surahNumber});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ShaderMask(
        shaderCallback: (bounds) => AppColors.goldGradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        ),
        child: Text(
          surahNumber,
          style: playerSurahNumber.copyWith(
            color: AppColors.textWhite,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Center circle: 200x200, 2px gold border, animated glow pulse.
/// Arabic name comes from the [currentSurahProvider] watch in the parent.
class _PlayerCircle extends StatelessWidget {
  final String arabicName;

  const _PlayerCircle({required this.arabicName});

  @override
  Widget build(BuildContext context) {
    return _AnimatedGlowCircle(arabicName: arabicName);
  }
}

/// Internally animated sub-widget so `PlayerScreen` itself does not need
/// a `State` subclass just for the glow pulse.
class _AnimatedGlowCircle extends StatefulWidget {
  final String arabicName;

  const _AnimatedGlowCircle({required this.arabicName});

  @override
  State<_AnimatedGlowCircle> createState() => _AnimatedGlowCircleState();
}

class _AnimatedGlowCircleState extends State<_AnimatedGlowCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        // Glow blur: 0 -> 12 -> 0 over 3s cycle
        final glowBlur = (_glowController.value < 0.5)
            ? _glowController.value * 2 * 12
            : (1 - _glowController.value) * 2 * 12;

        return Container(
          width: playerCircleSize,
          height: playerCircleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.goldGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.goldStart.withValues(alpha: 0.6),
                blurRadius: glowBlur,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgCardInner,
              border: Border.all(
                color: AppColors.goldStart,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                widget.arabicName,
                style: playerArabic.copyWith(
                  color: AppColors.textWhite,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Controls row: text buttons only ("|< Prev" | "Play/Pause" | "Next |>")
/// onPrev / onNext are nullable — null means the button is disabled.
class _PlayerControls extends StatelessWidget {
  final AsyncValue<PlayerState> playerStateAsync;
  final VoidCallback? onPrev;
  final VoidCallback onPlay;
  final VoidCallback? onNext;

  const _PlayerControls({
    required this.playerStateAsync,
    this.onPrev,
    required this.onPlay,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Prev button — disabled when onPrev is null (first surah)
        TextButton(
          onPressed: onPrev,
          style: TextButton.styleFrom(
            foregroundColor: onPrev == null
                ? AppColors.goldMuted.withValues(alpha: 0.35)
                : AppColors.goldMuted,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: const Text('|< Prev'),
        ),

        const SizedBox(width: 32),

        // Play/Pause button (larger, gold)
        playerStateAsync.when(
          data: (state) {
            return TextButton(
              onPressed: onPlay,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.goldStart,
                textStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(state.isPlaying ? 'Pause' : 'Play'),
            );
          },
          loading: () => const Text(
            '▶',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.goldStart,
            ),
          ),
          error: (_, __) => TextButton(
            onPressed: onPlay,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.goldMuted,
            ),
            child: const Text('Play'),
          ),
        ),

        const SizedBox(width: 32),

        // Next button — disabled when onNext is null (last surah)
        TextButton(
          onPressed: onNext,
          style: TextButton.styleFrom(
            foregroundColor: onNext == null
                ? AppColors.goldMuted.withValues(alpha: 0.35)
                : AppColors.goldMuted,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: const Text('Next |>'),
        ),
      ],
    );
  }
}

/// Seek bar wrapper that provides time labels and gold styling
class _PlayerSeekBar extends ConsumerWidget {
  final AsyncValue<PlayerState> playerStateAsync;
  final AsyncValue<int?> positionAsync;
  final ValueChanged<int> onSeek;

  const _PlayerSeekBar({
    required this.playerStateAsync,
    required this.positionAsync,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          SeekBarGold(
            value: _calculateProgress(ref),
            onChanged: (val) {
              final duration = _getDurationMs(ref);
              if (duration != null && duration > 0) {
                final seekPos = (val * duration).round();
                onSeek(seekPos);
              }
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_getPositionMs(ref)),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.goldMuted,
                  fontFamily: fontBody,
                ),
              ),
              Text(
                _formatDuration(_getDurationMs(ref) ?? 0),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.goldMuted,
                  fontFamily: fontBody,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateProgress(WidgetRef ref) {
    final position = _getPositionMs(ref);
    final duration = _getDurationMs(ref);
    if (duration == null || duration == 0) return 0.0;
    return position / duration;
  }

  int _getPositionMs(WidgetRef ref) {
    return positionAsync.value ??
        (playerStateAsync.value?.positionMs ?? 0);
  }

  int? _getDurationMs(WidgetRef ref) {
    return playerStateAsync.value?.durationMs;
  }

  String _formatDuration(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

/// Bottom meta row: Save + current time (muted gold, small)
class _PlayerMeta extends StatelessWidget {
  final AsyncValue<PlayerState> playerStateAsync;
  final AsyncValue<int?> positionAsync;
  final VoidCallback onSave;

  const _PlayerMeta({
    required this.playerStateAsync,
    required this.positionAsync,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Save button
          TextButton(
            onPressed: onSave,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.goldMuted,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: const Text('Save'),
          ),

          // Current time (live)
          Text(
            _formatDuration(_getPositionMs()),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.goldMuted,
              fontFamily: fontBody,
            ),
          ),
        ],
      ),
    );
  }

  int _getPositionMs() {
    return positionAsync.value ??
        (playerStateAsync.value?.positionMs ?? 0);
  }

  String _formatDuration(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

/// Loading overlay shown when switching surahs (3–5 s gap).
/// Gold waveform bars — no external dependencies.
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: AppColors.bgBase.withValues(alpha: 0.88),
        child: const Center(
          child: _WaveformAnimation(),
        ),
      ),
    );
  }
}

/// 5-bar waveform animation — each bar oscillates independently on a
/// 700 ms sine wave, staggered 120 ms apart so they look like audio.
class _WaveformAnimation extends StatelessWidget {
  const _WaveformAnimation();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _WaveformBar(delayMs: 0),
        SizedBox(width: 6),
        _WaveformBar(delayMs: 120),
        SizedBox(width: 6),
        _WaveformBar(delayMs: 240),
        SizedBox(width: 6),
        _WaveformBar(delayMs: 360),
        SizedBox(width: 6),
        _WaveformBar(delayMs: 480),
      ],
    );
  }
}

class _WaveformBar extends StatefulWidget {
  final int delayMs;
  const _WaveformBar({required this.delayMs});

  @override
  State<_WaveformBar> createState() => _WaveformBarState();
}

class _WaveformBarState extends State<_WaveformBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delayed = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    );
    return AnimatedBuilder(
      animation: delayed,
      builder: (_, __) {
        final h = 8.0 + 24.0 * delayed.value;
        return Container(
          width: 5,
          height: h,
          decoration: BoxDecoration(
            color: AppColors.goldStart,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }
}
