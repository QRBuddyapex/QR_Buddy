import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/modules/auth/bindings/auth_binding.dart';
import 'package:qr_buddy/app/routes/routes.dart';
import 'package:qr_buddy/app/routes/routes_name.dart';


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
      theme: AppTheme.theme, 
      initialRoute: RoutesName.loginScreen, 
      getPages: AppRoutes.appRoutes(),
      initialBinding: AuthBinding(), 
     
    );
  }
}