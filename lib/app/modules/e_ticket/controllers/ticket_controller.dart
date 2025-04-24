import 'package:get/get.dart';
import 'package:qr_buddy/app/data/models/ticket.dart';
import 'package:qr_buddy/app/routes/routes.dart';

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
        orderNumber: 'MAX00309',
        description: 'AC not working',
        block: 'Block A/GF',
        status: 'Accepted',
        date: '15/04/2025, 07:10 PM',
        department: 'E & M',
        phoneNumber: '7210000700',
        assignedTo: 'em',
        serviceLabel: 'Apple',
      ),
      Ticket(
        orderNumber: 'MAX00216',
        description: 'AC not working',
        block: 'Block A/GF',
        status: 'Assigned',
        date: '31/01/2025, 01:05 PM',
        department: 'E & M',
        phoneNumber: '7210000701',
        assignedTo: 'em',
        serviceLabel: 'Pvt 102',
        isQuickRequest: true,
      ),
      Ticket(
        orderNumber: 'MAX00215',
        description: 'AC not working',
        block: 'Block A/GF',
        status: 'Assigned',
        date: '31/01/2025, 01:03 PM',
        department: 'E & M',
        phoneNumber: '7210000702',
        assignedTo: 'em',
        serviceLabel: 'Pvt 102',
        isQuickRequest: true,
      ),
    ]);
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void navigateToDetail(Ticket ticket) {
    Get.toNamed(RoutesName.ticketDetailsView, arguments: ticket);
  }

  void dialPhone(String phoneNumber) {
    // Implementation for opening dialer (platform-specific)
    // For now, using url_launcher as a placeholder
    // import 'package:url_launcher/url_launcher.dart';
    // launch('tel:$phoneNumber');
  }
}