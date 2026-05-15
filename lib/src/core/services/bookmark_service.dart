import '../../data/models/bookmark.dart';

/// Defines the contract for bookmark management
abstract class BookmarkService {
  /// Add a new bookmark
  Future<void> addBookmark(Bookmark bookmark);

  /// Remove a bookmark
  Future<void> removeBookmark(String surahId, int verseId);

  /// Update an existing bookmark
  Future<void> updateBookmark(Bookmark bookmark);

  /// Get all bookmarks
  Future<List<Bookmark>> getAllBookmarks();

  /// Get bookmarks for a specific surah
  Future<List<Bookmark>> getBookmarksForSurah(String surahId);

  /// Get a specific bookmark by surah and verse
  Future<Bookmark?> getBookmark(String surahId, int verseId);

  /// Check if a verse is bookmarked
  Future<bool> isBookmarked(String surahId, int verseId);

  /// Get count of bookmarks for a surah
  Future<int> getBookmarkCountForSurah(String surahId);

  /// Search bookmarks by note text
  Future<List<Bookmark>> searchBookmarks(String query);

  /// Clear all bookmarks
  Future<void> clearAllBookmarks();

  /// Save current playback position for a surah (for auto-resume)
  Future<void> savePlaybackPosition(String surahId, int positionMs);

  /// Get last saved playback position for a surah
  Future<int> getPlaybackPosition(String surahId);

  /// Get the most recently played surah ID (for auto-resume)
  Future<String?> getLastPlayedSurahId();

  /// Clear all playback positions
  Future<void> clearPlaybackPositions();

  /// Dispose resources
  Future<void> dispose();
}
