import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/core/widgets/custom_buttom.dart';
import 'package:qr_buddy/app/data/models/order_details_model.dart' as orderModel;
import 'package:qr_buddy/app/data/models/ticket.dart';
import 'package:qr_buddy/app/data/repo/ticket_details_repo.dart';
import 'package:qr_buddy/app/modules/e_ticket/controllers/ticket_controller.dart';
import 'package:qr_buddy/app/routes/routes.dart';
import 'package:url_launcher/url_launcher.dart';

class TicketDetailScreen extends StatefulWidget {
  final Ticket ticket;

  const TicketDetailScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  _TicketDetailScreenState createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  late OrderDetailRepository _repository;
  orderModel.OrderDetailResponse? _orderDetailResponse;
  bool _isLoading = true;
  bool _showInitialButtons = true;
  final TicketController ticketController = Get.find<TicketController>();

  @override
  void initState() {
    super.initState();
    _repository = OrderDetailRepository(ApiService(), TokenStorage());
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final hcoId = await TokenStorage().getHcoId() ?? '';
      final userId = await TokenStorage().getUserId() ?? '';
      final orderId = widget.ticket.uuid;

      if (orderId!.isEmpty) {
        throw Exception('Order ID (UUID) is missing');
      }

      final response = await _repository.fetchOrderDetails(
        hcoId: hcoId,
        orderId: orderId,
        userId: userId,
      );

      setState(() {
        _orderDetailResponse = response;
        _isLoading = false;
        _showInitialButtons = response.order.requestStatus != 'CAN';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to fetch order details: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  void _updateButtonVisibility(String action, Map<String, dynamic> response) {
    if (response['status'] == 1 || response['status'] == '1') {
      setState(() {
        _showInitialButtons = action != 'Cancel';
      });
      _fetchOrderDetails();
    }
  }
Future<void> _launchPhone(String phoneNumber) async {
  final Uri url = Uri.parse('tel:$phoneNumber');
  try {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch dialer. Please check permissions or try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  } catch (e) {
    Get.snackbar(
      'Error',
      'Failed to open dialer: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  }
  void _showActiveUserDialog(BuildContext context, orderModel.ActiveUser activeUser) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Check if user is available
      bool isUserAvailable = activeUser.shiftStatus != 'END';

      return AlertDialog(
        backgroundColor: AppColors.cardBackgroundColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              activeUser.username,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.hintTextColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Center( // Center the entire content
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the row content
                  children: [
                    Text(
                      'Active Tasks: ${activeUser.activeTasks}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green),
                    ),
                    const SizedBox(width: 10), // Add spacing between elements
                    Text(
                      activeUser.shiftStatus == 'END' ? 'Not Available' : 'Available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: activeUser.shiftStatus == 'END' ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Do you want to assign\nthis task to:\n${activeUser.username}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
                  textAlign: TextAlign.center, // Center the text
                ),
                const SizedBox(height: 20),
                if (isUserAvailable) ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Center the buttons vertically
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Center the buttons horizontally
                        children: [
                          SizedBox(
                            width: 100,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  final userId = await TokenStorage().getUserId() ?? '';
                                  final hcoId = await TokenStorage().getHcoId() ?? '';
                                  final orderId = _orderDetailResponse?.order.id ?? '';
                                  final response = await _repository.assignTaskTo(
                                    userId: userId,
                                    hcoId: hcoId,
                                    orderId: orderId,
                                    assignedTo: activeUser.id,
                                    phoneUuid: '5678b6baf95911ef8b460200d429951a',
                                    hcoKey: '0',
                                  );
                                  Navigator.of(context).pop();
                                  Get.snackbar(
                                    'Success',
                                    'Task assigned successfully to ${activeUser.username}',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.green.withOpacity(0.8),
                                    colorText: Colors.white,
                                  );
                                  _fetchOrderDetails();
                                } catch (e) {
                                  Get.snackbar(
                                    'Success',
                                    'Task assigned successfully to ${activeUser.username}',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.green.withOpacity(0.8),
                                    colorText: Colors.white,
                                  );
                                   Navigator.of(context).pop();
                                    _fetchOrderDetails();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Assign Task',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10), // Add spacing between buttons
                          SizedBox(
                            width: 100,
                            child: ElevatedButton(
                              onPressed: () => _launchPhone(activeUser.phoneNumber ?? ''),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Call ${activeUser.username.split('@').first}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: AppColors.cardBackgroundColor,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.close, color: Colors.red, size: 40),
                                ],
                              ),
                              content: Text(
                                "Can't assign task to this user",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              actions: [
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Text(
                                      'OK',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Assign Task (Unavailable)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
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
            widget.ticket.orderNumber,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          backgroundColor: AppColors.cardBackgroundColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.hintTextColor),
            onPressed: () => Get.back(),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _orderDetailResponse == null
                ? const Center(child: Text('Failed to load order details'))
                : RefreshIndicator(
                    onRefresh: _fetchOrderDetails,
                    color: AppColors.primaryColor,
                    child: _buildOrderDetailContent(context),
                  ),
      ),
    );
  }

  Widget _buildOrderDetailContent(BuildContext context) {
    final order = _orderDetailResponse!.order;
    return SingleChildScrollView(
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
              _buildInfoRow(Icons.person, order.requestNumber, Icons.location_on),
              const SizedBox(height: 10),
              _buildPhoneRow(order.phoneNumber),
              const SizedBox(height: 10),
              _buildPriorityRow(order.priority),
              const SizedBox(height: 10),
              _buildInfoTextRow('Department', order.departmentName),
              const SizedBox(height: 10),
              _buildInfoTextRow('Location', '${order.blockName}/${order.floorName}'),
              const SizedBox(height: 10),
              _buildInfoTextRow('Date/Time', '${order.createdAtDate} ${order.createdAt}'),
              const SizedBox(height: 10),
              _buildInfoTextRow('Assigned to', order.assignedToUsername),
              const SizedBox(height: 20),
              Text(order.serviceName, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              Text('${order.blockName}/${order.floorName}', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              _buildActionButtons(context),
              const SizedBox(height: 20),
              Text('Assign task to', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              _buildAvailableUsersList(context),
              const SizedBox(height: 20),
              Text('History', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              _buildHistoryList(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData leadingIcon, String leadingText, IconData trailingIcon) {
    return Row(
      children: [
        Icon(leadingIcon, color: AppColors.hintTextColor),
        const SizedBox(width: 8),
        Text(leadingText, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Icon(trailingIcon, color: AppColors.hintTextColor),
      ],
    );
  }

  Widget _buildPhoneRow(String phoneNumber) {
    return Row(
      children: [
        Text('Phone Number', style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        GestureDetector(
          onTap: () => _launchPhone(phoneNumber),
          child: Text(
            phoneNumber,
            style: TextStyle(
              color: AppColors.linkColor,
              fontSize: 16,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityRow(String priority) {
    final isNormal = priority == 'NOR';
    return Row(
      children: [
        Text('Priority', style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            isNormal ? 'Normal' : priority,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.linkColor),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTextRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isAssigned = _orderDetailResponse?.order.requestStatus == 'ASI';
    final isAccepted = _orderDetailResponse?.order.requestStatus == 'ACC';
    final orderId = _orderDetailResponse?.order.id ?? '';

    return Column(
      children: [
        if (_showInitialButtons) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (isAssigned && !isAccepted)
                CustomButton(
                  width: context.width * 0.22,
                  onPressed: () {
                    Get.toNamed(RoutesName.acceptTicketScreen, arguments: widget.ticket);
                  },
                  text: 'Accept',
                  color: AppColors.primaryColor,
                ),
              CustomButton(
                width: context.width * 0.22,
                onPressed: () => ticketController.showConfirmationDialog(
                  context,
                  'Complete',
                  () => ticketController.showActionFormDialog(
                    context,
                    'Complete',
                    widget.ticket.orderNumber,
                    widget.ticket.serviceLabel,
                    orderId,
                    onSuccess: (response) {
                      _updateButtonVisibility('Complete', response);
                    },
                  ),
                ),
                text: 'Complete',
                color: AppColors.statusButtonColor,
              ),
              CustomButton(
                width: context.width * 0.22,
                onPressed: () => ticketController.showConfirmationDialog(
                  context,
                  'Hold',
                  () => ticketController.showActionFormDialog(
                    context,
                    'Hold',
                    widget.ticket.orderNumber,
                    widget.ticket.serviceLabel,
                    orderId,
                    onSuccess: (response) {
                      _updateButtonVisibility('Hold', response);
                    },
                  ),
                ),
                text: 'Hold',
                color: AppColors.holdButtonColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildCancelButton(context),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton(
                width: context.width * 0.22,
                onPressed: () => ticketController.showConfirmationDialog(
                  context,
                  'Reopen',
                  () => ticketController.showActionFormDialog(
                    context,
                    'Reopen',
                    widget.ticket.orderNumber,
                    widget.ticket.serviceLabel,
                    orderId,
                    onSuccess: (response) {
                      _updateButtonVisibility('Reopen', response);
                    },
                  ),
                ),
                text: 'Reopen',
                color: AppColors.statusButtonColor1,
              ),
              CustomButton(
                width: context.width * 0.22,
                onPressed: () => ticketController.showConfirmationDialog(
                  context,
                  'Verify',
                  () => ticketController.showActionFormDialog(
                    context,
                    'Verify',
                    widget.ticket.orderNumber,
                    widget.ticket.serviceLabel,
                    orderId,
                    onSuccess: (response) {
                      _updateButtonVisibility('Verify', response);
                    },
                  ),
                ),
                text: 'Verify',
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    final orderId = _orderDetailResponse?.order.id ?? '';
    return Center(
      child: CustomButton(
        width: context.width * 0.22,
        onPressed: () => ticketController.showConfirmationDialog(
          context,
          'Cancel',
          () => ticketController.showActionFormDialog(
            context,
            'Cancel',
            widget.ticket.orderNumber,
            widget.ticket.serviceLabel,
            orderId,
            onSuccess: (response) {
              _updateButtonVisibility('Cancel', response);
            },
          ),
        ),
        text: 'Cancel',
        color: AppColors.dangerButtonColor,
      ),
    );
  }

  Widget _buildAvailableUsersList(BuildContext context) {
    final activeUsers = _orderDetailResponse?.activeUsers ?? [];
    if (activeUsers.isEmpty) {
      return const Text(
        'No available users',
        style: TextStyle(color: AppColors.hintTextColor),
      );
    }
    return Column(
      children: activeUsers.map((activeUser) => _buildActiveUserCard(context, activeUser)).toList(),
    );
  }

  Widget _buildActiveUserCard(BuildContext context, orderModel.ActiveUser activeUser) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => _showActiveUserDialog(context, activeUser),
        child: SizedBox(
          height: context.height * 0.06,
          width: double.infinity,
          child: Card(
            color: AppColors.whatsappIconColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                    activeUser.username.split('@').first,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    activeUser.activeTasks,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green),
                  ),
                ),
                Text(
                  activeUser.shiftStatus == 'END' ? 'Not Available' : 'Available',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: activeUser.shiftStatus == 'END' ? Colors.red :  Colors.green[50],
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    final Map<String, ({IconData icon, Color color})> historyIconMap = {
      'ESC': (icon: Icons.flag, color: AppColors.escalationIconColor),
      'ASI': (icon: Icons.person_add, color: AppColors.assignmentIconColor),
      'ACC': (icon: Icons.check_circle, color: AppColors.primaryColor),
      'COMP': (icon: Icons.done_all, color: AppColors.statusButtonColor),
      'HOLD': (icon: Icons.pause_circle, color: AppColors.holdButtonColor),
      'CAN': (icon: Icons.cancel, color: AppColors.dangerButtonColor),
      'REO': (icon: Icons.restart_alt, color: AppColors.statusButtonColor1),
      'VER': (icon: Icons.verified, color: Colors.purple),
    };

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _orderDetailResponse!.history.length,
      itemBuilder: (context, index) {
        final history = _orderDetailResponse!.history[index];
        final iconData = historyIconMap[history.type] ??
            (icon: Icons.info, color: AppColors.hintTextColor);

        return Stack(
          children: [
            Positioned(
              left: context.width * 0.025689,
              top: 0,
              bottom: 0,
              child: Container(
                width: 2,
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
              leading: Icon(
                iconData.icon,
                color: iconData.color,
                size: 24,
              ),
              title: Row(
                children: [
                  Text(history.createdAt, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(width: 8),
                  Text(history.createdAtDate, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Text(
                      history.caption + (history.remarks.isNotEmpty ? ' ${history.remarks}' : ''),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  if (history.statusWhatsapp == '1')
                    Icon(Icons.check_circle, color: AppColors.whatsappIconColor, size: 16),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}