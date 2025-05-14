class NewETicketResponseModel {
  final List<Service> services;
  final Map<String, List<String>> linkedServices;
  final List<Room> rooms;
  final int status;
  final String message;

  NewETicketResponseModel({
    required this.services,
    required this.linkedServices,
    required this.rooms,
    required this.status,
    required this.message,
  });

  factory NewETicketResponseModel.fromJson(Map<String, dynamic> json) {
    return NewETicketResponseModel(
      services: (json['services'] as List<dynamic>?)
              ?.map((item) => Service.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      linkedServices: (json['linked_services'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, List<String>.from(value)),
          ) ??
          {},
      rooms: (json['rooms'] as List<dynamic>?)
              ?.map((item) => Room.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status'] as int? ?? 0,
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'services': services.map((service) => service.toJson()).toList(),
      'linked_services': linkedServices,
      'rooms': rooms.map((room) => room.toJson()).toList(),
      'status': status,
      'message': message,
    };
  }
}

class Service {
  final String id;
  final String uuid;
  final String requestType;
  final String serviceName;

  Service({
    required this.id,
    required this.uuid,
    required this.requestType,
    required this.serviceName,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String? ?? '',
      uuid: json['uuid'] as String? ?? '',
      requestType: json['request_type'] as String? ?? '',
      serviceName: json['service_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'request_type': requestType,
      'service_name': serviceName,
    };
  }
}

class Room {
  final String id;
  final String uuid;
  final String roomNumber;

  Room({
    required this.id,
    required this.uuid,
    required this.roomNumber,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String? ?? '',
      uuid: json['uuid'] as String? ?? '',
      roomNumber: json['room_number'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'room_number': roomNumber,
    };
  }
}