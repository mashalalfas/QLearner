# QLearner Redesign Plan — "Dignity" Theme

## Overview

Complete redesign of QLearner Quran audio player app following the approved "Dignity" design: premium black & gold with glassmorphism cards, gold gradient borders, and Google Fonts (Noto Naskh Arabic + Plus Jakarta Sans).

---

## 1. Theme System

### Color Tokens

```dart
// Background Colors
static const Color bgBase = Color(0xFF0A0A0A);        // Page background
static const Color bgPhone = Color(0xFF0D0D0D);       // Phone screen
static const Color bgCardDark = Color(0xFF1A1A1A);    // Card background (outer)
static const Color bgCardInner = Color(0xFF141414);    // Card background (inner)

// Gold Colors
static const Color goldStart = Color(0xFFC9A84C);     // Gold gradient start
static const Color goldEnd = Color(0xFFE8D48B);        // Gold gradient end
static const Color goldSoft = Color(0x3300C9A84C);     // 19% opacity gold border
static const Color goldMuted = Color(0x99C9A84C);      // 60% opacity gold text

// Text Colors
static const Color textWhite = Color(0xFFFFFFFF);
static const Color textGray = Color(0xFF888888);

// Gradients
static const LinearGradient goldGradient = LinearGradient(
  colors: [goldStart, goldEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

static const LinearGradient cardGradient = LinearGradient(
  colors: [bgCardDark, bgCardInner],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
```

### Typography Scale

```dart
// Font Families
String fontArabic = 'Noto Naskh Arabic';
String fontBody = 'Plus Jakarta Sans';

// Size Scale
TextStyle appbarTitle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.5,
);

TextStyle surahArabic = TextStyle(
  fontFamily: fontArabic,
  fontSize: 20,
  fontWeight: FontWeight.w600,
  height: 1.4,
);

TextStyle cardTitle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w600,
);

TextStyle cardSubtitle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
);

TextStyle metaText = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w500,
);

TextStyle sectionHeader = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.5,
);

TextStyle navItem = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w600,
  letterSpacing: 1.0,
);

TextStyle playerSurahNumber = TextStyle(
  fontSize: 52,
  fontWeight: FontWeight.w700,
);
```

### Spacing & Dimensions

```dart
// Phone Frame
const double phoneWidth = 375;
const double phoneHeight = 812;
const double screenPaddingH = 24;
const double screenPaddingTop = 60;
const double screenPaddingBottom = 100;

// Card
const double cardBorderRadius = 18;
const double cardPaddingV = 16;
const double cardPaddingH = 12;

// Grid
const double gridGap = 14;
const int gridColumns = 2;

// Bottom Nav
const double bottomNavHeight = 80;
const double bottomNavPaddingBottom = 24;

// Border
const double goldBorderWidth = 0.5;
const double goldBorderOpacity = 0.3;
```

### Shadows & Effects

```dart
// Card Hover (on tap)
BoxDecoration cardHoverDecoration = BoxDecoration(
  boxShadow: [
    BoxShadow(
      color: Color(0x1FC9A84C), // 12% opacity gold
      blurRadius: 24,
      offset: Offset(0, 4),
    ),
  ],
);

// Player Circle Glow Animation
// Keyframes: 0%, 100% → scale(1), shadow 0px
//            50%      → scale(1.03), shadow 12px
// Duration: 3s ease-in-out infinite

// Bottom Nav Blur
BackdropFilter(
  blur: 20,
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xCC0D0D0D), Color(0xF20D0D0D)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  ),
)
```

---

## 2. Screen Architecture

### Screen 1: Home (Surah Grid)

**Widget Tree:**
```
Scaffold
└── Stack
    ├── SafeArea
    │   └── Column
    │       ├── AppBar (centered title "QLearner" + gold underline)
    │       ├── SearchBar (48px height, 14px radius, gold border)
    │       └── Expanded
    │           └── GridView.builder
    │               └── SurahCard (×114 items)
    └── Positioned
        └── bottom: 0
            └── BottomNav (Home active)
```

**Key Widgets:**
- `AppBarGold` — Centered title with gold underline decoration
- `SearchBarGold` — Glassmorphism input with gold border
- `SurahCard` — 2-column grid card with gradient border effect
- `BottomNav` — 4-tab navigation with gold active indicator

**Layout Strategy:**
- Grid: 2 columns, 14px gap
- Scroll: vertical with gold scrollbar thumb
- Card aspect: fill width, auto height (content-based)

### Screen 2: Player

