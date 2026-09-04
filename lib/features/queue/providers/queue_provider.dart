import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../audio/domain/models/track_model.dart';

class QueueState {
  final List<TrackModel> originalQueue;
  final List<int> displayIndices; // Pointer map into originalQueue
  final int currentIndex; // Index in displayIndices
  final bool isShuffle;

  const QueueState({
    this.originalQueue = const [],
    this.displayIndices = const [],
    this.currentIndex = 0,
    this.isShuffle = false,
  });

  TrackModel? get currentTrack {
    if (displayIndices.isEmpty || currentIndex < 0 || currentIndex >= displayIndices.length) {
      return null;
    }
    final originalIdx = displayIndices[currentIndex];
    if (originalIdx < 0 || originalIdx >= originalQueue.length) return null;
    return originalQueue[originalIdx];
  }

  List<TrackModel> get currentQueue {
    return displayIndices.map((i) => originalQueue[i]).toList();
  }

  QueueState copyWith({
    List<TrackModel>? originalQueue,
    List<int>? displayIndices,
    int? currentIndex,
    bool? isShuffle,
  }) {
    return QueueState(
      originalQueue: originalQueue ?? this.originalQueue,
      displayIndices: displayIndices ?? this.displayIndices,
      currentIndex: currentIndex ?? this.currentIndex,
      isShuffle: isShuffle ?? this.isShuffle,
    );
  }
}

class QueueNotifier extends StateNotifier<QueueState> {
  QueueNotifier() : super(const QueueState());

  void setQueue(List<TrackModel> tracks, {int initialIndex = 0}) {
    final indices = List<int>.generate(tracks.length, (i) => i);
    state = QueueState(
      originalQueue: tracks,
      displayIndices: indices,
      currentIndex: initialIndex.clamp(0, max(0, tracks.length - 1)),
      isShuffle: false,
    );
  }

  void toggleShuffle() {
    if (state.originalQueue.isEmpty) return;

    if (!state.isShuffle) {
      // Enable shuffle: preserve current playing track as first item in shuffled list
      final currentOrigIdx = state.displayIndices[state.currentIndex];
      final remaining = List<int>.generate(state.originalQueue.length, (i) => i)
        ..remove(currentOrigIdx);
      remaining.shuffle(Random());
      
      final shuffledIndices = [currentOrigIdx, ...remaining];
      state = state.copyWith(
        displayIndices: shuffledIndices,
        currentIndex: 0,
        isShuffle: true,
      );
    } else {
      // Disable shuffle: return to original sequence, locate current track position
      final currentOrigIdx = state.displayIndices[state.currentIndex];
      final originalIndices = List<int>.generate(state.originalQueue.length, (i) => i);
      final newIdx = originalIndices.indexOf(currentOrigIdx);
      
      state = state.copyWith(
        displayIndices: originalIndices,
        currentIndex: newIdx >= 0 ? newIdx : 0,
        isShuffle: false,
      );
    }
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final indices = List<int>.from(state.displayIndices);
    final movedItem = indices.removeAt(oldIndex);
    indices.insert(newIndex, movedItem);

    int newCurrentIdx = state.currentIndex;
    if (oldIndex == state.currentIndex) {
      newCurrentIdx = newIndex;
    } else if (oldIndex < state.currentIndex && newIndex >= state.currentIndex) {
      newCurrentIdx -= 1;
    } else if (oldIndex > state.currentIndex && newIndex <= state.currentIndex) {
      newCurrentIdx += 1;
    }

    state = state.copyWith(
      displayIndices: indices,
      currentIndex: newCurrentIdx,
    );
  }

  void playTrackAtIndex(int index) {
    if (index >= 0 && index < state.displayIndices.length) {
      state = state.copyWith(currentIndex: index);
    }
  }

  TrackModel? nextTrack() {
    if (state.displayIndices.isEmpty) return null;
    final nextIdx = state.currentIndex + 1;
    if (nextIdx < state.displayIndices.length) {
      state = state.copyWith(currentIndex: nextIdx);
      return state.currentTrack;
    } else {
      // Wrap around to start of queue
      state = state.copyWith(currentIndex: 0);
      return state.currentTrack;
    }
  }

  TrackModel? previousTrack() {
    if (state.displayIndices.isEmpty) return null;
    final prevIdx = state.currentIndex - 1;
    if (prevIdx >= 0) {
      state = state.copyWith(currentIndex: prevIdx);
      return state.currentTrack;
    } else {
      // Go to last track
      state = state.copyWith(currentIndex: state.displayIndices.length - 1);
      return state.currentTrack;
    }
  }

  void playNext(TrackModel track) {
    final origQueue = List<TrackModel>.from(state.originalQueue);
    origQueue.add(track);
    final newTrackOrigIdx = origQueue.length - 1;

    final indices = List<int>.from(state.displayIndices);
    final insertPosition = state.displayIndices.isEmpty ? 0 : state.currentIndex + 1;
    indices.insert(insertPosition, newTrackOrigIdx);

    state = state.copyWith(
      originalQueue: origQueue,
      displayIndices: indices,
    );
  }

  void addToQueue(TrackModel track) {
    final origQueue = List<TrackModel>.from(state.originalQueue);
    origQueue.add(track);
    final newTrackOrigIdx = origQueue.length - 1;

    final indices = List<int>.from(state.displayIndices);
    indices.add(newTrackOrigIdx);

    state = state.copyWith(
      originalQueue: origQueue,
      displayIndices: indices,
    );
  }

  void removeTrackAt(int index) {
    if (index < 0 || index >= state.displayIndices.length) return;
    final indices = List<int>.from(state.displayIndices);
    indices.removeAt(index);

    int newCurrent = state.currentIndex;
    if (index < state.currentIndex) {
      newCurrent -= 1;
    } else if (index == state.currentIndex && newCurrent >= indices.length) {
      newCurrent = max(0, indices.length - 1);
    }

    state = state.copyWith(
      displayIndices: indices,
      currentIndex: newCurrent,
    );
  }
}

final queueProvider = StateNotifierProvider<QueueNotifier, QueueState>((ref) {
  return QueueNotifier();
});
