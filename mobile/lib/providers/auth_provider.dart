import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../data/models/user.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final _repo = AuthRepository();
  UserModel? _user;
  bool _loading = true;
  bool _adminMode = false;
  bool _needsVerification = false;

  UserModel? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == UserRole.admin;
  bool get adminMode => _adminMode;
  bool get needsVerification => _needsVerification;

  Future<void> init() async {
    _user = await _repo.getCurrentUser();
    _adminMode = _user?.role == UserRole.admin;
    
    if (_user != null) {
      AppConstants.authMode = (_user!.email == AppConstants.localAdminEmail || _user!.email == AppConstants.localUserEmail) ? 'local' : 'server';
    }
    
    _loading = false;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    try {
      AppConstants.authMode = (email == AppConstants.localAdminEmail || email == AppConstants.localUserEmail) ? 'local' : 'server';
      
      final u = await _repo.login(email, password);
      if (u == null) return 'Email tidak terdaftar atau password salah';
      
      if (u.isBlocked) return 'Akun Anda telah diblokir. Hubungi Admin.';
      
      _user = u;
      _adminMode = u.role == UserRole.admin;
      
      if (!u.isVerified) {
        _needsVerification = true;
      } else {
        await _repo.saveMockSession(u);
      }
      
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void verifySuccess() {
    _needsVerification = false;
    if (_user != null) {
      _user = UserModel(
        id: _user!.id, 
        username: _user!.username, 
        email: _user!.email, 
        role: _user!.role, 
        active: _user!.active, 
        isVerified: true,
        isBlocked: _user!.isBlocked,
      );
      _repo.saveMockSession(_user!);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    _adminMode = false;
    _needsVerification = false;
    notifyListeners();
  }

  void toggleMode() {
    if (!isAdmin) return;
    _adminMode = !_adminMode;
    notifyListeners();
  }

  Future<String?> changePassword(String newPassword) async {
    if (_user == null) return 'User tidak ditemukan';
    if (AppConstants.authMode == 'server') {
      return 'Fitur ganti sandi belum tersedia untuk akun server'; // Atau implementasikan API call
    }
    try {
      await _repo.updateLocalPassword(_user!.email, newPassword);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}