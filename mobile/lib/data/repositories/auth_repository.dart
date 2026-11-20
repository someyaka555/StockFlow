import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../api/api_client.dart';
import '../models/user.dart';

class AuthRepository {
  Future<UserModel?> login(String username, String password) async {
    if (!AppConstants.useApi) {
      // Mock lokal
      if (username == 'admin' && password == 'admin123') {
        return UserModel(
          id: 'mock-admin',
          username: 'admin',
          nama: 'Administrator',
          role: UserRole.admin,
        );
      }
      if (username == 'user1' && password == 'user123') {
        return UserModel(
          id: 'mock-user',
          username: 'user1',
          nama: 'User Satu',
          role: UserRole.user,
        );
      }
      return null;
    }
    final res = await ApiClient().dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
    final token = res.data['token'] as String;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    return UserModel.fromJson(res.data['user']);
  }

  Future<UserModel?> getCurrentUser() async {
    if (!AppConstants.useApi) {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('mock_user_id');
      if (id == 'mock-admin') {
        return UserModel(
          id: 'mock-admin',
          username: 'admin',
          nama: 'Administrator',
          role: UserRole.admin,
        );
      }
      if (id == 'mock-user') {
        return UserModel(
          id: 'mock-user',
          username: 'user1',
          nama: 'User Satu',
          role: UserRole.user,
        );
      }
      return null;
    }
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return null;
    try {
      final res = await ApiClient().dio.get('/auth/me');
      return UserModel.fromJson(res.data);
    } catch (_) {
      await prefs.remove('auth_token');
      return null;
    }
  }

  Future<void> saveMockSession(UserModel u) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mock_user_id', u.id ?? '');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('mock_user_id');
  }
}