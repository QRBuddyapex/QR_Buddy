import 'package:get/get.dart';
import 'package:qr_buddy/app/modules/new_ticket/controllers/new_ticket_controller.dart';

class NewTicketBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewETicketController>(() => NewETicketController());
  }
}
