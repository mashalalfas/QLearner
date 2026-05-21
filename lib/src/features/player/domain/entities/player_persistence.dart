
/// Persisted player state for audiobook-style resume
class PlayerPersistence {
  final int? lastSurahId;
  final bool wasPlaying;
  final int positionMs;

  const PlayerPersistence({
    this.lastSurahId,
    this.wasPlaying = false,
    this.positionMs = 0,
  });

  PlayerPersistence copyWith({
    int? lastSurahId,
    bool? wasPlaying,
    int? positionMs,
  }) {
    return PlayerPersistence(
      lastSurahId: lastSurahId ?? this.lastSurahId,
      wasPlaying: wasPlaying ?? this.wasPlaying,
      positionMs: positionMs ?? this.positionMs,
    );
  }

  Map<String, dynamic> toJson() => {
        'lastSurahId': lastSurahId,
        'wasPlaying': wasPlaying,
        'positionMs': positionMs,
      };

  factory PlayerPersistence.fromJson(Map<String, dynamic> json) {
    return PlayerPersistence(
      lastSurahId: json['lastSurahId'] as int?,
      wasPlaying: json['wasPlaying'] as bool? ?? false,
      positionMs: json['positionMs'] as int? ?? 0,
    );
  }
}
