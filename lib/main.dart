import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_buddy/app/core/config/notifications_services.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/modules/auth/bindings/auth_binding.dart';
import 'package:qr_buddy/app/modules/e_ticket/controllers/shift_controller.dart';
import 'package:qr_buddy/app/routes/routes.dart';
import 'package:qr_buddy/app/routes/routes_name.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // NEW: Initialize communication port BEFORE runApp (required for plugin registration)
  FlutterForegroundTask.initCommunicationPort();

  // Initialize NotificationServices
  final notificationServices = NotificationServices();
  await notificationServices.requestNotificationPermission();
  await notificationServices.initLocalNotification(null);
  notificationServices.firebaseInit(null);

  final token = await notificationServices.getDeviceToken();
  print('FCM Token: $token');

  final tokenStorage = TokenStorage();
  final authToken = await tokenStorage.getToken();

  final permissionStatus = await Permission.location.status;
  if (!permissionStatus.isGranted) {
    final requestStatus = await Permission.location.request();
    if (!requestStatus.isGranted) {
      exit(0);
    }
  }

  if (Platform.isAndroid) {
    await _checkForUpdate();
  }

  // Initialize foreground task for shift service
  await _initForegroundTask();

  final userId = await tokenStorage.getUserId();
  final initialRoute = (authToken != null && userId != null)
      ? RoutesName.ticketDashboardView
      : RoutesName.loginScreen;

  runApp(MyApp(
    notificationServices: notificationServices,
    initialRoute: initialRoute,
  ));
}

Future<void> _initForegroundTask() async {
  // Request general notification permission first (via permission_handler)
  await Permission.notification.request();

  // NOW initialize the plugin (sets up method channels)
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'shift_channel',
      channelName: 'Shift Status',
      channelDescription: 'Shows when shift is active and waiting for orders.',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      onlyAlertOnce: true,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(5000),  // Every 5s
      autoRunOnBoot: false,
      autoRunOnMyPackageReplaced: false,
      allowWakeLock: true,
      allowWifiLock: false,
    ),
  );

  // NOW check and request foreground-specific notification permission
  if (await FlutterForegroundTask.checkNotificationPermission() != NotificationPermission.granted) {
    await FlutterForegroundTask.requestNotificationPermission();
  }

  // Ignore battery optimization (prompt user)
  if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
    await FlutterForegroundTask.requestIgnoreBatteryOptimization();
  }

  // Set up data listener (for communication from service to app)
  FlutterForegroundTask.addTaskDataCallback(_onReceiveShiftData);
}

void _onReceiveShiftData(Object? data) {
  if (data is Map<String, dynamic>) {
    print('Received from shift service: $data');
    final String event = data['event'] ?? '';
    switch (event) {
      case 'take_break':
        // Handle break from button press
        final shiftController = Get.find<ShiftController>();
        shiftController.updateShiftStatus('BREAK');
        break;
      case 'shift_ended':
        // Handle service stop
        final shiftController = Get.find<ShiftController>();
        shiftController.shiftStatus.value = 'END';
        break;
      // Add more cases as needed (e.g., 'heartbeat' for logging)
    }
  }
}

Future<void> _checkForUpdate() async {
  log('checking for update');
  await InAppUpdate.checkForUpdate().then((info) async {
    if (info.updateAvailability == UpdateAvailability.updateAvailable) {
      log('update available');
      await _update();
    }
  }).catchError((error) {
    log('Error checking for update: $error');
  });
}

Future<void> _update() async {
  log('performing update');
  await InAppUpdate.startFlexibleUpdate();
  InAppUpdate.completeFlexibleUpdate().then((value) {
    log('update completed');
  }).catchError((error) {
    log('Error completing update: $error');
  });
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  print("Background message data: ${message.data.toString()}");
  print("Background message data structure: ${message.data}");

  final notificationServices = NotificationServices();
  await notificationServices.initLocalNotification(null);

  if (!NotificationServices.hasProcessedMessage(message.messageId)) {
    NotificationServices.addProcessedMessage(message.messageId);
    final notification = message.data['message'] as Map<String, dynamic>? ?? {};
    final data = notification['data'] as Map<String, dynamic>? ?? message.data;
    print('Processed background notification data: $data');
    final title = data['title'] as String? ?? 'QR Buddy';
    final body = data['body'] as String? ?? 'New message';
    final url = data['url'] as String? ?? '';

    if (title.isEmpty || body.isEmpty) {
      print('Warning: Empty title or body received from backend in background');
    }

    await notificationServices.showInAppNotificationWithSound(
      title: title,
      body: body,
      location: url.isNotEmpty ? url : 'Block A1, Ground Floor, Room G1-504 (Near Canteen)',
      task: 'View Details',
    );
  }
}

class MyApp extends StatelessWidget {
  final NotificationServices notificationServices;
  final String initialRoute;

  const MyApp({
    Key? key,
    required this.notificationServices,
    required this.initialRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationServices.firebaseInit(context);
    });

    // Wrap with WithForegroundTask for handling app lifecycle
    return WithForegroundTask(
      child: Obx(() => GetMaterialApp(
            title: 'QR Buddy',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
            initialRoute: initialRoute,
            getPages: AppRoutes.appRoutes(),
            initialBinding: AuthBinding(),
          )),
    );
  }
}