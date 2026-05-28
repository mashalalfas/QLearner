import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranaudio/core/theme/app_colors.dart';
import 'package:quranaudio/core/theme/app_typography.dart';
import 'package:quranaudio/core/theme/app_spacing.dart';
import 'package:quranaudio/shared/widgets/glass_card.dart';
import 'package:quranaudio/shared/widgets/section_header.dart';
import '../providers/library_providers.dart';
import 'package:quranaudio/src/core/providers/service_providers.dart';
import 'package:quranaudio/src/data/models/bookmark.dart';
import 'package:quranaudio/src/data/models/surah.dart';
import 'package:quranaudio/src/features/home/providers/home_providers.dart';

/// Library screen — Dignity theme (black & gold glassmorphism)
///
/// Layout:
/// - Single scroll view with storage card + two sections
/// - Downloads: surah name, ayah count + size, Play/Delete actions
/// - Bookmarks: verse reference, date
/// - Gold dividers between items
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Invalidate bookmarks so they are freshly loaded whenever the tab becomes active
    ref.invalidate(bookmarksProvider);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenPaddingH,
            vertical: screenPaddingTop,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Library Header ──
              _LibraryHeader(),

              SizedBox(height: 24),

              // ── Storage Card ──
              _StorageCard(),

              SizedBox(height: 28),

              // ── Downloads Section ──
              _DownloadsSection(),

              SizedBox(height: 32),

              // ── Bookmarks Section ──
              _BookmarksSection(),

              // Bottom spacing for navigation
              SizedBox(height: bottomNavHeight + screenPaddingBottom),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HEADER
// ═══════════════════════════════════════════════════════════════════════════

class _LibraryHeader extends StatelessWidget {
  const _LibraryHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title: 28px bold white
        const Text(
          'Library',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textWhite,
            fontFamily: fontBody,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        // Gold underline (gradient, full width)
        Container(
          width: double.infinity,
          height: 2,
          decoration: const BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.all(Radius.circular(1)),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STORAGE CARD
// ═══════════════════════════════════════════════════════════════════════════

class _StorageCard extends ConsumerWidget {
  const _StorageCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For now, use placeholder values; real implementation would query
    // download service for total size of downloaded files and device storage
    const double usedGB = 2.4;
    const double totalGB = 16.0;
    const double progress = usedGB / totalGB;

    return GlassCard(
      radius: cardBorderRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Storage',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                  fontFamily: fontBody,
                ),
              ),
              Text(
                '${usedGB.toStringAsFixed(1)} GB / ${totalGB.toStringAsFixed(1)} GB',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.goldMuted,
                  fontFamily: fontBody,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Gold progress track (4px thin)
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.bgCardInner,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.goldStart,
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DOWNLOADS SECTION
// ═══════════════════════════════════════════════════════════════════════════

class _DownloadsSection extends ConsumerWidget {
  const _DownloadsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsAsync = ref.watch(downloadsProvider);
    final surahsAsync = ref.watch(surahsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Downloads'),
        const SizedBox(height: 12),
        downloadsAsync.when(
          data: (filenames) {
            if (filenames.isEmpty) {
              return const _EmptySectionMessage(
                icon: Icons.download_done,
                message: 'No downloads yet',
              );
            }

            // Build list of download items
            return surahsAsync.when(
              data: (surahs) {
                final surahMap = {for (var s in surahs) s.surahId: s};
                final items = _parseDownloadFilenames(filenames, surahMap);

                return Column(
                  children: [
                    ...items.asMap().entries.map((entry) {
                      final item = entry.value;
                      return _DownloadItem(
                        key: ValueKey(item.filename),
                        surah: item.surah,
                        sizeMB: item.sizeMB,
                        onPlay: () => _onPlay(context, item),
                        onDelete: () => _onDelete(ref, item.filename),
                      );
                    }),
                    // Final divider
                    const _Divider(),
                  ],
                );
              },
              loading: () => const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.goldStart,
                    ),
                  ),
                ),
              ),
              error: (_, __) => const _ErrorSectionMessage(),
            );
          },
          loading: () => const SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldStart),
              ),
            ),
          ),
          error: (_, __) => const _ErrorSectionMessage(),
        ),
      ],
    );
  }

  // Parse filenames like "001.mp3" → (Surah, size)
  List<_DownloadItemData> _parseDownloadFilenames(
    List<String> filenames,
    Map<String, Surah> surahMap,
  ) {
    final List<_DownloadItemData> items = [];

    for (final filename in filenames) {
      // Extract numeric surah ID from filename (e.g., "001.mp3" → "1")
      final match = RegExp(r'(\d{1,3})').firstMatch(filename);
      if (match != null) {
        final surahId = match.group(1)!.padLeft(3, '0');
        final surah = surahMap[surahId];
        if (surah != null) {
          // Placeholder size: random realistic value based on ayah count
          // Real implementation would get actual file size
          final sizeMB = (surah.ayahCount * 0.15).toStringAsFixed(1);
          items.add(_DownloadItemData(
            surah: surah,
            filename: filename,
            sizeMB: sizeMB,
          ));
        }
      }
    }

    // Sort by surah number ascending
    items.sort((a, b) => int.parse(a.surah.surahId)
        .compareTo(int.parse(b.surah.surahId)));

    return items;
  }

  void _onPlay(BuildContext context, _DownloadItemData item) {
    // Navigate to player or play download
    // Implementation depends on audio service integration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing ${item.surah.englishName}'),
        backgroundColor: AppColors.bgCardDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onDelete(WidgetRef ref, String filename) async {
    final service = ref.read(downloadServiceProvider);
    await service.deleteFile(filename);
    // Invalidate provider to refresh list
    ref.invalidate(downloadsProvider);
  }
}

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

