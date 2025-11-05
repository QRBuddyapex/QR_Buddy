
class NotificationPayload {
  final String ticketUuid;
  final String eventType;
  final String title;
  final String body;
  final String url;
  final String? ticketId;

  NotificationPayload({
    required this.ticketUuid,
    required this.eventType,
    required this.title,
    required this.body,
    required this.url,
    this.ticketId,
  });

  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    return NotificationPayload(
      ticketUuid: map['ticket_uuid'] ?? '',
      eventType: map['event_type'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      url: map['url'] ?? '',
      ticketId: map['ticket_id']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticket_uuid': ticketUuid,
      'event_type': eventType,
      'title': title,
      'body': body,
      'url': url,
      if (ticketId != null) 'ticket_id': ticketId,
    };
  }
}

class NotificationExamples {
  static const Map<String, dynamic> ticketNotification = {
    "ticket_uuid": "46d5070fba0911f0b5c4022ed49f11e5",
    "event_type": "FOOD",
    "ticket_id": 114450,
    "body": "Ticket #MAX00945 is assigned to , em@demo.com. (em@demo.com)",
    "title": "Lift not working",
    "url": "-"
  };
}
