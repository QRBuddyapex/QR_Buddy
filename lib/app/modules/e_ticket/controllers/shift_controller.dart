// shift_controller.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/config/api_config.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';
import 'package:qr_buddy/app/core/services/native_shift_service.dart';
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
  }

  @override
  void onClose() {
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
      Get.snackbar('Error', 'Failed to update shift status: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white);
    }
  }

  Future<void> _manageForegroundService(String status) async {
    if (status == 'START') {
      await NativeShiftService.startShift();
    } else if (status == 'BREAK') {
      await NativeShiftService.takeBreak();
    } else if (status == 'START' && shiftStatus.value == 'BREAK') { // resume
      await NativeShiftService.resumeShift();
    } else if (status == 'END') {
      await NativeShiftService.endShift();
    }
  }
}