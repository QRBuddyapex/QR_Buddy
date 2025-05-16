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
      order: Order.fromJson(json['order']),
      history: (json['history'] as List)
          .map((item) => History.fromJson(item))
          .toList(),
      activeUsers: (json['active_users'] as List)
          .map((item) => ActiveUser.fromJson(item))
          .toList(),
      users: Users.fromJson(json['users']),
      department: Department.fromJson(json['department']),
      status: json['status'],
      message: json['message'],
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
      id: json['id'],
      uuid: json['uuid'],
      requestNumber: json['request_number'],
      hcoId: json['hco_id'],
      departmentId: json['department_id'],
      departmentName: json['department_name'],
      roomId: json['room_id'],
      roomNumber: json['room_number'],
      blockName: json['block_name'],
      floorName: json['floor_name'],
      serviceId: json['service_id'],
      serviceName: json['service_name'],
      assignedTo: json['assigned_to'],
      assignedToUsername: json['assigned_to_username'],
      requestStatus: json['request_status'],
      requestType: json['request_type'],
      priority: json['priority'],
      source: json['source'],
      mapLong: json['map_long'],
      mapLat: json['map_lat'],
      phoneNumber: json['phone_number'],
      timeStart: json['time_start'],
      timeAccepted: json['time_accepted'],
      createdAt: json['created_at'],
      createdAtDate: json['created_at_date'],
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
      id: json['id'],
      orderId: json['order_id'],
      userId: json['user_id'],
      type: json['type'],
      caption: json['caption'],
      remarks: json['remarks'],
      messageType: json['message_type'],
      phoneNumber: json['phone_number'],
      statusWhatsapp: json['status_whatsapp'],
      createdAt: json['created_at'],
      createdAtDate: json['created_at_date'],
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
      id: json['id'],
      uuid: json['uuid'],
      hcoId: json['hco_id'],
      departmentId: json['department_id'],
      username: json['username'],
      userType: json['user_type'],
      shiftStatus: json['shift_status'],
      activeTasks: json['active_tasks'],
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
      result: (json['RESULT'] as List)
          .map((item) => User.fromJson(item))
          .toList(),
      count: json['COUNT'],
      total: json['TOTAL'],
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
      id: json['id'],
      uuid: json['uuid'],
      hcoId: json['hco_id'],
      departmentId: json['department_id'],
      username: json['username'],
      userType: json['user_type'],
      shiftStatus: json['shift_status'],
      activeTasks: json['active_tasks'],
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
      id: json['id'],
      uuid: json['uuid'],
      hcoId: json['hco_id'],
      departmentName: json['department_name'],
    );
  }
}