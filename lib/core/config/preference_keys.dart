class PreferenceKeys {
  PreferenceKeys._();

  static const accessToken = 'access-token';
  static const isRememberMe = 'is-remember-me';
  static const isFirstTime = 'is-first-time';
  static const selectedLanguage = 'selectedLanguage';

  /// User
  static const userId = 'user-id';
  static const userName = 'user-name';
  static const userRole = 'user-role';
  static const userEmail = 'user-email';
  static const userPhone = 'user-phone';
  static const userAddress = 'user-address';
  static const userAvatarUrl = 'user-avatar-url';
  static const userGoal = 'user-goal';
  static const userGroup = 'user-group';
  static const userInstitution = 'user-institution';
  static const userDistrict = 'user-district';
  static const userGender = 'user-gender';
  static const userDob = 'user-dob';

  /// Group Membership
  static const activeGroupId = 'active-group-id';
  static const activeGroupTitle = 'active-group-title';
  static const groupLockedUntil = 'group-locked-until';

  /// Subscription
  static const subscriptionPlanId = 'subscription-plan-id';
  static const subscriptionPlanName = 'subscription-plan-name';
  static const subscriptionStatus = 'subscription-status';
  static const subscriptionStartDate = 'subscription-start-date';
  static const subscriptionExpiryDate = 'subscription-expiry-date';

  /// Notification
  static const hasPromptedNotificationSuffix = 'has_prompted_notification';

  static String userScoped(String userId, String key) {
    return '${userId}_$key';
  }
}
