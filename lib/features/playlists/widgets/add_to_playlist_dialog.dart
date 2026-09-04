import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/neo_brutalist_theme.dart';
import '../../../core/widgets/brutalist_button.dart';
import '../../../core/widgets/brutalist_card.dart';
import '../../audio/domain/models/track_model.dart';
import '../providers/playlist_provider.dart';

class AddToPlaylistBottomSheet extends ConsumerStatefulWidget {
  final TrackModel track;

  const AddToPlaylistBottomSheet({super.key, required this.track});

  @override
  ConsumerState<AddToPlaylistBottomSheet> createState() => _AddToPlaylistBottomSheetState();
}

class _AddToPlaylistBottomSheetState extends ConsumerState<AddToPlaylistBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  bool _isCreatingNew = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createNewPlaylist() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final newPlaylist = await ref.read(playlistProvider.notifier).createPlaylist(name);
    await ref.read(playlistProvider.notifier).addTrackToPlaylist(newPlaylist.id, widget.track);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ADDED "${widget.track.title}" TO "$name"'),
          backgroundColor: Colors.black,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlistState = ref.watch(playlistProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? NeoBrutalistColors.darkPrimary : NeoBrutalistColors.lightPrimary;
    final cardBg = isDark ? NeoBrutalistColors.darkCardBg : NeoBrutalistColors.lightCardBg;
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
    final textColor = isDark ? NeoBrutalistColors.darkText : NeoBrutalistColors.lightText;
    final accentColor = isDark ? NeoBrutalistColors.darkAccent : NeoBrutalistColors.lightAccent;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
        left: 16,
        right: 16,
      ),
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

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: const Icon(Icons.playlist_add, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ADD TO PLAYLIST',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                    Text(
                      widget.track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // New Playlist Creation Toggle / Form
          if (!_isCreatingNew)
            BrutalistButton(
              backgroundColor: accentColor,
              onPressed: () => setState(() => _isCreatingNew = true),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 18, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    'CREATE NEW PLAYLIST',
                    style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black38 : Colors.grey.shade100,
                border: Border.all(color: borderColor, width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                    decoration: InputDecoration(
                      hintText: 'PLAYLIST NAME...',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textColor.withValues(alpha: 0.5),
                      ),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => setState(() => _isCreatingNew = false),
                        child: Text('CANCEL', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      BrutalistButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        onPressed: _createNewPlaylist,
                        child: const Text('CREATE & ADD', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Existing Playlists List
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: playlistState.playlists.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'NO PLAYLISTS YET',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: playlistState.playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlistState.playlists[index];
                      final alreadyIn = playlist.tracks.any((t) => t.id == widget.track.id);

                      return BrutalistCard(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        backgroundColor: alreadyIn
                            ? (isDark ? Colors.grey.shade900 : Colors.grey.shade200)
                            : null,
                        onTap: () async {
                          if (alreadyIn) {
                            await ref
                                .read(playlistProvider.notifier)
                                .removeTrackFromPlaylist(playlist.id, widget.track.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('REMOVED FROM "${playlist.name}"'),
                                  backgroundColor: Colors.black,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          } else {
                            await ref
                                .read(playlistProvider.notifier)
                                .addTrackToPlaylist(playlist.id, widget.track);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('ADDED TO "${playlist.name}"'),
                                  backgroundColor: Colors.black,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                        child: Row(
                          children: [
                            Icon(
                              playlist.id == 'favorites' ? Icons.favorite : Icons.queue_music,
                              size: 22,
                              color: playlist.id == 'favorites' ? Colors.red : textColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    playlist.name,
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                                  ),
                                  Text(
                                    '${playlist.tracks.length} SONGS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: textColor.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              alreadyIn ? Icons.check_circle : Icons.add_circle_outline,
                              color: alreadyIn ? Colors.green : textColor,
                              size: 22,
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
