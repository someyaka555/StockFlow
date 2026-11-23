import '../api/api_client.dart';
import '../models/user.dart';

class UserRepository {
  bool _isLocal(String email) => email == 'admin@stockflow.com' || email == 'user@stockflow.com';

  static final List<UserModel> _mockUsers = [
    UserModel(id: 'local-admin', username: 'AdminLocal', email: 'admin@stockflow.com', role: UserRole.admin, isVerified: true),
    UserModel(id: 'local-user', username: 'UserLocal', email: 'user@stockflow.com', role: UserRole.user, isVerified: true),
  ];

  Future<List<UserModel>> getAll() async {
    return _mockUsers;
  }

  Future<void> create(UserModel u) async {
    if (_isLocal(u.email)) {
      _mockUsers.add(UserModel(
        id: 'm${_mockUsers.length + 1}', username: u.username, email: u.email, role: u.role, isVerified: u.isVerified,
      ));
      return;
    }
    await ApiClient().dio.post('/users', data: u.toJson());
  }

  Future<void> update(UserModel u) async {
    if (_isLocal(u.email ?? '')) {
      final i = _mockUsers.indexWhere((e) => e.id == u.id);
      if (i >= 0) _mockUsers[i] = u;
      return;
    }
    await ApiClient().dio.put('/users/${u.id}', data: u.toJson());
  }

  Future<void> delete(String id) async {
    if (id.startsWith('local-') || id.startsWith('m')) {
      _mockUsers.removeWhere((e) => e.id == id);
      return;
    }
    await ApiClient().dio.delete('/users/$id');
  }
}