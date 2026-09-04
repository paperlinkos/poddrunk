import 'dart:async';
import 'package:just_audio/just_audio.dart' as ja;
import '../entities/episode.dart';
import 'local_storage_service.dart';

enum PlaybackState { idle, loading, playing, paused, completed, error }

class AudioPlayerService {
  final ja.AudioPlayer _player = ja.AudioPlayer();
  LocalStorageService? _storage;
  Timer? _positionSaveTimer;

  Episode? _currentEpisode;
  bool _isVideo = false;

  Episode? get currentEpisode => _currentEpisode;
  bool get isVideo => _isVideo;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<ja.PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get playingStream => _player.playingStream;

  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  bool get isPlaying => _player.playing;
  double get speed => _player.speed;

  void setStorage(LocalStorageService storage) {
    _storage = storage;
  }

  Future<void> playEpisode(Episode episode, {bool isVideo = false}) async {
    try {
      _currentEpisode = episode;
      _isVideo = isVideo;

      if (episode.isDownloaded && episode.localPath != null) {
        await _player.setFilePath(episode.localPath!);
      } else {
        if (isVideo && episode.videoUrl != null) {
          await _player.setUrl(episode.videoUrl!);
        } else {
          await _player.setUrl(episode.audioUrl);
        }
      }

      if (episode.position != null && episode.position!.inSeconds > 0) {
        await _player.seek(episode.position!);
      }

      await _player.play();
      _startPositionSaving();
      _storage?.addToHistory(episode);
    } catch (e) {
      print('Error playing episode: $e');
    }
  }

  void _startPositionSaving() {
    _positionSaveTimer?.cancel();
    _positionSaveTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _savePosition();
    });
  }

  void _savePosition() {
    if (_currentEpisode != null && _storage != null) {
      final updatedEpisode = _currentEpisode!.copyWith(position: _player.position);
      _storage!.saveEpisode(updatedEpisode);
      _storage!.addToHistory(updatedEpisode);
    }
  }

  Future<void> play() async {
    await _player.play();
    _startPositionSaving();
  }

  Future<void> pause() async {
    await _player.pause();
    _positionSaveTimer?.cancel();
    _savePosition();
  }

  Future<void> stop() async {
    _positionSaveTimer?.cancel();
    _savePosition();
    await _player.stop();
    _currentEpisode = null;
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _savePosition();
  }

  Future<void> seekForward(int seconds) async {
    final newPosition = _player.position + Duration(seconds: seconds);
    if (duration != null && newPosition < duration!) {
      await _player.seek(newPosition);
    } else if (duration != null) {
      await _player.seek(duration!);
    }
  }

  Future<void> seekBackward(int seconds) async {
    final newPosition = _player.position - Duration(seconds: seconds);
    if (newPosition > Duration.zero) {
      await _player.seek(newPosition);
    } else {
      await _player.seek(Duration.zero);
    }
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  Future<void> dispose() async {
    _positionSaveTimer?.cancel();
    _savePosition();
    await _player.dispose();
  }
}