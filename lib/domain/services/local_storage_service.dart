import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/dummy_data.dart';
import '../entities/podcast.dart';
import '../entities/episode.dart';

class LocalStorageService {
  late Box _settingsBox;
  late Box _podcastsBox;
  late Box _episodesBox;
  late Box _subscriptionsBox;
  late Box _downloadsBox;
  late Box _historyBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox(HiveBoxes.settings);
    _podcastsBox = await Hive.openBox(HiveBoxes.podcasts);
    _episodesBox = await Hive.openBox(HiveBoxes.episodes);
    _subscriptionsBox = await Hive.openBox(HiveBoxes.subscriptions);
    _downloadsBox = await Hive.openBox(HiveBoxes.downloads);
    _historyBox = await Hive.openBox('history');
  }

  Future<void> savePodcast(Podcast podcast) async {
    await _podcastsBox.put(podcast.id, jsonEncode(podcast.toJson()));
  }

  Podcast? getPodcast(String id) {
    final data = _podcastsBox.get(id);
    if (data != null) {
      return Podcast.fromJson(jsonDecode(data));
    }
    return null;
  }

  List<Podcast> getAllPodcasts() {
    return _podcastsBox.values
        .map((data) => Podcast.fromJson(jsonDecode(data)))
        .toList();
  }

  Future<void> saveEpisode(Episode episode) async {
    await _episodesBox.put(episode.id, jsonEncode(episode.toJson()));
  }

  Episode? getEpisode(String id) {
    final data = _episodesBox.get(id);
    if (data != null) {
      return Episode.fromJson(jsonDecode(data));
    }
    return null;
  }

  List<Episode> getEpisodesForPodcast(String podcastId) {
    return _episodesBox.values
        .map((data) => Episode.fromJson(jsonDecode(data)))
        .where((e) => e.podcastId == podcastId)
        .toList();
  }

  Future<void> subscribe(String podcastId) async {
    await _subscriptionsBox.put(podcastId, DateTime.now().toIso8601String());
    final podcast = getPodcast(podcastId);
    if (podcast != null) {
      await savePodcast(podcast.copyWith(isSubscribed: true));
    }
  }

  Future<void> unsubscribe(String podcastId) async {
    await _subscriptionsBox.delete(podcastId);
    final podcast = getPodcast(podcastId);
    if (podcast != null) {
      await savePodcast(podcast.copyWith(isSubscribed: false));
    }
  }

  bool isSubscribed(String podcastId) {
    return _subscriptionsBox.containsKey(podcastId);
  }

  List<String> getSubscribedPodcastIds() {
    return _subscriptionsBox.keys.cast<String>().toList();
  }

  List<Podcast> getSubscribedPodcasts() {
    return getSubscribedPodcastIds()
        .map((id) => getPodcast(id))
        .whereType<Podcast>()
        .toList();
  }

  Future<void> downloadEpisode(Episode episode, String localPath) async {
    await _downloadsBox.put(episode.id, localPath);
    await saveEpisode(episode.copyWith(
      isDownloaded: true,
      localPath: localPath,
    ));
  }

  Future<void> removeDownload(String episodeId) async {
    await _downloadsBox.delete(episodeId);
    final episode = getEpisode(episodeId);
    if (episode != null) {
      await saveEpisode(episode.copyWith(
        isDownloaded: false,
        localPath: null,
      ));
    }
  }

  bool isDownloaded(String episodeId) {
    return _downloadsBox.containsKey(episodeId);
  }

  String? getDownloadPath(String episodeId) {
    return _downloadsBox.get(episodeId);
  }

  List<Episode> getDownloadedEpisodes() {
    return _episodesBox.values
        .map((data) => Episode.fromJson(jsonDecode(data)))
        .where((e) => e.isDownloaded)
        .toList();
  }

  T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  Future<void> setSetting<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }

  Future<void> clearAll() async {
    await _settingsBox.clear();
    await _podcastsBox.clear();
    await _episodesBox.clear();
    await _subscriptionsBox.clear();
    await _downloadsBox.clear();
    await _historyBox.clear();
  }

  bool get isFirstLaunch => !_settingsBox.containsKey('has_launched');

  Future<void> addToHistory(Episode episode) async {
    final historyItem = {
      'episodeId': episode.id,
      'playedAt': DateTime.now().toIso8601String(),
      'position': episode.position?.inSeconds ?? 0,
    };
    await _historyBox.put(episode.id, jsonEncode(historyItem));
  }

  List<Map<String, dynamic>> getHistory({int limit = 50}) {
    final history = _historyBox.values
        .map((data) => Map<String, dynamic>.from(jsonDecode(data)))
        .toList();
    history.sort((a, b) {
      final aDate = DateTime.parse(a['playedAt'] as String);
      final bDate = DateTime.parse(b['playedAt'] as String);
      return bDate.compareTo(aDate);
    });
    return history.take(limit).toList();
  }

  List<Episode> getRecentEpisodes({int limit = 20}) {
    final history = getHistory(limit: limit);
    return history.map((item) {
      final episodeId = item['episodeId'] as String;
      final episode = getEpisode(episodeId);
      if (episode != null) {
        final position = item['position'] as int? ?? 0;
        return episode.copyWith(position: Duration(seconds: position));
      }
      return null;
    }).whereType<Episode>().toList();
  }

  Future<void> clearHistory() async {
    await _historyBox.clear();
  }

  Future<void> loadDummyDataIfNeeded() async {
    await clearAll();
    final podcasts = DummyData.getPodcasts();
    for (final podcast in podcasts) {
      await savePodcast(podcast);
      final episodes = DummyData.getEpisodesForPodcast(podcast.id);
      for (final episode in episodes) {
        await saveEpisode(episode);
      }
      if (podcast.isSubscribed) {
        await subscribe(podcast.id);
      }
    }
  }
}