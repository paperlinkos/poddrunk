import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EqualizerState {
  final bool isEnabled;
  final String selectedPreset;
  final Map<String, double> bands; // Frequency in Hz -> gain (-10.0 to +10.0 dB)
  final double bassBoost; // 0.0 to 1.0
  final double virtualizer; // 0.0 to 1.0

  const EqualizerState({
    this.isEnabled = true,
    this.selectedPreset = 'FLAT',
    this.bands = const {
      '60Hz': 0.0,
      '230Hz': 0.0,
      '910Hz': 0.0,
      '3.6kHz': 0.0,
      '14kHz': 0.0,
    },
    this.bassBoost = 0.0,
    this.virtualizer = 0.0,
  });

  EqualizerState copyWith({
    bool? isEnabled,
    String? selectedPreset,
    Map<String, double>? bands,
    double? bassBoost,
    double? virtualizer,
  }) {
    return EqualizerState(
      isEnabled: isEnabled ?? this.isEnabled,
      selectedPreset: selectedPreset ?? this.selectedPreset,
      bands: bands ?? this.bands,
      bassBoost: bassBoost ?? this.bassBoost,
      virtualizer: virtualizer ?? this.virtualizer,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'selectedPreset': selectedPreset,
      'bands': bands,
      'bassBoost': bassBoost,
      'virtualizer': virtualizer,
    };
  }

  factory EqualizerState.fromJson(Map<String, dynamic> json) {
    final rawBands = json['bands'] as Map<String, dynamic>?;
    final parsedBands = <String, double>{};
    if (rawBands != null) {
      rawBands.forEach((k, v) {
        parsedBands[k] = (v as num).toDouble();
      });
    }

    return EqualizerState(
      isEnabled: json['isEnabled'] as bool? ?? true,
      selectedPreset: json['selectedPreset'] as String? ?? 'FLAT',
      bands: parsedBands.isNotEmpty
          ? parsedBands
          : const {
              '60Hz': 0.0,
              '230Hz': 0.0,
              '910Hz': 0.0,
              '3.6kHz': 0.0,
              '14kHz': 0.0,
            },
      bassBoost: (json['bassBoost'] as num?)?.toDouble() ?? 0.0,
      virtualizer: (json['virtualizer'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class EqualizerNotifier extends StateNotifier<EqualizerState> {
  static const String _storageKey = 'poddrunk_equalizer_settings_v1';

  static const Map<String, Map<String, double>> presets = {
    'FLAT': {
      '60Hz': 0.0,
      '230Hz': 0.0,
      '910Hz': 0.0,
      '3.6kHz': 0.0,
      '14kHz': 0.0,
    },
    'BASS HEAVY': {
      '60Hz': 8.0,
      '230Hz': 5.0,
      '910Hz': -1.0,
      '3.6kHz': 1.0,
      '14kHz': 2.0,
    },
    'VOCAL CLARITY': {
      '60Hz': -3.0,
      '230Hz': 1.0,
      '910Hz': 6.0,
      '3.6kHz': 5.0,
      '14kHz': 2.0,
    },
    'ACOUSTIC': {
      '60Hz': 3.0,
      '230Hz': 2.0,
      '910Hz': 1.0,
      '3.6kHz': 4.0,
      '14kHz': 5.0,
    },
    'ELECTRONIC': {
      '60Hz': 6.0,
      '230Hz': 4.0,
      '910Hz': 0.0,
      '3.6kHz': 4.0,
      '14kHz': 6.0,
    },
    'ROCK': {
      '60Hz': 5.0,
      '230Hz': 3.0,
      '910Hz': -2.0,
      '3.6kHz': 4.0,
      '14kHz': 6.0,
    },
  };

  EqualizerNotifier() : super(const EqualizerState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        state = EqualizerState.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('Error loading equalizer settings: $e');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state.toJson()));
    } catch (e) {
      debugPrint('Error saving equalizer settings: $e');
    }
  }

  void toggleEnabled() {
    state = state.copyWith(isEnabled: !state.isEnabled);
    _persist();
  }

  void applyPreset(String presetName) {
    final presetBands = presets[presetName];
    if (presetBands != null) {
      double newBass = state.bassBoost;
      if (presetName == 'BASS HEAVY') newBass = 0.8;
      if (presetName == 'ELECTRONIC') newBass = 0.6;
      if (presetName == 'FLAT') newBass = 0.0;

      state = state.copyWith(
        selectedPreset: presetName,
        bands: Map<String, double>.from(presetBands),
        bassBoost: newBass,
      );
      _persist();
    }
  }

  void setBandGain(String frequency, double gain) {
    final updated = Map<String, double>.from(state.bands);
    updated[frequency] = gain.clamp(-10.0, 10.0);
    state = state.copyWith(
      bands: updated,
      selectedPreset: 'CUSTOM',
    );
    _persist();
  }

  void setBassBoost(double value) {
    state = state.copyWith(
      bassBoost: value.clamp(0.0, 1.0),
      selectedPreset: 'CUSTOM',
    );
    _persist();
  }

  void setVirtualizer(double value) {
    state = state.copyWith(
      virtualizer: value.clamp(0.0, 1.0),
      selectedPreset: 'CUSTOM',
    );
    _persist();
  }
}

final equalizerProvider = StateNotifierProvider<EqualizerNotifier, EqualizerState>((ref) {
  return EqualizerNotifier();
});
