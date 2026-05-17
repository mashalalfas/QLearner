/// Defines the contract for audio playback operations
abstract class AudioPlayerService {
  /// Initialize the audio player
  Future<void> initialize();

  /// Play audio from a given URL
  Future<void> play(String url, {int? startMs, int? endMs, String? surahName, String? surahArabic});

  /// Pause playback
  Future<void> pause();

  /// Resume playback
  Future<void> resume();

  /// Stop playback and reset position
  Future<void> stop();

  /// Seek to a specific position in milliseconds
  Future<void> seek(int positionMs);

  /// Get current playback position in milliseconds
  Stream<int> get positionStream;

  /// Get playback state (playing, paused, stopped)
  Stream<PlayerState> get playerStateStream;

  /// Stream of current surah ID (for verse synchronization)
  Stream<String> get currentSurahIdStream;

  /// Stream of current playback position (alias for positionStream)
  Stream<int> get currentPositionStream;

  /// Set playback speed (1.0 = normal)
  Future<void> setSpeed(double speed);

  /// Set repeat mode (0=none, 1=one, 2=all)
  Future<void> setRepeatMode(int mode);

  /// Dispose resources
  Future<void> dispose();
}

/// Represents the state of the audio player
class PlayerState {
  final bool isPlaying;
  final int positionMs;
  final int? durationMs;
  final PlayerStateEnum state;

  const PlayerState({
    required this.isPlaying,
    required this.positionMs,
    this.durationMs,
    required this.state,
  });

  PlayerState copyWith({
    bool? isPlaying,
    int? positionMs,
    int? durationMs,
    PlayerStateEnum? state,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      state: state ?? this.state,
    );
  }
}

enum PlayerStateEnum {
  playing,
  buffering,
  paused,
  stopped,
  completed,
}
