# QuranAudio Feature Documentation

## Features Overview

### 1. Home Feature (`lib/src/features/home/`)
**Purpose**: Display all Quran surahs in an explorable grid

#### Components:
- `screens/home_screen.dart`: Main home screen with search, surah grid, gold border painter
- `widgets/surah_card.dart`: Individual surah card widget (Dignity style)
- `providers/home_providers.dart`: Riverpod providers for surah data
- `providers/home_state.dart`: Home screen state management

#### Features:
- Grid of all 114 surahs with Arabic name + English translation
- Search by English name, Arabic name, or meaning
- Loading and error states
- Tap to navigate to surah details / player
- Gold-themed shimmer loading skeleton

---

### 2. Read Feature (`lib/src/features/read/`)
**Purpose**: Display verses of a surah for reading

#### Components:
- `screens/read_screen.dart`: Displays verses with Arabic + translation
- `providers/read_providers.dart`: Providers for verse data + bookmark state per verse

#### Features:
- Arabic text display (Noto Naskh Arabic font)
- English translation below each verse
- **Bookmark toggle per verse** — tap icon to add/remove bookmark
- Individual verse audio play button
- Curtain route transition from home

---

### 3. Player Feature (`lib/src/features/player/`)
**Purpose**: Full audio playback controls

#### Components:
- `screens/player_screen.dart`: Full-screen player with controls
- `providers/player_providers.dart`: Player state providers
- `providers/current_surah_provider.dart`: Surah navigation + _isNavigating lock management
- `providers/surah_navigation_provider.dart`: Next/prev surah logic
- `providers/player_auto_save_provider.dart`: Position save on pause
- `providers/player_persistence_provider.dart`: Playback state persistence
- `providers/player_restoration_provider.dart`: Session restoration

#### Features:
- Play/Pause/Stop controls
- Seek forward/backward (±5s, ±10s)
- Playback speed control (0.5x - 2.0x)
- Position and duration display
- Next/Previous surah navigation
- Repeat mode (1, all, shuffle)
- **Bookmark from player** — save current verse as bookmark
- Auto-resume last position
- Background audio via `audio_service`
- Lottie loading animation during buffering

---

### 4. Library Feature (`lib/src/features/library/`)
**Purpose**: Central hub for bookmarks, downloads, and recents

#### Components:
- `screens/library_screen.dart`: Library with Downloads + Bookmarks + Storage + Recents sections
- `providers/library_providers.dart`: Downloads, bookmarks, recents, storage providers

#### Features:
- **Downloads section** — view all downloaded surahs with play button
- **Bookmarks section** — saved verses grouped by surah, tap to navigate to exact verse
- **Recents section** — last 50 played surahs (SharedPreferences)
- **Storage card** — real disk usage computed from download files
- `_onPlay` wired to `currentSurahProvider.loadSurah()`

---

### 5. Downloads Feature (`lib/src/features/downloads/`)
**Purpose**: Dedicated Downloads tab showing all downloaded surahs

#### Components:
- `screens/downloads_screen.dart`: Full downloads list with status
- `widgets/download_tile.dart`: Individual download item with progress bar

#### Features:
- List all downloaded surahs grouped by reciter
- **Download progress bars** for in-flight downloads
- Play downloaded surahs offline
- **Large file guard** — prompt if surah >40MB before downloading
- **Auto-download** — played surahs auto-cached to downloads
- Delete downloaded files

---

### 6. Reciters Feature (`lib/src/features/reciters/`)
**Purpose**: Switch between available reciters

#### Components:
- `screens/reciters_screen.dart`: Reciter list with selection
- `providers/reciters_providers.dart`: Reciter data + selected reciter state

#### Features:
- **Mishary Al-Afasy** (default) — primary reciter
- **AllahsWord (English)** — Quran with English translation audio (**PREMIUM** — code-gated)
- Reciter-aware URL resolution for audio playback
- Reciter-scoped download filenames: `{reciterId}_{surahNumber}.mp3`
- Selection persisted in SharedPreferences

---

### 7. Settings Feature (`lib/src/features/settings/`)
**Purpose**: User profile and app preferences

#### Components:
- `screens/settings_screen.dart`: Profile + preferences form

#### Features:
- Email display with **Save button**
- **Reciter preference** — dropdown synced with reciters system
- Audio quality placeholder (for future implementation)
- Theme is Dignity (black/gold) — fixed

---

## Recent Bug Fixes (2026-05-26)

