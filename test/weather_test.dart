import 'package:flutter_test/flutter_test.dart';
import 'package:poddrunk/features/library/services/weather_service.dart';

void main() {
  group('WeatherService', () {
    test('buildOpenMeteoUri normalizes custom endpoints properly', () {
      final uriDefault = WeatherService.buildOpenMeteoUri('', 12.34, 56.78);
      expect(uriDefault.scheme, equals('https'));
      expect(uriDefault.host, equals('api.open-meteo.com'));
      expect(uriDefault.path, equals('/v1/forecast'));
      expect(uriDefault.queryParameters['latitude'], equals('12.34'));
      expect(uriDefault.queryParameters['longitude'], equals('56.78'));

      final uriCustomHost = WeatherService.buildOpenMeteoUri('meteo.internal.org', 10.0, 20.0);
      expect(uriCustomHost.scheme, equals('https'));
      expect(uriCustomHost.host, equals('meteo.internal.org'));
      expect(uriCustomHost.path, equals('/v1/forecast'));

      final uriCustomFull = WeatherService.buildOpenMeteoUri('http://192.168.1.50:8080/custom/v1/forecast', 10.0, 20.0);
      expect(uriCustomFull.scheme, equals('http'));
      expect(uriCustomFull.host, equals('192.168.1.50'));
      expect(uriCustomFull.port, equals(8080));
      expect(uriCustomFull.path, equals('/custom/v1/forecast'));
    });

    test('fetchWeather returns ambient weather immediately when onlineEnabled is false', () async {
      WeatherService.clearCache();
      final offlineResult = await WeatherService.fetchWeather(onlineEnabled: false);
      expect(offlineResult.isLive, isFalse);
      expect(offlineResult.tempC, isNotNull);
      expect(offlineResult.condition.isNotEmpty, isTrue);
    });

    test('Live WeatherService Integration Test', () async {
      WeatherService.clearCache();
      final result = await WeatherService.fetchWeather(onlineEnabled: true);
      // ignore: avoid_print
      print('>>> LIVE WEATHER: Temp=${result.tempC}°C, Wind=${result.windSpeedKmH}km/h, Condition=${result.condition}, isLive=${result.isLive}');
      expect(result.tempC, isNotNull);
      expect(result.windSpeedKmH, isNotNull);
    });
  });
}
