
import 'package:http/http.dart' as http;
import 'dart:convert';

class DayWeather {}


Map<String, String> getWeather(String date, Map<String, dynamic> weatherJson) {
  for (var i = 0; i <= weatherJson['daily']['time'].length; i++) {
    if (weatherJson['daily']['time'][i] == date.toString()) {
      return {
        'max_temperature':
            weatherJson['daily']['temperature_2m_max'][i].toString(),
        'min_temperature':
            weatherJson['daily']['temperature_2m_min'][i].toString(),
        'apparent_max_temperature':
            weatherJson['daily']['apparent_temperature_max'][i].toString(),
        'precipitation_probability': weatherJson['daily']
                ['precipitation_probability_max'][i]
            .toString()
      };
    }
  }
  return <String, String>{};
}


Future<Map<String, dynamic>> fetchWeather() async {
  const String url =
      'https://api.open-meteo.com/v1/forecast?latitude=54.1875&longitude=37.625&daily=temperature_2m_max,temperature_2m_min,apparent_temperature_max,precipitation_probability_max&timezone=Europe%2FMoscow';
  // const String url = 'https://api.open-meteo.com/v1/forecast?latitude=54.1961&longitude=37.6182&hourly=temperature_2m,apparent_temperature,precipitation_probability,cloud_cover&timezone=Europe%2FMoscow';
  final response = await http.get(Uri.parse(url));
  return response.body.isEmpty ? {} : json.decode(response.body);
}
