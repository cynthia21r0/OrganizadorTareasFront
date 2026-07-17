enum FamilyRole { padre, madre, hijo, hija, abuelo, abuela, tio, tia, otro }

extension FamilyRoleX on FamilyRole {
  String get label {
    switch (this) {
      case FamilyRole.padre:
        return 'Padre';
      case FamilyRole.madre:
        return 'Madre';
      case FamilyRole.hijo:
        return 'Hijo';
      case FamilyRole.hija:
        return 'Hija';
      case FamilyRole.abuelo:
        return 'Abuelo';
      case FamilyRole.abuela:
        return 'Abuela';
      case FamilyRole.tio:
        return 'Tío';
      case FamilyRole.tia:
        return 'Tía';
      case FamilyRole.otro:
        return 'Otro';
    }
  }

  bool get isGuardian => this == FamilyRole.padre || this == FamilyRole.madre;
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final FamilyRole role;
  final String familyId;
  final String avatarInitial;
  final String? profilePicture;
  final String? familyName;
  final String? familyInviteCode;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.familyId,
    this.familyName,
    this.profilePicture,
    this.familyInviteCode,
  }) : avatarInitial = name.isNotEmpty ? name[0].toUpperCase() : '?';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: FamilyRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => FamilyRole.otro,
      ),
      familyId: json['familyId'] as String,
      profilePicture: json['profilePicture'] as String?,
      familyName: json['familyName'] as String?,
      familyInviteCode: json['familyInviteCode'] as String?,
    );
  }
}
