import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/core/widgets/custom_buttom.dart';
import 'package:qr_buddy/app/core/widgets/custom_textfield.dart';

import '../controllers/login_controller.dart';

class LoginView extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());

  LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Obx(
              () => Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
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
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      hintText: 'E-mail',
                      onChanged: loginController.updateEmail,
                    ),
                    CustomTextField(
                      hintText: 'Password',
                      obscureText: true,
                      onChanged: loginController.updatePassword,
                    ),
                    loginController.isLoading.value
                        ? const CircularProgressIndicator()
                        : CustomButton(
                            text: 'Sign In',
                            onPressed: loginController.login,
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
