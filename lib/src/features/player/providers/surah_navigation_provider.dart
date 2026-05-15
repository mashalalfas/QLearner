import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/surah.dart';
import '../../../core/services/quran_repository.dart';
import '../../../core/providers/service_providers.dart';

/// State for surah navigation
class SurahNavigationState {
  final List<Surah> allSurahs;
  final String? currentSurahId;
  final bool isLoading;
  final String? error;

  const SurahNavigationState({
    this.allSurahs = const [],
    this.currentSurahId,
    this.isLoading = false,
    this.error,
  });

  SurahNavigationState copyWith({
    List<Surah>? allSurahs,
    String? currentSurahId,
    bool? isLoading,
    String? error,
  }) {
    return SurahNavigationState(
      allSurahs: allSurahs ?? this.allSurahs,
      currentSurahId: currentSurahId ?? this.currentSurahId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Returns the index of the current surah in the list, or -1 if not found
  int getCurrentIndex() {
    if (currentSurahId == null) return -1;
    for (var i = 0; i < allSurahs.length; i++) {
      if (allSurahs[i].surahId == currentSurahId) return i;
    }
    return -1;
  }

  /// Whether prev navigation is possible (not at surah 1 and ID is resolved)
  bool get canGoPrev => currentSurahId != null && currentSurahId!.isNotEmpty && getCurrentIndex() > 0;

  /// Whether next navigation is possible (not at last surah and ID is resolved)
  bool get canGoNext => currentSurahId != null && currentSurahId!.isNotEmpty && getCurrentIndex() >= 0 && getCurrentIndex() < allSurahs.length - 1;
}

/// StateNotifier that manages the full surah list and current-position tracking
class SurahNavigationNotifier extends StateNotifier<SurahNavigationState> {
  final QuranRepository _repository;

  SurahNavigationNotifier(this._repository)
      : super(const SurahNavigationState());

  /// Load all 114 surahs from the repository
  Future<void> loadAllSurahs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final surahs = await _repository.getAllSurahs();
      state = state.copyWith(
        allSurahs: surahs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Set the currently-playing surah ID
  void setCurrentSurah(String surahId) {
    state = state.copyWith(currentSurahId: surahId);
  }

  /// Navigate to the previous surah; returns null if already at the first
  /// or if no surah is currently selected.
  Surah? goToPrevious() {
    if (state.currentSurahId == null || state.currentSurahId!.isEmpty) return null;
    final index = state.getCurrentIndex();
    if (index <= 0) return null;
    final prev = state.allSurahs[index - 1];
    state = state.copyWith(currentSurahId: prev.surahId);
    return prev;
  }

  /// Navigate to the next surah; returns null if already at the last
  /// or if no surah is currently selected.
  Surah? goToNext() {
    if (state.currentSurahId == null || state.currentSurahId!.isEmpty) return null;
    final index = state.getCurrentIndex();
    if (index < 0 || index >= state.allSurahs.length - 1) return null;
    final next = state.allSurahs[index + 1];
    state = state.copyWith(currentSurahId: next.surahId);
    return next;
  }
}

/// Provider: SurahNavigationNotifier backed by the app's QuranRepository
final surahNavigationProvider =
    StateNotifierProvider<SurahNavigationNotifier, SurahNavigationState>((ref) {
  final repo = ref.watch(quranRepositoryProvider);
  return SurahNavigationNotifier(repo);
});
