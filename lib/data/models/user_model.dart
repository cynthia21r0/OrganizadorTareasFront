enum UserRole { admin, member }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final UserRole role;
  final String avatarInitial; // usamos inicial del nombre como "avatar"

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.role,
    String? avatarInitial,
  }) : avatarInitial = avatarInitial ?? (name.isNotEmpty ? name[0].toUpperCase() : '?');

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      role: (map['role'] as String) == 'admin' ? UserRole.admin : UserRole.member,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'role': role == UserRole.admin ? 'admin' : 'member',
    };
  }
}
