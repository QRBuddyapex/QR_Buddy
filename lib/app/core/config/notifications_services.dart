import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // List to track processed message IDs to avoid duplicates
  static final List<String> _processedMessageIds = [];

  // Public method to check if a message has been processed
  static bool hasProcessedMessage(String? messageId) {
    if (messageId == null) return false;
    return _processedMessageIds.contains(messageId);
  }

  // Public method to add a message ID to the processed list
  static void addProcessedMessage(String? messageId) {
    if (messageId != null && !_processedMessageIds.contains(messageId)) {
      _processedMessageIds.add(messageId);
    }
  }

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
  Future<void> firebaseInit(BuildContext? context) async {
    // Initialize local notifications first
    await initLocalNotification(context);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) async {
      print('Foreground message received: ${message.messageId}');
      print('onMessage data: ${message.data}');
      print('onMessage notification: ${message.notification}');
      print('Data Title: ${message.data['fcm-title']}');
      print('Data Body: ${message.data['body']}');
      print('Data URL: ${message.data['url']}');

      // Only show in-app notification for foreground messages
      if (!hasProcessedMessage(message.messageId)) {
        addProcessedMessage(message.messageId);
        await showInAppNotificationWithSound(
          title: message.data['fcm-title'] ?? 'QR Buddy',
          body: message.data['body'] ?? 'New message',
          location: message.data['location'] ??
              'Block A1, Ground Floor, Room G1-504 (Near Canteen)',
          task: message.data['task'] ?? 'Change Bedsheet',
        );
      }
    });

    // Handle background messages (when app is opened from background)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('App opened from background: ${message.messageId}');
      print('Data on open: ${message.data}');
      if (!hasProcessedMessage(message.messageId)) {
        addProcessedMessage(message.messageId);
        showInAppNotificationWithSound(
          title: message.data['fcm-title'] ?? 'QR Buddy',
          body: message.data['body'] ?? 'New message',
          location: message.data['location'] ??
              'Block A1, Ground Floor, Room G1-504 (Near Canteen)',
          task: message.data['task'] ?? 'Change Bedsheet',
        );
      }
    });

    print('Firebase messaging initialized');
  }

  // Show notifications for background messages only
  Future<void> showNotifications(RemoteMessage message) async {
    var androidNotificationChannel = AndroidNotificationChannel(
      'default_channel',
      'qr_buddy',
      description: 'QR Buddy notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel)
        .catchError((e) {
      print('Failed to create notification channel: $e');
    });

   var androidNotificationDetails = AndroidNotificationDetails(
      'default_channel',
      'qr_buddy',
      channelDescription: 'QR Buddy notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      ticker: 'ticker',
    );
    const iosDetails = DarwinNotificationDetails(
      sound: 'notification_sound.caf',
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    );
    var notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosDetails,
    );

    try {
      print('Showing system notification with data: ${message.data}');
      final title = message.data['fcm-title'] ?? 'QR Buddy';
      final body = message.data['body'] ?? 'New message';
      final payload = message.data['url'] ?? '';

      await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      print('System notification shown successfully');
    } catch (e) {
      print('Failed to show system notification: $e');
    }
  }

  // Show in-app notification with sound and vibration (no system notification)
  Future<void> showInAppNotificationWithSound({
    required String title,
    required String body,
    required String location,
    required String task,
  }) async {
    // Define the Android notification channel for in-app notifications
    var androidNotificationChannel = AndroidNotificationChannel(
      'in_app_notification_channel',
      'In-App Notification',
      description: 'Channel for in-app notification sound and vibration',
      importance: Importance.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
    );

    // Create the notification channel for Android
    try {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidNotificationChannel);
      print('In-app notification channel created successfully');
    } catch (e) {
      print('Failed to create in-app notification channel: $e');
      return;
    }

    // Define Android notification details for sound and vibration
    var androidNotificationDetails = AndroidNotificationDetails(
      'in_app_notification_channel',
      'In-App Notification',
      channelDescription: 'Channel for in-app notification sound and vibration',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      showWhen: false,
      channelShowBadge: false,
      onlyAlertOnce: true,
      visibility: NotificationVisibility.secret,
    );

    // Define iOS notification details for sound and vibration
    const iosNotificationDetails = DarwinNotificationDetails(
      sound: 'notification_sound.caf',
      presentAlert: false,
      presentBadge: false,
      presentSound: true,
    );

   var notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    // Play the notification sound and trigger vibration
    try {
      print('Attempting to play in-app notification sound with vibration...');
      await flutterLocalNotificationsPlugin.show(
        1,
        null,
        null,
        notificationDetails,
        payload: 'in_app_notification_sound',
      );
      print('In-app notification sound and vibration triggered successfully');
    } catch (e) {
      print('Failed to play in-app notification sound or trigger vibration: $e');
      return;
    }

    // Show the custom in-app dialog
    Get.dialog(
      Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.notifications_active,
                    size: 64, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'New request assigned',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Block-Floor",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                Text(
                                    location.isNotEmpty
                                        ? location.split(',')[0].trim()
                                        : 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Room-Bed",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                Text(
                                    location.isNotEmpty && location.contains(',')
                                        ? location.split(',')[1].trim()
                                        : 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),
                      Center(
                        child: Text(task.isNotEmpty ? task : 'Unknown',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    print("Accept and Start pressed");
                    Get.back();
                  },
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  label: const Text("Accept and Start",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    print("Dismiss pressed");
                    Get.back();
                  },
                  child: const Text("Dismiss",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Play login sound with vibration using notification_sound.mp3
  Future<void> playLoginRinger() async {
    var androidNotificationChannel = AndroidNotificationChannel(
      'login_notification_channel',
      'Login Notification',
      description: 'Channel for login notification sound and vibration',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel)
        .catchError((e) {
      print('Failed to create login notification channel: $e');
    });

    var androidNotificationDetails = AndroidNotificationDetails(
      'login_notification_channel',
      'Login Notification',
      channelDescription: 'Channel for login notification sound and vibration',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      showWhen: false,
      channelShowBadge: false,
      onlyAlertOnce: true,
      visibility: NotificationVisibility.secret,
    );

    const iosNotificationDetails = DarwinNotificationDetails(
      sound: 'notification_sound.caf',
      presentAlert: false,
      presentBadge: false,
      presentSound: true,
    );

    var notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    try {
      print('Attempting to play login notification sound with vibration...');
      await flutterLocalNotificationsPlugin.show(
        0,
        null,
        null,
        notificationDetails,
        payload: 'login_notification_sound',
      );
      print('Login notification sound and vibration triggered successfully');
    } catch (e) {
      print('Failed to play login notification sound or trigger vibration: $e');
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