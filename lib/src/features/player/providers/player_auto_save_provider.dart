import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/player_persistence.dart';
import '../../../core/providers/service_providers.dart';
import 'current_surah_provider.dart';
import 'player_providers.dart';

/// Auto-saves the current player position every 30 seconds and on demand.
class PlayerAutoSaveNotifier extends StateNotifier<void> {
  Timer? _timer;
  final Ref _ref;

  PlayerAutoSaveNotifier(this._ref) : super(null) {
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => saveNow());
  }

  /// Immediately persist the current surah + playback state + position.
  /// Safe to call from outside (e.g. AppLifecycleListener).
  Future<void> saveNow() async {
    final currentSurah = _ref.read(currentSurahProvider);
    if (currentSurah == null) return;

    final playerStateAsync = _ref.read(playerStateProvider);
    final positionAsync = _ref.read(positionProvider);

    final isPlaying = playerStateAsync.value?.isPlaying ?? false;
    final position = positionAsync.value ?? 0;

    final persistence = PlayerPersistence(
      lastSurahId: int.tryParse(currentSurah.surahId),
      wasPlaying: isPlaying,
      positionMs: position,
    );

    await _ref.read(playerRepositoryProvider).savePlayerState(persistence);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provider for the player auto-save notifier.
final playerAutoSaveProvider = Provider<PlayerAutoSaveNotifier>((ref) {
  return PlayerAutoSaveNotifier(ref);
});