import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';
import 'package:qr_buddy/app/data/models/location_model.dart';


class LocationRepository {
  final ApiService _apiService = ApiService();
  final TokenStorage _tokenStorage = TokenStorage();

  Future<LocationResponse> fetchLocations({
    required String hcoId,
    required String userId,
    String phoneUuid = '',
    String hcoKey = '0',
  }) async {
    try {
      final response = await _apiService.get(
        '/users.html',
        queryParameters: {
          'action': 'my_location',
          'hco_id': hcoId,
          'user_id': userId,
          'phone_uuid': phoneUuid,
          'hco_key': hcoKey,
        },
      );
      return LocationResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch locations: $e');
    }
  }

  Future<SaveLocationResponse> saveLocations({
    required String userId,
    required String hcoId,
    required List<SelectedRoom> rooms,
    String phoneUuid = '',
    String hcoKey = '0',
  }) async {
    try {
      final payload = {
        'user_id': userId,
        'rooms': rooms.map((room) => room.toJson()).toList(),
      };

      final response = await _apiService.post(
        '/users.html',
        queryParameters: {
          'action': 'save_my_location',
          'user_id': userId,
          'hco_id': hcoId,
          'phone_uuid': phoneUuid,
          'hco_key': hcoKey,
        },
        data: payload,
      );
      return SaveLocationResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to save locations: $e');
    }
  }
}