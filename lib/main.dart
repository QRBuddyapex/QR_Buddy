import 'dart:io' show exit; // Import for exiting the app

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler
import 'package:qr_buddy/app/core/config/notifications_services.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/modules/auth/bindings/auth_binding.dart';
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

  // Determine initial route based on token and user ID
  final userId = await tokenStorage.getUserId();
  final initialRoute = (authToken != null && userId != null)
      ? RoutesName.ticketDashboardView
      : RoutesName.loginScreen;

  runApp(MyApp(
    notificationServices: notificationServices,
    initialRoute: initialRoute,
  ));
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  print("Background message data: ${message.data.toString()}");
  print("Background message data structure: ${message.data}");

  // Initialize NotificationServices
  final notificationServices = NotificationServices();
  await notificationServices.initLocalNotification(null);

  // Show full-screen notification for background/terminated state
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
 
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationServices.firebaseInit(context);
    });

    return GetMaterialApp(
      title: 'QR Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: initialRoute,
      getPages: AppRoutes.appRoutes(),
      initialBinding: AuthBinding(),
    );
  }
}