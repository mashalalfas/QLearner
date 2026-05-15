# QLearner Codebase Audit — Redesign Readiness

## 1. Project Structure

Clean Architecture layered: `core/` → `data/` → `features/` → `presentation/`

```
lib/
├── main.dart                          (entry point with ProviderScope)
├── src/
│   ├── core/                          (abstract contracts, theme, constants, utils)
│   ├── data/                          (implementations: DB, models, repos, services)
│   ├── features/                      (4 feature modules)
│   ├── presentation/                  (app shell, nav widget)
│   └── shared/widgets/                (shared glass_card.dart)
```

## 2. Current Screens & Line Counts

| Screen | File | Lines | Role |
|--------|------|-------|------|
| Home | `features/home/screens/home_screen.dart` | 428 | Surah listing with search, bento grid |
| Player | `features/player/screens/player_screen.dart` | 672 | Immersive audio player (largest file) |
| Library | `features/library/screens/library_screen.dart` | 476 | Bookmarks + Downloads tabs |
| Read | `features/read/screens/read_screen.dart` | 191 | Verse display with translation |
| App Shell | `presentation/app.dart` | 131 | Bottom nav + IndexedStack |
| Nav Widget | `presentation/widgets/center_island_nav.dart` | 272 | Floating mint island bottom bar |

**Total Dart files:** 34 files across the project.

## 3. State Management

**Riverpod** (`flutter_riverpod ^2.4.9`) — mixed patterns:
- `FutureProvider` — async data (surahs, verses, bookmarks, downloads)
- `StateNotifierProvider` — mutable home state (search, filtering)
- `StreamProvider` — audio position, playback state
- `Provider` — singleton DI (services injected via `overrideWith` in ProviderScope)
- `StateProvider` — current track info

No `riverpod_generator` / code-gen is actually in use yet despite the dependency.

## 4. Key Dependencies

- **State:** `flutter_riverpod`, `riverpod_annotation`
- **Audio:** `just_audio`, `audio_service`, `rxdart`
- **DB:** `sqflite`, `path`, `path_provider`
- **Networking:** `dio`
- **Quran:** `quran ^1.2.0`
- **Fonts:** `google_fonts`
- **Utils:** `equatable`

## 5. Theme / Color System

Two coexisting theme files — **needs consolidation**:

| File | Lines | Notes |
|------|-------|-------|
| `core/theme/app_theme.dart` | 126 | Original "Cotton Cloud" — lavender/cream/purple palette |
| `core/theme/cotton_cloud_theme.dart` | 376 | Updated "Cotton Cloud 2026" — adds mint, pink, glass effects, extended palette |

Mixed imports: `home_screen.dart` and `library_screen.dart` use `CottonCloudTheme`; `surah_card.dart` and `read_screen.dart` use `AppTheme`.

## 6. Navigation Structure

**Bottom nav with 3 tabs** (Home, Player, Library) via `CenterIslandNav` — a glassmorphic floating island FAB on a glass bar.

- `IndexedStack` preserves tab state
- **Read screen** is pushed as a full route (not a nav tab) when tapping a surah
- Player tab shows a `PlaceholderPlayerScreen` when idle; `PlayerScreen` is pushed over top when actively playing

## 7. Files Requiring Major Redesign

1. **`presentation/app.dart`** (131 lines) — Navigation shell, override wiring
2. **`presentation/widgets/center_island_nav.dart`** (272 lines) — Bottom nav UI
3. **`features/home/screens/home_screen.dart`** (428 lines) — Main surah grid
4. **`features/player/screens/player_screen.dart`** (672 lines) — Full player UI
5. **`features/library/screens/library_screen.dart`** (476 lines) — Bookmarks/downloads
6. **`features/read/screens/read_screen.dart`** (191 lines) — Verse reading page
7. **`shared/widgets/glass_card.dart`** — Shared glassmorphic card widget
8. **Both theme files** — Consolidate into `cotton_cloud_theme.dart` as single source of truth

---

**Total Dart LOC:** ~3,100 across 34 files. Redesign touches ~80% of UI files while the data/core layers are stable.
