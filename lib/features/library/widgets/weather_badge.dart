import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/neo_brutalist_theme.dart';
import '../services/weather_service.dart';

class WeatherBadge extends StatefulWidget {
  const WeatherBadge({super.key});

  @override
  State<WeatherBadge> createState() => _WeatherBadgeState();
}

class _WeatherBadgeState extends State<WeatherBadge> {
  late LiveWeatherData _weather;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize immediately with local ambient weather so UI appears instantly
    _weather = WeatherService.getAmbientWeather();
    _loadLiveWeather();
  }

  Future<void> _loadLiveWeather() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final data = await WeatherService.fetchWeather();
    if (mounted) {
      setState(() {
        _weather = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? NeoBrutalistColors.darkBorder : NeoBrutalistColors.lightBorder;
    final textColor = isDark ? NeoBrutalistColors.darkText : NeoBrutalistColors.lightText;

    final infoStyle = GoogleFonts.spaceGrotesk(
      color: textColor,
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.2,
    );

    return InkWell(
      onTap: _loadLiveWeather,
      borderRadius: BorderRadius.circular(4),
      child: Tooltip(
        message: '${_weather.condition} • Tap to refresh live weather',
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? NeoBrutalistColors.darkCardBg : NeoBrutalistColors.lightCardBg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: NeoBrutalistTheme.borderWidth),
            boxShadow: [
              BoxShadow(
                color: borderColor,
                offset: const Offset(1.5, 1.5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                _weather.icon,
                size: 13,
                color: textColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${_weather.tempC}°C',
                style: infoStyle,
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.air,
                size: 13,
                color: textColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${_weather.windSpeedKmH}km/h',
                style: infoStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
