import 'package:app/features/weather/domain/models/rayong_weather.dart';
import 'package:dio/dio.dart';

class WeatherRemoteDatasource {
  final Dio dio;

  WeatherRemoteDatasource({Dio? dio}) : dio = dio ?? Dio();

  Future<RayongWeather> getRayongWeather() async {
    final response = await dio.get(
      'https://api.open-meteo.com/v1/forecast',
      queryParameters: {
        'latitude': 12.6814,
        'longitude': 101.2816,
        'current': 'weather_code,temperature_2m',
        'timezone': 'Asia/Bangkok',
      },
    );

    final data = response.data;
    final current = data is Map ? data['current'] : null;

    if (current is! Map) {
      throw FormatException('Invalid weather response: ${response.data}');
    }

    return RayongWeather.fromJson(Map<String, dynamic>.from(current));
  }
}
