import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class SettingsProvider extends ChangeNotifier {
  String _baseUrl = AppConstants.apiBaseUrl;

  String get baseUrl => _baseUrl;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('api_base_url') ?? AppConstants.apiBaseUrl;
    AppConstants.apiBaseUrl = _baseUrl;
    notifyListeners();
  }

  Future<void> save(String url) async {
    _baseUrl = url;
    AppConstants.apiBaseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', url);
    notifyListeners();
  }
}