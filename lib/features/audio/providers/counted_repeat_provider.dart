import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RepeatMode { off, all, single, counted }

class CountedRepeatState {
  final RepeatMode mode;
  final int initialCount;
  final int remainingCount;

  const CountedRepeatState({
    this.mode = RepeatMode.off,
    this.initialCount = 5,
    this.remainingCount = 5,
  });

  CountedRepeatState copyWith({
    RepeatMode? mode,
    int? initialCount,
    int? remainingCount,
  }) {
    return CountedRepeatState(
      mode: mode ?? this.mode,
      initialCount: initialCount ?? this.initialCount,
      remainingCount: remainingCount ?? this.remainingCount,
    );
  }

  String get badgeText {
    switch (mode) {
      case RepeatMode.off:
        return '';
      case RepeatMode.all:
        return 'ALL';
      case RepeatMode.single:
        return '1';
      case RepeatMode.counted:
        return '$remainingCount';
    }
  }
}

class CountedRepeatNotifier extends StateNotifier<CountedRepeatState> {
  CountedRepeatNotifier() : super(const CountedRepeatState());

  void toggleMode() {
    switch (state.mode) {
      case RepeatMode.off:
        state = state.copyWith(mode: RepeatMode.all);
        break;
      case RepeatMode.all:
        state = state.copyWith(mode: RepeatMode.single);
        break;
      case RepeatMode.single:
        state = state.copyWith(
          mode: RepeatMode.counted,
          remainingCount: state.initialCount,
        );
        break;
      case RepeatMode.counted:
        state = state.copyWith(mode: RepeatMode.off);
        break;
    }
  }

  void setMode(RepeatMode mode) {
    state = state.copyWith(
      mode: mode,
      remainingCount: mode == RepeatMode.counted ? state.initialCount : state.remainingCount,
    );
  }

  void setCountedLoop(int count) {
    if (count < 1) return;
    state = state.copyWith(
      mode: RepeatMode.counted,
      initialCount: count,
      remainingCount: count,
    );
  }

  void incrementInitialCount() {
    final next = state.initialCount + 1;
    state = state.copyWith(
      initialCount: next,
      remainingCount: state.mode == RepeatMode.counted ? next : state.remainingCount,
    );
  }

  void decrementInitialCount() {
    if (state.initialCount <= 1) return;
    final next = state.initialCount - 1;
    state = state.copyWith(
      initialCount: next,
      remainingCount: state.mode == RepeatMode.counted ? next : state.remainingCount,
    );
  }

  /// Called when track finishes playback.
  /// Returns `true` if player should loop current track (seek to 0 & play).
  /// Returns `false` if player should advance to next track in queue.
  bool handleTrackCompletion() {
    if (state.mode == RepeatMode.single) {
      return true;
    }

    if (state.mode == RepeatMode.counted) {
      if (state.remainingCount > 1) {
        state = state.copyWith(remainingCount: state.remainingCount - 1);
        return true; // Loop current track again
      } else {
        // remainingCount == 1 -> Finished loop requirement. Switch to off and advance queue.
        state = state.copyWith(
          mode: RepeatMode.off,
          remainingCount: state.initialCount,
        );
        return false; // Advance to next track
      }
    }

    if (state.mode == RepeatMode.all) {
      return false; // Advance to next track in queue (queue handles wrap-around)
    }

    return false; // RepeatMode.off
  }
}

final countedRepeatProvider = StateNotifierProvider<CountedRepeatNotifier, CountedRepeatState>((ref) {
  return CountedRepeatNotifier();
});
