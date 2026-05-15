import '../../data/models/surah.dart';
import '../../data/models/verse.dart';

/// Defines the contract for Quran data repository
abstract class QuranRepository {
  /// Get all surahs (chapters)
  Future<List<Surah>> getAllSurahs();

  /// Get a specific surah by ID
  Future<Surah> getSurah(String surahId);

  /// Get all verses for a surah
  Future<List<Verse>> getVersesForSurah(String surahId);

  /// Get a specific verse by surah and verse number
  Future<Verse> getVerse(String surahId, int verseId);

  /// Search verses by Arabic text
  Future<List<Verse>> searchByArabic(String query);

  /// Search verses by English translation
  Future<List<Verse>> searchByEnglish(String query);

  /// Get total number of surahs
  Future<int> getSurahCount();

  /// Get total number of verses in a surah
  Future<int> getVerseCountForSurah(String surahId);

  /// Refresh/reload Quran data from source
  Future<void> refreshData();

  /// Dispose resources
  Future<void> dispose();
}
