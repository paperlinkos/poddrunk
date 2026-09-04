import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/neo_brutalist_theme.dart';
import 'features/audio/services/audio_handler.dart';
import 'features/audio/providers/audio_player_provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/splash/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize audio background service
  PoddrunkAudioHandler? audioHandler;
  try {
    audioHandler = await initAudioService();
  } catch (e) {
    debugPrint('AudioService init error: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        if (audioHandler != null)
          audioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: PoddrunkApp(audioHandler: audioHandler),
    ),
  );
}

class PoddrunkApp extends ConsumerStatefulWidget {
  final PoddrunkAudioHandler? audioHandler;

  const PoddrunkApp({super.key, this.audioHandler});

  @override
  ConsumerState<PoddrunkApp> createState() => _PoddrunkAppState();
}

class _PoddrunkAppState extends ConsumerState<PoddrunkApp> {
  @override
  void initState() {
    super.initState();
    if (widget.audioHandler != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(audioPlayerProvider.notifier).setHandler(widget.audioHandler!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Poddrunk',
      debugShowCheckedModeBanner: false,
      theme: NeoBrutalistTheme.lightTheme(),
      darkTheme: NeoBrutalistTheme.darkTheme(),
      themeMode: settingsState.themeMode,
      home: const SplashScreen(),
    );
  }
}
