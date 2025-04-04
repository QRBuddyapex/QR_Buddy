import 'package:get/get.dart';
import 'package:qr_buddy/app/data/models/ticket.dart';


class TicketController extends GetxController {
  var selectedFilter = 'New'.obs;
  var tickets = <Ticket>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTickets();
  }

  void fetchTickets() {
    tickets.assignAll([
      Ticket(
        orderNumber: 'MAX00294',
        description: 'Major OT (Recovery)',
        block: 'B BLOCK / TF',
        status: 'New',
        date: '03/04/2025, 11:37 AM',
        department: 'GDA Services',
        serviceLabel: 'Major OT (Recovery)',
      ),
      Ticket(
        orderNumber: 'MAX00295',
        description: 'Emergency Room Service',
        block: 'A BLOCK / GF',
        status: 'New',
        date: '03/04/2025, 11:35 AM',
        department: 'Emergency Services',
        serviceLabel: 'Emergency Room Service',
      ),
      Ticket(
        orderNumber: 'MAX00296',
        description: 'General Ward Maintenance',
        block: 'C BLOCK / SF',
        status: 'New',
        date: '03/04/2025, 11:30 AM',
        department: 'Maintenance',
        serviceLabel: 'General Ward Maintenance',
      ),
    ]);
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }
}