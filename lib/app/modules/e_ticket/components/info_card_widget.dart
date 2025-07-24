import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/modules/e_ticket/components/ticket_card.dart';
import 'package:qr_buddy/app/modules/e_ticket/controllers/ticket_controller.dart';

class InfoCardContentWidget extends StatelessWidget {
  const InfoCardContentWidget({Key? key}) : super(key: key);

  Widget _buildGroupHeader({
    required BuildContext context,
    required String groupName,
    required VoidCallback onRefresh,
    required Size size,
    required TextTheme textTheme,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: size.height * 0.01,
        horizontal: size.width * 0.04,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            groupName,
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.textColor,
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.05,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: AppColors.hintTextColor,
                  size: size.width * 0.06,
                ),
                onPressed: onRefresh,
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: AppColors.hintTextColor,
                  size: size.width * 0.06,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFoodDeliveryCard({
    required BuildContext context,
    required Map<String, dynamic> delivery,
    required int index,
    required Size size,
    required TextTheme textTheme,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.004,
        vertical: size.height * 0.01,
      ),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: AppColors.shadowColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(size.width * 0.015),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Delivery $index",
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * 0.04,
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.02),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Room ID: ${delivery['roomId']}",
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: size.width * 0.03,
                        ),
                      ),
                      Text(
                        "Room Name: ${delivery['roomName']}",
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.hintTextColor,
                          fontSize: size.width * 0.035,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Get.snackbar('QR', 'QR code for ${delivery['roomId']} generated');
                },
                child: Icon(
                  Icons.qr_code,
                  color: Colors.white,
                  size: size.width * 0.06,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistCard({
    required BuildContext context,
    required Map<String, dynamic> checklist,
    required int index,
    required Size size,
    required TextTheme textTheme,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.01,
      ),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: AppColors.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(size.width * 0.015),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Checklist $index",
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.04,
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.02),
                      Text(
                        checklist['checklist_name'],
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: size.width * 0.03,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                      size: size.width * 0.06,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.015),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.primaryColor,
                    size: size.width * 0.05,
                  ),
                  SizedBox(width: size.width * 0.02),
                  Expanded(
                    child: Text(
                      "Location: ${checklist['location']}",
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.hintTextColor,
                        fontSize: size.width * 0.035,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.015),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.primaryColor,
                    size: size.width * 0.05,
                  ),
                  SizedBox(width: size.width * 0.02),
                  Expanded(
                    child: Text(
                      "Date & Time: ${checklist['date_and_time']}",
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.hintTextColor,
                        fontSize: size.width * 0.035,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton({
    required BuildContext context,
    required String label,
    required Size size,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.01,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () {},
          icon: Icon(
            Icons.add,
            color: Colors.green,
            size: size.width * 0.06,
          ),
          label: Text(
            label,
            style: TextStyle(
              color: Colors.green,
              fontSize: size.width * 0.04,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;
    final controller = Get.find<TicketController>();

    return Obx(() {
      if (controller.selectedInfoCard.value == '') {
        return ListView.builder(
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
              onTap: () => controller.navigateToDetail(ticket),
            );
          },
        );
      } else if (controller.selectedInfoCard.value == 'Food Delivery') {
        return Column(
          children: [
            _buildGroupHeader(
              context: context,
              groupName: 'Food Deliveries',
              onRefresh: () => controller.fetchFoodDeliveries(),
              size: size,
              textTheme: textTheme,
            ),
            ...List.generate(3, (index) {
              final delivery = {
                'roomId': 'R${index + 1}',
                'roomName': 'Room ${String.fromCharCode(65 + index)}', // A, B, C
                'imageUrl': 'https://via.placeholder.com/150',
              };
              return _buildFoodDeliveryCard(
                context: context,
                delivery: delivery,
                index: index + 1,
                size: size,
                textTheme: textTheme,
              );
            }),
           
          ],
        );
      } else if (controller.selectedInfoCard.value == 'Checklists') {
        return Column(
          children: controller.checklists.map((group) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGroupHeader(
                  context: context,
                  groupName: group['group'],
                  onRefresh: () => controller.fetchChecklists(),
                  size: size,
                  textTheme: textTheme,
                ),
                ...group['checklists'].asMap().entries.map((entry) {
                  return _buildChecklistCard(
                    context: context,
                    checklist: entry.value,
                    index: entry.key + 1,
                    size: size,
                    textTheme: textTheme,
                  );
                }).toList(),
                _buildAddButton(
                  context: context,
                  label: 'Add Checklist',
                  size: size,
                ),
              ],
            );
          }).toList(),
        );
      }
      return const SizedBox.shrink();
    });
  }
}