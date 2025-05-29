import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Request notification permissions
  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  // Initialize local notifications
  Future<void> initLocalNotification(BuildContext? context) async {
    const androidInitialization =
        AndroidInitializationSettings('@drawable/ic_notification');
    const iosInitialization = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: androidInitialization,
      iOS: iosInitialization,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        print('Notification tapped: ${response.payload}');
      },
    ).catchError((e) {
      print('Failed to initialize local notifications: $e');
    });
  }

  // Initialize Firebase messaging
  void firebaseInit(BuildContext? context) {
    // Initialize local notifications
    initLocalNotification(context);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      print('onMessage: ${message.data}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      showNotifications(message);
    });

    // Handle background messages (when app is opened from background)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('App opened from background: ${message.messageId}');
    });
  }

  // Show notifications
  Future<void> showNotifications(RemoteMessage message) async {
    const androidNotificationChannel = AndroidNotificationChannel(
      'default_channel', // Match with AndroidManifest.xml
      'qr_buddy',
      description: 'QR Buddy notifications',
      importance: Importance.max,
      playSound: true,
    );

    // Create the channel on Android
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel)
        .catchError((e) {
      print('Failed to create notification channel: $e');
    });

    const androidNotificationDetails = AndroidNotificationDetails(
      'default_channel', // Match with AndroidManifest.xml
      'qr_buddy',
      channelDescription: 'QR Buddy notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosDetails,
    );

    try {
      await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title ?? 'QR Buddy',
        message.notification?.body ?? 'New message',
        notificationDetails,
        payload: message.data['payload'],
      );
    } catch (e) {
      print('Failed to show notification: $e');
    }
  }

  // Get device token
  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    print('FCM Token: $token');
    return token ?? '';
  }

  // Handle token refresh
  void isTokenRefresh() {
    messaging.onTokenRefresh.listen((token) {
      print('Token refreshed: $token');
    });
  }
}