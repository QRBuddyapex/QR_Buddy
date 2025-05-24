import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/data/models/order_details_model.dart' as orderModel;
import 'package:qr_buddy/app/data/models/ticket.dart';
import 'package:qr_buddy/app/data/repo/ticket_details_repo.dart';
import 'package:qr_buddy/app/modules/e_ticket/controllers/ticket_controller.dart';
import 'package:qr_buddy/app/routes/routes.dart';

class AcceptTicketScreen extends StatefulWidget {
  final Ticket ticket;

  const AcceptTicketScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  _AcceptTicketScreenState createState() => _AcceptTicketScreenState();
}

class _AcceptTicketScreenState extends State<AcceptTicketScreen> {
  final TicketController ticketController = Get.find<TicketController>();
  late OrderDetailRepository _repository;
  orderModel.OrderDetailResponse? _orderDetailResponse;
  bool _isLoading = true;
  String? _errorMessage;

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
        _errorMessage = 'Failed to fetch order details: $e';
      });
      Get.snackbar(
        'Error',
        'Failed to load ticket details: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  void _showConfirmationDialog(BuildContext context) {
    if (_orderDetailResponse == null) {
      Get.snackbar(
        'Error',
        'Cannot accept ticket: Order details not loaded',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    ticketController.showConfirmationDialog(
      context,
      'Accept',
      () => ticketController.showActionFormDialog(
        context,
        'Accept',
        widget.ticket.orderNumber,
        widget.ticket.serviceLabel,
        _orderDetailResponse!.order.id, // Use order.id
        onSuccess: (response) {
          Get.toNamed(RoutesName.ticketDashboardView);
          ticketController.fetchTickets();
        },
      ),
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
            widget.ticket.serviceLabel,
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
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : SingleChildScrollView(
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
                                widget.ticket.orderNumber,
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
                                '${widget.ticket.department} ${widget.ticket.block}/${widget.ticket.department}',
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
                            _buildInfoTextRow(
                                context, 'Remarks', (widget.ticket.isQuickRequest ?? false) ? "Quick Request" : "Normal Request"),
                            const SizedBox(height: 10),
                            _buildInfoTextRow(context, 'Priority', widget.ticket.status ?? ''),
                            const SizedBox(height: 10),
                            _buildInfoTextRow(context, 'Department', 'E & M'),
                            const SizedBox(height: 10),
                            _buildInfoTextRow(context, 'Room', widget.ticket.department ?? ''),
                            const SizedBox(height: 10),
                            _buildInfoTextRow(context, 'Location', '${widget.ticket.block}/${widget.ticket.department}'),
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