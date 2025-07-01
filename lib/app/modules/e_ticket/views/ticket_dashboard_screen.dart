import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/core/widgets/custom_appbar.dart';
import 'package:qr_buddy/app/core/widgets/custom_drawer.dart';
import 'package:qr_buddy/app/data/models/e_tickets.dart';
import 'package:qr_buddy/app/modules/e_ticket/components/filter_tab.dart';
import 'package:qr_buddy/app/modules/e_ticket/components/location_dialog.dart';
import 'package:qr_buddy/app/modules/e_ticket/components/qrbuddy_dashboard_widget.dart';
import 'package:qr_buddy/app/modules/e_ticket/components/ticket_card.dart';
import 'package:qr_buddy/app/modules/e_ticket/controllers/ticket_controller.dart';

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
          onQrPressed: () {},
          onBrightnessPressed: () {},
          onLocationPressed: () {
            showDialog(context: context, builder: (context) => const LocationDialog());
          },
          onProfilePressed: () {},
        ),
        drawer: const CustomDrawer(),
        body: RefreshIndicator(
          color: AppColors.primaryColor,
          backgroundColor: AppColors.backgroundColor,
          onRefresh: () async {
            await controller.fetchTickets();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                qrbuddyDashboardWidget(),
                Obx(() {
                  if (controller.selectedInfoCard.value == 'E-Tickets') {
                    return Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Obx(() => FilterTab(
                                    label: 'New',
                                    count: controller.links.firstWhere(
                                      (link) => link.type == 'NEW',
                                      orElse: () => Link(type: 'NEW', title: 'New', count: 0),
                                    ).count,
                                    isSelected: controller.selectedFilter.value == 'New',
                                    onTap: () => controller.setFilter('New'),
                                  )),
                              Obx(() => FilterTab(
                                    label: 'Assigned',
                                    count: controller.links.firstWhere(
                                      (link) => link.type == 'ASI',
                                      orElse: () => Link(type: 'ASI', title: 'Assigned', count: 0),
                                    ).count,
                                    isSelected: controller.selectedFilter.value == 'Assigned',
                                    onTap: () => controller.setFilter('Assigned'),
                                  )),
                              Obx(() => FilterTab(
                                    label: 'Accepted',
                                    count: controller.links.firstWhere(
                                      (link) => link.type == 'ACC',
                                      orElse: () => Link(type: 'ACC', title: 'Accepted', count: 0),
                                    ).count,
                                    isSelected: controller.selectedFilter.value == 'Accepted',
                                    onTap: () => controller.setFilter('Accepted'),
                                  )),
                              Obx(() => FilterTab(
                                    label: 'Completed',
                                    count: controller.links.firstWhere(
                                      (link) => link.type == 'COMP',
                                      orElse: () => Link(type: 'COMP', title: 'Completed', count: 0),
                                    ).count,
                                    isSelected: controller.selectedFilter.value == 'Completed',
                                    onTap: () => controller.setFilter('Completed'),
                                  )),
                              Obx(() => FilterTab(
                                    label: 'Verified',
                                    count: controller.links.firstWhere(
                                      (link) => link.type == 'VER',
                                      orElse: () => Link(type: 'VER', title: 'Verified', count: 0),
                                    ).count,
                                    isSelected: controller.selectedFilter.value == 'Verified',
                                    onTap: () => controller.setFilter('Verified'),
                                  )),
                              Obx(() => FilterTab(
                                    label: 'On Hold',
                                    count: controller.links.firstWhere(
                                      (link) => link.type == 'HOLD',
                                      orElse: () => Link(type: 'HOLD', title: 'On-Hold', count: 0),
                                    ).count,
                                    isSelected: controller.selectedFilter.value == 'On Hold',
                                    onTap: () => controller.setFilter('On Hold'),
                                  )),
                              Obx(() => FilterTab(
                                    label: 'Re-Open',
                                    count: controller.links.firstWhere(
                                      (link) => link.type == 'REO',
                                      orElse: () => Link(type: 'REO', title: 'Re-Open', count: 0),
                                    ).count,
                                    isSelected: controller.selectedFilter.value == 'Re-Open',
                                    onTap: () => controller.setFilter('Re-Open'),
                                  )),
                              Obx(() => FilterTab(
                                    label: 'Cancelled',
                                    count: controller.links.firstWhere(
                                      (link) => link.type == 'CAN',
                                      orElse: () => Link(type: 'CAN', title: 'Canceled', count: 0),
                                    ).count,
                                    isSelected: controller.selectedFilter.value == 'Cancelled',
                                    onTap: () => controller.setFilter('Cancelled'),
                                  )),
                              Obx(() => FilterTab(
                                    label: 'All',
                                    count: controller.links.firstWhere(
                                      (link) => link.type == 'ALL',
                                      orElse: () => Link(type: 'ALL', title: 'All', count: controller.tickets.length),
                                    ).count,
                                    isSelected: controller.selectedFilter.value == 'All',
                                    onTap: () => controller.setFilter('All'),
                                  )),
                            ],
                          ),
                        ),
                        Obx(() => ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.filteredTickets.length,
                              itemBuilder: (context, index) {
                                final ticket = controller.filteredTickets[index];
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
                                      uuid: ticket.uuid,
                                      onTap: () => controller.navigateToDetail(ticket),
                                    ),
                                  ],
                                );
                              },
                            )),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
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