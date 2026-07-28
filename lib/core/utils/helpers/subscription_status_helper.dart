class SubscriptionStatusHelper {
  SubscriptionStatusHelper._();

  /// Resolves the UX subscription status based on profile premium fields and the latest subscription record.
  static String parse({
    required bool isPremium,
    required String? expiryStr,
    required String? latestSubStatus,
    required String? latestSubPlanId,
    required String? latestSubPlanName,
  }) {
    final bool isExpired = expiryStr != null && DateTime.tryParse(expiryStr)?.isBefore(DateTime.now()) == true;

    if (isPremium && !isExpired) {
      final isTrial = latestSubPlanId == 'free_trial' || latestSubPlanName == 'Free Trial';
      return isTrial ? 'trial' : 'active';
    } else {
      if (latestSubStatus == 'pending') {
        return 'pending_verification';
      }
      if (isExpired) {
        return 'expired';
      }
    }
    return 'none';
  }
}
