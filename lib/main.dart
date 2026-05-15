import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/data/data.dart' as data;
import 'src/core/core.dart' as core;
import 'src/features/features.dart';
import 'src/features/home/providers/home_state.dart';
import 'src/core/providers/service_providers.dart';
import 'src/data/services/audio_player_service_impl.dart';
import 'src/features/player/providers/current_surah_provider.dart';
import 'src/presentation/app.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        // Bookmark Service (no deps)
        bookmarkServiceProvider.overrideWith((ref) => data.BookmarkServiceImpl()),

        // Download Service (no deps)
        downloadServiceProvider.overrideWith((ref) => data.DownloadServiceImpl()),

        // Quran Repository (no deps)
        quranRepositoryProvider.overrideWith((ref) => data.QuranRepositoryImpl()),

        // Audio Player Service (no DB access — runs in background isolate)
        audioPlayerProvider.overrideWith((ref) => AudioPlayerServiceImpl.create()),

        // Home Provider - inject repository (depends on quranRepositoryProvider)
        homeProvider.overrideWith((ref) => HomeNotifier(
          ref.read<core.QuranRepository>(quranRepositoryProvider),
        )),

        // CurrentSurahProvider — inject repo + audio player
        currentSurahProvider.overrideWith((ref) {
          final repo = ref.read<core.QuranRepository>(quranRepositoryProvider);
          final audioPlayer = ref.read(audioPlayerProvider);
          return CurrentSurahNotifier(repo, audioPlayer);
        }),
      ],
      child: const QLearnerApp(),
    ),
  );
}
