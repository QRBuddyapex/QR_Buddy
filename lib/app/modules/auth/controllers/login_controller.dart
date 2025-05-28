import 'package:get/get.dart';
import 'package:qr_buddy/app/core/config/api_config.dart';
import 'package:qr_buddy/app/core/config/notifications_services.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';
import 'package:qr_buddy/app/core/utils/snackbar.dart';
import 'package:qr_buddy/app/data/repo/auth_repo.dart';
import 'package:qr_buddy/app/routes/routes.dart';


class LoginController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  final AuthRepository _authRepository = AuthRepository();
  final NotificationServices _notificationServices = NotificationServices();
  final ApiService _apiService = ApiService();
  var isLogin = false.obs;
  var isLoading = false.obs;

  void updateEmail(String value) => email.value = value;
  void updatePassword(String value) => password.value = value;

  Future<void> login() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      CustomSnackbar.error('Please fill in all fields');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authRepository.login(email.value, password.value);

      if (response["status"] == 1) {
        CustomSnackbar.success("Login successful!");
      
        final userId = response["user"]["id"].toString();
        await _saveFcmToken(userId);
        Get.offAllNamed(RoutesName.ticketDashboardView);
      } else {
        CustomSnackbar.error(response["message"] ?? "Login failed");
      }
    } catch (e) {
      CustomSnackbar.error("Login failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveFcmToken(String userId) async {
    try {
      // Get FCM token
      final fcmToken = await _notificationServices.getDeviceToken();
      if (fcmToken == null) {
        print('Failed to retrieve FCM token');
        return;
      }

      // Make API request to save FCM token
      final response = await _apiService.post(
        "${AppUrl.baseUrl}/login.html",
        queryParameters: {
          'action': 'save_fcm_token',
          'user_id': userId,
          'fcm_token': fcmToken,
        },
      );
      // https://qrbuddyapi.in/v3/api/login.html?action=save_fcm_token&user_id=2055&fcm_token=eydjbkjbfdjabs

      // Log the response
      print('FCM Token Save Response: ${response.data}');
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }
}