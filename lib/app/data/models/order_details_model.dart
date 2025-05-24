class OrderDetailResponse {
  final Order order;
  final List<History> history;
  final List<ActiveUser> activeUsers;
  final Users users;
  final Department department;
  final int status;
  final String message;

  OrderDetailResponse({
    required this.order,
    required this.history,
    required this.activeUsers,
    required this.users,
    required this.department,
    required this.status,
    required this.message,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponse(
      order: Order.fromJson(json['order'] ?? {}),
      history: (json['history'] as List? ?? [])
          .map((item) => History.fromJson(item))
          .toList(),
      activeUsers: (json['active_users'] as List? ?? [])
          .map((item) => ActiveUser.fromJson(item))
          .toList(),
      users: Users.fromJson(json['users'] ?? {}),
      department: Department.fromJson(json['department'] ?? {}),
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}

class Order {
  final String id;
  final String uuid;
  final String requestNumber;
  final String hcoId;
  final String departmentId;
  final String departmentName;
  final String roomId;
  final String roomNumber;
  final String blockName;
  final String floorName;
  final String serviceId;
  final String serviceName;
  final String assignedTo;
  final String assignedToUsername;
  final String requestStatus;
  final String requestType;
  final String priority;
  final String source;
  final String mapLong;
  final String mapLat;
  final String phoneNumber;
  final String timeStart;
  final String timeAccepted;
  final String createdAt;
  final String createdAtDate;

  Order({
    required this.id,
    required this.uuid,
    required this.requestNumber,
    required this.hcoId,
    required this.departmentId,
    required this.departmentName,
    required this.roomId,
    required this.roomNumber,
    required this.blockName,
    required this.floorName,
    required this.serviceId,
    required this.serviceName,
    required this.assignedTo,
    required this.assignedToUsername,
    required this.requestStatus,
    required this.requestType,
    required this.priority,
    required this.source,
    required this.mapLong,
    required this.mapLat,
    required this.phoneNumber,
    required this.timeStart,
    required this.timeAccepted,
    required this.createdAt,
    required this.createdAtDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid']?.toString() ?? '',
      requestNumber: json['request_number']?.toString() ?? '',
      hcoId: json['hco_id']?.toString() ?? '',
      departmentId: json['department_id']?.toString() ?? '',
      departmentName: json['department_name']?.toString() ?? '',
      roomId: json['room_id']?.toString() ?? '',
      roomNumber: json['room_number']?.toString() ?? '',
      blockName: json['block_name']?.toString() ?? '',
      floorName: json['floor_name']?.toString() ?? '',
      serviceId: json['service_id']?.toString() ?? '',
      serviceName: json['service_name']?.toString() ?? '',
      assignedTo: json['assigned_to']?.toString() ?? '',
      assignedToUsername: json['assigned_to_username']?.toString() ?? '',
      requestStatus: json['request_status']?.toString() ?? '',
      requestType: json['request_type']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      mapLong: json['map_long']?.toString() ?? '',
      mapLat: json['map_lat']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      timeStart: json['time_start']?.toString() ?? '',
      timeAccepted: json['time_accepted']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      createdAtDate: json['created_at_date']?.toString() ?? '',
    );
  }
}

class History {
  final String id;
  final String orderId;
  final String userId;
  final String type;
  final String caption;
  final String remarks;
  final String messageType;
  final String phoneNumber;
  final String statusWhatsapp;
  final String createdAt;
  final String createdAtDate;

  History({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.type,
    required this.caption,
    required this.remarks,
    required this.messageType,
    required this.phoneNumber,
    required this.statusWhatsapp,
    required this.createdAt,
    required this.createdAtDate,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
      remarks: json['remarks']?.toString() ?? '',
      messageType: json['message_type']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      statusWhatsapp: json['status_whatsapp']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      createdAtDate: json['created_at_date']?.toString() ?? '',
    );
  }
}

class ActiveUser {
  final String id;
  final String uuid;
  final String hcoId;
  final String departmentId;
  final String username;
  final String userType;
  final String shiftStatus;
  final String activeTasks;

  ActiveUser({
    required this.id,
    required this.uuid,
    required this.hcoId,
    required this.departmentId,
    required this.username,
    required this.userType,
    required this.shiftStatus,
    required this.activeTasks,
  });

  factory ActiveUser.fromJson(Map<String, dynamic> json) {
    return ActiveUser(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid']?.toString() ?? '',
      hcoId: json['hco_id']?.toString() ?? '',
      departmentId: json['department_id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      userType: json['user_type']?.toString() ?? '',
      shiftStatus: json['shift_status']?.toString() ?? '',
      activeTasks: json['active_tasks']?.toString() ?? '',
    );
  }
}

class Users {
  final List<User> result;
  final int count;
  final int total;

  Users({
    required this.result,
    required this.count,
    required this.total,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      result: (json['RESULT'] as List? ?? [])
          .map((item) => User.fromJson(item))
          .toList(),
      count: json['COUNT'] ?? 0,
      total: json['TOTAL'] ?? 0,
    );
  }
}

class User {
  final String id;
  final String uuid;
  final String hcoId;
  final String departmentId;
  final String username;
  final String userType;
  final String shiftStatus;
  final String activeTasks;

  User({
    required this.id,
    required this.uuid,
    required this.hcoId,
    required this.departmentId,
    required this.username,
    required this.userType,
    required this.shiftStatus,
    required this.activeTasks,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid']?.toString() ?? '',
      hcoId: json['hco_id']?.toString() ?? '',
      departmentId: json['department_id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      userType: json['user_type']?.toString() ?? '',
      shiftStatus: json['shift_status']?.toString() ?? '',
      activeTasks: json['active_tasks']?.toString() ?? '',
    );
  }
}

class Department {
  final String id;
  final String uuid;
  final String hcoId;
  final String departmentName;

  Department({
    required this.id,
    required this.uuid,
    required this.hcoId,
    required this.departmentName,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid']?.toString() ?? '',
      hcoId: json['hco_id']?.toString() ?? '',
      departmentName: json['department_name']?.toString() ?? '',
    );
  }
}