// ═══════════════════════════════════════════════════════════════════════════
// BOOKMARKS SECTION
// ═══════════════════════════════════════════════════════════════════════════

class _BookmarksSection extends ConsumerWidget {
  const _BookmarksSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Bookmarks'),
        const SizedBox(height: 12),
        bookmarksAsync.when(
          data: (bookmarks) {
            if (bookmarks.isEmpty) {
              return const _EmptySectionMessage(
                icon: Icons.bookmark_border,
                message: 'No bookmarks yet',
              );
            }

            // Sort by newest first
            final sorted = List<Bookmark>.from(bookmarks)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return Column(
              children: [
                ...sorted.asMap().entries.map((entry) {
                  final entryIndex = entry.key;
                  final bookmark = entry.value;
                  return _BookmarkItem(
                    key: ValueKey(bookmark.id),
                    bookmark: bookmark,
                    index: entryIndex,
                    onTap: () => _onBookmarkTap(context, bookmark),
                  );
                }),
                // Final divider
                const _Divider(),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldStart),
              ),
            ),
          ),
          error: (_, __) => const _ErrorSectionMessage(),
        ),
      ],
    );
  }

  void _onBookmarkTap(BuildContext context, Bookmark bookmark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Jump to ${bookmark.surahId}:${bookmark.verseId}'),
        backgroundColor: AppColors.bgCardDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LIST ITEMS
// ═══════════════════════════════════════════════════════════════════════════

class _DownloadItem extends StatelessWidget {
  final Surah surah;
  final String sizeMB;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  const _DownloadItem({
    required Key key,
    required this.surah,
    required this.sizeMB,
    required this.onPlay,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thin gold divider (except first item - handled by parent)
        const _Divider(),
        // Item content
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              // Surah info (expanded)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Surah name (white)
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
                    // Ayah count + size (gray)
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
        ),
      ],
    );
  }
}

class _BookmarkItem extends StatelessWidget {
  final Bookmark bookmark;
  final int index;
  final VoidCallback onTap;

  const _BookmarkItem({
    required Key key,
    required this.bookmark,
    required this.index,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format verse reference: "Al-Fatiha:1" or "1:1"
    final surahNum = int.parse(bookmark.surahId).toString();
    final verseRef = '$surahNum:${bookmark.verseId}';

    // Format date: "May 12" or full date
    final dateStr = _formatDate(bookmark.createdAt);

    return Column(
      children: [
        const _Divider(),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                // Verse reference (white)
                Expanded(
                  child: Text(
                    verseRef,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textWhite,
                      fontFamily: fontBody,
                    ),
                  ),
                ),
                // Date (muted gold)
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.goldMuted,
                    fontFamily: fontBody,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      // Short month name + day
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SMALL WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      height: 0.5,
      color: AppColors.goldSoft, // Thin gold line
    );
  }
}

class _EmptySectionMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptySectionMessage({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            icon,
            size: 36,
            color: AppColors.textGray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textGray,
              fontFamily: fontBody,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorSectionMessage extends StatelessWidget {
  const _ErrorSectionMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: const Text(
        'Unable to load',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textGray,
          fontFamily: fontBody,
        ),
      ),
    );
  }
}
