import 'package:equatable/equatable.dart';

/// Represents a Surah (chapter) in the Quran
class Surah extends Equatable {
  final String surahId; // 1-114
  final String name; // Arabic name
  final String englishName; // English transliteration
  final String englishNameTranslation; // English meaning/translation
  final int ayahCount; // Number of verses
  final String? audioUrl; // Full chapter recitation URL
  final int revelationType; // 1 = Meccan, 2 = Medinan

  const Surah({
    required this.surahId,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.ayahCount,
    this.audioUrl,
    required this.revelationType,
  });

  /// Helper to get revelation type as string
  String get revelationTypeString {
    return revelationType == 1 ? 'Meccan' : 'Medinan';
  }

  @override
  List<Object?> get props => [
    surahId,
    name,
    englishName,
    englishNameTranslation,
    ayahCount,
    audioUrl,
    revelationType,
  ];

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'surah_id': surahId,
      'name': name,
      'english_name': englishName,
      'english_name_translation': englishNameTranslation,
      'ayah_count': ayahCount,
      'audio_url': audioUrl,
      'revelation_type': revelationType,
    };
  }

  /// Create Surah from Map
  factory Surah.fromMap(Map<String, dynamic> map) {
    return Surah(
      surahId: map['surah_id'] as String,
      name: map['name'] as String,
      englishName: map['english_name'] as String,
      englishNameTranslation: map['english_name_translation'] as String,
      ayahCount: map['ayah_count'] as int,
      audioUrl: map['audio_url'] as String?,
      revelationType: map['revelation_type'] as int,
    );
  }

  Surah copyWith({
    String? surahId,
    String? name,
    String? englishName,
    String? englishNameTranslation,
    int? ayahCount,
    String? audioUrl,
    int? revelationType,
  }) {
    return Surah(
      surahId: surahId ?? this.surahId,
      name: name ?? this.name,
      englishName: englishName ?? this.englishName,
      englishNameTranslation: englishNameTranslation ?? this.englishNameTranslation,
      ayahCount: ayahCount ?? this.ayahCount,
      audioUrl: audioUrl ?? this.audioUrl,
      revelationType: revelationType ?? this.revelationType,
    );
  }
}
