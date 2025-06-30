import 'package:dio/dio.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';
import 'package:qr_buddy/app/data/models/order_details_model.dart';

class OrderDetailRepository {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;

  OrderDetailRepository(this._apiService, this._tokenStorage);

  Future<OrderDetailResponse> fetchOrderDetails({
    required String hcoId,
    required String orderId,
    required String userId,
  }) async {
    final response = await _apiService.get(
      '/orders.html?action=order_detail&hco_id=$hcoId&order_id=$orderId&user_id=$userId&phone_uuid=5678b6baf95911ef8b460200d429951a&hco_key=0',
    );

    if (response.statusCode == 200) {
      return OrderDetailResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to fetch order details: ${response.data['message']}');
    }
  }

  Future<Map<String, dynamic>> updateRequest({
    required String userId,
    required String hcoId,
    required String orderId,
    required String phoneUuid,
    required String hcoKey,
    required String requestStatus,
    required String remarks,
    String? timeHoldTill,
    MultipartFile? file,
  }) async {
    final formData = FormData.fromMap({
      'file_count': file != null ? 1 : 0,
      'user_id': userId,
      'hco_id': hcoId,
      'order_id': orderId,
      'phone_uuid': phoneUuid,
      'hco_key': hcoKey,
      'request_status': requestStatus,
      'remarks': remarks,
      'assigned_to': '',
      'time_hold_till': timeHoldTill ?? '',
      if (file != null) 'file0': file,
    });

    final response = await _apiService.post(
      '/ticket/ticket.html?action=update_request&user_id=$userId&hco_id=$hcoId&phone_uuid=$phoneUuid&hco_key=$hcoKey',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    if (response.statusCode == 200 && response.data['status'] == 1) {
      return response.data;
    } else {
      throw Exception(response.data['message'] ?? 'Failed to update request');
    }
  }

  Future<Map<String, dynamic>> assignTaskTo({
    required String userId,
    required String hcoId,
    required String orderId,
    required String assignedTo,
    required String phoneUuid,
    required String hcoKey,
  }) async {
    final formData = FormData.fromMap({
      'order_id': orderId,
      'assigned_to': assignedTo,
    });

    final response = await _apiService.post(
      '/ticket/ticket.html?action=assign_task_to&user_id=$userId&hco_id=$hcoId&phone_uuid=$phoneUuid&hco_key=$hcoKey',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    if (response.statusCode == 200 && response.data['status'] == 1) {
      return response.data;
    } else {
      throw Exception(response.data['message'] ?? 'Failed to assign task');
    }
  }
}