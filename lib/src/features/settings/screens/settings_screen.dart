import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/section_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHARED PREFERENCES KEYS
// ─────────────────────────────────────────────────────────────────────────────

class SettingsKeys {
  SettingsKeys._();
  static const String displayName = 'settings_display_name';
  static const String email = 'settings_email';
  static const String reciter = 'settings_reciter';
  static const String audioQuality = 'settings_audio_quality';
  static const String autoPlayNext = 'settings_auto_play_next';
  static const String playbackSpeed = 'settings_playback_speed';
  static const String cacheSize = 'settings_cache_size';
}

// ─────────────────────────────────────────────────────────────────────────────
// RECITER LIST
// ─────────────────────────────────────────────────────────────────────────────

const List<String> reciterOptions = [
  'Alafasy',
  'Abdul Basit',
  'Abdurrahmaan As-Sudais',
  'Hani Ar-Rifai',
  'Maher Al-Muaiqly',
  'Mishary Rashid Alafasy',
  'Abdullah Basfar',
  'Saud Ash-Shuraim',
  'Mahmoud Khalil Al-Husary',
  'Mohamed Siddiq Al-Minshawi',
];

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS STATE (persisted via shared_preferences)
// ─────────────────────────────────────────────────────────────────────────────

class SettingsModel extends ChangeNotifier {
  // ── Profile ────────────────────────────────────────────────────────────
  String _displayName = '';
  String _email = '';
  String _reciter = 'Alafasy';

  // ── Audio ──────────────────────────────────────────────────────────────
  String _audioQuality = 'Auto';
  bool _autoPlayNext = true;
  double _playbackSpeed = 1.0;

  // ── Storage ────────────────────────────────────────────────────────────
  String _cacheSize = '0 MB';

  // ── Getters ────────────────────────────────────────────────────────────
  String get displayName => _displayName;
  String get email => _email;
  String get reciter => _reciter;
  String get audioQuality => _audioQuality;
  bool get autoPlayNext => _autoPlayNext;
  double get playbackSpeed => _playbackSpeed;
  String get cacheSize => _cacheSize;

  // ── Init from shared_preferences ───────────────────────────────────────
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _displayName = prefs.getString(SettingsKeys.displayName) ?? '';
    _email = prefs.getString(SettingsKeys.email) ?? '';
    _reciter = prefs.getString(SettingsKeys.reciter) ?? 'Alafasy';
    _audioQuality = prefs.getString(SettingsKeys.audioQuality) ?? 'Auto';
    _autoPlayNext = prefs.getBool(SettingsKeys.autoPlayNext) ?? true;
    _playbackSpeed = prefs.getDouble(SettingsKeys.playbackSpeed) ?? 1.0;
    _cacheSize = prefs.getString(SettingsKeys.cacheSize) ?? '0 MB';
    notifyListeners();
  }

  // ── Profile ────────────────────────────────────────────────────────────
  Future<void> setDisplayName(String value) async {
    _displayName = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SettingsKeys.displayName, value);
    notifyListeners();
  }

  Future<void> setEmail(String value) async {
    _email = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SettingsKeys.email, value);
    notifyListeners();
  }

  // ── Reciter ────────────────────────────────────────────────────────────
  Future<void> setReciter(String value) async {
    _reciter = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SettingsKeys.reciter, value);
    notifyListeners();
  }

  // ── Audio ──────────────────────────────────────────────────────────────
  Future<void> setAudioQuality(String value) async {
    _audioQuality = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SettingsKeys.audioQuality, value);
    notifyListeners();
  }

  Future<void> setAutoPlayNext(bool value) async {
    _autoPlayNext = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SettingsKeys.autoPlayNext, value);
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double value) async {
    _playbackSpeed = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(SettingsKeys.playbackSpeed, value);
    notifyListeners();
  }

  // ── Storage ────────────────────────────────────────────────────────────
  Future<void> clearCache() async {
    _cacheSize = '0 MB';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SettingsKeys.cacheSize, '0 MB');
    notifyListeners();
  }
}

/// Provider for the settings model.
final settingsProvider = ChangeNotifierProvider<SettingsModel>((ref) {
  return SettingsModel();
});

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

