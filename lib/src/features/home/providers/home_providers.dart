import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/surah.dart';
import '../../../data/models/verse.dart';
import '../../../core/providers/service_providers.dart';

/// Provider for the list of all surahs
final surahsProvider = FutureProvider.autoDispose<List<Surah>>((ref) async {
  final repository = ref.watch(quranRepositoryProvider);
  return await repository.getAllSurahs();
});

/// Provider for a specific surah
final surahProvider = FutureProvider.autoDispose.family<Surah, String>((ref, surahId) async {
  final repository = ref.watch(quranRepositoryProvider);
  return await repository.getSurah(surahId);
});

/// Provider for verses of a surah
final versesProvider = FutureProvider.autoDispose.family<List<Verse>, String>((ref, surahId) async {
  final repository = ref.watch(quranRepositoryProvider);
  return await repository.getVersesForSurah(surahId);
});
