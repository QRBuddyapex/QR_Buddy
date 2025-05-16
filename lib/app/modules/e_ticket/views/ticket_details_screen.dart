import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/core/widgets/custom_buttom.dart';
import 'package:qr_buddy/app/data/models/order_details_model.dart';
import 'package:qr_buddy/app/data/models/ticket.dart';
import 'package:qr_buddy/app/data/repo/ticket_details_repo.dart';
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

  @override
  void initState() {
    super.initState();
    _repository = OrderDetailRepository(ApiService(), TokenStorage());
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    try {
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
                : _buildOrderDetailContent(context),
      ),
    );
  }

  Widget _buildOrderDetailContent(BuildContext context) {
    final order = _orderDetailResponse!.order;
    final activeUser = _orderDetailResponse!.activeUsers.isNotEmpty ? _orderDetailResponse!.activeUsers[0] : null;

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
              const SizedBox(height: 10),
              _buildCancelButton(context),
              const SizedBox(height: 20),
              _buildTransferToField(context),
              const SizedBox(height: 10),
              if (activeUser != null) _buildActiveUserCard(context, activeUser),
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomButton(
              width: context.width * 0.22,
              onPressed: () {},
              text: 'Accept',
              color: AppColors.primaryColor,
            ),
            CustomButton(
              width: context.width * 0.22,
              onPressed: () {},
              text: 'Start',
              color: AppColors.whatsappIconColor,
            ),
            CustomButton(
              width: context.width * 0.22,
              onPressed: () {},
              text: 'Complete',
              color: AppColors.statusButtonColor,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomButton(
              width: context.width * 0.22,
              onPressed: () {},
              text: 'Hold',
              color: AppColors.holdButtonColor,
            ),
            CustomButton(
              width: context.width * 0.22,
              onPressed: () {},
              text: 'Reopen',
              color: AppColors.statusButtonColor1,
            ),
            CustomButton(
              width: context.width * 0.22,
              onPressed: () {},
              text: 'Verify',
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return Center(
      child: CustomButton(
        width: context.width * 0.22,
        onPressed: () {},
        text: 'Cancel',
        color: AppColors.dangerButtonColor,
      ),
    );
  }

  Widget _buildTransferToField(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Transfer to',
        suffixIcon: const Icon(Icons.search),
        labelStyle: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _buildActiveUserCard(BuildContext context, ActiveUser activeUser) {
    return SafeArea(
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
                activeUser.username,
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
                      color: activeUser.shiftStatus == 'END' ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _orderDetailResponse!.history.length,
      itemBuilder: (context, index) {
        final history = _orderDetailResponse!.history[index];
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
                history.type == 'ESC' ? Icons.flag : Icons.person,
                color: history.type == 'ESC'
                    ? AppColors.escalationIconColor
                    : AppColors.assignmentIconColor,
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