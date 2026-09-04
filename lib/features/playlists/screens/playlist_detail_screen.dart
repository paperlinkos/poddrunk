import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/neo_brutalist_theme.dart';
import '../../../core/widgets/brutalist_button.dart';
import '../../../core/widgets/brutalist_card.dart';
import '../../audio/providers/audio_player_provider.dart';
import '../../audio/domain/models/track_model.dart';
import '../../library/widgets/track_options_bottom_sheet.dart';
import '../../player/screens/now_playing_screen.dart';
import '../domain/models/playlist_model.dart';
import '../providers/playlist_provider.dart';

class PlaylistDetailScreen extends ConsumerStatefulWidget {
  final String playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  ConsumerState<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen> {
  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showRenameDialog(PlaylistModel playlist) {
    final controller = TextEditingController(text: playlist.name);
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
        title: const Text('RENAME PLAYLIST', style: TextStyle(fontWeight: FontWeight.w900)),
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
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                ref.read(playlistProvider.notifier).renamePlaylist(playlist.id, newName);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showDeletePlaylistDialog(PlaylistModel playlist) {
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
        title: const Text('DELETE PLAYLIST?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text(
          'Are you sure you want to delete "${playlist.name}"? The audio files on your phone will NOT be deleted.',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          BrutalistButton(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            onPressed: () {
              ref.read(playlistProvider.notifier).deletePlaylist(playlist.id);
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to library
            },
            child: const Text('DELETE', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playlistState = ref.watch(playlistProvider);
    final playlist = playlistState.getPlaylistById(widget.playlistId);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? NeoBrutalistColors.darkPrimary : NeoBrutalistColors.lightPrimary;
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
    final textColor = isDark ? NeoBrutalistColors.darkText : NeoBrutalistColors.lightText;
    final accentColor = isDark ? NeoBrutalistColors.darkAccent : NeoBrutalistColors.lightAccent;

    if (playlist == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('PLAYLIST NOT FOUND')),
        body: const Center(child: Text('Playlist was removed')),
      );
    }

    final isCustomPlaylist = playlist.id != 'favorites';

    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name),
        actions: [
          if (isCustomPlaylist) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Rename',
              onPressed: () => _showRenameDialog(playlist),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: () => _showDeletePlaylistDialog(playlist),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Playlist Banner Card
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(NeoBrutalistTheme.borderRadius),
              border: Border.all(color: borderColor, width: NeoBrutalistTheme.borderWidth),
              boxShadow: [
                BoxShadow(
                  color: borderColor,
                  offset: NeoBrutalistTheme.shadowOffset,
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Center(
                        child: Icon(
                          playlist.id == 'favorites' ? Icons.favorite : Icons.queue_music,
                          color: playlist.id == 'favorites' ? Colors.red : Colors.white,
                          size: 28,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${playlist.tracks.length} SONGS • ${_formatDuration(playlist.totalDuration)} TOTAL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: textColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (playlist.description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    playlist.description,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
                const SizedBox(height: 14),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: BrutalistButton(
                        backgroundColor: accentColor,
                        onPressed: playlist.tracks.isEmpty
                            ? null
                            : () {
                                ref.read(audioPlayerProvider.notifier).playTrack(
                                      playlist.tracks.first,
                                      queue: playlist.tracks,
                                      index: 0,
                                    );
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (ctx) => const NowPlayingScreen(),
                                );
                              },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow, size: 20, color: Colors.black),
                            SizedBox(width: 6),
                            Text(
                              'PLAY ALL',
                              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BrutalistButton(
                        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
                        onPressed: playlist.tracks.isEmpty
                            ? null
                            : () {
                                final shuffled = List<TrackModel>.from(playlist.tracks)..shuffle();
                                ref.read(audioPlayerProvider.notifier).playTrack(
                                      shuffled.first,
                                      queue: shuffled,
                                      index: 0,
                                    );
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (ctx) => const NowPlayingScreen(),
                                );
                              },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shuffle, size: 18, color: textColor),
                            const SizedBox(width: 6),
                            Text(
                              'SHUFFLE',
                              style: TextStyle(fontWeight: FontWeight.w900, color: textColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Track List
          Expanded(
            child: playlist.tracks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.music_off, size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'NO TRACKS IN THIS PLAYLIST YET',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Long-press any song in your library or tap the 3-dots menu to add songs here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.only(left: 12, right: 12, bottom: 90, top: 4),
                    itemCount: playlist.tracks.length,
                    onReorder: (oldIndex, newIndex) {
                      ref.read(playlistProvider.notifier).reorderTracks(playlist.id, oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final track = playlist.tracks[index];
                      final isPlayingCurrent =
                          ref.watch(audioPlayerProvider).currentTrack?.id == track.id;

                      return BrutalistCard(
                        key: ValueKey('${track.id}_$index'),
                        margin: const EdgeInsets.only(bottom: 8.0),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        backgroundColor: isPlayingCurrent
                            ? (isDark
                                ? NeoBrutalistColors.darkPrimary.withValues(alpha: 0.15)
                                : NeoBrutalistColors.lightPrimary)
                            : null,
                        onTap: () {
                          ref.read(audioPlayerProvider.notifier).playTrack(
                                track,
                                queue: playlist.tracks,
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
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isPlayingCurrent ? accentColor : primaryColor,
                                border: Border.all(color: borderColor, width: 1.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
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
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${track.artist} • ${track.album}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: textColor.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDuration(track.duration),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                                  queue: playlist.tracks,
                                  index: index,
                                  playlistId: playlist.id,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
