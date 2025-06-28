import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/data/repo/auth_repo.dart';
import 'package:qr_buddy/app/routes/routes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onStartShiftPressed;
  final VoidCallback? onQrPressed;
  final VoidCallback? onBrightnessPressed;
  final VoidCallback? onLocationPressed;
  final VoidCallback? onProfilePressed;
  final Widget? leading;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onStartShiftPressed,
    this.onQrPressed,
    this.onBrightnessPressed,
    this.onLocationPressed,
    this.onProfilePressed,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TokenStorage tokenStorage = TokenStorage();
    final AuthRepository authRepository = AuthRepository();

    void showProfileDialog() async {
      final String? userName = await tokenStorage.getUserName() ?? 'User';
      final String? userType = await tokenStorage.getUserType() ?? 'User';

  
      final RenderBox? appBarRenderBox = context.findRenderObject() as RenderBox?;
      final Offset? appBarPosition = appBarRenderBox?.localToGlobal(Offset.zero);
      final Size? appBarSize = appBarRenderBox?.size;

      const double iconButtonWidth = 48.0; 
      const double dialogWidth = 200.0;
      final double rightOffset = 16.0; 
      final double topOffset = appBarPosition?.dy != null
          ? appBarPosition!.dy + (appBarSize?.height ?? kToolbarHeight)
          : kToolbarHeight;

      showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return Stack(
            children: [
              Positioned(
                right: rightOffset,
                top: topOffset,
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: dialogWidth,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackgroundColor, 
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName ?? 'User',
                          style: AppTheme.theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ) ??
                              TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userType ?? 'User',
                          style: AppTheme.theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.subtitleColor,
                          ) ??
                              TextStyle(
                                fontSize: 12,
                                color: AppColors.subtitleColor,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            await authRepository.logout();
                            Get.offAllNamed(RoutesName.loginScreen);
                          },
                          style: AppTheme.theme.elevatedButtonTheme.style?.copyWith(
                            backgroundColor: WidgetStateProperty.all(AppColors.dangerButtonColor), 
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Log Out',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      leading: leading,
      title: Text(
        title,
        style: AppTheme.theme.textTheme.headlineMedium?.copyWith(
          fontSize: 20,
        ) ??
            TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
      ),
      actions:[
        ElevatedButton(
          onPressed: onStartShiftPressed,
          style: AppTheme.theme.elevatedButtonTheme.style?.copyWith(
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              ) ??
              ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
          child: const Text(
            'Start Shift',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.qr_code, color: AppColors.hintTextColor),
          onPressed: onQrPressed,
        ),
        IconButton(
          icon: const Icon(Icons.brightness_6, color: AppColors.hintTextColor),
          onPressed: onBrightnessPressed,
        ),
        IconButton(
          icon: const Icon(Icons.location_on, color: AppColors.hintTextColor),
          onPressed: onLocationPressed,
        ),
        IconButton(
          icon: const Icon(Icons.person, color: AppColors.hintTextColor),
          onPressed: showProfileDialog,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}