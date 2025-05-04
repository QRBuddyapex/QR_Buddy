import 'package:get/get.dart';
import 'package:qr_buddy/app/data/models/ticket.dart';
import 'package:qr_buddy/app/routes/routes.dart';

class TicketController extends GetxController {
  var selectedFilter = 'New'.obs;
  var tickets = <Ticket>[].obs;
  var selectedInfoCard = ''.obs; // Track the selected info card
  var tasks = <Map<String, dynamic>>[].obs; // Store tasks for "Daily Tasks"
  var checklists = <Map<String, dynamic>>[].obs; // Store checklists

  var todayStatus = 50.0.obs;
  var flags = 90.obs;
  var comments = 17.obs;
  var missed = 20.obs;
  var reviewPending = 6.obs;
  var schedules = 4.obs;
  var openIssues = 1.obs;
  var tasksCount = 0.obs;
  var documents = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTickets();
    fetchTasks();
    fetchChecklists();
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

  void fetchTasks() {
    tasks.assignAll([
      {
        'group': 'Dummy Group 1',
        'tasks': [
          {
            'taskName': 'Integrate payment method',
            'assigned': ['RM', 'MK', 'AS'],
            'priority': 'High',
            'dueDate': 'Due Date',
            'notes': 'This is a note',
            'lastUpdated': 'Last Updated',
          },
          {
            'taskName': 'Impliment cart functionality',
            'assigned': ['RM', 'MK', 'AS'],
            'priority': 'High',
            'dueDate': 'Due Date',
            'notes': 'This is important',
            'lastUpdated': 'Last Updated',
          },
        ],
      },
      {
        'group': 'Dummy Group 2',
        'tasks': [
          {
            'taskName': 'Book a flight ticket from inc',
            'assigned': ['AS'],
            'priority': 'Low',
            'dueDate': 'Due Date',
            'notes': 'Business class',
            'lastUpdated': '5/2/2025, 10:10:08 AM',
          },
        ],
      },
    ]);
  }

  void fetchChecklists() {
    checklists.assignAll([
      {
        'group': 'Checklist Group 1',
        'checklists': [
          {
            'checklist_name': 'Safety Inspection',
            'location': 'Block A/GF',
            'date_and_time': '15/04/2025, 09:00 AM',
          },
          {
            'checklist_name': 'Equipment Check',
            'location': 'Block B/1F',
            'date_and_time': '15/04/2025, 11:00 AM',
          },
        ],
      },
      {
        'group': 'Checklist Group 2',
        'checklists': [
          {
            'checklist_name': 'Fire Drill',
            'location': 'Block C/2F',
            'date_and_time': '16/04/2025, 02:00 PM',
          },
        ],
      },
    ]);
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void setSelectedInfoCard(String card) {
    selectedInfoCard.value = card;
  }

  void navigateToDetail(Ticket ticket) {
    Get.toNamed(RoutesName.ticketDetailsView, arguments: ticket);
  }

  void dialPhone(String phoneNumber) {}

  void updateTicketList(int index) {
    if (index >= 0 && index < tickets.length) {
      fetchTickets();
    }
  }
}