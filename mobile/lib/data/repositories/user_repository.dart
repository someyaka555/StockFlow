import '../../core/constants.dart';
import '../api/api_client.dart';
import '../models/user.dart';

class UserRepository {
  static final List<UserModel> _mockUsers = [
    UserModel(id: 'mock-admin', username: 'Administrator', email: 'admin@stockflow.com', role: UserRole.admin, isVerified: true),
    UserModel(id: 'mock-admin2', username: 'Admin Tester', email: 'admin2@stockflow.com', role: UserRole.admin, isVerified: true),
    UserModel(id: 'mock-user', username: 'User Satu', email: 'user1@stockflow.com', role: UserRole.user, isVerified: true),
  ];

  Future<List<UserModel>> getAll() async {
    if (!AppConstants.useApi) return _mockUsers;
    final res = await ApiClient().dio.get('/users');
    return (res.data as List).map((e) => UserModel.fromJson(e)).toList();
  }

  Future<int> count() async {
    if (!AppConstants.useApi) return _mockUsers.length;
    final res = await ApiClient().dio.get('/users/count');
    return res.data['total'] as int;
  }

  Future<void> create(UserModel u) async {
    if (!AppConstants.useApi) {
      _mockUsers.add(UserModel(
        id: 'm${_mockUsers.length + 1}',
        username: u.username,
        email: u.email,
        role: u.role,
        isVerified: u.isVerified,
      ));
      return;
    }
    await ApiClient().dio.post('/users', data: u.toJson());
  }

  Future<void> update(UserModel u) async {
    if (!AppConstants.useApi) {
      final i = _mockUsers.indexWhere((e) => e.id == u.id);
      if (i >= 0) _mockUsers[i] = u;
      return;
    }
    await ApiClient().dio.put('/users/${u.id}', data: u.toJson());
  }

  Future<void> delete(String id) async {
    if (!AppConstants.useApi) {
      _mockUsers.removeWhere((e) => e.id == id);
      return;
    }
    await ApiClient().dio.delete('/users/$id');
  }
}