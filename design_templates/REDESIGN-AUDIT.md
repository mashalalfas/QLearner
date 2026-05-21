# QLearner Codebase Audit — Current State

## 1. Project Structure

Clean Architecture layered: `core/` → `data/` → `features/` → `presentation/`

```
lib/
├── main.dart                          (entry point with ProviderScope)
├── src/
│   ├── core/                          (abstract contracts, theme, constants, utils)
│   │   ├── services/                   # Abstract service contracts
│   │   ├── theme/                      # Dignity theme (app_colors, app_spacing, app_typography)
│   │   ├── constants/                  # App constants
│   │   └── utils/                      # Utilities
│   ├── data/                          (implementations: DB, models, repos, services)
│   ├── features/                      (4 feature modules)
│   │   ├── home/                       # Surah grid + search
│   │   ├── read/                       # Verse reading screen
│   │   ├── player/                     # Audio player
│   │   ├── library/                    # Bookmarks + downloads
│   │   ├── reciters/                   # Reciter selection
│   │   └── settings/                   # Settings screen
│   └── presentation/                   (app shell, nav widget)
│       └── app.dart
└── data.dart, core.dart, features.dart  # Barrel exports
```

## 2. Current Screens & Line Counts

| Screen | File | Lines | Theme |
|--------|------|-------|-------|
| Home | `features/home/screens/home_screen.dart` | ~428 | Dignity (black/gold) |
| Player | `features/player/screens/player_screen.dart` | ~672 | Dignity (black/gold) |
| Library | `features/library/screens/library_screen.dart` | ~476 | Dignity (black/gold) |
| Reciters | `features/reciters/screens/reciters_screen.dart` | ~200 | Dignity (black/gold) |
| Read | `features/read/screens/read_screen.dart` | ~191 | Dignity (black/gold) |
| Settings | `features/settings/screens/settings_screen.dart` | ~350 | Dignity (black/gold) |
| App Shell | `presentation/app.dart` | 131 | Dignity |
| Nav Widget | `presentation/widgets/center_island_nav.dart` | ~272 | Gold island |

**Total Dart files:** 34+ files across the project.

## 3. State Management

**Riverpod** (`flutter_riverpod ^2.4.9`) — mixed patterns:
- `FutureProvider` — async data (surahs, verses, bookmarks, downloads)
- `StateNotifierProvider` — mutable home state (search, filtering)
- `StreamProvider` — audio position, playback state
- `Provider` — singleton DI (services injected via `overrideWith` in ProviderScope)
- `StateProvider` — current track info

No `riverpod_generator` / code-gen is in use.

## 4. Key Dependencies

| Category | Packages |
|----------|----------|
| State | `flutter_riverpod`, `riverpod_annotation` |
| Audio | `just_audio`, `audio_service`, `rxdart` |
| DB | `sqflite`, `path`, `path_provider` |
| Networking | `dio` |
| Quran | `quran ^1.2.0` |
| Fonts | `google_fonts` |
| Utils | `equatable` |

## 5. Theme System — Consolidated

Single source of truth: `lib/core/theme/`

| File | Purpose |
|------|---------|
| `app_colors.dart` | All color constants (black/gold palette) |
| `app_spacing.dart` | Dimensions, radii, gaps |
| `app_typography.dart` | Text styles + font families |

**No duplicate theme files.** The previous Cotton Cloud theme files (`app_theme.dart`, `cotton_cloud_theme.dart` under `lib/src/core/theme/`) are not imported by any active code.

### Active Color Tokens (Dignity)

```dart
bgBase = Color(0xFF0A0A0A)      // Page background
bgCardDark = Color(0xFF1A1A1A)   // Card background
bgCardInner = Color(0xFF141414)  // Card inner
goldStart = Color(0xFFC9A84C)    // Gold gradient start
goldEnd = Color(0xFFE8D48B)      // Gold gradient end
goldSoft = Color(0x33C9A84C)     // 19% opacity gold border
goldMuted = Color(0x99C9A84C)    // 60% opacity gold text
textWhite = Color(0xFFFFFFFF)
textGray = Color(0xFF888888)
```

### Typography

- **English:** `Plus Jakarta Sans` (fontBody)
- **Arabic:** `Noto Naskh Arabic` (fontArabic)
- Scale: 52 → 28 → 24 → 20 → 16 → 15 → 14 → 12 → 10

## 6. Navigation Structure

**Bottom nav with 4 tabs** (Home, Library, Reciters, Settings) via `BottomNav` widget with `IndexedStack` for state preservation.

- **Read screen** is pushed as a full Material route when a surah is tapped
- **Player screen** is pushed over the current context when audio starts
- No tab shows an "active" player — the mini player bar at the bottom of Home handles quick controls

## 7. Shared Widgets

| Widget | Location | Purpose |
|--------|----------|---------|
| `GlassCard` | `shared/widgets/glass_card.dart` | Gold-bordered dark card with subtle blur |
| `GoldGradientBorder` | `shared/widgets/gold_gradient_border.dart` | Custom painter for gradient borders |
| `AppBarGold` | `shared/widgets/app_bar_gold.dart` | AppBar with gold underline |
| `SearchBarGold` | `shared/widgets/search_bar_gold.dart` | Glassmorphism search input |
| `BottomNav` | `shared/widgets/bottom_nav.dart` | 4-tab navigation bar |
| `SectionHeader` | `shared/widgets/section_header.dart` | Gold section title divider |
| `SeekBarGold` | `shared/widgets/seek_bar_gold.dart` | Custom seek slider |

## 8. Audit Summary

| Category | Status |
|----------|--------|
| Theme consistency | ✅ Single source of truth in `lib/core/theme/` |
| No Cotton Cloud references | ✅ Zero remaining lavender/mint/pink/glassWhite |
| Font consistency | ✅ Plus Jakarta Sans + Noto Naskh Arabic |
| Analyzer errors | ✅ 0 errors (excluding test/widget_test.dart) |
| Code organization | ✅ Clean Architecture maintained |
| UI polish | ⚠️ PlayerScreen (672 lines) could be split |
| Tests | ⚠️ Minimal — widget_test.dart references old `MyApp` class |

---

**Total LOC:** ~3,100 across 34+ files.
**Active theme:** Dignity (black/gold) — branch `dignity-only-20260521`.
