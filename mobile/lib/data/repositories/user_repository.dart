import '../../core/constants.dart';
import '../api/api_client.dart';
import '../models/user.dart';

class UserRepository {
  static final List<UserModel> _mockUsers = [
    UserModel(id: 'local-admin', username: 'AdminLocal', email: AppConstants.localAdminEmail, role: UserRole.admin, isVerified: true),
    UserModel(id: 'local-user', username: 'UserLocal', email: AppConstants.localUserEmail, role: UserRole.user, isVerified: true),
  ];

  Future<List<UserModel>> getAll() async {
    if (AppConstants.authMode == 'local') return List.from(_mockUsers);
    final res = await ApiClient().dio.get('/users');
    return (res.data as List).map((e) => UserModel.fromJson(e)).toList();
  }

  Future<void> create(UserModel u) async {
    if (AppConstants.authMode == 'local') {
      _mockUsers.add(UserModel(
        id: 'm${_mockUsers.length + 1}', username: u.username, email: u.email, role: u.role, isVerified: u.isVerified,
      ));
      return;
    }
    await ApiClient().dio.post('/users', data: u.toJson());
  }

  Future<void> update(UserModel u) async {
    if (AppConstants.authMode == 'local') {
      final i = _mockUsers.indexWhere((e) => e.id == u.id);
      if (i >= 0) _mockUsers[i] = u;
      return;
    }
    await ApiClient().dio.put('/users/${u.id}', data: u.toJson());
  }

  Future<void> delete(String id) async {
    if (AppConstants.authMode == 'local') {
      _mockUsers.removeWhere((e) => e.id == id);
      return;
    }
    await ApiClient().dio.delete('/users/$id');
  }
}