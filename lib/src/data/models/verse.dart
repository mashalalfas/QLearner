import 'package:equatable/equatable.dart';

/// Represents a Verse (ayah) in the Quran
class Verse extends Equatable {
  final String surahId;
  final int verseId; // Ayah number within surah
  final String arabicText; // Arabic text with uthmani script
  final String englishText; // English translation
  final String? englishTransliteration; // English transliteration
  final int startMs; // Start time in audio (milliseconds)
  final int? endMs; // End time in audio (milliseconds)
  final String? audioUrl; // Individual verse audio URL

  const Verse({
    required this.surahId,
    required this.verseId,
    required this.arabicText,
    required this.englishText,
    this.englishTransliteration,
    required this.startMs,
    this.endMs,
    this.audioUrl,
  });

  /// Get the duration of this verse in milliseconds
  int? get durationMs {
    if (endMs == null) return null;
    return endMs! - startMs;
  }

  @override
  List<Object?> get props => [
    surahId,
    verseId,
    arabicText,
    englishText,
    englishTransliteration,
    startMs,
    endMs,
    audioUrl,
  ];

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'surah_id': surahId,
      'verse_id': verseId,
      'arabic_text': arabicText,
      'english_text': englishText,
      'english_transliteration': englishTransliteration,
      'start_ms': startMs,
      'end_ms': endMs,
      'audio_url': audioUrl,
    };
  }

  /// Create Verse from Map
  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      surahId: map['surah_id'] as String,
      verseId: map['verse_id'] as int,
      arabicText: map['arabic_text'] as String,
      englishText: map['english_text'] as String,
      englishTransliteration: map['english_transliteration'] as String?,
      startMs: map['start_ms'] as int,
      endMs: map['end_ms'] as int?,
      audioUrl: map['audio_url'] as String?,
    );
  }

  Verse copyWith({
    String? surahId,
    int? verseId,
    String? arabicText,
    String? englishText,
    String? englishTransliteration,
    int? startMs,
    int? endMs,
    String? audioUrl,
  }) {
    return Verse(
      surahId: surahId ?? this.surahId,
      verseId: verseId ?? this.verseId,
      arabicText: arabicText ?? this.arabicText,
      englishText: englishText ?? this.englishText,
      englishTransliteration: englishTransliteration ?? this.englishTransliteration,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }
}
