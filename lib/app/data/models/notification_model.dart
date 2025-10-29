// lib/app/models/notification_model.dart
class NotificationPayload {
  final String eventType;
  final String title;
  final String body;
  final String location;
  final String eventUuid;
  final String? eventId;
  final String task;

  NotificationPayload({
    required this.eventType,
    required this.title,
    required this.body,
    required this.location,
    required this.eventUuid,
    this.eventId,
    required this.task,
  });

  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    return NotificationPayload(
      eventType: map['event_type'] ?? 'ticket',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      location: map['url'] ?? '',
      eventUuid: map['event_uuid'] ?? map['ticket_uuid'] ?? '',
      eventId: map['event_id']?.toString() ?? map['ticket_id']?.toString(),
      task: map['task'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'event_type': eventType,
      'title': title,
      'body': body,
      'url': location,
      'event_uuid': eventUuid,
      if (eventId != null) 'event_id': eventId,
      'task': task,
    };
  }
}

class NotificationExamples {
  static const Map<String, dynamic> ticketNotification = {
    "event_type": "ticket",
    "title": "Exhaust not working",
    "body": "Ticket #MAX00906 is assigned to , em2@demo.com. (em2@demo.com)",
    "url": "-",
    "event_uuid": "12d431ddaf2311f08c55022ed49f11e5",
    "event_id": 113402,
    "task": "Accept and Start Repair"
  };

  static const Map<String, dynamic> foodNotification = {
    "event_type": "food",
    "title": "Food Delivery Request",
    "body": "Order #123 ready for pickup and delivery to Room G2-101",
    "url": "Block A1, Ground Floor, Room G2-101 (Near Entrance)",
    "event_uuid": "def456-uuid-food-789",
    "event_id": 123456,
    "task": "Start Delivery"
  };

  static const Map<String, dynamic> checklistNotification = {
    "event_type": "checklist",
    "title": "New Checklist Task",
    "body": "Complete safety inspection required in Lab 3 immediately",
    "url": "Block B2, First Floor, Lab 3",
    "event_uuid": "ghi789-uuid-checklist-012",
    "event_id": 789012,
    "task": "Start Checklist"
  };
}