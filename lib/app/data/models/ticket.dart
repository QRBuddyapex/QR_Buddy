class Ticket {
  final String orderNumber;
  final String description;
  final String block;
  final String status;
  final String date;
  final String department;
  final String serviceLabel;

  Ticket({
    required this.orderNumber,
    required this.description,
    required this.block,
    required this.status,
    required this.date,
    required this.department,
    required this.serviceLabel,
  });
}