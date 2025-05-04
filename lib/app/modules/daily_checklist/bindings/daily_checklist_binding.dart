import 'package:get/get.dart';

import '../controllers/daily_checklist_controller.dart';

class DailyChecklistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailyChecklistController>(
      () => DailyChecklistController(),
    );
  }
}
