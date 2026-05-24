import 'dart:async' show unawaited;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_route.dart';
import '../providers/home_state.dart';
import '../../../data/models/surah.dart';
import '../../player/screens/player_screen.dart';
import '../../player/providers/current_surah_provider.dart';
import '../../player/providers/player_providers.dart';
import '../../../core/services/audio_player_service.dart';
import '../../../core/providers/service_providers.dart';

/// Home screen — 2-column grid of surah cards with Dignity theme
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isPushingPlayer = false;

  @override
  void initState() {
    super.initState();
    // Kick off home surah loading
    Future.microtask(() => ref.read(homeProvider.notifier).loadSurahs());
    // Pre-load all surahs for CurrentSurahNotifier so that
    // playNext / playPrevious are ready without a network round-trip.
    Future.microtask(
      () => ref.read(currentSurahProvider.notifier).ensureSurahsLoaded(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Called when a surah card is tapped.
  /// Fires-and-forgets audio loading so navigation is instant.
  Future<void> _onSurahTap(BuildContext context, Surah surah) async {
    if (_isPushingPlayer) return;
    _isPushingPlayer = true;
    try {
      unawaited(ref.read(currentSurahProvider.notifier).loadSurah(surah.surahId));
      if (!context.mounted) return;
      Navigator.of(context).push(
        GoldCurtainRoute(page: PlayerScreen(surahId: surah.surahId)),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      _isPushingPlayer = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final surahs = homeState.filteredSurahs;
    final playerStateAsync = ref.watch(playerStateProvider);
    final isPlaying = playerStateAsync.value?.isPlaying ?? false;
    final isPaused = playerStateAsync.value?.state == PlayerStateEnum.paused;
    final showMiniPlayer = isPlaying || isPaused;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top spacing
            const SizedBox(height: screenPaddingTop),

            // AppBar with gold underline
            const _AppBarGold(),

            const SizedBox(height: 16),

            // Search bar with glassmorphism
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: screenPaddingH),
              child: _SearchBarGold(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(homeProvider.notifier).updateSearchQuery(value);
                },
              ),
            ),

            const SizedBox(height: 16),

            // Surah grid
            Expanded(
              child: homeState.isLoading
                  ? const _LoadingShimmerWidget()
                  : homeState.error != null
                      ? _ErrorState(
                          error: homeState.error!,
                          onRetry: () =>
                              ref.read(homeProvider.notifier).loadSurahs(),
                        )
                      : surahs.isEmpty
                          ? const _EmptyState()
                          : GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: gridColumns,
                                mainAxisSpacing: gridGap,
                                crossAxisSpacing: gridGap,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: surahs.length,
                              itemBuilder: (context, index) {
                                final surah = surahs[index];
                                return _SurahCard(surah: surah, onTap: _onSurahTap);
                              },
                              padding: EdgeInsets.zero,
                            ),
            ),

            // Mini player bar — only shows when playing or paused
            if (showMiniPlayer)
              _MiniPlayerBar(
                onTap: () {
                  final surahId = ref.read(currentSurahProvider)!.surahId;
                  Navigator.of(context).push(
                    GoldCurtainRoute(
                      page: PlayerScreen(surahId: surahId),
                    ),
                  );
                },
              ),

            // Bottom padding for nav bar (system UI)
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
          ],
        ),
      ),
    );
  }
}

/// Centered AppBar with "QLearner" and gold underline
class _AppBarGold extends StatelessWidget {
  const _AppBarGold();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'QLearner',
            style: appbarTitle.copyWith(
              foreground: Paint()
                ..shader = AppColors.goldGradient.createShader(
                  const Rect.fromLTWH(0, 0, 120, 30),
                ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 80,
            height: 2,
            decoration: const BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.all(Radius.circular(1)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Glassmorphism search bar with gold border
class _SearchBarGold extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBarGold({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: searchBarHeight,
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(searchBarRadius),
        border: Border.all(
          color: AppColors.goldSoft,
          width: goldBorderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(searchBarRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: searchBarBlur,
            sigmaY: searchBarBlur,
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Search surahs...',
              hintStyle: searchPlaceholder,
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textGray,
                size: 20,
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.textGray,
                        size: 18,
                      ),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: searchInput,
          ),
        ),
      ),
    );
  }
}

/// 2-column GridView of surah cards
/// Surah card with dark gradient background and gold gradient border
class _SurahCard extends StatefulWidget {
  final Surah surah;
  final Future<void> Function(BuildContext, Surah) onTap;

  const _SurahCard({
    required this.surah,
    required this.onTap,
  });

