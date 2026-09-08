import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/neo_brutalist_theme.dart';
import '../../../core/widgets/brutalist_button.dart';
import '../../../core/widgets/brutalist_card.dart';
import '../../audio/domain/models/track_model.dart';
import '../../audio/providers/audio_player_provider.dart';
import '../../player/screens/now_playing_screen.dart';
import '../widgets/track_options_bottom_sheet.dart';

import '../providers/history_provider.dart';

enum CollectionType { album, artist, recentlyAdded, recentlyPlayed }

class CollectionDetailScreen extends ConsumerWidget {
  final String title;
  final String subtitle;
  final List<TrackModel> tracks;
  final CollectionType type;

  const CollectionDetailScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tracks,
    required this.type,
  });

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _getTotalDuration(List<TrackModel> trackList) {
    int totalMs = 0;
    for (var t in trackList) {
      totalMs += t.duration.inMilliseconds;
    }
    final d = Duration(milliseconds: totalMs);
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours > 0) {
      return '$hours hr $minutes min';
    }
    return '$minutes MIN';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? NeoBrutalistColors.darkCanvas : NeoBrutalistColors.lightCanvas;
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
    final primaryColor = isDark ? NeoBrutalistColors.darkPrimary : NeoBrutalistColors.lightPrimary;
    final accentColor = isDark ? NeoBrutalistColors.darkAccent : NeoBrutalistColors.lightAccent;
    final cardBg = isDark ? NeoBrutalistColors.darkCardBg : NeoBrutalistColors.lightCardBg;
    final textColor = isDark ? NeoBrutalistColors.darkText : NeoBrutalistColors.lightText;

    final playerState = ref.watch(audioPlayerProvider);
    final activeTracks = type == CollectionType.recentlyPlayed
        ? ref.watch(historyProvider).recentlyPlayed
        : tracks;

    String appBarTitle;
    IconData badgeIcon;
    Color badgeColor;
    switch (type) {
      case CollectionType.album:
        appBarTitle = 'ALBUM';
        badgeIcon = Icons.album;
        badgeColor = primaryColor;
        break;
      case CollectionType.artist:
        appBarTitle = 'ARTIST';
        badgeIcon = Icons.person;
        badgeColor = primaryColor;
        break;
      case CollectionType.recentlyAdded:
        appBarTitle = 'RECENTLY ADDED';
        badgeIcon = Icons.auto_awesome;
        badgeColor = primaryColor;
        break;
      case CollectionType.recentlyPlayed:
        appBarTitle = 'RECENTLY PLAYED';
        badgeIcon = Icons.history;
        badgeColor = accentColor;
        break;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? NeoBrutalistColors.darkHeaderBg : primaryColor,
        elevation: 0,
        title: Text(
          appBarTitle,
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (type == CollectionType.recentlyPlayed && activeTracks.isNotEmpty)
            IconButton(
              tooltip: 'CLEAR HISTORY',
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NeoBrutalistTheme.borderRadius),
                      side: BorderSide(color: borderColor, width: NeoBrutalistTheme.borderWidth),
                    ),
                    title: const Text('CLEAR PLAYBACK HISTORY?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    content: const Text(
                      'This will remove all songs from your Recently Played history.',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      BrutalistButton(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        backgroundColor: Colors.red,
                        onPressed: () {
                          ref.read(historyProvider.notifier).clearHistory();
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('CLEAR', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: borderColor, height: NeoBrutalistTheme.borderWidth),
        ),
      ),
      body: Column(
        children: [
          // Header Summary Card
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: cardBg,
              border: Border(
                bottom: BorderSide(color: borderColor, width: NeoBrutalistTheme.borderWidth),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Visual Badge
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(type == CollectionType.artist ? 36 : 8),
                        border: Border.all(color: borderColor, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black : borderColor,
                            offset: const Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          badgeIcon,
                          size: 38,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          if (subtitle.isNotEmpty) ...[
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: textColor.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            '${activeTracks.length} TRACKS • ${_getTotalDuration(activeTracks)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: textColor.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: BrutalistButton(
                        backgroundColor: primaryColor,
                        onPressed: activeTracks.isEmpty
                            ? null
                            : () {
                                ref.read(audioPlayerProvider.notifier).playTrack(
                                      activeTracks.first,
                                      queue: activeTracks,
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
                            Icon(Icons.play_arrow, size: 20),
                            SizedBox(width: 6),
                            Text('PLAY ALL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BrutalistButton(
                        backgroundColor: cardBg,
                        onPressed: activeTracks.isEmpty
                            ? null
                            : () {
                                final shuffled = List<TrackModel>.from(activeTracks)..shuffle();
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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shuffle, size: 18),
                            SizedBox(width: 6),
                            Text('SHUFFLE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
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
            child: activeTracks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          type == CollectionType.recentlyPlayed
                              ? Icons.history
                              : Icons.music_off,
                          size: 48,
                          color: textColor.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          type == CollectionType.recentlyPlayed
                              ? 'NO PLAYED SONGS YET'
                              : 'NO SONGS FOUND',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: textColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 12, right: 12, bottom: 90, top: 8),
                    itemCount: activeTracks.length,
                    itemBuilder: (context, index) {
                      final track = activeTracks[index];
                      final isPlayingCurrent = playerState.currentTrack?.id == track.id;

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
                                queue: activeTracks,
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
                            queue: activeTracks,
                            index: index,
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
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black),
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
                                    type == CollectionType.album ? track.artist : track.album,
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
                            Text(
                              _formatDuration(track.duration),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: textColor.withValues(alpha: 0.6),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert, size: 18),
                              onPressed: () {
                                TrackOptionsBottomSheet.show(
                                  context,
                                  track: track,
                                  queue: activeTracks,
                                  index: index,
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
