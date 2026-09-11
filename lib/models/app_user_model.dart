enum UserRole { admin, employee }

class AppUserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final bool canSeeWholesalePrice;
  final bool isActive;

  AppUserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.canSeeWholesalePrice,
    required this.isActive,
  });

  factory AppUserModel.fromMap(String uid, Map<String, dynamic> map) {
    return AppUserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: (map['role'] == 'admin') ? UserRole.admin : UserRole.employee,
      canSeeWholesalePrice: map['canSeeWholesalePrice'] ?? false,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role == UserRole.admin ? 'admin' : 'employee',
      'canSeeWholesalePrice': canSeeWholesalePrice,
      'isActive': isActive,
    };
  }

  bool get isAdmin => role == UserRole.admin;
}
