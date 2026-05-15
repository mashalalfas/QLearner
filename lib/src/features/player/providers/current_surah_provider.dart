import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/surah.dart';
import '../../../core/services/quran_repository.dart';
import '../../../core/services/audio_player_service.dart';
import '../../../core/providers/service_providers.dart';

/// Single source of truth for "what surah is currently playing".
/// Provider exposes the current Surah? and manages audio playback for navigation.
final currentSurahProvider =
    StateNotifierProvider<CurrentSurahNotifier, Surah?>((ref) {
  final repo = ref.watch(quranRepositoryProvider);
  final audioPlayer = ref.watch(audioPlayerProvider);
  return CurrentSurahNotifier(repo, audioPlayer);
});

/// StateNotifier that owns:
/// - The currently playing Surah? (state)
/// - The full surah list (loaded once, kept in memory)
/// - Audio playback orchestration
class CurrentSurahNotifier extends StateNotifier<Surah?> {
  final QuranRepository _repository;
  final AudioPlayerService _audioPlayer;
  List<Surah> _allSurahs = [];

  CurrentSurahNotifier(this._repository, this._audioPlayer) : super(null);

  /// Initializes the notifier by loading all 114 surahs.
  /// Safe to call multiple times (no-op after first).
  Future<void> ensureSurahsLoaded() async {
    if (_allSurahs.isNotEmpty) return;
    _allSurahs = await _repository.getAllSurahs();
  }

  /// The canonical index of the currently playing surah in [_allSurahs],
  /// or -1 if none is selected.
  int get _currentIndex {
    final id = state?.surahId;
    if (id == null) return -1;
    for (var i = 0; i < _allSurahs.length; i++) {
      if (_allSurahs[i].surahId == id) return i;
    }
    return -1;
  }

  /// Load a surah and begin playback. This is the ONLY public method
  /// for changing the current surah.
  /// - Fetches the full Surah object (ensures audioUrl is present).
  /// - Updates state (triggers UI rebuild via provider watch).
  /// - Plays audio.
  Future<void> loadSurah(String surahId) async {
    await ensureSurahsLoaded();

    final surah = await _repository.getSurah(surahId);
    final audioUrl = surah.audioUrl;
    if (audioUrl == null || audioUrl.isEmpty) {
      throw Exception('No audio available for surah $surahId');
    }

    state = surah;
    await _audioPlayer.play(audioUrl);
  }

  /// Play the next surah if possible (surahId < 114).
  /// Returns the loaded Surah on success, null if at boundary.
  Future<Surah?> playNext() async {
    await ensureSurahsLoaded();
    final idx = _currentIndex;
    if (idx < 0 || idx >= _allSurahs.length - 1) return null; // at last surah or none

    final nextSurah = _allSurahs[idx + 1];
    await loadSurah(nextSurah.surahId);
    return nextSurah;
  }

  /// Play the previous surah if possible (surahId > 1).
  /// Returns the loaded Surah on success, null if at boundary.
  Future<Surah?> playPrevious() async {
    await ensureSurahsLoaded();
    final idx = _currentIndex;
    if (idx <= 0) return null; // at first surah or none

    final prevSurah = _allSurahs[idx - 1];
    await loadSurah(prevSurah.surahId);
    return prevSurah;
  }

  /// Whether prev navigation is allowed (not at surah 1 and a surah is selected).
  bool get canGoPrev => _currentIndex > 0;

  /// Whether next navigation is allowed (not at surah 114 and a surah is selected).
  bool get canGoNext => _currentIndex >= 0 && _currentIndex < _allSurahs.length - 1;

  /// Returns the surah number (1-114) of the currently selected surah, or null.
  int? get currentSurahNumber {
    final id = state?.surahId;
    return id != null ? int.tryParse(id) : null;
  }
}
