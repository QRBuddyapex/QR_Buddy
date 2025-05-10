import 'package:get/get.dart';
import 'package:qr_buddy/app/core/utils/snackbar.dart';
import 'package:qr_buddy/app/data/repo/auth_repo.dart';
import 'package:qr_buddy/app/routes/routes.dart';

class LoginController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  final AuthRepository _authRepository = AuthRepository();
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

      // Check status field for success
      if (response["status"] == 1) {
        CustomSnackbar.success("Login successful!");
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
}