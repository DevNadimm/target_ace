import 'package:target_ace/core/network/base_remote_datasource.dart';
import 'package:target_ace/features/subscription/data/models/subscription_model.dart';

abstract interface class SubscriptionRemoteDataSource {
  Future<bool> fetchIsPremium(String userId);
  Future<SubscriptionModel?> fetchLatestApprovedSubscription(String userId);
  Future<SubscriptionModel?> fetchLatestSubscription(String userId);
  Future<bool> checkTrialEligibility(String userId);
  Future<void> activateFreeTrial({required String userId, required String userEmail});
}

class SubscriptionRemoteDataSourceImpl extends BaseRemoteDataSource implements SubscriptionRemoteDataSource {
  const SubscriptionRemoteDataSourceImpl(super.client);

  @override
  Future<bool> fetchIsPremium(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select('is_premium')
          .eq('id', userId)
          .single();
      return response['is_premium'] as bool? ?? false;
    } catch (e) {
      handleException(e);
    }
  }

  @override
  Future<SubscriptionModel?> fetchLatestApprovedSubscription(String userId) async {
    try {
      final response = await client
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .eq('status', 'approved')
          .order('created_at', ascending: false)
          .limit(1);
      
      final list = List<Map<String, dynamic>>.from(response);
      if (list.isEmpty) return null;
      return SubscriptionModel.fromJson(list.first);
    } catch (e) {
      handleException(e);
    }
  }

  @override
  Future<SubscriptionModel?> fetchLatestSubscription(String userId) async {
    try {
      final response = await client
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1);
      
      final list = List<Map<String, dynamic>>.from(response);
      if (list.isEmpty) return null;
      return SubscriptionModel.fromJson(list.first);
    } catch (e) {
      handleException(e);
    }
  }

  @override
  Future<bool> checkTrialEligibility(String userId) async {
    try {
      final profile = await client
          .from('profiles')
          .select('is_premium')
          .eq('id', userId)
          .maybeSingle();

      final isPremium = profile?['is_premium'] as bool? ?? false;
      if (isPremium) return false;

      final hasTrial = await client
          .from('subscriptions')
          .select('id')
          .eq('user_id', userId)
          .or('payment_method.eq.FREE,plan_id.eq.free_trial')
          .limit(1)
          .maybeSingle();

      return hasTrial == null;
    } catch (e) {
      handleException(e);
    }
  }

  @override
  Future<void> activateFreeTrial({required String userId, required String userEmail}) async {
    try {
      final userShortId = userId.length >= 8 ? userId.substring(0, 8) : userId;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final transactionId = 'FREE-$userShortId-$timestamp';
      final senderNumber = userEmail.isNotEmpty ? userEmail : 'FREE_TRIAL';

      await client.rpc('submit_purchase', params: {
        'p_user_id': userId,
        'p_plan_id': 'free_trial',
        'p_promo_code': null,
        'p_payment_method': 'FREE',
        'p_sender_number': senderNumber,
        'p_transaction_id': transactionId,
      });
    } catch (e) {
      handleException(e);
    }
  }
}