import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/service_providers.dart';

/// Provider to check if a specific verse is bookmarked
final isBookmarkedProvider = FutureProvider.autoDispose
    .family<bool, ({String surahId, int verseId})>((ref, params) async {
  final bookmarkService = ref.watch(bookmarkServiceProvider);
  return await bookmarkService.isBookmarked(params.surahId, params.verseId);
});
