import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/config/notifications_services.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/core/widgets/custom_buttom.dart';
import 'package:qr_buddy/app/core/widgets/custom_textfield.dart';

import '../controllers/login_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController loginController = Get.put(LoginController());
  final NotificationServices notificationServices = NotificationServices();
  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    print('NotificationServices initialized in LoginView');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.darkBackgroundColor
          : AppColors.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Obx(
              () => Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.darkCardBackgroundColor
                      : AppColors.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? AppColors.darkShadowColor
                          : AppColors.shadowColor,
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      'https://qrbuddy.in/assets/qr_buddy_logo.9534a79b.png',
                      height: 60,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Sign in',
                      style: textTheme.headlineMedium?.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextColor
                            : AppColors.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      hintText: 'E-mail',
                      onChanged: loginController.updateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    CustomTextField(
                      hintText: 'Password',
                      obscureText: true,
                      showToggleIcon: true,
                      visibilityController: loginController.isPasswordVisible,
                      onChanged: loginController.updatePassword,
                    ),
                    const SizedBox(height: 20),
                    loginController.isLoading.value
                        ? CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          )
                        : CustomButton(
                            width: width,
                            text: 'Sign In',
                            onPressed: loginController.login,
                            color: AppColors.primaryColor,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
