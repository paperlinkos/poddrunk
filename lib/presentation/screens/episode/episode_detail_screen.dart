import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../domain/entities/episode.dart';
import '../../../providers/providers.dart';
import '../player/player_screen.dart';

class EpisodeDetailScreen extends ConsumerWidget {
  final Episode episode;

  const EpisodeDetailScreen({super.key, required this.episode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadProgress = ref.watch(downloadProgressProvider);
    final isDownloading = downloadProgress.containsKey(episode.id);
    final progress = downloadProgress[episode.id];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: episode.imageUrl.isNotEmpty
                        ? episode.imageUrl
                        : 'https://via.placeholder.com/300',
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  final text = 'Listen to "${episode.title}"\n${episode.audioUrl}';
                  Share.share(text, subject: episode.title);
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMMM d, yyyy').format(episode.publishedAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        episode.formattedDuration,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ref.read(currentEpisodeProvider.notifier).state = episode;
                            ref.read(audioPlayerServiceProvider).playEpisode(episode);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PlayerScreen()),
                            );
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: episode.isDownloaded
                              ? const Icon(Icons.download_done, color: Colors.green)
                              : isDownloading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        value: progress,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.download_outlined),
                          onPressed: () {
                            if (episode.isDownloaded) {
                              _showDeleteDialog(context, ref);
                            } else if (isDownloading) {
                              ref.read(downloadProgressProvider.notifier).cancelDownload(episode.id);
                            } else {
                              ref.read(downloadProgressProvider.notifier).downloadEpisode(episode);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.playlist_add),
                          onPressed: () {
                            final queue = ref.read(queueProvider);
                            ref.read(queueProvider.notifier).state = [...queue, episode];
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to queue')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  if (episode.position != null && episode.position!.inSeconds > 0) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: episode.position!.inSeconds / episode.duration.inSeconds,
                      backgroundColor: Colors.grey[800],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDuration(episode.position!)} played of ${episode.formattedDuration}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Show Notes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    episode.description.isNotEmpty
                        ? episode.description
                        : 'No show notes available.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[400],
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m ${seconds}s';
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
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
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}