class Weather {
  final String cityName;
  final double temprature;
  final double tempMin;
  final double tempMax;
  final double feelsLike;
  final String description;
  final int humidity;
  final int sunRise;
  final int sunSet;
  final double windSpeed;
  final double windDirection;
  final String icon;
  final int pressure;

  Weather({
    required this.cityName,
    required this.temprature,
    required this.tempMax,
    required this.tempMin,
    required this.description,
    required this.humidity,
    required this.sunRise,
    required this.sunSet,
    required this.windSpeed,
    required this.windDirection,
    required this.icon,
    required this.feelsLike,
    required this.pressure,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      temprature: json['main']['temp'].toDouble(),
      tempMax: json['main']['temp_max'],
      tempMin: json['main']['temp_min'],
      humidity: json['main']['humidity'],
      sunRise: json['sys']['sunrise'],
      sunSet: json['sys']['sunset'],
      windSpeed: json['wind']['speed'].toDouble(),
      windDirection: json['wind']['deg'].toDouble(),
      feelsLike: json['main']['feels_like'],
      pressure: json['main']['pressure'],
    );
  }
}
