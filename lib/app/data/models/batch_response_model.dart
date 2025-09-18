// First, add these models to app/data/models/batch_response_model.dart

class Location {
  final String id;
  final String uuid;
  final String roomNumber;
  final String blockName;
  final String floorName;

  Location({
    required this.id,
    required this.uuid,
    required this.roomNumber,
    required this.blockName,
    required this.floorName,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'].toString(),
      uuid: json['uuid'],
      roomNumber: json['room_number'],
      blockName: json['block_name'],
      floorName: json['floor_name'],
    );
  }
}

class User {
  final String id;
  final String uuid;
  final String username;

  User({
    required this.id,
    required this.uuid,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      uuid: json['uuid'],
      username: json['username'],
    );
  }
}

class BatchResponse {
  final List<Location> locations;
  final List<User> users;
  final int status;
  final String message;

  BatchResponse({
    required this.locations,
    required this.users,
    required this.status,
    required this.message,
  });

  factory BatchResponse.fromJson(Map<String, dynamic> json) {
    return BatchResponse(
      locations: (json['locations'] as List<dynamic>)
          .map((e) => Location.fromJson(e))
          .toList(),
      users: (json['users'] as List<dynamic>)
          .map((e) => User.fromJson(e))
          .toList(),
      status: json['status'],
      message: json['message'],
    );
  }
}