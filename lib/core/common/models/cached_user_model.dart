import 'package:supabase_flutter/supabase_flutter.dart' show User;
import 'package:target_ace/core/common/entities/cached_user_entity.dart';
import 'package:target_ace/core/utils/helpers/subscription_status_helper.dart';

/// Data layer model for [CachedUserEntity].
///
/// Provides serialization (toJson/fromJson) for SharedPreferences storage
/// and a factory to map directly from the RPC payload.
class CachedUserModel extends CachedUserEntity {
  const CachedUserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.gender,
    super.dob,
    super.avatarUrl,
    super.institution,
    super.district,
    super.goal,
    super.howDidYouHear,
    super.dailyGoal,
    super.learningModes,
    super.groupId,
    super.groupTitle,
    super.groupLockedUntil,
    super.subscriptionStatus,
    super.subscriptionPlanName,
    super.subscriptionExpiryDate,
  });

  /// Deserialize from SharedPreferences JSON blob.
  factory CachedUserModel.fromJson(Map<String, dynamic> json) {
    return CachedUserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      dob: json['dob'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      institution: json['institution'] as String? ?? '',
      district: json['district'] as String? ?? '',
      goal: json['goal'] as String? ?? '',
      howDidYouHear: json['how_did_you_hear'] as String? ?? '',
      dailyGoal: json['daily_goal'] as String? ?? '',
      learningModes: (json['learning_modes'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      groupId: json['group_id'] as String? ?? '',
      groupTitle: json['group_title'] as String? ?? '',
      groupLockedUntil: json['group_locked_until'] as String? ?? '',
      subscriptionStatus: json['subscription_status'] as String? ?? 'none',
      subscriptionPlanName: json['subscription_plan_name'] as String? ?? '',
      subscriptionExpiryDate: json['subscription_expiry_date'] as String? ?? '',
    );
  }

  /// Serialize to JSON for SharedPreferences storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'dob': dob,
      'avatar_url': avatarUrl,
      'institution': institution,
      'district': district,
      'goal': goal,
      'how_did_you_hear': howDidYouHear,
      'daily_goal': dailyGoal,
      'learning_modes': learningModes,
      'group_id': groupId,
      'group_title': groupTitle,
      'group_locked_until': groupLockedUntil,
      'subscription_status': subscriptionStatus,
      'subscription_plan_name': subscriptionPlanName,
      'subscription_expiry_date': subscriptionExpiryDate,
    };
  }

  /// Map directly from the `get_user_profile_with_subscription` RPC response.
  ///
  /// [profile] is the 'profile' key from the RPC response (includes active_group_title, locked_until).
  /// [subscription] is the 'subscription' key (nullable).
  /// [supabaseUser] is the Supabase auth user for fallback metadata.
  factory CachedUserModel.fromRpcPayload({
    required Map<String, dynamic> profile,
    Map<String, dynamic>? subscription,
    required User supabaseUser,
  }) {
    final metadata = supabaseUser.userMetadata ?? {};

    final name = profile['name'] as String? ??
        metadata['name'] as String? ??
        'Student';
    final email = supabaseUser.email ?? '';
    final avatarUrl = profile['avatar_url'] as String? ?? '';

    final phone = profile['phone'] as String? ??
        supabaseUser.phone ??
        metadata['phone'] as String? ??
        '';
    final gender = profile['gender'] as String? ??
        metadata['gender'] as String? ??
        '';
    final dob = profile['dob'] as String? ??
        metadata['dob'] as String? ??
        metadata['birthday'] as String? ??
        metadata['birthdate'] as String? ??
        '';

    final goal = profile['goal'] as String? ?? '';
    final groupId = profile['group_id'] as String? ?? '';
    final institution = profile['institution'] as String? ?? '';
    final district = profile['district'] as String? ?? '';

    final howDidYouHear = profile['how_did_you_hear'] as String? ??
        metadata['how_did_you_hear'] as String? ??
        '';
    final dailyGoal = profile['daily_goal'] as String? ??
        metadata['daily_goal'] as String? ??
        '';
    final rawLearningModes = profile['learning_modes'] ?? metadata['learning_modes'];
    final List<String> learningModes = rawLearningModes is List
        ? rawLearningModes.map((e) => e.toString()).toList()
        : const [];

    // Group membership from RPC JOIN
    final activeGroupTitle = profile['active_group_title'] as String? ?? '';
    final lockedUntil = profile['locked_until'] as String? ?? '';

    // Subscription status
    final isPremium = profile['is_premium'] as bool? ?? false;
    final expiryStr = profile['premium_expires_at'] as String?;

    final latestSubStatus = subscription?['status'] as String?;
    final latestSubPlanId = subscription?['plan_id'] as String?;
    final latestSubPlanName = subscription?['plan_name'] as String?;

    final subStatus = SubscriptionStatusHelper.parse(
      isPremium: isPremium,
      expiryStr: expiryStr,
      latestSubStatus: latestSubStatus,
      latestSubPlanId: latestSubPlanId,
      latestSubPlanName: latestSubPlanName,
    );

    final planName = (subscription != null && subscription['plan_name'] != null)
        ? subscription['plan_name'] as String
        : 'Free Member';

    return CachedUserModel(
      id: supabaseUser.id,
      name: name,
      email: email,
      phone: phone,
      gender: gender,
      dob: dob,
      avatarUrl: avatarUrl,
      institution: institution,
      district: district,
      goal: goal,
      howDidYouHear: howDidYouHear,
      dailyGoal: dailyGoal,
      learningModes: learningModes,
      groupId: groupId,
      groupTitle: activeGroupTitle,
      groupLockedUntil: lockedUntil,
      subscriptionStatus: subStatus,
      subscriptionPlanName: planName,
      subscriptionExpiryDate: expiryStr ?? '',
    );
  }
}