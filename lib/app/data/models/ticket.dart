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
  final String roomNumber;
  final String? uuid;
  final String source;
  Ticket({
    required this.orderNumber,
    required this.description,
    required this.block,
    required this.status,
    required this.date,
    required this.department,
    required this.phoneNumber,
    required this.assignedTo, 
    required  this.roomNumber,
    required this.serviceLabel,
    required  this.source,
    this.isQuickRequest= false,
    
    this.uuid,
  });
}