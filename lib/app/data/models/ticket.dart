class Ticket {
  final String orderNumber;
  final String description;
  final String block;
  final String status;
  final String date;
  final String department;
  final String phoneNumber;
  final String serviceLabel;
  final String assignedTo;
  final bool? isQuickRequest;

  Ticket({
    required this.orderNumber,
    required this.description,
    required this.block,
    required this.status,
    required this.date,
    required this.department,
    required this.phoneNumber,
    required this.assignedTo, 
    required this.serviceLabel,
    this.isQuickRequest= false,
  });
}