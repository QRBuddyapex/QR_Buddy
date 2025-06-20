
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:vibration/vibration.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // List to track processed message IDs to avoid duplicates
  static final List<String> _processedMessageIds = [];

  // Public method to check if a message has been processed
  static bool hasProcessedMessage(String? messageId) {
    if (messageId == null) {
      print("Warning: Message ID is null, skipping to avoid duplicates");
      return true;
    }
    return _processedMessageIds.contains(messageId);
  }

  // Public method to add a message ID to the processed list
  static void addProcessedMessage(String? messageId) {
    if (messageId != null && !_processedMessageIds.contains(messageId)) {
      _processedMessageIds.add(messageId);
      print("Added message ID to processed list: $messageId");
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

    if (Platform.isAndroid && await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

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

    try {
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          print('Notification tapped: ${response.payload}');
          if (response.payload != null && response.payload!.isNotEmpty) {
            print('Handling payload: ${response.payload}');
            final payloadData = response.payload!.split('|');
            if (payloadData[0] == 'in_app_notification') {
              try {
                Get.to(() => FullScreenNotification(
                      title: payloadData.length > 1 ? payloadData[1] : 'QR Buddy',
                      body: payloadData.length > 2 ? payloadData[2] : 'New message',
                      location: payloadData.length > 3
                          ? payloadData[3]
                          : 'Block A1, Ground Floor, Room G1-504 (Near Canteen)',
                      task: payloadData.length > 4 ? payloadData[4] : 'Change Bedsheet',
                    ));
              } catch (e) {
                print('Failed to navigate to FullScreenNotification: $e');
              }
            }
          }
        },
      );
      print('Local notifications initialized successfully');
    } catch (e) {
      print('Failed to initialize local notifications: $e');
    }
  }

  // Initialize Firebase messaging
  Future<void> firebaseInit(BuildContext? context) async {
    await initLocalNotification(context);

    FirebaseMessaging.onMessage.listen((message) async {
      print('Foreground message received: ${message.messageId}');
      print('onMessage data: ${message.data}');
      print('onMessage notification: ${message.notification}');

      if (!hasProcessedMessage(message.messageId)) {
        addProcessedMessage(message.messageId);
        try {
          await showInAppNotificationWithSound(
            title: message.data['fcm-title'] ?? 'QR Buddy',
            body: message.data['body'] ?? 'New message',
            location: message.data['location'] ??
                'Block A1, Ground Floor, Room G1-504 (Near Canteen)',
            task: message.data['task'] ?? 'Change Bedsheet',
          );
        } catch (e) {
          print('Failed to process foreground notification: $e');
        }
      } else {
        print('Foreground notification already processed: ${message.messageId}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('App opened from background: ${message.messageId}');
      print('Data on open: ${message.data}');
      if (!hasProcessedMessage(message.messageId)) {
        addProcessedMessage(message.messageId);
        try {
          Get.to(() => FullScreenNotification(
                title: message.data['fcm-title'] ?? 'QR Buddy',
                body: message.data['body'] ?? 'New message',
                location: message.data['location'] ??
                    'Block A1, Ground Floor, Room G1-504 (Near Canteen)',
                task: message.data['task'] ?? 'Change Bedsheet',
              ));
        } catch (e) {
          print('Failed to navigate to FullScreenNotification: $e');
        }
      }
    });

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && !hasProcessedMessage(initialMessage.messageId)) {
      print('App opened from terminated state: ${initialMessage.messageId}');
      addProcessedMessage(initialMessage.messageId);
      try {
        await showInAppNotificationWithSound(
          title: initialMessage.data['fcm-title'] ?? 'QR Buddy',
          body: initialMessage.data['body'] ?? 'New message',
          location: initialMessage.data['location'] ??
              'Block A1, Ground Floor, Room G1-504 (Near Canteen)',
          task: initialMessage.data['task'] ?? 'Change Bedsheet',
        );
      } catch (e) {
        print('Failed to process initial message: $e');
      }
    }

    print('Firebase messaging initialized');
  }

  Future<void> showInAppNotificationWithSound({
    required String title,
    required String body,
    required String location,
    required String task,
  }) async {
    var androidNotificationChannel = AndroidNotificationChannel(
      'in_app_notification_channel',
      'In-App Notification',
      description: 'Channel for in-app notification sound and vibration',
      importance: Importance.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1500, 500, 1500, 500, 1500]),
    );

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

    var androidNotificationDetails = AndroidNotificationDetails(
      'in_app_notification_channel',
      'In-App Notification',
      channelDescription: 'Channel for in-app notification sound and vibration',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1500, 500, 1500, 500, 1500]),
      showWhen: false,
      channelShowBadge: false,
      onlyAlertOnce: true,
      visibility: NotificationVisibility.public,
      fullScreenIntent: true,
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
      print('Showing notification with title: $title, body: $body');
      await flutterLocalNotificationsPlugin.show(
        1,
        'Ticket Assigned: $title',
        body,
        notificationDetails,
        payload: 'in_app_notification|$title|$body|$location|$task',
      );
      print('Notification shown successfully');
    } catch (e) {
      print('Failed to show notification: $e');
    }

    // Show full-screen notification
    try {
      print('Navigating to FullScreenNotification');
      Get.to(() => FullScreenNotification(
            title: 'Ticket Assigned: $title',
            body: body,
            location: location,
            task: task,
          ));
      print('Navigation successful');
    } catch (e) {
      print('Failed to navigate to FullScreenNotification: $e');
    }

    // Fallback vibration for Android
    if (Platform.isAndroid && await Vibration.hasVibrator() == true) {
      print('Triggering fallback vibration');
      try {
        Vibration.vibrate(pattern: [0, 1500, 500, 1500, 500, 1500], intensities: [0, 255, 0, 255, 0, 255]);
      } catch (e) {
        print('Failed to trigger vibration: $e');
      }
    }
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
      vibrationPattern: Int64List.fromList([0, 1500, 500, 1500, 500, 1500]),
    );

    try {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidNotificationChannel);
      print('Login notification channel created successfully');
    } catch (e) {
      print('Failed to create login notification channel: $e');
    }

    var androidNotificationDetails = AndroidNotificationDetails(
      'login_notification_channel',
      'Login Notification',
      channelDescription: 'Channel for login notification sound and vibration',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1500, 500, 1500, 500, 1500]),
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

    // Fallback vibration for Android
    if (Platform.isAndroid && await Vibration.hasVibrator() == true) {
      print('Triggering fallback vibration for login');
      try {
        Vibration.vibrate(pattern: [0, 1500, 500, 1500, 500, 1500], intensities: [0, 255, 0, 255, 0, 255]);
      } catch (e) {
        print('Failed to trigger vibration: $e');
      }
    }
  }

  // Get device token
  Future<String> getDeviceToken() async {
    try {
      String? token = await messaging.getToken();
      print('FCM Token: $token');
      return token ?? '';
    } catch (e) {
      print('Failed to get FCM token: $e');
      return '';
    }
  }

  // Handle token refresh
  void isTokenRefresh() {
    messaging.onTokenRefresh.listen((token) {
      print('Token refreshed: $token');
    });
  }
}

class FullScreenNotification extends StatelessWidget {
  final String title;
  final String body;
  final String location;
  final String task;

  const FullScreenNotification({
    Key? key,
    required this.title,
    required this.body,
    required this.location,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.notifications_active,
                    size: 80, color: Colors.white),
                const SizedBox(height: 24),
                Text(
                  title, // Use the updated title with "Ticket Assigned"
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'New request assigned',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
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
                                        fontSize: 14, color: Colors.grey)),
                                Text(
                                    location.isNotEmpty
                                        ? location.split(',')[0].trim()
                                        : 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 16,
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
                                        fontSize: 14, color: Colors.grey)),
                                Text(
                                    location.isNotEmpty && location.contains(',')
                                        ? location.split(',')[1].trim()
                                        : 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, thickness: 1),
                      Center(
                        child: Text(task.isNotEmpty ? task : 'Unknown',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    print("Accept and Start pressed");
                    Get.back(); // Close the notification screen
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
                        horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    print("Dismiss pressed");
                    Get.back();
                  },
                  child: const Text("Dismiss",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}