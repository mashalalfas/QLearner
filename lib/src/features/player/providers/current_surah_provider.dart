import 'dart:async';
import 'package:flutter/foundation.dart';
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
  StreamSubscription<PlayerState>? _playerStateSubscription;
  Timer? _navigationTimeout;

  CurrentSurahNotifier(this._repository, this._audioPlayer) : super(null) {
    // Auto-play next surah when the current one finishes.
    _playerStateSubscription = _audioPlayer.playerStateStream.listen(
      (state) {
        if (state.state == PlayerStateEnum.completed && canGoNext && !_isNavigating) {
          playNext();
        }
        if (state.state == PlayerStateEnum.playing) {
          _cancelNavigationTimeout();
          setLoading(false);
          _isNavigating = false; // unlock navigation
        }
      },
    );
  }

  @override
  void dispose() {
    _cancelNavigationTimeout();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void setLoading(bool v) { _isLoading = v; }
  // kept for internal backward-compat
  void _setLoading(bool v) { _isLoading = v; }

  /// Guards against concurrent navigation (rapid Next/Prev taps).
  /// While true, canGoPrev/canGoNext report false to disable buttons.
  bool _isNavigating = false;
  bool get isNavigating => _isNavigating;

  /// Starts (or restarts) a 10-second safety-net timer that force-clears
  /// [_isNavigating] if the audio player never fires a `playing` event.
  /// Covers the case where the stream silently fails and the lock would
  /// otherwise remain stuck forever.
  void _resetNavigationTimeout() {
    _cancelNavigationTimeout();
    _navigationTimeout = Timer(const Duration(seconds: 10), () {
      if (_isNavigating) {
        debugPrint('[currentSurahProvider] nav timeout — force-clearing _isNavigating');
        _isNavigating = false;
        _setLoading(false);
        _navigationTimeout = null;
      }
    });
  }

  void _cancelNavigationTimeout() {
    _navigationTimeout?.cancel();
    _navigationTimeout = null;
  }

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
    _resetNavigationTimeout(); // 10 s safety net: force-unlock if audio never plays
    await ensureSurahsLoaded();
    final surah = await _repository.getSurah(surahId);
    final audioUrl = surah.audioUrl;
    if (audioUrl == null || audioUrl.isEmpty) {
      throw Exception('No audio available for surah $surahId');
    }

    state = surah;
    // Defensive check — state must be non-null after assignment
    if (state == null) {
      throw Exception('Failed to set current surah to $surahId — state is still null');
    }
    await _audioPlayer.play(audioUrl, surahName: surah.name, surahArabic: surah.name);
  }

  /// Play the next surah if possible (surahId < 114).
  /// Returns the loaded Surah on success, null if at boundary or while navigation is in-flight.
  Future<Surah?> playNext() async {
    if (_isNavigating) return null;
    await ensureSurahsLoaded();
    final idx = _currentIndex;
    if (idx < 0 || idx >= _allSurahs.length - 1) return null;

    final nextSurah = _allSurahs[idx + 1];
    _isNavigating = true;
    _setLoading(true);
    try {
      await loadSurah(nextSurah.surahId);
      return nextSurah;
    } catch (_) {
      _setLoading(false);
      _isNavigating = false;
      rethrow;
    }
    // _isNavigating = false is set by the playerStateStream listener
    // when PlayerStateEnum.playing fires — this holds the lock for the
    // full duration of the async chain (buffering + ready).
  }

  /// Play the previous surah if possible (surahId > 1).
  /// Returns the loaded Surah on success, null if at boundary or while navigation is in-flight.
  Future<Surah?> playPrevious() async {
    if (_isNavigating) return null;
    await ensureSurahsLoaded();
    final idx = _currentIndex;
    if (idx <= 0) return null;

    final prevSurah = _allSurahs[idx - 1];
    _isNavigating = true;
    _setLoading(true);
    try {
      await loadSurah(prevSurah.surahId);
      return prevSurah;
    } catch (_) {
      _setLoading(false);
      _isNavigating = false;
      rethrow;
    }
    // Same: _isNavigating cleared by playerStateStream on 'playing'.
  }

  /// Whether prev navigation is allowed (not at surah 1, a surah is selected, and no navigation in-flight).
  bool get canGoPrev => !_isNavigating && _currentIndex > 0;

  /// Whether next navigation is allowed (not at surah 114, a surah is selected, and no navigation in-flight).
  bool get canGoNext => !_isNavigating && _currentIndex >= 0 && _currentIndex < _allSurahs.length - 1;

  /// Returns the next [count] surahs from the current position (max 10).
  /// Returns empty list if at end or no surah selected.
  List<Surah> getUpcomingSurahs({int count = 10}) {
    if (_currentIndex < 0 || _currentIndex >= _allSurahs.length - 1) return [];
    final end = (_currentIndex + 1 + count).clamp(0, _allSurahs.length);
    return _allSurahs.sublist(_currentIndex + 1, end);
  }

  /// Returns the previous [count] surahs before the current position (max 10).
  /// Returns empty list if at start or no surah selected.
  List<Surah> getPreviousSurahs({int count = 10}) {
    if (_currentIndex <= 0) return [];
    final start = (_currentIndex - count).clamp(0, _currentIndex);
    return _allSurahs.sublist(start, _currentIndex);
  }

  /// Returns the surah number (1-114) of the currently selected surah, or null.
  int? get currentSurahNumber {
    final id = state?.surahId;
    return id != null ? int.tryParse(id) : null;
  }
}
