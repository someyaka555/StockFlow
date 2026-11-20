import 'package:flutter/material.dart';
import '../data/models/user.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final _repo = AuthRepository();
  UserModel? _user;
  bool _loading = true;
  bool _adminMode = false;

  UserModel? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == UserRole.admin;
  bool get adminMode => _adminMode;

  Future<void> init() async {
    _user = await _repo.getCurrentUser();
    _adminMode = _user?.role == UserRole.admin;
    _loading = false;
    notifyListeners();
  }

  Future<String?> login(String username, String password) async {
    try {
      final u = await _repo.login(username, password);
      if (u == null) return 'Username atau password salah';
      _user = u;
      _adminMode = u.role == UserRole.admin;
      await _repo.saveMockSession(u);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    _adminMode = false;
    notifyListeners();
  }

  void toggleMode() {
    if (!isAdmin) return;
    _adminMode = !_adminMode;
    notifyListeners();
  }
}