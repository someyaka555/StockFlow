import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../api/api_client.dart';
import '../models/user.dart';

class AuthRepository {
  bool _isLocalAccount(String email) {
    return email == AppConstants.localAdminEmail || email == AppConstants.localUserEmail;
  }

  Future<String> _getLocalPassword(String email) async {
    final prefs = await SharedPreferences.getInstance();
    if (email == AppConstants.localAdminEmail) {
      return prefs.getString('local_admin_password') ?? AppConstants.localAdminPassword;
    } else {
      return prefs.getString('local_user_password') ?? AppConstants.localUserPassword;
    }
  }

  Future<UserModel?> login(String email, String password) async {
    if (_isLocalAccount(email)) {
      final expectedPassword = await _getLocalPassword(email);
      if (password != expectedPassword) return null;

      if (email == AppConstants.localAdminEmail) {
        return UserModel(id: 'local-admin', username: 'AdminLocal', email: email, role: UserRole.admin, isVerified: true);
      } else {
        return UserModel(id: 'local-user', username: 'UserLocal', email: email, role: UserRole.user, isVerified: true);
      }
    } else {
      final res = await ApiClient().dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final token = res.data['token'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      return UserModel.fromJson(res.data['user']);
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('mock_user_id');
    final token = prefs.getString('auth_token');

    if (id == 'local-admin') return UserModel(id: 'local-admin', username: 'AdminLocal', email: AppConstants.localAdminEmail, role: UserRole.admin, isVerified: true);
    if (id == 'local-user') return UserModel(id: 'local-user', username: 'UserLocal', email: AppConstants.localUserEmail, role: UserRole.user, isVerified: true);

    if (token != null) {
      try {
        final res = await ApiClient().dio.get('/auth/me');
        return UserModel.fromJson(res.data);
      } catch (_) {
        await prefs.remove('auth_token');
      }
    }
    return null;
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

  Future<void> updateLocalPassword(String email, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    if (email == AppConstants.localAdminEmail) {
      await prefs.setString('local_admin_password', newPassword);
    } else if (email == AppConstants.localUserEmail) {
      await prefs.setString('local_user_password', newPassword);
    }
  }
}