class PreferenceKeys {
  PreferenceKeys._();

  static const accessToken = 'access-token';
  static const isRememberMe = 'is-remember-me';
  static const isFirstTime = 'is-first-time';
  static const selectedLanguage = 'selectedLanguage';

  static const userRole = 'user-role';

  /// FCM Token
  static const lastSyncedFcmToken = 'last-synced-fcm-token';

  // -- User-Scoped Key Support --

  /// Generates a user-scoped preference key: `{userId}_{suffix}`.
  ///
  /// Example: `userScoped('abc-123', 'trial_dismissed')` -> `'abc-123_trial_dismissed'`
  static String userScoped(String userId, String suffix) => '${userId}_$suffix';

  /// Suffix constants for user-scoped keys.
  static const String hasPromptedNotificationSuffix = 'has_prompted_notification';
  static const String hasSkippedFreeTrialSuffix = 'has_skipped_free_trial';
}