import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/utils/snackbar.dart';
import 'package:qr_buddy/app/routes/routes.dart';


class TokenValidityInterceptor extends Interceptor {
  final TokenStorage _tokenStorage = TokenStorage();

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is Map && response.data['status'] == 400 && response.data['message'] == "Invalid access token!") {
      CustomSnackbar.error("Session expired. Please log in again.");
      _tokenStorage.clearToken();
      getx.Get.offAllNamed(RoutesName.loginScreen);
      handler.reject(DioException(requestOptions: response.requestOptions, message: "Invalid access token!"));
    } else {
      handler.next(response);
    }
  }
}