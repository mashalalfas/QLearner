# Mini Player Behavior + Persistence + Cleanup

> **For Claude:** REQUIRED SUB-SKILL: Use flutter-craft:flutter-executing to implement this plan task-by-task.

**Goal:** Mini player only appears when audio is playing or paused (not stopped). State persists across app restarts like an audiobook. Smooth slide-up animation via flutter_animate. Plus DB cleanup and auto-save position.

**Architecture:** Clean Architecture with Riverpod

**Dependencies:**
```bash
flutter pub add flutter_animate
flutter pub add shared_preferences
```

---

## Domain Layer

### Task 1: PlayerPersistence Entity

**Layer:** Domain

**Files:**
- Create: `lib/features/player/domain/entities/player_persistence.dart`

**Implementation:**

```dart
/// Persisted player state for audiobook-style resume
class PlayerPersistence {
  final int? lastSurahId;
  final bool wasPlaying;
  final int positionMs;

  const PlayerPersistence({
    this.lastSurahId,
    this.wasPlaying = false,
    this.positionMs = 0,
  });

  PlayerPersistence copyWith({
    int? lastSurahId,
    bool? wasPlaying,
    int? positionMs,
  }) {
    return PlayerPersistence(
      lastSurahId: lastSurahId ?? this.lastSurahId,
      wasPlaying: wasPlaying ?? this.wasPlaying,
      positionMs: positionMs ?? this.positionMs,
    );
  }

  Map<String, dynamic> toJson() => {
        'lastSurahId': lastSurahId,
        'wasPlaying': wasPlaying,
        'positionMs': positionMs,
      };

  factory PlayerPersistence.fromJson(Map<String, dynamic> json) {
    return PlayerPersistence(
      lastSurahId: json['lastSurahId'] as int?,
      wasPlaying: json['wasPlaying'] as bool? ?? false,
      positionMs: json['positionMs'] as int? ?? 0,
    );
  }
}
```

**Verification:**

```bash
flutter analyze lib/features/player/domain/entities/player_persistence.dart
# Expected: No issues found!
```

**Commit:**

```bash
git add lib/features/player/domain/entities/player_persistence.dart
git commit -m "feat(player): add PlayerPersistence entity for audiobook-style state"
```

---

## Data Layer

### Task 2: PlayerLocalDataSource (SharedPreferences)

**Layer:** Data

**Files:**
- Create: `lib/features/player/data/datasources/player_local_datasource.dart`

**Implementation:**

```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/player_persistence.dart';

abstract class PlayerLocalDataSource {
  Future<PlayerPersistence?> getLastPlayerState();
  Future<void> savePlayerState(PlayerPersistence state);
  Future<void> clearPlayerState();
}

class PlayerLocalDataSourceImpl implements PlayerLocalDataSource {
  static const _key = 'ql_player_state';

  @override
  Future<PlayerPersistence?> getLastPlayerState() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return null;
    return PlayerPersistence.fromJson(
      Map<String, dynamic>.from(jsonDecode(json)),
    );
  }

  @override
  Future<void> savePlayerState(PlayerPersistence state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toJson()));
  }

  @override
  Future<void> clearPlayerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
```

**Note:** Add `import 'dart:convert';` at top of file.

**Verification:**

```bash
flutter analyze lib/features/player/data/datasources/player_local_datasource.dart
# Expected: No issues found!
```

**Commit:**

```bash
git add lib/features/player/data/datasources/player_local_datasource.dart
git commit -m "feat(player): add SharedPreferences local data source"
```

---

### Task 3: PlayerRepositoryImpl Persistence Methods

**Layer:** Data

**Files:**
- Modify: `lib/features/player/data/repositories/player_repository_impl.dart`
- Create: `lib/features/player/domain/repositories/player_repository.dart` (if not exists)

**Implementation:**

