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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    final double horizontalPadding = size.width * 0.04;
    final double verticalPadding = size.height * 0.01;

    return Container(
      color: AppColors.backgroundColor,
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section (Today's Status)
            _buildTodaysStatusSection(size, textTheme),
            SizedBox(height: verticalPadding * 2),

            // Info Grid Section
            _buildInfoGrid(size, textTheme),

            // Expandable Content Section
            Obx(() {
              if (controller.selectedInfoCard.value == 'Rating') {
                final double avgRating =
                    controller.getAverageRatingForCompleted();
                final int fullStars = avgRating.floor();
                final bool hasHalfStar = avgRating - fullStars >= 0.5;
                final double totalPendingReviews =
                    controller.reviewPending.value;
                final String status = getRatingName(controller
                    .averageRating.value); // Get status based on average rating

                return Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(top: 12.0),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rating (Pending: $totalPendingReviews)',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Divider(color: AppColors.borderColor, thickness: 1),
                      const SizedBox(height: 10),

                      // ⭐ Star Display
                      Row(
                        children: List.generate(5, (index) {
                          if (index < fullStars) {
                            return const Icon(Icons.star,
                                color: Colors.orange, size: 24);
                          } else if (index == fullStars && hasHalfStar) {
                            return const Icon(Icons.star_half,
                                color: Colors.orange, size: 24);
                          } else {
                            return const Icon(Icons.star_border,
                                color: Colors.orange, size: 24);
                          }
                        }),
                      ),

                      const SizedBox(height: 8),
                      Text(
                        '${controller.averageRating.value.toStringAsFixed(1)} star',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status: $status',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: _getStatusColor(controller
                                      .averageRating.value *
                                  20), // Map rating to percentage-like color
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // 📊 Rating Details
                      Text(
                        'Details:',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('5 - Champion'),
                      const Text('4.5 - 4.9  → Super Hero'),
                      const Text('4 - 4.5   → Hero'),
                      const Text('3 - 4     → General'),
                      const Text('1 - 3     → Beginner'),
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

  Widget _buildTodaysStatusSection(Size size, TextTheme textTheme) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04, vertical: size.height * 0.015),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
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
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "${statusValue.toStringAsFixed(0)}%",
                  style: textTheme.titleMedium?.copyWith(
                    color: _getStatusColor(statusValue),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.008),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (statusValue / 100) * _progressAnimation.value,
                    minHeight: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        _getStatusColor(statusValue)),
                    backgroundColor: AppColors.backgroundColor.withOpacity(0.3),
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInfoGrid(Size size, TextTheme textTheme) {
    return Obx(() => GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: size.width * 0.03,
          mainAxisSpacing: size.height * 0.012,
          childAspectRatio: 2.2,
          children: [
            _infoCard(
              "Food Delivery",
              controller.tasksCount.value.toString(),
              Icons.local_dining,
              size,
              textTheme,
              _getLineColor(controller.tasksCount.value),
            ),
            _infoCard(
              "E-Tickets",
              controller.tickets.length.toString(),
              Icons.sticky_note_2_outlined,
              size,
              textTheme,
              _getLineColor(controller.tickets.length),
            ),
            _infoCard(
              "Checklists",
              controller.missed.value.toString(),
              Icons.checklist_rtl_outlined,
              size,
              textTheme,
             isDisabled: true,
              _getLineColor(controller.missed.value),
            ),
            _infoCard(
              "Rating",
              controller.averageRating.value
                  .toStringAsFixed(1), // Show average rating
              Icons.star,
              size,
              textTheme,
              _getLineColor(controller.averageRating.value.toInt()),
            ),
          ],
        ));
  }

  Widget _infoCard(String title, String count, IconData icon, Size size,
      TextTheme textTheme, Color accentColor,
      {bool isDisabled = false}) {
    return Obx(() {
      bool isSelected = controller.selectedInfoCard.value == title;
      return GestureDetector(
        onTap: isDisabled
            ? null
            : () {
                controller.setSelectedInfoCard(isSelected ? '' : title);
              },
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.03, vertical: size.height * 0.005),
          decoration: BoxDecoration(
            color: isDisabled
                ? Colors.grey[300]
                : isSelected
                    ? AppColors.primaryColor.withOpacity(0.1)
                    : AppColors.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border(
                left: BorderSide(
                    color:
                        isDisabled ? Colors.grey[400]! : AppColors.primaryColor,
                    width: 5)),
            boxShadow: [
              BoxShadow(
                color: isDisabled
                    ? Colors.grey.withOpacity(0.1)
                    : AppColors.shadowColor,
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
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
                      Text(
                        count,
                        style: textTheme.headlineSmall?.copyWith(
                          fontSize:
                              (textTheme.headlineSmall?.fontSize ?? 24) * 0.9,
                          color: isDisabled
                              ? Colors.grey[500]
                              : isSelected
                                  ? AppColors.primaryColor
                                  : AppColors.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: size.height * 0.03),
                        child: Icon(
                          icon,
                          color: isDisabled
                              ? Colors.grey[500]
                              : isSelected
                                  ? AppColors.primaryColor
                                  : AppColors.textColor,
                          size: size.width * 0.05,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.003),
                  Text(
                    title,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isDisabled
                          ? Colors.grey[500]
                          : isSelected
                              ? AppColors.primaryColor
                              : AppColors.subtitleColor,
                      fontWeight: FontWeight.w500,
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
                    padding: EdgeInsets.all(size.width * 0.01),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock,
                      size: size.width * 0.04,
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

  Widget _bottomTabItem(
      String count, String title, int index, Size size, TextTheme textTheme) {
    bool isActive = _selectedBottomTabIndex == index;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.015),
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
              : AppColors.cardBackgroundColor,
          padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.02, vertical: size.height * 0.005),
          label: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: textTheme.bodySmall?.copyWith(
                  color: isActive
                      ? AppColors.primaryColor
                      : AppColors.subtitleColor,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: size.height * 0.003),
              Text(
                count,
                style: textTheme.bodyMedium?.copyWith(
                  color: isActive
                      ? AppColors.primaryColor
                      : AppColors.subtitleColor,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          side: BorderSide(
            color: isActive ? AppColors.primaryColor : AppColors.borderColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
