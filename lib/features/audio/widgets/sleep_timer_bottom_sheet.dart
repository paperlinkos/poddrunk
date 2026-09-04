import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/neo_brutalist_theme.dart';
import '../../../core/widgets/brutalist_button.dart';
import '../../../core/widgets/brutalist_card.dart';
import '../providers/sleep_timer_provider.dart';

class SleepTimerBottomSheet extends ConsumerWidget {
  const SleepTimerBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const SleepTimerBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(sleepTimerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? NeoBrutalistColors.darkCardBg : NeoBrutalistColors.lightCardBg;
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
    final textColor = isDark ? NeoBrutalistColors.darkText : NeoBrutalistColors.lightText;
    final primaryColor = isDark ? NeoBrutalistColors.darkPrimary : NeoBrutalistColors.lightPrimary;

    final presets = [
      {'label': '15 MINUTES', 'duration': const Duration(minutes: 15)},
      {'label': '30 MINUTES', 'duration': const Duration(minutes: 30)},
      {'label': '45 MINUTES', 'duration': const Duration(minutes: 45)},
      {'label': '60 MINUTES', 'duration': const Duration(minutes: 60)},
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
                child: const Icon(Icons.bedtime_outlined, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SLEEP TIMER',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    Text(
                      timerState.isActive
                          ? 'Active: ${timerState.formattedRemaining} remaining'
                          : 'Automatically pauses audio when you fall asleep',
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

          // Presets
          ...presets.map((p) {
            final dur = p['duration'] as Duration;
            final isCurrent = timerState.isActive &&
                !timerState.isEndOfTrack &&
                timerState.initialDuration == dur;

            return BrutalistCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              backgroundColor: isCurrent ? primaryColor : null,
              onTap: () {
                ref.read(sleepTimerProvider.notifier).startTimer(dur);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('SLEEP TIMER SET FOR ${p['label']}'),
                    backgroundColor: Colors.black,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      p['label'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                  if (isCurrent)
                    const Icon(Icons.check_circle, color: Colors.black, size: 20),
                ],
              ),
            );
          }),

          // End of Current Track Option
          BrutalistCard(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            backgroundColor: timerState.isEndOfTrack ? primaryColor : null,
            onTap: () {
              ref.read(sleepTimerProvider.notifier).setEndOfTrack();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SLEEP TIMER SET FOR END OF CURRENT SONG'),
                  backgroundColor: Colors.black,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Row(
              children: [
                const Icon(Icons.music_note, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'END OF CURRENT SONG',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),
                if (timerState.isEndOfTrack)
                  const Icon(Icons.check_circle, color: Colors.black, size: 20),
              ],
            ),
          ),

          // Cancel Timer Button (if active)
          if (timerState.isActive)
            BrutalistButton(
              backgroundColor: Colors.red,
              onPressed: () {
                ref.read(sleepTimerProvider.notifier).cancelTimer();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('SLEEP TIMER CANCELLED'),
                    backgroundColor: Colors.black,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Text(
                'TURN OFF SLEEP TIMER',
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
