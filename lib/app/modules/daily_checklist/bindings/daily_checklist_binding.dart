import 'package:get/get.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';
import 'package:qr_buddy/app/data/repo/daily_checklist_repo.dart';

import '../controllers/daily_checklist_controller.dart';

class DailyChecklistBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure dependencies are registered
    Get.lazyPut<TokenStorage>(() => TokenStorage());
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut<DailyChecklistRepository>(
      () => DailyChecklistRepository(
        Get.find<ApiService>(),
        Get.find<TokenStorage>(),
      ),
    );
    Get.lazyPut<DailyChecklistController>(
      () => DailyChecklistController(
        Get.find<DailyChecklistRepository>(),
        Get.find<TokenStorage>(),
      ),
    );
  }
}