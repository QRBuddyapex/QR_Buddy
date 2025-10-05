import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/data/repo/auth_repo.dart';
import 'package:qr_buddy/app/routes/routes.dart';

/// GetX controller for drawer selection
class DrawerControllerX extends GetxController {
  var selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _updateIndexFromRoute(Get.currentRoute);
  }

  void _updateIndexFromRoute(String route) {
    switch (route) {
      case RoutesName.ticketDashboardView:
        selectedIndex.value = 0;
        break;
      case RoutesName.newtTicketView:
        selectedIndex.value = 4;
        break;
      case RoutesName.dailyChecklistView:
        selectedIndex.value = 5;
        break;
      default:
        selectedIndex.value = -1;
    }
  }

  void setIndex(int index) {
    selectedIndex.value = index;
  }
}


class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> with TickerProviderStateMixin {
  String? userName = 'User';
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;
  final List<AnimationController> _itemControllers = [];
  final List<Animation<Offset>> _slideAnimations = [];
  final List<Animation<double>> _fadeAnimations = [];

  // Initialize GetX DrawerController
  final drawerController = Get.put(DrawerControllerX());

  @override
  void initState() {
    super.initState();
    getUserName().then((value) {
      if (mounted) {
        setState(() {
          userName = value;
        });
      }
    });

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );
    _logoController.forward();

    _setupItemAnimations();
  }

  Future<String?> getUserName() async {
    final tokenStorage = TokenStorage();
    return await tokenStorage.getUserName();
  }

  void _setupItemAnimations() {
    for (int i = 0; i < 7; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + i * 100),
      );
      final slideAnimation = Tween<Offset>(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));
      _itemControllers.add(controller);
      _slideAnimations.add(slideAnimation);
      _fadeAnimations.add(fadeAnimation);
      controller.forward();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final headerHeight = height * 0.25;
    final imageHeight = height * 0.09;
    final imageWidth = width * 0.25;
    final vSpacingSmall = height * 0.015;
    final vSpacingMedium = height * 0.03;
    final fontSizeLarge = width * 0.045;
    final fontSizeSmall = width * 0.035;
    final elevation = width * 0.015;
    final borderRadiusRight = width * 0.04;
    final listPaddingV = height * 0.01;
    final listPaddingH = width * 0.03;
    final tileMarginH = width * 0.03;
    final tileMarginV = height * 0.008;
    final iconSize = width * 0.065;
    final contentPaddingH = width * 0.04;
    final contentPaddingV = height * 0.01;
    final borderWidth = width * 0.0025;
    final selectedOpacity = 0.15;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Drawer(
        elevation: elevation,
        backgroundColor: isDarkMode ? AppColors.darkBackgroundColor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(borderRadiusRight)),
        ),
        child: Column(
          children: [
            DrawerHeader(
              child: ScaleTransition(
                scale: _logoAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(borderRadiusRight * 0.3),
                        child: Image.asset(
                          'assets/images/qr_buddy_logo__1_-removebg-preview.png',
                          height: imageHeight,
                          width: imageWidth,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: vSpacingSmall),
                    Flexible(
                      child: Text(
                        userName ?? 'User',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isDarkMode ? AppColors.backgroundColor : AppColors.iconColor,
                              fontWeight: FontWeight.bold,
                              fontSize: fontSizeLarge,
                            ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'Welcome back!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDarkMode ? AppColors.backgroundColor : AppColors.iconColor,
                              fontSize: fontSizeSmall,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: listPaddingV),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildAnimatedTile(
                    index: 0,
                    icon: IconlyBold.home,
                    title: "Dashboard",
                    onTap: () {
                      drawerController.setIndex(0);
                      Get.offNamed(RoutesName.ticketDashboardView);
                    },
                  ),
                  _buildAnimatedTile(
                    index: 4,
                    icon: IconlyBold.plus,
                    title: "New eTicket",
                    onTap: () {
                      drawerController.setIndex(4);
                      Get.offNamed(RoutesName.newtTicketView);
                    },
                  ),
                  _buildAnimatedTile(
                    index: 5,
                    icon: IconlyBold.document,
                    title: "Daily Checklist",
                    onTap: () {
                      drawerController.setIndex(5);
                      Get.offNamed(RoutesName.dailyChecklistView);
                    },
                  ),
                  _buildAnimatedTile(
                    index: 6,
                    icon: IconlyBold.logout,
                    title: "Logout",
                    onTap: () async {
                      final authRepository = AuthRepository();
                      await authRepository.logout();
                      await TokenStorage().clearToken();
                      Get.offAllNamed(RoutesName.loginScreen);
                    },
                    iconColor: AppColors.dangerButtonColor,
                    textColor: AppColors.dangerButtonColor,
                  ),
                  SizedBox(height: vSpacingMedium * 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTile({
    required int index,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Color? tileColor,
    Color? iconColor,
    Color? textColor,
  }) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final tileMarginH = width * 0.03;
    final tileMarginV = height * 0.008;
    final borderRadius = width * 0.03;
    final iconSize = width * 0.065;
    final contentPaddingH = width * 0.04;
    final contentPaddingV = height * 0.01;
    final borderWidthSelected = width * 0.00375;
    final borderWidthNormal = width * 0.0025;
    final selectedColor = AppColors.primaryColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final selected = drawerController.selectedIndex.value == index;

      return SlideTransition(
        position: _slideAnimations[index],
        child: FadeTransition(
          opacity: _fadeAnimations[index],
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(horizontal: tileMarginH, vertical: tileMarginV),
            decoration: BoxDecoration(
              color: tileColor ??
                  (selected
                      ? selectedColor.withOpacity(0.15)
                      : (isDarkMode
                          ? AppColors.darkCardBackgroundColor
                          : AppColors.cardBackgroundColor)),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: selected
                    ? selectedColor
                    : (isDarkMode ? AppColors.darkBorderColor : AppColors.borderColor),
                width: selected ? borderWidthSelected : borderWidthNormal,
              ),
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
              contentPadding: EdgeInsets.symmetric(horizontal: contentPaddingH, vertical: contentPaddingV),
              leading: Icon(
                icon,
                color: iconColor ?? (selected ? selectedColor : (isDarkMode ? AppColors.darkTextColor : AppColors.textColor)),
                size: iconSize,
              ),
              title: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor ?? (selected ? selectedColor : (isDarkMode ? AppColors.darkTextColor : AppColors.textColor)),
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    ),
              ),
              subtitle: subtitle != null
                  ? Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
                          ),
                    )
                  : null,
              trailing: trailing,
              onTap: onTap,
            ),
          ),
        ),
      );
    });
  }
}