**Widget Tree:**
```
Scaffold
└── Stack
    ├── SafeArea
    │   └── Column
    │       ├── PlayerHeader (surah number, gold gradient)
    │       ├── Center
    │       │   └── PlayerCircle (200×200, animated glow border)
    │       │       └── PlayerArabicText (centered)
    │       ├── PlayerEnglishName
    │       ├── ControlsArea (expanded)
    │       │   ├── ControlsRow (prev/play/next)
    │       │   ├── SeekBar (gold fill + dot)
    │       │   └── PlayerMetaRow
    │       └── Spacer(flex: 1)
    └── Positioned
        └── bottom: 0
            └── BottomNav (no active state shown)
```

**Key Widgets:**
- `PlayerSurahNumber` — 52px gold gradient text
- `PlayerCircle` — Animated border with inner Arabic text
- `PlayerControlsRow` — Prev/Play/Next buttons
- `SeekBarGold` — Custom slider with gold fill and dot
- `PlayerMetaRow` — Repeat/Save/Time indicators

**Layout Strategy:**
- Centered circular visual as focal point
- Controls stack below, vertically centered in available space

### Screen 3: Library

**Widget Tree:**
```
Scaffold
└── Stack
    ├── SafeArea
    │   └── SingleChildScrollView
    │       └── Column
    │           ├── LibraryHeader ("Library" + gold underline)
    │           ├── StorageCard
    │           │   ├── StorageHeader (title + value)
    │           │   ├── ProgressTrack (gold fill)
    │           │   └── StorageStats
    │           ├── SectionHeader ("Downloads")
    │           ├── LibraryItem (×n, Download items)
    │           ├── SectionHeader ("Bookmarks")
    │           └── LibraryItem (×n, Bookmark items)
    └── Positioned
        └── bottom: 0
            └── BottomNav (Library active)
```

**Key Widgets:**
- `StorageCard` — Shows storage usage with progress bar
- `LibraryItem` — Card with Play/Delete actions
- `SectionHeader` — Gold text section divider

**Layout Strategy:**
- Vertical scrolling list
- Sections separated by gold headers
- Storage card always at top

### Screen 4: Reciters

**Widget Tree:**
```
Scaffold
└── Stack
    ├── SafeArea
    │   └── Column
    │       ├── RecitersHeader
    │       │   ├── RecitersTitle ("Reciters" + gold underline)
    │       │   └── RecitersSubtitle
    │       └── Expanded
    │           └── ListView.builder
    │               └── ReciterCard (×n)
    └── Positioned
        └── bottom: 0
            └── BottomNav (Reciters active)
```

**Key Widgets:**
- `ReciterCard` — Horizontal card with name/style + Select button
- `ReciterSelectButton` — Gold outlined button, fills on hover/selected

**Layout Strategy:**
- Vertical scrolling list
- Each card shows reciter info + selection action
- Active reciter has brighter border and "Selected" button state

---

## 3. Navigation

### Bottom Nav Implementation

```dart
// 4 tabs: Home, Library, Reciters, Settings
// Active tab: white text + gold underline bar
// Inactive: gray text, no underline

BottomNavBar(
  height: 80,
  backgroundColor: Colors.transparent,
  elevation: 0,
  type: BottomNavigationBarType.fixed,
  items: [
    BottomNavigationBarItem(icon: Icon(...), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(...), label: 'Library'),
    BottomNavigationBarItem(icon: Icon(...), label: 'Reciters'),
    BottomNavigationBarItem(icon: Icon(...), label: 'Settings'),
  ],
  selectedItemColor: textWhite,
  unselectedItemColor: textGray,
  selectedLabelStyle: navItem,
  unselectedLabelStyle: navItem,
)

// Custom indicator (gold underline):
// Positioned bottom: 20, width: 40, height: 2
// Gradient: goldStart → goldEnd
```

### State Persistence

```dart
// Use IndexedStack to preserve screen state
IndexedStack(
  index: _currentIndex,
  children: [
    HomeScreen(),
    LibraryScreen(),
    RecitersScreen(),
    SettingsScreen(),
  ],
)

// Each screen retains scroll position, input, etc.
```

---

## 4. Component Mapping

### Reusable Components to Create

| Component | Description | Reusable? |
|-----------|-------------|-----------|
| `GoldGradientBorder` | Painted gradient border for cards | YES |
| `GlassCard` | Card with blur + gradient + border | YES |
| `AppBarGold` | AppBar with gold underline title | YES |
| `SearchBarGold` | Input with glassmorphism styling | YES |
| `BottomNav` | 4-tab bottom navigation | YES |
| `SurahCard` | Surah grid item | YES |
| `LibraryItem` | Download/bookmark list item | YES |
| `StorageCard` | Storage progress card | YES |
| `ReciterCard` | Reciter selection card | YES |
| `PlayerCircle` | Animated circular player visual | YES |
| `SeekBarGold` | Custom seek bar | YES |
| `SectionHeader` | Gold section divider | YES |