| Bug | Status | Fix |
|-----|--------|-----|
| Nav/control buttons unresponsive | ✅ Fixed | `_isNavigating` lock now handles error/idle/buffering states; double-push guard in home; play guard for unloaded audio |
| Bookmarks not working | ✅ Fixed | `verseId:1` hardcode replaced with actual verse position; per-verse bookmark toggle in read_screen; library tap navigates to verse |
| Animation flickering | ✅ Fixed | Shared shimmer controller (InheritedWidget); merged curtain route transitions; `Rect.largest` → `Rect.fromLTWH` in GoldBorderPainter |

---

## Phase 2 Feature Documentation

### 8. Reciters Feature (`lib/src/features/reciters/`)
**Purpose**: Allow users to switch between multiple reciters for Quran audio playback

#### Components:
- `screens/reciters_screen.dart`: Reciter list with gold-underline title, subtitles, and selection cards
- `providers/reciters_providers.dart`: Reciter data models, premium gating, selection persistence

#### Features:
- **12 Arabic reciters** — Mishary Al-Afasy, Abdul Basit, Al-Minshawi, Al-Husary, Saad Al-Ghamdi, Yasser Al-Dosari, Saud Al-Shuraim, As-Sudais, Hani Ar-Rifai, Maher Al-Muaiqly, Abdullah Basfar, plus more
- **AllahsWord (English) PREMIUM** — Quran with English translation audio; flagged `isPremium: true`
- **Premium code gating** — `isPremiumUnlockedProvider` backed by SharedPreferences; PlayerScreen checks `isPremiumReciter && !isUnlocked` before playback
- **Reciter-aware URLs** — `allahsword_english` uses `getAllahsWordSlug()` URL scheme; other reciters use `{surahNumber.padLeft(3, "0")}.mp3`
- **Reciter-scoped downloads** — filenames: `{reciterId}_{surahNumber}.mp3` to avoid conflicts
- **Selection persistence** — `selectedReciterIdProvider` stores in SharedPreferences

### 9. Downloads Feature (`lib/src/features/downloads/`)
**Purpose**: Dedicated tab for managing downloaded surahs with offline playback

#### Components:
- `screens/downloads_screen.dart`: Full-screen downloads list grouped by reciter
- `widgets/large_download_dialog.dart`: >40MB confirmation dialog

#### Features:
- **Downloads list** — All downloaded files listed with play/delete actions
- **Progress bars** — In-flight download progress shown in UI
- **Group by reciter** — Downloads grouped and labeled by reciter ID
- **Group empty states** — Gold-themed empty state with download icon and helper text
- **Auto-download** — Played surahs automatically cached (fire-and-forget in `loadSurah()`)
- **Large file guard** — `largeDownloadThresholdBytes = 40 * 1024 * 1024`; prompts user before downloading >40MB over mobile data

### 10. Library Feature (`lib/src/features/library/`)
**Purpose**: Central hub for bookmarks, downloads, recents, and storage

#### Components:
- `screens/library_screen.dart`: Library with Downloads, Bookmarks, Recents, Storage sections
- `providers/library_providers.dart`: Downloads, bookmarks, recents, storage providers

#### Features:
- **Downloads section** — View all downloaded surahs with play button
- **Bookmarks section** — Saved verses grouped by surah; tap navigates to exact verse
- **Recents section** — Last 50 played surahs via SharedPreferences; most-recent-first
- **Storage card** — Real disk usage computed from download file sizes
- `_onPlay` wired to `currentSurahProvider.loadSurah()`

### 11. Settings Feature (`lib/src/features/settings/`)
**Purpose**: User profile and app preferences

#### Components:
- `screens/settings_screen.dart`: Profile form with Save button
- `providers/` — Settings state managed via `SettingsModel extends ChangeNotifier`

#### Features:
- **Profile section** — Display name and email with **Save button**
- **Reciter preference** — Dropdown populated from `reciterOptions` (12 Arabic reciters + AllahsWord), syncs with `selectedReciterIdProvider`
- **Audio quality** — Dropdown placeholder for future implementation (Auto, Low, Medium, High)
- **Auto-play next toggle** — Persisted switch for auto-advancing surahs
- **Playback speed** — Slider (0.5x–2.0x) persisted to SharedPreferences
- **Theme** — Dignity black/gold (fixed, non-configurable)

---

## Planned Features (Future)

| Task | Effort | Status |
|------|--------|--------|
| T8: Lottie Animation Overhaul | L | 🔜 Planned |
| Info lint cleanup (~28 suggestions) | S | 🔜 Future |
| Real reciter audio URLs for all 12 reciters | M | 🔜 Future |
