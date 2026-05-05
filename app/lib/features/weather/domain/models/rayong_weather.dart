enum WeatherAssetType { cloudy, rainy, storm }

class RayongWeather {
  final int weatherCode;
  final double temperature;

  const RayongWeather({required this.weatherCode, required this.temperature});

  factory RayongWeather.fromJson(Map<String, dynamic> json) {
    return RayongWeather(
      weatherCode: _parseInt(json['weather_code']),
      temperature: _parseDouble(json['temperature_2m']),
    );
  }

  WeatherAssetType get assetType {
    if (weatherCode == 95 || weatherCode == 96 || weatherCode == 99) {
      return WeatherAssetType.storm;
    }

    if ((weatherCode >= 51 && weatherCode <= 67) ||
        (weatherCode >= 80 && weatherCode <= 82)) {
      return WeatherAssetType.rainy;
    }

    return WeatherAssetType.cloudy;
  }

  String get assetPath {
    switch (assetType) {
      case WeatherAssetType.storm:
        return 'lib/assets/image/weather/storm_3d.png';
      case WeatherAssetType.rainy:
        return 'lib/assets/image/weather/cloud_with_rain_3d.png';
      case WeatherAssetType.cloudy:
        return 'lib/assets/image/weather/sun_behind_cloud_3d.png';
    }
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
