import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_buddy/app/core/config/notifications_services.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/data/models/daily_checklist_model.dart';
import 'package:qr_buddy/app/data/models/e_tickets.dart';
import 'package:qr_buddy/app/data/models/ticket.dart';
import 'package:qr_buddy/app/data/repo/daily_checklist_repo.dart';
import 'package:qr_buddy/app/data/repo/e_ticket_repo.dart';
import 'package:qr_buddy/app/data/repo/food_delivery_repository.dart';
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

  var todayStatus = 0.0.obs;
  var flags = 90.obs;
  var comments = 17.obs;
  var schedules = 4.obs;
  var openIssues = 1.obs;
  var tasksCount = 0.obs;
  var documents = 0.obs;
  RxDouble averageRating = 0.0.obs;
  var totalChecklists = 0.obs;
  var logEntriesCount = 0.obs; // New observable for log entries count
  RxDouble reviewPending = 0.0.obs;

  var dailyChecklist = Rxn<DailyChecklistModel>();
  var startDate = DateTime.now().subtract(const Duration(days: 7)).obs;
  var endDate = DateTime.now().obs;
  var selectedCategory = 'No Category'.obs;
  var selectedLogDate = ''.obs;
  var isLoading = true.obs; // Initialize as true

  var _orders = <Order>[].obs;
  List<Order> get orders => _orders;

  late final TicketRepository _ticketRepository;
  late final OrderDetailRepository _orderDetailRepository;
  late final DailyChecklistRepository _dailyChecklistRepository;
  late final FoodDeliveryRepository _foodDeliveryRepository;

  final NotificationServices notificationServices = NotificationServices();

  final remarksController = TextEditingController();
  final holdDateTimeController = TextEditingController();
  var selectedImage = Rxn<File>();

  // Track completion of async operations
  final _completedFetches = <String, bool>{}.obs;

  Timer? _pollTimer;

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
    _dailyChecklistRepository = DailyChecklistRepository(
      ApiService(),
      TokenStorage(),
    );
    _foodDeliveryRepository = FoodDeliveryRepository(
      ApiService(),
      TokenStorage(),
    );

    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(null);
    notificationServices.isTokenRefresh();

    // Initialize fetch tracking
    _completedFetches.value = {
      'tickets': false,
      'foodDeliveries': false,
      'checklistLog': false,
      'eTickets': false,
    };

    // Start all fetches
    fetchTickets();
    fetchFoodDeliveries();
    fetchChecklistLog();

    // Poll for new food deliveries every minute
    _pollTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      fetchFoodDeliveries();
    });
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    remarksController.dispose();
    holdDateTimeController.dispose();
    super.onClose();
  }

  void _checkAllFetchesComplete() {
    if (_completedFetches.values.every((completed) => completed)) {
      isLoading.value = false;
    }
  }

  String formatDateForDisplay(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day-$month-$year';
  }

  String _formatDateForApi(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$year-$month-$day';
  }

  DateTime? _parseChecklistDate(String dateStr, String timeStr) {
    final dateTime = _parseShortDate(dateStr);
    final timeParts = timeStr.split(':');
    int hour = 0;
    int minute = 0;
    if (timeParts.isNotEmpty) {
      hour = int.tryParse(timeParts[0]) ?? 0;
    }
    if (timeParts.length > 1) {
      minute = int.tryParse(timeParts[1]) ?? 0;
    }
    return DateTime(dateTime.year, dateTime.month, dateTime.day, hour, minute);
  }

  DateTime _parseShortDate(String dateStr) {
    final parts = dateStr.trim().split(' ');
    if (parts.length != 2) {
      return DateTime.now();
    }

    final day = int.tryParse(parts[0]) ?? 1;
    const monthMap = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };

    final month = monthMap[parts[1]] ?? 1;
    return DateTime(2025, month, day);
  }

  void updateFilteredChecklists() {
    if (dailyChecklist.value == null) return;

    int checklistCount = 0;
    final filteredChecklistsTemp = <Map<String, dynamic>>[];
    DateTime filterStart, filterEnd;
    if (selectedLogDate.value.isNotEmpty) {
      final parsed = _parseShortDate(selectedLogDate.value);
      filterStart = DateTime(parsed.year, parsed.month, parsed.day);
      filterEnd = filterStart.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));
    } else {
      filterStart = DateTime(startDate.value.year, startDate.value.month, startDate.value.day);
      filterEnd = DateTime(endDate.value.year, endDate.value.month, endDate.value.day, 23, 59, 59);
    }

    dailyChecklist.value!.roundData.forEach((roomId, dateMap) {
      dateMap.forEach((dateKey, rounds) {
        for (var round in rounds) {
          final timeStr = round.timeSchedule ?? '00:00';
          final fullDateTime = _parseChecklistDate(dateKey, timeStr);
          if (fullDateTime != null &&
              fullDateTime.isAfter(filterStart.subtract(const Duration(microseconds: 1))) &&
              fullDateTime.isBefore(filterEnd.add(const Duration(microseconds: 1)))) {
            checklistCount += 1;
            final room = dailyChecklist.value!.rooms[roomId];
            filteredChecklistsTemp.add({
              'checklist_name': round.itemName ?? 'Checklist',
              'location': '${room?.blockName ?? 'Unknown'} - ${room?.floorName ?? 'Unknown'}',
              'date_and_time': '${dateKey} $timeStr',
            });
          }
        }
      });
    });

    checklists.value = [
      {
        'group': 'All Checklists',
        'checklists': filteredChecklistsTemp,
      }
    ];
    totalChecklists.value = checklistCount;
    logEntriesCount.value = checklistCount;
  }

  Future<void> fetchChecklistLog() async {
    try {
      final hcoId = await TokenStorage().getHcoId();
      final userId = await TokenStorage().getUserId();
      const phoneUuid = '5678b6baf95911ef8b460200d429951a';
      if (hcoId == null || userId == null) {
        Get.snackbar('Error', 'HCO ID or User ID not found');
        _completedFetches['checklistLog'] = true;
        _checkAllFetchesComplete();
        return;
      }

      final categories = dailyChecklist.value?.categories ?? [];
      String? categoryId;
      if (selectedCategory.value != 'No Category') {
        final selected = categories.firstWhereOrNull(
            (cat) => cat.categoryName == selectedCategory.value);
        categoryId = selected?.id;
      }

      final response = await _dailyChecklistRepository.fetchDailyChecklist(
        hcoId: hcoId,
        userId: userId,
        phoneUuid: phoneUuid,
        dateFrom: _formatDateForApi(startDate.value),
        dateTo: _formatDateForApi(endDate.value),
        categoryId: categoryId,
      );
      // Copy checklist log to clipboard
  
      // await Clipboard.setData(ClipboardData(text: response.toString()));
      // print('Checklist log copied to clipboard');

      dailyChecklist.value = response;

      selectedLogDate.value = '';
      updateFilteredChecklists();

      print('Fetched ${logEntriesCount.value} log entries and ${totalChecklists.value} checklists');
    } catch (e) {
      // Get.snackbar('Error', 'Failed to fetch checklist log: $e');
      dailyChecklist.value = null;
      totalChecklists.value = 0;
      logEntriesCount.value = 0; // Reset log entries count on error
      checklists.value = [];
      print('Error in fetchChecklistLog: $e');
    } finally {
      _completedFetches['checklistLog'] = true;
      _checkAllFetchesComplete();
    }
  }

  Future<void> fetchTickets() async {
    try {
      final response = await _ticketRepository.fetchTickets(
        hcoId: await TokenStorage().getHcoId() ?? '',
        requestStatus: _mapFilterToRequestStatus(selectedFilter.value),
      );
      tickets.assignAll(response.orders.map((order) => order.toTicket()).toList());
      links.assignAll(response.links);
      _orders.assignAll(response.orders);

      final completedOrders = _orders.where((order) => order.requestStatus == 'COMP').toList();
      final validRatings = completedOrders
          .where((order) => order.rating != '-1' && double.tryParse(order.rating) != null)
          .toList();
      reviewPending.value = (completedOrders.length - validRatings.length).toDouble();

      if (validRatings.isNotEmpty) {
        final ratings = validRatings.map((order) => double.parse(order.rating)).toList();
        averageRating.value = ratings.reduce((a, b) => a + b) / ratings.length;
      } else {
        averageRating.value = 0.0;
      }

      int assignedTickets = links
          .firstWhere(
            (link) => link.type == 'ASI',
            orElse: () => Link(type: 'ASI', title: 'Assigned', count: 0),
          )
          .count;
      int completedTickets = links
          .firstWhere(
            (link) => link.type == 'COMP',
            orElse: () => Link(type: 'COMP', title: 'Completed', count: 0),
          )
          .count;

      if (assignedTickets > 0) {
        todayStatus.value = ((completedTickets * 100) / assignedTickets).clamp(0, 100).toDouble();
      } else {
        todayStatus.value = 0.0;
      }
      updateTicketList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch tickets: $e');
    } finally {
      _completedFetches['tickets'] = true;
      _checkAllFetchesComplete();
    }
  }

  Future<void> fetchFoodDeliveries() async {
    try {
      final userId = await TokenStorage().getUserId() ?? '2055';
      final newTasksData = await _foodDeliveryRepository.fetchFoodDeliveries(userId: userId);
      
      // Collect old UUIDs
      final Set<String> oldUuids = {};
      for (final group in tasks) {
        for (final task in (group['tasks'] as List)) {
          final uuid = task['uuid']?.toString() ?? '';
          if (uuid.isNotEmpty) oldUuids.add(uuid);
        }
      }
      
      // Collect new UUIDs
      final Set<String> newUuids = {};
      bool hasNew = false;
      for (final group in newTasksData) {
        for (final task in (group['tasks'] as List)) {
          final uuid = task['uuid']?.toString() ?? '';
          if (uuid.isNotEmpty) {
            newUuids.add(uuid);
            if (!oldUuids.contains(uuid)) {
              hasNew = true;
            }
          }
        }
      }
      
      if (hasNew) {
        tasks.assignAll(newTasksData);
        print('Fetched ${tasks.length} task groups with new items');
        updateTasksCount();

        // Trigger static notification for new food delivery
        await notificationServices.showInAppNotificationWithSound(
          title: '🍱 Food Delivery Assigned',
          body: 'You have a new food delivery order waiting.',
          location: 'Block B1, Room 204',
          task: 'View Delivery Details',
          ticketId: 'FD-2025-001',
        );
      } else {
        print('No new food deliveries');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch food deliveries: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      _completedFetches['foodDeliveries'] = true;
      _checkAllFetchesComplete();
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
    if (card == 'Checklists') {
      fetchChecklistLog();
    }
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

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
        holdDateTimeController.text =
            '${selectedDateTime.day.toString().padLeft(2, '0')}-'
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final hPadding = width * 0.04;
    final vPadding = height * 0.01;
    final fontSize = width * 0.045;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackgroundColor,
          title: Padding(
            padding: EdgeInsets.all(hPadding),
            child: Text(
              'Confirm $action',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ),
            ),
          ),
          content: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPadding),
            child: Text(
              'Do you want to $action this request?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: fontSize * 0.8,
                  ),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'No',
                        style: TextStyle(
                          color: AppColors.dangerButtonColor,
                          fontSize: fontSize * 0.9,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: hPadding),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: fontSize * 0.9,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void showActionFormDialog(BuildContext context, String action, String orderNumber, String serviceLabel, String orderId,
      {Function(Map<String, dynamic>)? onSuccess}) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final hPadding = width * 0.04;
    final vPadding = height * 0.01;
    final vSpacingSmall = height * 0.012;
    final vSpacingMedium = height * 0.025;
    final fontSizeLarge = width * 0.045;
    final fontSizeSmall = width * 0.035;
    final imageSize = width * 0.25;
    final imagePadding = width * 0.05;
    final buttonHeight = height * 0.055;
    final borderRadius = width * 0.025;
    final iconSize = width * 0.05;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackgroundColor,
          title: Padding(
            padding: EdgeInsets.all(hPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderNumber,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSizeLarge,
                      ),
                ),
                SizedBox(height: vSpacingSmall),
                Text(
                  serviceLabel,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSizeLarge,
                      ),
                ),
                SizedBox(height: vSpacingSmall),
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.hintTextColor, size: iconSize),
                  onPressed: () {
                    clearDialogFields();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (action == 'Hold') ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPadding),
                    child: Text(
                      'For how long do you want to hold this request?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: fontSizeSmall,
                          ),
                    ),
                  ),
                  SizedBox(height: vSpacingSmall),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPadding),
                    child: TextField(
                      controller: holdDateTimeController,
                      readOnly: true,
                      onTap: () => pickDateTime(context),
                      decoration: InputDecoration(
                        hintText: 'dd-mm-yyyy --:--',
                        hintStyle: TextStyle(color: AppColors.hintTextColor, fontSize: fontSizeSmall),
                        suffixIcon: Icon(Icons.calendar_today, color: AppColors.hintTextColor, size: iconSize),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                          borderSide: BorderSide(color: AppColors.borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                          borderSide: BorderSide(color: AppColors.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: vSpacingSmall),
                ],
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPadding),
                  child: Text(
                    'Comment on your contribution to the request process',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: fontSizeSmall,
                        ),
                  ),
                ),
                SizedBox(height: vSpacingSmall),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPadding),
                  child: TextField(
                    controller: remarksController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Enter remarks',
                      hintStyle: TextStyle(color: AppColors.hintTextColor, fontSize: fontSizeSmall),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                        borderSide: BorderSide(color: AppColors.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                        borderSide: BorderSide(color: AppColors.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                        borderSide: BorderSide(color: AppColors.primaryColor),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: vSpacingMedium),
                Obx(() => Center(
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: AppColors.cardBackgroundColor,
                            builder: (BuildContext context) {
                              final bottomSheetSize = MediaQuery.of(context).size;
                              final bottomSheetWidth = bottomSheetSize.width;
                              final bottomSheetHeight = bottomSheetSize.height;
                              final bottomSheetHPadding = bottomSheetWidth * 0.04;
                              final bottomSheetIconSize = bottomSheetWidth * 0.05;
                              final bottomSheetFontSize = bottomSheetWidth * 0.04;
                              return SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.camera_alt, color: AppColors.hintTextColor, size: bottomSheetIconSize),
                                      title: Text(
                                        'Take a Photo',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontSize: bottomSheetFontSize,
                                            ),
                                      ),
                                      onTap: () {
                                        pickImage(ImageSource.camera);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    if (selectedImage.value != null)
                                      ListTile(
                                        leading: Icon(Icons.delete, color: AppColors.dangerButtonColor, size: bottomSheetIconSize),
                                        title: Text(
                                          'Remove Image',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: AppColors.dangerButtonColor,
                                                fontSize: bottomSheetFontSize,
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
                          padding: EdgeInsets.all(imagePadding),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                          child: selectedImage.value == null
                              ? Icon(
                                  Icons.camera_alt,
                                  color: AppColors.primaryColor,
                                  size: imageSize * 0.8,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(borderRadius),
                                  child: Image.file(
                                    selectedImage.value!,
                                    width: imageSize,
                                    height: imageSize,
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
                    final response = await updateRequest(action: action, orderId: orderId);
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
                    borderRadius: BorderRadius.circular(borderRadius * 1.5),
                  ),
                  minimumSize: Size(double.infinity, buttonHeight),
                ),
                child: Text(
                  'Submit',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSizeSmall,
                      ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double getAverageRatingForCompleted() {
    final completedOrders = tickets
        .where((ticket) => ticket.status == 'Completed')
        .map((ticket) => _orders.firstWhere((order) => order.uuid == ticket.uuid))
        .where((order) => order.rating != '-1' && double.tryParse(order.rating) != null)
        .toList();

    if (completedOrders.isEmpty) return 0.0;

    final validRatings = completedOrders.map((order) => double.parse(order.rating)).toList();
    return validRatings.isNotEmpty ? (validRatings.reduce((a, b) => a + b) / validRatings.length) : 0.0;
  }

  int getRatedCompletedCount() {
    return tickets
        .where((ticket) => ticket.status == 'Completed')
        .map((ticket) => _orders.firstWhere((order) => order.uuid == ticket.uuid))
        .where((order) => order.rating != '-1' && double.tryParse(order.rating) != null)
        .length;
  }
}