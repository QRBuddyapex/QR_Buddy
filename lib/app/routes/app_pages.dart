import 'package:get/get.dart';

import '../modules/daily_checklist/bindings/daily_checklist_binding.dart';
import '../modules/daily_checklist/views/daily_checklist_view.dart';
import '../modules/quality_rounds/bindings/quality_rounds_binding.dart';
import '../modules/quality_rounds/views/quality_rounds_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = '/home';

  static final routes = [
    GetPage(
      name: _Paths.DAILY_CHECKLIST,
      page: () => const DailyChecklistView(),
      binding: DailyChecklistBinding(),
    ),
    GetPage(
      name: _Paths.QUALITY_ROUNDS,
      page: () => const QualityRoundsView(),
      binding: QualityRoundsBinding(),
    ),
  ];
}
