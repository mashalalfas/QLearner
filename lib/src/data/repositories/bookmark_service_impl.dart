import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../core/services/bookmark_service.dart';
import '../../data/models/bookmark.dart';

/// Local bookmark service implementation using JSON files for storage.
///
/// Bookmarks are stored in [applicationDocumentsDirectory]/bookmarks.json
/// Playback positions are stored in [applicationDocumentsDirectory]/playback_positions.json
///
/// This avoids SQLite entirely, eliminating SQLITE_BUSY races between isolates.
class BookmarkServiceImpl implements BookmarkService {
  static const _bookmarksFile = 'bookmarks.json';
  static const _positionsFile = 'playback_positions.json';

  Future<Directory> get _appDir async =>
      await getApplicationDocumentsDirectory();

  Future<File> _getBookmarksFile() async =>
      File('${(await _appDir).path}/$_bookmarksFile');

  Future<File> _getPositionsFile() async =>
      File('${(await _appDir).path}/$_positionsFile');

  T? _firstWhereOrNull<T>(List<T> list, bool Function(T) test) {
    try {
      return list.firstWhere(test);
    } on StateError {
      return null;
    }
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _readJsonList(File file) async {
    if (!await file.exists()) return [];
    final content = await file.readAsString();
    if (content.trim().isEmpty) return [];
    final decoded = jsonDecode(content);
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> _writeJsonList(File file, List<Map<String, dynamic>> data) async {
    await file.writeAsString(jsonEncode(data));
  }

  // ── Initialise ────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    // Ensure both files exist (no-op if they already do)
    await (_getBookmarksFile()).then((f) async {
      if (!await f.exists()) await f.writeAsString('[]');
    });
    await (_getPositionsFile()).then((f) async {
      if (!await f.exists()) await f.writeAsString('[]');
    });
  }

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  @override
  Future<void> addBookmark(Bookmark bookmark) async {
    final file = await _getBookmarksFile();
    final list = await _readJsonList(file);
    // Remove any existing entry with the same id, then append
    list.removeWhere((m) => m['id'] == bookmark.id);
    list.add(bookmark.toMap());
    await _writeJsonList(file, list);
  }

  @override
  Future<void> removeBookmark(String surahId, int verseId) async {
    final file = await _getBookmarksFile();
    final list = await _readJsonList(file);
    list.removeWhere((m) => m['surah_id'] == surahId && m['verse_id'] == verseId);
    await _writeJsonList(file, list);
  }

  @override
  Future<void> updateBookmark(Bookmark bookmark) async {
    final file = await _getBookmarksFile();
    final list = await _readJsonList(file);
    final idx = list.indexWhere((m) => m['id'] == bookmark.id);
    if (idx != -1) {
      list[idx] = bookmark.toMap();
      await _writeJsonList(file, list);
    }
  }

  @override
  Future<List<Bookmark>> getAllBookmarks() async {
    final list = await _readJsonList(await _getBookmarksFile());
    list.sort((a, b) => (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''));
    return list.map(Bookmark.fromMap).toList();
  }

  @override
  Future<List<Bookmark>> getBookmarksForSurah(String surahId) async {
    final list = await _readJsonList(await _getBookmarksFile());
    final filtered =
        list.where((m) => m['surah_id'] == surahId).toList()
          ..sort((a, b) => (a['verse_id'] ?? 0).compareTo(b['verse_id'] ?? 0));
    return filtered.map(Bookmark.fromMap).toList();
  }

  @override
  Future<Bookmark?> getBookmark(String surahId, int verseId) async {
    final list = await _readJsonList(await _getBookmarksFile());
    final match = _firstWhereOrNull(
      list,
      (m) => m['surah_id'] == surahId && m['verse_id'] == verseId,
    );
    return match != null ? Bookmark.fromMap(match) : null;
  }

  @override
  Future<bool> isBookmarked(String surahId, int verseId) async =>
      (await getBookmark(surahId, verseId)) != null;

  @override
  Future<int> getBookmarkCountForSurah(String surahId) async {
    final list = await _readJsonList(await _getBookmarksFile());
    return list.where((m) => m['surah_id'] == surahId).length;
  }

  @override
  Future<List<Bookmark>> searchBookmarks(String query) async {
    final list = await _readJsonList(await _getBookmarksFile());
    final q = query.toLowerCase();
    final filtered = list
        .where((m) => (m['note'] as String? ?? '').toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''));
    return filtered.map(Bookmark.fromMap).toList();
  }

  @override
  Future<void> clearAllBookmarks() async {
    await _writeJsonList(await _getBookmarksFile(), []);
  }

  // ── Playback positions ────────────────────────────────────────────────────

  @override
  Future<void> savePlaybackPosition(String surahId, int positionMs) async {
    final file = await _getPositionsFile();
    final list = await _readJsonList(file);
    final entry = <String, dynamic>{
      'surah_id': surahId,
      'position_ms': positionMs,
      'updated_at': DateTime.now().toIso8601String(),
    };
    list.removeWhere((m) => m['surah_id'] == surahId);
    list.add(entry);
    await _writeJsonList(file, list);
  }

  @override
  Future<int> getPlaybackPosition(String surahId) async {
    final list = await _readJsonList(await _getPositionsFile());
    final match = _firstWhereOrNull(
      list,
      (m) => m['surah_id'] == surahId,
    );
    return match != null ? (match['position_ms'] as int) : 0;
  }

  @override
  Future<String?> getLastPlayedSurahId() async {
    final list = await _readJsonList(await _getPositionsFile());
    if (list.isEmpty) return null;
    // Sort by updated_at descending and return the top surah_id
    list.sort((a, b) =>
        (b['updated_at'] ?? '').compareTo(a['updated_at'] ?? ''));
    return list.first['surah_id'] as String?;
  }

  @override
  Future<void> clearPlaybackPositions() async {
    await _writeJsonList(await _getPositionsFile(), []);
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  @override
  Future<void> dispose() async {
    // Nothing to clean up for file-based storage.
  }
}
