import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/episode.dart';
import '../../../providers/providers.dart';
import '../../widgets/podcast_card.dart';
import '../podcast/podcast_detail_screen.dart';
import '../player/player_screen.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscribedPodcasts = ref.watch(subscribedPodcastsProvider);
    final downloadedEpisodes = ref.watch(downloadedEpisodesProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Your Library',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(text: 'Subscriptions'),
                  Tab(text: 'Downloads'),
                  Tab(text: 'Queue'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _SubscriptionsTab(podcasts: subscribedPodcasts),
                    _DownloadsTab(episodes: downloadedEpisodes),
                    const _QueueTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubscriptionsTab extends StatelessWidget {
  final List podcasts;

  const _SubscriptionsTab({required this.podcasts});

  @override
  Widget build(BuildContext context) {
    if (podcasts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.subscriptions_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'No subscriptions yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Subscribe to podcasts to see them here',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: podcasts.length,
      itemBuilder: (context, index) {
        final podcast = podcasts[index];
        return PodcastCard(
          podcast: podcast,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PodcastDetailScreen(podcast: podcast),
              ),
            );
          },
        );
      },
    );
  }
}

class _DownloadsTab extends ConsumerWidget {
  final List<Episode> episodes;

  const _DownloadsTab({required this.episodes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (episodes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.download_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'No downloads yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Download episodes to listen offline',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: episodes.length,
      itemBuilder: (context, index) {
        final episode = episodes[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: episode.imageUrl.isNotEmpty ? episode.imageUrl : 'https://via.placeholder.com/50',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 50,
                height: 50,
                color: Colors.grey[800],
                child: const Icon(Icons.podcasts),
              ),
            ),
          ),
          title: Text(
            episode.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(episode.formattedDuration),
          trailing: const Icon(Icons.play_circle_filled),
          onTap: () {
            ref.read(currentEpisodeProvider.notifier).state = episode;
            ref.read(audioPlayerServiceProvider).playEpisode(episode);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlayerScreen()),
            );
          },
        );
      },
    );
  }
}

class _QueueTab extends ConsumerWidget {
  const _QueueTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(queueProvider);

    if (queue.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.queue_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Queue is empty',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Add episodes to your queue from the player menu',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      itemCount: queue.length,
      onReorder: (oldIndex, newIndex) {
        final newQueue = [...queue];
        if (newIndex > oldIndex) newIndex -= 1;
        final item = newQueue.removeAt(oldIndex);
        newQueue.insert(newIndex, item);
        ref.read(queueProvider.notifier).state = newQueue;
      },
      itemBuilder: (context, index) {
        final episode = queue[index];
        return Dismissible(
          key: Key(episode.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            final newQueue = [...queue]..removeAt(index);
            ref.read(queueProvider.notifier).state = newQueue;
          },
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: episode.imageUrl.isNotEmpty ? episode.imageUrl : 'https://via.placeholder.com/50',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[800],
                  child: const Icon(Icons.podcasts),
                ),
              ),
            ),
            title: Text(
              episode.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(episode.formattedDuration),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_circle_filled),
                  onPressed: () {
                    ref.read(currentEpisodeProvider.notifier).state = episode;
                    ref.read(audioPlayerServiceProvider).playEpisode(episode);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PlayerScreen()),
                    );
                  },
                ),
                const Icon(Icons.drag_handle),
              ],
            ),
            onTap: () {
              ref.read(currentEpisodeProvider.notifier).state = episode;
              ref.read(audioPlayerServiceProvider).playEpisode(episode);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlayerScreen()),
              );
            },
          ),
        );
      },
    );
  }
}