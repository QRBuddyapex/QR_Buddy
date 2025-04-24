import 'package:dio/dio.dart';
import 'package:qr_buddy/app/core/utils/snackbar.dart';


class ErrorInterceptor extends Interceptor {
  ErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorTitle = "Error";
    String errorMessage = "An unexpected error occurred";

    if (err.type == DioExceptionType.connectionTimeout) {
      errorMessage = "Connection Timeout";
    }

    if (err.response != null) {
      switch (err.response!.statusCode) {
        case 400:
          errorTitle = "Bad Request";
          errorMessage = '${err.response?.data['message']}';
          break;
        case 401:
          errorTitle = "Unauthorized";
          errorMessage = '${err.response?.data['message']}';
          break;
        case 403:
          errorTitle = "Forbidden";
          errorMessage = '${err.response?.data['message']}';
          break;
        case 404:
          errorTitle = "Not Found";
          errorMessage = '${err.response?.data['message']}';
          break;
        case 500:
          errorTitle = "Server Error";
          errorMessage = 'Internal Server Error';
          break;
        default:
          errorTitle = "Error";
          errorMessage = '${err.response?.statusMessage}';
          break;
      }
    }

    if (err.response?.statusCode == 401) {
      CustomSnackbar.error("$errorTitle: $errorMessage");
    }

    // Continue with the error
    handler.next(err);
  }
}
