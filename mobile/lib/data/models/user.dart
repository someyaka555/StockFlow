enum UserRole { admin, user }

class UserModel {
  final String? id;
  final String username;
  final String nama;
  final UserRole role;
  final bool active;

  UserModel({
    this.id,
    required this.username,
    required this.nama,
    required this.role,
    this.active = true,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'nama': nama,
        'role': role.name,
        'active': active,
      };

  factory UserModel.fromJson(Map<String, dynamic> m) => UserModel(
        id: (m['_id'] ?? m['id'])?.toString(),
        username: m['username'] ?? '',
        nama: m['nama'] ?? '',
        role: UserRole.values.firstWhere(
          (e) => e.name == m['role'],
          orElse: () => UserRole.user,
        ),
        active: m['active'] ?? true,
      );
}