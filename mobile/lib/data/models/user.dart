enum UserRole { admin, user }

class UserModel {
  final String? id;
  final String username;
  final String email;
  final UserRole role;
  final bool active;
  final bool isVerified;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.role,
    this.active = true,
    this.isVerified = false,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'role': role.name,
        'active': active,
        'isVerified': isVerified,
      };

  factory UserModel.fromJson(Map<String, dynamic> m) => UserModel(
        id: (m['_id'] ?? m['id'])?.toString(),
        username: m['username'] ?? '',
        email: m['email'] ?? '',
        role: UserRole.values.firstWhere(
          (e) => e.name == m['role'],
          orElse: () => UserRole.user,
        ),
        active: m['active'] ?? true,
        isVerified: m['isVerified'] ?? false,
      );
}