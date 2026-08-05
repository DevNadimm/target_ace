import 'package:target_ace/core/common/entities/user.dart';

class UserModel extends User {
  final bool isAdmin;

  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.avatarUrl,
    required this.isAdmin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      isAdmin: json['is_admin'] == '1' || json['is_admin'] == 1 || json['is_admin'] == true,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'is_admin': isAdmin,
      'avatar_url': avatarUrl,
    };
  }
}