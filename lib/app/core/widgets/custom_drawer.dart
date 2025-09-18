import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for SystemNavigator.pop
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/core/utils/snackbar.dart';
import 'package:qr_buddy/app/data/repo/auth_repo.dart';
import 'package:qr_buddy/app/routes/routes.dart';

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
  int? _hoveredIndex;

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        // Exit the app when the back button is pressed
        SystemNavigator.pop();
        return false; // Prevent default back navigation
      },
      child: Drawer(
        elevation: 6,
        backgroundColor: isDarkMode ? AppColors.darkBackgroundColor : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
        ),
        child: Column(
          children: [
            DrawerHeader(
              child: ScaleTransition(
                scale: _logoAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/qr_buddy_logo__1_-removebg-preview.png',
                        height: 70,
                        width: 100,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userName ?? 'User',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isDarkMode ? AppColors.backgroundColor : AppColors.iconColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Welcome back!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDarkMode ? AppColors.backgroundColor : AppColors.iconColor,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildAnimatedTile(
                    index: 0,
                    icon: IconlyBold.home,
                    title: "Dashboard",
                    onTap: () {
                      Get.offNamed(RoutesName.ticketDashboardView); // Changed to offNamed
                    },
                  ),
                  _buildAnimatedTile(
                    index: 1,
                    icon: IconlyBold.scan,
                    title: "QR Locator",
                    subtitle: "Search your location",
                    onTap: () {
                      CustomSnackbar.info("This Service is not implemented yet (Coming Soon)");
                    },
                  ),
                  _buildAnimatedTile(
                    index: 2,
                    icon: IconlyBold.work,
                    title: "Task Manager",
                    onTap: () {
                      CustomSnackbar.info("This Service is not implemented yet (Coming Soon)");
                    },
                  ),
                  _buildAnimatedTile(
                    index: 4,
                    icon: IconlyBold.plus,
                    title: "New eTicket",
                    onTap: () {
                      Get.offNamed(RoutesName.newtTicketView); // Changed to offNamed
                    },
                  ),
                  _buildAnimatedTile(
                    index: 5,
                    icon: IconlyBold.document,
                    title: "Daily Checklist",
                    onTap: () {
                      Get.offNamed(RoutesName.dailyChecklistView); // Changed to offNamed
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
                      Get.offAllNamed(RoutesName.loginScreen); // Kept offAllNamed for logout
                    },
                    iconColor: AppColors.dangerButtonColor,
                    textColor: AppColors.dangerButtonColor,
                  ),
                  const SizedBox(height: 24),
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
    bool selected = false,
    required VoidCallback onTap,
    Widget? trailing,
    Color? tileColor,
    Color? iconColor,
    Color? textColor,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimations[index],
      child: FadeTransition(
        opacity: _fadeAnimations[index],
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: tileColor ??
                (selected
                    ? AppColors.primaryColor.withOpacity(0.1)
                    : (isDarkMode
                        ? AppColors.darkCardBackgroundColor
                        : AppColors.cardBackgroundColor)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
                blurRadius: selected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Icon(
              icon,
              color: iconColor ??
                  (selected ? AppColors.primaryColor : (isDarkMode ? AppColors.darkTextColor : AppColors.textColor)),
              size: 26,
            ),
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor ??
                        (selected ? AppColors.primaryColor : (isDarkMode ? AppColors.darkTextColor : AppColors.textColor)),
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
  }
}