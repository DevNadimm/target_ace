import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:target_ace/core/common/models/cached_user_model.dart';
import 'package:target_ace/core/config/preference_keys.dart';

/// Single point of read/write for all cached user data in SharedPreferences.
///
/// Stores the entire [CachedUserModel] as a single JSON blob under
/// the key [_kCachedUser], replacing 20+ scattered preference keys.
class UserLocalDataSource {
  UserLocalDataSource._();

  static const String _kCachedUser = 'cached_user';
  static Future<void>? _activeWriteLock;

  // ─────────────────────────────────────────────
  // Primary CRUD
  // ─────────────────────────────────────────────

  /// Save the entire user model as a single JSON string.
  static Future<void> saveUser(CachedUserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCachedUser, jsonEncode(user.toJson()));
  }

  /// Read the cached user model. Returns null if no user is cached.
  static Future<CachedUserModel?> readUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_kCachedUser);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return CachedUserModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Clear the cached user data (e.g., on logout).
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCachedUser);
  }

  static Future<void> updateFields(Map<String, dynamic> updates) async {
    if (_activeWriteLock != null) {
      await _activeWriteLock;
    }

    final completer = Completer<void>();
    _activeWriteLock = completer.future;

    try {
      final current = await readUser();
      if (current != null) {
        final json = current.toJson();
        json.addAll(updates);
        await saveUser(CachedUserModel.fromJson(json));
      }
    } finally {
      completer.complete();
      _activeWriteLock = null;
    }
  }

  // ─────────────────────────────────────────────
  // Convenience Getters (read from the JSON blob)
  // ─────────────────────────────────────────────

  static Future<String> getUserId() async {
    final user = await readUser();
    return user?.id ?? '';
  }

  static Future<String> getUserName() async {
    final user = await readUser();
    return user?.name ?? 'User';
  }

  static Future<String> getUserEmail() async {
    final user = await readUser();
    return user?.email ?? '';
  }

  static Future<String> getUserPhone() async {
    final user = await readUser();
    return user?.phone ?? '';
  }

  static Future<String> getUserGender() async {
    final user = await readUser();
    return user?.gender ?? '';
  }

  static Future<String> getUserDob() async {
    final user = await readUser();
    return user?.dob ?? '';
  }

  static Future<String> getUserAvatarUrl() async {
    final user = await readUser();
    return user?.avatarUrl ?? '';
  }

  static Future<String> getUserGoal() async {
    final user = await readUser();
    return user?.goal ?? '';
  }

  static Future<String> getUserGroupId() async {
    final user = await readUser();
    return user?.groupId ?? '';
  }

  static Future<String?> getUserGroupTitle() async {
    final user = await readUser();
    final title = user?.groupTitle ?? '';
    return title.isEmpty ? null : title;
  }

  static Future<String> getUserInstitution() async {
    final user = await readUser();
    return user?.institution ?? '';
  }

  static Future<String> getUserDistrict() async {
    final user = await readUser();
    return user?.district ?? '';
  }

  static Future<String> getHowDidYouHear() async {
    final user = await readUser();
    return user?.howDidYouHear ?? '';
  }

  static Future<String> getDailyGoal() async {
    final user = await readUser();
    return user?.dailyGoal ?? '';
  }

  static Future<List<String>> getLearningModes() async {
    final user = await readUser();
    return user?.learningModes ?? const [];
  }

  static Future<String?> getUserGroupLockedUntil() async {
    final user = await readUser();
    final locked = user?.groupLockedUntil ?? '';
    return locked.isEmpty ? null : locked;
  }

  static Future<bool> isGroupSwitchAllowed() async {
    final user = await readUser();
    final lockedUntil = user?.groupLockedUntil ?? '';
    if (lockedUntil.isEmpty) return true;

    final lockDate = DateTime.tryParse(lockedUntil);
    if (lockDate == null) return true;

    return DateTime.now().toUtc().isAfter(lockDate);
  }

  static Future<String> getSubscriptionStatus() async {
    final user = await readUser();
    return user?.subscriptionStatus ?? 'none';
  }

  static Future<String> getSubscriptionPlanName() async {
    final user = await readUser();
    return user?.subscriptionPlanName ?? '';
  }

  static Future<String?> getSubscriptionExpiryDate() async {
    final user = await readUser();
    final expiry = user?.subscriptionExpiryDate ?? '';
    return expiry.isEmpty ? null : expiry;
  }

  /// Subscription start date is not stored in CachedUserEntity.
  /// Returns null for backward compatibility — callers display '' if null.
  static Future<String?> getSubscriptionStartDate() async {
    return null;
  }

  static Future<bool> getHasPromptedNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await getUserId();
    if (userId.isEmpty) return false;
    final key = PreferenceKeys.userScoped(
      userId,
      PreferenceKeys.hasPromptedNotificationSuffix,
    );
    return prefs.getBool(key) ?? false;
  }

  static Future<bool> setHasPromptedNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await getUserId();
    if (userId.isEmpty) return false;
    final key = PreferenceKeys.userScoped(
      userId,
      PreferenceKeys.hasPromptedNotificationSuffix,
    );
    return await prefs.setBool(key, value);
  }

  static Future<bool> getHasSkippedFreeTrial() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await getUserId();
    if (userId.isEmpty) return false;
    final key = PreferenceKeys.userScoped(
      userId,
      PreferenceKeys.hasSkippedFreeTrialSuffix,
    );
    return prefs.getBool(key) ?? false;
  }

  static Future<bool> setHasSkippedFreeTrial(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await getUserId();
    if (userId.isEmpty) return false;
    final key = PreferenceKeys.userScoped(
      userId,
      PreferenceKeys.hasSkippedFreeTrialSuffix,
    );
    return await prefs.setBool(key, value);
  }

  /// Checks if the user profile is complete (groupId and phone are non-empty).
  static Future<bool> isProfileComplete() async {
    final user = await readUser();
    if (user == null) return false;
    return user.groupId.isNotEmpty &&
        user.phone.isNotEmpty;
  }
}