Add to `PlayerRepository` interface (if it doesn't exist yet, create it):

```dart
// In lib/features/player/domain/repositories/player_repository.dart
abstract class PlayerRepository {
  // ... existing methods
  
  Future<PlayerPersistence?> getLastPlayerState();
  Future<void> savePlayerState(PlayerPersistence state);
  Future<void> clearPlayerState();
}
```

Add to `PlayerRepositoryImpl`:

```dart
// In lib/features/player/data/repositories/player_repository_impl.dart
class PlayerRepositoryImpl implements PlayerRepository {
  // ... existing fields + constructor
  
  final PlayerLocalDataSource localDataSource;

  // ... existing methods

  @override
  Future<PlayerPersistence?> getLastPlayerState() {
    return localDataSource.getLastPlayerState();
  }

  @override
  Future<void> savePlayerState(PlayerPersistence state) {
    return localDataSource.savePlayerState(state);
  }

  @override
  Future<void> clearPlayerState() {
    return localDataSource.clearPlayerState();
  }
}
```

**Verification:**

```bash
flutter analyze lib/features/player/data/repositories/player_repository_impl.dart
# Expected: No issues found!
```

**Commit:**

```bash
git add lib/features/player/domain/repositories/player_repository.dart \
        lib/features/player/data/repositories/player_repository_impl.dart
git commit -m "feat(player): add persistence methods to PlayerRepository"
```

---

## Presentation Layer

### Task 4: PlayerPersistenceNotifier (Riverpod)

**Layer:** Presentation

**Files:**
- Create: `lib/features/player/providers/player_persistence_provider.dart`

**Implementation:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/player_persistence.dart';
import '../data/datasources/player_local_datasource.dart';
import '../domain/repositories/player_repository.dart';
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
```

**Verification:**

```bash
flutter analyze lib/features/player/providers/player_persistence_provider.dart
# Expected: No issues found!
```

**Commit:**

```bash
git add lib/features/player/providers/player_persistence_provider.dart
git commit -m "feat(player): add PlayerPersistenceNotifier with SharedPreferences"
```

---

### Task 5: Update _MiniPlayerBar — Conditional Visibility + Animation

**Layer:** Presentation

**Files:**
- Modify: `lib/src/features/home/screens/home_screen.dart`

**Changes:**

1. Replace the current `if (ref.watch(currentSurahProvider) != null)` condition with a check for playing/paused state
2. Add `flutter_animate` slide-up + fade-in animation
3. Keep content: surah name (Arabic + English), play/pause, thin progress bar

**Implementation:**

```dart
// In HomeScreen build method, replace the mini player section:

// Mini player bar — only shows when playing or paused
final playerStateAsync = ref.watch(playerStateProvider);
final isPlaying = playerStateAsync.value?.isPlaying ?? false;
final isPaused = playerStateAsync.value?.processingState == ProcessingState.ready 
    && !isPlaying && playerStateAsync.value?.position.inMilliseconds ?? 0 > 0;
final showMiniPlayer = isPlaying || isPaused;

if (showMiniPlayer)
  _MiniPlayerBar(
    onTap: () {
      final surahId = ref.read(currentSurahProvider)!.surahId;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlayerScreen(surahId: surahId),
        ),
      );
    },
  ),
```

Update `_MiniPlayerBar` widget to include progress bar and animation:

```dart
class _MiniPlayerBar extends ConsumerWidget {
  final VoidCallback onTap;

