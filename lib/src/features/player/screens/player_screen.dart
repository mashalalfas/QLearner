import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:qlearner/src/features/reciters/providers/reciters_providers.dart';
import 'package:qlearner/src/data/models/surah.dart';
import 'package:lottie/lottie.dart';

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
                  Color(0x33C9A84C),
                  AppColors.bgBase,
                ],
                stops: [0.0, 0.7],
              ),
            ),
            child: Stack(
              children: [
                // Radial glow layer — strengthens background radial gradient
                Positioned.fill(
                  child: _RadialGlowPulse(),
                ),
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

                    // Reciter name
                    Consumer(
                      builder: (context, ref, _) {
                        final reciter = ref.watch(selectedReciterProvider);
                        return Text(
                          reciter?.name ?? 'Default Reciter',
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Controls row: Prev | Play/Pause/Loading | Next
                    _PlayerControls(
                      playerStateAsync: playerStateAsync,
                      isLoading: isLoading,
                      onPrev: currentSurahNotifier.canGoPrev
                          ? () async {
                              try {
                                await currentSurahNotifier.playPrevious();
                              } catch (e) {
                                debugPrint('Nav error (prev): $e');
                                currentSurahNotifier.setLoading(false);
                              }
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
                              try {
                                await currentSurahNotifier.playNext();
                              } catch (e) {
                                debugPrint('Nav error (next): $e');
                                currentSurahNotifier.setLoading(false);
                              }
                            }
                          : null,
                      positionMs: positionAsync.value ??
                          (playerStateAsync.value?.positionMs ?? 0),
                      durationMs: playerStateAsync.value?.durationMs ?? 0,
                      onSeek: (positionMs) {
                        ref.read(audioPlayerProvider).seek(positionMs);
                      },
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
                // No overlay — loading shown inside _PlayerControls via waveform
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
class _PlayerControls extends ConsumerStatefulWidget {
  final AsyncValue<PlayerState> playerStateAsync;
  final bool isLoading;
  final VoidCallback? onPrev;
  final VoidCallback onPlay;
  final VoidCallback? onNext;
  final int positionMs;
  final int durationMs;
  final ValueChanged<int> onSeek;

  const _PlayerControls({
    required this.playerStateAsync,
    required this.isLoading,
    this.onPrev,
    required this.onPlay,
    this.onNext,
    required this.positionMs,
    required this.durationMs,
    required this.onSeek,
  });

  @override
  ConsumerState<_PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends ConsumerState<_PlayerControls> {
  OverlayEntry? _peekOverlay;

  @override
  void dispose() {
    _dismissPeek();
    super.dispose();
  }

  void _showPeek(BuildContext context, {required bool isNext}) {
    final notifier = ref.read(currentSurahProvider.notifier);
    final surahs = isNext ? notifier.getUpcomingSurahs() : notifier.getPreviousSurahs();
    if (surahs.isEmpty) return;

    final buttonBox = context.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context);
    if (buttonBox == null) return;

    final buttonPos = buttonBox.localToGlobal(Offset.zero);
    final buttonSize = buttonBox.size;
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    const panelW = _SurahPeekPanel.panelWidth;
    const panelH = _SurahPeekPanel.panelHeight;
    const gap = 8.0;

    // Horizontal: center panel on button, clamp to screen edges
    final panelLeft = (buttonPos.dx + buttonSize.width / 2 - panelW / 2).clamp(8.0, screenW - panelW - 8.0);
    // Vertical: panel sits ABOVE the button
    final panelTop = (buttonPos.dy - panelH - gap).clamp(8.0, screenH - panelH - 8.0);

    _peekOverlay = OverlayEntry(
      builder: (_) => _SurahPeekPanel(
        surahs: surahs,
        isNext: isNext,
        panelTopLeft: Offset(panelLeft, panelTop),
        onDismiss: _dismissPeek,
        onTapSurah: (surah) {
          _dismissPeek();
          notifier.loadSurah(surah.surahId);
        },
      ),
    );

    overlay.insert(_peekOverlay!);
  }

  void _dismissPeek() {
    _peekOverlay?.remove();
    _peekOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Prev button — disabled when onPrev is null (first surah)
        GestureDetector(
          onLongPressStart: (_) {
            if (widget.onPrev != null) _showPeek(context, isNext: false);
          },
          child: IconButton(
            icon: const Icon(Icons.skip_previous_rounded),
            iconSize: 32,
            onPressed: widget.onPrev,
            disabledColor: AppColors.goldMuted.withValues(alpha: 0.35),
            color: AppColors.goldStart,
            
          ),
        ),

        const SizedBox(width: 32),

        // Back 5 seconds button
        _SeekBack5Button(
          positionMs: widget.positionMs,
          durationMs: widget.durationMs,
          onSeek: widget.onSeek,
        ),

        // Center: waveform when audio is buffering/loading, otherwise Play/Pause
        widget.playerStateAsync.when(
          data: (state) {
            if (state.state == PlayerStateEnum.buffering) {
              return Lottie.asset(
                'assets/loading.quran.json',
                width: 48,
                height: 48,
                repeat: true,
              );
            }
            return IconButton(
              icon: Icon(
                state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              ),
              iconSize: 36,
              onPressed: widget.onPlay,
              color: AppColors.goldStart,
              tooltip: state.isPlaying ? 'Pause' : 'Play',
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
          error: (_, __) => IconButton(
            icon: const Icon(Icons.play_arrow_rounded),
            iconSize: 36,
            onPressed: widget.onPlay,
            color: AppColors.goldMuted,
            tooltip: 'Play',
          ),
        ),

        // Forward 5 seconds button
        _SeekForward5Button(
          positionMs: widget.positionMs,
          durationMs: widget.durationMs,
          onSeek: widget.onSeek,
        ),

        const SizedBox(width: 32),

        // Next button — disabled when onNext is null (last surah)
        GestureDetector(
          onLongPressStart: (_) {
            if (widget.onNext != null) _showPeek(context, isNext: true);
          },
          child: IconButton(
            icon: const Icon(Icons.skip_next_rounded),
            iconSize: 32,
            onPressed: widget.onNext,
            disabledColor: AppColors.goldMuted.withValues(alpha: 0.35),
            color: AppColors.goldStart,
            
          ),
        ),
      ],
    );
  }
}

/// Floating peek overlay that shows up to 10 upcoming (or previous) surahs
/// anchored above the prev/next button. Tapping a surah navigates to it;
/// tapping the backdrop dismisses the panel.
class _SurahPeekPanel extends StatelessWidget {
  static const double panelWidth = 300;
  static const double panelHeight = 392; // (7 * 56) + 48

  final List<Surah> surahs;
  final bool isNext;
  final Offset panelTopLeft;
  final VoidCallback onDismiss;
  final ValueChanged<Surah> onTapSurah;

  const _SurahPeekPanel({
    required this.surahs,
    required this.isNext,
    required this.panelTopLeft,
    required this.onDismiss,
    required this.onTapSurah,
  });

  static const double _itemHeight = 56;
  static const double _borderRadius = 16;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent backdrop — tap to dismiss
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            child: Container(color: AppColors.bgBase.withValues(alpha: 0.30)),
          ),
        ),
        // Floating panel — position pre-computed by _showPeek
        Positioned(
          left: panelTopLeft.dx,
          top: panelTopLeft.dy,
          child: _buildPanel(context),
        ),
      ],
    );
  }

  Widget _buildPanel(BuildContext context) {
    // panelHeight is a static const; Material elevation matches
    return Material(
      color: AppColors.bgCardDark.withValues(alpha: 0.85),
      elevation: 16,
      shadowColor: AppColors.goldStart.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(_borderRadius),
      child: Container(
        width: panelWidth,
        constraints: BoxConstraints(maxHeight: panelHeight),
        decoration: BoxDecoration(
          color: AppColors.bgCardDark.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(color: AppColors.goldStart.withValues(alpha: 0.20), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.goldStart.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(_borderRadius),
                  topRight: Radius.circular(_borderRadius),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isNext ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: AppColors.goldStart,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isNext ? 'Upcoming' : 'Previous',
                    style: const TextStyle(
                      color: AppColors.goldStart,
                      fontFamily: fontBody,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onDismiss,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.goldStart.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.goldStart,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable surah list
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                itemCount: surahs.length,
                itemExtent: _itemHeight,
                itemBuilder: (context, index) {
                  final s = surahs[index];
                  return InkWell(
                    onTap: () => onTapSurah(s),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      child: Row(
                        children: [
                          // Surah number badge
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.goldStart.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              s.surahId,
                              style: const TextStyle(
                                color: AppColors.goldStart,
                                fontFamily: fontBody,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Arabic name
                          Expanded(
                            flex: 3,
                            child: Text(
                              s.name,
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontFamily: fontBody,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // English name + ayah count
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  s.englishName,
                                  style: const TextStyle(
                                    color: AppColors.textWhite,
                                    fontFamily: fontBody,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${s.ayahCount} ayahs',
                                  style: const TextStyle(
                                    color: AppColors.goldMuted,
                                    fontFamily: fontBody,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ±5-second seek buttons — small gold icons flanking the time labels
class _SeekBack5Button extends StatelessWidget {
  final int positionMs;
  final int durationMs;
  final ValueChanged<int> onSeek;

  const _SeekBack5Button({
    required this.positionMs,
    required this.durationMs,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final atStart = positionMs == 0;
    return IconButton(
      icon: const Icon(Icons.replay_5),
      iconSize: 28,
      onPressed: atStart
          ? null
          : () {
              HapticFeedback.lightImpact();
              final newPos = positionMs - 5000;
              onSeek(newPos > 0 ? newPos : 0);
            },
      color: atStart
          ? AppColors.goldMuted.withValues(alpha: 0.35)
          : AppColors.goldStart,
      tooltip: 'Back 5 seconds',
    );
  }
}

class _SeekForward5Button extends StatelessWidget {
  final int positionMs;
  final int durationMs;
  final ValueChanged<int> onSeek;

  const _SeekForward5Button({
    required this.positionMs,
    required this.durationMs,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final atEnd = positionMs >= durationMs - 5000;
    return IconButton(
      icon: const Icon(Icons.forward_5),
      iconSize: 28,
      onPressed: atEnd
          ? null
          : () {
              HapticFeedback.lightImpact();
              onSeek((positionMs + 5000).clamp(0, durationMs));
            },
      color: atEnd
          ? AppColors.goldMuted.withValues(alpha: 0.35)
          : AppColors.goldStart,
      tooltip: 'Forward 5 seconds',
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
        return Container(
            width: 32 * 0.22,
          height: 32 * 0.75 * (0.33 + 0.67 * delayed.value),
          decoration: BoxDecoration(
            color: AppColors.goldStart,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }
}

/// Subtle pulsing radial glow behind the player circle.
/// Adds depth and a premium feel to the player background.
class _RadialGlowPulse extends StatefulWidget {
  @override
  State<_RadialGlowPulse> createState() => _RadialGlowPulseState();
}

class _RadialGlowPulseState extends State<_RadialGlowPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
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
      builder: (context, _) {
        final pulse = 0.15 + 0.1 * _controller.value;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.8,
              colors: [
                AppColors.goldStart.withValues(alpha: pulse),
                AppColors.goldStart.withValues(alpha: pulse * 0.3),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        );
      },
    );
  }
}
