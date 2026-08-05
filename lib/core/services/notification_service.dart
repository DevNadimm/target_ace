import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/services/access_token_generator.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/services/dio_service.dart';
import 'package:target_ace/features/home/presentation/pages/main_navigation_page.dart';
import 'package:target_ace/features/notification/domain/usecases/store_fcm_token.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/main.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background handler runs in a separate isolate where GetIt is unavailable.
  // Create a lightweight standalone instance with only the local notifications
  // plugin, which is all that setupFlutterNotifications() and showNotification() need.
  final backgroundService = NotificationService._backgroundOnly(
    localNotifications: FlutterLocalNotificationsPlugin(),
  );
  await backgroundService.setupFlutterNotifications();
  await backgroundService.showNotification(message);
}

Future<void> storeFcmToken(String userId, String? token) async {
  if (token == null || token.isEmpty || userId.isEmpty) return;
  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser == null || currentUser.id != userId) {
    return;
  }

  // Prevent race-condition parallel uploads of the same token
  if (NotificationService._isTokenSyncing || NotificationService._lastAttemptedToken == token) {
    return;
  }

  NotificationService._isTokenSyncing = true;
  NotificationService._lastAttemptedToken = token;

  // Prevent duplicate API calls if the FCM token is already synced locally for this device
  final cachedToken = await AppPreferences.getLastSyncedFcmToken();
  if (cachedToken == token) {
    NotificationService._isTokenSyncing = false;
    return;
  }

  try {
    await sl<StoreFcmToken>().call(
      StoreFcmTokenParams(userId: userId, token: token),
    );
    await AppPreferences.setLastSyncedFcmToken(token);
  } catch (e) {
    NotificationService._lastAttemptedToken = ''; // Reset to allow retry later
    debugPrint("Failed to store FCM device token: $e");
  } finally {
    NotificationService._isTokenSyncing = false;
  }
}

class NotificationService {
  final SupabaseClient? _client;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotification;
  bool _isFlutterLocalNotificationInitialized = false;

  // Private static members for thread safety and global memory hygiene
  static String _lastAttemptedToken = '';
  static bool _isTokenSyncing = false;

  /// Primary constructor for full-featured service with all dependencies.
  NotificationService({
    required SupabaseClient client,
    required FirebaseMessaging messaging,
    required FlutterLocalNotificationsPlugin localNotifications,
  })  : _client = client,
        _messaging = messaging,
        _localNotification = localNotifications;

  /// Lightweight constructor for background isolate usage only.
  /// Only the local notifications plugin is needed for showing notifications.
  NotificationService._backgroundOnly({
    required FlutterLocalNotificationsPlugin localNotifications,
  })  : _client = null,
        _messaging = FirebaseMessaging.instance,
        _localNotification = localNotifications;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    /// setup message handlers
    await _setupMessageHandlers();

    /// subscribe to global topic
    try {
      await subscribeToTopic('all_users');
    } catch (e) {
      debugPrint("Failed to subscribe to all_users topic: $e");
    }

    /// subscribe to active battle group topic
    final activeGroupId = await UserLocalDataSource.getUserGroupId();
    if (activeGroupId.isNotEmpty) {
      try {
        await subscribeToTopic('group_$activeGroupId');
      } catch (e) {
        debugPrint("Failed to subscribe to group topic: $e");
      }
    }

    /// post fcm token (only if not already synced locally)
    final token = await _messaging.getToken();
    final currentUser = _client?.auth.currentUser;
    if (currentUser != null && token != null) {
      await storeFcmToken(currentUser.id, token);
    }
  }

  /// Registers FCM Token and subscribes to topics for the logged-in user.
  /// 
  /// Should be called after successful login or profile sync.
  Future<void> subscribeForUser({required String userId, required String groupId}) async {
    try {
      // Subscribe to global topic
      await subscribeToTopic('all_users');
      
      // Subscribe to active group topic
      if (groupId.isNotEmpty) {
        await subscribeToTopic('group_$groupId');
      }

      // Sync FCM device token with DB
      final token = await _messaging.getToken();
      if (token != null) {
        await storeFcmToken(userId, token);
      }
    } catch (e) {
      debugPrint("Failed to subscribe/sync FCM for user $userId: $e");
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

  Future<void> requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
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
    try {
      final syncedTopics = await AppPreferences.getSyncedTopics();
      if (syncedTopics.contains(topic)) {
        return; // Skip redundant API calls if already synced
      }

      await _messaging.subscribeToTopic(topic).timeout(const Duration(seconds: 10));
      await AppPreferences.addSyncedTopic(topic);
    } catch (e) {
      debugPrint("FCM subscribe to topic ($topic) failed/timed out: $e");
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic).timeout(const Duration(seconds: 10));
      await AppPreferences.removeSyncedTopic(topic);
    } catch (e) {
      debugPrint("FCM unsubscribe from topic ($topic) failed/timed out: $e");
    }
  }

  Future<void> handleLogout() async {
    try {
      final activeGroupId = await UserLocalDataSource.getUserGroupId();
      if (activeGroupId.isNotEmpty) {
        await unsubscribeFromTopic('group_$activeGroupId').catchError((e) {
          debugPrint("FCM unsubscribe activeGroup error: $e");
        });
      }
      await unsubscribeFromTopic('all_users').catchError((e) {
        debugPrint("FCM unsubscribe all_users error: $e");
      });
      
      await AppPreferences.setLastSyncedFcmToken('');
      await AppPreferences.clearSyncedTopics();
      
      // Delete token from Firebase to ensure next login generates a fresh token
      await _messaging.deleteToken().catchError((e) {
        debugPrint("FCM delete token error: $e");
      });
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