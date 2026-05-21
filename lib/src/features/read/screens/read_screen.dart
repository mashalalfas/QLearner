import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlearner/core/theme/app_colors.dart';
import 'package:qlearner/core/theme/app_typography.dart';
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
      appBar: AppBar(
        backgroundColor: AppColors.bgCardDark,
        elevation: 0,
        title: surahAsync.when(
          data: (surah) => Text('${surah.englishName} - ${surah.name}'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
      ),
      body: versesAsync.when(
        data: (verses) {
          if (verses.isEmpty) {
            return const Center(
              child: Text('No verses found'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: verses.length,
            itemBuilder: (context, index) {
              final verse = verses[index];
              return _VerseCard(verse: verse, surahId: widget.surahId);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.goldStart,
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.textGray,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                style: const TextStyle(
                  color: AppColors.textGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          color: AppColors.bgCardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: AppColors.goldSoft,
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                              MaterialPageRoute(
                                builder: (_) =>
                                    PlayerScreen(surahId: surahId),
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.play_circle_outline,
                          color: AppColors.goldStart,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Arabic text
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgCardInner,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.goldSoft,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    verse.arabicText,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 28,
                      height: 1.8,
                      color: AppColors.textWhite,
                      fontFamily: 'Noto Sans Arabic',
                      fontFamilyFallback: [
                        'Amiri',
                        'Scheherazade New',
                        'Noto Naskh Arabic'
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // English translation
                Text(
                  verse.englishText,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: AppColors.textWhite,
                    fontFamily: fontBody,
                  ),
                  textAlign: TextAlign.left,
                ),

                // Transliteration (if available)
                if (verse.englishTransliteration != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    verse.englishTransliteration!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textGray,
                      fontFamily: fontBody,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
