import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/features/subscription/data/models/subscription_model.dart';

class SubscriptionRepo {
  /// Fetches the current user's subscription status from Supabase.
  static Future<SubscriptionModel?> fetchMySubscription() async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return SubscriptionModel(status: 'none');

      // Fetch profile premium flag
      final profile = await client
          .from('profiles')
          .select('is_premium')
          .eq('id', userId)
          .single();
      
      final isPremium = profile['is_premium'] as bool? ?? false;

      if (isPremium) {
        // Try to fetch latest approved subscription details
        final List<dynamic> subs = await client
            .from('subscriptions')
            .select()
            .eq('user_id', userId)
            .eq('status', 'approved')
            .order('created_at', ascending: false)
            .limit(1);

        if (subs.isNotEmpty) {
          final subData = subs.first;
          return SubscriptionModel(
            status: 'active',
            planId: subData['plan_id']?.toString(),
            planName: subData['plan_name']?.toString(),
            startDate: subData['start_date']?.toString(),
            endDate: subData['end_date']?.toString(),
          );
        }

        return SubscriptionModel(
          status: 'active',
          planId: 'pro',
          planName: 'Pro Plan',
          startDate: DateTime.now().toIso8601String(),
          endDate: DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        );
      } else {
        // Check for any pending verification subscription request
        final List<dynamic> subs = await client
            .from('subscriptions')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false)
            .limit(1);

        if (subs.isNotEmpty && subs.first['status'] == 'pending') {
          return SubscriptionModel(
            status: 'pending_verification',
            planId: subs.first['plan_id']?.toString(),
            planName: subs.first['plan_name']?.toString(),
          );
        }
      }

      return SubscriptionModel(status: 'none');
    } catch (e) {
      return SubscriptionModel(status: 'none');
    }
  }
}


