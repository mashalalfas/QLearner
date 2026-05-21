# QLearner Feature Documentation

## Features Overview

### 1. Home Feature (`lib/src/features/home/`)
**Purpose**: Display all Quran surahs in an explorable list

#### Components:
- `screens/home_screen.dart`: Main home screen with search functionality
- `widgets/surah_card.dart`: Individual surah card widget
- `providers/home_providers.dart`: Riverpod providers for surah data
- `providers/home_state.dart`: Home screen state management

#### Features:
- List all 114 surahs
- Search by English name, Arabic name, or meaning
- Loading and error states
- Tap to navigate to surah details

### 2. Read Feature (`lib/src/features/read/`)
**Purpose**: Display verses of a surah for reading

#### Components:
- `screens/read_screen.dart`: Displays verses with Arabic and translation
- `providers/read_providers.dart`: Providers for verse data and bookmarks

#### Features:
- Arabic text display (requires Arabic font)
- English translation
- Optional transliteration
- Play button for each verse (placeholder)
- Bookmark indicator

### 3. Player Feature (`lib/src/features/player/`)
**Purpose**: Audio playback controls

#### Components:
- `screens/player_screen.dart`: Full-screen player with controls
- `providers/player_providers.dart`: Player state providers

#### Features:
- Play/Pause/Stop controls
- Seek forward/backward (10s increments)
- Playback speed control (0.5x - 2.0x)
- Position and duration display
- Album art / visual indicator

### 4. Library Feature (`lib/src/features/library/`)
**Purpose**: Manage bookmarks and downloads

#### Components:
- `screens/library_screen.dart`: Tabbed interface for bookmarks/downloads
- `providers/library_providers.dart`: Providers for library data

#### Features:
- Bookmarks tab: List all bookmarked verses with notes
- Downloads tab: List downloaded audio files
- Empty states with helpful messages

## Data Flow

```
UI (Screens)
    ↓
Providers (State)
    ↓
Repositories
    ↓
Services (Audio, Database, Network)
    ↓
External APIs (quran package, audio files)
```

## State Management

All state is managed via Riverpod:

- **FutureProvider**: For async data loading (surahs, verses)
- **StateNotifierProvider**: For mutable state (home search)
- **StreamProvider**: For streams (player position, playback state)
- **StateProvider**: For simple state (current track info)

## Color Theme (Dignity)

```dart
static const Color bgBase = Color(0xFF0A0A0A);       // Page background
static const Color bgCardDark = Color(0xFF1A1A1A);    // Card background
static const Color bgCardInner = Color(0xFF141414);   // Card inner
static const Color goldStart = Color(0xFFC9A84C);     // Gold gradient start
static const Color goldEnd = Color(0xFFE8D48B);       // Gold gradient end
static const Color goldSoft = Color(0x33C9A84C);      // 19% opacity gold border
static const Color goldMuted = Color(0x99C9A84C);     // 60% opacity gold text
static const Color textWhite = Color(0xFFFFFFFF);     // Primary text
static const Color textGray = Color(0xFF888888);      // Secondary text
```

## Models

### Surah
- `surahId`: String (1-114)
- `name`: Arabic name
- `englishName`: English transliteration
- `englishNameTranslation`: English meaning
- `ayahCount`: Number of verses
- `audioUrl`: Full chapter recitation URL
- `revelationType`: 1 (Meccan) or 2 (Medinan)

### Verse
- `surahId`: Parent surah
- `verseId`: Ayah number
- `arabicText`: Arabic script
- `englishText`: English translation
- `englishTransliteration`: Optional transliteration
- `startMs`: Audio start position
- `endMs`: Audio end position
- `audioUrl`: Individual verse audio

### Bookmark
- `id`: Unique identifier
- `surahId`, `verseId`: Reference to verse
- `positionMs`: Audio position when bookmarked
- `note`: Optional user note
- `createdAt`, `updatedAt`: Timestamps

## Services

### AudioPlayerService
- Play audio from URL
- Seek to position
- Pause/Resume/Stop
- Adjust playback speed
- Stream position and state

### BookmarkService
- Add/Remove/Update bookmarks
- Query bookmarks by surah
- Search bookmarks by note
- Check if verse is bookmarked

### DownloadService
- Download files
- Track download progress
- List downloaded files
- Delete files

### QuranRepository
- Get all surahs
- Get verses for surah
- Search verses
- Get surah/verse counts

## Database Schema

### surahs table
- `surah_id` (PK)
- `name`, `english_name`, `english_name_translation`
- `ayah_count`, `audio_url`, `revelation_type`

### verses table
- `id` (PK, autoincrement)
- `surah_id`, `verse_id` (unique together)
- `arabic_text`, `english_text`
- `english_transliteration` (optional)
- `start_ms`, `end_ms`, `audio_url`

### bookmarks table
- `id` (PK, generated from surah_verse)
- `surah_id`, `verse_id`
- `position_ms`, `note`
- `created_at`, `updated_at`

## Next Steps for Implementation

1. **Dependency Injection**: Configure providers in `app.dart`
2. **Audio Timing**: Integrate actual audio timing data
3. **Search**: Implement full-text search across all verses
4. **Downloads**: Complete download management UI
5. **Arabic Font**: Add Amiri or similar font
6. **Testing**: Add unit and widget tests
7. **Error Handling**: Add comprehensive error boundaries
8. **Offline Mode**: Implement offline Quran data
9. **Player Integration**: Connect player to verses
10. **Bookmarks UI**: Add bookmark creation from read screen
