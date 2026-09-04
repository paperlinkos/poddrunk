import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/neo_brutalist_theme.dart';
import '../../../core/widgets/brutalist_card.dart';
import '../../../core/widgets/brutalist_button.dart';
import '../providers/queue_provider.dart';
import '../../audio/providers/audio_player_provider.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueState = ref.watch(queueProvider);
    final queueNotifier = ref.read(queueProvider.notifier);
    final playerState = ref.watch(audioPlayerProvider);

    final currentQueue = queueState.currentQueue;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
    final textColor = isDark ? NeoBrutalistColors.darkText : NeoBrutalistColors.lightText;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PLAY QUEUE'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.shuffle,
              color: queueState.isShuffle
                  ? (isDark ? NeoBrutalistColors.darkAccent : NeoBrutalistColors.lightAccent)
                  : textColor,
            ),
            onPressed: () => queueNotifier.toggleShuffle(),
          ),
        ],
      ),
      body: currentQueue.isEmpty
          ? const Center(
              child: Text(
                'QUEUE IS EMPTY',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            )
          : Column(
              children: [
                // Header Bar with Queue Info & Shuffle State
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? NeoBrutalistColors.darkCardBg : NeoBrutalistColors.lightCardBg,
                    border: Border(bottom: BorderSide(color: borderColor, width: NeoBrutalistTheme.borderWidth)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${currentQueue.length} TRACKS IN QUEUE',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                      BrutalistButton(
                        active: queueState.isShuffle,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        onPressed: () => queueNotifier.toggleShuffle(),
                        child: Text(
                          queueState.isShuffle ? 'SHUFFLE ON' : 'SHUFFLE OFF',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),

                // Reorderable Queue List
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 90),
                    itemCount: currentQueue.length,
                    onReorder: (oldIdx, newIdx) {
                      queueNotifier.reorder(oldIdx, newIdx);
                    },
                    itemBuilder: (context, index) {
                      final track = currentQueue[index];
                      final isCurrentTrack = index == queueState.currentIndex;

                      return Container(
                        key: ValueKey('${track.id}_$index'),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: BrutalistCard(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          backgroundColor: isCurrentTrack
                              ? (isDark
                                  ? NeoBrutalistColors.darkAccent.withValues(alpha: 0.35)
                                  : NeoBrutalistColors.lightPrimary)
                              : null,
                          onTap: () {
                            if (isCurrentTrack) {
                              ref.read(audioPlayerProvider.notifier).togglePlayPause();
                            } else {
                              queueNotifier.playTrackAtIndex(index);
                            }
                          },
                          child: Row(
                            children: [
                              // Drag Handle
                              ReorderableDragStartListener(
                                index: index,
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(Icons.drag_handle, size: 20),
                                ),
                              ),

                              // Play Status Indicator
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isCurrentTrack
                                      ? (isDark ? NeoBrutalistColors.darkAccent : NeoBrutalistColors.lightAccent)
                                      : Colors.grey.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: borderColor, width: 1.0),
                                ),
                                child: Center(
                                  child: isCurrentTrack
                                      ? Icon(
                                          playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : Text(
                                          '${index + 1}',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      track.artist,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                _formatDuration(track.duration),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                              const SizedBox(width: 8),

                              // Remove button
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  queueNotifier.removeTrackAt(index);
                                },
                              ),
                            ],
                          ),
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
