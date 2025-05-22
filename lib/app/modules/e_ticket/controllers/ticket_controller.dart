import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/data/models/e_tickets.dart';
import 'package:qr_buddy/app/data/models/ticket.dart';
import 'package:qr_buddy/app/data/repo/e_ticket_repo.dart';
import 'package:qr_buddy/app/data/repo/ticket_details_repo.dart';
import 'package:qr_buddy/app/routes/routes.dart';
import 'package:url_launcher/url_launcher.dart';

class TicketController extends GetxController {
  var selectedFilter = 'All'.obs;
  var tickets = <Ticket>[].obs;
  var filteredTickets = <Ticket>[].obs;
  var links = <Link>[].obs;
  var selectedInfoCard = 'E-Tickets'.obs;

  var tasks = <Map<String, dynamic>>[].obs;
  var checklists = <Map<String, dynamic>>[].obs;

  var todayStatus = 50.0.obs;
  var flags = 90.obs;
  var comments = 17.obs;
  var missed = 20.obs;
  var reviewPending = 6.obs;
  var schedules = 4.obs;
  var openIssues = 1.obs;
  var tasksCount = 0.obs;
  var documents = 0.obs;

  late final TicketRepository _ticketRepository;
  late final OrderDetailRepository _orderDetailRepository;

