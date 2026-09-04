import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/neo_brutalist_theme.dart';
import '../../../core/widgets/brutalist_button.dart';
import '../../../core/widgets/brutalist_card.dart';
import '../../audio/domain/models/track_model.dart';
import '../../audio/providers/audio_player_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/track_options_bottom_sheet.dart';
import '../../player/screens/now_playing_screen.dart';

class FolderBrowserScreen extends ConsumerStatefulWidget {
  const FolderBrowserScreen({super.key});

  @override
  ConsumerState<FolderBrowserScreen> createState() => _FolderBrowserScreenState();
}

class _FolderBrowserScreenState extends ConsumerState<FolderBrowserScreen> {
  String? _selectedFolder;

  String _getFolderName(String uri) {
    if (uri.isEmpty) return 'Unknown Folder';
    try {
      final file = File(uri);
      final parent = file.parent;
      return parent.path.split('/').where((s) => s.isNotEmpty).last;
    } catch (_) {
      return 'Internal Storage';
    }
  }

  String _getParentPath(String uri) {
    if (uri.isEmpty) return '';
    try {
      return File(uri).parent.path;
    } catch (_) {
      return uri;
    }
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryProvider);
    final tracks = libraryState.tracks.where((t) => t.isLocal).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? NeoBrutalistColors.darkPrimary : NeoBrutalistColors.lightPrimary;
    final accentColor = isDark ? NeoBrutalistColors.darkAccent : NeoBrutalistColors.lightAccent;
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
    final textColor = isDark ? NeoBrutalistColors.darkText : NeoBrutalistColors.lightText;

    // Group tracks by parent folder directory path
    final folderMap = <String, List<TrackModel>>{};
    for (var track in tracks) {
      final dirPath = _getParentPath(track.uri);
      folderMap.putIfAbsent(dirPath, () => []).add(track);
    }

    final folderPaths = folderMap.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedFolder != null ? _getFolderName(_selectedFolder!) : 'STORAGE FOLDER BROWSER'),
        leading: _selectedFolder != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedFolder = null),
              )
            : null,
      ),
      body: _selectedFolder == null
          // Folder List View
          ? (folderPaths.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'NO LOCAL DIRECTORIES FOUND',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: folderPaths.length,
                  itemBuilder: (context, index) {
                    final path = folderPaths[index];
                    final folderTracks = folderMap[path]!;
                    final folderName = _getFolderName(path);

                    return BrutalistCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      onTap: () => setState(() => _selectedFolder = path),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: borderColor, width: 1.2),
                            ),
                            child: const Center(
                              child: Icon(Icons.folder, size: 24, color: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  folderName,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${folderTracks.length} SONGS • $path',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: textColor.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    );
                  },
                ))
          // Folder Detail Tracks View
          : _buildFolderDetail(
              context,
              folderMap[_selectedFolder] ?? [],
              _selectedFolder!,
              accentColor,
              primaryColor,
              borderColor,
              textColor,
            ),
    );
  }

  Widget _buildFolderDetail(
    BuildContext context,
    List<TrackModel> folderTracks,
    String path,
    Color accentColor,
    Color primaryColor,
    Color borderColor,
    Color textColor,
  ) {
    return Column(
      children: [
        // Action Banner
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: NeoBrutalistTheme.borderWidth),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getFolderName(path),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                    Text(
                      '${folderTracks.length} Audio Tracks',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              BrutalistButton(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                onPressed: folderTracks.isEmpty
                    ? null
                    : () {
                        ref.read(audioPlayerProvider.notifier).playTrack(
                              folderTracks.first,
                              queue: folderTracks,
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
                  children: [
                    Icon(Icons.play_arrow, color: Colors.black, size: 18),
                    SizedBox(width: 4),
                    Text('PLAY ALL', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tracks List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: folderTracks.length,
            itemBuilder: (context, index) {
              final track = folderTracks[index];
              return BrutalistCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                onTap: () {
                  ref.read(audioPlayerProvider.notifier).playTrack(
                        track,
                        queue: folderTracks,
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
                          Text(
                            '${track.artist} • ${track.album}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: textColor.withValues(alpha: 0.6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => TrackOptionsBottomSheet.show(
                        context,
                        track: track,
                        queue: folderTracks,
                        index: index,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
