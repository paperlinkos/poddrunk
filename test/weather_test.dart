import 'package:flutter_test/flutter_test.dart';
import 'package:poddrunk/features/library/services/weather_service.dart';

void main() {
  test('Live WeatherService Integration Test', () async {
    final result = await WeatherService.fetchWeather();
    // ignore: avoid_print
    print('>>> LIVE WEATHER: Temp=${result.tempC}°C, Wind=${result.windSpeedKmH}km/h, Condition=${result.condition}, isLive=${result.isLive}');
    expect(result.tempC, isNotNull);
    expect(result.windSpeedKmH, isNotNull);
  });
}
