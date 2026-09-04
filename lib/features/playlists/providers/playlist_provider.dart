import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../audio/domain/models/track_model.dart';
import '../domain/models/playlist_model.dart';

class PlaylistState {
  final List<PlaylistModel> playlists;
  final bool isLoading;
  final String? errorMessage;

  const PlaylistState({
    this.playlists = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PlaylistModel? getPlaylistById(String id) {
    try {
      return playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  PlaylistState copyWith({
    List<PlaylistModel>? playlists,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PlaylistState(
      playlists: playlists ?? this.playlists,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class PlaylistNotifier extends StateNotifier<PlaylistState> {
  static const String _storageKey = 'poddrunk_user_playlists_v1';

  PlaylistNotifier() : super(const PlaylistState(isLoading: true)) {
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_storageKey);

      if (rawJson != null && rawJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
        final loaded = decoded
            .map((item) => PlaylistModel.fromJson(item as Map<String, dynamic>))
            .map((p) => p.copyWith(
                  tracks: p.tracks.where((t) => !t.id.startsWith('sample_')).toList(),
                ))
            .toList();

        state = state.copyWith(playlists: loaded, isLoading: false);
      } else {
        // Initialize with default Favorites & Heavy Rotation playlists
        final defaultPlaylists = [
          PlaylistModel(
            id: 'favorites',
            name: 'FAVORITES',
            description: 'Loved & starred tracks',
            tracks: const [],
            createdAt: DateTime.now(),
            colorIndex: 0,
          ),
          PlaylistModel(
            id: 'heavy_rotation',
            name: 'HEAVY ROTATION',
            description: 'Daily editorial rotation',
            tracks: const [],
            createdAt: DateTime.now(),
            colorIndex: 1,
          ),
        ];
        state = state.copyWith(playlists: defaultPlaylists, isLoading: false);
        await _persist();
      }
    } catch (e) {
      debugPrint('Error loading playlists: $e');
      state = state.copyWith(isLoading: false, errorMessage: 'Could not load playlists: $e');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.playlists.map((p) => p.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Error saving playlists: $e');
    }
  }

  Future<PlaylistModel> createPlaylist(String name, {String description = '', int colorIndex = 0}) async {
    final newPlaylist = PlaylistModel(
      id: 'playlist_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'NEW PLAYLIST' : name.trim(),
      description: description.trim(),
      tracks: const [],
      createdAt: DateTime.now(),
      colorIndex: colorIndex,
    );

    state = state.copyWith(playlists: [...state.playlists, newPlaylist]);
    await _persist();
    return newPlaylist;
  }

  Future<void> renamePlaylist(String id, String newName) async {
    final updated = state.playlists.map((p) {
      if (p.id == id) {
        return p.copyWith(name: newName.trim());
      }
      return p;
    }).toList();

    state = state.copyWith(playlists: updated);
    await _persist();
  }

  Future<void> deletePlaylist(String id) async {
    final updated = state.playlists.where((p) => p.id != id).toList();
    state = state.copyWith(playlists: updated);
    await _persist();
  }

  Future<bool> addTrackToPlaylist(String playlistId, TrackModel track) async {
    bool added = false;
    final updated = state.playlists.map((p) {
      if (p.id == playlistId) {
        // Prevent duplicate tracks if already in playlist
        final existingIdx = p.tracks.indexWhere((t) => t.id == track.id);
        if (existingIdx == -1) {
          added = true;
          return p.copyWith(tracks: [...p.tracks, track]);
        }
      }
      return p;
    }).toList();

    if (added) {
      state = state.copyWith(playlists: updated);
      await _persist();
    }
    return added;
  }

  Future<void> removeTrackFromPlaylist(String playlistId, String trackId) async {
    final updated = state.playlists.map((p) {
      if (p.id == playlistId) {
        return p.copyWith(tracks: p.tracks.where((t) => t.id != trackId).toList());
      }
      return p;
    }).toList();

    state = state.copyWith(playlists: updated);
    await _persist();
  }

  Future<void> removeTrackAtIndex(String playlistId, int index) async {
    final updated = state.playlists.map((p) {
      if (p.id == playlistId && index >= 0 && index < p.tracks.length) {
        final currentTracks = List<TrackModel>.from(p.tracks)..removeAt(index);
        return p.copyWith(tracks: currentTracks);
      }
      return p;
    }).toList();

    state = state.copyWith(playlists: updated);
    await _persist();
  }

  Future<void> reorderTracks(String playlistId, int oldIndex, int newIndex) async {
    final updated = state.playlists.map((p) {
      if (p.id == playlistId) {
        var idx = newIndex;
        if (oldIndex < idx) idx -= 1;
        final tracksList = List<TrackModel>.from(p.tracks);
        final item = tracksList.removeAt(oldIndex);
        tracksList.insert(idx, item);
        return p.copyWith(tracks: tracksList);
      }
      return p;
    }).toList();

    state = state.copyWith(playlists: updated);
    await _persist();
  }

  bool isFavorite(String trackId) {
    final fav = state.getPlaylistById('favorites');
    if (fav == null) return false;
    return fav.tracks.any((t) => t.id == trackId);
  }

  Future<void> toggleFavorite(TrackModel track) async {
    if (isFavorite(track.id)) {
      await removeTrackFromPlaylist('favorites', track.id);
    } else {
      await addTrackToPlaylist('favorites', track);
    }
  }
}

final playlistProvider = StateNotifierProvider<PlaylistNotifier, PlaylistState>((ref) {
  return PlaylistNotifier();
});