/// Settings Screen — Dignity theme (black & gold glassmorphism)
///
/// Sections:
/// 1. Profile — display name, email, avatar
/// 2. Reciter Preference — dropdown selector
/// 3. Audio Quality — Auto / High / Medium / Low
/// 4. Playback — auto-play toggle + speed selector
/// 5. Storage — cache size + clear cache
/// 6. About — version + credits
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const List<String> _qualityOptions = ['Auto', 'High', 'Medium', 'Low'];
  static const List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  void initState() {
    super.initState();
    // Load persisted settings after first frame so provider is ready
    Future.microtask(() => ref.read(settingsProvider).load());
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: screenPaddingH,
            vertical: screenPaddingTop,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Page Header ──────────────────────────────────────────────
              const _PageHeader(),

              const SizedBox(height: 28),

              // ── Profile Section ──────────────────────────────────────────
              _SettingsSection(
                title: 'Profile',
                child: _ProfileSection(settings: settings),
              ),

              const SizedBox(height: 20),

              // ── Reciter Preference Section ───────────────────────────────
              _SettingsSection(
                title: 'Reciter Preference',
                child: _ReciterSelector(
                  options: reciterOptions,
                  selected: settings.reciter,
                  onSelected: (v) => settings.setReciter(v),
                ),
              ),

              const SizedBox(height: 20),

              // ── Audio Quality Section ────────────────────────────────────
              _SettingsSection(
                title: 'Audio Quality',
                child: _QualitySelector(
                  options: _qualityOptions,
                  selected: settings.audioQuality,
                  onSelected: (v) => settings.setAudioQuality(v),
                ),
              ),

              const SizedBox(height: 20),

              // ── Playback Section ─────────────────────────────────────────
              _SettingsSection(
                title: 'Playback',
                children: [
                  _ToggleRow(
                    label: 'Auto-play next surah',
                    value: settings.autoPlayNext,
                    onChanged: (v) => settings.setAutoPlayNext(v),
                  ),
                  const SizedBox(height: 16),
                  _SpeedSelector(
                    options: _speedOptions,
                    selected: settings.playbackSpeed,
                    onSelected: (v) => settings.setPlaybackSpeed(v),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Storage Section ──────────────────────────────────────────
              _SettingsSection(
                title: 'Storage',
                children: [
                  _InfoRow(
                    label: 'Cache Size',
                    value: settings.cacheSize,
                  ),
                  const SizedBox(height: 16),
                  _SettingsButton(
                    label: 'Clear Cache',
                    isDestructive: true,
                    onPressed: () => settings.clearCache(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── About Section ────────────────────────────────────────────
              const _SettingsSection(
                title: 'About',
                children: [
                  _InfoRow(
                    label: 'App Version',
                    value: 'QuranAudio v1.0.0',
                  ),
                  SizedBox(height: 12),
                  _InfoRow(
                    label: 'Credits',
                    value: 'Audio from mp3quran.net',
                  ),
                ],
              ),

              // Bottom spacing for navigation
              const SizedBox(height: bottomNavHeight + screenPaddingBottom),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: AppColors.textWhite,
            fontFamily: fontBody,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 2,
          decoration: const BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.all(Radius.circular(1)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS SECTION WRAPPER
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  final String title;
  final Widget? child;
  final List<Widget>? children;

  const _SettingsSection({
    required this.title,
    this.child,
    this.children,
  }) : assert(child != null || children != null);

  @override
  Widget build(BuildContext context) {
    final content = child ??
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children!,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: 12),
        GlassCard(
          radius: cardBorderRadius,
          child: content,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileSection extends StatelessWidget {
  final SettingsModel settings;

  const _ProfileSection({required this.settings});

  @override
  Widget build(BuildContext context) {
    final name = settings.displayName.trim().isNotEmpty
        ? settings.displayName
        : 'Your Name';
    final initials = _getInitials(settings.displayName);

    return Column(
      children: [
        // Avatar row: circle + name label
        Row(
          children: [
            // Avatar circle with initials
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.goldGradient,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.bgBase,
                    fontFamily: fontBody,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Friendly display label
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                  fontFamily: fontBody,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Display name field
        _SettingsTextField(
          label: 'Display Name',
          value: settings.displayName,
          onChanged: settings.setDisplayName,
          hint: 'Enter your name',
        ),
        const SizedBox(height: 14),

        // Email field
        _SettingsTextField(
          label: 'Email',
          value: settings.email,
          onChanged: settings.setEmail,
          hint: 'your@email.com',
          isEmail: true,
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}

class _SettingsTextField extends StatelessWidget {
  final String label;
  final String value;
  final Future<void> Function(String) onChanged;
  final String? hint;
  final bool isEmail;

  const _SettingsTextField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    this.isEmail = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textGray,
            fontFamily: fontBody,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: TextEditingController(text: value)
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: value.length),
            ),
          onChanged: onChanged,
          keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textWhite,
            fontFamily: fontBody,
          ),
          cursorColor: AppColors.goldStart,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textGray,
              fontFamily: fontBody,
            ),
            filled: true,
            fillColor: AppColors.bgCardInner,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.goldSoft,
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.goldSoft,
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.goldStart,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RECITER SELECTOR (dropdown)
// ─────────────────────────────────────────────────────────────────────────────

class _ReciterSelector extends StatefulWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const _ReciterSelector({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_ReciterSelector> createState() => _ReciterSelectorState();
}

class _ReciterSelectorState extends State<_ReciterSelector> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        const Text(
          'Reciter',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textGray,
            fontFamily: fontBody,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgCardInner,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _expanded
                    ? AppColors.goldStart
                    : AppColors.goldSoft,
                width: _expanded ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.selected,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textWhite,
                    fontFamily: fontBody,
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.goldStart,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        // Dropdown menu
        if (_expanded)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppColors.bgCardInner,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.goldSoft,
                width: 0.5,
              ),
            ),
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: widget.options.map((option) {
                final isSelected = option == widget.selected;
                return InkWell(
                  onTap: () {
                    widget.onSelected(option);
                    setState(() => _expanded = false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0x1FC9A84C)
                          : Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.goldStart
                                : AppColors.textWhite,
                            fontFamily: fontBody,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_rounded,
                            color: AppColors.goldStart,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUALITY SELECTOR (radio-style buttons)
// ─────────────────────────────────────────────────────────────────────────────

class _QualitySelector extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const _QualitySelector({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option == selected;
        return GestureDetector(
          onTap: () => onSelected(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.goldStart : AppColors.goldSoft,
                width: isSelected ? 1.5 : 0.5,
              ),
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0x1FC9A84C), Color(0x0FC9A84C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
            child: Text(
              option,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.goldStart : AppColors.textGray,
                fontFamily: fontBody,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOGGLE ROW (switch)
// ─────────────────────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textWhite,
            fontFamily: fontBody,
          ),
        ),
        Transform.scale(
          scale: 0.85,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.goldStart,
            activeTrackColor: AppColors.goldSoft,
            inactiveThumbColor: AppColors.textGray,
            inactiveTrackColor: AppColors.bgCardInner,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SPEED SELECTOR (horizontal chip selector)
// ─────────────────────────────────────────────────────────────────────────────

class _SpeedSelector extends StatelessWidget {
  final List<double> options;
  final double selected;
  final ValueChanged<double> onSelected;

  const _SpeedSelector({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: options.map((speed) {
        final isSelected = speed == selected;
        return GestureDetector(
          onTap: () => onSelected(speed),
          child: Container(
            width: 52,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.goldStart
                    : AppColors.goldSoft,
                width: isSelected ? 1.5 : 0.5,
              ),
              color: isSelected
                  ? const Color(0x1FC9A84C)
                  : Colors.transparent,
            ),
            child: Text(
              speed == speed.roundToDouble()
                  ? '${speed.toInt()}x'
                  : '${speed.toStringAsFixed(1)}x',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.goldStart
                    : AppColors.textGray,
                fontFamily: fontBody,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INFO ROW (label + value, read-only)
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textGray,
            fontFamily: fontBody,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textWhite,
            fontFamily: fontBody,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS BUTTON (text action button)
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsButton extends StatelessWidget {
  final String label;
  final bool isDestructive;
  final VoidCallback onPressed;

  const _SettingsButton({
    required this.label,
    this.isDestructive = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: isDestructive
                  ? const Color(0xFFE05050)
                  : AppColors.goldStart,
              fontFamily: fontBody,
            ),
          ),
        ),
      ),
    );
  }
}
