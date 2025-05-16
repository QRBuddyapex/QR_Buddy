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
      '/orders.html?action=order_detail&hco_id=$hcoId&order_id=$orderId&user_id=$userId',
    );

    if (response.statusCode == 200) {
      return OrderDetailResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to fetch order details: ${response.data['message']}');
    }
  }
}