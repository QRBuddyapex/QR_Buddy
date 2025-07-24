import 'package:get/get.dart';

import '../controllers/quality_rounds_controller.dart';

class QualityRoundsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QualityRoundsController>(
      () => QualityRoundsController(),
    );
  }
}
