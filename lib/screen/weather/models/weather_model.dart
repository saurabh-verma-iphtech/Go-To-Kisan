class Weather {
  final String cityName;
  final double temprature;
  final String description;
  final int humidity;
  final int sunRise;
  final int sunSet;
  final double
      windSpeed; // Changed to double for windSpeed to match the response type

  Weather({
    required this.cityName,
    required this.temprature,
    required this.description,
    required this.humidity,
    required this.sunRise,
    required this.sunSet,
    required this.windSpeed,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      description: json['weather'][0]['description'],
      temprature: json['main']['temp'],
      humidity: json['main']['humidity'],
      sunRise: json['sys']['sunrise'],
      sunSet: json['sys']['sunset'],
      windSpeed: json['wind']['speed'].toDouble(),
    );
  }
}
