import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Local database helper for SQLite operations
class LocalDatabaseHelper {
  static final LocalDatabaseHelper _instance = LocalDatabaseHelper._internal();
  factory LocalDatabaseHelper() => _instance;
  LocalDatabaseHelper._internal();

  static Database? _database;

  /// Returns the singleton database instance.
  ///
  /// Uses [singleInstance: true] to prevent SQLITE_BUSY when multiple
  /// isolates attempt to open the same file.  Callers should always go
  /// through this getter — never call [openDatabase] directly.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'quranaudio.db');

    return await openDatabase(
      path,
      version: 2,
      singleInstance: true,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add playback_positions table in version 2
      await db.execute('''
        CREATE TABLE playback_positions (
          surah_id TEXT PRIMARY KEY,
          position_ms INTEGER NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      await db.execute('CREATE INDEX idx_playback_surah ON playback_positions(surah_id)');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Surahs table
    await db.execute('''
      CREATE TABLE surahs (
        surah_id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        english_name TEXT NOT NULL,
        english_name_translation TEXT NOT NULL,
        ayah_count INTEGER NOT NULL,
        audio_url TEXT,
        revelation_type INTEGER NOT NULL
      )
    ''');

    // Verses table
    await db.execute('''
      CREATE TABLE verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_id TEXT NOT NULL,
        verse_id INTEGER NOT NULL,
        arabic_text TEXT NOT NULL,
        english_text TEXT NOT NULL,
        english_transliteration TEXT,
        start_ms INTEGER NOT NULL,
        end_ms INTEGER,
        audio_url TEXT,
        UNIQUE(surah_id, verse_id)
      )
    ''');

    // Bookmarks table
    await db.execute('''
      CREATE TABLE bookmarks (
        id TEXT PRIMARY KEY,
        surah_id TEXT NOT NULL,
        verse_id INTEGER NOT NULL,
        position_ms INTEGER NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes for faster queries
    await db.execute('CREATE INDEX idx_verses_surah ON verses(surah_id)');
    await db.execute('CREATE INDEX idx_bookmarks_surah ON bookmarks(surah_id)');

    // Create playback_positions table
    await db.execute('''
      CREATE TABLE playback_positions (
        surah_id TEXT PRIMARY KEY,
        position_ms INTEGER NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_playback_surah ON playback_positions(surah_id)');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
