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
  // Initialize local notifications before any sound is played
  await notificationServices.initLocalNotification(null);
  notificationServices.firebaseInit(null); // We'll pass context later

  // Print device token
  final token = await notificationServices.getDeviceToken();
  print('FCM Token: $token');

  // Handle notifications when app is terminated
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    print("App opened from terminated state: ${initialMessage.messageId}");
    print("Terminated state data: ${initialMessage.data}");
    // Show in-app notification for terminated state
    // Ensure we haven't already processed this message
    if (!NotificationServices.hasProcessedMessage(initialMessage.messageId)) {
      NotificationServices.addProcessedMessage(initialMessage.messageId);
      await notificationServices.showInAppNotificationWithSound(
        title: initialMessage.data['fcm-title'] ?? 'QR Buddy',
        body: initialMessage.data['body'] ?? 'New message',
        location: initialMessage.data['location'] ??
            'Block A1, Ground Floor, Room G1-504 (Near Canteen)',
        task: initialMessage.data['task'] ?? 'Change Bedsheet',
      );
    }
  }

  runApp(MyApp(notificationServices: notificationServices));
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  print("Background message data: ${message.data}");

  // Show notification in background
  final notificationServices = NotificationServices();
  await notificationServices.initLocalNotification(null); // Ensure initialization
  await notificationServices.showNotifications(message);
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