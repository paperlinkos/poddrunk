import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poddrunk/features/audio/domain/models/track_model.dart';
import 'package:poddrunk/features/library/providers/history_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HistoryNotifier Tests', () {
    test('Records tracks and bubbles recent play to index 0', () async {
      final notifier = HistoryNotifier();

      const track1 = TrackModel(
        id: '1',
        title: 'Song 1',
        artist: 'Artist A',
        album: 'Album X',
        duration: Duration(seconds: 180),
        uri: '/path/1.mp3',
        isLocal: true,
      );

      const track2 = TrackModel(
        id: '2',
        title: 'Song 2',
        artist: 'Artist B',
        album: 'Album Y',
        duration: Duration(seconds: 210),
        uri: '/path/2.mp3',
        isLocal: true,
      );

      await notifier.recordTrack(track1);
      expect(notifier.state.recentlyPlayed.length, 1);
      expect(notifier.state.recentlyPlayed.first.id, '1');

      await notifier.recordTrack(track2);
      expect(notifier.state.recentlyPlayed.length, 2);
      expect(notifier.state.recentlyPlayed.first.id, '2');

      // Re-record track1 -> should bubble to index 0
      await notifier.recordTrack(track1);
      expect(notifier.state.recentlyPlayed.length, 2);
      expect(notifier.state.recentlyPlayed.first.id, '1');
      expect(notifier.state.recentlyPlayed[1].id, '2');
    });

    test('Clear history empties list', () async {
      final notifier = HistoryNotifier();

      const track = TrackModel(
        id: '1',
        title: 'Song 1',
        artist: 'Artist A',
        album: 'Album X',
        duration: Duration(seconds: 180),
        uri: '/path/1.mp3',
        isLocal: true,
      );

      await notifier.recordTrack(track);
      expect(notifier.state.recentlyPlayed.isNotEmpty, isTrue);

      await notifier.clearHistory();
      expect(notifier.state.recentlyPlayed.isEmpty, isTrue);
    });
  });
}
