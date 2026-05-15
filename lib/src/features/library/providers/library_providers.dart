import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/bookmark.dart';
import '../../../core/providers/service_providers.dart';

/// Provider for list of bookmarks
final bookmarksProvider = FutureProvider.autoDispose<List<Bookmark>>((ref) async {
  final service = ref.watch(bookmarkServiceProvider);
  return await service.getAllBookmarks();
});

/// Provider for downloaded files
final downloadsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final service = ref.watch(downloadServiceProvider);
  return await service.getDownloadedFiles();
});
