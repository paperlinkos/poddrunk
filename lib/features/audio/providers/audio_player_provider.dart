import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../services/audio_handler.dart';
import '../domain/models/track_model.dart';
import 'counted_repeat_provider.dart';
import 'sleep_timer_provider.dart';
import '../../queue/providers/queue_provider.dart';

class AudioPlayerState {
  final TrackModel? currentTrack;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final double speed;

  const AudioPlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
  });

  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  AudioPlayerState copyWith({
    TrackModel? currentTrack,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    double? speed,
  }) {
    return AudioPlayerState(
      currentTrack: currentTrack ?? this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
    );
  }
}

final audioHandlerProvider = Provider<PoddrunkAudioHandler?>((ref) {
  return null;
});

class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final Ref _ref;
  PoddrunkAudioHandler? _handler;
  late final AudioPlayer _fallbackPlayer;

  AudioPlayerNotifier(this._ref) : super(const AudioPlayerState()) {
    _fallbackPlayer = AudioPlayer();
    _setupPlayerListeners(activePlayer);
    _initQueueListener();
  }

  AudioPlayer get activePlayer => _handler?.player ?? _fallbackPlayer;

  void setHandler(PoddrunkAudioHandler handler) {
    _handler = handler;
    _setupPlayerListeners(_handler!.player);
  }

  void _initQueueListener() {
    _ref.listen<QueueState>(queueProvider, (previous, next) {
      if (next.currentTrack != state.currentTrack && next.currentTrack != null) {
        _playTrack(next.currentTrack!);
      }
    });
  }

  void _setupPlayerListeners(AudioPlayer player) {
    // Listen to player state (playing, completion)
    player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      state = state.copyWith(
        isPlaying: isPlaying,
        isBuffering: processingState == ProcessingState.buffering || processingState == ProcessingState.loading,
      );

      // Handle track completion for Counted Repeat Engine
      if (processingState == ProcessingState.completed) {
        _onTrackCompleted();
      }
    });

    // Listen to position stream
    player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    // Listen to duration stream
    player.durationStream.listen((dur) {
      if (dur != null) {
        state = state.copyWith(duration: dur);
      }
    });
  }

  void _onTrackCompleted() async {
    // Check if sleep timer is waiting for end of track
    _ref.read(sleepTimerProvider.notifier).onTrackCompleted();

    final repeatNotifier = _ref.read(countedRepeatProvider.notifier);
    final shouldLoopCurrent = repeatNotifier.handleTrackCompletion();

    if (shouldLoopCurrent) {
      // Seek back to start and continue playing current track
      await seek(Duration.zero);
      await activePlayer.play();
    } else {
      // Advance to next track in queue
      final nextTrack = _ref.read(queueProvider.notifier).nextTrack();
      if (nextTrack != null) {
        await _playTrack(nextTrack);
      } else {
        await seek(Duration.zero);
        await activePlayer.pause();
      }
    }
  }

  Future<void> playTrack(TrackModel track, {List<TrackModel>? queue, int index = 0}) async {
    if (queue != null && queue.isNotEmpty) {
      _ref.read(queueProvider.notifier).setQueue(queue, initialIndex: index);
    }
    await _playTrack(track);
  }

  Future<void> _playTrack(TrackModel track) async {
    state = state.copyWith(
      currentTrack: track,
      isPlaying: true,
      isBuffering: true,
      position: Duration.zero,
      duration: track.duration,
    );

    try {
      if (_handler != null) {
        await _handler!.playTrack(track);
      } else {
        if (track.isLocal) {
          await _fallbackPlayer.setFilePath(track.uri);
        } else {
          await _fallbackPlayer.setUrl(track.uri);
        }
        await _fallbackPlayer.play();
      }
    } catch (e, st) {
      debugPrint('Playback error for ${track.title}: $e\n$st');
      state = state.copyWith(isPlaying: false, isBuffering: false);
    }
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      if (_handler != null) {
        await _handler!.pause();
      } else {
        await _fallbackPlayer.pause();
      }
    } else {
      if (state.currentTrack != null) {
        if (_handler != null) {
          await _handler!.play();
        } else {
          await _fallbackPlayer.play();
        }
      }
    }
  }

  Future<void> seek(Duration position) async {
    if (_handler != null) {
      await _handler!.seek(position);
    } else {
      await _fallbackPlayer.seek(position);
    }
  }

  Future<void> seekBy(int seconds) async {
    final currentPos = state.position;
    final targetPos = currentPos + Duration(seconds: seconds);
    final clamped = targetPos < Duration.zero
        ? Duration.zero
        : (targetPos > state.duration ? state.duration : targetPos);
    await seek(clamped);
  }

  Future<void> skipNext() async {
    final nextTrack = _ref.read(queueProvider.notifier).nextTrack();
    if (nextTrack != null) {
      await _playTrack(nextTrack);
    }
  }

  Future<void> skipPrevious() async {
    final prevTrack = _ref.read(queueProvider.notifier).previousTrack();
    if (prevTrack != null) {
      await _playTrack(prevTrack);
    }
  }

  void playNext(TrackModel track) {
    _ref.read(queueProvider.notifier).playNext(track);
  }

  void addToQueue(TrackModel track) {
    _ref.read(queueProvider.notifier).addToQueue(track);
  }

  Future<void> setSpeed(double speed) async {
    state = state.copyWith(speed: speed);
    try {
      if (_handler != null) {
        await _handler!.setSpeed(speed);
      } else {
        await _fallbackPlayer.setSpeed(speed);
      }
    } catch (e) {
      debugPrint('Error setting playback speed: $e');
    }
  }

  @override
  void dispose() {
    _fallbackPlayer.dispose();
    super.dispose();
  }
}

final audioPlayerProvider = StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  final notifier = AudioPlayerNotifier(ref);
  final handler = ref.watch(audioHandlerProvider);
  if (handler != null) {
    notifier.setHandler(handler);
  }
  return notifier;
});
