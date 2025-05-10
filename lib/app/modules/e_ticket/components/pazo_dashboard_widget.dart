import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/modules/e_ticket/components/info_card_widget.dart';

import '../controllers/ticket_controller.dart';

class qrbuddyDashboardWidget extends StatefulWidget {
  const qrbuddyDashboardWidget({super.key});

  @override
  State<qrbuddyDashboardWidget> createState() => _qrbuddyDashboardWidgetState();
}

class _qrbuddyDashboardWidgetState extends State<qrbuddyDashboardWidget> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    final double horizontalPadding = size.width * 0.04;
    final double verticalPadding = size.height * 0.01;

    return Container(
      color: Colors.grey[100],
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTodaysStatusSection(size, textTheme),
            SizedBox(height: verticalPadding * 1.7),
            _buildInfoGrid(size, textTheme),
            _buildBottomTabs(size, textTheme),
            const SizedBox(height: 20),
            Obx(() {
              if (controller.selectedInfoCard.value.isNotEmpty) {
                return InfoCardContentWidget();
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysStatusSection(Size size, TextTheme textTheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: size.height * 0.015),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
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
                    valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(statusValue)),
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
          "Daily Tasks",
          controller.tasksCount.value.toString(),
          Icons.flag_outlined,
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
          _getLineColor(controller.missed.value),
        ),
        _infoCard(
          "Avg TAT",
          controller.reviewPending.value.toString(),
          Icons.timer_outlined,
          size,
          textTheme,
          _getLineColor(controller.reviewPending.value),
        ),
      ],
    ));
  }

  Widget _infoCard(String title, String count, IconData icon, Size size, TextTheme textTheme, Color accentColor) {
    return Obx(() {
      bool isSelected = controller.selectedInfoCard.value == title;
      return GestureDetector(
        onTap: () {
          controller.setSelectedInfoCard(isSelected ? '' : title);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03, vertical: size.height * 0.005),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: AppColors.primaryColor, width: 5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
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
                      fontSize: (textTheme.headlineSmall?.fontSize ?? 24) * 0.9,
                      color: isSelected ? AppColors.primaryColor : AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    icon,
                    color: isSelected ? AppColors.primaryColor : AppColors.primaryColor,
                    size: size.width * 0.05,
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.003),
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  color: isSelected ? AppColors.primaryColor : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBottomTabs(Size size, TextTheme textTheme) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.006),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
          children: [
            SizedBox(width: size.width * 0.01),
            _bottomTabItem(controller.tickets.length.toString(), "Total", 0, size, textTheme),
            _bottomTabItem(controller.filteredTickets.where((t) => t.status == 'Accepted').length.toString(), "Completed", 1, size, textTheme),
            _bottomTabItem(controller.filteredTickets.where((t) => t.status == 'Missed').length.toString(), "Missed", 2, size, textTheme),
            _bottomTabItem(controller.filteredTickets.where((t) => t.status == 'Assigned').length.toString(), "Pending", 3, size, textTheme),
            SizedBox(width: size.width * 0.02),
          ],
        )),
      ),
    );
  }

  Widget _bottomTabItem(String count, String title, int index, Size size, TextTheme textTheme) {
    bool isActive = _selectedBottomTabIndex == index;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.015),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedBottomTabIndex = index;
            controller.updateTicketList(index);
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Chip(
          backgroundColor: isActive ? AppColors.primaryColor.withOpacity(0.15) : Colors.grey.shade200,
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.02, vertical: size.height * 0.005),
          label: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: textTheme.bodySmall?.copyWith(
                  color: isActive ? AppColors.primaryColor : AppColors.textColor.withOpacity(0.8),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: size.height * 0.003),
              Text(
                count,
                style: textTheme.bodyMedium?.copyWith(
                  color: isActive ? AppColors.primaryColor : AppColors.textColor.withOpacity(0.8),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          side: BorderSide(
            color: isActive ? AppColors.primaryColor : Colors.transparent,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}