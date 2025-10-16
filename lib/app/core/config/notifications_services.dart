import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/modules/e_ticket/controllers/ticket_controller.dart';
import 'package:qr_buddy/app/routes/routes.dart';
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
                final notificationType = payloadData[1];
                final title = payloadData[2];
                final body = payloadData[3];
                final location = payloadData[4];
                final task = payloadData[5];
                final ticketId = payloadData.length > 6 ? payloadData[6] : null;
                print('Extracted notificationType: $notificationType, ticketId: $ticketId');

                if (notificationType == 'food') {
                  Get.to(() => QikTasksNotification(
                        title: title,
                        body: body,
                        location: location,
                        task: task,
                        ticketId: ticketId,
                      ));
                } else {
                  Get.to(() => FullScreenNotification(
                        title: title,
                        body: body,
                        location: location,
                        task: task,
                        ticketId: ticketId,
                      ));
                }
              } catch (e) {
                print('Failed to navigate based on notification type: $e');
              }
            }
          }
        },
        onDidReceiveBackgroundNotificationResponse: (response) {
          print('Background notification tapped: ${response.payload}');
          if (response.payload != null && response.payload!.isNotEmpty) {
            print('Handling background payload: ${response.payload}');
            final payloadData = response.payload!.split('|');
            if (payloadData[0] == 'in_app_notification') {
              try {
                final notificationType = payloadData[1];
                final title = payloadData[2];
                final body = payloadData[3];
                final location = payloadData[4];
                final task = payloadData[5];
                final ticketId = payloadData.length > 6 ? payloadData[6] : null;
                print('Extracted background notificationType: $notificationType, ticketId: $ticketId');

                if (notificationType == 'food') {
                  Get.to(() => QikTasksNotification(
                        title: title,
                        body: body,
                        location: location,
                        task: task,
                        ticketId: ticketId,
                      ));
                } else {
                  Get.to(() => FullScreenNotification(
                        title: title,
                        body: body,
                        location: location,
                        task: task,
                        ticketId: ticketId,
                      ));
                }
              } catch (e) {
                print('Failed to navigate from background based on type: $e');
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
      print('Foreground message received: ${message.toString()}');
      print('Foreground message ID: ${message.messageId}');
      print('onMessage data: ${message.data.toString()}');
      print('onMessage notification message: ${message.notification?.title}, ${message.notification?.body}');
      print('onMessage data structure: ${message.data}');

      if (!hasProcessedMessage(message.messageId)) {
        addProcessedMessage(message.messageId);
        try {
          final notification = message.data['message'] as Map<String, dynamic>? ?? {};
          final data = notification['data'] as Map<String, dynamic>? ?? message.data;
          print('Processed notification data: $data');
          final title = data['title'] as String? ?? 'QR Buddy';
          final body = data['body'] as String? ?? 'New message';
          final url = data['url'] as String? ?? '';
          final ticketId = data['ticket_id'] as String?; // Extract ticket_id as per log
          print('Extracted ticketId: $ticketId');

          if (title.isEmpty || body.isEmpty) {
            print('Warning: Empty title or body received from backend');
          }

          await showInAppNotificationWithSound(
            title: title,
            body: body,
            location: url.isNotEmpty ? url : 'Block A1, Ground Floor, Room G1-504 (Near Canteen)',
            task: 'View Details',
            ticketId: ticketId,
            notificationType: 'ticket',
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
      print('Data on open: ${message.data.toString()}');
      if (!hasProcessedMessage(message.messageId)) {
        addProcessedMessage(message.messageId);
        try {
          final notification = message.data['message'] as Map<String, dynamic>? ?? {};
          final data = notification['data'] as Map<String, dynamic>? ?? message.data;
          final title = data['title'] as String? ?? 'QR Buddy';
          final body = data['body'] as String? ?? 'New message';
          final url = data['url'] as String? ?? '';
          final ticketId = data['ticket_id'] as String?; // Extract ticket_id as per log
          print('Extracted ticketId on open: $ticketId');

          Get.to(() => FullScreenNotification(
                title: title,
                body: body,
                location: url.isNotEmpty ? url : 'Block A1, Ground Floor, Room G1-504 (Near Canteen)',
                task: 'View Details',
                ticketId: ticketId,
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
        final notification = initialMessage.data['message'] as Map<String, dynamic>? ?? {};
        final data = notification['data'] as Map<String, dynamic>? ?? initialMessage.data;
        final title = data['title'] as String? ?? 'QR Buddy';
        final body = data['body'] as String? ?? 'New message';
        final url = data['url'] as String? ?? '';
        final ticketId = data['ticket_id'] as String?; // Extract ticket_id as per log
        print('Extracted ticketId from initial: $ticketId');

        Get.to(() => FullScreenNotification(
              title: title,
              body: body,
              location: url.isNotEmpty ? url : 'Block A1, Ground Floor, Room G1-504 (Near Canteen)',
              task: 'View Details',
              ticketId: ticketId,
            ));
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
    String? ticketId,
    String notificationType = 'ticket',
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
      print('Showing notification with title: $title, body: $body, ticketId: $ticketId, type: $notificationType');
      await flutterLocalNotificationsPlugin.show(
        1,
        title,
        body,
        notificationDetails,
        payload: 'in_app_notification|$notificationType|$title|$body|$location|$task${ticketId != null ? '|$ticketId' : ''}',
      );
      print('Notification shown successfully with payload: in_app_notification|$notificationType|$title|$body|$location|$task${ticketId != null ? '|$ticketId' : ''}');
    } catch (e) {
      print('Failed to show notification: $e');
    }

    // Avoid contextless navigation in background
    if (Get.context != null) {
      try {
        print('Navigating to ${notificationType == 'food' ? 'QikTasksNotification' : 'FullScreenNotification'} with ticketId: $ticketId');
        if (notificationType == 'food') {
          Get.to(() => QikTasksNotification(
                title: title,
                body: body,
                location: location,
                task: task,
                ticketId: ticketId,
              ));
        } else {
          Get.to(() => FullScreenNotification(
                title: title,
                body: body,
                location: location,
                task: task,
                ticketId: ticketId,
              ));
        }
        print('Navigation successful');
      } catch (e) {
        print('Failed to navigate: $e');
      }
    } else {
      print('Context not available, skipping navigation');
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
  final String? ticketId;

  const FullScreenNotification({
    Key? key,
    required this.title,
    required this.body,
    required this.location,
    required this.task,
    this.ticketId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('FullScreenNotification built with ticketId: $ticketId');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBackgroundColor = isDark ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor;
    final textColor = isDark ? AppColors.darkTextColor : AppColors.textColor;
    final subtitleColor = isDark ? AppColors.darkSubtitleColor : AppColors.subtitleColor;
    final primaryColor = theme.primaryColor;
    final whiteColor = Colors.white;

    String blockFloor = 'Unknown';
    String roomBed = 'Unknown';
    if (location.contains('Block') || location.contains('Floor')) {
      final parts = location.split(',');
      blockFloor = parts.firstWhere(
        (part) => part.contains('Block') || part.contains('Floor'),
        orElse: () => '',
      ).trim();
    }
    if (location.contains('Room') || location.contains('Bed')) {
      final parts = location.split(',');
      roomBed = parts.firstWhere(
        (part) => part.contains('Room') || part.contains('Bed'),
        orElse: () => '',
      ).trim();
    }

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_active,
                    size: 80, color: whiteColor),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: theme.textTheme.headlineMedium!.copyWith(
                    color: whiteColor,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: whiteColor.withOpacity(0.7),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
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
                                Text("Block-Floor",
                                    style: theme.textTheme.bodySmall!.copyWith(
                                      color: subtitleColor,
                                      fontFamily: 'Poppins',
                                    )),
                                Text(
                                  blockFloor,
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Room-Bed",
                                    style: theme.textTheme.bodySmall!.copyWith(
                                      color: subtitleColor,
                                      fontFamily: 'Poppins',
                                    )),
                                Text(
                                  roomBed,
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, thickness: 1),
                      Center(
                        child: Text(task.isNotEmpty ? task : 'Unknown',
                            style: theme.textTheme.headlineSmall!.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            )),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    print("Accept and Start pressed with ticketId: $ticketId");
                    try {
                      if (ticketId == null) {
                        throw Exception('Ticket ID is missing from notification');
                      }
                      final ticketController = Get.find<TicketController>();
                      await ticketController.updateRequest(
                        action: 'Accept',
                        orderId: ticketId!,
                      );
                      Get.offAllNamed(RoutesName.ticketDashboardView);
                      await ticketController.fetchTickets();
                    } catch (e) {
                      print('Failed to accept request: $e');
                      Get.snackbar(
                        'Error',
                        'Failed to accept request: $e',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red.withOpacity(0.8),
                        colorText: Colors.white,
                      );
                    }
                  },
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  label: Text("Accept and Start",
                      style: theme.textTheme.labelLarge!.copyWith(
                        color: whiteColor,
                        fontFamily: 'Poppins',
                      )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteColor.withOpacity(0.2),
                    foregroundColor: whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    print("Dismiss pressed");
                    Get.back();
                  },
                  child: Text("Dismiss",
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: whiteColor,
                        fontFamily: 'Poppins',
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QikTasksNotification extends StatelessWidget {
  final String title;
  final String body;
  final String location;
  final String task;
  final String? ticketId;

  const QikTasksNotification({
    Key? key,
    required this.title,
    required this.body,
    required this.location,
    required this.task,
    this.ticketId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('QikTasksNotification built with ticketId: $ticketId');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBackgroundColor = isDark ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor;
    final textColor = isDark ? AppColors.darkTextColor : AppColors.textColor;
    final subtitleColor = isDark ? AppColors.darkSubtitleColor : AppColors.subtitleColor;
    final primaryColor = theme.primaryColor;
    final whiteColor = Colors.white;
    final orangeColor = Colors.orange[600]!;

    return Scaffold(
      backgroundColor: orangeColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.restaurant_menu,
                    size: 80, color: Colors.white),
                const SizedBox(height: 24),
                Text(
                  'Qik Tasks Notification',
                  style: theme.textTheme.headlineSmall!.copyWith(
                    color: whiteColor,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: theme.textTheme.headlineMedium!.copyWith(
                    color: whiteColor,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: whiteColor.withOpacity(0.7),
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
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
                                Text("Location",
                                    style: theme.textTheme.bodySmall!.copyWith(
                                      color: subtitleColor,
                                      fontFamily: 'Poppins',
                                    )),
                                Text(
                                  location,
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, thickness: 1),
                      Center(
                        child: Text(task.isNotEmpty ? task : 'Unknown',
                            style: theme.textTheme.headlineSmall!.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            )),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    print("Start Delivery pressed with ticketId: $ticketId");
                    try {
                      // For food delivery, navigate to dashboard or specific screen
                      // Optionally, implement accept logic if needed
                      Get.offAllNamed(RoutesName.ticketDashboardView);
                      final ticketController = Get.find<TicketController>();
                      await ticketController.fetchFoodDeliveries();
                    } catch (e) {
                      print('Failed to start delivery: $e');
                      Get.snackbar(
                        'Error',
                        'Failed to start delivery: $e',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red.withOpacity(0.8),
                        colorText: Colors.white,
                      );
                    }
                  },
                  icon: Icon(Icons.arrow_forward, color: orangeColor),
                  label: Text("Start Delivery",
                      style: theme.textTheme.labelLarge!.copyWith(
                        color: orangeColor,
                        fontFamily: 'Poppins',
                      )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteColor,
                    foregroundColor: orangeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    print("Dismiss pressed");
                    Get.back();
                  },
                  child: Text("Dismiss",
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: whiteColor,
                        fontFamily: 'Poppins',
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}