import 'package:qlearner/src/features/player/domain/entities/player_persistence.dart';
import 'package:qlearner/src/features/player/data/datasources/player_local_datasource.dart';
import 'package:qlearner/src/core/services/audio_player_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class PlayerRepository {
  // Audio playback
  Future<void> initialize();
  Future<void> play(
    String url, {
    int? startMs,
    int? endMs,
    String? surahName,
    String? surahArabic,
  });
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> seek(int positionMs);

  // State streams
  Stream<String> get currentSurahIdStream;
  Stream<int> get currentPositionStream;
  Stream<PlayerState> get playerStateStream;

  // Persistence
  Future<PlayerPersistence?> getLastPlayerState();
  Future<void> savePlayerState(PlayerPersistence state);
  Future<void> clearPlayerState();

  // Lifecycle
  Future<void> dispose();
}

/// Concrete implementation of [PlayerRepository].
///
/// Audio operations are delegated to [AudioPlayerService].
/// Persistence operations are delegated to [PlayerLocalDataSourceImpl].
class PlayerRepositoryImpl implements PlayerRepository {
  PlayerRepositoryImpl({
    required this.audioPlayerService,
    required this.localDataSource,
  });

  final AudioPlayerService audioPlayerService;
  final PlayerLocalDataSourceImpl localDataSource;

  // ─── Audio playback ───────────────────────────────────────────────

  @override
  Future<void> initialize() => audioPlayerService.initialize();

  @override
  Future<void> play(
    String url, {
    int? startMs,
    int? endMs,
    String? surahName,
    String? surahArabic,
  }) {
    return audioPlayerService.play(
      url,
      startMs: startMs,
      endMs: endMs,
      surahName: surahName,
      surahArabic: surahArabic,
    );
  }

  @override
  Future<void> pause() => audioPlayerService.pause();

  @override
  Future<void> resume() => audioPlayerService.resume();

  @override
  Future<void> stop() => audioPlayerService.stop();

  @override
  Future<void> seek(int positionMs) => audioPlayerService.seek(positionMs);

  // ─── State streams ───────────────────────────────────────────────

  @override
  Stream<String> get currentSurahIdStream =>
      audioPlayerService.currentSurahIdStream;

  @override
  Stream<int> get currentPositionStream =>
      audioPlayerService.currentPositionStream;

  @override
  Stream<PlayerState> get playerStateStream =>
      audioPlayerService.playerStateStream;

  // ─── Persistence ─────────────────────────────────────────────────

  @override
  Future<PlayerPersistence?> getLastPlayerState() {
    return localDataSource.getLastPlayerState();
  }

  @override
  Future<void> savePlayerState(PlayerPersistence state) {
    return localDataSource.savePlayerState(state);
  }

  @override
  Future<void> clearPlayerState() {
    return localDataSource.clearPlayerState();
  }

  // ─── Lifecycle ───────────────────────────────────────────────────

  @override
  Future<void> dispose() => audioPlayerService.dispose();
}
