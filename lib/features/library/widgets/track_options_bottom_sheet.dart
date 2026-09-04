import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/neo_brutalist_theme.dart';
import '../../../core/widgets/brutalist_button.dart';
import '../../audio/domain/models/track_model.dart';
import '../../audio/providers/audio_player_provider.dart';
import '../../audio/services/ringtone_service.dart';
import '../providers/library_provider.dart';
import '../../playlists/providers/playlist_provider.dart';
import '../../playlists/widgets/add_to_playlist_dialog.dart';
import 'track_info_dialog.dart';

class TrackOptionsBottomSheet extends ConsumerWidget {
  final TrackModel track;
  final List<TrackModel>? queue;
  final int index;
  final String? playlistId; // Non-null if opened from a playlist view

  const TrackOptionsBottomSheet({
    super.key,
    required this.track,
    this.queue,
    this.index = 0,
    this.playlistId,
  });

  static void show(
    BuildContext context, {
    required TrackModel track,
    List<TrackModel>? queue,
    int index = 0,
    String? playlistId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TrackOptionsBottomSheet(
        track: track,
        queue: queue,
        index: index,
        playlistId: playlistId,
      ),
    );
  }

  void _confirmDeleteFile(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
    final cardBg = isDark ? NeoBrutalistColors.darkCardBg : NeoBrutalistColors.lightCardBg;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoBrutalistTheme.borderRadius),
          side: BorderSide(color: borderColor, width: NeoBrutalistTheme.borderWidth),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.delete_forever, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'DELETE AUDIO FILE?',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to permanently delete "${track.title}" from device storage?',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action is permanent and cannot be undone.',
              style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          BrutalistButton(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.of(context).pop(); // Close bottom sheet
              
              final success = await ref.read(libraryProvider.notifier).deleteLocalTrack(track);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'DELETED "${track.title}"' : 'FAILED TO DELETE FILE',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: success ? Colors.black : Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'DELETE PERMANENTLY',
              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSetRingtoneDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
    final cardBg = isDark ? NeoBrutalistColors.darkCardBg : NeoBrutalistColors.lightCardBg;
    final primaryColor = isDark ? NeoBrutalistColors.darkPrimary : NeoBrutalistColors.lightPrimary;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoBrutalistTheme.borderRadius),
          side: BorderSide(color: borderColor, width: NeoBrutalistTheme.borderWidth),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: borderColor, width: 1.2),
              ),
              child: const Icon(Icons.ring_volume, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'SET AS AUDIO TONE',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Set "${track.title}" as your device ringtone or alert sound:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildToneButton(
              context: ctx,
              parentContext: context,
              icon: Icons.phone_in_talk,
              label: 'PHONE RINGTONE',
              target: RingtoneTarget.ringtone,
            ),
            const SizedBox(height: 8),
            _buildToneButton(
              context: ctx,
              parentContext: context,
              icon: Icons.notifications_active,
              label: 'NOTIFICATION SOUND',
              target: RingtoneTarget.notification,
            ),
            const SizedBox(height: 8),
            _buildToneButton(
              context: ctx,
              parentContext: context,
              icon: Icons.alarm,
              label: 'ALARM SOUND',
              target: RingtoneTarget.alarm,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildToneButton({
    required BuildContext context,
    required BuildContext parentContext,
    required IconData icon,
    required String label,
    required RingtoneTarget target,
  }) {
    return BrutalistButton(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      onPressed: () {
        Navigator.of(context).pop();
        _applyRingtone(parentContext, target);
      },
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyRingtone(BuildContext context, RingtoneTarget target) async {
    try {
      final res = await RingtoneService.setRingtone(track, target: target);
      if (!context.mounted) return;

      if (res == 'PERMISSION_NEEDED') {
        _showPermissionDialog(context, target);
      } else if (res == 'SUCCESS') {
        final label = switch (target) {
          RingtoneTarget.notification => 'NOTIFICATION SOUND',
          RingtoneTarget.alarm => 'ALARM SOUND',
          RingtoneTarget.ringtone => 'PHONE RINGTONE',
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SET "${track.title}" AS $label 🔔', style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.black,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('FAILED TO SET TONE: $res', style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ERROR SETTING RINGTONE: $e', style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPermissionDialog(BuildContext context, RingtoneTarget target) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
    final cardBg = isDark ? NeoBrutalistColors.darkCardBg : NeoBrutalistColors.lightCardBg;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoBrutalistTheme.borderRadius),
          side: BorderSide(color: borderColor, width: NeoBrutalistTheme.borderWidth),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.settings, size: 20, color: Colors.black),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'PERMISSION REQUIRED',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Android requires permission to modify system audio settings in order to set custom ringtones.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(height: 8),
            Text(
              'Tap OPEN SETTINGS, toggle "Allow modifying system settings" for Poddrunk, then return to apply.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          BrutalistButton(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await RingtoneService.openWriteSettings();
            },
            child: const Text(
              'OPEN SETTINGS',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? NeoBrutalistColors.darkPrimary : NeoBrutalistColors.lightPrimary;
    final cardBg = isDark ? NeoBrutalistColors.darkCardBg : NeoBrutalistColors.lightCardBg;
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
    final textColor = isDark ? NeoBrutalistColors.darkText : NeoBrutalistColors.lightText;
    final isFav = ref.watch(playlistProvider.notifier).isFavorite(track.id);

    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 16),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(
          top: BorderSide(color: borderColor, width: NeoBrutalistTheme.borderWidth),
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Track Header Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: borderColor, width: NeoBrutalistTheme.borderWidth),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                  child: const Center(
                    child: Icon(Icons.music_note, color: Colors.white, size: 22),
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
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${track.artist} • ${track.album}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
          ),
          const SizedBox(height: 12),

          // Action Options
          _buildOptionTile(
            context,
            icon: Icons.play_arrow,
            title: 'PLAY NOW',
            onTap: () {
              Navigator.of(context).pop();
              ref.read(audioPlayerProvider.notifier).playTrack(
                    track,
                    queue: queue,
                    index: index,
                  );
            },
          ),
          _buildOptionTile(
            context,
            icon: Icons.playlist_play,
            title: 'PLAY NEXT',
            onTap: () {
              Navigator.of(context).pop();
              ref.read(audioPlayerProvider.notifier).playNext(track);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('PLAYING NEXT: "${track.title}"'),
                  backgroundColor: Colors.black,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          _buildOptionTile(
            context,
            icon: Icons.queue_music,
            title: 'ADD TO QUEUE',
            onTap: () {
              Navigator.of(context).pop();
              ref.read(audioPlayerProvider.notifier).addToQueue(track);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('ADDED TO QUEUE: "${track.title}"'),
                  backgroundColor: Colors.black,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          _buildOptionTile(
            context,
            icon: isFav ? Icons.favorite : Icons.favorite_border,
            title: isFav ? 'REMOVE FROM FAVORITES' : 'ADD TO FAVORITES',
            iconColor: isFav ? Colors.red : null,
            onTap: () async {
              Navigator.of(context).pop();
              await ref.read(playlistProvider.notifier).toggleFavorite(track);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isFav
                          ? 'REMOVED FROM FAVORITES'
                          : 'ADDED TO FAVORITES ❤️',
                    ),
                    backgroundColor: Colors.black,
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          _buildOptionTile(
            context,
            icon: Icons.playlist_add,
            title: 'ADD TO PLAYLIST...',
            onTap: () {
              Navigator.of(context).pop();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => AddToPlaylistBottomSheet(track: track),
              );
            },
          ),
          _buildOptionTile(
            context,
            icon: Icons.info_outline,
            title: 'TRACK DETAILS & METADATA',
            onTap: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (ctx) => TrackInfoDialog(track: track),
              );
            },
          ),

          // Contextual Delete: remove from playlist or delete from phone disk
          if (playlistId != null) ...[
            _buildOptionTile(
              context,
              icon: Icons.remove_circle_outline,
              title: 'REMOVE FROM THIS PLAYLIST',
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () async {
                Navigator.of(context).pop();
                await ref
                    .read(playlistProvider.notifier)
                    .removeTrackFromPlaylist(playlistId!, track.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('REMOVED TRACK FROM PLAYLIST'),
                      backgroundColor: Colors.black,
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
            ),
          ] else if (track.isLocal) ...[
            _buildOptionTile(
              context,
              icon: Icons.ring_volume,
              title: 'SET AS RINGTONE / AUDIO TONE...',
              onTap: () {
                Navigator.of(context).pop();
                _showSetRingtoneDialog(context);
              },
            ),
            _buildOptionTile(
              context,
              icon: Icons.delete_outline,
              title: 'DELETE FILE FROM DEVICE STORAGE',
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () => _confirmDeleteFile(context, ref),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? NeoBrutalistColors.darkText : NeoBrutalistColors.lightText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? defaultTextColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: textColor ?? defaultTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
