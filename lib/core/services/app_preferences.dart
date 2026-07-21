import 'dart:convert';
import 'package:target_ace/core/config/preference_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:target_ace/core/utils/enums/subscription_gate_type.dart';

class AppPreferences {
  AppPreferences._();

  /// Access Token
  static Future<String> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.accessToken) ?? '';
  }

  static Future<void> setAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.accessToken, token);
  }

  static Future<void> removeAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PreferenceKeys.accessToken);
  }

  /// Remember Me
  static Future<bool> isRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PreferenceKeys.isRememberMe) ?? false;
  }

  static Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PreferenceKeys.isRememberMe, value);
  }

  /// First Time User
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PreferenceKeys.isFirstTime) ?? true;
  }

  static Future<void> setFirstTime(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PreferenceKeys.isFirstTime, value);
  }

  /// Language
  static Future<String> getSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.selectedLanguage) ?? 'en';
  }

  static Future<void> setSelectedLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.selectedLanguage, code);
  }

  /// User Role
  static Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.userRole) ?? '';
  }

  static Future<void> setUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.userRole, role);
  }

  /// User Name
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.userName) ?? 'User';
  }

  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.userName, name);
  }

  /// User ID
  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.userId) ?? '';
  }

  static Future<void> setUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.userId, id);
  }

  /// User Email
  static Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.userEmail) ?? '';
  }

  static Future<void> setUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.userEmail, email);
  }

  /// User Phone
  static Future<String> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.userPhone) ?? '';
  }

  static Future<void> setUserPhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.userPhone, phone);
  }

  static const String _userAvatarUrlKey = PreferenceKeys.userAvatarUrl;

  static Future<String> getUserAvatarUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userAvatarUrlKey) ?? '';
  }

  static Future<void> setUserAvatarUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userAvatarUrlKey, url);
  }

  /// User Goal (e.g., 'BCS', 'HSC', 'Admission')
  static Future<String> getUserGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.userGoal) ?? '';
  }

  static Future<void> setUserGoal(String goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.userGoal, goal);
  }

  /// User Sub-Group (e.g., 'science', 'commerce', 'humanities')
  static Future<String> getUserGroup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.userGroup) ?? '';
  }

  static Future<void> setUserGroup(String group) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.userGroup, group);
  }

  /// User Institution / College / University
  static Future<String> getUserInstitution() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.userInstitution) ?? '';
  }

  static Future<void> setUserInstitution(String institution) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.userInstitution, institution);
  }

  /// User District
  static Future<String> getUserDistrict() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.userDistrict) ?? '';
  }

  static Future<void> setUserDistrict(String district) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.userDistrict, district);
  }

  /// User Gender
  static Future<String> getUserGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.userGender) ?? '';
  }

  static Future<void> setUserGender(String gender) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.userGender, gender);
  }

  /// User Date of Birth (ISO format e.g. YYYY-MM-DD)
  static Future<String> getUserDob() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.userDob) ?? '';
  }

  static Future<void> setUserDob(String dob) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.userDob, dob);
  }

  /// Active Battle Group ID
  static Future<String> getActiveGroupId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.activeGroupId) ?? '';
  }

  static Future<void> setActiveGroupId(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.activeGroupId, groupId);
  }

  /// Active Battle Group Title (display name)
  static Future<String> getActiveGroupTitle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.activeGroupTitle) ?? '';
  }

  static Future<void> setActiveGroupTitle(String title) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.activeGroupTitle, title);
  }

  /// Group Lock Expiry (ISO 8601 string)
  static Future<String?> getGroupLockedUntil() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.groupLockedUntil);
  }

  static Future<void> setGroupLockedUntil(String isoDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.groupLockedUntil, isoDate);
  }

  /// Check if group switch is allowed (30-day lock expired)
  static Future<bool> isGroupSwitchAllowed() async {
    final lockedUntil = await getGroupLockedUntil();
    if (lockedUntil == null || lockedUntil.isEmpty) return true;
    final lockDate = DateTime.tryParse(lockedUntil);
    if (lockDate == null) return true;
    return DateTime.now().toUtc().isAfter(lockDate);
  }

  /// Save full group membership in one call
  static Future<void> saveGroupMembership({
    required String groupId,
    required String groupTitle,
    required String lockedUntil,
  }) async {
    await setActiveGroupId(groupId);
    await setActiveGroupTitle(groupTitle);
    await setGroupLockedUntil(lockedUntil);
  }

  // ─────────────────────────────────────────────
  // Subscription
  // ─────────────────────────────────────────────

  /// Subscription Plan ID
  static Future<int> getSubscriptionPlanId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PreferenceKeys.subscriptionPlanId) ?? 0;
  }

  static Future<void> setSubscriptionPlanId(int planId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PreferenceKeys.subscriptionPlanId, planId);
  }

  /// Subscription Plan Name (e.g. "Starter", "Pro", "Pro Yearly")
  static Future<String> getSubscriptionPlanName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.subscriptionPlanName) ?? '';
  }

  static Future<void> setSubscriptionPlanName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.subscriptionPlanName, name);
  }

  /// Subscription Status: "active", "expired", "trial", "cancelled", or "none"
  static Future<String> getSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.subscriptionStatus) ?? 'none';
  }

  static Future<void> setSubscriptionStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.subscriptionStatus, status);
  }

  /// Subscription Start Date
  static Future<String?> getSubscriptionStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.subscriptionStartDate);
  }

  static Future<void> setSubscriptionStartDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.subscriptionStartDate, date);
  }

  /// Subscription Expiry Date
  static Future<String?> getSubscriptionExpiryDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.subscriptionExpiryDate);
  }

  static Future<void> setSubscriptionExpiryDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.subscriptionExpiryDate, date);
  }

  /// Determines the current subscription gate state.
  static Future<SubscriptionGateType> getGateType() async {
    final status = await getSubscriptionStatus();
    final expiry = await getSubscriptionExpiryDate();

    if (status == 'none') return SubscriptionGateType.none;

    if (status == 'pending_verification') {
      return SubscriptionGateType.pending;
    }

    if (status == 'expired') return SubscriptionGateType.expired;

    if (status == 'cancelled') return SubscriptionGateType.cancelled;

    if (expiry == null) {
      setSubscriptionStatus('expired');
      return SubscriptionGateType.expired;
    }

    final isValid = DateTime.parse(expiry).isAfter(DateTime.now());

    if (!isValid) {
      setSubscriptionStatus('expired');
      return SubscriptionGateType.expired;
    }

    return SubscriptionGateType.ok;
  }

  /// Saves all subscription fields in one call â€” call this right after a
  /// successful subscribe/renew API response.
  static Future<void> saveSubscription({
    required int planId,
    required String planName,
    required String startDate,
    required String expiryDate,
    String status = 'active',
  }) async {
    await setSubscriptionPlanId(planId);
    await setSubscriptionPlanName(planName);
    await setSubscriptionStartDate(startDate);
    await setSubscriptionExpiryDate(expiryDate);
    await setSubscriptionStatus(status);
  }

  /// Clears only subscription-related data (e.g. on plan cancellation or
  /// downgrade), leaving auth/profile data untouched.
  static Future<void> clearSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PreferenceKeys.subscriptionPlanId);
    await prefs.remove(PreferenceKeys.subscriptionPlanName);
    await prefs.remove(PreferenceKeys.subscriptionStartDate);
    await prefs.remove(PreferenceKeys.subscriptionExpiryDate);
    await prefs.remove(PreferenceKeys.subscriptionStatus);
  }

  /// Clear all preferences (e.g., on logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ─────────────────────────────────────────────
  // Exam Questions Caching
  // ─────────────────────────────────────────────

  static const String _cachedQuestionsKeyPrefix = 'cached_exam_questions_';

  static Future<void> saveCachedExamQuestions(String examId, List<Map<String, dynamic>> questions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(questions);
    await prefs.setString('$_cachedQuestionsKeyPrefix$examId', jsonStr);
  }

  static Future<List<Map<String, dynamic>>> getCachedExamQuestions(String examId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('$_cachedQuestionsKeyPrefix$examId');
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonStr) as List;
      return decoded.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearCachedExamQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_cachedQuestionsKeyPrefix)) {
        await prefs.remove(key);
      }
    }
  }
}

