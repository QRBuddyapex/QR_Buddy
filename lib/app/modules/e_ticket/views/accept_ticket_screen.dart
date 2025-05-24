import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/data/models/ticket.dart';
import 'package:qr_buddy/app/modules/e_ticket/controllers/ticket_controller.dart';
import 'package:qr_buddy/app/routes/routes.dart';

class AcceptTicketScreen extends StatelessWidget {
  final Ticket ticket;
  final TicketController ticketController = Get.find<TicketController>();

  AcceptTicketScreen({Key? key, required this.ticket}) : super(key: key);

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackgroundColor,
          title: Text(
            'Confirm Accept',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          content: Text(
            'Are you sure you want to accept this ticket?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'No',
                style: TextStyle(color: AppColors.dangerButtonColor),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await ticketController.updateRequest(
                    action: 'Accept',
                    orderId: '92254', 
                  );
                  Get.toNamed(RoutesName.ticketDashboardView);
                  await ticketController.fetchTickets();
                } catch (e) {
                 
                }
              },
              child: Text(
                'Yes',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.theme,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: Text(
            ticket.serviceLabel,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          backgroundColor: AppColors.cardBackgroundColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.hintTextColor),
            onPressed: () => Get.back(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: AppColors.cardBackgroundColor,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      ticket.orderNumber,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Icon(
                      Icons.notifications_active,
                      color: Colors.orange,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      '${ticket.department} ${ticket.block}/${ticket.department}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _showConfirmationDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: AppColors.textColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: const Text('Click Here to Accept E-Ticket'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Cancel Alarm',
                        style: TextStyle(color: AppColors.dangerButtonColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoTextRow(context, 'Remarks', (ticket.isQuickRequest ?? false) ? "Quick Request" : "Normal Request"),
                  const SizedBox(height: 10),
                  _buildInfoTextRow(context, 'Priority', ticket.status ?? ''),
                  const SizedBox(height: 10),
                  _buildInfoTextRow(context, 'Department', 'E & M'),
                  const SizedBox(height: 10),
                  _buildInfoTextRow(context, 'Room', ticket.department ?? ''),
                  const SizedBox(height: 10),
                  _buildInfoTextRow(context, 'Location', '${ticket.block}/${ticket.department}'),
                  const SizedBox(height: 10),
                  _buildInfoTextRow(context, 'Date', '31/01/2025'),
                  const SizedBox(height: 10),
                  _buildInfoTextRow(context, 'Time', '01:03 PM'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTextRow(BuildContext context, String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}