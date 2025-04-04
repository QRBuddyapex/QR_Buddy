import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/modules/e_ticket/views/ticket_dashboard_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'QR Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme, // Apply the custom theme
      // initialRoute: RoutesName.loginScreen, // Set the initial route
      // getPages: AppRoutes.appRoutes(),
      // initialBinding: AuthBinding(), // Register the routes
      home: TicketDashboardScreen(),
    );
  }
}