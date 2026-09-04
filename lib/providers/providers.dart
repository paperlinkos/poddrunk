import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/episode.dart';
import '../domain/entities/podcast.dart';
import '../domain/services/audio_player_service.dart';
import '../domain/services/local_storage_service.dart';
import '../domain/services/rss_parser_service.dart';
import '../domain/services/download_service.dart';
import '../domain/services/notification_service.dart';

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  final storage = ref.watch(localStorageServiceProvider);
  service.setStorage(storage);
  ref.onDispose(() => service.dispose());
  return service;
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final rssParserServiceProvider = Provider<RssParserService>((ref) {
  return RssParserService();
});

final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final isDarkModeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return ThemeNotifier(storage);
});

class ThemeNotifier extends StateNotifier<bool> {
  final LocalStorageService _storage;

  ThemeNotifier(this._storage) : super(true) {
    _loadTheme();
  }

  void _loadTheme() {
    state = _storage.getSetting<bool>('isDarkMode') ?? true;
  }

  Future<void> toggleTheme() async {
    state = !state;
    await _storage.setSetting('isDarkMode', state);
  }
}

final playbackSpeedProvider = StateProvider<double>((ref) => 1.0);

final currentTabIndexProvider = StateProvider<int>((ref) => 0);

final isPlayingProvider = StreamProvider<bool>((ref) {
  final player = ref.watch(audioPlayerServiceProvider);
  return player.playingStream;
});

final positionProvider = StreamProvider<Duration>((ref) {
  final player = ref.watch(audioPlayerServiceProvider);
  return player.positionStream;
});

final durationProvider = StreamProvider<Duration?>((ref) {
  final player = ref.watch(audioPlayerServiceProvider);
  return player.durationStream;
});

final currentEpisodeProvider = StateProvider<Episode?>((ref) => null);

class PodcastNotifier extends StateNotifier<AsyncValue<List<Podcast>>> {
  final RssParserService _rssParser;
  final LocalStorageService _storage;

  PodcastNotifier(this._rssParser, this._storage)
      : super(const AsyncValue.loading()) {
    loadPodcasts();
  }

  Future<void> loadPodcasts() async {
    state = const AsyncValue.loading();
    try {
      final podcasts = _storage.getAllPodcasts();
      if (podcasts.isEmpty) {
        state = const AsyncValue.data([]);
      } else {
        state = AsyncValue.data(podcasts);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addPodcast(String feedUrl) async {
    try {
      final result = await _rssParser.parseFeed(feedUrl);
      await _storage.savePodcast(result.podcast);
      for (final episode in result.episodes) {
        await _storage.saveEpisode(episode);
      }
      await loadPodcasts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> subscribe(String podcastId) async {
    await _storage.subscribe(podcastId);
    await loadPodcasts();
  }

  Future<void> unsubscribe(String podcastId) async {
    await _storage.unsubscribe(podcastId);
    await loadPodcasts();
  }

  bool isSubscribed(String podcastId) {
    return _storage.isSubscribed(podcastId);
  }
}

final podcastProvider = StateNotifierProvider<PodcastNotifier, AsyncValue<List<Podcast>>>((ref) {
  final rssParser = ref.watch(rssParserServiceProvider);
  final storage = ref.watch(localStorageServiceProvider);
  return PodcastNotifier(rssParser, storage);
});

class EpisodeNotifier extends StateNotifier<AsyncValue<List<Episode>>> {
  final LocalStorageService _storage;
  final String? podcastId;

  EpisodeNotifier(this._storage, this.podcastId)
      : super(const AsyncValue.loading()) {
    if (podcastId != null) {
      loadEpisodes();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadEpisodes() async {
    if (podcastId == null) return;
    state = const AsyncValue.loading();
    try {
      final episodes = _storage.getEpisodesForPodcast(podcastId!);
      episodes.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      state = AsyncValue.data(episodes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final episodesProvider = StateNotifierProvider.family<EpisodeNotifier, AsyncValue<List<Episode>>, String>((ref, podcastId) {
  final storage = ref.watch(localStorageServiceProvider);
  return EpisodeNotifier(storage, podcastId);
});

final downloadedEpisodesProvider = Provider<List<Episode>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return storage.getDownloadedEpisodes();
});

final subscribedPodcastsProvider = Provider<List<Podcast>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return storage.getSubscribedPodcasts();
});

class DownloadProgressNotifier extends StateNotifier<Map<String, double>> {
  final DownloadService _downloadService;
  final LocalStorageService _storage;

  DownloadProgressNotifier(this._downloadService, this._storage) : super({});

  Future<void> downloadEpisode(Episode episode) async {
    if (state.containsKey(episode.id)) return;

    state = {...state, episode.id: 0.0};

    try {
      final path = await _downloadService.downloadEpisode(episode);
      if (path != null) {
        await _storage.downloadEpisode(episode, path);
      }
      state = Map.from(state)..remove(episode.id);
    } catch (e) {
      state = Map.from(state)..remove(episode.id);
    }
  }

  Future<void> cancelDownload(String episodeId) async {
    await _downloadService.cancelDownload(episodeId);
    state = Map.from(state)..remove(episodeId);
  }

  Future<void> deleteDownload(Episode episode) async {
    if (episode.localPath != null) {
      await _downloadService.deleteDownload(episode.localPath!);
    }
    await _storage.removeDownload(episode.id);
  }

  bool isDownloading(String episodeId) => state.containsKey(episodeId);
}

final downloadProgressProvider = StateNotifierProvider<DownloadProgressNotifier, Map<String, double>>((ref) {
  final downloadService = ref.watch(downloadServiceProvider);
  final storage = ref.watch(localStorageServiceProvider);
  return DownloadProgressNotifier(downloadService, storage);
});

final recentlyPlayedProvider = Provider<List<Episode>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return storage.getRecentEpisodes();
});

final queueProvider = StateProvider<List<Episode>>((ref) => []);

class SleepTimerNotifier extends StateNotifier<Duration?> {
  SleepTimerNotifier() : super(null);

  Timer? _timer;

  void setSleepTimer(Duration duration) {
    _timer?.cancel();
    state = duration;
    _timer = Timer(duration, () {
      state = null;
    });
  }

  void cancelSleepTimer() {
    _timer?.cancel();
    state = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final sleepTimerProvider = StateNotifierProvider<SleepTimerNotifier, Duration?>((ref) {
  return SleepTimerNotifier();
});