import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF4361EE);
  static const Color secondaryColor = Color(0xFF3F37C9);
  static const Color accentColor = Color(0xFF4CC9F0);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF212529);
  static const Color hintColor = Color(0xFF6C757D);
  static const Color borderColor = Color(0xFFDEE2E6);
  static const Color successColor = Color(0xFF28A745);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color dangerColor = Color(0xFFDC3545);
  static const Color infoColor = Color(0xFF17A2B8);

  static const Color solarStable = Color(0xFF28A745);
  static const Color solarUnstable = Color(0xFFFFC107);
  static const Color solarOffline = Color(0xFF6C757D);

  static const Color lampOn = Color(0xFF28A745);
  static const Color lampOff = Color(0xFFDC3545);
  static const Color lampAuto = Color(0xFFFFC107);

  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient solarGradient = LinearGradient(
    colors: [Color(0xFF4CC9F0), Color(0xFF4361EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppStyles {
  static const double borderRadius = 16.0;
  static const double cardElevation = 2.0;
  static const double padding = 16.0;
  static const double margin = 16.0;

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 8,
    spreadRadius: 0,
    offset: Offset(0, 2),
  );

  static const BoxShadow buttonShadow = BoxShadow(
    color: Color(0x26000000),
    blurRadius: 4,
    spreadRadius: 0,
    offset: Offset(0, 2),
  );
}

class ApiEndpoints {
  // Use 10.0.2.2 for Android Emulator to access localhost
  // Use your machine's IP (e.g., 192.168.50.9) for physical devices
  static String baseUrl = 'http://192.168.50.9:8080';
  static String get status => '$baseUrl/api/status';
  static String get solarPanel => '$baseUrl/api/solar-panel';
  static String get toggleLamp => '$baseUrl/api/lamp';
  static String get toggleAllLamps => '$baseUrl/api/lamps/all';
  static String get toggleRelay => '$baseUrl/api/toggle';
  static String get exportData => '$baseUrl/api/export';
}

class AppConstants {
  static const String appName = 'Smart Home';
  static const String appVersion = '1.0.0';
  static const int refreshInterval = 2000; // 2 seconds
  static const int connectionTimeout = 10000; // 10 seconds
}
