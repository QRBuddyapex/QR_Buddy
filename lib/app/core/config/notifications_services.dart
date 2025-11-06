import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/data/models/notification_model.dart';
import 'package:qr_buddy/app/modules/e_ticket/controllers/ticket_controller.dart';
import 'package:qr_buddy/app/routes/routes.dart';
import 'package:vibration/vibration.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final List<String> _processedMessageIds = [];
  static int _nextNotificationId = 0;

  static bool hasProcessedMessage(String? messageId) {
    if (messageId == null) return true;
    return _processedMessageIds.contains(messageId);
  }

  static void addProcessedMessage(String? messageId) {
    if (messageId != null && !_processedMessageIds.contains(messageId)) {
      _processedMessageIds.add(messageId);
    }
  }

  // 🔹 Create enhanced notification channels
  Future<void> createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final channels = [
      AndroidNotificationChannel(
        'ticket_channel',
        'Ticket Notifications',
        description: 'Notifications for ticket updates and assignments',
        importance: Importance.max,
        enableLights: true,
        enableVibration: true,
        showBadge: true,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('notification_sound'),
        vibrationPattern: Int64List.fromList([0, 1500, 500, 1500]),
      ),
      AndroidNotificationChannel(
        'food_channel',
        'Food Delivery Notifications',
        description: 'Notifications for food delivery tasks',
        importance: Importance.max,
        enableLights: true,
        enableVibration: true,
        showBadge: true,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('notification_sound'),
        vibrationPattern: Int64List.fromList([0, 1500, 500, 1500]),
      ),
      AndroidNotificationChannel(
        'checklist_channel',
        'Checklist Notifications',
        description: 'Notifications for checklist tasks',
        importance: Importance.max,
        enableLights: true,
        enableVibration: true,
        showBadge: true,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('notification_sound'),
        vibrationPattern: Int64List.fromList([0, 1500, 500, 1500]),
      ),
      AndroidNotificationChannel(
        'system_notification_channel',
        'General Notifications',
        description: 'Shows notifications in system tray',
        importance: Importance.max,
        playSound: true,
      ),
    ];

    for (final c in channels) {
      await androidPlugin?.createNotificationChannel(c);
    }

    print('✅ Notification channels created successfully');
  }

  // 🔹 Request notification permissions
  Future<void> requestNotificationPermission() async {
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
      criticalAlert: true,
    );

    if (Platform.isAndroid && await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    print('Notification permission: ${settings.authorizationStatus}');
  }

  // 🔹 Initialize local notifications
  Future<void> initLocalNotification(BuildContext? context) async {
    const androidInit =
        AndroidInitializationSettings('@drawable/ic_notification'); // ✅ FIXED ICON
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    try {
      await flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          _handleNotificationTap(response.payload);
        },
        onDidReceiveBackgroundNotificationResponse: (response) {
          _handleNotificationTap(response.payload);
        },
      );
      print('✅ Local notifications initialized');
      await createNotificationChannels();
    } catch (e) {
      print('❌ Failed to initialize notifications: $e');
    }
  }

  // 🔹 Handle taps on notifications
  void _handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;

    final parts = payload.split('|');
    if (parts.length < 6) return;

    final notificationType = parts[1];
    final title = parts[2];
    final body = parts[3];
    final location = parts[4];
    final task = parts[5];
    final eventUuid = parts.length > 6 ? parts[6] : null;

    print('📩 Notification tapped → $notificationType');

    if (notificationType == 'food') {
      Get.to(() => FullScreenNotification(
            title: title,
            body: body,
            location: location,
            task: task,
            eventUuid: eventUuid,
          ));
    } else if (notificationType == 'checklist') {
      Get.to(() => ChecklistNotification(
            title: title,
            body: body,
            location: location,
            task: task,
            eventUuid: eventUuid,
          ));
    } else {
      Get.to(() => FullScreenNotification(
            title: title,
            body: body,
            location: location,
            task: task,
            eventUuid: eventUuid,
          ));
    }
  }

  // 🔹 Initialize Firebase messaging
  Future<void> firebaseInit(BuildContext? context) async {
    await initLocalNotification(context);

    FirebaseMessaging.onMessage.listen((message) async {
      if (hasProcessedMessage(message.messageId)) return;
      addProcessedMessage(message.messageId);

      try {
        final data = message.data;
        final payload = NotificationPayload.fromMap(data);
        final title = payload.title;
        final body = payload.body;
        final location = payload.url.isNotEmpty
            ? payload.url
            : 'Block A1, Ground Floor, Room G1-504 (Near Canteen)';
        final type = payload.eventType.toLowerCase();
        final eventUuid = payload.ticketUuid.isNotEmpty ? payload.ticketUuid : null;
        final task = 'View Details';

        await showInAppNotificationWithSound(
          title: title,
          body: body,
          location: location,
          task: task,
          eventUuid: eventUuid,
          notificationType: type,
        );
      } catch (e) {
        print('❌ Error showing foreground notification: $e');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (hasProcessedMessage(message.messageId)) return;
      addProcessedMessage(message.messageId);
      final data = message.data;
      final payload = NotificationPayload.fromMap(data);
      _handleNotificationTap(
          'in_app_notification|${payload.eventType}|${payload.title}|${payload.body}|${payload.url}|View Details|${payload.ticketUuid}');
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && !hasProcessedMessage(initialMessage.messageId)) {
      addProcessedMessage(initialMessage.messageId);
      final data = initialMessage.data;
      final payload = NotificationPayload.fromMap(data);
      _handleNotificationTap(
          'in_app_notification|${payload.eventType}|${payload.title}|${payload.body}|${payload.url}|View Details|${payload.ticketUuid}');
    }

    print('✅ Firebase Messaging initialized');
  }

  // 🔹 Channel mapping helper
  (String, String, String) _getChannelDetails(String notificationType) {
    switch (notificationType) {
      case 'food':
        return ('food_channel', 'Food Delivery Notifications',
            'Notifications for food delivery tasks');
      case 'checklist':
        return ('checklist_channel', 'Checklist Notifications',
            'Notifications for checklist tasks');
      default:
        return ('ticket_channel', 'Ticket Notifications',
            'Notifications for ticket updates and assignments');
    }
  }

  // 🔹 Core method: Show notification + full screen
  Future<void> showInAppNotificationWithSound({
    required String title,
    required String body,
    required String location,
    required String task,
    String? eventUuid,
    String notificationType = 'ticket',
  }) async {
    final (channelId, channelName, channelDescription) =
        _getChannelDetails(notificationType);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      showWhen: true,
      channelShowBadge: true,
      visibility: NotificationVisibility.public,
      autoCancel: true,
      fullScreenIntent: notificationType == 'ticket',
      icon: '@drawable/ic_notification', // ✅ Use your drawable icon
    );

    const iOSDetails = DarwinNotificationDetails(
      sound: 'notification_sound.caf',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    final payload =
        'in_app_notification|$notificationType|$title|$body|$location|$task${eventUuid != null ? '|$eventUuid' : ''}';

    final id = _nextNotificationId++;

    // Step 1: Show system tray notification
    await flutterLocalNotificationsPlugin.show(id, title, body, details,
        payload: payload);
    print('🔔 System notification displayed: $title');

    // Step 2: Show full-screen overlay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (notificationType == 'ticket') {
        Get.to(() => FullScreenNotification(
              title: title,
              body: body,
              location: location,
              task: task,
              eventUuid: eventUuid,
            ));
      } else if (notificationType == 'food') {
        Get.to(() => FullScreenNotification(
              title: title,
              body: body,
              location: location,
              task: task,
              eventUuid: eventUuid,
            ));
      } else if (notificationType == 'checklist') {
        Get.to(() => ChecklistNotification(
              title: title,
              body: body,
              location: location,
              task: task,
              eventUuid: eventUuid,
            ));
      }
    });

    // Step 3: Vibrate as fallback
    if (Platform.isAndroid && await Vibration.hasVibrator() == true) {
      Vibration.vibrate(pattern: [0, 1500, 500, 1500]);
    }
  }

  // 🔹 Play login alert
  Future<void> playLoginRinger() async {
    const channelId = 'login_notification_channel';

    final androidDetails = AndroidNotificationDetails(
      channelId,
      'Login Notification',
      channelDescription: 'Sound and vibration for login',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1500, 500, 1500]),
      visibility: NotificationVisibility.public,
      icon: '@drawable/ic_notification', // ✅ fix for login sound
    );

    const iOSDetails = DarwinNotificationDetails(
      sound: 'notification_sound.caf',
      presentSound: true,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await flutterLocalNotificationsPlugin.show(
      9999,
      'Login Successful',
      'Welcome back!',
      details,
    );

    if (Platform.isAndroid && await Vibration.hasVibrator() == true) {
      Vibration.vibrate(pattern: [0, 1500, 500, 1500]);
    }
  }

  // 🔹 Get device token
  Future<String> getDeviceToken() async {
    try {
      final token = await messaging.getToken();
      print('📱 FCM Token: $token');
      return token ?? '';
    } catch (e) {
      print('❌ Failed to get token: $e');
      return '';
    }
  }

  // 🔹 Token refresh listener
  void isTokenRefresh() {
    messaging.onTokenRefresh.listen((token) {
      print('🔁 Token refreshed: $token');
    });
  }

  // 🔹 Show simple system tray notification
  Future<void> showSystemNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'system_notification_channel',
        'General Notifications',
        channelDescription: 'Shows notifications in system tray',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
        icon: '@drawable/ic_notification', 
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails =
          NotificationDetails(android: androidDetails, iOS: iosDetails);

      final uniqueId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await flutterLocalNotificationsPlugin.show(
        uniqueId,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      print('System notification shown with ID: $uniqueId');
    } catch (e) {
      print('Error showing system notification: $e');
    }
  }
}


