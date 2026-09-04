import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/neo_brutalist_theme.dart';
import '../../../core/widgets/brutalist_card.dart';
import '../../../core/widgets/brutalist_button.dart';
import '../providers/settings_provider.dart';
import '../../equalizer/screens/equalizer_screen.dart';
import '../../audio/widgets/sleep_timer_bottom_sheet.dart';
import '../../library/widgets/folder_browser_view.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Section: Appearance Theme Mode
          _buildSectionHeader(context, 'THEME MODE'),
          const SizedBox(height: 8),
          BrutalistCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BrutalistButton(
                  active: settingsState.themeMode == ThemeMode.system,
                  onPressed: () => settingsNotifier.setThemeMode(ThemeMode.system),
                  child: const Text('SYSTEM'),
                ),
                BrutalistButton(
                  active: settingsState.themeMode == ThemeMode.light,
                  onPressed: () => settingsNotifier.setThemeMode(ThemeMode.light),
                  child: const Text('LIGHT'),
                ),
                BrutalistButton(
                  active: settingsState.themeMode == ThemeMode.dark,
                  onPressed: () => settingsNotifier.setThemeMode(ThemeMode.dark),
                  child: const Text('DARK'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section: Audio Tools & Enhancements
          _buildSectionHeader(context, 'AUDIO TOOLS & PLAYBACK FX'),
          const SizedBox(height: 8),
          BrutalistCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.equalizer),
                  title: const Text('5-BAND EQUALIZER & BASS BOOST', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  subtitle: const Text('Custom sound profiles & frequency shaping', style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const EqualizerScreen()),
                    );
                  },
                ),
                Divider(color: borderColor, height: 1),
                ListTile(
                  leading: const Icon(Icons.bedtime_outlined),
                  title: const Text('SLEEP TIMER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  subtitle: const Text('Auto-pause audio after time or song finish', style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => SleepTimerBottomSheet.show(context),
                ),
                Divider(color: borderColor, height: 1),
                ListTile(
                  leading: const Icon(Icons.folder_open),
                  title: const Text('STORAGE FOLDER BROWSER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  subtitle: const Text('Browse audio by device folder hierarchy', style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const FolderBrowserScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section: Configurable Seek Intervals
          _buildSectionHeader(context, 'ARTWORK DOUBLE-TAP SEEK INTERVAL'),
          const SizedBox(height: 8),
          BrutalistCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Set forward/rewind skip duration when double-tapping cassette artwork:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [10, 15, 30, 60].map((seconds) {
                    final isSelected = settingsState.seekIntervalSeconds == seconds;
                    return BrutalistButton(
                      active: isSelected,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      onPressed: () => settingsNotifier.setSeekInterval(seconds),
                      child: Text('${seconds}s'),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section: App Info
          _buildSectionHeader(context, 'APP INFO'),
          const SizedBox(height: 8),
          const BrutalistCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Poddrunk', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                SizedBox(height: 4),
                Text('Offline Music & Audio Player', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                SizedBox(height: 12),
                Text('Version 1.0.0 • 100% Offline & Ad-Free', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
      ),
    );
  }
}
