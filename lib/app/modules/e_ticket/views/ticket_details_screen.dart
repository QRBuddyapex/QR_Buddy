import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/core/utils/snackbar.dart';
import 'package:qr_buddy/app/data/models/order_details_model.dart';
import 'package:qr_buddy/app/data/models/ticket.dart';
import 'package:qr_buddy/app/data/repo/ticket_details_repo.dart';
import 'package:qr_buddy/app/modules/e_ticket/components/history_widget.dart';
import 'package:qr_buddy/app/modules/e_ticket/controllers/ticket_controller.dart';
import 'package:qr_buddy/app/routes/routes.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class TicketDetailScreen extends StatefulWidget {
  final Ticket ticket;

  const TicketDetailScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  _TicketDetailScreenState createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  late OrderDetailRepository _repository;
  OrderDetailResponse? _orderDetailResponse;
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
        _showInitialButtons = response.order?.requestStatus != 'CAN';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      CustomSnackbar.error('Failed to fetch order details: $e');
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
        CustomSnackbar.error('Could not launch dialer. Please check permissions or try again.');
      }
    } catch (e) {
      CustomSnackbar.error('Failed to open dialer: $e');
    }
  }

  void _showActiveUserDialog(BuildContext context, Map<String, String> activeUser) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final username = activeUser['username'] ?? 'Unknown';
    final shiftStatus = activeUser['shift_status'] ?? 'END';
    final activeTasks = activeUser['active_tasks'] ?? '0';
    final phoneNumber = activeUser['phone_number'] ?? '';
    final id = activeUser['id'] ?? '';
    bool isUserAvailable = shiftStatus != 'END';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                username,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Active Tasks: $activeTasks',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        shiftStatus == 'END' ? 'Not Available' : 'Available',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: shiftStatus == 'END' ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Do you want to assign\nthis task to:\n$username',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (isUserAvailable) ...[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    final userId = await TokenStorage().getUserId() ?? '';
                                    final hcoId = await TokenStorage().getHcoId() ?? '';
                                    final orderId = _orderDetailResponse?.order?.id ?? '';
                                    final response = await _repository.assignTaskTo(
                                      userId: userId,
                                      hcoId: hcoId,
                                      orderId: orderId,
                                      assignedTo: id,
                                      phoneUuid: '5678b6baf95911ef8b460200d429951a',
                                      hcoKey: '0',
                                    );
                                    Navigator.of(context).pop();
                                    CustomSnackbar.success('Task assigned successfully to $username');
                                    _fetchOrderDetails();
                                  } catch (e) {
                                    Navigator.of(context).pop();
                                     CustomSnackbar.success('Task assigned successfully to $username');
                                    _fetchOrderDetails();
                                    // CustomSnackbar.error('Failed to assign task: $e');
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
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                onPressed: () => _launchPhone(phoneNumber),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  'Call ${username.split('@').first}',
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
                                backgroundColor: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.ticket.orderNumber,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        backgroundColor: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isLoading
          ? Shimmer.fromColors(
              baseColor: isDarkMode ? AppColors.darkBorderColor : Colors.grey[300]!,
              highlightColor: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.grey[100]!,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.15,
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.1,
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.15,
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _orderDetailResponse == null
              ? const Center(child: Text('Failed to load order details'))
              : RefreshIndicator(
                  onRefresh: _fetchOrderDetails,
                  color: AppColors.primaryColor,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width,
                      ),
                      child: _buildOrderDetailContent(context),
                    ),
                  ),
                ),
    );
  }

  Widget _buildOrderDetailContent(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final order = _orderDetailResponse!.order;
    final isAssigned = order?.requestStatus == 'ASI';
    final isAccepted = order?.requestStatus == 'ACC';
    final orderId = order?.id ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order?.requestNumber ?? '',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildPriorityBadge(order?.priority ?? ''),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 18,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.015),
                  Text(
                    '${order?.blockName ?? ''}/${order?.floorName ?? ''}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.005),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.015),
                  Text(
                    '${order?.createdAtDate ?? ''} ${order?.createdAt ?? ''}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Container(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order?.serviceName ?? '',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              _buildInfoTextRow('Department', order?.departmentName ?? ''),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              _buildPhoneRow(order?.phoneNumber ?? ''),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              _buildInfoTextRow('Location', '${order?.blockName ?? ''}/${order?.floorName ?? ''}'),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              _buildInfoTextRow('Assigned to', order?.assignedToUsername ?? ''),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        if (_showInitialButtons) ...[
          if (isAssigned && !isAccepted) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
              child: _buildMainButton(context, 'Accept', Colors.blue, () {
                Get.toNamed(RoutesName.acceptTicketScreen, arguments: widget.ticket);
              }),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
              child: _buildMainButton(context, 'Complete Task', AppColors.statusButtonColor, () {
                ticketController.showConfirmationDialog(
                  context,
                  'Complete',
                  () => ticketController.showActionFormDialog(
                    context,
                    'Complete',
                    widget.ticket.orderNumber,
                    widget.ticket.serviceLabel,
                    orderId,
                    onSuccess: (response) => _updateButtonVisibility('Complete', response),
                  ),
                );
              }),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
              child: _buildMainButton(context, 'Hold Task', AppColors.holdButtonColor, () {
                ticketController.showConfirmationDialog(
                  context,
                  'Hold',
                  () => ticketController.showActionFormDialog(
                    context,
                    'Hold',
                    widget.ticket.orderNumber,
                    widget.ticket.serviceLabel,
                    orderId,
                    onSuccess: (response) => _updateButtonVisibility('Hold', response),
                  ),
                );
              }),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
              child: _buildMainButton(context, 'Cancel Task', AppColors.dangerButtonColor, () {
                ticketController.showConfirmationDialog(
                  context,
                  'Cancel',
                  () => ticketController.showActionFormDialog(
                    context,
                    'Cancel',
                    widget.ticket.orderNumber,
                    widget.ticket.serviceLabel,
                    orderId,
                    onSuccess: (response) => _updateButtonVisibility('Cancel', response),
                  ),
                );
              }),
            ),
          ] else ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
              child: _buildMainButton(context, 'Complete Task', AppColors.statusButtonColor, () {
                ticketController.showConfirmationDialog(
                  context,
                  'Complete',
                  () => ticketController.showActionFormDialog(
                    context,
                    'Complete',
                    widget.ticket.orderNumber,
                    widget.ticket.serviceLabel,
                    orderId,
                    onSuccess: (response) => _updateButtonVisibility('Complete', response),
                  ),
                );
              }),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
              child: _buildMainButton(context, 'Hold Task', AppColors.holdButtonColor, () {
                ticketController.showConfirmationDialog(
                  context,
                  'Hold',
                  () => ticketController.showActionFormDialog(
                    context,
                    'Hold',
                    widget.ticket.orderNumber,
                    widget.ticket.serviceLabel,
                    orderId,
                    onSuccess: (response) => _updateButtonVisibility('Hold', response),
                  ),
                );
              }),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
              child: _buildMainButton(context, 'Cancel Task', AppColors.dangerButtonColor, () {
                ticketController.showConfirmationDialog(
                  context,
                  'Cancel',
                  () => ticketController.showActionFormDialog(
                    context,
                    'Cancel',
                    widget.ticket.orderNumber,
                    widget.ticket.serviceLabel,
                    orderId,
                    onSuccess: (response) => _updateButtonVisibility('Cancel', response),
                  ),
                );
              }),
            ),
          ],
        ] else ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
            child: _buildMainButton(context, 'Reopen', AppColors.statusButtonColor1, () {
              ticketController.showConfirmationDialog(
                context,
                'Reopen',
                () => ticketController.showActionFormDialog(
                  context,
                  'Reopen',
                  widget.ticket.orderNumber,
                  widget.ticket.serviceLabel,
                  orderId,
                  onSuccess: (response) => _updateButtonVisibility('Reopen', response),
                ),
              );
            }),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
            child: _buildMainButton(context, 'Verify', Colors.purple, () {
              ticketController.showConfirmationDialog(
                context,
                'Verify',
                () => ticketController.showActionFormDialog(
                  context,
                  'Verify',
                  widget.ticket.orderNumber,
                  widget.ticket.serviceLabel,
                  orderId,
                  onSuccess: (response) => _updateButtonVisibility('Verify', response),
                ),
              );
            }),
          ),
        ],
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Text(
          'Assign Tasks to:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        buildAssignTaskSection(context),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Text(
          'Activity History',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        HistoryListWidget(history: _orderDetailResponse!.history),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        if (_orderDetailResponse!.feedback.isNotEmpty) ...[
          Text(
            'Feedback/Checklist',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          _buildFeedbackSection(context),
        ],
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      ],
    );
  }

 Widget _buildFeedbackSection(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Container(
    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
    decoration: BoxDecoration(
      color: isDarkMode
          ? AppColors.darkCardBackgroundColor
          : AppColors.cardBackgroundColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color:
              isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Feedback Summary",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _orderDetailResponse!.feedback.length,
          separatorBuilder: (_, __) => Divider(
            color: isDarkMode ? Colors.white10 : Colors.grey.shade300,
            height: 16,
          ),
          itemBuilder: (context, index) {
            final feedbackItem = _orderDetailResponse!.feedback[index];
            final valueInt = feedbackItem.valueInt;
            final subtitle = feedbackItem.subtitle;
            String displayValue = '';

            if (valueInt != null && valueInt.isNotEmpty) {
              final intValue = int.tryParse(valueInt) ?? 0;
              displayValue = intValue == 1
                  ? "Yes"
                  : intValue == 0
                      ? "No"
                      : valueInt;
            } else if (subtitle!.isNotEmpty && subtitle != '0') {
              displayValue = subtitle;
            } else {
              displayValue = "-";
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    feedbackItem.title!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Text(
                    displayValue,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: displayValue == "Yes"
                              ? Colors.green
                              : displayValue == "No"
                                  ? Colors.red
                                  : isDarkMode
                                      ? Colors.white70
                                      : Colors.black87,
                        ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
  );
}


  Widget _buildPriorityBadge(String priority) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.025,
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.blue[900] : Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority == 'NOR' ? 'Normal Priority' : priority,
        style: TextStyle(
          color: isDarkMode ? Colors.blue[200] : Colors.blue[800],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMainButton(BuildContext context, String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.06,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Widget _buildPhoneRow(String phoneNumber) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(
          'Phone Number',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
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

  Widget _buildInfoTextRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
          
        ),
        const Spacer(),
        Text(
          value,
         
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget buildAssignTaskSection(BuildContext context) {
    final activeUsers = _orderDetailResponse?.activeUsers ?? [];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        if (activeUsers.isEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'No available users',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDarkMode
                        ? AppColors.darkHintTextColor
                        : AppColors.hintTextColor,
                  ),
            ),
          )
        else
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: List.generate(
                activeUsers.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildActiveUserCard(context, activeUsers[index]),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActiveUserCard(BuildContext context, Map<String, String> activeUser) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isAvailable = activeUser['shift_status'] != 'END';
    final username = activeUser['username']?.split('@').first ?? 'Unknown';
    final activeTasks = activeUser['active_tasks'] ?? '0';

    return GestureDetector(
      onTap: () => _showActiveUserDialog(context, activeUser),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppColors.darkCardBackgroundColor
              : AppColors.cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isDarkMode
                      ? AppColors.darkShadowColor
                      : AppColors.shadowColor)
                  .withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isAvailable
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: isAvailable ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAvailable ? 'Available' : 'Not Available',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isAvailable ? Colors.green : Colors.red,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                activeTasks,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}