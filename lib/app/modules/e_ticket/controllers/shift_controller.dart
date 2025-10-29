// shift_controller.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/config/api_config.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';
import 'package:qr_buddy/app/core/services/native_shift_service.dart';
import 'package:qr_buddy/app/modules/e_ticket/controllers/location_dialog.dart';

class ShiftController extends GetxController with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  final TokenStorage _tokenStorage = TokenStorage();
  var shiftStatus = 'END'.obs;
  var isAppInBackground = false.obs;

  @override
  void onInit() {
    super.onInit();
    Get.put(LocationDialogController(), permanent: true);
    WidgetsBinding.instance.addObserver(this);
    _fetchCurrentShiftStatus();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        isAppInBackground.value = true;
        _syncFloatingService();
        break;
      case AppLifecycleState.resumed:
        isAppInBackground.value = false;
        _syncFloatingService();
        break;
      default:
        break;
    }
  }

  Future<void> _fetchCurrentShiftStatus() async {
    final userId = await _tokenStorage.getUserId();
    final hcoId = await _tokenStorage.getHcoId();
    final token = await _tokenStorage.getToken();

    if (userId == null || hcoId == null || token == null) {
      print('User details not found, cannot fetch shift status.');
      shiftStatus.value = await _tokenStorage.getShiftStatus() ?? 'END';
      await _syncFloatingService();
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
        await _syncFloatingService();
      }
    } catch (e) {
      print('Error fetching shift status: $e');
      final localStatus = await _tokenStorage.getShiftStatus();
      if (localStatus != null) {
        shiftStatus.value = localStatus;
        await _manageForegroundService(localStatus);
        await _syncFloatingService();
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
    if (shiftStatus.value == status) return; // prevent duplicate calls

    final userId = await _tokenStorage.getUserId();
    final hcoId = await _tokenStorage.getHcoId();
    final token = await _tokenStorage.getToken();

    if (userId == null || hcoId == null || token == null) {
      Get.snackbar('Error', 'User not logged in.', backgroundColor: Colors.red);
      return;
    }

    shiftStatus.value = status; // optimistically update UI

    try {
      final response = await _apiService.post(
        '${AppUrl.baseUrl}/users.html?action=update_shift&user_id=$userId&hco_id=$hcoId',
        data: {'shift_status': status},
        options: Options(
          headers: {'authorization': token},
        ),
      );
      if (response.statusCode == 200 && response.data['status'] == 1) {
        await _tokenStorage.saveShiftStatus(status);
        await _manageForegroundService(status);
        await _syncFloatingService();
        Get.snackbar('Success', 'Shift status updated to $status',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update status');
      }
    } catch (e) {
      // rollback status
      final oldStatus = await _tokenStorage.getShiftStatus() ?? 'END';
      shiftStatus.value = oldStatus;
      await _syncFloatingService();
      Get.snackbar('Error', 'Failed to update shift status: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white);
    }
  }

  Future<void> _syncFloatingService() async {
    final shouldShowFloating = shiftStatus.value == 'START' && isAppInBackground.value;
    if (shouldShowFloating) {
      await _startFloatingService();
    } else {
      await _stopFloatingService();
    }
  }

  Future<void> _startFloatingService() async {
    // Assuming NativeShiftService has a method to start the floating icon service
    // If not, implement via MethodChannel:
    // const channel = MethodChannel('com.nxtdesigns.qrbuddy_v2/floating');
    // await channel.invokeMethod('startFloatingService');
    await NativeShiftService.startFloatingIcon();
  }

  Future<void> _stopFloatingService() async {
    // Assuming NativeShiftService has a method to stop the floating icon service
    // If not, implement via MethodChannel:
    // const channel = MethodChannel('com.nxtdesigns.qrbuddy_v2/floating');
    // await channel.invokeMethod('stopFloatingService');
    await NativeShiftService.stopFloatingIcon();
  }

  Future<void> _manageForegroundService(String status) async {
    // Keep existing logic for other shift management (e.g., tracking), but floating is handled separately in _syncFloatingService
    if (status == 'START') {
      await NativeShiftService.startShift();
    } else if (status == 'BREAK') {
      await NativeShiftService.takeBreak();
    } else if (status == 'START' && shiftStatus.value == 'BREAK') { // resume - note: this condition may need adjustment based on previous state
      await NativeShiftService.resumeShift();
    } else if (status == 'END') {
      await NativeShiftService.endShift();
    }
  }
}