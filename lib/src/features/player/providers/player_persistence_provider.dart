import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/player_persistence.dart';
import '../domain/repositories/player_repository.dart';
import '../data/datasources/player_local_datasource.dart';
import '../../../core/providers/service_providers.dart';

/// Player persistence — audiobook-style state survival
class PlayerPersistenceNotifier extends StateNotifier<AsyncValue<PlayerPersistence?>> {
  final PlayerRepository _repository;

  PlayerPersistenceNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadState();
  }

  Future<void> _loadState() async {
    state = const AsyncValue.loading();
    try {
      final saved = await _repository.getLastPlayerState();
      state = AsyncValue.data(saved);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveState(PlayerPersistence persistence) async {
    state = const AsyncValue.loading();
    try {
      await _repository.savePlayerState(persistence);
      state = AsyncValue.data(persistence);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> clearState() async {
    state = const AsyncValue.loading();
    try {
      await _repository.clearPlayerState();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for player persistence
final playerPersistenceProvider = StateNotifierProvider<
  PlayerPersistenceNotifier,
  AsyncValue<PlayerPersistence?>
>((ref) {
  final repository = ref.watch(playerRepositoryProvider);
  return PlayerPersistenceNotifier(repository);
});
