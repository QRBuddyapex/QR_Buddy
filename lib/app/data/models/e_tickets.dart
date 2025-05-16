import 'package:qr_buddy/app/data/models/ticket.dart';

class TicketResponse {
  final int currentTime;
  final List<Order> orders;
  final List<Link> links;
  final String alarm;
  final Options options;
  final int status;
  final String message;

  TicketResponse({
    required this.currentTime,
    required this.orders,
    required this.links,
    required this.alarm,
    required this.options,
    required this.status,
    required this.message,
  });

  factory TicketResponse.fromJson(Map<String, dynamic> json) {
    return TicketResponse(
      currentTime: json['current_time'] ?? 0,
      orders: (json['orders'] as List<dynamic>?)
              ?.map((e) => Order.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      links: (json['links'] as List<dynamic>?)
              ?.map((e) => Link.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      alarm: json['alarm'] ?? '',
      options: Options.fromJson(json['options'] ?? {}),
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}

class Order {
  final String id;
  final String uuid;
  final String requestNumber;
  final String roomNumber;
  final String stockId;
  final String roundId;
  final List<dynamic> stockDetails;
  final String blockName;
  final String floorName;
  final String assignedTo;
  final String assignedToUsername;
  final String requestStatus;
  final String requestType;
  final String timeStart;
  final String timeAssigned;
  final String timeAccepted;
  final String timeCompleted;
  final String createdAt;
  final String createdAtDate;
  final String timeHoldTill;
  final String dateHoldTill;
  final String createdBy;
  final String rating;
  final String mapLong;
  final String mapLat;
  final String departmentId;
  final String departmentName;
  final String priority;
  final String serviceName;
  final String secNewAsi;
  final String secAsiAcc;
  final String secNewComp;
  final String secAsiComp;
  final String secAccComp;
  final String slaAssignSec;
  final String slaAcceptSec;
  final String slaCompleteSec;
  final String phoneNumber;
  final String fullName;
  final String notes;
  final String source;
  final String? username;
  final String timeCreate;
  final String? timeAssign;
  final String? timeAccept;
  final String parentId;
  final List<dynamic> jsonChildren;
  final String round;

  Order({
    required this.id,
    required this.uuid,
    required this.requestNumber,
    required this.roomNumber,
    required this.stockId,
    required this.roundId,
    required this.stockDetails,
    required this.blockName,
    required this.floorName,
    required this.assignedTo,
    required this.assignedToUsername,
    required this.requestStatus,
    required this.requestType,
    required this.timeStart,
    required this.timeAssigned,
    required this.timeAccepted,
    required this.timeCompleted,
    required this.createdAt,
    required this.createdAtDate,
    required this.timeHoldTill,
    required this.dateHoldTill,
    required this.createdBy,
    required this.rating,
    required this.mapLong,
    required this.mapLat,
    required this.departmentId,
    required this.departmentName,
    required this.priority,
    required this.serviceName,
    required this.secNewAsi,
    required this.secAsiAcc,
    required this.secNewComp,
    required this.secAsiComp,
    required this.secAccComp,
    required this.slaAssignSec,
    required this.slaAcceptSec,
    required this.slaCompleteSec,
    required this.phoneNumber,
    required this.fullName,
    required this.notes,
    required this.source,
    this.username,
    required this.timeCreate,
    this.timeAssign,
    this.timeAccept,
    required this.parentId,
    required this.jsonChildren,
    required this.round,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      uuid: json['uuid'] ?? '',
      requestNumber: json['request_number'] ?? '',
      roomNumber: json['room_number'] ?? '',
      stockId: json['stock_id'] ?? '',
      roundId: json['round_id'] ?? '',
      stockDetails: json['stock_details'] ?? [],
      blockName: json['block_name'] ?? '',
      floorName: json['floor_name'] ?? '',
      assignedTo: json['assigned_to'] ?? '',
      assignedToUsername: json['assigned_to_username'] ?? '',
      requestStatus: json['request_status'] ?? '',
      requestType: json['request_type'] ?? '',
      timeStart: json['time_start'] ?? '',
      timeAssigned: json['time_assigned'] ?? '',
      timeAccepted: json['time_accepted'] ?? '',
      timeCompleted: json['time_completed'] ?? '',
      createdAt: json['created_at'] ?? '',
      createdAtDate: json['created_at_date'] ?? '',
      timeHoldTill: json['time_hold_till'] ?? '',
      dateHoldTill: json['date_hold_till'] ?? '',
      createdBy: json['created_by'] ?? '',
      rating: json['rating'] ?? '',
      mapLong: json['map_long'] ?? '',
      mapLat: json['map_lat'] ?? '',
      departmentId: json['department_id'] ?? '',
      departmentName: json['department_name'] ?? '',
      priority: json['priority'] ?? '',
      serviceName: json['service_name'] ?? '',
      secNewAsi: json['sec_new_asi'] ?? '',
      secAsiAcc: json['sec_asi_acc'] ?? '',
      secNewComp: json['sec_new_comp'] ?? '',
      secAsiComp: json['sec_asi_comp'] ?? '',
      secAccComp: json['sec_acc_comp'] ?? '',
      slaAssignSec: json['sla_assign_sec'] ?? '',
      slaAcceptSec: json['sla_accept_sec'] ?? '',
      slaCompleteSec: json['sla_complete_sec'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      fullName: json['full_name'] ?? '',
      notes: json['notes'] ?? '',
      source: json['source'] ?? '',
      username: json['username'],
      timeCreate: json['time_create'] ?? '',
      timeAssign: json['time_assign'],
      timeAccept: json['time_accept'],
      parentId: json['parent_id'] ?? '',
      jsonChildren: json['json_children'] ?? [],
      round: json['round'] ?? '',
    );
  }

  Ticket toTicket() {
    return Ticket(
      orderNumber: requestNumber,
      description: notes.isNotEmpty ? notes : serviceName,
      block: '$blockName/$floorName'.trim(),
      status: _mapStatus(requestStatus),
      date: '$createdAtDate, $createdAt'.trim(),
      department: departmentName,
      phoneNumber: phoneNumber,
      assignedTo: assignedToUsername.split('@').first,
      serviceLabel: serviceName,
      isQuickRequest: source == 'QR',
      uuid: uuid, // Add uuid mapping
    );
  }

  static String _mapStatus(String status) {
    switch (status) {
      case 'NEW':
        return 'New';
      case 'ASI':
        return 'Assigned';
      case 'ACC':
        return 'Accepted';
      case 'COMP':
        return 'Completed';
      case 'VER':
        return 'Verified';
      case 'HOLD':
        return 'On Hold';
      case 'REO':
        return 'Re-Open';
      case 'CAN':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

class Link {
  final String type;
  final String title;
  final int count;

  Link({
    required this.type,
    required this.title,
    required this.count,
  });

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      count: int.tryParse(json['count'].toString()) ?? 0,
    );
  }
}

class Options {
  final String userType;
  final String rooms;
  final String services;
  final String departmentId;
  final List<dynamic> where;

  Options({
    required this.userType,
    required this.rooms,
    required this.services,
    required this.departmentId,
    required this.where,
  });

  factory Options.fromJson(Map<String, dynamic> json) {
    return Options(
      userType: json['user_type'] ?? '',
      rooms: json['rooms'] ?? '',
      services: json['services'] ?? '',
      departmentId: json['department_id'] ?? '',
      where: json['where'] ?? [],
    );
  }
}

