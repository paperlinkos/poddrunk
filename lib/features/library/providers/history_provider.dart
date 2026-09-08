import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../audio/domain/models/track_model.dart';

class HistoryState {
  final List<TrackModel> recentlyPlayed;
  final bool isLoading;

  const HistoryState({
    this.recentlyPlayed = const [],
    this.isLoading = false,
  });

  HistoryState copyWith({
    List<TrackModel>? recentlyPlayed,
    bool? isLoading,
  }) {
    return HistoryState(
      recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  static const String _storageKey = 'poddrunk_recently_played_tracks_v1';
  static const int _maxHistoryLimit = 100;

  HistoryNotifier() : super(const HistoryState(isLoading: true)) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
        final tracks = decoded
            .map((item) => TrackModel.fromJson(item as Map<String, dynamic>))
            .where((t) => !t.id.startsWith('sample_'))
            .toList();
        state = state.copyWith(recentlyPlayed: tracks, isLoading: false);
      } else {
        state = state.copyWith(recentlyPlayed: const [], isLoading: false);
      }
    } catch (e) {
      debugPrint('Failed to load playback history: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> recordTrack(TrackModel track) async {
    // Avoid sample tracks
    if (track.id.startsWith('sample_')) return;

    final updated = List<TrackModel>.from(state.recentlyPlayed);
    // Remove if already present so it bubbles to index 0
    updated.removeWhere((t) => t.id == track.id);
    updated.insert(0, track);

    // Limit maximum history size
    if (updated.length > _maxHistoryLimit) {
      updated.removeRange(_maxHistoryLimit, updated.length);
    }

    state = state.copyWith(recentlyPlayed: updated);
    await _persist();
  }

  Future<void> removeTrack(String trackId) async {
    final updated = state.recentlyPlayed.where((t) => t.id != trackId).toList();
    state = state.copyWith(recentlyPlayed: updated);
    await _persist();
  }

  Future<void> clearHistory() async {
    state = state.copyWith(recentlyPlayed: const []);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      debugPrint('Failed to clear playback history: $e');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.recentlyPlayed.map((t) => t.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Failed to persist playback history: $e');
    }
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier();
});
