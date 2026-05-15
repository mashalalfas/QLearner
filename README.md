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
- **Arabic Typography:** Noto Sans Arabic font for beautiful rendering
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

## Cotton Glass 2026 Design

QLearner now features the **Cotton Glass** design system — a soft, organic evolution of glassmorphism with the Cotton Cloud palette.

### Design Principles

- **Glassmorphism 2.0:** Frosted blur (`backdropFilter`), translucent surfaces (60–70% opacity), hairline borders.
- **Cotton Cloud Palette:** Lavender `#C4B5D6`, Cream `#FFFDF5`, Mint `#B8E4D1`, Pink `#FFD6E0`, Accent `#8B7BB8`.
- **Organic Shapes:** Blob-like player art with gentle morph animation (10s cycle).
- **Bento Grid Home:** 3-column modular cards, staggered entrance, dense yet breathable.
- **Immersive Player:** Glass control bar, organic art, breathing glow effects.
- **Compact Library:** Glass list items with tight spacing and icons.
- **Floating Island Nav:** Mint-glass circular FAB with breathing glow.
- **Slow, Calm Animations:** 3–10s durations, cubic-bezier easing.

### Widgets

**GlassCard** (`lib/src/shared/widgets/glass_card.dart`)

Reusable glassmorphic container with frosted blur, subtle shadow, and optional border. Usage:

```dart
GlassCard(
  borderRadius: 20,
  padding: EdgeInsets.all(16),
  child: YourContent(),
  onTap: () {},
);
```

**GlassListTile** — compact variant for list items.

### Theme

All colors and glass surfaces are defined in `lib/src/core/theme/cotton_cloud_theme.dart`. Use `CottonCloudTheme` constants for colors (e.g. `CottonCloudTheme.lavender`, `CottonCloudTheme.glassWhite`, `CottonCloudTheme.mintGradient`).

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
│   │   │   ├── theme/                    # App theme
│   │   │   │   └── app_theme.dart
│   │   │   └── utils/                    # Utilities
│   │   ├── data/                         # Data layer
│   │   │   ├── models/                   # Data models
│   │   │   │   ├── surah.dart
│   │   │   │   ├── verse.dart
│   │   │   │   └── bookmark.dart
│   │   │   ├── repositories/             # Repository implementations
│   │   │   │   ├── quran_repository_impl.dart
│   │   │   │   └── bookmark_service_impl.dart
│   │   │   ├── services/                 # Service implementations
│   │   │   │   ├── audio_player_service_impl.dart
│   │   │   │   └── download_service_impl.dart
│   │   │   └── database/
│   │   │       └── local_database_helper.dart
│   │   ├── features/                     # Feature modules (UI + state)
│   │   │   ├── home/
│   │   │   │   ├── screens/home_screen.dart
│   │   │   │   ├── providers/home_providers.dart
│   │   │   │   ├── providers/home_state.dart
│   │   │   │   └── widgets/surah_card.dart
│   │   │   ├── read/
│   │   │   │   ├── screens/read_screen.dart
│   │   │   │   └── providers/read_providers.dart
│   │   │   ├── player/
│   │   │   │   ├── screens/player_screen.dart
│   │   │   │   └── providers/player_providers.dart
│   │   │   └── library/
│   │   │       ├── screens/library_screen.dart
│   │   │       └── providers/library_providers.dart
│   │   └── presentation/
│   │       └── app.dart                  # Entry point + ProviderScope overrides
│   └── data.dart, core.dart, features.dart  # Barrel exports
├── pubspec.yaml
├── INTEGRATION.md                       # Integration documentation
└── README.md                            # This file
```

---

## Prerequisites

- **Flutter SDK:** >=3.0.0 <4.0.0
- **Dart SDK:** Comes with Flutter
- **Android Studio / VS Code:** With Flutter & Dart plugins
- **Android device/emulator** or **iOS simulator** (iOS support may require additional setup)

---

## Getting Started

### 1. Clone & Navigate

```bash
cd qlearner
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Check Flutter Environment

```bash
flutter doctor
```

Resolve any issues (especially Android toolchain, VS Code/Android Studio plugin).

---

## Running the App

