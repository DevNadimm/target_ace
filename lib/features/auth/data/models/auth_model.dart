import 'package:target_ace/features/subscription/data/models/subscription_model.dart';

class AuthModel {
  final bool success;
  final String message;
  final String token;
  final UserModel user;
  final SubscriptionModel? subscription;

  AuthModel({
    required this.success,
    required this.message,
    required this.token,
    required this.user,
    this.subscription,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      subscription: json['subscription'] != null
          ? SubscriptionModel.fromJson(json['subscription'] as Map<String, dynamic>)
          : null,
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final bool isAdmin;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.isAdmin = false,
    this.avatarUrl,
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
}

