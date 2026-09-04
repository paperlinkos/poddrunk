import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../domain/models/track_model.dart';

Future<PoddrunkAudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => PoddrunkAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.neobrutalism.poddrunk.channel.audio',
      androidNotificationChannelName: 'Poddrunk Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
    ),
  );
}

class PoddrunkAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer player = AudioPlayer();

  PoddrunkAudioHandler() {
    _init();
  }

  void _init() {
    // Listen to player state and update AudioService broadcast
    player.playerStateStream.listen((playerState) {
      final playing = playerState.playing;
      final processingState = playerState.processingState;

      AudioProcessingState audioProcState;
      switch (processingState) {
        case ProcessingState.idle:
          audioProcState = AudioProcessingState.idle;
          break;
        case ProcessingState.loading:
        case ProcessingState.buffering:
          audioProcState = AudioProcessingState.buffering;
          break;
        case ProcessingState.ready:
          audioProcState = AudioProcessingState.ready;
          break;
        case ProcessingState.completed:
          audioProcState = AudioProcessingState.completed;
          break;
      }

      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: audioProcState,
        playing: playing,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
        queueIndex: player.currentIndex,
      ));
    });

    // Listen to position updates
    player.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
      ));
    });
  }

  Future<void> playTrack(TrackModel track) async {
    final mediaItem = MediaItem(
      id: track.id,
      title: track.title,
      artist: track.artist,
      album: track.album,
      duration: track.duration,
      artUri: track.artworkPath != null ? Uri.file(track.artworkPath!) : null,
    );

    this.mediaItem.add(mediaItem);

    try {
      if (track.isLocal) {
        await player.setFilePath(track.uri);
      } else {
        await player.setUrl(track.uri);
      }
      await player.play();
    } catch (e, st) {
      debugPrint('PoddrunkAudioHandler error playing ${track.title}: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() async {
    await player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> seekForward(bool begin) async {
    final currentPos = player.position;
    await player.seek(currentPos + const Duration(seconds: 30));
  }

  @override
  Future<void> seekBackward(bool begin) async {
    final currentPos = player.position;
    final target = currentPos - const Duration(seconds: 30);
    await player.seek(target < Duration.zero ? Duration.zero : target);
  }
}
