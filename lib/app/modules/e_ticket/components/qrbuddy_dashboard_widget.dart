import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/modules/e_ticket/components/info_card_widget.dart';
import 'package:qr_buddy/app/modules/e_ticket/controllers/ticket_controller.dart';

class qrbuddyDashboardWidget extends StatefulWidget {
  const qrbuddyDashboardWidget({super.key});

  @override
  State<qrbuddyDashboardWidget> createState() => _qrbuddyDashboardWidgetState();
}

class _qrbuddyDashboardWidgetState extends State<qrbuddyDashboardWidget>
    with SingleTickerProviderStateMixin {
  final TicketController controller = Get.put(TicketController());
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  int _selectedBottomTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Defer setting default selected tab to after first frame to avoid build-phase update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setSelectedInfoCard('E-Tickets');
    });
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStatusColor(double percentage) {
    if (percentage >= 80) return Colors.green.shade500;
    if (percentage >= 50) return AppColors.primaryColor;
    return Colors.red.shade500;
  }

  Color _getLineColor(int value) {
    if (value <= 10) return Colors.green.shade400;
    if (value <= 30) return Colors.yellow.shade600;
    if (value <= 60) return Colors.orange.shade400;
    return Colors.red.shade400;
  }

  String getRatingName(double avgRating) {
    if (avgRating == 5.0) return 'Champions';
    if (avgRating >= 4.5 && avgRating < 5.0) return 'SuperHero';
    if (avgRating >= 4.0 && avgRating < 4.5) return 'Hero';
    if (avgRating >= 3.0 && avgRating < 4.0) return 'General';
    if (avgRating >= 1.0 && avgRating < 3.0) return 'Beginner';
    return 'Poor';
  }

  bool _isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  double _getScaledValue(double baseValue, {double smallScreenMultiplier = 0.8}) {
    final width = MediaQuery.of(context).size.width;
    return width < 360 ? baseValue * smallScreenMultiplier : baseValue;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;
    final bool isSmall = _isSmallScreen(context);

    final double horizontalPadding = _getScaledValue(size.width * 0.04);
    final double verticalPadding = _getScaledValue(size.height * 0.01);

    final double smallFontScale = isSmall ? 0.85 : 1.0;
    final double smallIconScale = isSmall ? 0.9 : 1.0;

    return Container(
      color: isDarkMode ? AppColors.darkBackgroundColor : AppColors.backgroundColor,
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTodaysStatusSection(size, textTheme, isSmall, smallFontScale),
            SizedBox(height: verticalPadding * 2),
            _buildInfoGrid(size, textTheme, isSmall, smallIconScale),
            Obx(() {
              if (controller.selectedInfoCard.value == 'Rating') {
                final double avgRating = controller.getAverageRatingForCompleted();
                final int fullStars = avgRating.floor();
                final bool hasHalfStar = avgRating - fullStars >= 0.5;
                final double totalPendingReviews = controller.reviewPending.value;
                final String status = getRatingName(controller.averageRating.value);

                return Container(
                  padding: EdgeInsets.all(_getScaledValue(size.width * 0.04)),
                  margin: EdgeInsets.only(top: _getScaledValue(size.height * 0.015)),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rating (Pending: $totalPendingReviews)',
                        style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                              fontSize: (textTheme.titleSmall?.fontSize ?? 16) * smallFontScale,
                            ),
                      ),
                      Divider(
                        color: isDarkMode ? AppColors.darkBorderColor : AppColors.borderColor,
                        thickness: 1,
                      ),
                      SizedBox(height: _getScaledValue(size.height * 0.012)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          if (index < fullStars) {
                            return Icon(Icons.star, color: Colors.orange, size: _getScaledValue(size.width * 0.065));
                          } else if (index == fullStars && hasHalfStar) {
                            return Icon(Icons.star_half, color: Colors.orange, size: _getScaledValue(size.width * 0.065));
                          } else {
                            return Icon(Icons.star_border, color: Colors.orange, size: _getScaledValue(size.width * 0.065));
                          }
                        }),
                      ),
                      SizedBox(height: _getScaledValue(size.height * 0.01)),
                      Text(
                        '${controller.averageRating.value.toStringAsFixed(1)} star',
                        style: textTheme.headlineSmall?.copyWith(
                              color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                              fontSize: (textTheme.headlineSmall?.fontSize ?? 24) * smallFontScale,
                            ),
                      ),
                      SizedBox(height: _getScaledValue(size.height * 0.01)),
                      Text(
                        'Status: $status',
                        style: textTheme.bodyLarge?.copyWith(
                              color: _getStatusColor(controller.averageRating.value * 20),
                              fontWeight: FontWeight.bold,
                              fontSize: (textTheme.bodyLarge?.fontSize ?? 16) * smallFontScale,
                            ),
                      ),
                      SizedBox(height: _getScaledValue(size.height * 0.02)),
                      Text(
                        'Details:',
                        style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                              fontSize: (textTheme.bodyLarge?.fontSize ?? 16) * smallFontScale,
                            ),
                      ),
                      SizedBox(height: _getScaledValue(size.height * 0.01)),
                      _buildRatingDetailRow('5 - Champion', textTheme, isDarkMode, smallFontScale),
                      _buildRatingDetailRow('4.5 - 4.9  → Super Hero', textTheme, isDarkMode, smallFontScale),
                      _buildRatingDetailRow('4 - 4.5   → Hero', textTheme, isDarkMode, smallFontScale),
                      _buildRatingDetailRow('3 - 4     → General', textTheme, isDarkMode, smallFontScale),
                      _buildRatingDetailRow('1 - 3     → Beginner', textTheme, isDarkMode, smallFontScale),
                    ],
                  ),
                );
              } else if (controller.selectedInfoCard.value.isNotEmpty) {
                return InfoCardContentWidget();
              }
              return const SizedBox.shrink();
            }),
            SizedBox(height: verticalPadding * 2),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDetailRow(String text, TextTheme textTheme, bool isDarkMode, double smallFontScale) {
    return Padding(
      padding: EdgeInsets.only(bottom: _getScaledValue(MediaQuery.of(context).size.height * 0.005)),
      child: Text(
        text,
        style: textTheme.bodyMedium?.copyWith(
              color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
              fontSize: (textTheme.bodyMedium?.fontSize ?? 14) * smallFontScale,
            ),
      ),
    );
  }

  Widget _buildTodaysStatusSection(Size size, TextTheme textTheme, bool isSmall, double smallFontScale) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: _getScaledValue(size.width * 0.04), vertical: _getScaledValue(size.height * 0.015)),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() {
        double statusValue = controller.todayStatus.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Status",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                    fontSize: (textTheme.titleMedium?.fontSize ?? 18) * smallFontScale,
                  ),
                ),
                Text(
                  "${statusValue.toStringAsFixed(0)}%",
                  style: textTheme.titleMedium?.copyWith(
                    color: _getStatusColor(statusValue),
                    fontWeight: FontWeight.bold,
                    fontSize: (textTheme.titleMedium?.fontSize ?? 18) * smallFontScale,
                  ),
                ),
              ],
            ),
            SizedBox(height: _getScaledValue(size.height * 0.008)),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (statusValue / 100) * _progressAnimation.value,
                    minHeight: _getScaledValue(size.height * 0.008),
                    valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(statusValue)),
                    backgroundColor: isDarkMode
                        ? AppColors.darkBackgroundColor.withOpacity(0.3)
                        : AppColors.backgroundColor.withOpacity(0.3),
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInfoGrid(Size size, TextTheme textTheme, bool isSmall, double smallIconScale) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final double childAspectRatio = isSmall ? 1.5 : (size.width < 360 ? 1.8 : 2.2);
    final double crossSpacing = _getScaledValue(size.width * 0.03);
    final double mainSpacing = _getScaledValue(size.height * 0.012);
    return Obx(() => GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: crossSpacing,
          mainAxisSpacing: mainSpacing,
          childAspectRatio: childAspectRatio,
          children: [
            _infoCard(
              "Food Delivery",
              controller.tasksCount.value.toString(),
              Icons.local_dining,
              size,
              textTheme,
              _getLineColor(controller.tasksCount.value),
              isSmall: isSmall,
              smallIconScale: smallIconScale,
            ),
            _infoCard(
              "E-Tickets",
              controller.tickets.length.toString(),
              Icons.sticky_note_2_outlined,
              size,
              textTheme,
              _getLineColor(controller.tickets.length),
              isSmall: isSmall,
              smallIconScale: smallIconScale,
            ),
            _infoCard(
              "Checklists",
              controller.logEntriesCount.value.toString(),
              Icons.checklist_rtl_outlined,
              size,
              textTheme,
              _getLineColor(controller.logEntriesCount.value),
              isSmall: isSmall,
              smallIconScale: smallIconScale,
            ),
            _infoCard(
              "Rating",
              controller.averageRating.value.toStringAsFixed(1),
              Icons.star,
              size,
              textTheme,
              _getLineColor(controller.averageRating.value.toInt()),
              isSmall: isSmall,
              smallIconScale: smallIconScale,
            ),
          ],
        ));
  }

  Widget _infoCard(
      String title, String count, IconData icon, Size size, TextTheme textTheme, Color accentColor,
      {bool isDisabled = false, required bool isSmall, required double smallIconScale}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final double cardHorizontalPadding = _getScaledValue(size.width * 0.03);
    final double cardVerticalPadding = _getScaledValue(size.height * 0.005);
    final double countFontSize = _getScaledValue((textTheme.headlineSmall?.fontSize ?? 24) * 0.9);
    final double iconSizeValue = _getScaledValue(size.width * 0.05 * smallIconScale);
    final double titleFontSize = _getScaledValue((textTheme.bodyMedium?.fontSize ?? 14));
    return Obx(() {
      bool isSelected = controller.selectedInfoCard.value == title;
      return GestureDetector(
        onTap: isDisabled
            ? null
            : () {
                // Only change selection if a different tab is tapped
                if (!isSelected) {
                  controller.setSelectedInfoCard(title);
                }
              },
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: cardHorizontalPadding, vertical: cardVerticalPadding),
          decoration: BoxDecoration(
            color: isDisabled
                ? (isDarkMode ? Colors.grey[700] : Colors.grey[300])
                : isSelected
                    ? AppColors.primaryColor.withOpacity(0.1)
                    : (isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor),
            borderRadius: BorderRadius.circular(12),
            border: Border(
                left: BorderSide(
                    color: isDisabled
                        ? (isDarkMode ? Colors.grey[600]! : Colors.grey[400]!)
                        : AppColors.primaryColor,
                    width: 5)),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          count,
                          style: textTheme.headlineSmall?.copyWith(
                            fontSize: countFontSize,
                            color: isDisabled
                                ? (isDarkMode ? Colors.grey[400] : Colors.grey[500])
                                : isSelected
                                    ? AppColors.primaryColor
                                    : (isDarkMode ? AppColors.darkTextColor : AppColors.textColor),
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: _getScaledValue(size.height * 0.03)),
                        child: Icon(
                          icon,
                          color: isDisabled
                              ? (isDarkMode ? Colors.grey[400] : Colors.grey[500])
                              : isSelected
                                  ? AppColors.primaryColor
                                  : (isDarkMode ? AppColors.darkTextColor : AppColors.textColor),
                          size: iconSizeValue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _getScaledValue(size.height * 0.003)),
                  Text(
                    title,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isDisabled
                          ? (isDarkMode ? Colors.grey[400] : Colors.grey[500])
                          : isSelected
                              ? AppColors.primaryColor
                              : (isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor),
                      fontWeight: FontWeight.w500,
                      fontSize: titleFontSize,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (isDisabled)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(_getScaledValue(size.width * 0.01)),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock,
                      size: _getScaledValue(size.width * 0.04),
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _bottomTabItem(String count, String title, int index, Size size, TextTheme textTheme) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    bool isActive = _selectedBottomTabIndex == index;
    final double tabPaddingH = _getScaledValue(size.width * 0.015);
    final double tabPaddingV = _getScaledValue(size.height * 0.005);
    final double tabFontSize = _getScaledValue((textTheme.bodySmall?.fontSize ?? 12));
    final double countFontSize = _getScaledValue((textTheme.bodyMedium?.fontSize ?? 14));
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tabPaddingH),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedBottomTabIndex = index;
            controller.setFilter(title);
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Chip(
          backgroundColor: isActive
              ? AppColors.primaryColor.withOpacity(0.15)
              : (isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor),
          padding: EdgeInsets.symmetric(
              horizontal: _getScaledValue(size.width * 0.02), vertical: tabPaddingV),
          label: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: textTheme.bodySmall?.copyWith(
                  color: isActive
                      ? AppColors.primaryColor
                      : (isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: tabFontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: _getScaledValue(size.height * 0.003)),
              Text(
                count,
                style: textTheme.bodyMedium?.copyWith(
                  color: isActive
                      ? AppColors.primaryColor
                      : (isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: countFontSize,
                ),
              ),
            ],
          ),
          side: BorderSide(
            color: isActive
                ? AppColors.primaryColor
                : (isDarkMode ? AppColors.darkBorderColor : AppColors.borderColor),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}