import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/player/providers/player_persistence_provider.dart';
import '../features/player/providers/current_surah_provider.dart';
import '../core/providers/service_providers.dart';
import '../core/services/audio_player_service.dart';

/// Restores the last played surah and playback state when the app launches.
/// Provides a provider that triggers restoration on first read.
class PlayerRestorationNotifier extends StateNotifier<void> {
  final PlayerRepository _repository;
  final Ref _ref;

  PlayerRestorationNotifier(this._repository, this._ref) {
    _restore();
  }

  Future<void> _restore() async {
    try {
      final saved = await _repository.getLastPlayerState();
      if (saved == null || saved.lastSurahId == null) return;

      // Load the surah
      final surah = await _ref.read(currentSurahProvider.notifier).loadSurah(saved.lastSurahId!);
      if (surah == null) return;

      // Seek to saved position (delay to allow audio to initialize)
      await Future.delayed(const Duration(milliseconds: 500));
      final audioPlayer = _ref.read(audioPlayerProvider);
      await audioPlayer.seek(saved.positionMs);

      // Resume if it was playing
      if (saved.wasPlaying) {
        await audioPlayer.play();
      }
    } catch (e) {
      // Silent fail — don't block app startup
    }
  }
}

/// Provider that triggers restoration on app startup
final playerRestorationProvider = Provider<PlayerRestorationNotifier>((ref) {
  final repository = ref.watch(playerRepositoryProvider);
  return PlayerRestorationNotifier(repository, ref);
});
