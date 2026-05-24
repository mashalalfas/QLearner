import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlearner/core/theme/app_shimmer.dart';
import 'package:qlearner/core/theme/app_colors.dart';
import 'package:qlearner/core/theme/app_typography.dart';
import 'package:qlearner/core/theme/app_spacing.dart';
import 'package:qlearner/core/theme/app_route.dart';
import 'package:qlearner/shared/widgets/glass_card.dart';
import '../../home/providers/home_providers.dart';
import '../../player/screens/player_screen.dart';
import '../../player/providers/current_surah_provider.dart';
import '../../../data/models/verse.dart';

/// Read screen - displays verses of a surah for reading
/// Dignity theme: dark background, gold accents
class ReadScreen extends ConsumerStatefulWidget {
  final String surahId;

  const ReadScreen({
    super.key,
    required this.surahId,
  });

  @override
  ConsumerState<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends ConsumerState<ReadScreen> {
  @override
  Widget build(BuildContext context) {
    final versesAsync = ref.watch(versesProvider(widget.surahId));
    final surahAsync = ref.watch(surahProvider(widget.surahId));

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom AppBar with glass styling
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                gradient: AppColors.cardGradient,
                border: Border(
                  bottom: BorderSide(color: AppColors.goldSoft, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    color: AppColors.goldStart,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: surahAsync.when(
                      data: (surah) => Text(
                        '${surah.englishName} - ${surah.name}',
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: fontBody,
                        ),
                      ),
                      loading: () => const Text(
                        'Loading...',
                        style: TextStyle(color: AppColors.textGray),
                      ),
                      error: (_, __) => const Text(
                        'Error',
                        style: TextStyle(color: AppColors.textGray),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: versesAsync.when(
                data: (verses) {
                  if (verses.isEmpty) {
                    return Center(
                      child: GlassCard(
                        radius: cardBorderRadius,
                        padding: const EdgeInsets.symmetric(
                            vertical: 32, horizontal: 24),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.menu_book_outlined,
                                size: 40, color: AppColors.goldMuted),
                            SizedBox(height: 12),
                            Text(
                              'No verses found',
                              style: TextStyle(
                                color: AppColors.textGray,
                                fontSize: 15,
                                fontFamily: fontBody,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: verses.length,
                    itemBuilder: (context, index) {
                      final verse = verses[index];
                      return _VerseCard(
                          verse: verse, surahId: widget.surahId);
                    },
                  );
                },
                loading: () => ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 6,
                  itemBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: GoldShimmer(height: 120, borderRadius: 18),
                  ),
                ),
                error: (error, stack) => Center(
                  child: GlassCard(
                    radius: cardBorderRadius,
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 40,
                          color: AppColors.goldMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Error: $error',
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 14,
                            fontFamily: fontBody,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card widget for displaying a single verse
/// Dignity theme: dark cards, gold accents
class _VerseCard extends StatelessWidget {
  final Verse verse;
  final String surahId;

  const _VerseCard({required this.verse, required this.surahId});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GlassCard(
            radius: cardBorderRadius,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verse header with number
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.goldStart.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Verse ${verse.verseId}',
                        style: const TextStyle(
                          color: AppColors.goldMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          fontFamily: fontBody,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (verse.audioUrl != null)
                      IconButton(
                        onPressed: () {
                          ref
                              .read(currentSurahProvider.notifier)
                              .ensureSurahsLoaded();
                          ref
                              .read(currentSurahProvider.notifier)
                              .loadSurah(surahId);
                          if (context.mounted) {
                            Navigator.of(context).push(
                              GoldCurtainRoute(
                                page: PlayerScreen(surahId: surahId),
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.play_circle_outline,
                          color: AppColors.goldStart,
                          size: 22,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Arabic text
                Text(
                  verse.arabicText,
                  style: const TextStyle(
                    fontFamily: fontArabic,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                    color: AppColors.textWhite,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                // Translation
                Text(
                  verse.englishText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: AppColors.textGray,
                      fontFamily: fontBody,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
