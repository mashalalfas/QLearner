import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_player_service.dart';
import '../services/bookmark_service.dart';
import '../services/download_service.dart';
import '../services/quran_repository.dart';
import '../../features/player/domain/repositories/player_repository.dart';

/// Provider for the Quran repository
final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  throw UnimplementedError('QuranRepository provider not configured');
});

/// Provider for the audio player service
final audioPlayerProvider = Provider<AudioPlayerService>((ref) {
  throw UnimplementedError('AudioPlayerService provider not configured');
});

/// Provider for the bookmark service
final bookmarkServiceProvider = Provider<BookmarkService>((ref) {
  throw UnimplementedError('BookmarkService provider not configured');
});

/// Provider for the download service
final downloadServiceProvider = Provider<DownloadService>((ref) {
  throw UnimplementedError('DownloadService provider not configured');
});

/// Provider for the PlayerRepository
final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  throw UnimplementedError('PlayerRepository provider not configured');
});
