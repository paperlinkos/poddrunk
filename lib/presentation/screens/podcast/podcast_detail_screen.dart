import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/episode.dart';
import '../../../domain/entities/podcast.dart';
import '../../../providers/providers.dart';
import '../../widgets/episode_list_tile.dart';
import '../../widgets/mini_player.dart';
import '../episode/episode_detail_screen.dart';
import '../player/player_screen.dart';

class PodcastDetailScreen extends ConsumerWidget {
  final Podcast podcast;

  const PodcastDetailScreen({super.key, required this.podcast});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodesAsync = ref.watch(episodesProvider(podcast.id));
    final currentEpisode = ref.watch(currentEpisodeProvider);
    final isSubscribed = ref.watch(localStorageServiceProvider).isSubscribed(podcast.id);
    final downloadProgress = ref.watch(downloadProgressProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: podcast.imageUrl.isNotEmpty
                        ? podcast.imageUrl
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
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    podcast.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    podcast.author,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (isSubscribed) {
                              ref.read(podcastProvider.notifier).unsubscribe(podcast.id);
                            } else {
                              ref.read(podcastProvider.notifier).subscribe(podcast.id);
                            }
                          },
                          icon: Icon(isSubscribed ? Icons.check : Icons.add),
                          label: Text(isSubscribed ? 'Subscribed' : 'Subscribe'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSubscribed
                                ? Colors.grey
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    podcast.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Episodes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          episodesAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $error')),
            ),
            data: (episodes) {
              if (episodes.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No episodes found'),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final episode = episodes[index];
                    final isPlaying = currentEpisode?.id == episode.id;
return EpisodeListTile(
                      episode: episode,
                      isPlaying: isPlaying,
                      downloadProgress: downloadProgress[episode.id],
 onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EpisodeDetailScreen(episode: episode),
                          ),
                        );
                      },
                      onPlayTap: () {
                        if (isPlaying) {
                          ref.read(audioPlayerServiceProvider).pause();
                        } else {
                          ref.read(currentEpisodeProvider.notifier).state = episode;
                          ref.read(audioPlayerServiceProvider).playEpisode(episode);
                        }
                      },
                      onDownloadTap: () {
                        final progress = ref.read(downloadProgressProvider);
                        if (episode.isDownloaded) {
                          _showDeleteDownloadDialog(context, ref, episode);
                        } else if (progress.containsKey(episode.id)) {
                          ref.read(downloadProgressProvider.notifier).cancelDownload(episode.id);
                        } else {
                          ref.read(downloadProgressProvider.notifier).downloadEpisode(episode);
                        }
                      },
                    );
                  },
                  childCount: episodes.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
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
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}