import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final notificationServices = NotificationServices();
  await notificationServices.requestNotificationPermission();
  await notificationServices.initLocalNotification(null);
  notificationServices.firebaseInit(null);

  final token = await notificationServices.getDeviceToken();
  log('FCM Token: $token');

  final tokenStorage = TokenStorage();
  final authToken = await tokenStorage.getToken();

  await _requestCorePermissions();
  if (Platform.isAndroid) await _checkForUpdate();

  final userId = await tokenStorage.getUserId();
  final initialRoute = (authToken != null && userId != null)
      ? RoutesName.ticketDashboardView
      : RoutesName.loginScreen;

  runApp(MyApp(
    notificationServices: notificationServices,
    initialRoute: initialRoute,
  ));
}

Future<void> _requestCorePermissions() async {
  if (!(await Permission.systemAlertWindow.isGranted)) {
    await Permission.systemAlertWindow.request();
  }
  if (!(await Permission.locationWhenInUse.isGranted)) {
    await Permission.locationWhenInUse.request();
  }
  if (!(await Permission.notification.isGranted)) {
    await Permission.notification.request();
  }
}

Future<void> _checkForUpdate() async {
  try {
    final info = await InAppUpdate.checkForUpdate();
    if (info.updateAvailability == UpdateAvailability.updateAvailable) {
      await _update();
    }
  } catch (e) {
    log('Error checking for update: $e');
  }
}

Future<void> _update() async {
  try {
    await InAppUpdate.startFlexibleUpdate();
    await InAppUpdate.completeFlexibleUpdate();
  } catch (e) {
    log('Error completing update: $e');
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final notificationServices = NotificationServices();
  await notificationServices.initLocalNotification(null);

  if (!NotificationServices.hasProcessedMessage(message.messageId)) {
    NotificationServices.addProcessedMessage(message.messageId);
    final notification = message.data['message'] as Map<String, dynamic>? ?? {};
    final data = notification['data'] as Map<String, dynamic>? ?? message.data;
    final title = data['title'] as String? ?? 'QR Buddy';
    final body = data['body'] as String? ?? 'New message';
    final url = data['url'] as String? ?? '';

    await notificationServices.showInAppNotificationWithSound(
      title: title,
      body: body,
      location: url.isNotEmpty
          ? url
          : 'Block A1, Ground Floor, Room G1-504 (Near Canteen)',
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
    final themeController = Get.put(ThemeController());
    Get.put(ShiftController()); // ShiftController globally

    // Setup MethodChannel handler after controller is put
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupMethodChannelHandler();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationServices.firebaseInit(context);
    });

    return Obx(
      () => GetMaterialApp(
        title: 'QR Buddy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode:
            themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        initialRoute: initialRoute,
        getPages: AppRoutes.appRoutes(),
        initialBinding: AuthBinding(),
      ),
    );
  }

  void _setupMethodChannelHandler() {
    const channel = MethodChannel('com.nxtdesigns.qrbuddy_apexv3/shift_service');
    channel.setMethodCallHandler((call) async {
      print('MethodChannel received call: ${call.method}');
      final shiftController = Get.find<ShiftController>();
      switch (call.method) {
        case 'takeBreak':
          print('Native requested to take break');
          await shiftController.updateShiftStatus('BREAK');
          break;
        case 'endShift':
          await shiftController.updateShiftStatus('END');
          break;
        case 'resumeShift':
          await shiftController.updateShiftStatus('START');
          break;
      }
    });
  }
}