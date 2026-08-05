import 'dart:convert';
import 'package:target_ace/core/config/preference_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static Future<String> getLastSyncedFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.lastSyncedFcmToken) ?? '';
  }

  static Future<void> setLastSyncedFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.lastSyncedFcmToken, token);
  }

  /// Clear all preferences (e.g., on logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final firstTime = prefs.getBool(PreferenceKeys.isFirstTime) ?? true;
    final language = prefs.getString(PreferenceKeys.selectedLanguage);
    
    await prefs.clear();
    
    await prefs.setBool(PreferenceKeys.isFirstTime, firstTime);
    if (language != null) {
      await prefs.setString(PreferenceKeys.selectedLanguage, language);
    }
  }

  /// Exam Questions Caching
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

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // FCM Topics Local Sync Cache
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const String _syncedTopicsKey = 'synced_topics';

  static Future<List<String>> getSyncedTopics() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_syncedTopicsKey) ?? [];
  }

  static Future<void> addSyncedTopic(String topic) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_syncedTopicsKey) ?? [];
    if (!current.contains(topic)) {
      current.add(topic);
      await prefs.setStringList(_syncedTopicsKey, current);
    }
  }

  static Future<void> removeSyncedTopic(String topic) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_syncedTopicsKey) ?? [];
    if (current.contains(topic)) {
      current.remove(topic);
      await prefs.setStringList(_syncedTopicsKey, current);
    }
  }

  static Future<void> clearSyncedTopics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_syncedTopicsKey);
  }
}