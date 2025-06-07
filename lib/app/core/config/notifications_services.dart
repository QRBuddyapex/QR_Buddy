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
        if (response.payload != null && response.payload!.isNotEmpty) {
          print('Opening URL: ${response.payload}');
          // Add navigation logic here if needed
        }
      },
    ).catchError((e) {
      print('Failed to initialize local notifications: $e');
    });

    print('Local notifications initialized');
  }

  // Initialize Firebase messaging
  void firebaseInit(BuildContext? context) {
    // Initialize local notifications
    initLocalNotification(context);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      print('Foreground message received: ${message.messageId}');
      print('onMessage data: ${message.data}');
      print('onMessage notification: ${message.notification}');
      print('Data Title: ${message.data['fcm-title']}');
      print('Data Body: ${message.data['body']}');
      print('Data URL: ${message.data['url']}');
      showNotifications(message);
    });

    // Handle background messages (when app is opened from background)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('App opened from background: ${message.messageId}');
      print('Data on open: ${message.data}');
    });

    print('Firebase messaging initialized');
  }

  // Show notifications for FCM messages
  Future<void> showNotifications(RemoteMessage message) async {
    const androidNotificationChannel = AndroidNotificationChannel(
      'default_channel',
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
      'default_channel',
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
      // Use message.data since PHP sends a data message
      print('Showing notification with data: ${message}');
      print('Notification data: ${message.data}');
      final title = message.data['fcm-title'] ?? 'QR Buddy';
      final body = message.data['body'] ?? 'New message';
      final payload = message.data['url'] ?? '';

      print('Showing notification with title: $title, body: $body, payload: $payload');

      await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      print('Notification shown successfully');
    } catch (e) {
      print('Failed to show notification: $e');
    }
  }

  // Play a ringer tone on successful login
  Future<void> playLoginRinger() async {
    const androidNotificationChannel = AndroidNotificationChannel(
      'login_ringer_channel',
      'Login Ringer',
      description: 'Channel for login ringer tone',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('ringer'), // Custom sound file (ringer.mp3)
    );

    // Create the channel on Android
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel)
        .catchError((e) {
      print('Failed to create login ringer channel: $e');
    });

    const androidNotificationDetails = AndroidNotificationDetails(
      'login_ringer_channel',
      'Login Ringer',
      channelDescription: 'Channel for login ringer tone',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('ringer'), // Custom sound file (ringer.mp3)
      enableVibration: false, // Disable vibration for ringer
      showWhen: false, // Hide timestamp
    );

    const iosNotificationDetails = DarwinNotificationDetails(
      sound: 'ringer.caf', // Custom sound file (ringer.caf)
      presentAlert: false, // Don't show the notification banner
      presentBadge: false, // Don't update the app badge
    );

    const notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    try {
      await flutterLocalNotificationsPlugin.show(
        0, // Notification ID (unique for login ringer)
        'Login Successful',
        'Welcome to QR Buddy!',
        notificationDetails,
        payload: 'login_ringer', // Optional payload to identify this notification
      );

      print('Login ringer played successfully');
    } catch (e) {
      print('Failed to play login ringer: $e');
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