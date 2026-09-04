import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class LiveWeatherData {
  final IconData icon;
  final int tempC;
  final int windSpeedKmH;
  final String condition;
  final bool isLive;

  const LiveWeatherData({
    required this.icon,
    required this.tempC,
    required this.windSpeedKmH,
    required this.condition,
    this.isLive = false,
  });
}

class WeatherService {
  static LiveWeatherData? _cached;
  static DateTime? _lastFetchTime;

  /// Fetches real-time weather from Open-Meteo using IP geolocation.
  /// Falls back to ambient time-of-day condition on connection failure.
  static Future<LiveWeatherData> fetchWeather() async {
    // Return cached if fetched within the last 15 minutes
    if (_cached != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes < 15) {
      return _cached!;
    }

    try {
      final (lat, lon) = await _getCoordinatesFromIp();
      final weather = await _fetchOpenMeteo(lat, lon);
      _cached = weather;
      _lastFetchTime = DateTime.now();
      return weather;
    } catch (_) {
      // Fallback to ambient offline weather
      return getAmbientWeather();
    }
  }

  static Future<(double, double)> _getCoordinatesFromIp() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);

    try {
      // Try ipwhois first
      final request = await client.getUrl(Uri.parse('https://ipwhois.app/json/'));
      final response = await request.close().timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        if (json['latitude'] != null && json['longitude'] != null) {
          return (
            (json['latitude'] as num).toDouble(),
            (json['longitude'] as num).toDouble(),
          );
        }
      }
    } catch (_) {
      // Ignore and fallback to secondary
    }

    // Secondary IP lookup: ip-api.com
    final request2 = await client.getUrl(Uri.parse('http://ip-api.com/json'));
    final response2 = await request2.close().timeout(const Duration(seconds: 4));
    if (response2.statusCode == 200) {
      final body = await response2.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      if (json['lat'] != null && json['lon'] != null) {
        return (
          (json['lat'] as num).toDouble(),
          (json['lon'] as num).toDouble(),
        );
      }
    }

    throw Exception('Could not determine IP coordinates');
  }

  static Future<LiveWeatherData> _fetchOpenMeteo(double lat, double lon) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,wind_speed_10m,weather_code',
    );

    final request = await client.getUrl(url);
    final response = await request.close().timeout(const Duration(seconds: 4));

    if (response.statusCode == 200) {
      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final current = json['current'] as Map<String, dynamic>?;

      if (current != null) {
        final temp = (current['temperature_2m'] as num?)?.round() ?? 22;
        final wind = (current['wind_speed_10m'] as num?)?.round() ?? 10;
        final code = (current['weather_code'] as num?)?.toInt() ?? 0;

        return LiveWeatherData(
          icon: _mapWmoCodeToIcon(code),
          tempC: temp,
          windSpeedKmH: wind,
          condition: _mapWmoCodeToLabel(code),
          isLive: true,
        );
      }
    }

    throw Exception('Failed to parse Open-Meteo response');
  }

  static IconData _mapWmoCodeToIcon(int code) {
    final hour = DateTime.now().hour;
    final isNight = hour < 6 || hour >= 20;

    if (code == 0) {
      return isNight ? Icons.nightlight_round_outlined : Icons.wb_sunny_outlined;
    } else if (code <= 3) {
      return Icons.cloud_outlined;
    } else if (code >= 51 && code <= 67) {
      return Icons.water_drop_outlined;
    } else if (code >= 71 && code <= 77) {
      return Icons.ac_unit;
    } else if (code >= 80 && code <= 82) {
      return Icons.water_drop_outlined;
    } else if (code >= 95) {
      return Icons.flash_on_outlined;
    }
    return Icons.cloud_outlined;
  }

  static String _mapWmoCodeToLabel(int code) {
    if (code == 0) return 'Clear';
    if (code <= 3) return 'Partly Cloudy';
    if (code >= 51 && code <= 67) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Showers';
    if (code >= 95) return 'Thunderstorm';
    return 'Overcast';
  }

  /// Ambient fallback when offline
  static LiveWeatherData getAmbientWeather() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 11) {
      return const LiveWeatherData(
        icon: Icons.cloud_outlined,
        tempC: 21,
        windSpeedKmH: 9,
        condition: 'Breezy Morning',
        isLive: false,
      );
    } else if (hour >= 11 && hour < 18) {
      return const LiveWeatherData(
        icon: Icons.wb_sunny_outlined,
        tempC: 25,
        windSpeedKmH: 14,
        condition: 'Sunny Midday',
        isLive: false,
      );
    } else if (hour >= 18 && hour < 22) {
      return const LiveWeatherData(
        icon: Icons.cloud_outlined,
        tempC: 22,
        windSpeedKmH: 11,
        condition: 'Breezy Evening',
        isLive: false,
      );
    } else {
      return const LiveWeatherData(
        icon: Icons.nightlight_round_outlined,
        tempC: 18,
        windSpeedKmH: 6,
        condition: 'Clear Night',
        isLive: false,
      );
    }
  }
}
