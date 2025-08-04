import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
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
  final TicketController controller = Get.put(TicketController());

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

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
          onQrPressed: () async {
            final result = await Get.toNamed('/qr-scan');
            if (result != null && result is String) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Scanned URL: $result')),
              );
            }
          },
          onBrightnessPressed: () {},
          onLocationPressed: () {
            showDialog(
              context: context,
              builder: (context) => const LocationDialog(),
            );
          },
          onProfilePressed: () {},
        ),
        drawer: const CustomDrawer(),
        body: FutureBuilder<String?>(
          future: TokenStorage().getUserType(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading user type'));
            }
            final userType = snapshot.data;

            return RefreshIndicator(
              color: AppColors.primaryColor,
              backgroundColor: AppColors.backgroundColor,
              onRefresh: () async {
                try {
                  await controller.fetchTickets();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error refreshing tickets: $e')),
                  );
                }
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
                            if (userType != 'S_TEAM') // Only show FilterTab for non-S_TEAM users
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Obx(() => Row(
                                      children: [
                                        FilterTab(
                                          label: 'All',
                                          count: controller.tickets.length,
                                          isSelected:
                                              controller.selectedFilter.value ==
                                                  'All',
                                          onTap: () =>
                                              controller.setFilter('All'),
                                        ),
                                        FilterTab(
                                          label: 'New',
                                          count: controller.links
                                              .firstWhere(
                                                (link) => link.type == 'NEW',
                                                orElse: () => Link(
                                                    type: 'NEW',
                                                    title: 'New',
                                                    count: 0),
                                              )
                                              .count,
                                          isSelected:
                                              controller.selectedFilter.value ==
                                                  'New',
                                          onTap: () =>
                                              controller.setFilter('New'),
                                        ),
                                        FilterTab(
                                          label: 'Assigned',
                                          count: controller.links
                                              .firstWhere(
                                                (link) => link.type == 'ASI',
                                                orElse: () => Link(
                                                    type: 'ASI',
                                                    title: 'Assigned',
                                                    count: 0),
                                              )
                                              .count,
                                          isSelected:
                                              controller.selectedFilter.value ==
                                                  'Assigned',
                                          onTap: () =>
                                              controller.setFilter('Assigned'),
                                        ),
                                        FilterTab(
                                          label: 'Accepted',
                                          count: controller.links
                                              .firstWhere(
                                                (link) => link.type == 'ACC',
                                                orElse: () => Link(
                                                    type: 'ACC',
                                                    title: 'Accepted',
                                                    count: 0),
                                              )
                                              .count,
                                          isSelected:
                                              controller.selectedFilter.value ==
                                                  'Accepted',
                                          onTap: () =>
                                              controller.setFilter('Accepted'),
                                        ),
                                        FilterTab(
                                          label: 'Completed',
                                          count: controller.links
                                              .firstWhere(
                                                (link) => link.type == 'COMP',
                                                orElse: () => Link(
                                                    type: 'COMP',
                                                    title: 'Completed',
                                                    count: 0),
                                              )
                                              .count,
                                          isSelected:
                                              controller.selectedFilter.value ==
                                                  'Completed',
                                          onTap: () =>
                                              controller.setFilter('Completed'),
                                        ),
                                        FilterTab(
                                          label: 'Verified',
                                          count: controller.links
                                              .firstWhere(
                                                (link) => link.type == 'VER',
                                                orElse: () => Link(
                                                    type: 'VER',
                                                    title: 'Verified',
                                                    count: 0),
                                              )
                                              .count,
                                          isSelected:
                                              controller.selectedFilter.value ==
                                                  'Verified',
                                          onTap: () =>
                                              controller.setFilter('Verified'),
                                        ),
                                        FilterTab(
                                          label: 'On Hold',
                                          count: controller.links
                                              .firstWhere(
                                                (link) => link.type == 'HOLD',
                                                orElse: () => Link(
                                                    type: 'HOLD',
                                                    title: 'On-Hold',
                                                    count: 0),
                                              )
                                              .count,
                                          isSelected:
                                              controller.selectedFilter.value ==
                                                  'On Hold',
                                          onTap: () =>
                                              controller.setFilter('On Hold'),
                                        ),
                                        FilterTab(
                                          label: 'Re-Open',
                                          count: controller.links
                                              .firstWhere(
                                                (link) => link.type == 'REO',
                                                orElse: () => Link(
                                                    type: 'REO',
                                                    title: 'Re-Open',
                                                    count: 0),
                                              )
                                              .count,
                                          isSelected:
                                              controller.selectedFilter.value ==
                                                  'Re-Open',
                                          onTap: () =>
                                              controller.setFilter('Re-Open'),
                                        ),
                                        FilterTab(
                                          label: 'Cancelled',
                                          count: controller.links
                                              .firstWhere(
                                                (link) => link.type == 'CAN',
                                                orElse: () => Link(
                                                    type: 'CAN',
                                                    title: 'Canceled',
                                                    count: 0),
                                              )
                                              .count,
                                          isSelected:
                                              controller.selectedFilter.value ==
                                                  'Cancelled',
                                          onTap: () =>
                                              controller.setFilter('Cancelled'),
                                        ),
                                      ],
                                    )),
                              ),
                            Obx(() => ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.filteredTickets.length,
                                  itemBuilder: (context, index) {
                                    final ticket =
                                        controller.filteredTickets[index];
                                    return TicketCard(
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
                                      isQuickRequest:
                                          ticket.isQuickRequest ?? false,
                                      uuid: ticket.uuid,
                                      onTap: () =>
                                          controller.navigateToDetail(ticket),
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
            );
          },
        ),
      ),
    );
  }
}