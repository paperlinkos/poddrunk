import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/providers.dart';
import '../../../core/constants/app_constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final playbackSpeed = ref.watch(playbackSpeedProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            _SectionHeader(title: 'Appearance'),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme'),
              value: isDarkMode,
              onChanged: (value) {
                ref.read(isDarkModeProvider.notifier).toggleTheme();
              },
            ),
            const Divider(),
            _SectionHeader(title: 'Playback'),
            ListTile(
              title: const Text('Default Playback Speed'),
              subtitle: Text('${playbackSpeed}x'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showSpeedPicker(context, ref, playbackSpeed);
              },
            ),
            ListTile(
              title: const Text('Sleep Timer'),
              subtitle: const Text('Off'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const Divider(),
            _SectionHeader(title: 'Storage'),
            ListTile(
              title: const Text('Download Location'),
              subtitle: const Text('Internal Storage'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Clear Download Cache'),
              subtitle: const Text('0 MB used'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const Divider(),
            _SectionHeader(title: 'About'),
            ListTile(
              title: const Text('Version'),
              subtitle: Text(AppConstants.appVersion),
            ),
            ListTile(
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showSpeedPicker(BuildContext context, WidgetRef ref, double currentSpeed) {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Playback Speed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...speeds.map((speed) => ListTile(
                title: Text('${speed}x'),
                trailing: speed == currentSpeed
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  ref.read(playbackSpeedProvider.notifier).state = speed;
                  ref.read(audioPlayerServiceProvider).setSpeed(speed);
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}