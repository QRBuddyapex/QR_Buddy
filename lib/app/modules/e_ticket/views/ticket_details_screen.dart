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

  // Added: User type detection
  String _userType = '';
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _repository = OrderDetailRepository(ApiService(), TokenStorage());
    _loadUserType(); // Load user type
    _fetchOrderDetails();
  }

  // Added: Load user type from storage
  Future<void> _loadUserType() async {
    final userType = await TokenStorage().getUserType() ?? '';
    if (mounted) {
      setState(() {
        _userType = userType;
        _isAdmin = userType != 'S_TEAM'; // Anyone not S_TEAM is Admin
      });
    }
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
        final status = response.order?.requestStatus ?? '';
        _showInitialButtons = !['CAN', 'COMP', 'VER'].contains(status);
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
        CustomSnackbar.error(
            'Could not launch dialer. Please check permissions or try again.');
      }
    } catch (e) {
      CustomSnackbar.error('Failed to open dialer: $e');
    }
  }

  void _showActiveUserDialog(
      BuildContext context, Map<String, String> activeUser) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final hPadding = width * 0.04;
    final vSpacingSmall = height * 0.008;
    final vSpacingMedium = height * 0.012;
    final vSpacingLarge = height * 0.02;
    final buttonWidth = width * 0.25;
    final buttonHeight = height * 0.055;
    final iconSize = width * 0.08;
    final textSize = width * 0.04;
    final buttonFontSize = width * 0.035;
    final dialogTextSize = width * 0.045;
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
          backgroundColor: isDarkMode
              ? AppColors.darkCardBackgroundColor
              : AppColors.cardBackgroundColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                username,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: dialogTextSize,
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
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.green, fontSize: textSize),
                      ),
                      SizedBox(width: hPadding),
                      Text(
                        shiftStatus == 'END' ? 'Not Available' : 'Available',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: shiftStatus == 'END'
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: textSize,
                            ),

                      ),
                    ],
                  ),
                  SizedBox(height: vSpacingLarge),
                  Text(
                    'Do you want to assign\nthis task to:\n$username',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.textColor,
                          fontSize: dialogTextSize,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: vSpacingLarge),
                  if (isUserAvailable) ...[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: buttonWidth,
                              height: buttonHeight,
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    final userId =
                                        await TokenStorage().getUserId() ?? '';
                                    final hcoId =
                                        await TokenStorage().getHcoId() ?? '';
                                    final orderId =
                                        _orderDetailResponse?.order?.id ?? '';
                                    final response =
                                        await _repository.assignTaskTo(
                                      userId: userId,
                                      hcoId: hcoId,
                                      orderId: orderId,
                                      assignedTo: id,
                                      phoneUuid:
                                          '5678b6baf95911ef8b460200d429951a',
                                      hcoKey: '0',
                                    );
                                    Navigator.of(context).pop();
                                    CustomSnackbar.success(
                                        'Task assigned successfully to $username');
                                    _fetchOrderDetails();
                                  } catch (e) {
                                    Navigator.of(context).pop();
                                    CustomSnackbar.error('Failed to assign task: $e');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  minimumSize: Size(buttonWidth, buttonHeight),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: hPadding,
                                    vertical: vSpacingSmall,
                                  ),
                                ),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  'Assign Task',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: buttonFontSize,
                                      ),
                                ),
                              ),
                            ),
                            SizedBox(width: hPadding),
                            SizedBox(
                              width: buttonWidth,
                              height: buttonHeight,
                              child: ElevatedButton(
                                onPressed: () => _launchPhone(phoneNumber),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  minimumSize: Size(buttonWidth, buttonHeight),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: hPadding,
                                    vertical: vSpacingSmall,
                                  ),
                                ),
                                child: Text(
                                  'Call ${username.split('@').first}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: buttonFontSize,
                                      ),
                                  textAlign: TextAlign.center,
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
                              final innerSize = MediaQuery.of(context).size;
                              final innerWidth = innerSize.width;
                              final innerHeight = innerSize.height;
                              final innerHPadding = innerWidth * 0.04;
                              final innerVSpacingSmall = innerHeight * 0.008;
                              final innerIconSize = innerWidth * 0.08;
                              final innerTextSize = innerWidth * 0.045;
                              final innerButtonFontSize = innerWidth * 0.04;
                              final innerButtonHeight = innerHeight * 0.055;
                              return AlertDialog(
                                backgroundColor: isDarkMode
                                    ? AppColors.darkCardBackgroundColor
                                    : AppColors.cardBackgroundColor,
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.close,
                                        color: Colors.red, size: innerIconSize),
                                  ],
                                ),
                                content: Text(
                                  "Can't assign task to this user",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: innerTextSize,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  Center(
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: innerButtonHeight,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          minimumSize: Size.fromHeight(innerButtonHeight),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: innerHPadding,
                                            vertical: innerVSpacingSmall,
                                          ),
                                        ),
                                        child: Text(
                                          'OK',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: innerButtonFontSize,
                                              ),
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
                          backgroundColor:
                              AppColors.primaryColor.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: hPadding,
                            vertical: vSpacingSmall,
                          ),
                        ),
                        child: Text(
                          'Assign Task (Unavailable)',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: buttonFontSize,
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final hPadding = width * 0.04;
    final vSpacingSmall = height * 0.005;
    final vSpacingMedium = height * 0.01;
    final vSpacingLarge = height * 0.02;
    final containerHeight1 = height * 0.15;
    final containerHeight2 = height * 0.25;
    final containerHeight3 = height * 0.1;
    final containerHeight4 = height * 0.15;
    final iconSize = width * 0.045;
    final textSpacingH = width * 0.038;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.ticket.orderNumber,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        backgroundColor: isDarkMode
            ? AppColors.darkCardBackgroundColor
            : AppColors.cardBackgroundColor,
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
              baseColor:
                  isDarkMode ? AppColors.darkBorderColor : Colors.grey[300]!,
              highlightColor: isDarkMode
                  ? AppColors.darkCardBackgroundColor
                  : Colors.grey[300]!,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(hPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: containerHeight1,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.darkCardBackgroundColor
                            : AppColors.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(height: vSpacingLarge),
                    Container(
                      height: containerHeight2,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.darkCardBackgroundColor
                            : AppColors.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(height: vSpacingLarge),
                    Container(
                      height: containerHeight3,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.darkCardBackgroundColor
                            : AppColors.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(height: vSpacingLarge),
                    Container(
                      height: containerHeight4,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.darkCardBackgroundColor
                            : AppColors.cardBackgroundColor,
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
                  onRefresh: () async {
                    await _loadUserType();
                    await _fetchOrderDetails();
                  },
                  color: AppColors.primaryColor,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(hPadding),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: width),
                      child: _buildOrderDetailContent(context),
                    ),
                  ),
                ),
    );
  }

  Widget _buildOrderDetailContent(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final hPadding = width * 0.04;
    final vSpacingSmall = height * 0.005;
    final vSpacingMedium = height * 0.01;
    final vSpacingLarge = height * 0.02;
    final iconSize = width * 0.045;
    final textSpacingH = width * 0.038;
    final buttonWidth = width * 0.9;
    final buttonHeight = height * 0.06;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final order = _orderDetailResponse!.order;
    final isAssigned = order?.requestStatus == 'ASI';
    final isAccepted = order?.requestStatus == 'ACC';
    final orderId = order?.id ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(hPadding),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkCardBackgroundColor
                : AppColors.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order?.requestNumber ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildPriorityBadge(order?.priority ?? ''),
                ],
              ),
              SizedBox(height: vSpacingMedium),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: iconSize,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  SizedBox(width: textSpacingH),
                  Text(
                    '${order?.roomNumber ?? ''}/${order?.floorName ?? ''}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              SizedBox(height: vSpacingSmall),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: iconSize,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  SizedBox(width: textSpacingH),
                  Text(
                    '${order?.createdAtDate ?? ''} ${order?.createdAt ?? ''}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: vSpacingLarge),
        Container(
          padding: EdgeInsets.all(hPadding),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkCardBackgroundColor
                : AppColors.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order?.serviceName ?? '',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: vSpacingMedium),
              _buildInfoTextRow('Department', order?.departmentName ?? ''),
              SizedBox(height: vSpacingMedium),
              _buildPhoneRow(order?.phoneNumber ?? ''),
              SizedBox(height: vSpacingMedium),
              _buildInfoTextRow('Location', '${order?.roomNumber ?? ''}/${order?.floorName ?? ''}'),
              SizedBox(height: vSpacingMedium),
              _buildInfoTextRow('Assigned to', order?.assignedToUsername ?? ''),
            ],
          ),
        ),
        SizedBox(height: vSpacingLarge),

        // ONLY THIS PART IS MODIFIED — LOGIC ADDED HERE
        if (_showInitialButtons) ...[
          if (isAssigned && !isAccepted) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              child: _buildMainButton(context, 'Accept', Colors.blue, () {
                Get.toNamed(RoutesName.acceptTicketScreen,
                    arguments: widget.ticket);
              }),
            ),
            SizedBox(height: vSpacingMedium),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              child: _buildMainButton(
                  context, 'Complete Task', AppColors.statusButtonColor, () {
                ticketController.showConfirmationDialog(
                  context,
                  'Complete',
                  () => ticketController.showActionFormDialog(
                    context,
                    'Complete',
                    widget.ticket.orderNumber,
                    widget.ticket.serviceLabel,
                    orderId,
                    onSuccess: (response) =>
                        _updateButtonVisibility('Complete', response),
                  ),
                );
              }),
            ),
            SizedBox(height: vSpacingMedium),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              child: _buildMainButton(
                  context, 'Hold Task', AppColors.holdButtonColor, () {
                ticketController.showConfirmationDialog(
                  context,
                  'Hold',
                  () => ticketController.showActionFormDialog(
                    context,
                    'Hold',
                    widget.ticket.orderNumber,
                    widget.ticket.serviceLabel,
                    orderId,
                    onSuccess: (response) =>
                        _updateButtonVisibility('Hold', response),
                  ),
                );
              }),
            ),
            SizedBox(height: vSpacingMedium),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              child: _buildMainButton(
                  context, 'Cancel Task', AppColors.dangerButtonColor, () {
                ticketController.showConfirmationDialog(
                  context,
                  'Cancel',
                  () => ticketController.showActionFormDialog(
                    context,
                    'Cancel',
                    widget.ticket.orderNumber,
                    widget.ticket.serviceLabel,
                    orderId,
                    onSuccess: (response) =>
                        _updateButtonVisibility('Cancel', response),
                  ),
                );
              }),
            ),
          ] else ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              child: _buildMainButton(
                  context, 'Complete Task', AppColors.statusButtonColor, () {
                ticketController.showConfirmationDialog(
                  context,
                  'Complete',
                  () => ticketController.showActionFormDialog(
                    context,
                    'Complete',
                    widget.ticket.orderNumber,
                    widget.ticket.serviceLabel,
                    orderId,
                    onSuccess: (response) =>
                        _updateButtonVisibility('Complete', response),
                  ),
                );
              }),
            ),
            SizedBox(height: vSpacingMedium),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              child: _buildMainButton(
                  context, 'Hold Task', AppColors.holdButtonColor, () {
                ticketController.showConfirmationDialog(
                  context,
                  'Hold',
                  () => ticketController.showActionFormDialog(
                    context,
                    'Hold',
                    widget.ticket.orderNumber,
                    widget.ticket.serviceLabel,
                    orderId,
                    onSuccess: (response) =>
                        _updateButtonVisibility('Hold', response),
                  ),
                );
              }),
            ),
            SizedBox(height: vSpacingMedium),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              child: _buildMainButton(
                  context, 'Cancel Task', AppColors.dangerButtonColor, () {
                ticketController.showConfirmationDialog(
                  context,
                  'Cancel',
                  () => ticketController.showActionFormDialog(
                    context,
                    'Cancel',
                    widget.ticket.orderNumber,
                    widget.ticket.serviceLabel,
                    orderId,
                    onSuccess: (response) =>
                        _updateButtonVisibility('Cancel', response),
                  ),
                );
              }),
            ),
          ],
        ] else ...[
          // MODIFIED: Check user role before showing Reopen/Verify
          if (_isAdmin) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              child: _buildMainButton(
                  context, 'Reopen', AppColors.statusButtonColor1, () {
                ticketController.showConfirmationDialog(
                  context,
                  'Reopen',
                  () => ticketController.showActionFormDialog(
                    context,
                    'Reopen',
                    widget.ticket.orderNumber,
                    widget.ticket.serviceLabel,
                    orderId,
                    onSuccess: (response) =>
                        _updateButtonVisibility('Reopen', response),
                  ),
                );
              }),
            ),
            SizedBox(height: vSpacingMedium),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              child: _buildMainButton(
                  context, 'Verify', AppColors.verifyButtonColor, () {
                ticketController.showConfirmationDialog(
                  context,
                  'Verify',
                  () => ticketController.showActionFormDialog(
                    context,
                    'Verify',
                    widget.ticket.orderNumber,
                    widget.ticket.serviceLabel,
                    orderId,
                    onSuccess: (response) =>
                        _updateButtonVisibility('Verify', response),
                  ),
                );
              }),
            ),
          ] else ...[
            // Staff sees only "Ticket completed"
            Padding(
              padding: EdgeInsets.symmetric(vertical: height * 0.08),
              child: Center(
                child: Text(
                  "Ticket completed",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ]
        ],

        SizedBox(height: vSpacingLarge),
        Text(
          'Assign Tasks to:',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: vSpacingMedium),
        buildAssignTaskSection(context),
        SizedBox(height: vSpacingMedium),
        Text(
          'Activity History',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: vSpacingMedium),
        HistoryListWidget(history: _orderDetailResponse!.history),
        SizedBox(height: vSpacingLarge),
        if (_orderDetailResponse!.feedback.isNotEmpty) ...[
          Text(
            'Feedback/Checklist',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: vSpacingMedium),
          _buildFeedbackSection(context),
        ],
        SizedBox(height: vSpacingLarge),
      ],
    );
  }



  Widget _buildFeedbackSection(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final hPadding = width * 0.04;
    final vSpacingSmall = height * 0.008;
    final vSpacingMedium = height * 0.012;
    final dividerHeight = height * 0.02;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Container(
    padding: EdgeInsets.all(hPadding),
    decoration: BoxDecoration(
      color: isDarkMode
          ? AppColors.darkCardBackgroundColor
          : AppColors.cardBackgroundColor,
      borderRadius: BorderRadius.circular(12),
      // boxShadow: [
      //   BoxShadow(
      //     color:
      //         isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
      //     blurRadius: 6,
      //     offset: const Offset(0, 2),
      //   ),
      // ],
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
        SizedBox(height: vSpacingMedium),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _orderDetailResponse!.feedback.length,
          separatorBuilder: (_, __) => Divider(
            color: isDarkMode ? Colors.white10 : Colors.grey.shade300,
            height: dividerHeight,
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
                  SizedBox(width: hPadding / 2),
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final hPadding = width * 0.025;
    final vPadding = height * 0.01;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: hPadding,
        vertical: vPadding,
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

  Widget _buildMainButton(
      BuildContext context, String text, Color color, VoidCallback onPressed) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final buttonWidth = width * 0.9;
    final buttonHeight = height * 0.06;
    final buttonFontSize = width * 0.04;
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.01,
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: buttonFontSize,
              ),
        ),
      ),
    );
  }

  Widget _buildPhoneRow(String phoneNumber) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final fontSize = width * 0.04;
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
              fontSize: fontSize,
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
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final vSpacingSmall = height * 0.015;
    final vPadding = height * 0.01;
    final activeUsers = _orderDetailResponse?.activeUsers ?? [];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: vSpacingSmall),
        if (activeUsers.isEmpty)
          Padding(
            padding: EdgeInsets.all(vPadding),
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
                  padding: EdgeInsets.only(bottom: vSpacingSmall),
                  child: _buildActiveUserCard(context, activeUsers[index]),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActiveUserCard(
      BuildContext context, Map<String, String> activeUser) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final hPadding = width * 0.04;
    final vPadding = height * 0.02;
    final vSpacingSmall = height * 0.005;
    final avatarRadius = width * 0.06;
    final iconSize = width * 0.05;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isAvailable = activeUser['shift_status'] != 'END';
    final username = activeUser['username']?.split('@').first ?? 'Unknown';
    final activeTasks = activeUser['active_tasks'] ?? '0';

    return GestureDetector(
      onTap: () => _showActiveUserDialog(context, activeUser),
      child: Container(
        padding: EdgeInsets.all(hPadding),
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppColors.darkCardBackgroundColor
              : AppColors.cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            // BoxShadow(
            //   color: (isDarkMode
            //           ? AppColors.darkShadowColor
            //           : AppColors.shadowColor)
            //       .withOpacity(0.25),
            //   blurRadius: 6,
            //   offset: const Offset(0, 3),
            // ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: isAvailable
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: isAvailable ? Colors.green : Colors.red,
                size: iconSize,
              ),
            ),
            SizedBox(width: hPadding),
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
                  SizedBox(height: vSpacingSmall),
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
              padding: EdgeInsets.symmetric(horizontal: hPadding / 2, vertical: vPadding / 2),
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