  final remarksController = TextEditingController();
  final holdDateTimeController = TextEditingController();
  var selectedImage = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    _ticketRepository = TicketRepository(
      ApiService(),
      TokenStorage(),
    );
    _orderDetailRepository = OrderDetailRepository(
      ApiService(),
      TokenStorage(),
    );
    fetchTickets();
    fetchTasks();
    fetchChecklists();
    updateTasksCount();
  }

  @override
  void onClose() {
    remarksController.dispose();
    holdDateTimeController.dispose();
    super.onClose();
  }

  Future<void> fetchTickets() async {
    try {
      final response = await _ticketRepository.fetchTickets(
        hcoId: await TokenStorage().getHcoId() ?? '',
        requestStatus: _mapFilterToRequestStatus(selectedFilter.value),
      );
      tickets.assignAll(response.orders.map((order) => order.toTicket()).toList());
      links.assignAll(response.links);
      updateTicketList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch tickets: $e');
    }
  }

  String _mapFilterToRequestStatus(String filter) {
    switch (filter) {
      case 'New':
        return 'NEW';
      case 'Assigned':
        return 'ASI';
      case 'Accepted':
        return 'ACC';
      case 'Completed':
        return 'COMP';
      case 'Verified':
        return 'VER';
      case 'On Hold':
        return 'HOLD';
      case 'Re-Open':
        return 'REO';
      case 'Cancelled':
        return 'CAN';
      case 'Total':
      case 'All':
      default:
        return 'ALL';
    }
  }

  void fetchTasks() {
    tasks.clear();
    tasks.assignAll([
      {
        'group': 'Dummy Group 1',
        'tasks': [
          {
            'taskName': 'Integrate payment method',
            'assigned': ['RM', 'MK', 'AS'],
            'priority': 'High',
            'dueDate': 'Due Date',
            'notes': 'This is a note',
            'lastUpdated': 'Last Updated',
          },
          {
            'taskName': 'Implement cart functionality',
            'assigned': ['RM', 'MK', 'AS'],
            'priority': 'High',
            'dueDate': 'Due Date',
            'notes': 'This is important',
            'lastUpdated': 'Last Updated',
          },
        ],
      },
      {
        'group': 'Dummy Group 2',
        'tasks': [
          {
            'taskName': 'Book a flight ticket from inc',
            'assigned': ['AS'],
            'priority': 'Low',
            'dueDate': 'Due Date',
            'notes': 'Business class',
            'lastUpdated': '5/2/2025, 10:10:08 AM',
          },
        ],
      },
    ]);
    updateTasksCount();
  }

  void fetchChecklists() {
    checklists.clear();
    checklists.assignAll([
      {
        'group': 'Checklist Group 1',
        'checklists': [
          {
            'checklist_name': 'Safety Inspection',
            'location': 'Block A/GF',
            'date_and_time': '15/04/2025, 09:00 AM',
          },
          {
            'checklist_name': 'Equipment Check',
            'location': 'Block B/1F',
            'date_and_time': '15/04/2025, 11:00 AM',
          },
        ],
      },
      {
        'group': 'Checklist Group 2',
        'checklists': [
          {
            'checklist_name': 'Fire Drill',
            'location': 'Block C/2F',
            'date_and_time': '16/04/2025, 02:00 PM',
          },
        ],
      },
    ]);
  }

  void updateTasksCount() {
    int totalTasks = tasks.fold(0, (sum, group) => sum + (group['tasks'] as List).length);
    tasksCount.value = totalTasks;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    fetchTickets();
  }

  void setSelectedInfoCard(String card) {
    selectedInfoCard.value = card;
  }

  void navigateToDetail(Ticket ticket) {
    if (ticket.uuid!.isEmpty) {
      Get.snackbar('Error', 'Order ID (UUID) is missing for this ticket');
      return;
    }
    Get.toNamed(RoutesName.ticketDetailsView, arguments: ticket);
  }

  void dialPhone(String phoneNumber) async {
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

  void updateTicketList() {
    switch (selectedFilter.value) {
      case 'New':
        filteredTickets.assignAll(tickets.where((ticket) => ticket.status == 'New').toList());
        break;
      case 'Assigned':
        filteredTickets.assignAll(tickets.where((ticket) => ticket.status == 'Assigned').toList());
        break;
      case 'Accepted':
        filteredTickets.assignAll(tickets.where((ticket) => ticket.status == 'Accepted').toList());
        break;
      case 'Completed':
        filteredTickets.assignAll(tickets.where((ticket) => ticket.status == 'Completed').toList());
        break;
      case 'Verified':
        filteredTickets.assignAll(tickets.where((ticket) => ticket.status == 'Verified').toList());
        break;
      case 'On Hold':
        filteredTickets.assignAll(tickets.where((ticket) => ticket.status == 'On Hold').toList());
        break;
      case 'Re-Open':
        filteredTickets.assignAll(tickets.where((ticket) => ticket.status == 'Re-Open').toList());
        break;
      case 'Cancelled':
        filteredTickets.assignAll(tickets.where((ticket) => ticket.status == 'Cancelled').toList());
        break;
      case 'Total':
      case 'All':
      default:
        filteredTickets.assignAll(tickets);
        break;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  void clearImage() {
    selectedImage.value = null;
  }

  Future<void> pickDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        holdDateTimeController.text = '${selectedDateTime.day.toString().padLeft(2, '0')}-'
            '${selectedDateTime.month.toString().padLeft(2, '0')}-'
            '${selectedDateTime.year} '
            '${selectedDateTime.hour.toString().padLeft(2, '0')}:'
            '${selectedDateTime.minute.toString().padLeft(2, '0')}';
      }
    }
  }

  void clearDialogFields() {
    remarksController.clear();
    holdDateTimeController.clear();
    selectedImage.value = null;
  }

  Future<Map<String, dynamic>> updateRequest({
    required String action,
    required String orderId,
  }) async {
    try {
      final userId = await TokenStorage().getUserId() ?? '';
      final hcoId = await TokenStorage().getHcoId() ?? '';
      final phoneUuid = '5678b6baf95911ef8b460200d429951a';
      final hcoKey = '0';
      final remarks = remarksController.text;
      final timeHoldTill = action == 'Hold' ? holdDateTimeController.text : '';

      // Map action to request_status
      final requestStatus = {
        'Accept': 'ACC',
        'Complete': 'COMP',
        'Hold': 'HOLD',
        'Cancel': 'CAN',
        'Reopen': 'REO',
        'Verify': 'VER',
      }[action] ?? 'CAN';

      dio.MultipartFile? file;
      if (selectedImage.value != null) {
        file = await dio.MultipartFile.fromFile(
          selectedImage.value!.path,
          filename: 'image.jpg',
        );
      }

      final response = await _orderDetailRepository.updateRequest(
        userId: userId,
        hcoId: hcoId,
        orderId: orderId,
        phoneUuid: phoneUuid,
        hcoKey: hcoKey,
        requestStatus: requestStatus,
        remarks: remarks,
        timeHoldTill: timeHoldTill.isNotEmpty ? timeHoldTill : null,
        file: file,
      );

      Get.snackbar(
        'Success',
        '$action action submitted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );

      return response;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit $action action: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      rethrow;
    }
  }

  void showConfirmationDialog(BuildContext context, String action, Function onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackgroundColor,
          title: Text(
            'Confirm $action',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          content: Text(
            'Do you want to $action this request?',
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
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
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

  void showActionFormDialog(
    BuildContext context,
    String action,
    String orderNumber,
    String serviceLabel, {
    Function(Map<String, dynamic>)? onSuccess,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackgroundColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderNumber,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                serviceLabel,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.hintTextColor),
                onPressed: () {
                  clearDialogFields();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (action == 'Hold') ...[
                  Text(
                    'For how long do you want to hold this request?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: holdDateTimeController,
                    readOnly: true,
                    onTap: () => pickDateTime(context),
                    decoration: InputDecoration(
                      hintText: 'dd-mm-yyyy --:--',
                      hintStyle: TextStyle(color: AppColors.hintTextColor),
                      suffixIcon: const Icon(Icons.calendar_today, color: AppColors.hintTextColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Text(
                  'Comment on your contribution to the request process',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: remarksController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Enter remarks',
                    hintStyle: TextStyle(color: AppColors.hintTextColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() => Center(
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: AppColors.cardBackgroundColor,
                            builder: (BuildContext context) {
                              return SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.photo_library, color: AppColors.hintTextColor),
                                      title: Text(
                                        'Pick from Gallery',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      onTap: () {
                                        pickImage(ImageSource.gallery);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt, color: AppColors.hintTextColor),
                                      title: Text(
                                        'Take a Photo',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      onTap: () {
                                        pickImage(ImageSource.camera);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    if (selectedImage.value != null)
                                      ListTile(
                                        leading: const Icon(Icons.delete, color: AppColors.dangerButtonColor),
                                        title: Text(
                                          'Remove Image',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: AppColors.dangerButtonColor,
                                              ),
                                        ),
                                        onTap: () {
                                          clearImage();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: selectedImage.value == null
                              ? const Icon(
                                  Icons.camera_alt,
                                  color: AppColors.primaryColor,
                                  size: 40,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    selectedImage.value!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final response = await updateRequest(action: action, orderId: orderNumber);
                    Navigator.of(context).pop();
                    clearDialogFields();
                    await fetchTickets();
                    onSuccess?.call(response);
                  } catch (e) {
                    // Error handling is already done in updateRequest
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Submit',
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
  }
}