import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/services/access_token_generator.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/services/dio_service.dart';
import 'package:target_ace/features/dashboard/presentation/pages/main_navigation_page.dart';
import 'package:target_ace/features/profile/data/repos/profile_repo.dart';
import 'package:target_ace/main.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance.showNotification(message);
}

Future<void> storeFcmToken(String userId, String? token) async {
  if (token == null || token.isEmpty || userId.isEmpty) return;
  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser == null || currentUser.id != userId) {
    debugPrint("Skipping FCM token storage: user is not authenticated in Supabase.");
    return;
  }
  try {
    await ProfileRepo.storeFcmToken(userId: userId, token: token);
  } catch (e) {
    debugPrint("Failed to store FCM device token: $e");
  }
}

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotification = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationInitialized = false;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    /// request permission
    await _requestPermission();

    /// setup message handlers
    await _setupMessageHandlers();

    /// subscribe to global topic
    try {
      await subscribeToTopic('all_users');
    } catch (e) {
      debugPrint("Failed to subscribe to all_users topic: $e");
    }

    /// subscribe to active battle group topic
    final activeGroupId = await AppPreferences.getActiveGroupId();
    if (activeGroupId.isNotEmpty) {
      try {
        await subscribeToTopic('group_$activeGroupId');
      } catch (e) {
        debugPrint("Failed to subscribe to group topic: $e");
      }
    }

    /// post fcm token
    final token = await _messaging.getToken();
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null && token != null) {
      await storeFcmToken(currentUser.id, token);
    }
  }

  Future<void> updateGroupSubscription(String oldGroupId, String newGroupId) async {
    if (oldGroupId == newGroupId) return;
    if (oldGroupId.isNotEmpty) {
      try {
        await unsubscribeFromTopic('group_$oldGroupId');
      } catch (e) {
        debugPrint("Failed to unsubscribe from old group topic ($oldGroupId): $e");
      }
    }
    if (newGroupId.isNotEmpty) {
      try {
        await subscribeToTopic('group_$newGroupId');
      } catch (e) {
        debugPrint("Failed to subscribe to new group topic ($newGroupId): $e");
      }
    }
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    debugPrint("Permission status: ${settings.authorizationStatus}");
  }

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationInitialized) {
      return;
    }

    const channel = AndroidNotificationChannel(
      "high_important_channel",
      "High Important Notifications",
      description: "This channel is used for important notifications.",
      importance: Importance.high,
    );

    await _localNotification.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    const initializationSettingsAndroid = AndroidInitializationSettings(
      "app_logo_transparent_notification",
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotification.initialize(
      onDidReceiveNotificationResponse: (details) {
        navigatorKey.currentState?.push(MainNavigationPage.route());
      },
      settings: initializationSettings,
    );

    _isFlutterLocalNotificationInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      await _localNotification.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            "high_important_channel",
            "High Important Notifications",
            channelDescription: "This channel is used for important notifications.",
            importance: Importance.max,
            priority: Priority.high,
            icon: 'app_logo_transparent_notification',
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> _setupMessageHandlers() async {
    /// foreground message
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
    });

    /// background message
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    /// opened app
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleBackgroundMessage(initialMessage);
      });
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    if (message.data['type'] == 'notification') {
      /// open main navigation screen
      navigatorKey.currentState?.push(MainNavigationPage.route());
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    debugPrint("Subscribed to: $topic");
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    debugPrint("Unsubscribed from: $topic");
  }

  Future<void> handleLogout() async {
    try {
      final activeGroupId = await AppPreferences.getActiveGroupId();
      if (activeGroupId.isNotEmpty) {
        await unsubscribeFromTopic('group_$activeGroupId');
      }
      await unsubscribeFromTopic('all_users');
      await _messaging.deleteToken();
      debugPrint("FCM token deleted and unsubscribed from topics on logout.");
    } catch (e) {
      debugPrint("Failed to handle FCM logout: $e");
    }
  }

  Future<void> sendFcmNotification({
    required String title,
    required String body,
    required String token,
  }) async {
    final accessToken = await AccessTokenGenerator.generateAccessToken();
    final dioService = DioService(baseUrl: "https://fcm.googleapis.com");
    await dioService.initAuthToken(accessToken);
    final data = {
      "message": {
        "token": token,
        "notification": {"title": title, "body": body},
        "data": {"type": "notification"},
      },
    };

    dioService.postRequest(
      "/v1/projects/targetace-app/messages:send",
      data: data,
    );
  }
}
