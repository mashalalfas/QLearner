import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/home_state.dart';
import '../../../data/models/surah.dart';
import '../../player/screens/player_screen.dart';
import '../../player/providers/current_surah_provider.dart';

/// Home screen — 2-column grid of surah cards with Dignity theme
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

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
  /// Uses [currentSurahProvider] as the single source of truth:
  /// 1. If tapped surah matches the currently playing one, just open the player (no restart).
  /// 2. Otherwise loadSurah fetches the Surah and starts playback.
  Future<void> _onSurahTap(BuildContext context, Surah surah) async {
    final current = ref.read(currentSurahProvider);
    final isAlreadyPlaying = current != null && current.surahId == surah.surahId;

    final messenger = ScaffoldMessenger.of(context);
    try {
      if (!isAlreadyPlaying) {
        await ref.read(currentSurahProvider.notifier).loadSurah(surah.surahId);
      }
      if (!context.mounted) return;
      if (!isAlreadyPlaying) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Playing ${surah.englishName}…'),
            duration: const Duration(milliseconds: 800),
          ),
        );
      }
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PlayerScreen(surahId: surah.surahId)),
      );
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final surahs = homeState.filteredSurahs;

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
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.goldStart,
                      ),
                    )
                  : homeState.error != null
                      ? _ErrorState(
                          error: homeState.error!,
                          onRetry: () =>
                              ref.read(homeProvider.notifier).loadSurahs(),
                        )
                      : surahs.isEmpty
                          ? const _EmptyState()
                          : _SurahGrid(
                              surahs: surahs,
                              onSurahTap: _onSurahTap,
                            ),
            ),

            // Bottom padding for nav bar
            const SizedBox(height: screenPaddingBottom),
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
class _SurahGrid extends StatelessWidget {
  final List<Surah> surahs;
  final Future<void> Function(BuildContext, Surah) onSurahTap;

  const _SurahGrid({
    required this.surahs,
    required this.onSurahTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: screenPaddingH),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridColumns,
          mainAxisSpacing: gridGap,
          crossAxisSpacing: gridGap,
          childAspectRatio: 0.85,
        ),
        itemCount: surahs.length,
        itemBuilder: (context, index) {
          final surah = surahs[index];
          return _SurahCard(surah: surah, onTap: onSurahTap);
        },
      ),
    );
  }
}

/// Surah card with dark gradient background and gold gradient border
class _SurahCard extends StatelessWidget {
  final Surah surah;
  final Future<void> Function(BuildContext, Surah) onTap;

  const _SurahCard({
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(context, surah),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(cardBorderRadius),
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
                  surah.surahId,
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
                      surah.name,
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
                      surah.englishName,
                      style: cardSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${surah.ayahCount} ayahs',
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
  }
}

/// Custom painter for gold gradient border
class _GoldBorderPainter extends CustomPainter {
  final double borderRadius;

  _GoldBorderPainter({required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
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

/// Empty state widget
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: AppColors.textGray,
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
    );
  }
}
