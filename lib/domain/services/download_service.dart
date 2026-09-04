import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../entities/episode.dart';

class DownloadService {
  final Dio _dio = Dio();
  final Map<String, CancelToken> _downloadTokens = {};
  final Map<String, double> _downloadProgress = {};

  double getProgress(String episodeId) => _downloadProgress[episodeId] ?? 0.0;

  bool isDownloading(String episodeId) => _downloadTokens.containsKey(episodeId);

  Stream<double> downloadProgressStream(String episodeId) async* {
    while (_downloadTokens.containsKey(episodeId)) {
      yield _downloadProgress[episodeId] ?? 0.0;
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<String?> downloadEpisode(Episode episode) async {
    if (_downloadTokens.containsKey(episode.id)) {
      return null;
    }

    final cancelToken = CancelToken();
    _downloadTokens[episode.id] = cancelToken;
    _downloadProgress[episode.id] = 0.0;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${dir.path}/downloads');
      if (!downloadDir.existsSync()) {
        downloadDir.createSync(recursive: true);
      }

      final fileName = '${episode.id}.mp3';
      final filePath = '${downloadDir.path}/$fileName';

      await _dio.download(
        episode.audioUrl,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _downloadProgress[episode.id] = received / total;
          }
        },
      );

      _downloadTokens.remove(episode.id);
      _downloadProgress.remove(episode.id);
      return filePath;
    } catch (e) {
      _downloadTokens.remove(episode.id);
      _downloadProgress.remove(episode.id);
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> cancelDownload(String episodeId) async {
    final token = _downloadTokens[episodeId];
    if (token != null && !token.isCancelled) {
      token.cancel('Download cancelled by user');
      _downloadTokens.remove(episodeId);
      _downloadProgress.remove(episodeId);
    }
  }

  Future<void> deleteDownload(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<bool> isDownloaded(String episodeId) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/downloads/$episodeId.mp3';
    return File(filePath).exists();
  }
}