  @override
  State<_SurahCard> createState() => _SurahCardState();
}

class _SurahCardState extends State<_SurahCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressController.forward();
  void _onTapUp(TapUpDetails _) {
    _pressController.reverse();
    widget.onTap(context, widget.surah);
  }
  void _onTapCancel() => _pressController.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(cardBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldStart
                        .withValues(alpha: 0.3 * _glowAnim.value),
                    blurRadius: 16 * _glowAnim.value,
                    spreadRadius: 2 * _glowAnim.value,
                  ),
                ],
              ),
              child: CustomPaint(
          painter: _GoldBorderPainter(
            borderRadius: cardBorderRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(cardPaddingH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Surah number (gold, top-left)
                Text(
                  widget.surah.surahId,
                  style: const TextStyle(
                    fontFamily: fontBody,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldStart,
                  ),
                ),

                // Arabic name (white, centered, Noto Naskh 20px)
                Expanded(
                  child: Center(
                    child: Text(
                      widget.surah.name,
                      style: surahArabic,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // English name (gray, 12px) and ayah count (muted gold, 10px)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.surah.englishName,
                      style: cardSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.surah.ayahCount} ayahs',
                          style: metaText,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
        },
      ),
    );
  }
}

/// Custom painter for gold gradient border
class _GoldBorderPainter extends CustomPainter {
  final double borderRadius;

  _GoldBorderPainter({required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    const rect = Rect.largest;
    final gradient = AppColors.goldGradient;
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = goldBorderWidth;

    final rrect = RRect.fromRectAndRadius(
      rect.deflate(goldBorderWidth / 2),
      Radius.circular(borderRadius - goldBorderWidth / 2),
    );

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Mini player bar shown at bottom of home screen when audio is active
class _MiniPlayerBar extends ConsumerWidget {
  final VoidCallback onTap;

  const _MiniPlayerBar({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSurah = ref.watch(currentSurahProvider);
    final audioPlayer = ref.watch(audioPlayerProvider);
    final playerStateAsync = ref.watch(playerStateProvider);
    final positionAsync = ref.watch(positionProvider);

    if (currentSurah == null) return const SizedBox.shrink();

    final isPlaying = playerStateAsync.value?.isPlaying ?? false;
    final positionMs = positionAsync.value ?? playerStateAsync.value?.positionMs ?? 0;
    final durationMs = playerStateAsync.value?.durationMs ?? 0;
    final progress = durationMs > 0 ? positionMs / durationMs : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        margin: EdgeInsets.only(
          left: screenPaddingH,
          right: screenPaddingH,
          bottom: MediaQuery.of(context).viewPadding.bottom + 8,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(cardBorderRadius),
          border: Border.all(
            color: AppColors.goldSoft,
            width: goldBorderWidth,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thin progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.bgBase.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldStart),
              minHeight: 2,
            ),
            Expanded(
              child: Row(
                children: [
                  // Album art placeholder
                  Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.volume_up,
                      color: AppColors.bgBase,
                      size: 24,
                    ),
                  ),
                  // Surah info
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentSurah.name,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentSurah.englishName,
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Play/Pause button
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: AppColors.goldStart,
                    ),
                    onPressed: () async {
                      if (isPlaying) {
                        await audioPlayer.pause();
                      } else {
                        await audioPlayer.resume();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 100, end: 0).fadeIn();
  }
}

/// Loading shimmer placeholder

class _LoadingShimmerWidget extends StatelessWidget {
  const _LoadingShimmerWidget();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridColumns,
        mainAxisSpacing: gridGap,
        crossAxisSpacing: gridGap,
        childAspectRatio: 0.85,
      ),
      itemCount: 8,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => const GoldShimmerCard(),
    );
  }
}

/// Error state widget
class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.textGray,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldStart,
              foregroundColor: AppColors.bgBase,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Empty state widget with gold geometric pattern
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: const Size(200, 200),
        painter: _GoldPatternPainter(),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.goldMuted,
            ),
            SizedBox(height: 16),
            Text(
              'No surahs found',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 16,
                fontFamily: fontBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gold geometric pattern painter for empty states.
/// Draws a subtle arrangement of gold circles and lines.
class _GoldPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Concentric circles
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (double r = 30; r <= 90; r += 15) {
      circlePaint.color = AppColors.goldSoft.withValues(alpha: 0.15 + (r / 300));
      canvas.drawCircle(center, r, circlePaint);
    }

    // Diagonal lines
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3
      ..color = AppColors.goldSoft.withValues(alpha: 0.1);

    for (double i = -100; i <= 100; i += 20) {
      canvas.drawLine(
        Offset(center.dx + i, center.dy - 90),
        Offset(center.dx + i, center.dy + 90),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
