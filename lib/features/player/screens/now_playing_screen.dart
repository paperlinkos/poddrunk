import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/neo_brutalist_theme.dart';
import '../../../core/widgets/brutalist_button.dart';
import '../../../core/widgets/brutalist_badge.dart';
import '../../../core/widgets/brutalist_modal.dart';
import '../../../core/widgets/retro_cassette_widget.dart';
import '../../audio/providers/audio_player_provider.dart';
import '../../audio/providers/counted_repeat_provider.dart';
import '../../audio/providers/sleep_timer_provider.dart';
import '../../audio/widgets/sleep_timer_bottom_sheet.dart';
import '../../audio/widgets/playback_speed_bottom_sheet.dart';
import '../../queue/providers/queue_provider.dart';
import '../../settings/providers/settings_provider.dart';

class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  String? _seekOverlayText;
  double? _dragValue;

  void _showSeekOverlay(String text) {
    setState(() => _seekOverlayText = text);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _seekOverlayText = null);
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _openCountedRepeatModal(BuildContext context) {
    BrutalistModal.show(
      context: context,
      title: 'COUNTED REPEAT ENGINE',
      child: Consumer(
        builder: (context, ref, child) {
          final repeatState = ref.watch(countedRepeatProvider);
          final repeatNotifier = ref.read(countedRepeatProvider.notifier);
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final border = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
          final accent = isDark ? NeoBrutalistColors.darkAccent : NeoBrutalistColors.lightAccent;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Set Finite Loop Count for Track',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Stepper [-] [ N ] [+]
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BrutalistButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    onPressed: () => repeatNotifier.decrementInitialCount(),
                    child: const Text('-', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 70,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: border, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        '${repeatState.initialCount}x',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  BrutalistButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    onPressed: () => repeatNotifier.incrementInitialCount(),
                    child: const Text('+', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Quick Chips (2x, 3x, 5x, 10x)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [2, 3, 5, 10].map((count) {
                  final isSelected = repeatState.mode == RepeatMode.counted && repeatState.initialCount == count;
                  return BrutalistButton(
                    active: isSelected,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    onPressed: () => repeatNotifier.setCountedLoop(count),
                    child: Text('${count}x'),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),

              // Mode Selectors
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  BrutalistButton(
                    active: repeatState.mode == RepeatMode.off,
                    onPressed: () => repeatNotifier.setMode(RepeatMode.off),
                    child: const Text('OFF'),
                  ),
                  BrutalistButton(
                    active: repeatState.mode == RepeatMode.all,
                    onPressed: () => repeatNotifier.setMode(RepeatMode.all),
                    child: const Text('REPEAT ALL'),
                  ),
                  BrutalistButton(
                    active: repeatState.mode == RepeatMode.single,
                    onPressed: () => repeatNotifier.setMode(RepeatMode.single),
                    child: const Text('REPEAT SINGLE'),
                  ),
                  BrutalistButton(
                    active: repeatState.mode == RepeatMode.counted,
                    onPressed: () => repeatNotifier.setCountedLoop(repeatState.initialCount),
                    child: Text('COUNTED (${repeatState.remainingCount})'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(audioPlayerProvider);
    final playerNotifier = ref.read(audioPlayerProvider.notifier);
    final queueState = ref.watch(queueProvider);
    final queueNotifier = ref.read(queueProvider.notifier);
    final repeatState = ref.watch(countedRepeatProvider);
    final repeatNotifier = ref.read(countedRepeatProvider.notifier);
    final settingsState = ref.watch(settingsProvider);

    final track = playerState.currentTrack;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? NeoBrutalistColors.darkPrimary : NeoBrutalistColors.lightPrimary;
    final accentColor = isDark ? NeoBrutalistColors.darkAccent : NeoBrutalistColors.lightAccent;
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
    final textColor = isDark ? NeoBrutalistColors.darkText : NeoBrutalistColors.lightText;

    final sleepTimer = ref.watch(sleepTimerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NOW PLAYING'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Playback Speed Selector Chip
          InkWell(
            onTap: () => PlaybackSpeedBottomSheet.show(context),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Text(
                '${playerState.speed}x',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
          ),

          // Sleep Timer Icon
          IconButton(
            icon: Icon(
              sleepTimer.isActive ? Icons.bedtime : Icons.bedtime_outlined,
              color: sleepTimer.isActive ? Colors.red : textColor,
              size: 22,
            ),
            tooltip: 'Sleep Timer',
            onPressed: () => SleepTimerBottomSheet.show(context),
          ),

          // Queue Button
          IconButton(
            icon: const Icon(Icons.queue_music, size: 22),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Retro Cassette Tape Artwork with Double-Tap Seek Gestures
              Stack(
                children: [
                  RetroCassetteWidget(
                    isPlaying: playerState.isPlaying,
                    title: track?.title ?? 'NO TRACK SELECTED',
                    artist: track?.artist ?? 'SELECT FROM LIBRARY',
                    progress: playerState.progress,
                  ),

                  // Double-tap left half -> Seek Backward
                  Positioned.fill(
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onDoubleTap: () {
                              playerNotifier.seekBy(-settingsState.seekIntervalSeconds);
                              _showSeekOverlay('-${settingsState.seekIntervalSeconds}s');
                            },
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onDoubleTap: () {
                              playerNotifier.seekBy(settingsState.seekIntervalSeconds);
                              _showSeekOverlay('+${settingsState.seekIntervalSeconds}s');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Seek Overlay Indicator Animation
                  if (_seekOverlayText != null)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: accentColor,
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _seekOverlayText!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Title & Artist Block
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? NeoBrutalistColors.darkCardBg : NeoBrutalistColors.lightCardBg,
                  borderRadius: BorderRadius.circular(NeoBrutalistTheme.borderRadius),
                  border: Border.all(color: borderColor, width: NeoBrutalistTheme.borderWidth),
                  boxShadow: [
                    BoxShadow(color: borderColor, offset: NeoBrutalistTheme.shadowOffset, blurRadius: 0),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track?.title ?? 'NO TRACK PLAYING',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${track?.artist ?? "Unknown Artist"} — ${track?.album ?? "Unknown Album"}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Scrubber Slider
              Builder(
                builder: (context) {
                  final durationMs = playerState.duration.inMilliseconds.toDouble();
                  final maxVal = durationMs > 0 ? durationMs : 1.0;
                  final currentPosMs = playerState.position.inMilliseconds.toDouble();
                  final sliderValue = (_dragValue ?? currentPosMs).clamp(0.0, maxVal);
                  final displayPos = _dragValue != null
                      ? Duration(milliseconds: _dragValue!.toInt())
                      : playerState.position;

                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 6,
                          activeTrackColor: accentColor,
                          inactiveTrackColor: isDark ? Colors.white24 : Colors.black12,
                          thumbColor: primaryColor,
                          overlayColor: accentColor.withValues(alpha: 0.2),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 3),
                        ),
                        child: Slider(
                          value: sliderValue,
                          max: maxVal,
                          onChangeStart: (val) {
                            setState(() => _dragValue = val);
                          },
                          onChanged: (val) {
                            setState(() => _dragValue = val);
                          },
                          onChangeEnd: (val) {
                            playerNotifier.seek(Duration(milliseconds: val.toInt()));
                            setState(() => _dragValue = null);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(displayPos),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                            ),
                            Text(
                              _formatDuration(playerState.duration),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Playback Controls Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Shuffle Button
                  BrutalistButton(
                    active: queueState.isShuffle,
                    padding: const EdgeInsets.all(12),
                    onPressed: () => queueNotifier.toggleShuffle(),
                    child: const Icon(Icons.shuffle, size: 20),
                  ),

                  // Previous Track
                  BrutalistButton(
                    padding: const EdgeInsets.all(12),
                    onPressed: () => playerNotifier.skipPrevious(),
                    child: const Icon(Icons.skip_previous, size: 24),
                  ),

                  // Play / Pause Button
                  BrutalistButton(
                    active: true,
                    padding: const EdgeInsets.all(18),
                    onPressed: () => playerNotifier.togglePlayPause(),
                    child: Icon(
                      playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),

                  // Next Track
                  BrutalistButton(
                    padding: const EdgeInsets.all(12),
                    onPressed: () => playerNotifier.skipNext(),
                    child: const Icon(Icons.skip_next, size: 24),
                  ),

                  // Counted Repeat Button with Dynamic Badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      BrutalistButton(
                        active: repeatState.mode != RepeatMode.off,
                        padding: const EdgeInsets.all(12),
                        onPressed: () => repeatNotifier.toggleMode(),
                        onLongPress: () => _openCountedRepeatModal(context),
                        child: const Icon(Icons.repeat, size: 20),
                      ),

                      if (repeatState.badgeText.isNotEmpty)
                        Positioned(
                          top: -6,
                          right: -6,
                          child: BrutalistBadge(text: repeatState.badgeText),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Counted Repeat Status Banner
              if (repeatState.mode == RepeatMode.counted)
                GestureDetector(
                  onTap: () => _openCountedRepeatModal(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: borderColor, width: 1.2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.repeat_one_on, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'COUNTED REPEAT: ${repeatState.remainingCount} LOOPS REMAINING',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  },
),
),
);
}
}
