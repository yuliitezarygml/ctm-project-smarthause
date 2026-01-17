import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/smart_home_data.dart';

class ApiProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  SmartHomeData? _smartHomeData;
  Timer? _refreshTimer;
  final List<String> _logs = [];

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  SmartHomeData? get smartHomeData => _smartHomeData;
  List<String> get logs => List.unmodifiable(_logs);

  ApiProvider() {
    _init();
    startAutoRefresh();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('api_base_url');
    // Force update the URL if it matches the old known broken one
    if (savedUrl != null && savedUrl.contains('192.168.100.229')) {
       ApiEndpoints.baseUrl = 'http://192.168.50.9:8080';
       await prefs.setString('api_base_url', ApiEndpoints.baseUrl);
       log('Forced update of API URL from old broken one to: ${ApiEndpoints.baseUrl}');
    } else if (savedUrl != null && savedUrl.isNotEmpty) {
      ApiEndpoints.baseUrl = savedUrl;
      log('Loaded saved API URL: $savedUrl');
    } else {
      // If no saved URL, use the default from constants (which is now updated)
      ApiEndpoints.baseUrl = 'http://192.168.50.9:8080';
      log('Using default API URL: ${ApiEndpoints.baseUrl}');
    }
    notifyListeners();
  }

  Future<void> setBaseUrl(String url) async {
    if (url.isEmpty) return;
    
    // Remove trailing slash if present
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    ApiEndpoints.baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', url);
    
    log('API URL updated to: $url');
    notifyListeners();
    
    // Refresh data with new URL
    fetchSmartHomeData();
  }

  void log(String message) {
    final timestamp = DateTime.now().toString().split('.')[0];
    final logMessage = '[$timestamp] $message';
    _logs.add(logMessage);
    // Keep only last 100 logs to prevent memory issues
    if (_logs.length > 100) {
      _logs.removeAt(0);
    }
    print(logMessage); // Also print to console
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  Future<void> startAutoRefresh() async {
    _refreshTimer = Timer.periodic(
      Duration(milliseconds: AppConstants.refreshInterval),
      (timer) async {
        await fetchSmartHomeData();
      },
    );
  }

  Future<void> stopAutoRefresh() async {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<bool> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> fetchSmartHomeData() async {
    final isConnected = await checkConnectivity();
    if (!isConnected) {
      _hasError = true;
      _errorMessage = 'No internet connection';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      log('Fetching status from: ${ApiEndpoints.status}');
      // Fetch status data
      final statusResponse = await http.get(
        Uri.parse(ApiEndpoints.status),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(milliseconds: AppConstants.connectionTimeout));

      log('Status response code: ${statusResponse.statusCode}');

      if (statusResponse.statusCode == 200) {
        final statusData = json.decode(statusResponse.body);

        // Use local data for solar panel instead of fetching from backend
        // TODO: Remove this mock when backend is ready
        final solarData = {
          'power': '250 W',
          'voltage': '12.5 V',
          'current': '2.0 A',
          'efficiency': '85%',
          'temperature': '25°C',
          'status': 'stable',
          'condition': 'Sunny'
        };

        _smartHomeData = SmartHomeData.fromJson({
          ...statusData,
          'solar_panel': solarData,
        });

        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load data: ${statusResponse.statusCode}');
      }
    } catch (error) {
      log('Error fetching data: $error');
      _isLoading = false;
      _hasError = true;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> toggleLamp(int lampId) async {
    try {
      final url = '${ApiEndpoints.baseUrl}/api/lamp/${lampId}/toggle';
      log('Toggling lamp $lampId at $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to toggle lamp: ${response.statusCode}');
      }

      log('Lamp $lampId toggled successfully');

      // Update local data immediately for better UX
      if (_smartHomeData != null) {
        _smartHomeData!.lamps[lampId] = !_smartHomeData!.lamps[lampId];
        notifyListeners();
      }
    } catch (error) {
      log('Error toggling lamp: $error');
      rethrow;
    }
  }

  Future<void> toggleAllLamps(bool state) async {
    try {
      log('Toggling all lamps to $state');
      final response = await http.post(
        Uri.parse(ApiEndpoints.toggleAllLamps),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'state': state}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to toggle all lamps: ${response.statusCode}');
      }

      log('All lamps toggled successfully');

      // Update local data immediately
      if (_smartHomeData != null) {
        for (int i = 0; i < _smartHomeData!.lamps.length; i++) {
          _smartHomeData!.lamps[i] = state;
        }
        notifyListeners();
      }
    } catch (error) {
      log('Error toggling all lamps: $error');
      rethrow;
    }
  }

  Future<void> toggleRelay() async {
    try {
      log('Toggling relay');
      final response = await http.post(
        Uri.parse(ApiEndpoints.toggleRelay),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to toggle relay: ${response.statusCode}');
      }

      log('Relay toggled successfully');

      // Update local data - create new instance since SmartHomeData is immutable
      if (_smartHomeData != null) {
        _smartHomeData = SmartHomeData(
          weather: _smartHomeData!.weather,
          clock: _smartHomeData!.clock,
          data: _smartHomeData!.data,
          lamps: List.from(_smartHomeData!.lamps),
          lampsAuto: List.from(_smartHomeData!.lampsAuto),
          relay: !_smartHomeData!.relay,
          lock: _smartHomeData!.lock,
          learning: _smartHomeData!.learning,
          lastAccess: _smartHomeData!.lastAccess,
          cards: List.from(_smartHomeData!.cards),
          history: List.from(_smartHomeData!.history),
          weatherForecast: _smartHomeData!.weatherForecast,
          solarPanel: _smartHomeData!.solarPanel,
        );
        // Important: Update the nested 'data' map as well, since that's where UI might be reading from
        if (_smartHomeData!.data.containsKey('relay')) {
            _smartHomeData!.data['relay'] = _smartHomeData!.relay;
        }
        notifyListeners();
      }
    } catch (error) {
      log('Error toggling relay: $error');
      rethrow;
    }
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