class FullScreenNotification extends StatelessWidget {
  final String title;
  final String body;
  final String location;
  final String task;
  final String? eventUuid;
  const FullScreenNotification({
    Key? key,
    required this.title,
    required this.body,
    required this.location,
    required this.task,
    this.eventUuid,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print('FullScreenNotification built with eventUuid: $eventUuid');
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
                    print("Accept and Start pressed with eventUuid: $eventUuid");
                    try {
                      if (eventUuid == null || eventUuid!.isEmpty) {
                        throw Exception('Event UUID is missing from notification');
                      }
                      final ticketController = Get.find<TicketController>();
                      final orderDetailResponse = await ticketController.fetchOrderDetail(eventUuid!);
                      if (orderDetailResponse == null) {
                        throw Exception('Failed to load ticket details');
                      }
                      final order = orderDetailResponse.order;
                      if (order == null) {
                        throw Exception('Order data not found');
                      }
                      final actualOrderId = order.id!;
                      await ticketController.updateRequest(
                        action: 'Accept',
                        orderId: actualOrderId,
                      );
                      Get.offAllNamed(RoutesName.ticketDashboardView);
                      await ticketController.fetchTickets();
                    } catch (e) {
                      print('Failed to accept request: $e');
                      Get.snackbar(
                        'Error',
                        'Failed to accept request. Please try again.',
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
  final String? eventUuid;
  const QikTasksNotification({
    Key? key,
    required this.title,
    required this.body,
    required this.location,
    required this.task,
    this.eventUuid,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print('QikTasksNotification built with eventUuid: $eventUuid');
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
                    print("Start Delivery pressed with eventUuid: $eventUuid");
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
class ChecklistNotification extends StatelessWidget {
  final String title;
  final String body;
  final String location;
  final String task;
  final String? eventUuid;
  const ChecklistNotification({
    Key? key,
    required this.title,
    required this.body,
    required this.location,
    required this.task,
    this.eventUuid,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print('ChecklistNotification built with eventUuid: $eventUuid');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBackgroundColor = isDark ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor;
    final textColor = isDark ? AppColors.darkTextColor : AppColors.textColor;
    final subtitleColor = isDark ? AppColors.darkSubtitleColor : AppColors.subtitleColor;
    final primaryColor = theme.primaryColor;
    final whiteColor = Colors.white;
    final greenColor = Colors.green[600]!; // Different color for checklists, e.g., green for completion
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
      backgroundColor: greenColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.checklist,
                    size: 80, color: whiteColor),
                const SizedBox(height: 24),
                Text(
                  'Checklist Notification',
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
                    print("Start Checklist pressed with eventUuid: $eventUuid");
                    try {
                      if (eventUuid == null || eventUuid!.isEmpty) {
                        throw Exception('Event UUID is missing from notification');
                      }
                      // Navigate to checklist details or update status
                      // Example: Get.offAllNamed(RoutesName.checklistDetailsView, arguments: {'checklistId': eventUuid});
                      Get.offAllNamed(RoutesName.ticketDashboardView); // Fallback to dashboard
                      final ticketController = Get.find<TicketController>();
                      await ticketController.fetchChecklistLog(); // Refresh checklists
                    } catch (e) {
                      print('Failed to start checklist: $e');
                      Get.snackbar(
                        'Error',
                        'Failed to start checklist: $e',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red.withOpacity(0.8),
                        colorText: Colors.white,
                      );
                    }
                  },
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  label: Text("Start Checklist",
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