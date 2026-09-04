import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final int seekIntervalSeconds; // 10, 15, 30, 60
  final ThemeMode themeMode;

  const SettingsState({
    this.seekIntervalSeconds = 30,
    this.themeMode = ThemeMode.system,
  });

  SettingsState copyWith({
    int? seekIntervalSeconds,
    ThemeMode? themeMode,
  }) {
    return SettingsState(
      seekIntervalSeconds: seekIntervalSeconds ?? this.seekIntervalSeconds,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  static const String _keySeek = 'poddrunk_seek_interval';
  static const String _keyTheme = 'poddrunk_theme_mode';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final seek = prefs.getInt(_keySeek) ?? 30;
    final themeIdx = prefs.getInt(_keyTheme) ?? 0;
    
    ThemeMode mode;
    switch (themeIdx) {
      case 1:
        mode = ThemeMode.light;
        break;
      case 2:
        mode = ThemeMode.dark;
        break;
      default:
        mode = ThemeMode.system;
    }

    state = SettingsState(
      seekIntervalSeconds: seek,
      themeMode: mode,
    );
  }

  Future<void> setSeekInterval(int seconds) async {
    state = state.copyWith(seekIntervalSeconds: seconds);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySeek, seconds);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    int idx = 0;
    if (mode == ThemeMode.light) idx = 1;
    if (mode == ThemeMode.dark) idx = 2;
    await prefs.setInt(_keyTheme, idx);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
