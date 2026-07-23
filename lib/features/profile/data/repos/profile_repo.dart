import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepo {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Fetch onboarding goals sorted by creation time.
  static Future<List<Map<String, dynamic>>> getOnboardingGoals() async {
    final response = await _client
        .from('onboarding_goals')
        .select()
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch battle groups for a specific goal.
  static Future<List<Map<String, dynamic>>> getBattleGroups(String goalId) async {
    final response = await _client
        .from('battle_groups')
        .select()
        .eq('goal_id', goalId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Switch battle group transactionally and return new locked_until timestamp.
  static Future<String> switchGroup({
    required String userId,
    required String goalId,
    required String groupId,
  }) async {
    // 1. Update profiles table
    await _client.from('profiles').update({
      'goal': goalId,
      'group_id': groupId,
    }).eq('id', userId);

    // 2. Deactivate previous active memberships
    try {
      await _client
          .from('group_memberships')
          .update({'is_active': false})
          .eq('user_id', userId)
          .eq('is_active', true);
    } catch (_) {}

    // 3. Insert new membership
    final membershipResp = await _client
        .from('group_memberships')
        .insert({
          'user_id': userId,
          'group_id': groupId,
          'is_active': true,
        })
        .select()
        .single();

    return membershipResp['locked_until'] as String;
  }

  /// Stores/upserts the FCM device token to public.user_device_tokens.
  static Future<void> storeFcmToken({
    required String userId,
    required String token,
  }) async {
    await _client.from('user_device_tokens').upsert({
      'user_id': userId,
      'device_token': token,
      'last_seen_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id,device_token');
  }
}
