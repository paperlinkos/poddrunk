import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/podcast_card.dart';
import '../podcast/podcast_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _showUrlInput = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchLocal(String query) {
    setState(() {});
  }

  Future<void> _addByUrl(String url) async {
    if (url.isEmpty) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(podcastProvider.notifier).addPodcast(url);
      setState(() {
        _showUrlInput = false;
        _searchController.clear();
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load podcast. Please check the URL and try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final podcastsAsync = ref.watch(podcastProvider);
    final query = _searchController.text.toLowerCase();

    final filteredPodcasts = podcastsAsync.maybeWhen(
      data: (podcasts) => query.isEmpty
          ? <dynamic>[]
          : podcasts.where((p) =>
              p.title.toLowerCase().contains(query) ||
              p.author.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query)).toList(),
      orElse: () => <dynamic>[],
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: query.isEmpty ? 'Search your podcasts...' : query,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.link),
                            onPressed: () {
                              setState(() {
                                _showUrlInput = !_showUrlInput;
                              });
                            },
                          ),
                        ],
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  if (_showUrlInput) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Paste RSS feed URL...',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onSubmitted: _addByUrl,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : () => _addByUrl(_searchController.text),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                const SizedBox(height: 16),
                                Text(_error!, textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        )
                      : query.isNotEmpty && filteredPodcasts.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredPodcasts.length,
                              itemBuilder: (context, index) {
                                final podcast = filteredPodcasts[index];
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
                            )
                          : ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                if (query.isEmpty) ...[
                                  Text(
                                    'Your Podcasts',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  podcastsAsync.when(
                                    loading: () => const CircularProgressIndicator(),
                                    error: (e, s) => Text('Error: $e'),
                                    data: (podcasts) {
                                      if (podcasts.isEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(
                                            'No podcasts yet. Add some below!',
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                        );
                                      }
                                      return SizedBox(
                                        height: 200,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: podcasts.length,
                                          itemBuilder: (context, index) {
                                            final podcast = podcasts[index];
                                            return SizedBox(
                                              width: 140,
                                              child: PodcastCard(
                                                podcast: podcast,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => PodcastDetailScreen(podcast: podcast),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                Text(
                                  'Add by URL',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 16),
                                ...AppConstants.featuredPodcasts.map((podcast) => ListTile(
                                      leading: const Icon(Icons.podcasts),
                                      title: Text(podcast['title']!),
                                      trailing: const Icon(Icons.add),
                                      onTap: () => _addByUrl(podcast['feedUrl']!),
                                    )),
                              ],
                            ),
            ),
          ],
        ),
      ),
    );
  }
}