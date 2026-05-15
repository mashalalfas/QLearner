import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/services/download_service.dart';

/// Download service implementation using Dio
class DownloadServiceImpl implements DownloadService {
  final Dio _dio = Dio();
  final Map<String, double> _progressMap = {};
  final Map<String, StreamController<double>> _controllers = {};

  Future<void> initialize() async {
    // Nothing to initialize
  }

  @override
  Future<String> downloadFile(String url, String filename) async {
    final downloadId = '${DateTime.now().millisecondsSinceEpoch}_$filename';
    final controller = StreamController<double>.broadcast();
    _controllers[downloadId] = controller;

    try {
      final dir = await _getDownloadDirectory();
      final filePath = '${dir.path}/$filename';

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            _progressMap[downloadId] = progress;
            controller.add(progress);
          }
        },
      );

      controller.close();
      _controllers.remove(downloadId);
      _progressMap.remove(downloadId);

      return filePath;
    } catch (e) {
      controller.close();
      _controllers.remove(downloadId);
      _progressMap.remove(downloadId);
      rethrow;
    }
  }

  @override
  Future<bool> isDownloaded(String filename) async {
    final dir = await _getDownloadDirectory();
    final file = File('${dir.path}/$filename');
    return await file.exists();
  }

  @override
  Future<String?> getLocalPath(String filename) async {
    if (!await isDownloaded(filename)) return null;
    final dir = await _getDownloadDirectory();
    return '${dir.path}/$filename';
  }

  @override
  Future<void> cancelDownload(String downloadId) async {
    // Dio doesn't support cancellation easily without CancelToken
    // This is a simplified implementation
    _progressMap.remove(downloadId);
    final controller = _controllers[downloadId];
    controller?.close();
    _controllers.remove(downloadId);
  }

  @override
  Stream<double> getProgress(String downloadId) {
    return _controllers[downloadId]?.stream ??
        Stream.value(_progressMap[downloadId] ?? 0.0);
  }

  @override
  Future<void> deleteFile(String filename) async {
    final dir = await _getDownloadDirectory();
    final file = File('${dir.path}/$filename');
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<List<String>> getDownloadedFiles() async {
    final dir = await _getDownloadDirectory();
    final entities = await dir.list().toList();

    return entities
        .whereType<File>()
        .map((file) => file.path.split('/').last)
        .toList();
  }

  Future<Directory> _getDownloadDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${appDocDir.path}/downloads');

    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    return downloadDir;
  }

  @override
  Future<void> dispose() async {
    _dio.close();
    for (final controller in _controllers.values) {
      await controller.close();
    }
    _controllers.clear();
    _progressMap.clear();
  }
}
