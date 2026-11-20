import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class SettingsProvider extends ChangeNotifier {
  String _baseUrl = AppConstants.apiBaseUrl;
  bool _useApi = AppConstants.useApi;

  String get baseUrl => _baseUrl;
  bool get useApi => _useApi;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('api_base_url') ?? AppConstants.apiBaseUrl;
    _useApi = prefs.getBool('use_api') ?? AppConstants.useApi;
    AppConstants.apiBaseUrl = _baseUrl;
    AppConstants.useApi = _useApi;
    notifyListeners();
  }

  Future<void> save(String url, bool useApi) async {
    _baseUrl = url;
    _useApi = useApi;
    AppConstants.apiBaseUrl = url;
    AppConstants.useApi = useApi;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', url);
    await prefs.setBool('use_api', useApi);
    notifyListeners();
  }
}