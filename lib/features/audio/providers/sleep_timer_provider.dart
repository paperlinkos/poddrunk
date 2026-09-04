import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_player_provider.dart';

class SleepTimerState {
  final bool isActive;
  final Duration? initialDuration;
  final Duration remaining;
  final bool isEndOfTrack;

  const SleepTimerState({
    this.isActive = false,
    this.initialDuration,
    this.remaining = Duration.zero,
    this.isEndOfTrack = false,
  });

  String get formattedRemaining {
    if (!isActive) return '';
    if (isEndOfTrack) return 'End of song';
    final minutes = remaining.inMinutes;
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  SleepTimerState copyWith({
    bool? isActive,
    Duration? initialDuration,
    Duration? remaining,
    bool? isEndOfTrack,
  }) {
    return SleepTimerState(
      isActive: isActive ?? this.isActive,
      initialDuration: initialDuration ?? this.initialDuration,
      remaining: remaining ?? this.remaining,
      isEndOfTrack: isEndOfTrack ?? this.isEndOfTrack,
    );
  }
}

class SleepTimerNotifier extends StateNotifier<SleepTimerState> {
  final Ref _ref;
  Timer? _ticker;

  SleepTimerNotifier(this._ref) : super(const SleepTimerState());

  void startTimer(Duration duration) {
    _ticker?.cancel();

    state = SleepTimerState(
      isActive: true,
      initialDuration: duration,
      remaining: duration,
      isEndOfTrack: false,
    );

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remaining.inSeconds <= 1) {
        _triggerSleep();
      } else {
        state = state.copyWith(
          remaining: state.remaining - const Duration(seconds: 1),
        );
      }
    });
  }

  void setEndOfTrack() {
    _ticker?.cancel();
    state = const SleepTimerState(
      isActive: true,
      isEndOfTrack: true,
    );
  }

  void onTrackCompleted() {
    if (state.isActive && state.isEndOfTrack) {
      _triggerSleep();
    }
  }

  void cancelTimer() {
    _ticker?.cancel();
    state = const SleepTimerState();
  }

  void _triggerSleep() {
    _ticker?.cancel();
    _ref.read(audioPlayerProvider.notifier).activePlayer.pause();
    state = const SleepTimerState();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final sleepTimerProvider = StateNotifierProvider<SleepTimerNotifier, SleepTimerState>((ref) {
  return SleepTimerNotifier(ref);
});
