import 'package:equatable/equatable.dart';

/// Represents a user bookmark with optional notes
class Bookmark extends Equatable {
  final String id; // Unique identifier
  final String surahId;
  final int verseId;
  final int positionMs; // Audio playback position when bookmarked
  final String? note; // User's personal note
  final DateTime createdAt;
  final DateTime updatedAt;

  const Bookmark({
    required this.id,
    required this.surahId,
    required this.verseId,
    required this.positionMs,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Generate a unique ID
  static String generateId(String surahId, int verseId) {
    return '${surahId}_$verseId';
  }

  /// Create a new bookmark (generates ID and timestamps)
  factory Bookmark.create({
    required String surahId,
    required int verseId,
    required int positionMs,
    String? note,
  }) {
    final now = DateTime.now();
    return Bookmark(
      id: generateId(surahId, verseId),
      surahId: surahId,
      verseId: verseId,
      positionMs: positionMs,
      note: note,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Update timestamp on modification
  Bookmark update({String? note, int? positionMs}) {
    return Bookmark(
      id: id,
      surahId: surahId,
      verseId: verseId,
      positionMs: positionMs ?? this.positionMs,
      note: note ?? this.note,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    surahId,
    verseId,
    positionMs,
    note,
    createdAt,
    updatedAt,
  ];

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surah_id': surahId,
      'verse_id': verseId,
      'position_ms': positionMs,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create Bookmark from Map
  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as String,
      surahId: map['surah_id'] as String,
      verseId: map['verse_id'] as int,
      positionMs: map['position_ms'] as int,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Bookmark copyWith({
    String? id,
    String? surahId,
    int? verseId,
    int? positionMs,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bookmark(
      id: id ?? this.id,
      surahId: surahId ?? this.surahId,
      verseId: verseId ?? this.verseId,
      positionMs: positionMs ?? this.positionMs,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
