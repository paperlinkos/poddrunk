import 'package:flutter/services.dart';
import '../domain/models/track_model.dart';

enum RingtoneTarget {
  ringtone,
  notification,
  alarm,
}

class RingtoneService {
  static const MethodChannel _channel = MethodChannel('com.neobrutalism.poddrunk/ringtone');

  /// Check if the app has permission to modify system audio settings (Android M+)
  static Future<bool> checkCanWriteSettings() async {
    try {
      final bool? canWrite = await _channel.invokeMethod<bool>('checkCanWriteSettings');
      return canWrite ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Direct the user to the Android System Settings screen to grant WRITE_SETTINGS
  static Future<bool> openWriteSettings() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('openWriteSettings');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Sets the given track as ringtone, notification, or alarm.
  /// Returns 'SUCCESS', 'PERMISSION_NEEDED', or throws an Exception on failure.
  static Future<String> setRingtone(
    TrackModel track, {
    RingtoneTarget target = RingtoneTarget.ringtone,
  }) async {
    final typeString = switch (target) {
      RingtoneTarget.notification => 'notification',
      RingtoneTarget.alarm => 'alarm',
      RingtoneTarget.ringtone => 'ringtone',
    };

    final result = await _channel.invokeMethod<String>('setRingtone', {
      'filePath': track.uri,
      'trackId': track.id,
      'title': track.title,
      'type': typeString,
    });

    return result ?? 'ERROR';
  }
}
