import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../audio/domain/models/track_model.dart';

class LibraryState {
  final List<TrackModel> tracks;
  final bool isLoading;
  final bool hasPermission;
  final String? errorMessage;
  final String searchQuery;

  const LibraryState({
    this.tracks = const [],
    this.isLoading = true, // Default to true on initial launch to avoid flashing error screen
    this.hasPermission = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  List<TrackModel> get filteredTracks {
    if (searchQuery.trim().isEmpty) return tracks;
    final q = searchQuery.toLowerCase();
    return tracks.where((t) =>
      t.title.toLowerCase().contains(q) ||
      t.artist.toLowerCase().contains(q) ||
      t.album.toLowerCase().contains(q)
    ).toList();
  }

  LibraryState copyWith({
    List<TrackModel>? tracks,
    bool? isLoading,
    bool? hasPermission,
    String? errorMessage,
    String? searchQuery,
  }) {
    return LibraryState(
      tracks: tracks ?? this.tracks,
      isLoading: isLoading ?? this.isLoading,
      hasPermission: hasPermission ?? this.hasPermission,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class LibraryNotifier extends StateNotifier<LibraryState> {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  LibraryNotifier() : super(const LibraryState(isLoading: true)) {
    scanAudioLibrary();
  }

  Future<void> scanAudioLibrary() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      bool isGranted = false;

      // 1. Silent check first (avoids dialogs/delays if already granted)
      final audioStatus = await Permission.audio.status;
      if (audioStatus.isGranted) {
        isGranted = true;
      } else {
        final storageStatus = await Permission.storage.status;
        if (storageStatus.isGranted) {
          isGranted = true;
        } else {
          final mediaStatus = await Permission.mediaLibrary.status;
          if (mediaStatus.isGranted) {
            isGranted = true;
          }
        }
      }

      // 2. If not yet granted, request permissions sequentially
      if (!isGranted) {
        final reqAudio = await Permission.audio.request();
        if (reqAudio.isGranted) {
          isGranted = true;
        } else {
          final reqStorage = await Permission.storage.request();
          if (reqStorage.isGranted) {
            isGranted = true;
          } else {
            final reqMedia = await Permission.mediaLibrary.request();
            if (reqMedia.isGranted) {
              isGranted = true;
            }
          }
        }
      }

      // Fallback: check on_audio_query's status if needed
      if (!isGranted) {
        try {
          isGranted = await _audioQuery.permissionsStatus();
        } catch (_) {}
      }

      if (isGranted) {
        final songs = await _audioQuery.querySongs(
          sortType: SongSortType.DATE_ADDED,
          orderType: OrderType.DESC_OR_GREATER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        );

        final localTracks = songs.map((s) {
          return TrackModel(
            id: s.id.toString(),
            title: s.title.isNotEmpty ? s.title : 'Unknown Track',
            artist: s.artist != null && s.artist != '<unknown>' ? s.artist! : 'Unknown Artist',
            album: s.album != null && s.album != '<unknown>' ? s.album! : 'Unknown Album',
            duration: Duration(milliseconds: s.duration ?? 0),
            uri: s.data,
            isLocal: true,
          );
        }).toList();

        state = state.copyWith(
          tracks: localTracks,
          isLoading: false,
          hasPermission: true,
        );
        return;
      }

      // Permission not granted
      state = state.copyWith(
        tracks: const [],
        isLoading: false,
        hasPermission: false,
      );
    } catch (e) {
      state = state.copyWith(
        tracks: const [],
        isLoading: false,
        hasPermission: false,
        errorMessage: 'Unable to query device storage: $e',
      );
    }
  }

  Future<bool> deleteLocalTrack(TrackModel track) async {
    try {
      if (track.isLocal && track.uri.isNotEmpty) {
        final file = File(track.uri);
        if (await file.exists()) {
          await file.delete();
        }
      }
      final updatedTracks = state.tracks.where((t) => t.id != track.id).toList();
      state = state.copyWith(tracks: updatedTracks);
      return true;
    } catch (e) {
      debugPrint('Failed to delete track file: $e');
      return false;
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>((ref) {
  return LibraryNotifier();
});
