import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static const String appName = "TargetAce";
  static const String appVersion = "1.0.0";
  static const String appSubtitle = "Live. Battle. Exams.";
  static const bool isDevelopment = true;
  static const bool isPracticeUnderDevelopment = true;

  /// Supabase Configuration Placeholders
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

  /// URLs
  static const String websiteUrl = "https://targetace-web.vercel.app/";
  static const String subscriptionPlanUrl = "$websiteUrl/en#pricing";
  static const String termsUrl = "$websiteUrl/en/terms";
  static const String privacyUrl = "$websiteUrl/en/privacy";

  /// Support
  static const String supportPhone = "+8801841953404";

  static String supportWhatsAppUrl([String? message]) {
    if (message == null || message.isEmpty) {
      return "https://wa.me/$supportPhone";
    }

    return "https://wa.me/$supportPhone?text=${Uri.encodeComponent(message)}";
  }
}