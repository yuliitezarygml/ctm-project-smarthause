class SmartHomeData {
  final String weather;
  final String clock;
  final Map<String, dynamic> data;
  final List<bool> lamps;
  final List<bool> lampsAuto;
  final bool relay;
  final bool lock;
  final bool learning;
  final String lastAccess;
  final List<dynamic> cards;
  final List<dynamic> history;
  final Map<String, dynamic> weatherForecast;
  final Map<String, dynamic>? solarPanel;

  SmartHomeData({
    required this.weather,
    required this.clock,
    required this.data,
    required this.lamps,
    required this.lampsAuto,
    required this.relay,
    required this.lock,
    required this.learning,
    required this.lastAccess,
    required this.cards,
    required this.history,
    required this.weatherForecast,
    this.solarPanel,
  });

  factory SmartHomeData.fromJson(Map<String, dynamic> json) {
    // Check relay status in multiple places as backend structure might vary
    bool relayStatus = false;
    if (json['data'] != null && json['data']['relay'] != null) {
      relayStatus = json['data']['relay'];
    } else if (json['relay'] != null) {
      relayStatus = json['relay'];
    }

    return SmartHomeData(
      weather: json['weather'] ?? '',
      clock: json['clock'] ?? '',
      data: json['data'] ?? {},
      lamps: List<bool>.from(json['lamps'] ?? []),
      lampsAuto: List<bool>.from(json['lamps_auto'] ?? []),
      relay: relayStatus,
      lock: json['lock'] ?? false,
      learning: json['learning'] ?? false,
      lastAccess: json['last_access'] ?? '',
      cards: json['cards'] ?? [],
      history: json['history'] ?? [],
      weatherForecast: json['weather_forecast'] ?? {},
      solarPanel: json['solar_panel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weather': weather,
      'clock': clock,
      'data': data,
      'lamps': lamps,
      'lamps_auto': lampsAuto,
      'relay': relay,
      'lock': lock,
      'learning': learning,
      'last_access': lastAccess,
      'cards': cards,
      'history': history,
      'weather_forecast': weatherForecast,
      'solar_panel': solarPanel,
    };
  }

  // Helper methods
  double get temperature => data['temp']?.toDouble() ?? 0.0;
  double get humidity => data['hum']?.toDouble() ?? 0.0;
  double get soilMoisture => data['soil']?.toDouble() ?? 0.0;
  double get lightLevel {
    double baseLight = data['light']?.toDouble() ?? 0.0;
    
    // Эмуляция уровня света на основе включенных ламп (как на сайте)
    // Formula: Base + (ActiveLamps / TotalLamps) * 50
    int activeLamps = lamps.where((l) => l).length;
    double additionalLight = (activeLamps / 6.0) * 50.0;
    
    return baseLight + additionalLight;
  }

  String get solarPower => solarPanel?['power'] ?? '0 W';
  String get solarVoltage => solarPanel?['voltage'] ?? '0 V';
  String get solarCurrent => solarPanel?['current'] ?? '0 A';
  String get solarEfficiency => solarPanel?['efficiency'] ?? '0%';
  String get solarTemperature => solarPanel?['temperature'] ?? '0°C';
  String get solarStatus => solarPanel?['status'] ?? 'offline';
  String get solarCondition => solarPanel?['condition'] ?? 'Unknown';
}
