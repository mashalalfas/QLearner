import 'package:dio/dio.dart';
import 'package:quran/quran.dart' as q;
import '../../core/services/quran_repository.dart';
import '../models/surah.dart';
import '../models/verse.dart';

/// Quran repository implementation using the quran package and Dio for API calls
class QuranRepositoryImpl implements QuranRepository {
  final Dio _dio = Dio();
  static const String _baseAudioUrl = 'https://server8.mp3quran.net/afs';

  @override
  Future<List<Surah>> getAllSurahs() async {
    final surahs = <Surah>[];
    int failures = 0;

    for (int i = 1; i <= 114; i++) {
      try {
        final surah = await getSurah(i.toString());
        surahs.add(surah);
      } catch (e) {
        failures++;
      }
    }

    if (surahs.isEmpty) {
      throw Exception('Failed to load any surahs (114/114 failed)');
    }

    return surahs;
  }

  @override
  Future<Surah> getSurah(String surahId) async {
    final surahNumber = int.parse(surahId);
    final name = q.getSurahNameArabic(surahNumber); // Arabic name
    final englishName = q.getSurahName(surahNumber); // English transliteration
    final englishNameTranslation = q.getSurahNameEnglish(surahNumber); // English meaning
    final ayahCount = q.getVerseCount(surahNumber);
    final revelationPlace = q.getPlaceOfRevelation(surahNumber);

    return Surah(
      surahId: surahId,
      name: name,
      englishName: englishName,
      englishNameTranslation: englishNameTranslation,
      ayahCount: ayahCount,
      audioUrl: '$_baseAudioUrl/${surahId.padLeft(3, "0")}.mp3',
      revelationType: revelationPlace == 'Makkah' ? 1 : 2,
    );
  }

  @override
  Future<List<Verse>> getVersesForSurah(String surahId) async {
    final verses = <Verse>[];
    final surah = await getSurah(surahId);

    for (int i = 1; i <= surah.ayahCount; i++) {
      final verse = await getVerse(surahId, i);
      verses.add(verse);
    }

    return verses;
  }

  @override
  Future<Verse> getVerse(String surahId, int verseId) async {
    final surahNumber = int.parse(surahId);
    final arabic = q.getVerse(surahNumber, verseId);
    final english = q.getVerseTranslation(
      surahNumber,
      verseId,
      translation: q.Translation.enSaheeh,
    );

    // Generate audio URL for this specific verse
    final audioUrl = '$_baseAudioUrl/${surahId.padLeft(3, "0")}${verseId.toString().padLeft(3, "0")}.mp3';

    // Estimate start/end times (approximate, would need actual timing data)
    // This is a placeholder - actual timing would come from a timing file or API
    final startMs = (verseId - 1) * 5000; // Rough estimate
    final endMs = verseId * 5000;

    return Verse(
      surahId: surahId,
      verseId: verseId,
      arabicText: arabic,
      englishText: english,
      startMs: startMs,
      endMs: endMs,
      audioUrl: audioUrl,
    );
  }

  @override
  Future<List<Verse>> searchByArabic(String query) async {
    // This is a simplified implementation
    // In production, you'd want to query a proper database or API
    final results = <Verse>[];

    // Search through all surahs (inefficient for large datasets)
    for (int i = 1; i <= 114; i++) {
      final surahId = i.toString();
      final verses = await getVersesForSurah(surahId);

      for (final verse in verses) {
        if (verse.arabicText.contains(query)) {
          results.add(verse);
        }
      }
    }

    return results;
  }

  @override
  Future<List<Verse>> searchByEnglish(String query) async {
    final results = <Verse>[];

    for (int i = 1; i <= 114; i++) {
      final surahId = i.toString();
      final verses = await getVersesForSurah(surahId);

      for (final verse in verses) {
        if (verse.englishText.toLowerCase().contains(query.toLowerCase())) {
          results.add(verse);
        }
      }
    }

    return results;
  }

  @override
  Future<int> getSurahCount() async {
    return 114;
  }

  @override
  Future<int> getVerseCountForSurah(String surahId) async {
    final surah = await getSurah(surahId);
    return surah.ayahCount;
  }

  @override
  Future<void> refreshData() async {
    // Refresh logic would go here
    // Could re-fetch from API or re-parse assets
  }

  @override
  Future<void> dispose() async {
    _dio.close();
  }
}
