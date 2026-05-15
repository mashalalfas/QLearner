import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/providers/home_providers.dart';
import '../../../data/models/verse.dart';

/// Read screen - displays verses of a surah for reading
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
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        backgroundColor: AppTheme.lavender,
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
              return _VerseCard(verse: verse);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppTheme.accentPurple,
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.secondaryText,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                style: const TextStyle(
                  color: AppTheme.secondaryText,
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
class _VerseCard extends StatelessWidget {
  final Verse verse;

  const _VerseCard({required this.verse});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
                    color: AppTheme.accentPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Verse ${verse.verseId}',
                    style: const TextStyle(
                      color: AppTheme.accentPurple,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                if (verse.audioUrl != null)
                  IconButton(
                    onPressed: () {
                      // Navigate to player with this verse
                      // TODO: Implement navigation to player
                    },
                    icon: const Icon(
                      Icons.play_circle_outline,
                      color: AppTheme.accentPurple,
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
                color: AppTheme.lightLavender,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                verse.arabicText,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 28,
                  height: 1.8,
                  color: AppTheme.darkText,
                  fontFamily: 'Noto Sans Arabic',
                  fontFamilyFallback: ['Amiri', 'Scheherazade New', 'Noto Naskh Arabic'],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // English translation
            Text(
              verse.englishText,
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppTheme.darkText,
              ),
              textAlign: TextAlign.left,
            ),

            // Transliteration (if available)
            if (verse.englishTransliteration != null) ...[
              const SizedBox(height: 12),
              Text(
                verse.englishTransliteration!,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppTheme.secondaryText,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
