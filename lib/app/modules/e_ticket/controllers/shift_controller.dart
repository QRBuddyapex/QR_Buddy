import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/config/api_config.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';
import 'package:qr_buddy/app/core/services/shift_foreground_service.dart';
import 'package:qr_buddy/app/modules/e_ticket/controllers/location_dialog.dart';
import 'package:qr_buddy/app/routes/routes.dart';
 // Ensures startCallback is accessible

class ShiftController extends GetxController {
  final ApiService _apiService = ApiService();
  final TokenStorage _tokenStorage = TokenStorage();
  var shiftStatus = 'END'.obs; 

  @override
  void onInit() {
    super.onInit();
    Get.put(LocationDialogController(), permanent: true);
    _fetchCurrentShiftStatus();
  }

  Future<void> _fetchCurrentShiftStatus() async {
    final userId = await _tokenStorage.getUserId() ?? '2053';
    final hcoId = await _tokenStorage.getHcoId() ?? '46';
    final token = await _tokenStorage.getToken() ?? '';

    try {
      final response = await _apiService.post(
        '${AppUrl.baseUrl}/users.html?action=get_shift_status&user_id=$userId&hco_id=$hcoId',
        queryParameters: {
          'action': 'get_shift_status',
          'user_id': userId,
          'hco_id': hcoId,
          'phone_uuid': '',
          'hco_key': '0',
        },
        options: Options(
          headers: {'authorization': token},
        ),
      );
      if (response.statusCode == 200 && response.data['status'] == 1) {
        final newStatus = response.data['shift_status'] ?? 'END';
        shiftStatus.value = newStatus;
        // Manage foreground service based on fetched status
        await _manageForegroundService(newStatus);
      }
    } catch (e) {
      print('Error fetching shift status: $e');
    }
  }

  Future<void> startShift() async {
    final locationController = Get.find<LocationDialogController>();
    locationController.onSaveSuccess.value = () => updateShiftStatus('START');
    Get.dialog(
      const LocationDialog(),
      barrierDismissible: false,
    );
  }

  Future<void> updateShiftStatus(String status) async {
    final userId = await _tokenStorage.getUserId() ?? '2053';
    final hcoId = await _tokenStorage.getHcoId() ?? '46';
    final token = await _tokenStorage.getToken() ??
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NiIsIm5hbWUiOiIxQGRlbW8uY29tIiwidXNlcl90eXBlIjoiSENPX0FETUlOIn0=.115a9ed3718c5d61dd56181813cf620edc72e689f417520a948a9baa954f8c28';

    try {
      final response = await _apiService.post(
        '${AppUrl.baseUrl}/users.html?action=update_shift&user_id=$userId&hco_id=$hcoId',
        queryParameters: {
          'action': 'update_shift',
          'user_id': userId,
          'hco_id': hcoId,
          'phone_uuid': '',
          'hco_key': '0',
        },
        data: {'shift_status': status},
        options: Options(
          headers: {'authorization': token},
        ),
      );
      if (response.statusCode == 200 && response.data['status'] == 1) {
        shiftStatus.value = status;
        // Manage foreground service
        await _manageForegroundService(status);
        Get.snackbar(
          'Success',
          'Shift status updated to $status',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update shift status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  // Helper to manage foreground service
  Future<void> _manageForegroundService(String status) async {
    if (status == 'START' || status == 'BREAK') {
      final bool isRunning = await FlutterForegroundTask.isRunningService;
      final String text = status == 'START' ? 'Waiting for orders...' : 'On Break - Waiting for orders...';
      final List<NotificationButton> buttons = [
        const NotificationButton(id: 'break_shift', text: 'Take Break'),
        const NotificationButton(id: 'end_shift', text: 'End Shift'),
      ];

      if (isRunning) {
        // Update existing service
        await FlutterForegroundTask.updateService(
          notificationTitle: 'QR Buddy Shift Active',
          notificationText: text,
          notificationButtons: buttons,
        );
      } else {
        // Start new service
        final ServiceRequestResult result = await FlutterForegroundTask.startService(
          serviceId: 888,  // Required unique ID
          notificationTitle: 'QR Buddy Shift Active',
          notificationText: text,
          notificationIcon: null,  // Use null as per latest API; customize via AndroidNotificationOptions if needed
          notificationButtons: buttons,
          notificationInitialRoute: RoutesName.ticketDashboardView,  // Use your route constant
          callback: startCallback,
        );
        if (result case ServiceRequestSuccess()) {
          print('Shift service started successfully');
        } else {
          print('Failed to start shift service: $result');
        }
      }
    } else if (status == 'END') {
      final ServiceRequestResult result = await FlutterForegroundTask.stopService();
      if (result case ServiceRequestSuccess()) {
        print('Shift service stopped');
      } else {
        print('Failed to stop shift service: $result');
      }
    }
  }
}