# QLearner

A modern, clean-architecture Flutter app for learning and reading the Quran with audio playback, bookmarks, and downloads.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![State Management](https://img.shields.io/badge/Riverpod-2.4-green)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Features

- **Read Quran:** Browse all 114 surahs with Arabic text and English translations
- **Audio Playback:** Listen to recitations with background audio support
- **Bookmarks:** Save and organize favorite verses with notes
- **Download Manager:** Download audio files for offline listening
- **Persistent State:** Auto-resume last reading position and playback
- **Arabic Typography:** Noto Naskh Arabic font for beautiful rendering
- **Clean Architecture:** Separated layers (presentation, domain, data)

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
| Fonts | google_fonts | Noto Sans Arabic for Arabic script |

---

## Dignity Theme

QLearner uses the **Dignity** design system — premium black & gold with subtle glassmorphism.

### Design Principles

- **Dark premium palette:** Deep black (`#0A0A0A`) with charcoal card surfaces (`#1A1A1A`)
- **Gold accents:** Warm gold gradient (`#C9A84C → #E8D48B`) for borders, active states, and highlights
- **Subtle glassmorphism:** 0.5px gold hairline borders, gentle backdrop blur (4–10px)
- **Typography:** Plus Jakarta Sans (English) + Noto Naskh Arabic (Arabic script)
- **No trendy effects:** No mint, pink, lavender, or glass-white surfaces
- **Purposeful motion:** Subtle breathing animations on interactive elements only

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

### Spacing & Typography

Defined in `lib/core/theme/app_spacing.dart` and `lib/core/theme/app_typography.dart`:

```dart
// Card
cardBorderRadius = 18
cardPaddingV = 16, cardPaddingH = 12

// Grid
gridGap = 14, gridColumns = 2

// Bottom Nav
bottomNavHeight = 80
```

Text styles use `Plus Jakarta Sans` (English) and `Noto Naskh Arabic` (Arabic) with a clear hierarchy from 52px (player surah number) down to 10px (meta text).

---

## Project Structure

```
qlearner/
├── lib/
│   ├── main.dart                         # Root widget (QLearnerApp, MainNavigation)
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
│   │   │   ├── read/                     # Verse reading screen
│   │   │   ├── player/                   # Audio player
│   │   │   ├── library/                  # Bookmarks + downloads
│   │   │   ├── reciters/                 # Reciter selection
│   │   │   └── settings/                 # Settings screen
│   │   └── presentation/                 # App shell, navigation
│   │       └── app.dart
│   └── data.dart, core.dart, features.dart  # Barrel exports
├── shared/
│   └── widgets/                          # Reusable shared widgets
│       ├── glass_card.dart               # Gold-bordered glass card
│       ├── gold_gradient_border.dart     # Custom painter for gold borders
│       ├── app_bar_gold.dart             # AppBar with gold underline
│       ├── bottom_nav.dart               # 4-tab bottom navigation
│       ├── search_bar_gold.dart          # Glassmorphism search input
│       ├── section_header.dart           # Gold section divider
│       └── seek_bar_gold.dart            # Custom seek bar
├── design_templates/                     # HTML mockups and design docs
│   ├── REDESIGN-PLAN.md                  # Original Dignity plan
│   ├── REDESIGN-AUDIT.md                 # Codebase audit
│   └── template-blackgold-dignity.html   # Visual reference mockup
├── pubspec.yaml
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
cd qlearner
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
| Cotton Cloud 2026 | Lavender/cream/mint/pink glassmorphism | **Removed** (branch: dignity-only-20260521) |
| **Dignity** | **Black/gold premium** | **Active** (master) |

The Dignity theme replaced all Cotton Cloud references — no lavender, mint, pink, or glass-white surfaces remain in the active codebase.

---

## License

MIT
