import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/neo_brutalist_theme.dart';
import '../../../core/widgets/brutalist_button.dart';
import '../../library/screens/library_screen.dart';
import '../../queue/screens/queue_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../player/screens/now_playing_screen.dart';
import '../../audio/providers/audio_player_provider.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    LibraryScreen(),
    QueueScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(audioPlayerProvider);
    final playerNotifier = ref.read(audioPlayerProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? NeoBrutalistColors.darkPrimary : NeoBrutalistColors.lightPrimary;
    final accentColor = isDark ? NeoBrutalistColors.darkAccent : NeoBrutalistColors.lightAccent;
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
    final textColor = isDark ? NeoBrutalistColors.darkText : NeoBrutalistColors.lightText;

    final currentTrack = playerState.currentTrack;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Persistent Bottom Mini-Player Bar (if track available)
          if (currentTrack != null)
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => const NowPlayingScreen(),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? NeoBrutalistColors.darkCardBg : Colors.white,
                  border: Border(
                    top: BorderSide(color: borderColor, width: NeoBrutalistTheme.borderWidth),
                    bottom: BorderSide(color: borderColor, width: NeoBrutalistTheme.borderWidth),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mini progress indicator at top edge of mini player
                    LinearProgressIndicator(
                      value: playerState.progress,
                      backgroundColor: isDark ? Colors.black45 : Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      minHeight: 3,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          // Cassette Icon with Orange Accent
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: borderColor, width: 1.2),
                            ),
                            child: const Center(
                              child: Icon(Icons.album, color: Colors.white, size: 20),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Title & Artist
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentTrack.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  currentTrack.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isDark
                                        ? NeoBrutalistColors.darkMutedText
                                        : NeoBrutalistColors.lightMutedText,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Skip Previous
                          IconButton(
                            icon: Icon(Icons.skip_previous, color: textColor, size: 22),
                            onPressed: () => playerNotifier.skipPrevious(),
                          ),

                          // Mini Play/Pause Button in Vibrant Orange
                          BrutalistButton(
                            padding: const EdgeInsets.all(8),
                            backgroundColor: accentColor,
                            borderColor: borderColor,
                            onPressed: () => playerNotifier.togglePlayPause(),
                            child: Icon(
                              playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),

                          // Skip Next
                          IconButton(
                            icon: Icon(Icons.skip_next, color: textColor, size: 22),
                            onPressed: () => playerNotifier.skipNext(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Neo-Brutalist Bottom Tab Bar
          Container(
            decoration: BoxDecoration(
              color: isDark ? NeoBrutalistColors.darkCanvas : primaryColor,
              border: Border(
                top: BorderSide(color: borderColor, width: NeoBrutalistTheme.borderWidth),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: isDark ? NeoBrutalistColors.darkPrimary : textColor,
              unselectedItemColor: isDark
                  ? NeoBrutalistColors.darkMutedText
                  : textColor.withValues(alpha: 0.5),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_music),
                  label: 'LIBRARY',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.queue_music),
                  label: 'QUEUE',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'SETTINGS',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
