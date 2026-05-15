# QLearner Project Setup Guide

## Project Structure Overview

This Flutter project follows Clean Architecture with Riverpod state management.

```
qlearner/
├── lib/
│   ├── main.dart                      # App entry point
│   └── src/
│       ├── core/                      # Core layer (no dependencies)
│       │   ├── theme/                 # App theme & styling
│       │   ├── services/              # Abstract service interfaces
│       │   ├── constants/             # App constants
│       │   └── utils/                 # Utility functions
│       ├── data/                      # Data layer (depends on core)
│       │   ├── models/                # Data models
│       │   ├── repositories/          # Repository implementations
│       │   ├── services/              # Service implementations
│       │   └── database/              # SQLite helper
│       ├── features/                  # Feature modules
│       │   ├── home/                  # Home screen
│       │   ├── player/                # Audio player
│       │   ├── read/                  # Reading screen
│       │   └── library/               # Bookmarks & downloads
│       └── presentation/              # UI layer (depends on features)
├── pubspec.yaml                       # Dependencies
├── analysis_options.yaml              # Linting rules
└── README.md                          # Project documentation
```

## Key Components

### Core Layer
- **Theme**: Cotton Cloud colors (Lavender, Cream, Purple accent)
- **Services**: Abstract interfaces for Audio, Bookmark, Download, Quran Repository
- **Constants**: API endpoints, DB names, UI constants
- **Utils**: Formatting helpers

### Data Layer
- **Models**: Surah, Verse, Bookmark
- **Repositories**: Implementation of QuranRepository using `quran` package
- **Services**: Concrete implementations using just_audio, sqflite, dio
- **Database**: SQLite helper for local storage

### Features
Each feature follows the same pattern:
- `screens/`: UI widgets
- `providers/`: Riverpod state providers
- `feature.dart`: Barrel export

## To Complete the App

### 1. Add Dependencies
```bash
flutter pub get
```

### 2. Add Dependencies to pubspec.yaml
The following dependencies are already declared:
- flutter_riverpod
- just_audio
- audio_service
- sqflite
- path
- dio
- quran
- equatable (for models - add this)
- path_provider (for downloads - add this)

Add equatable and path_provider:
```yaml
dependencies:
  equatable: ^2.0.5
  path_provider: ^2.1.1
```

### 3. Configure Providers
Update `lib/src/presentation/app.dart` to provide actual implementations:

```dart
// Add these provider overrides
override=[
  Provider<QuranRepository>((ref) => QuranRepositoryImpl()),
  Provider<AudioPlayerService>((ref) => AudioPlayerServiceImpl()),
  Provider<BookmarkService>((ref) => BookmarkServiceImpl()),
  Provider<DownloadService>((ref) => DownloadServiceImpl()),
]
```

### 4. Add Arabic Font
Add an Arabic font (e.g., Amiri) to `pubspec.yaml`:
```yaml
flutter:
  fonts:
    - family: Amiri
      fonts:
        - asset: fonts/Amiri-Regular.ttf
```

### 5. Update Main.dart
Ensure proper provider setup:
```dart
void main() {
  runApp(
    ProviderScope(
      child: QLearnerApp(),
      observers: [],
    ),
  );
}
```

### 6. Implement Missing Features
- Audio timing data (currently using estimates)
- Download management UI
- Search across all surahs
- Player screen integration with verses
- Bookmark note editing

### 7. Run the App
```bash
flutter run
```

## Architecture Notes

- **Clean Architecture**: Core → Data → Features → Presentation
- **Riverpod**: All state managed via providers
- **SQLite**: Local persistence for bookmarks
- **Repository Pattern**: Abstracts data sources
- **Service Interfaces**: Allows easy testing/mocking

## Testing

Unit tests should be added for:
- Repository implementations
- Service implementations
- Business logic in providers

Widget tests for:
- All screen widgets
- Custom widgets

## Next Steps

1. Add error handling throughout
2. Implement proper error boundaries
3. Add offline support
4. Implement caching strategies
5. Add analytics
6. Add user preferences
7. Implement search with full-text
8. Add reciter selection
9. Implement verse-by-verse playback
10. Add night mode

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
