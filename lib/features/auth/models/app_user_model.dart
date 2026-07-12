enum UserRole { admin, moderator, penghuni }

extension UserRoleX on UserRole {
  String get name {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.moderator:
        return 'moderator';
      case UserRole.penghuni:
        return 'penghuni';
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.penghuni,
    );
  }
}

class AppUserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? roomId;
  final String? phone;
  final String? emergencyContact;

  const AppUserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.roomId,
    this.phone,
    this.emergencyContact,
  });

  factory AppUserModel.fromMap(String uid, Map<String, dynamic> map) {
    return AppUserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRoleX.fromString(map['role'] ?? 'penghuni'),
      roomId: map['roomId'],
      phone: map['phone'],
      emergencyContact: map['emergencyContact'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'roomId': roomId,
      'phone': phone,
      'emergencyContact': emergencyContact,
    };
  }
}