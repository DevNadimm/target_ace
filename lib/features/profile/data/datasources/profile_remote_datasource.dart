import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/error/server_exception.dart';

abstract interface class ProfileRemoteDataSource {
  Future<List<Map<String, dynamic>>> getOnboardingGoals();
  Future<List<Map<String, dynamic>>> getBattleGroups(String goalId);
  Future<void> updateAuthUserMetadata(Map<String, dynamic> metadata);
  Future<Map<String, dynamic>?> fetchLatestApprovedSubscription(String userId);
  Future<Map<String, dynamic>?> fetchProfileSingle(String userId);
  Future<Map<String, dynamic>?> fetchProfileWithSubscription(String userId);
  Future<void> upsertProfile(Map<String, dynamic> profileData);
  Future<void> deactivateActiveMemberships(String userId);
  Future<Map<String, dynamic>> insertGroupMembership(Map<String, dynamic> membershipData);
  Future<Map<String, dynamic>> completeProfileSetup(Map<String, dynamic> params);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient _client;
  const ProfileRemoteDataSourceImpl(this._client);

  @override
  Future<List<Map<String, dynamic>>> getOnboardingGoals() async {
    try {
      final response = await _client
          .from('onboarding_goals')
          .select('*, battle_groups(*)')
          .order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBattleGroups(String goalId) async {
    try {
      final response = await _client
          .from('battle_groups')
          .select()
          .eq('goal_id', goalId)
          .order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateAuthUserMetadata(Map<String, dynamic> metadata) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(data: metadata),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchLatestApprovedSubscription(String userId) async {
    try {
      final res = await _client
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .eq('status', 'approved')
          .order('created_at', ascending: false)
          .limit(1);
      final list = List<Map<String, dynamic>>.from(res);
      if (list.isEmpty) return null;
      return list.first;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchProfileSingle(String userId) async {
    try {
      return await _client.from('profiles').select().eq('id', userId).maybeSingle();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchProfileWithSubscription(String userId) async {
    try {
      final response = await _client.rpc(
        'get_user_profile_with_subscription',
        params: {'p_user_id': userId},
      );
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> upsertProfile(Map<String, dynamic> profileData) async {
    try {
      await _client.from('profiles').upsert(profileData);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deactivateActiveMemberships(String userId) async {
    try {
      await _client
          .from('group_memberships')
          .update({'is_active': false})
          .eq('user_id', userId)
          .eq('is_active', true);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> insertGroupMembership(Map<String, dynamic> membershipData) async {
    try {
      return await _client
          .from('group_memberships')
          .insert(membershipData)
          .select()
          .single();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> completeProfileSetup(Map<String, dynamic> params) async {
    try {
      final response = await _client.rpc(
        'complete_profile_setup',
        params: params,
      );
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
