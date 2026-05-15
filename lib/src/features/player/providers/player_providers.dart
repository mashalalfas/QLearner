import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audio_player_service.dart';
import '../../../core/providers/service_providers.dart';

/// Provider for current playing track info
final currentTrackProvider = StateProvider<Map<String, String>?>((ref) {
  return null;
});

/// Provider to check if audio is currently playing
final isPlayingProvider = Provider<bool>((ref) {
  final playerStateAsync = ref.watch(playerStateProvider);
  return playerStateAsync.value?.isPlaying ?? false;
});

/// Provider for the player state stream
final playerStateProvider = StreamProvider.autoDispose<PlayerState>((ref) {
  final player = ref.watch(audioPlayerProvider);
  return player.playerStateStream;
});

/// Provider for current position stream
final positionProvider = StreamProvider.autoDispose<int>((ref) {
  final player = ref.watch(audioPlayerProvider);
  return player.positionStream;
});
