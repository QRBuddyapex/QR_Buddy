
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
import 'package:shimmer/shimmer.dart';

class TicketDashboardScreen extends StatefulWidget {
  const TicketDashboardScreen({Key? key}) : super(key: key);

  @override
  State<TicketDashboardScreen> createState() => _TicketDashboardScreenState();
}

class _TicketDashboardScreenState extends State<TicketDashboardScreen> {
  final TicketController controller = Get.put(TicketController());
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await controller.fetchTickets();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: '',
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        onQrPressed: () async {
          final result = await Get.toNamed('/qr-scan');
          if (result != null && result is String) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Scanned URL: $result',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
                backgroundColor: AppColors.primaryColor.withOpacity(0.9),
              ),
            );
          }
        },
        onLocationPressed: () {
          showDialog(
            context: context,
            builder: (context) => const LocationDialog(),
          );
        },
        onProfilePressed: () {},
      ),
      drawer: const CustomDrawer(),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              if (_isLoading)
                _buildSkeletonLayout()
              else
                qrbuddyDashboardWidget(),
              Obx(() {
                if (controller.selectedInfoCard.value == 'E-Tickets' && !_isLoading) {
                  return Column(
                    children: [
                      if (TokenStorage().getUserType() != 'S_TEAM')
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Obx(() => Row(
                                children: [
                                  FilterTab(
                                    label: 'All',
                                    count: controller.tickets.length,
                                    isSelected: controller.selectedFilter.value == 'All',
                                    onTap: () => controller.setFilter('All'),
                                  ),
                                  FilterTab(
                                    label: 'New',
                                    count: controller.links.firstWhere(
                                          (link) => link.type == 'NEW',
                                          orElse: () => Link(type: 'NEW', title: 'New', count: 0),
                                    ).count,
                                    isSelected: controller.selectedFilter.value == 'New',
                                    onTap: () => controller.setFilter('New'),
                                  ),
                                  FilterTab(
                                    label: 'Assigned',
                                    count: controller.links.firstWhere(
                                          (link) => link.type == 'ASI',
                                          orElse: () => Link(type: 'ASI', title: 'Assigned', count: 0),
                                    ).count,
                                    isSelected: controller.selectedFilter.value == 'Assigned',
                                    onTap: () => controller.setFilter('Assigned'),
                                  ),
                                  FilterTab(
                                    label: 'Accepted',
                                    count: controller.links.firstWhere(
                                          (link) => link.type == 'ACC',
                                          orElse: () => Link(type: 'ACC', title: 'Accepted', count: 0),
                                    ).count,
                                    isSelected: controller.selectedFilter.value == 'Accepted',
                                    onTap: () => controller.setFilter('Accepted'),
                                  ),
                                  FilterTab(
                                    label: 'Completed',
                                    count: controller.links.firstWhere(
                                          (link) => link.type == 'COMP',
                                          orElse: () => Link(type: 'COMP', title: 'Completed', count: 0),
                                    ).count,
                                    isSelected: controller.selectedFilter.value == 'Completed',
                                    onTap: () => controller.setFilter('Completed'),
                                  ),
                                  FilterTab(
                                    label: 'Verified',
                                    count: controller.links.firstWhere(
                                          (link) => link.type == 'VER',
                                          orElse: () => Link(type: 'VER', title: 'Verified', count: 0),
                                    ).count,
                                    isSelected: controller.selectedFilter.value == 'Verified',
                                    onTap: () => controller.setFilter('Verified'),
                                  ),
                                  FilterTab(
                                    label: 'On Hold',
                                    count: controller.links.firstWhere(
                                          (link) => link.type == 'HOLD',
                                          orElse: () => Link(type: 'HOLD', title: 'On-Hold', count: 0),
                                    ).count,
                                    isSelected: controller.selectedFilter.value == 'On Hold',
                                    onTap: () => controller.setFilter('On Hold'),
                                  ),
                                  FilterTab(
                                    label: 'Re-Open',
                                    count: controller.links.firstWhere(
                                          (link) => link.type == 'REO',
                                          orElse: () => Link(type: 'REO', title: 'Re-Open', count: 0),
                                    ).count,
                                    isSelected: controller.selectedFilter.value == 'Re-Open',
                                    onTap: () => controller.setFilter('Re-Open'),
                                  ),
                                  FilterTab(
                                    label: 'Cancelled',
                                    count: controller.links.firstWhere(
                                          (link) => link.type == 'CAN',
                                          orElse: () => Link(type: 'CAN', title: 'Canceled', count: 0),
                                    ).count,
                                    isSelected: controller.selectedFilter.value == 'Cancelled',
                                    onTap: () => controller.setFilter('Cancelled'),
                                  ),
                                ],
                              )),
                        ),
                      Obx(() => ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.filteredTickets.length,
                            itemBuilder: (context, index) {
                              final ticket = controller.filteredTickets[index];
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
                                isQuickRequest: ticket.isQuickRequest ?? false,
                                uuid: ticket.uuid,
                                onTap: () => controller.navigateToDetail(ticket),
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
    );
  }

  Widget _buildSkeletonLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkBorderColor
                : AppColors.borderColor,
            highlightColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkCardBackgroundColor
                : AppColors.cardBackgroundColor,
            child: Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCardBackgroundColor
                    : AppColors.cardBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: List.generate(
              4,
              (index) => Shimmer.fromColors(
                baseColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBorderColor
                    : AppColors.borderColor,
                highlightColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCardBackgroundColor
                    : AppColors.cardBackgroundColor,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkCardBackgroundColor
                        : AppColors.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkBorderColor
                : AppColors.borderColor,
            highlightColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkCardBackgroundColor
                : AppColors.cardBackgroundColor,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCardBackgroundColor
                    : AppColors.cardBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) => Shimmer.fromColors(
              baseColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkBorderColor
                  : AppColors.borderColor,
              highlightColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkCardBackgroundColor
                  : AppColors.cardBackgroundColor,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkCardBackgroundColor
                      : AppColors.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
