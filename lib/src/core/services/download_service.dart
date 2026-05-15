/// Defines the contract for downloading audio files
abstract class DownloadService {
  /// Download a file from URL and save to local storage
  /// Returns the local file path
  Future<String> downloadFile(String url, String filename);

  /// Check if a file exists locally
  Future<bool> isDownloaded(String filename);

  /// Get the local path for a downloaded file
  Future<String?> getLocalPath(String filename);

  /// Cancel an ongoing download
  Future<void> cancelDownload(String downloadId);

  /// Get download progress stream (0.0 to 1.0)
  Stream<double> getProgress(String downloadId);

  /// Delete a downloaded file
  Future<void> deleteFile(String filename);

  /// Get list of downloaded files
  Future<List<String>> getDownloadedFiles();

  /// Dispose resources
  Future<void> dispose();
}

/// Represents a download task
class DownloadTask {
  final String id;
  final String url;
  final String filename;
  double progress;
  DownloadStatus status;

  DownloadTask({
    required this.id,
    required this.url,
    required this.filename,
    this.progress = 0.0,
    this.status = DownloadStatus.pending,
  });
}

enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
  cancelled,
}
