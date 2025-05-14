import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/utils/snackbar.dart';



class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage = TokenStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = '$token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
    
      CustomSnackbar.error("Session expired. Please log in again.");
    
      _tokenStorage.clearToken();
      Get.offAllNamed('/login');
    }
    handler.next(err);
  }
}