  const _MiniPlayerBar({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSurah = ref.watch(currentSurahProvider);
    final audioPlayer = ref.watch(audioPlayerProvider);
    final playerStateAsync = ref.watch(playerStateProvider);
    final positionAsync = ref.watch(positionProvider);

    if (currentSurah == null) return const SizedBox.shrink();

    final isPlaying = playerStateAsync.value?.isPlaying ?? false;
    final position = positionAsync.value ?? Duration.zero;
    final duration = playerStateAsync.value?.duration ?? Duration.zero;
    final progress = duration.inMilliseconds > 0 
        ? position.inMilliseconds / duration.inMilliseconds 
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        margin: EdgeInsets.only(
          left: screenPaddingH,
          right: screenPaddingH,
          bottom: MediaQuery.of(context).viewPadding.bottom + 8,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(cardBorderRadius),
          border: Border.all(
            color: AppColors.goldSoft,
            width: goldBorderWidth,
          ),
        ),
        child: Column(
          children: [
            // Thin progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.bgBase.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldStart),
              minHeight: 2,
            ),
            Expanded(
              child: Row(
                children: [
                  // Album art placeholder
                  Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.volume_up,
                      color: AppColors.bgBase,
                      size: 24,
                    ),
                  ),
                  // Surah info
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentSurah.name,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentSurah.englishName,
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Play/Pause button
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: AppColors.goldStart,
                    ),
                    onPressed: () async {
                      if (isPlaying) {
                        await audioPlayer.pause();
                      } else {
                        await audioPlayer.resume();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 100, end: 0).fadeIn();
  }
}
```

**Verification:**

```bash
flutter analyze lib/src/features/home/screens/home_screen.dart
# Expected: No issues found!
```

**Commit:**

```bash
git add lib/src/features/home/screens/home_screen.dart
git commit -m "feat(home): mini player conditional visibility + anime.js animation + progress bar"
```

---

### Task 6: Restore Player State on App Launch

**Layer:** Presentation

**Files:**
- Modify: `lib/src/core/app.dart` or main entry point
- Modify: `lib/features/player/providers/player_providers.dart` (add restoration logic)

**Implementation:**

Add a method to restore player state from persistence:

```dart
// In player_providers.dart or a new player_restoration_provider.dart
class PlayerRestorationNotifier extends StateNotifier<AsyncValue<void>> {
  final PlayerRepository _repository;
  final Ref _ref;

  PlayerRestorationNotifier(this._repository, this._ref) : super(const AsyncValue.data(null)) {
    _restore();
  }

  Future<void> _restore() async {
    try {
      final saved = await _repository.getLastPlayerState();
      if (saved == null || saved.lastSurahId == null) return;

      // Load the surah
      final surah = await _ref.read(currentSurahProvider.notifier).loadSurah(saved.lastSurahId!);
      if (surah == null) return;

      // Seek to saved position
      final audioPlayer = _ref.read(audioPlayerProvider);
      await audioPlayer.seek(Duration(milliseconds: saved.positionMs));

      // Resume if it was playing
      if (saved.wasPlaying) {
        await audioPlayer.play();
      }
    } catch (e, st) {
      // Silent fail — don't block app startup
      state = AsyncValue.error(e, st);
    }
  }
}
```

Wire it up in `main.dart` or app startup:

```dart
// In main.dart, wrap MaterialApp with providers
void main() {
  runApp(
    ProviderScope(
      child: QLearnerApp(),
    ),
  );
}

// In QLearnerApp build, ensure restoration runs on startup
Widget build(BuildContext context) {
  // Trigger restoration
  ref.read(playerRestorationProvider);
  
  // ... rest of app
}
```

**Verification:**

```bash
flutter analyze lib/features/player/providers/
# Expected: No issues found!
```

**Commit:**

```bash
git add lib/features/player/providers/player_restoration_provider.dart
git commit -m "feat(player): restore last played surah + position on app launch"
```

---

### Task 7: Auto-Save Position Every 30 Seconds

**Layer:** Presentation

**Files:**
- Modify: `lib/features/player/providers/player_providers.dart`

**Implementation:**

Add a periodic timer in `CurrentSurahNotifier` or a new `PlayerAutoSaveNotifier`:

```dart
class PlayerAutoSaveNotifier extends StateNotifier<void> {
  Timer? _timer;
  final PlayerRepository _repository;
  final Ref _ref;

  PlayerAutoSaveNotifier(this._repository, this._ref) {
    _startAutoSave();
  }

  void _startAutoSave() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final currentSurah = _ref.read(currentSurahProvider);
      final playerStateAsync = _ref.read(playerStateProvider);
      final positionAsync = _ref.read(positionProvider);

      if (currentSurah == null) return;

      final isPlaying = playerStateAsync.value?.isPlaying ?? false;
      final position = positionAsync.value ?? Duration.zero;

      final persistence = PlayerPersistence(
        lastSurahId: currentSurah.surahId,
        wasPlaying: isPlaying,
        positionMs: position.inMilliseconds,
      );

      await _repository.savePlayerState(persistence);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
```

**Verification:**

```bash
flutter analyze lib/features/player/providers/player_auto_save_provider.dart
# Expected: No issues found!
```

**Commit:**

```bash
git add lib/features/player/providers/player_auto_save_provider.dart
git commit -m "feat(player): auto-save position every 30s"
```

---

### Task 8: Save State on App Pause/Background

**Layer:** Presentation

**Files:**
- Modify: `lib/src/core/app.dart` or add AppLifecycleListener

**Implementation:**

```dart
// In QLearnerApp or a top-level widget
class _QLearnerAppState extends State<QLearnerApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Trigger immediate save
      _ref.read(playerAutoSaveProvider.notifier)._saveNow();
    }
    super.didChangeAppLifecycleState(state);
  }
}
```

**Verification:**

```bash
flutter analyze lib/src/core/app.dart
# Expected: No issues found!
```

**Commit:**

```bash
git add lib/src/core/app.dart
git commit -m "feat(core): save player state on app pause/background"
```

---

## Data Cleanup

### Task 9: DB Cleanup — Stale Positions and Orphaned Cache

**Layer:** Data

**Files:**
- Modify: `lib/src/data/services/audio_player_service_impl.dart` or relevant DB service

**Implementation:**

Add a cleanup method:

```dart
Future<void> cleanupStaleData() async {
  // Remove positions for surahs not in current library
  final allPositions = await getSavedPositions();
  final validSurahIds = await getAllSurahIds(); // from API or local DB
  
  for (final pos in allPositions) {
    if (!validSurahIds.contains(pos.surahId)) {
      await deletePosition(pos.surahId);
    }
  }

  // Remove cached audio files not referenced in positions
  final cachedFiles = await getCachedAudioFiles();
  final referencedFiles = await getReferencedAudioFiles();
  
  for (final file in cachedFiles) {
    if (!referencedFiles.contains(file)) {
      await deleteCachedFile(file);
    }
  }
}
```

Run cleanup on app startup (once, with a flag to avoid repeated runs):

```dart
// In main.dart or app startup
await audioPlayerService.cleanupStaleData();
```

**Verification:**

```bash
flutter analyze lib/src/data/services/audio_player_service_impl.dart
# Expected: No issues found!
```

**Commit:**

```bash
git add lib/src/data/services/audio_player_service_impl.dart
git commit -m "fix(data): cleanup stale positions and orphaned cache on startup"
```

---

### Task 10: Reciter Metadata Display

**Layer:** Presentation

**Files:**
- Modify: `lib/features/reciters/screens/reciters_screen.dart`
- Modify: `lib/features/player/screens/player_screen.dart`

**Implementation:**

Add reciter name display in player screen (below surah name):

```dart
// In PlayerScreen, add below surah name:
Text(
  currentReciter?.name ?? 'Default Reciter',
  style: const TextStyle(
    color: AppColors.textGray,
    fontSize: 12,
  ),
),
```

Add reciter selection in reciters screen with metadata (language, style).

**Verification:**

```bash
flutter analyze lib/features/reciters/screens/reciters_screen.dart \
               lib/features/player/screens/player_screen.dart
# Expected: No issues found!
```

**Commit:**

```bash
git add lib/features/reciters/screens/reciters_screen.dart \
        lib/features/player/screens/player_screen.dart
git commit -m "feat(reciters): display reciter metadata in player screen"
```

---

## Testing

### Task 11: Player Persistence Unit Tests

**Layer:** Test

**Files:**
- Create: `test/features/player/data/datasources/player_local_datasource_test.dart`

**Implementation:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qlearner/features/player/data/datasources/player_local_datasource.dart';
import 'package:qlearner/features/player/domain/entities/player_persistence.dart';

void main() {
  group('PlayerLocalDataSource', () {
    late PlayerLocalDataSource dataSource;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      dataSource = PlayerLocalDataSourceImpl();
    });

    test('saves and retrieves player state', () async {
      final state = PlayerPersistence(
        lastSurahId: 1,
        wasPlaying: true,
        positionMs: 45000,
      );
      await dataSource.savePlayerState(state);
      final retrieved = await dataSource.getLastPlayerState();
      expect(retrieved, equals(state));
    });

    test('returns null when no state saved', () async {
      final result = await dataSource.getLastPlayerState();
      expect(result, isNull);
    });

    test('clears saved state', () async {
      final state = PlayerPersistence(lastSurahId: 1);
      await dataSource.savePlayerState(state);
      await dataSource.clearPlayerState();
      final result = await dataSource.getLastPlayerState();
      expect(result, isNull);
    });
  });
}
```

**Verification:**

```bash
flutter test test/features/player/data/datasources/player_local_datasource_test.dart
# Expected: All tests pass
```

**Commit:**

```bash
git add test/features/player/data/datasources/player_local_datasource_test.dart
git commit -m "test(player): add PlayerLocalDataSource unit tests"
```

---

## Final Verification

### Task 12: Full Test Suite + Push

**Commands:**

```bash
# Run full analyzer
flutter analyze

# Run all tests
flutter test

# If all pass, push to GitHub
git push origin master
```

**Acceptance Criteria:**
- [ ] `flutter analyze` shows 0 errors, 0 warnings (infos OK)
- [ ] `flutter test` passes all tests
- [ ] Mini player only appears when playing or paused
- [ ] Mini player slides up with animation when audio starts
- [ ] App restart restores last played surah + state
- [ ] Position auto-saves every 30 seconds
- [ ] Position saves on app background
- [ ] DB cleanup runs on startup (removes stale entries)
- [ ] Reciter name displays in player screen

---

## Plan Summary

| Task | Layer | Files | Est. Time |
|------|-------|-------|-----------|
| 1. PlayerPersistence entity | Domain | 1 new | 5 min |
| 2. PlayerLocalDataSource | Data | 1 new | 10 min |
| 3. PlayerRepository persistence | Data | 2 modified | 10 min |
| 4. PlayerPersistenceNotifier | Presentation | 1 new | 15 min |
| 5. MiniPlayerBar update | Presentation | 1 modified | 20 min |
| 6. Restore on launch | Presentation | 2 modified | 15 min |
| 7. Auto-save 30s | Presentation | 1 new | 10 min |
| 8. Save on pause | Presentation | 1 modified | 5 min |
| 9. DB cleanup | Data | 1 modified | 15 min |
| 10. Reciter metadata | Presentation | 2 modified | 10 min |
| 11. Unit tests | Test | 1 new | 15 min |
| 12. Final verify + push | Integration | 0 | 10 min |

**Total:** ~140 minutes (2-3 hours with Army parallelization)
