
import 'package:dio/dio.dart';
import 'package:qr_buddy/app/core/config/api_config.dart';
import 'package:qr_buddy/app/core/services/api_exception.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';
import 'package:qr_buddy/app/data/models/e_tickets.dart';


class TicketRepository {
  final ApiService _apiService;

  TicketRepository(this._apiService);

  Future<TicketResponse> fetchTickets({
    required String hcoId,
    String? dateFrom,
    String? dateTo,
    String? orderNumber,
    String? requestStatus,
  }) async {
    try {
      final response = await _apiService.post(
        '${AppUrl.baseUrl}/orders.html?user_id=2600&hco_id=$hcoId',
        data: {
          'hco_id': hcoId,
          'date_from': dateFrom ?? '',
          'date_to': dateTo ?? '',
          'order_number': orderNumber ?? '',
          'request_status': requestStatus ?? 'ALL',
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 1) {
        return TicketResponse.fromJson(response.data);
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
      throw Exception('Failed to fetch tickets: $e');
    }
  }
}