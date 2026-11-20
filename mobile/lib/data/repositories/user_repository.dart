import '../../core/constants.dart';
import '../api/api_client.dart';
import '../models/user.dart';

class UserRepository {
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

  Future<void> create({
    required String username,
    required String password,
    required String nama,
    required UserRole role,
  }) async {
    if (!AppConstants.useApi) {
      _mockUsers.add(UserModel(
        id: 'm${_mockUsers.length + 1}',
        username: username,
        nama: nama,
        role: role,
      ));
      return;
    }
    await ApiClient().dio.post('/users', data: {
      'username': username,
      'password': password,
      'nama': nama,
      'role': role.name,
    });
  }

  Future<void> delete(String id) async {
    if (!AppConstants.useApi) {
      _mockUsers.removeWhere((u) => u.id == id);
      return;
    }
    await ApiClient().dio.delete('/users/$id');
  }

  static final List<UserModel> _mockUsers = [
    UserModel(id: 'mock-admin', username: 'admin', nama: 'Administrator', role: UserRole.admin),
    UserModel(id: 'mock-user', username: 'user1', nama: 'User Satu', role: UserRole.user),
  ];
}