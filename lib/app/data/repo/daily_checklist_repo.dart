import 'package:dio/dio.dart';
import 'package:qr_buddy/app/core/config/api_config.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_exception.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';
import 'package:qr_buddy/app/data/models/batch_response_model.dart';
import 'package:qr_buddy/app/data/models/daily_checklist_model.dart';

class DailyChecklistRepository {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;

  DailyChecklistRepository(this._apiService, this._tokenStorage);

  Future<DailyChecklistModel> fetchDailyChecklist({
    required String hcoId,
    String? dateFrom,
    String? dateTo,
    required String userId,
    required String phoneUuid,
    String hcoKey = '0',
    String? categoryId, // Add categoryId parameter
  }) async {
    try {
      final storedHcoId = await _tokenStorage.getHcoId();
      final storedUserId = await _tokenStorage.getUserId();

      if (storedHcoId == null || storedUserId == null) {
        throw Exception('User ID or HCO ID not found in storage');
      }

      final queryParameters = {
        'action': 'index',
        'hco_id': hcoId,
        'date_from': dateFrom ?? '',
        'date_to': dateTo ?? '',
        'user_id': userId,
        'phone_uuid': phoneUuid,
        'hco_key': hcoKey,
        if (categoryId != null) 'category_id': categoryId, // Include category_id if provided
      };

      final response = await _apiService.get(
        '${AppUrl.baseUrl}/quality_summary/quality_summary.html',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data['status'] == 1) {
        return DailyChecklistModel.fromJson(response.data);
      } else {
        throw ApiException.fromDioError(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: response,
          ),
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException.fromDioError(e);
      }
      throw Exception('Failed to fetch daily checklist: $e');
    }
  }



Future<BatchResponse> fetchBatchForm({
  required String hcoId,
  required String userId,
  String phoneUuid = '',
  String hcoKey = '0',
}) async {
  try {
    final queryParameters = {
      'action': 'form',
      'hco_id': hcoId,
      'user_id': userId,
      'phone_uuid': phoneUuid,
      'hco_key': hcoKey,
    };

    final response = await _apiService.get(
      '/checklist/batch.html',
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200 ) {
      return BatchResponse.fromJson(response.data);
    } else {
      throw ApiException.fromDioError(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: response,
        ),
      );
    }
  } catch (e) {
    if (e is DioException) {
      throw ApiException.fromDioError(e);
    }
    throw Exception('Failed to fetch batch form: $e');
  }
}
Future<void> createBatchChecklist({
  required String hcoId,
  required String userId,
  required String phoneUuid,
  required String hcoKey,
  required List<String> roomIds,
  required List<String> userIds,
  required String categoryId,
}) async {
  try {
    final token = await _tokenStorage.getToken();
    if (token == null) {
      throw Exception('Authorization token not found');
    }

    final queryParameters = {
      'action': 'create',
      'hco_id': hcoId,
      'user_id': userId,
      'phone_uuid': phoneUuid,
      'hco_key': hcoKey,
    };

    final payload = {
      'room_ids': roomIds,
      'user_ids': userIds,
      'category_id': categoryId,
    };

    final response = await _apiService.post(
      '${AppUrl.baseUrl}/checklist/batch.html',
      data: payload,
      queryParameters: queryParameters,
      options: Options(
        headers: {
          'Authorization': token,
        },
      ),
    );

    if (response.statusCode == 200 && response.data['status'] == 1) {
      // Success case
      return;
    } else {
      throw ApiException.fromDioError(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: response,
        ),
      );
    }
  } catch (e) {
    if (e is DioException) {
      throw ApiException.fromDioError(e);
    }
    throw Exception('Failed to create batch checklist: $e');
  }
}
}