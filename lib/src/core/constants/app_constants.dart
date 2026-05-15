/// Application-wide constants
class AppConstants {
  // Quran API endpoints
  static const String quranApiBase = 'https://api.quran.com/api/v4';
  static const String everyayahBase = 'https://everyayah.com/data/';

  // Database
  static const String databaseName = 'qlearner.db';
  static const int databaseVersion = 1;

  // Audio
  static const int defaultBufferDurationMs = 10000;
  static const double defaultPlaybackSpeed = 1.0;
  static const List<double> availableSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  // UI
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;

  // Surah data
  static const int totalSurahs = 114;

  // Storage paths
  static const String downloadsDirectory = 'downloads';
  static const String audioDirectory = 'audio';
}
