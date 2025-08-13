import 'package:dio/dio.dart';
import 'package:qr_buddy/app/core/config/api_config.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_exception.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';
import 'package:qr_buddy/app/data/models/management_form_model.dart';

class QualityRoundsRepository {
  final ApiService _apiService = ApiService();
  final TokenStorage _tokenStorage = TokenStorage();

  Future<ManagementFormModel> fetchParameters({
    required String categoryUuid,
    required String userId,
    required String hcoId,
  }) async {
    try {
      final queryParameters = {
        'action': 'parameters',
        'round_uuid': '-',
        'category_uuid': categoryUuid,
        'user_id': userId,
        'hco_id': hcoId,
        'phone_uuid': '',
        'hco_key': '0',
      };

      final response = await _apiService.get(
        '${AppUrl.baseUrl}/quality_rounds.html',
        queryParameters: queryParameters,
      );

      return ManagementFormModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch parameters: $e');
    }
  }

  Future<void> saveFormData({
    required String categoryUuid,
    required String userId,
    required String hcoId,
    required String roomUuid,
    required String averageRating,
    required Map<String, dynamic> parameters,
    required List<Parameter> formParameters,
  }) async {
    try {
      final data = {
        'category_uuid': categoryUuid,
        'parameters': formParameters.map((param) {
          final userValue = parameters[param.parameterName!];
          return {
            'id': param.id,
            'uuid': param.uuid,
            'category_id': param.categoryId,
            'tag': param.tag,
            'parameter_name': param.parameterName,
            'data_entry_type': param.dataEntryType,
            'value_min': param.valueMin,
            'value_max': param.valueMax,
            'value_unit': param.valueUnit,
            'value_default': param.valueDefault,
            'specify_status': param.specifyStatus,
            'specify_title': param.specifyTitle,
            'status_ask_date': param.statusAskDate,
            'status_image': param.statusImage,
            'status_ask_progress': param.statusAskProgress,
            'complaint_conditions': param.complaintConditions,
            'value_int': userValue is int
                ? userValue
                : (userValue is String ? int.tryParse(userValue) : param.valueInt),
            'value_string': userValue is String ? userValue : param.valueString,
            'question': param.question,
            'choices': param.choices,
          };
        }).toList(),
        'round_uuid': '-',
        'room_uuid': roomUuid,
        'source': 'QR',
        'status_update': 'END',
        'user_id_login': 0,
        'rating': averageRating,
        'remarks': '',
        'stock_uuid': '-',
      };

      final response = await _apiService.post(
        '${AppUrl.baseUrl}/quality_rounds.html',
        data: data,
        queryParameters: {
          'action': 'save_data',
          'user_id': userId,
          'hco_id': hcoId,
          'phone_uuid': '',
          'hco_key': '0',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save data: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to save data: $e');
    }
  }
}