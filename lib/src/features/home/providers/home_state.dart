import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/surah.dart';
import '../../../core/services/quran_repository.dart';

/// State for the home screen
class HomeState {
  final List<Surah> surahs;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final List<Surah> filteredSurahs;

  const HomeState({
    this.surahs = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.filteredSurahs = const [],
  });

  HomeState copyWith({
    List<Surah>? surahs,
    bool? isLoading,
    String? error,
    String? searchQuery,
    List<Surah>? filteredSurahs,
  }) {
    return HomeState(
      surahs: surahs ?? this.surahs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredSurahs: filteredSurahs ?? this.filteredSurahs,
    );
  }
}

/// Home screen state notifier
class HomeNotifier extends StateNotifier<HomeState> {
  final QuranRepository _repository;

  HomeNotifier(this._repository) : super(const HomeState());

  /// Load all surahs from repository
  Future<void> loadSurahs() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final surahs = await _repository.getAllSurahs();
      state = state.copyWith(
        isLoading: false,
        surahs: surahs,
        filteredSurahs: surahs,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update search query and filter surahs
  void updateSearchQuery(String query) {
    final filtered = query.isEmpty
        ? state.surahs
        : state.surahs.where((surah) {
            return surah.englishName.toLowerCase().contains(query.toLowerCase()) ||
                surah.name.contains(query) ||
                surah.englishNameTranslation.toLowerCase().contains(query.toLowerCase());
          }).toList();

    state = state.copyWith(
      searchQuery: query,
      filteredSurahs: filtered,
    );
  }
}

/// Provider for home screen state
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  // Repository will be injected via override
  throw UnimplementedError('homeProvider must be overridden with a HomeNotifier instance');
});
