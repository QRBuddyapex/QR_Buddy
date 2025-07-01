import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/config/api_config.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';

class ShiftController extends GetxController {
  final ApiService _apiService = ApiService();
  final TokenStorage _tokenStorage = TokenStorage();
  var shiftStatus = 'END'.obs; 

  @override
  void onInit() {
    super.onInit();
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
        shiftStatus.value = response.data['shift_status'] ?? 'END';
      }
    } catch (e) {
      print('Error fetching shift status: $e');
    }
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
}