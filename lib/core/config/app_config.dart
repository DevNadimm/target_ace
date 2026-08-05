class AppConfig {
  AppConfig._();

  static const String appName = "TargetAce";
  static const String appVersion = "1.0.0";
  static const String appSubtitle = "Live. Battle. Exams.";

  /// Supabase Configuration Placeholders
  static const String supabaseUrl = "https://pymjlwxuqyxjdjwdkryl.supabase.co";
  static const String supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB5bWpsd3h1cXl4amRqd2RrcnlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQxMzIxMDQsImV4cCI6MjA5OTcwODEwNH0.Wy-lep-A4JgOn8PyXwl0gj9UUSq6mtC5DPQR3vdbnHc";
  static const String googleWebClientId = "18544964366-df9f7gm7235a1gok16kcmaqcu56im2kp.apps.googleusercontent.com";

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
