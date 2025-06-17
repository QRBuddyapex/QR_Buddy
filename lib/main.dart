import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/config/notifications_services.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/modules/auth/bindings/auth_binding.dart';
import 'package:qr_buddy/app/routes/routes.dart';
import 'package:qr_buddy/app/routes/routes_name.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize NotificationServices
  final notificationServices = NotificationServices();
  await notificationServices.requestNotificationPermission();
  await notificationServices.initLocalNotification(null);
  notificationServices.firebaseInit(null);

  // Print device token
  final token = await notificationServices.getDeviceToken();
  print('FCM Token: $token');

  runApp(MyApp(notificationServices: notificationServices));
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  print("Background message data: ${message.data}");

  // Initialize NotificationServices
  final notificationServices = NotificationServices();
  await notificationServices.initLocalNotification(null);

  // Show full-screen notification for background/terminated state
  if (!NotificationServices.hasProcessedMessage(message.messageId)) {
    NotificationServices.addProcessedMessage(message.messageId);
    await notificationServices.showInAppNotificationWithSound(
      title: message.data['fcm-title'] ?? 'QR Buddy',
      body: message.data['body'] ?? 'New message',
      location: message.data['location'] ??
          'Block A1, Ground Floor, Room G1-504 (Near Canteen)',
      task: message.data['task'] ?? 'Change Bedsheet',
    );
  }
}

class MyApp extends StatelessWidget {
  final NotificationServices notificationServices;

  const MyApp({Key? key, required this.notificationServices})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pass context to firebaseInit after the app is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationServices.firebaseInit(context);
    });

    return GetMaterialApp(
      title: 'QR Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: RoutesName.loginScreen,
      getPages: AppRoutes.appRoutes(),
      initialBinding: AuthBinding(),
    );
  }
}