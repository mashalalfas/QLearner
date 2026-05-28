# QuranAudio

A modern, clean-architecture Flutter app for listening and reading the Quran with audio playback, multiple reciters, bookmarks, and offline downloads.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![State Management](https://img.shields.io/badge/Riverpod-2.4-green)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Features

### Phase 2 (2026-05-26) — Reciters, Premium Gating, Downloads, Settings

- **Multiple Reciters (12+1):** Switch between Mishary Al-Afasy, Abdul Basit, Al-Minshawi, Al-Husary, Saad Al-Ghamdi, Yasser Al-Dosari, Saud Al-Shuraim, As-Sudais, Hani Ar-Rifai, Maher Al-Muaiqly, Abdullah Basfar, and more
- **AllahsWord Premium Gating:** AllahsWord (English translation) reciter is code-gated as `isPremium` — requires unlock flag; playback blocked without it
- **Library Hub:** Central screen combining Downloads (grouped by reciter, play/delete), Bookmarks (grouped by surah, tap to verse), Recents (last 50), and Storage card (real disk usage)
- **Dedicated Downloads Tab:** Full downloads list with progress bars, grouped by reciter, offline play, and delete
- **Auto-Download:** Played surahs automatically cached offline (fire-and-forget in `loadSurah()`)
- **Large File Guard:** >40MB download prompt before downloading over mobile data
- **Profile/Settings:** Profile form with email display, Save button, reciter preference dropdown synced with reciters system, audio quality placeholder
- **Reciter-Aware URLs:** Audio URLs resolved per reciter; download filenames scoped as `{reciterId}_{surahNumber}.mp3`
- **Persistent Reciter Preference:** Selected reciter stored in SharedPreferences

### Core (Established)

- **Read Quran:** Browse all 114 surahs with Arabic text and English translations
- **Audio Playback:** Background audio support, speed control (0.5x–2.0x), seek, next/prev surah
- **Bookmarks:** Save and organize favorite verses with notes, navigate from library
- **Download Manager:** Download audio files for offline listening with progress tracking
- **Persistent State:** Auto-resume last reading position and playback
- **Arabic Typography:** Noto Naskh Arabic font for beautiful rendering
- **Dignity Theme:** Premium black & gold design system with Lottie animations

---

## Tech Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| UI | Flutter + Material 3 | Cross-platform mobile UI |
| State Management | Riverpod + StateNotifier | Reactive state with DI |
| Audio | just_audio + audio_service | Background playback, notifications |
| Database | sqflite (SQLite) | Local storage for bookmarks & positions |
| Networking | dio | HTTP downloads |
| Quran Data | quran package | Arabic text & translations |
| Animations | Lottie + flutter_animate | Premium motion design |
| Fonts | google_fonts | Noto Sans Arabic for Arabic script |

---

## Dignity Theme

QuranAudio uses the **Dignity** design system — premium black & gold with subtle glassmorphism.

### Design Principles

- **Dark premium palette:** Deep black (`#0A0A0A`) with charcoal card surfaces (`#1A1A1A`)
- **Gold accents:** Warm gold gradient (`#C9A84C → #E8D48B`) for borders, active states, and highlights
- **Subtle glassmorphism:** 0.5px gold hairline borders, gentle backdrop blur (4–10px)
- **Typography:** Plus Jakarta Sans (English) + Noto Naskh Arabic (Arabic script)
- **No trendy effects:** No mint, pink, lavender, or glass-white surfaces
- **Purposeful motion:** Lottie animations + micro-interactions with haptic feedback

### Color Tokens

All colors defined in `lib/core/theme/app_colors.dart`:

```dart
// Backgrounds
static const Color bgBase = Color(0xFF0A0A0A);      // Page background
static const Color bgCardDark = Color(0xFF1A1A1A);   // Card background
static const Color bgCardInner = Color(0xFF141414);  // Card inner

// Gold palette
static const Color goldStart = Color(0xFFC9A84C);    // Gold gradient start
static const Color goldEnd = Color(0xFFE8D48B);      // Gold gradient end
static const Color goldSoft = Color(0x33C9A84C);     // 19% opacity gold border
static const Color goldMuted = Color(0x99C9A84C);    // 60% opacity gold text

// Text
static const Color textWhite = Color(0xFFFFFFFF);
static const Color textGray = Color(0xFF888888);

// Gradients
static const LinearGradient goldGradient = LinearGradient(
  colors: [goldStart, goldEnd], begin: Alignment.topLeft, end: Alignment.bottomRight,
);
static const LinearGradient cardGradient = LinearGradient(
  colors: [bgCardDark, bgCardInner], begin: Alignment.topCenter, end: Alignment.bottomCenter,
);
```

---

## Project Structure

```
quranaudio/
├── lib/
│   ├── main.dart                         # Root widget (QuranAudioApp, MainNavigation)
│   ├── src/
│   │   ├── core/                         # Core domain layer
│   │   │   ├── services/                 # Abstract service contracts
│   │   │   │   ├── audio_player_service.dart
│   │   │   │   ├── bookmark_service.dart
│   │   │   │   ├── download_service.dart
│   │   │   │   └── quran_repository.dart
│   │   │   ├── theme/                    # Dignity theme tokens
│   │   │   │   ├── app_colors.dart
│   │   │   │   ├── app_spacing.dart
│   │   │   │   └── app_typography.dart
│   │   │   ├── constants/                # App constants
│   │   │   └── utils/                    # Utilities
│   │   ├── data/                         # Data layer
│   │   │   ├── models/                   # Data models (surah, verse, bookmark)
│   │   │   ├── repositories/             # Repository implementations
│   │   │   ├── services/                 # Service implementations
│   │   │   └── database/                 # SQLite helper
│   │   ├── features/                     # Feature modules (UI + state)
│   │   │   ├── home/                     # Surah grid + search
│   │   │   ├── read/                     # Verse reading screen with bookmark per verse
│   │   │   ├── player/                   # Audio player
│   │   │   ├── library/                  # Bookmarks + downloads
│   │   │   ├── downloads/                # Dedicated Downloads tab
│   │   │   ├── reciters/                 # Reciter selection + premium gating
│   │   │   └── settings/                 # Profile, reciter pref, audio quality
│   │   └── presentation/                 # App shell, navigation (5-tab bottom nav)
│   │       └── app.dart
│   └── data.dart, core.dart, features.dart  # Barrel exports
├── shared/
│   └── widgets/                          # Reusable shared widgets
│       ├── glass_card.dart               # Gold-bordered glass card
│       ├── gold_gradient_border.dart     # Custom painter for gold borders
│       ├── app_bar_gold.dart             # AppBar with gold underline
│       ├── bottom_nav.dart               # 5-tab bottom navigation
│       ├── search_bar_gold.dart          # Glassmorphism search input
│       ├── section_header.dart           # Gold section divider
│       └── seek_bar_gold.dart            # Custom seek bar
├── pubspec.yaml
├── FEATURES.md
├── README.md
├── SETUP.md
└── INTEGRATION.md
```

---

## Getting Started

### Prerequisites

- Flutter SDK >= 3.0.0 < 4.0.0
- Dart SDK (bundled with Flutter)
- Android Studio / VS Code with Flutter & Dart plugins
- Android device/emulator or iOS simulator

### Install & Run

```bash
cd quranaudio
flutter pub get
flutter run
```

### Build Release

```bash
flutter build apk --release
# Artifact: build/app/outputs/flutter-apk/app-release.apk
```

---

## Architecture

Clean Architecture with Riverpod:

```
UI (ConsumerWidget)
  → Provider (StateNotifier / StreamProvider / FutureProvider)
    → Repository / Service (abstract contracts in core/)
      → Database (sqflite) / Network (dio) / Audio (just_audio)
```

All concrete implementations are injected via `ProviderScope` overrides in `app.dart`.

---

## Design System Evolution

| Version | Theme | Status |
|---------|-------|--------|
| Cotton Cloud 2026 | Lavender/cream/mint/pink glassmorphism | **Removed** |
| **Dignity** | **Black/gold premium** | **Active** (master) |

---

## Progress

See `FEATURES.md` for detailed feature documentation and `docs/plans/` for design plans.

---

## License

MIT
