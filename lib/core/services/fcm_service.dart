import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../router/app_router.dart';

class FCMService {
  static const String _updateTokenUrl = 'http://188.245.212.240/api/users/update-fcm-token/';
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize(BuildContext context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configure foreground presentation for iOS
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications for Android foreground
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          try {
            final data = jsonDecode(response.payload!);
            _handleNotificationRouting(data);
          } catch (e) {
            debugPrint("Payload error: $e");
          }
        }
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      description: 'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Get and send token
    String? token = await messaging.getToken();
    if (token != null) {
      await _sendTokenToServer(token);
    }

    // Listen to token refresh
    messaging.onTokenRefresh.listen((newToken) {
      _sendTokenToServer(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/launcher_icon',
              color: const Color(0xFF1E3A8A), // Premium Dark Blue
              importance: Importance.high,
              priority: Priority.high,
              styleInformation: BigTextStyleInformation(
                notification.body ?? '',
                contentTitle: notification.title,
              ),
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // Handle terminated state (app launched from notification)
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationRouting(initialMessage.data);
    }

    // Handle background state (app running in background, user taps notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationRouting(message.data);
    });
  }

  static void _handleNotificationRouting(Map<String, dynamic> data) {
    if (data.containsKey('type')) {
      final type = data['type'];
      if (type == 'chat') {
        appRouter.go('/messages');
      } else if (type == 'new_job' || type == 'job_application') {
        appRouter.go('/classifieds?tab=jobs');
      } else if (type == 'forum_reply' || type == 'forum_comment') {
        appRouter.go('/community');
      } else {
        appRouter.go('/notifications');
      }
    } else {
      appRouter.go('/notifications');
    }
  }

  static Future<void> _sendTokenToServer(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('auth_token');
      
      if (accessToken == null) {
        debugPrint('FCM: User not logged in, cannot send token');
        return; // User not logged in
      }

      final response = await http.post(
        Uri.parse(_updateTokenUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'token': token,
          'device_type': 'android/ios',
        }),
      );
    } catch (e) {
      debugPrint('Failed to send FCM token: $e');
    }
  }
}
