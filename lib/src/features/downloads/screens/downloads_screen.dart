import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranaudio/core/theme/app_colors.dart';
import 'package:quranaudio/core/theme/app_route.dart';
import 'package:quranaudio/core/theme/app_spacing.dart';
import 'package:quranaudio/core/theme/app_typography.dart';
import 'package:quranaudio/src/core/providers/service_providers.dart';
import 'package:quranaudio/src/data/models/surah.dart';
import 'package:quranaudio/src/features/home/providers/home_providers.dart';
import 'package:quranaudio/src/features/library/providers/library_providers.dart';
import 'package:quranaudio/src/features/player/providers/current_surah_provider.dart';
import 'package:quranaudio/src/features/player/screens/player_screen.dart';

/// Full-screen view of all downloaded surahs with play/delete actions.
///
/// Reads from [downloadsProvider] and [surahsProvider].
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsAsync = ref.watch(downloadsProvider);
    final surahsAsync = ref.watch(surahsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Downloads',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textWhite,
            fontFamily: fontBody,
          ),
        ),
        centerTitle: false,
      ),
      body: downloadsAsync.when(
        data: (filenames) {
          if (filenames.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.download_rounded,
                      size: 64,
                      color: AppColors.goldMuted,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No downloads yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textWhite,
                        fontFamily: fontBody,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Play a surah to cache it.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textGray,
                        fontFamily: fontBody,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return surahsAsync.when(
            data: (surahs) {
              final surahMap = {for (var s in surahs) s.surahId: s};
              final items = _parseDownloadFilenames(filenames, surahMap);

              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    'No matching surahs found',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGray,
                      fontFamily: fontBody,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: screenPaddingH,
                  vertical: 8,
                ),
                itemCount: items.length,
                separatorBuilder: (_, __) => Container(
                  height: 0.5,
                  color: AppColors.goldSoft,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _DownloadItem(
                    surah: item.surah,
                    sizeMB: item.sizeMB,
                    onPlay: () => _onPlay(context, ref, item),
                    onDelete: () => _onDelete(ref, item.filename),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldStart),
              ),
            ),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Failed to load surahs: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGray,
                    fontFamily: fontBody,
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldStart),
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Failed to load downloads: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGray,
                fontFamily: fontBody,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────

  List<_DownloadItemData> _parseDownloadFilenames(
    List<String> filenames,
    Map<String, Surah> surahMap,
  ) {
    final items = <_DownloadItemData>[];

    for (final filename in filenames) {
      final match = RegExp(r'(\d{1,3})').firstMatch(filename);
      if (match != null) {
        final surahId = match.group(1)!.padLeft(3, '0');
        final surah = surahMap[surahId];
        if (surah != null) {
          final sizeMB = (surah.ayahCount * 0.15).toStringAsFixed(1);
          items.add(_DownloadItemData(
            surah: surah,
            filename: filename,
            sizeMB: sizeMB,
          ));
        }
      }
    }

    items.sort((a, b) =>
        int.parse(a.surah.surahId).compareTo(int.parse(b.surah.surahId)));

    return items;
  }

  void _onPlay(
    BuildContext context,
    WidgetRef ref,
    _DownloadItemData item,
  ) async {
    await addRecentSurah(item.surah.surahId, item.surah.englishName);
    try {
      await ref
          .read(currentSurahProvider.notifier)
          .loadSurah(item.surah.surahId);
      if (context.mounted) {
        unawaited(
          Navigator.of(context).push(
            GoldCurtainRoute(page: PlayerScreen(surahId: item.surah.surahId)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing ${item.surah.englishName}: $e'),
            backgroundColor: AppColors.bgCardDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _onDelete(WidgetRef ref, String filename) async {
    final service = ref.read(downloadServiceProvider);
    await service.deleteFile(filename);
    ref.invalidate(downloadsProvider);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Data class for a parsed download item
// ─────────────────────────────────────────────────────────────────────────

class _DownloadItemData {
  final Surah surah;
  final String filename;
  final String sizeMB;

  _DownloadItemData({
    required this.surah,
    required this.filename,
    required this.sizeMB,
  });
}

// ─────────────────────────────────────────────────────────────────────────
// Download row widget
// ─────────────────────────────────────────────────────────────────────────

class _DownloadItem extends StatelessWidget {
  final Surah surah;
  final String sizeMB;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  const _DownloadItem({
    required this.surah,
    required this.sizeMB,
    required this.onPlay,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Surah info (expanded)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surah.englishName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                    fontFamily: fontBody,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${surah.ayahCount} ayahs • $sizeMB MB',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGray,
                    fontFamily: fontBody,
                  ),
                ),
              ],
            ),
          ),
          // Play button (gold)
          _TextGoldButton(
            label: 'Play',
            onTap: onPlay,
          ),
          const SizedBox(width: 16),
          // Delete button (gray)
          _TextGrayButton(
            label: 'Delete',
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────

class _TextGoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TextGoldButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: AppColors.goldStart,
              fontFamily: fontBody,
            ),
          ),
        ),
      ),
    );
  }
}

class _TextGrayButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TextGrayButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              color: AppColors.textGray,
              fontFamily: fontBody,
            ),
          ),
        ),
      ),
    );
  }
}
