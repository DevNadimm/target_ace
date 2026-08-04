import 'package:target_ace/features/profile/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.name,
    required super.email,
    required super.phone,
    required super.gender,
    required super.dob,
    required super.institution,
    required super.district,
    required super.avatarUrl,
    required super.subscriptionPlanName,
    required super.subscriptionStatus,
    required super.subscriptionExpiry,
    required super.activeGroupTitle,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
      institution: json['institution']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ?? '',
      subscriptionPlanName: json['subscription_plan_name']?.toString() ?? '',
      subscriptionStatus: json['subscription_status']?.toString() ?? '',
      subscriptionExpiry: json['subscription_expiry']?.toString() ?? '',
      activeGroupTitle: json['active_group_title']?.toString() ?? 'Not Selected',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'dob': dob,
      'institution': institution,
      'district': district,
      'avatar_url': avatarUrl,
      'subscription_plan_name': subscriptionPlanName,
      'subscription_status': subscriptionStatus,
      'subscription_expiry': subscriptionExpiry,
      'active_group_title': activeGroupTitle,
    };
  }
}
