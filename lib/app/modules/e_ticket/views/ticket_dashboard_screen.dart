import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/core/widgets/custom_appbar.dart';
import 'package:qr_buddy/app/core/widgets/custom_drawer.dart';
import 'package:qr_buddy/app/modules/e_ticket/components/location_dialog.dart';
import 'package:qr_buddy/app/modules/e_ticket/components/qrbuddy_dashboard_widget.dart';
import 'package:qr_buddy/app/modules/e_ticket/components/ticket_card.dart';

import '../controllers/ticket_controller.dart';

class TicketDashboardScreen extends StatefulWidget {
  const TicketDashboardScreen({Key? key}) : super(key: key);

  @override
  State<TicketDashboardScreen> createState() => _TicketDashboardScreenState();
}

class _TicketDashboardScreenState extends State<TicketDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final TicketController controller = Get.put(TicketController());

    return Theme(
      data: AppTheme.theme,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: CustomAppBar(
          title: '',
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.hintTextColor),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          onStartShiftPressed: () {},
          onQrPressed: () {},
          onBrightnessPressed: () {},
          onLocationPressed: () {
            showDialog(context: context, builder: (context) => const LocationDialog());
          },
          onProfilePressed: () {},
        ),
        drawer: const CustomDrawer(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              qrbuddyDashboardWidget(),
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              //   child: Row(
              //     children: [
              //       Obx(() => FilterTab(
              //             label: 'New',
              //             count: 161,
              //             isSelected: controller.selectedFilter.value == 'New',
              //             onTap: () => controller.setFilter('New'),
              //           )),
              //       Obx(() => FilterTab(
              //             label: 'Assigned',
              //             count: 55,
              //             isSelected: controller.selectedFilter.value == 'Assigned',
              //             onTap: () => controller.setFilter('Assigned'),
              //           )),
              //       Obx(() => FilterTab(
              //             label: 'Accepted',
              //             count: 1,
              //             isSelected: controller.selectedFilter.value == 'Accepted',
              //             onTap: () => controller.setFilter('Accepted'),
              //           )),
              //       Obx(() => FilterTab(
              //             label: 'Completed',
              //             count: 62,
              //             isSelected: controller.selectedFilter.value == 'Completed',
              //             onTap: () => controller.setFilter('Completed'),
              //           )),
              //       Obx(() => FilterTab(
              //             label: 'Verified',
              //             count: 5,
              //             isSelected: controller.selectedFilter.value == 'Verified',
              //             onTap: () => controller.setFilter('Verified'),
              //           )),
              //       Obx(() => FilterTab(
              //             label: 'On Hold',
              //             count: 4,
              //             isSelected: controller.selectedFilter.value == 'On Hold',
              //             onTap: () => controller.setFilter('On Hold'),
              //           )),
              //       Obx(() => FilterTab(
              //             label: 'Re-Open',
              //             count: 2,
              //             isSelected: controller.selectedFilter.value == 'Re-Open',
              //             onTap: () => controller.setFilter('Re-Open'),
              //           )),
              //       Obx(() => FilterTab(
              //             label: 'Cancelled',
              //             count: 6,
              //             isSelected: controller.selectedFilter.value == 'Cancelled',
              //             onTap: () => controller.setFilter('Cancelled'),
              //           )),
              //       Obx(() => FilterTab(
              //             label: 'All',
              //             count: 200,
              //             isSelected: controller.selectedFilter.value == 'All',
              //             onTap: () => controller.setFilter('All'),
              //           )),
              //     ],
              //   ),
              // ),
              Obx(() {
                if (controller.selectedInfoCard.value == 'E-Tickets') {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = controller.tickets[index];
                      return Stack(
                        children: [
                          TicketCard(
                            index: index,
                            orderNumber: ticket.orderNumber,
                            description: ticket.description,
                            block: ticket.block,
                            status: ticket.status,
                            date: ticket.date,
                            department: ticket.department,
                            phoneNumber: ticket.phoneNumber,
                            assignedTo: ticket.assignedTo,
                            serviceLabel: ticket.serviceLabel,
                            isQuickRequest: ticket.isQuickRequest ?? false,
                            onTap: () => controller.navigateToDetail(ticket),
                          ),
                        ],
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.primaryColor,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}