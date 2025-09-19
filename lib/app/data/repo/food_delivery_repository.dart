import 'package:dio/dio.dart';
import 'package:qr_buddy/app/core/config/api_config.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_exception.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';
import 'package:qr_buddy/app/data/models/food_delivery_model.dart';

class FoodDeliveryRepository {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;

  FoodDeliveryRepository(this._apiService, this._tokenStorage);

  Future<List<Map<String, dynamic>>> fetchFoodDeliveries({
    required String userId,
  }) async {
    try {
      final queryParameters = {
        'user_id': userId,
      };

      final response = await _apiService.get(
        '${AppUrl.baseUrl}/checklist/batch.html',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final foodDeliveryResponse = FoodDeliveryResponse.fromJson(response.data);
        // Sort pending_rounds by id in descending order
        final sortedRounds = foodDeliveryResponse.pendingRounds
          ..sort((a, b) {
            final aId = a.id ?? 0;
            final bId = b.id ?? 0;
            return bId.compareTo(aId);
          });

        final tasks = <Map<String, dynamic>>[];

        tasks.add({
          'group': 'Food Delivery Group',
          'tasks': sortedRounds.map((round) => {
                'roomId': round.roomId.toString(),
                'uuid': round.uuid,
                'room_number': round.roomNumber,
                'category_name': round.categoryName,
                'room_uuid': round.roomuuid,
                'category_uuid': round.categoryUuid,
                'id': round.id, // Include id in the task map for reference
              }).toList(),
        });

        return tasks;
      } else {
        throw Exception('Failed to fetch food deliveries: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch food deliveries: $e');
    }
  }
}