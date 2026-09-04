import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/neo_brutalist_theme.dart';
import '../../../core/widgets/brutalist_button.dart';
import '../../../core/widgets/brutalist_card.dart';
import '../providers/equalizer_provider.dart';

class EqualizerScreen extends ConsumerWidget {
  const EqualizerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eqState = ref.watch(equalizerProvider);
    final eqNotifier = ref.read(equalizerProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? NeoBrutalistColors.darkPrimary : NeoBrutalistColors.lightPrimary;
    final accentColor = isDark ? NeoBrutalistColors.darkAccent : NeoBrutalistColors.lightAccent;
    final textColor = isDark ? NeoBrutalistColors.darkText : NeoBrutalistColors.lightText;
    final cardBg = isDark ? NeoBrutalistColors.darkCardBg : NeoBrutalistColors.lightCardBg;

    final presetKeys = EqualizerNotifier.presets.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AUDIO EQUALIZER & FX'),
        actions: [
          Switch(
            value: eqState.isEnabled,
            activeThumbColor: Colors.black,
            activeTrackColor: accentColor,
            onChanged: (val) => eqNotifier.toggleEnabled(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Preset Selector Section
          Text(
            'SOUND PROFILES & PRESETS',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1.5,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: presetKeys.map((preset) {
                final isSelected = eqState.selectedPreset == preset;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: BrutalistButton(
                    backgroundColor: isSelected ? accentColor : cardBg,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    onPressed: eqState.isEnabled ? () => eqNotifier.applyPreset(preset) : null,
                    child: Text(
                      preset,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: isSelected ? Colors.black : textColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // 5-Band Frequency Faders
          BrutalistCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '5-BAND FREQUENCY CONTROL',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                    Text(
                      eqState.selectedPreset,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Sliders Row
                SizedBox(
                  height: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: eqState.bands.entries.map((entry) {
                      final freq = entry.key;
                      final gain = entry.value;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${gain > 0 ? '+' : ''}${gain.toStringAsFixed(0)}dB',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
                          ),
                          Expanded(
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: primaryColor,
                                  inactiveTrackColor: isDark ? Colors.black54 : Colors.grey.shade300,
                                  thumbColor: accentColor,
                                  trackHeight: 6,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                                ),
                                child: Slider(
                                  value: gain,
                                  min: -10.0,
                                  max: 10.0,
                                  onChanged: eqState.isEnabled
                                      ? (val) => eqNotifier.setBandGain(freq, val)
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            freq,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              color: textColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Bass Boost & Virtualizer Controls
          Row(
            children: [
              // Bass Boost Card
              Expanded(
                child: BrutalistCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'BASS BOOST',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                          ),
                          Text(
                            '${(eqState.bassBoost * 100).toInt()}%',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: accentColor,
                          thumbColor: primaryColor,
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: eqState.bassBoost,
                          min: 0.0,
                          max: 1.0,
                          onChanged: eqState.isEnabled
                              ? (v) => eqNotifier.setBassBoost(v)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Virtualizer Card
              Expanded(
                child: BrutalistCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'SURROUND 3D',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                          ),
                          Text(
                            '${(eqState.virtualizer * 100).toInt()}%',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: primaryColor,
                          thumbColor: accentColor,
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: eqState.virtualizer,
                          min: 0.0,
                          max: 1.0,
                          onChanged: eqState.isEnabled
                              ? (v) => eqNotifier.setVirtualizer(v)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Reset Button
          BrutalistButton(
            onPressed: () => eqNotifier.applyPreset('FLAT'),
            child: const Text(
              'RESET TO FLAT / DEFAULT',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
