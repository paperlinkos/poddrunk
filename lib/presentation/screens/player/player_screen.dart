import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../../domain/entities/episode.dart';
import '../../../domain/entities/podcast.dart';
import '../../../providers/providers.dart';
import '../podcast/podcast_detail_screen.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentEpisode = ref.watch(currentEpisodeProvider);
    final isPlayingAsync = ref.watch(isPlayingProvider);
    final positionAsync = ref.watch(positionProvider);
    final durationAsync = ref.watch(durationProvider);
    final playbackSpeed = ref.watch(playbackSpeedProvider);
    final sleepTimer = ref.watch(sleepTimerProvider);
    final downloadProgress = ref.watch(downloadProgressProvider);

    if (currentEpisode == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No episode playing')),
      );
    }

    final isPlaying = isPlayingAsync.valueOrNull ?? false;
    final position = positionAsync.valueOrNull ?? Duration.zero;
    final duration = durationAsync.valueOrNull ?? Duration.zero;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Now Playing'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(context, ref, value, currentEpisode),
            itemBuilder: (context) {
              final isDownloading = downloadProgress.containsKey(currentEpisode.id);
              final progress = downloadProgress[currentEpisode.id];
              
              return [
                PopupMenuItem(
                  value: 'download',
                  child: ListTile(
                    leading: currentEpisode.isDownloaded
                        ? const Icon(Icons.download_done, color: Colors.green)
                        : isDownloading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.download_outlined),
                    title: Text(
                      currentEpisode.isDownloaded
                          ? 'Downloaded'
                          : isDownloading
                              ? 'Downloading ${((progress ?? 0) * 100).toInt()}%'
                              : 'Download',
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'add_queue',
                  child: ListTile(
                    leading: Icon(Icons.queue),
                    title: Text('Add to Queue'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'go_podcast',
                  child: ListTile(
                    leading: Icon(Icons.podcasts),
                    title: Text('Go to Podcast'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'mark_played',
                  child: ListTile(
                    leading: Icon(Icons.check_circle_outline),
                    title: Text('Mark as Played'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: currentEpisode.imageUrl.isNotEmpty
                          ? currentEpisode.imageUrl
                          : 'https://via.placeholder.com/300',
                      width: 280,
                      height: 280,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.podcasts, size: 100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    currentEpisode.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Episode',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                  ),
                  child: Slider(
                    value: duration.inMilliseconds > 0
                        ? position.inMilliseconds / duration.inMilliseconds
                        : 0,
                    onChanged: (value) {
                      final newPosition = Duration(
                        milliseconds: (value * duration.inMilliseconds).toInt(),
                      );
                      ref.read(audioPlayerServiceProvider).seek(newPosition);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        _formatDuration(duration),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      iconSize: 36,
                      onPressed: () {
                        ref.read(audioPlayerServiceProvider).seekBackward(10);
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        iconSize: 48,
                        onPressed: () async {
                          final player = ref.read(audioPlayerServiceProvider);
                          if (isPlaying) {
                            await player.pause();
                          } else {
                            await player.play();
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_30),
                      iconSize: 36,
                      onPressed: () {
                        ref.read(audioPlayerServiceProvider).seekForward(30);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.speed),
                      onPressed: () {
                        _showSpeedPicker(context, ref, playbackSpeed);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.timer_outlined,
                        color: sleepTimer != null ? Theme.of(context).colorScheme.primary : null,
                      ),
                      onPressed: () {
                        _showSleepTimer(context, ref);
                      },
                    ),
                    IconButton(
                      icon: Stack(
                        children: [
                          const Icon(Icons.queue_music),
                          if (ref.watch(queueProvider).isNotEmpty)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 12,
                                  minHeight: 12,
                                ),
                                child: Text(
                                  '${ref.watch(queueProvider).length}',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onPressed: () => _showQueue(context, ref),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => _shareEpisode(currentEpisode),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showSpeedPicker(BuildContext context, WidgetRef ref, double currentSpeed) {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Playback Speed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...speeds.map((speed) => ListTile(
                title: Text('${speed}x'),
                trailing: speed == currentSpeed
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  ref.read(playbackSpeedProvider.notifier).state = speed;
                  ref.read(audioPlayerServiceProvider).setSpeed(speed);
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }

  void _showSleepTimer(BuildContext context, WidgetRef ref) {
    final times = [5, 10, 15, 30, 45, 60, 90];
    final currentTimer = ref.read(sleepTimerProvider);
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Sleep Timer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text('Off'),
            trailing: currentTimer == null ? const Icon(Icons.check, color: Colors.green) : null,
            onTap: () {
              ref.read(sleepTimerProvider.notifier).cancelSleepTimer();
              Navigator.pop(context);
            },
          ),
          ...times.map((minutes) => ListTile(
                title: Text('$minutes minutes'),
                trailing: currentTimer != null && currentTimer.inMinutes == minutes
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  ref.read(sleepTimerProvider.notifier).setSleepTimer(Duration(minutes: minutes));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sleep timer set for $minutes minutes')),
                  );
                },
              )),
        ],
      ),
    );
  }

  void _shareEpisode(Episode episode) {
    final text = 'Listen to "${episode.title}"\n${episode.audioUrl}';
    Share.share(text, subject: episode.title);
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action, Episode? episode) {
    if (episode == null) return;

    switch (action) {
      case 'download':
        _handleDownload(context, ref, episode);
        break;
      case 'add_queue':
        _addToQueue(ref, episode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added "${episode.title}" to queue')),
        );
        break;
      case 'go_podcast':
        _goToPodcast(context, ref, episode);
        break;
      case 'mark_played':
        _markAsPlayed(ref, episode);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marked as played')),
        );
        break;
    }
  }

  void _handleDownload(BuildContext context, WidgetRef ref, Episode episode) {
    final progress = ref.read(downloadProgressProvider);
    if (episode.isDownloaded) {
      _showDeleteDownloadDialog(context, ref, episode);
    } else if (progress.containsKey(episode.id)) {
      ref.read(downloadProgressProvider.notifier).cancelDownload(episode.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download cancelled')),
      );
    } else {
      ref.read(downloadProgressProvider.notifier).downloadEpisode(episode);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloading...')),
      );
    }
  }

  void _addToQueue(WidgetRef ref, Episode episode) {
    final queue = ref.read(queueProvider);
    ref.read(queueProvider.notifier).state = [...queue, episode];
  }

  void _goToPodcast(BuildContext context, WidgetRef ref, Episode episode) {
    final storage = ref.read(localStorageServiceProvider);
    final podcast = storage.getPodcast(episode.podcastId);
    if (podcast != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PodcastDetailScreen(podcast: podcast),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Podcast not found')),
      );
    }
  }

  void _markAsPlayed(WidgetRef ref, Episode episode) {
    final storage = ref.read(localStorageServiceProvider);
    final duration = episode.duration;
    final playedEpisode = episode.copyWith(position: duration);
    storage.saveEpisode(playedEpisode);
  }

  void _showDeleteDownloadDialog(BuildContext context, WidgetRef ref, Episode episode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Download'),
        content: Text('Remove "${episode.title}" from downloads?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(downloadProgressProvider.notifier).deleteDownload(episode);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download removed')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showQueue(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final queue = ref.watch(queueProvider);
          
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) => Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Queue (${queue.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (queue.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            ref.read(queueProvider.notifier).state = [];
                            Navigator.pop(context);
                          },
                          child: const Text('Clear All'),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: queue.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.queue_music, size: 48, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text('Queue is empty'),
                              const SizedBox(height: 8),
                              Text(
                                'Add episodes from the episode detail page',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: queue.length,
                          itemBuilder: (context, index) {
                            final episode = queue[index];
                            return ListTile(
                              leading: Text(
                                '${index + 1}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              title: Text(
                                episode.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(episode.formattedDuration),
                              trailing: IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () {
                                  final newQueue = [...queue]..removeAt(index);
                                  ref.read(queueProvider.notifier).state = newQueue;
                                },
                              ),
                              onTap: () {
                                ref.read(currentEpisodeProvider.notifier).state = episode;
                                ref.read(audioPlayerServiceProvider).playEpisode(episode);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}