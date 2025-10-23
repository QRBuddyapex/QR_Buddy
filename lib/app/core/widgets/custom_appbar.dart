import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/data/repo/auth_repo.dart';
import 'package:qr_buddy/app/modules/e_ticket/controllers/shift_controller.dart';
import 'package:qr_buddy/app/routes/routes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onQrPressed;
  final VoidCallback? onLocationPressed;
  final VoidCallback? onProfilePressed;
  final Widget? leading;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onQrPressed,
    this.onLocationPressed,
    this.onProfilePressed,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TokenStorage tokenStorage = TokenStorage();
    final AuthRepository authRepository = AuthRepository();
    final ShiftController shiftController = Get.put(ShiftController(), permanent: true);
    final ThemeController themeController = Get.put(ThemeController(), permanent: true);

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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkCardBackgroundColor
                      : AppColors.cardBackgroundColor,
                  child: Container(
                    width: dialogWidth,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkBorderColor
                            : AppColors.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,

                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userType!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            await authRepository.logout();
                            await tokenStorage.clearToken();
                            Get.offAllNamed(RoutesName.loginScreen);
                          },
                          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: leading,
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 15,
            ),
      ),
      actions: [
        Obx(() {
          final currentStatus = shiftController.shiftStatus.value;
          return Row(
            children: [
              if (currentStatus == 'START')
                IconButton(
                  icon: const Icon(Icons.pause_circle_outline, color: Colors.yellow, size: 30),
                  onPressed: () => shiftController.updateShiftStatus('BREAK'),
                ),
              if (currentStatus == 'START' || currentStatus == 'BREAK')
                IconButton(
                  icon: const Icon(Icons.stop_circle, color: Colors.red, size: 30),
                  onPressed: () => shiftController.updateShiftStatus('END'),
                ),
              if (currentStatus == 'END' || currentStatus == 'BREAK')
                ElevatedButton(
                  onPressed: () => shiftController.startShift(),
                  style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                      ),
                  child: Text(
                    'Start Shift',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                  ),
                ),
              // IconButton(
              //   icon: Icon(
              //     Icons.qr_code,
              //     color: Theme.of(context).iconTheme.color,
              //   ),
              //   onPressed: onQrPressed,
              // ),
              Obx(() => IconButton(
                    icon: Icon(
                      themeController.isDarkMode.value ? Icons.brightness_7 : Icons.brightness_4,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () {
                      themeController.toggleTheme();
                    },
                  )),
              IconButton(
                icon: Icon(
                  Icons.location_on,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: onLocationPressed,
              ),
              IconButton(
                icon: Icon(
                  Icons.person,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: showProfileDialog,
              ),
            ],
          );
        }),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}