### Development Mode (Debug)

```bash
flutter run
```

Or use your IDE's Run button.

**Hot Reload:** Press `r` in terminal or use IDE hot reload button.

### Release Mode (Local Build)

```bash
flutter build apk --release
```

Then install on device:

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

*(Ensure USB debugging enabled and device authorized)*

---

## Configuration

### Arabic Font

The app uses **Noto Sans Arabic** via `google_fonts` package — no additional setup required. Fonts are downloaded automatically on first run (requires internet). For offline use, pre-cache fonts by adding them as assets (optional).

### Audio Sources

- **Quran audio:** Archive.org (`https://archive.org/download/Quran_With_English_Translation/`)
- **Streaming:** Direct MP3 streaming with just_audio
- **Downloads:** Saved to `appDocumentsDirectory/downloads/` via Dio

### Database

SQLite database (`qlearner.db`) created automatically at:
- Android: `/data/data/com.example.qlearner/databases/qlearner.db`
- iOS: `.../Documents/qlearner.db`

Tables: `surahs`, `verses`, `bookmarks`, `playback_positions`

---

## Build Variants

| Variant | Command | Use Case |
|---------|---------|----------|
| Debug | `flutter run` or `flutter build apk --debug` | Development, hot reload |
| Profile | `flutter build apk --profile` | Performance testing |
| Release | `flutter build apk --release` | Distribution (Play Store) |

---

## Publishing to Google Play

### 1. App Signing

Create a keystore (once):

```bash
keytool -genkey -v -keystore ~/qlearner.keystore \
  -alias qlearner_key -keyalg RSA -keysize 2048 -validity 10000
```

Add `android/key.properties` (gitignored):

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=qlearner_key
storeFile=../qlearner.keystore
```

Update `android/app/build.gradle` — signing already configured by default in Flutter template; just ensure `signingConfigs.release` points to `key.properties`.

### 2. Build Release APK/AAB

```bash
flutter build appbundle --release
# or for APK:
flutter build apk --release
```

Artifacts:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### 3. Upload to Play Console

- Create app in [Google Play Console](https://play.google.com/console)
- Upload AAB (recommended) or APK
- Fill store listing, content rating, pricing
- Rollout to production or testing tracks

---

## Testing

### Unit Tests

```bash
flutter test
```

### Widget Tests

```bash
flutter test --platform=android
```

*(Add tests as needed — currently minimal)*

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `path_provider` errors on iOS | Add `ios/Runner/Info.plist` entries for file access (usually not needed) |
| Audio not playing | Check device volume, verify `just_audio` permissions (Android: none; iOS: add `audio` background mode) |
| Fonts not loading | Ensure internet on first run (google_fonts downloads fonts); or bundle fonts as assets |
| Database errors | Uninstall and reinstall app to reset DB (data loss) |
| Provider overrides not applied | Ensure `app.dart` is the entry point (it is) |

### Logs

```bash
flutter logs
```

Filter by tag:
```bash
flutter logs --clear
flutter run | grep "QLearner"
```

---

## Architecture Notes

### Clean Architecture Layers

1. **Presentation** (`lib/src/presentation/`, `features/`)
   - UI widgets, Riverpod providers, state notifiers
   - No business logic — delegates to domain

2. **Domain** (`lib/src/core/`)
   - Abstract service contracts (interfaces)
   - Business logic boundaries

3. **Data** (`lib/src/data/`)
   - Repository implementations
   - Service implementations (audio, download, bookmark)
   - Local database (SQLite)
   - Network calls (Dio)

### Dependency Flow

```
UI (ConsumerWidget) → Provider (StateNotifier/Stream) → Repository/Service → Database/Network
```

All dependencies are **inverted** via interfaces — concrete implementations provided by `ProviderScope` overrides at app startup.

---

## Contributing

This is a personal project. For questions or suggestions, reach out to the maintainer.

---

## License

MIT License — see LICENSE file (if added).

---

## Acknowledgments

- **quran** package for Arabic text and translations
- **just_audio** and **audio_service** for robust audio playback
- **Google Fonts** for Noto Sans Arabic
- **Riverpod** for elegant state management

---

*Built with ❤️ and Flutter*
