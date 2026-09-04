import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/neo_brutalist_theme.dart';
import '../../../core/widgets/brutalist_card.dart';
import '../../../core/widgets/brutalist_button.dart';
import '../providers/library_provider.dart';
import '../../audio/providers/audio_player_provider.dart';
import '../../audio/domain/models/track_model.dart';
import '../../player/screens/now_playing_screen.dart';
import '../../playlists/providers/playlist_provider.dart';
import '../../playlists/domain/models/playlist_model.dart';
import '../../playlists/screens/playlist_detail_screen.dart';
import '../widgets/track_options_bottom_sheet.dart';
import '../widgets/weather_badge.dart';
import 'collection_detail_screen.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showCreatePlaylistDialog() {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? NeoBrutalistColors.darkCardBg : NeoBrutalistColors.lightCardBg;
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoBrutalistTheme.borderRadius),
          side: BorderSide(color: borderColor, width: NeoBrutalistTheme.borderWidth),
        ),
        title: const Text('CREATE NEW PLAYLIST', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'PLAYLIST NAME',
            border: OutlineInputBorder(borderSide: BorderSide(color: borderColor)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          BrutalistButton(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await ref.read(playlistProvider.notifier).createPlaylist(name);
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('CREATE', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showPlaylistOptions(PlaylistModel playlist) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
    final cardBg = isDark ? NeoBrutalistColors.darkCardBg : NeoBrutalistColors.lightCardBg;
    final textColor = isDark ? NeoBrutalistColors.darkText : NeoBrutalistColors.lightText;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border(top: BorderSide(color: borderColor, width: NeoBrutalistTheme.borderWidth)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              playlist.name,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            Text(
              '${playlist.tracks.length} Songs',
              style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.6), fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('PLAY ALL', style: TextStyle(fontWeight: FontWeight.w900)),
              onTap: () {
                Navigator.of(ctx).pop();
                if (playlist.tracks.isNotEmpty) {
                  ref.read(audioPlayerProvider.notifier).playTrack(
                        playlist.tracks.first,
                        queue: playlist.tracks,
                        index: 0,
                      );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.shuffle),
              title: const Text('SHUFFLE PLAY', style: TextStyle(fontWeight: FontWeight.w900)),
              onTap: () {
                Navigator.of(ctx).pop();
                if (playlist.tracks.isNotEmpty) {
                  final shuffled = List<TrackModel>.from(playlist.tracks)..shuffle();
                  ref.read(audioPlayerProvider.notifier).playTrack(
                        shuffled.first,
                        queue: shuffled,
                        index: 0,
                      );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.queue_music),
              title: const Text('ADD ALL TO QUEUE', style: TextStyle(fontWeight: FontWeight.w900)),
              onTap: () {
                Navigator.of(ctx).pop();
                for (var t in playlist.tracks) {
                  ref.read(audioPlayerProvider.notifier).addToQueue(t);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ADDED ${playlist.tracks.length} SONGS TO QUEUE'),
                    backgroundColor: Colors.black,
                  ),
                );
              },
            ),
            if (playlist.id != 'favorites')
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('DELETE PLAYLIST', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.red)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ref.read(playlistProvider.notifier).deletePlaylist(playlist.id);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryProvider);
    final playlistState = ref.watch(playlistProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? NeoBrutalistColors.darkHeaderBg : NeoBrutalistColors.lightPrimary;
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
    final textColor = isDark ? NeoBrutalistColors.darkText : NeoBrutalistColors.lightText;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LIBRARY'),
        actions: const [
          WeatherBadge(),
          SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: isDark ? NeoBrutalistColors.darkCanvas : primaryColor,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: isDark ? NeoBrutalistColors.darkPrimary : textColor,
              unselectedLabelColor: isDark
                  ? NeoBrutalistColors.darkMutedText
                  : textColor.withValues(alpha: 0.6),
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              indicatorColor: isDark ? NeoBrutalistColors.darkPrimary : NeoBrutalistColors.lightAccent,
              indicatorWeight: 3.0,
              tabs: const [
                Tab(text: 'SONGS'),
                Tab(text: 'PLAYLISTS'),
                Tab(text: 'ALBUMS'),
                Tab(text: 'ARTISTS'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (q) => ref.read(libraryProvider.notifier).setSearchQuery(q),
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'SEARCH SONGS, ARTISTS, ALBUMS...',
                hintStyle: TextStyle(
                  color: isDark ? NeoBrutalistColors.darkMutedText : NeoBrutalistColors.lightMutedText,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                prefixIcon: Icon(Icons.search, color: textColor),
                filled: true,
                fillColor: isDark ? NeoBrutalistColors.darkCardBg : NeoBrutalistColors.lightCardBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(NeoBrutalistTheme.borderRadius),
                  borderSide: BorderSide(color: borderColor, width: NeoBrutalistTheme.borderWidth),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(NeoBrutalistTheme.borderRadius),
                  borderSide: BorderSide(
                    color: isDark ? NeoBrutalistColors.darkAccent : NeoBrutalistColors.lightAccent,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),

          // Permission Banner: ONLY shown when NOT loading AND permission is truly denied
          if (!libraryState.isLoading && !libraryState.hasPermission)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: borderColor, width: NeoBrutalistTheme.borderWidth),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Storage permission required to play local audio files.',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  BrutalistButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    onPressed: () => ref.read(libraryProvider.notifier).scanAudioLibrary(),
                    child: const Text('GRANT', style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ),

          // Tab Content
          Expanded(
            child: libraryState.isLoading
                ? _buildLoadingState(isDark)
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSongsList(libraryState.filteredTracks),
                      _buildPlaylistsTab(playlistState.playlists),
                      _buildAlbumsGrid(libraryState.filteredTracks),
                      _buildArtistsList(libraryState.filteredTracks),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    final accentColor = isDark ? NeoBrutalistColors.darkAccent : NeoBrutalistColors.lightAccent;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder,
                width: 2.0,
              ),
            ),
            child: const Center(
              child: Icon(Icons.graphic_eq, color: Colors.black, size: 26),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'INDEXING AUDIO LIBRARY...',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistsTab(List<PlaylistModel> playlists) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? NeoBrutalistColors.darkAccent : NeoBrutalistColors.lightAccent;
    final textColor = isDark ? NeoBrutalistColors.darkText : NeoBrutalistColors.lightText;
    final primaryColor = isDark ? NeoBrutalistColors.darkPrimary : NeoBrutalistColors.lightPrimary;
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;

    return ListView(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 90, top: 4),
      children: [
        // Create Playlist Action Button
        BrutalistButton(
          backgroundColor: accentColor,
          onPressed: _showCreatePlaylistDialog,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.black, size: 20),
              SizedBox(width: 8),
              Text(
                'CREATE NEW PLAYLIST',
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (playlists.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const Icon(Icons.queue_music, size: 48),
                  const SizedBox(height: 12),
                  const Text('NO PLAYLISTS YET', style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(
                    'Create your first playlist and start organizing your audio collection.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
          )
        else
          ...playlists.map((playlist) {
            return BrutalistCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => PlaylistDetailScreen(playlistId: playlist.id),
                  ),
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: playlist.id == 'favorites' ? Colors.red : primaryColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: borderColor, width: 1.2),
                    ),
                    child: Center(
                      child: Icon(
                        playlist.id == 'favorites' ? Icons.favorite : Icons.queue_music,
                        color: playlist.id == 'favorites' ? Colors.white : textColor,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.name,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${playlist.tracks.length} SONGS • ${_formatDuration(playlist.totalDuration)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: textColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showPlaylistOptions(playlist),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildSongsList(List<TrackModel> tracks) {
    if (tracks.isEmpty) {
      final libraryState = ref.watch(libraryProvider);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.music_off, size: 48),
              const SizedBox(height: 12),
              Text(
                libraryState.hasPermission
                    ? 'NO LOCAL TRACKS FOUND ON DEVICE'
                    : 'DEVICE STORAGE ACCESS REQUIRED',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                libraryState.hasPermission
                    ? 'Add audio files (.mp3, .m4a, .wav, .flac) to your device storage.'
                    : 'Grant permission so Poddrunk can index and play offline songs on your phone.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              BrutalistButton(
                onPressed: () => ref.read(libraryProvider.notifier).scanAudioLibrary(),
                child: Text(libraryState.hasPermission ? 'RESCAN STORAGE' : 'GRANT PERMISSION'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 90),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        final isPlayingCurrent = ref.watch(audioPlayerProvider).currentTrack?.id == track.id;

        return BrutalistCard(
          margin: const EdgeInsets.only(bottom: 8.0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          backgroundColor: isPlayingCurrent
              ? (Theme.of(context).brightness == Brightness.dark
                  ? NeoBrutalistColors.darkPrimary.withValues(alpha: 0.15)
                  : NeoBrutalistColors.lightPrimary)
              : null,
          onTap: () {
            ref.read(audioPlayerProvider.notifier).playTrack(
                  track,
                  queue: tracks,
                  index: index,
                );
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const NowPlayingScreen(),
            );
          },
          onLongPress: () {
            TrackOptionsBottomSheet.show(
              context,
              track: track,
              queue: tracks,
              index: index,
            );
          },
          child: Row(
            children: [
              // Track Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isPlayingCurrent
                      ? (Theme.of(context).brightness == Brightness.dark
                          ? NeoBrutalistColors.darkPrimary
                          : NeoBrutalistColors.lightAccent)
                      : Theme.of(context).primaryColor,
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? NeoBrutalistColors.darkBorder
                        : NeoBrutalistColors.lightBorder,
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Icon(
                    isPlayingCurrent ? Icons.graphic_eq : Icons.music_note,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${track.artist} • ${track.album}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(track.duration),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  TrackOptionsBottomSheet.show(
                    context,
                    track: track,
                    queue: tracks,
                    index: index,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlbumsGrid(List<TrackModel> tracks) {
    final albumsMap = <String, List<TrackModel>>{};
    for (var track in tracks) {
      albumsMap.putIfAbsent(track.album, () => []).add(track);
    }

    final albums = albumsMap.keys.toList();

    return GridView.builder(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 90, top: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final albumName = albums[index];
        final albumTracks = albumsMap[albumName]!;
        final firstTrack = albumTracks.first;

        return BrutalistCard(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => CollectionDetailScreen(
                  title: albumName,
                  subtitle: firstTrack.artist,
                  tracks: albumTracks,
                  type: CollectionType.album,
                ),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.album, size: 42),
              const SizedBox(height: 8),
              Text(
                albumName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                '${albumTracks.length} SONGS',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArtistsList(List<TrackModel> tracks) {
    final artistsMap = <String, List<TrackModel>>{};
    for (var track in tracks) {
      artistsMap.putIfAbsent(track.artist, () => []).add(track);
    }
    final artists = artistsMap.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 90, top: 8),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artistName = artists[index];
        final artistTracks = artistsMap[artistName]!;

        return BrutalistCard(
          margin: const EdgeInsets.only(bottom: 8),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => CollectionDetailScreen(
                  title: artistName,
                  subtitle: '${artistTracks.length} SONGS',
                  tracks: artistTracks,
                  type: CollectionType.artist,
                ),
              ),
            );
          },
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.black,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artistName,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                    Text(
                      '${artistTracks.length} TRACKS',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        );
      },
    );
  }
}
