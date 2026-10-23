import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/neo_brutalist_theme.dart';
import '../../settings/providers/settings_provider.dart';
import '../services/weather_service.dart';

class WeatherBadge extends ConsumerStatefulWidget {
  const WeatherBadge({super.key});

  @override
  ConsumerState<WeatherBadge> createState() => _WeatherBadgeState();
}

class _WeatherBadgeState extends ConsumerState<WeatherBadge> {
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
    final settings = ref.read(settingsProvider);
    final data = await WeatherService.fetchWeather(
      onlineEnabled: settings.enableOnlineWeather,
      customEndpoint: settings.openMeteoEndpoint,
    );
    if (mounted) {
      setState(() {
        _weather = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SettingsState>(settingsProvider, (previous, next) {
      if (previous?.enableOnlineWeather != next.enableOnlineWeather ||
          previous?.openMeteoEndpoint != next.openMeteoEndpoint) {
        _loadLiveWeather();
      }
    });
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
        message: _weather.isLive
            ? '${_weather.condition} • Live via Open-Meteo (tap to refresh)'
            : '${_weather.condition} • Offline ambient weather (tap to refresh)',
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
