// shift_controller.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/config/api_config.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';
import 'package:qr_buddy/app/core/services/shift_foreground_service.dart';
import 'package:qr_buddy/app/modules/e_ticket/controllers/location_dialog.dart';

class ShiftController extends GetxController {
  final ApiService _apiService = ApiService();
  final TokenStorage _tokenStorage = TokenStorage();
  var shiftStatus = 'END'.obs;

  @override
  void onInit() {
    super.onInit();
    Get.put(LocationDialogController(), permanent: true);
    _fetchCurrentShiftStatus();
    // Listen for data from the foreground service.
    FlutterForegroundTask.addTaskDataCallback(_onReceiveShiftData);
  }

  void _onReceiveShiftData(Object? data) {
    if (data is Map<String, dynamic>) {
      print('Received from shift service: $data');
      final String event = data['event'] ?? '';
      // Use updateShiftStatus for actions that require an API call
      // and directly update status for sync events.
      switch (event) {
        case 'take_break':
          updateShiftStatus('BREAK');
          break;
        case 'resume_shift':
          updateShiftStatus('START');
          break;
        case 'end_shift':
          updateShiftStatus('END');
          break;
        case 'shift_ended':
          shiftStatus.value = 'END';
          break;
      }
    }
  }
  
  @override
  void onClose() {
    // It's good practice to remove the callback when the controller is destroyed.
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveShiftData);
    super.onClose();
  }

  Future<void> _fetchCurrentShiftStatus() async {
    final userId = await _tokenStorage.getUserId();
    final hcoId = await _tokenStorage.getHcoId();
    final token = await _tokenStorage.getToken();

    if (userId == null || hcoId == null || token == null) {
      print('User details not found, cannot fetch shift status.');
      shiftStatus.value = await _tokenStorage.getShiftStatus() ?? 'END';
      return;
    }

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
        await _tokenStorage.saveShiftStatus(newStatus);
        await _manageForegroundService(newStatus);
      }
    } catch (e) {
      print('Error fetching shift status: $e');
      final localStatus = await _tokenStorage.getShiftStatus();
      if (localStatus != null) {
        shiftStatus.value = localStatus;
        await _manageForegroundService(localStatus);
      }
    }

    final pendingStatus = await _tokenStorage.getPendingShiftStatus();
    if (pendingStatus != null && pendingStatus != shiftStatus.value) {
      print('Applying pending shift status: $pendingStatus');
      await updateShiftStatus(pendingStatus);
      await _tokenStorage.clearPendingShiftStatus();
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
    final userId = await _tokenStorage.getUserId();
    final hcoId = await _tokenStorage.getHcoId();
    final token = await _tokenStorage.getToken();

    if (userId == null || hcoId == null || token == null) {
       Get.snackbar('Error', 'User not logged in.', backgroundColor: Colors.red);
       return;
    }

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
        await _tokenStorage.saveShiftStatus(status);
        await _manageForegroundService(status);
        Get.snackbar(
          'Success',
          'Shift status updated to $status',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update status');
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
Future<void> _manageForegroundService(String status) async {
  final isOverlayPermitted = await FlutterOverlayWindow.isPermissionGranted();
  if (!isOverlayPermitted) {
    await FlutterOverlayWindow.requestPermission();
  }

  if (status == 'START' || status == 'BREAK') {
    final text = status == 'START'
        ? 'Waiting for orders...'
        : 'On Break - Waiting for orders...';

    final buttons = status == 'START'
        ? [
            const NotificationButton(id: 'take_break', text: 'Take Break'),
            const NotificationButton(id: 'end_shift', text: 'End Shift'),
          ]
        : [
            const NotificationButton(id: 'resume_shift', text: 'Resume Shift'),
            const NotificationButton(id: 'end_shift', text: 'End Shift'),
          ];

    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.updateService(
        notificationTitle: 'QR Buddy Shift Active',
        notificationText: text,
        notificationButtons: buttons,
      );
    } else {
      await FlutterForegroundTask.startService(
        notificationTitle: 'QR Buddy Shift Active',
        notificationText: text,
        notificationButtons: buttons,
        callback: startCallback,
      );
    }

    if (await FlutterOverlayWindow.isPermissionGranted()) {
      if (await FlutterOverlayWindow.isActive()) {
        await FlutterOverlayWindow.closeOverlay();
      }
      await FlutterOverlayWindow.showOverlay(
        height: 80,
        width: 80,
        enableDrag: true,
        flag: OverlayFlag.defaultFlag,
        alignment: OverlayAlignment.topRight,
      );
    }

  } else if (status == 'END') {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
    }
  }
}
}