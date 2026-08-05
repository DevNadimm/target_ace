import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:target_ace/firebase_options.dart';
import 'package:target_ace/core/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/app.dart';
import 'package:device_preview/device_preview.dart';
import 'package:target_ace/core/config/app_config.dart';
import 'package:target_ace/core/logger/supabase_logging_client.dart';
import 'package:target_ace/core/services/service_locator.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey, // ignore: deprecated_member_use
    httpClient: SupabaseLoggingClient(),
  );

  await init();
  await sl.allReady();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  sl<NotificationService>().initialize().catchError((e) {
    debugPrint("Notification initialization failed: $e");
  });

  return runApp(DevicePreview(enabled: false, builder: (_) => const MyApp()));
}
