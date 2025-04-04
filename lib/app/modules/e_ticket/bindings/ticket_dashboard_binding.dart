import 'package:get/get.dart';
import 'package:qr_buddy/app/modules/e_ticket/controllers/ticket_controller.dart';

class TicketDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TicketController>(() => TicketController());
  }
}
