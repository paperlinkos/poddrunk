import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/neo_brutalist_theme.dart';
import '../../../core/widgets/brutalist_card.dart';
import '../providers/audio_player_provider.dart';

class PlaybackSpeedBottomSheet extends ConsumerWidget {
  const PlaybackSpeedBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PlaybackSpeedBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(audioPlayerProvider);
    final currentSpeed = playerState.speed;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? NeoBrutalistColors.darkCardBg : NeoBrutalistColors.lightCardBg;
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
    final textColor = isDark ? NeoBrutalistColors.darkText : NeoBrutalistColors.lightText;
    final primaryColor = isDark ? NeoBrutalistColors.darkPrimary : NeoBrutalistColors.lightPrimary;

    final speeds = [
      {'speed': 0.5, 'label': '0.5x (Slowed)'},
      {'speed': 0.75, 'label': '0.75x (Relaxed)'},
      {'speed': 1.0, 'label': '1.0x (Standard)'},
      {'speed': 1.25, 'label': '1.25x (Brisk)'},
      {'speed': 1.5, 'label': '1.5x (Fast)'},
      {'speed': 1.75, 'label': '1.75x (Very Fast)'},
      {'speed': 2.0, 'label': '2.0x (Double Speed)'},
    ];

    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 16),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(top: BorderSide(color: borderColor, width: NeoBrutalistTheme.borderWidth)),
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
                child: const Icon(Icons.speed, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PLAYBACK SPEED',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    Text(
                      'Current speed: ${currentSpeed.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}x',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: textColor.withValues(alpha: 0.7),
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

          // Speeds List
          ...speeds.map((s) {
            final val = s['speed'] as double;
            final isSelected = (currentSpeed - val).abs() < 0.01;

            return BrutalistCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              backgroundColor: isSelected ? primaryColor : null,
              onTap: () {
                ref.read(audioPlayerProvider.notifier).setSpeed(val);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('PLAYBACK SPEED SET TO ${val}x'),
                    backgroundColor: Colors.black,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    '${val}x',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.black, size: 20),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