### Components to Rewrite

| Component | Reason |
|-----------|--------|
| `SurahCard` (existing) | Different design — needs gold borders |
| `PlayerScreen` (existing) | Needs complete redesign with circle visual |
| `LibraryScreen` (existing) | Needs storage card + new item styling |
| All color constants | Replace with gold theme |

### Components to Keep/Adapt

| Component | Action |
|-----------|--------|
| `Surah` model | Keep — add any new fields |
| `Verse` model | Keep |
| `Bookmark` model | Keep |
| Audio service | Keep — integrate with new UI |

---

## 5. File Plan

### New Files to Create

```
lib/
├── main.dart
│   └── Entry point
│
├── core/
│   └── theme/
│       ├── app_colors.dart      # All color constants
│       ├── app_typography.dart  # Text styles
│       ├── app_spacing.dart     # Dimensions & spacing
│       └── app_theme.dart       # ThemeData assembly
│
├── shared/
│   └── widgets/
│       ├── gold_gradient_border.dart  # Gradient border painter
│       ├── glass_card.dart            # Glassmorphism card widget
│       ├── app_bar_gold.dart          # Gold underline AppBar
│       ├── search_bar_gold.dart       # Gold bordered search input
│       ├── bottom_nav.dart            # 4-tab bottom navigation
│       ├── section_header.dart        # Gold section title
│       └── seek_bar_gold.dart         # Custom seek slider
│
├── features/
│   ├── home/
│   │   ├── screens/
│   │   │   └── home_screen.dart      # Surah grid screen
│   │   └── widgets/
│   │       └── surah_card.dart       # Grid item card
│   │
│   ├── player/
│   │   ├── screens/
│   │   │   └── player_screen.dart    # Full player screen
│   │   └── widgets/
│   │       ├── player_circle.dart    # Animated circle visual
│   │       └── player_controls.dart  # Play/prev/next row
│   │
│   ├── library/
│   │   ├── screens/
│   │   │   └── library_screen.dart   # Downloads & bookmarks
│   │   └── widgets/
│   │       ├── storage_card.dart     # Storage usage widget
│   │       └── library_item.dart     # List item with actions
│   │
│   ├── reciters/
│   │   ├── screens/
│   │   │   └── reciters_screen.dart  # Reciter selection
│   │   └── widgets/
│   │       └── reciter_card.dart     # Reciter item + button
│   │
│   └── settings/
│       └── screens/
│           └── settings_screen.dart   # Settings placeholder
│
└── app/
    └── main_app.dart                  # Root with IndexedStack nav
```

### Existing Files to Modify

```
lib/src/features/home/screens/home_screen.dart   → Copy to new path
lib/src/features/player/screens/player_screen.dart → Copy to new path
lib/src/features/library/screens/library_screen.dart → Copy to new path
lib/src/app.dart                                → Update navigation
lib/src/core/theme/app_theme.dart               → Create
```

### Files to Delete (after migration)

```
lib/src/features/home/widgets/surah_card.dart   (replaced)
lib/src/features/player/widgets/player_widgets.dart
lib/src/core/theme/colors.dart                  (replace with app_colors.dart)
```

---

## 6. Implementation Notes

### Gold Gradient Border Technique

Use `CustomPainter` to paint gradient border on card:

```dart
class GoldBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      colors: [goldStart, goldEnd, goldStart],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(18)),
      paint,
    );
  }
}
```

### Player Circle Glow Animation

```dart
class PlayerCircle extends StatefulWidget {
  // Use AnimatedContainer or TweenAnimationBuilder
  // Shadow: 0 → 12px blur → 0 (3s cycle)
  // Scale: 1.0 → 1.03 → 1.0
}
```

### Bottom Nav Blur Effect

```dart
ClipRRect(
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(24),
    topRight: Radius.circular(24),
  ),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xCC0D0D0D),
            Color(0xF20D0D0D),
          ],
        ),
      ),
    ),
  ),
)
```

### Search Bar Glassmorphism

```dart
Container(
  height: 48,
  decoration: BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: goldSoft),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: BackdropFilter(
      blur: 10,
      child: TextField(...),
    ),
  ),
)
```

---

## 7. Success Criteria

1. All 4 screens match the HTML mockup visual design
2. Bottom nav transitions preserve screen state
3. Gold gradient borders visible on all interactive cards
4. Player circle animates smoothly (60fps)
5. Search bar functional with gold styling
6. All text uses correct fonts (Noto Naskh Arabic for Arabic, Plus Jakarta Sans for English)
7. Dark theme consistent across all screens