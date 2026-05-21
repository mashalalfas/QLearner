import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/player_persistence.dart';
import '../domain/repositories/player_repository.dart';
import 'current_surah_provider.dart';
import '../data/datasources/player_local_datasource.dart';
import '../../../core/providers/service_providers.dart';

/// Restores the last played surah + position on app launch.
///
/// Reads persisted state from SharedPreferences via [PlayerRepository].
/// If a previous session exists, re-loads the surah, seeks to the saved
/// position, and resumes playback when it was playing.
///
/// Errors are swallowed silently — a failed restore must never block app
/// startup. The mini player will simply not appear until the user starts
/// playback manually.
class PlayerRestorationNotifier {
  final PlayerRepository _repository;
  final Ref _ref;

  PlayerRestorationNotifier(this._repository, this._ref) {
    _restore();
  }

  Future<void> _restore() async {
    try {
      final saved = await _repository.getLastPlayerState();
      if (saved == null || saved.lastSurahId == null) return;

      final surahId = saved.lastSurahId.toString();

      // Load surah (triggers audio playback internally)
      await _ref
          .read(currentSurahProvider.notifier)
          .loadSurah(surahId);

      // Small delay so the audio pipeline is ready before seeking
      await Future.delayed(const Duration(milliseconds: 500));

      // Seek to saved position
      if (saved.positionMs > 0) {
        await _repository.seek(saved.positionMs);
      }

      // Resume if it was playing when the user left
      if (saved.wasPlaying) {
        await _repository.resume();
      }
    } catch (_) {
      // Silent fail — do not block app startup
    }
  }
}

/// Triggers player state restoration on first read.
///
/// The [PlayerRestorationNotifier] runs its restore logic in its
/// constructor, so simply reading this provider is enough to kick off
/// the whole flow.  The [autoDispose] modifier means the notifier is
/// discarded when no widget is listening — this is intentional: we only
/// need it to fire once at startup.
final playerRestorationProvider = Provider<PlayerRestorationNotifier>((ref) {
  final repository = ref.watch(playerRepositoryProvider);
  return PlayerRestorationNotifier(repository, ref);
});
