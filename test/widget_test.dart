import 'package:flutter_test/flutter_test.dart';
import 'package:poddrunk/features/audio/providers/counted_repeat_provider.dart';

void main() {
  group('Counted Repeat Engine Tests', () {
    test('Initial state is RepeatMode.off', () {
      final notifier = CountedRepeatNotifier();
      expect(notifier.state.mode, RepeatMode.off);
      expect(notifier.state.initialCount, 5);
      expect(notifier.state.remainingCount, 5);
    });

    test('Mode toggle sequence works correctly', () {
      final notifier = CountedRepeatNotifier();
      
      // off -> all
      notifier.toggleMode();
      expect(notifier.state.mode, RepeatMode.all);

      // all -> single
      notifier.toggleMode();
      expect(notifier.state.mode, RepeatMode.single);

      // single -> counted
      notifier.toggleMode();
      expect(notifier.state.mode, RepeatMode.counted);

      // counted -> off
      notifier.toggleMode();
      expect(notifier.state.mode, RepeatMode.off);
    });

    test('Counted repeat countdown decrements and resets when reaching 1', () {
      final notifier = CountedRepeatNotifier();
      notifier.setCountedLoop(3);

      expect(notifier.state.mode, RepeatMode.counted);
      expect(notifier.state.remainingCount, 3);

      // First completion: remainingCount 3 -> 2, should return true (loop track)
      bool loopResult1 = notifier.handleTrackCompletion();
      expect(loopResult1, isTrue);
      expect(notifier.state.remainingCount, 2);

      // Second completion: remainingCount 2 -> 1, should return true (loop track)
      bool loopResult2 = notifier.handleTrackCompletion();
      expect(loopResult2, isTrue);
      expect(notifier.state.remainingCount, 1);

      // Third completion: remainingCount 1 -> mode resets to off, returns false (advance queue)
      bool loopResult3 = notifier.handleTrackCompletion();
      expect(loopResult3, isFalse);
      expect(notifier.state.mode, RepeatMode.off);
    });
  });
}
