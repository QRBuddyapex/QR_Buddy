import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';
import 'package:qr_buddy/app/data/models/e_tickets.dart';
import 'package:qr_buddy/app/data/models/ticket.dart';
import 'package:qr_buddy/app/data/repo/e_ticket_repo.dart';
import 'package:qr_buddy/app/routes/routes.dart';
import 'package:url_launcher/url_launcher.dart';

class TicketController extends GetxController {
  var selectedFilter = 'All'.obs;
  var tickets = <Ticket>[].obs;
  var filteredTickets = <Ticket>[].obs;
  var links = <Link>[].obs;
  var selectedInfoCard = 'E-Tickets'.obs;

  var tasks = <Map<String, dynamic>>[].obs;
  var checklists = <Map<String, dynamic>>[].obs;

  var todayStatus = 50.0.obs;
  var flags = 90.obs;
  var comments = 17.obs;
  var missed = 20.obs;
  var reviewPending = 6.obs;
  var schedules = 4.obs;
  var openIssues = 1.obs;
  var tasksCount = 0.obs;
  var documents = 0.obs;

  late final TicketRepository _ticketRepository;

  @override
  void onInit() {
    super.onInit();
    _ticketRepository = TicketRepository(
      ApiService(),
      TokenStorage(),
    );
    fetchTickets();
    fetchTasks();
    fetchChecklists();
    updateTasksCount();
  }

  Future<void> fetchTickets() async {
    try {
      final response = await _ticketRepository.fetchTickets(
        hcoId: await TokenStorage().getHcoId() ?? '',
        requestStatus: _mapFilterToRequestStatus(selectedFilter.value),
      );
      tickets.assignAll(response.orders.map((order) => order.toTicket()).toList());
      links.assignAll(response.links);
      updateTicketList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch tickets: $e');
    }
  }

  String _mapFilterToRequestStatus(String filter) {
    switch (filter) {
      case 'New':
        return 'NEW';
      case 'Assigned':
        return 'ASI';
      case 'Accepted':
        return 'ACC';
      case 'Completed':
        return 'COMP';
      case 'Verified':
        return 'VER';
      case 'On Hold':
        return 'HOLD';
      case 'Re-Open':
        return 'REO';
      case 'Cancelled':
        return 'CAN';
      case 'Total':
      case 'All':
      default:
        return 'ALL';
    }
  }

  void fetchTasks() {
    tasks.clear();
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
            'taskName': 'Implement cart functionality',
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
    updateTasksCount();
  }

  void fetchChecklists() {
    checklists.clear();
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

  void updateTasksCount() {
    int totalTasks = tasks.fold(0, (sum, group) => sum + (group['tasks'] as List).length);
    tasksCount.value = totalTasks;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    fetchTickets();
  }

  void setSelectedInfoCard(String card) {
    selectedInfoCard.value = card;
  }

  void navigateToDetail(Ticket ticket) {
    if (ticket.uuid!.isEmpty) {
      Get.snackbar('Error', 'Order ID (UUID) is missing for this ticket');
      return;
    }
    Get.toNamed(RoutesName.ticketDetailsView, arguments: ticket);
  }

  void dialPhone(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        Get.snackbar(
          'Error',
          'Could not launch dialer. Please check permissions or try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open dialer: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  void updateTicketList() {
    switch (selectedFilter.value) {
      case 'New':
        filteredTickets.assignAll(tickets.where((ticket) => ticket.status == 'New').toList());
        break;
      case 'Assigned':
        filteredTickets.assignAll(tickets.where((ticket) => ticket.status == 'Assigned').toList());
        break;
      case 'Accepted':
        filteredTickets.assignAll(tickets.where((ticket) => ticket.status == 'Accepted').toList());
        break;
      case 'Completed':
        filteredTickets.assignAll(tickets.where((ticket) => ticket.status == 'Completed').toList());
        break;
      case 'Verified':
        filteredTickets.assignAll(tickets.where((ticket) => ticket.status == 'Verified').toList());
        break;
      case 'On Hold':
        filteredTickets.assignAll(tickets.where((ticket) => ticket.status == 'On Hold').toList());
        break;
      case 'Re-Open':
        filteredTickets.assignAll(tickets.where((ticket) => ticket.status == 'Re-Open').toList());
        break;
      case 'Cancelled':
        filteredTickets.assignAll(tickets.where((ticket) => ticket.status == 'Cancelled').toList());
        break;
      case 'Total':
      case 'All':
      default:
        filteredTickets.assignAll(tickets);
        break;
    }
  }
}