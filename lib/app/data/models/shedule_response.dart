// app/data/models/checklist_batch_model.dart
class ChecklistBatchModel {
  final List<Location> locations;
  final List<User> users;
  final int status;
  final String message;

  ChecklistBatchModel({
    required this.locations,
    required this.users,
    required this.status,
    required this.message,
  });

  factory ChecklistBatchModel.fromJson(Map<String, dynamic> json) {
    return ChecklistBatchModel(
      locations: (json['locations'] as List<dynamic>?)
              ?.map((e) => Location.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      users: (json['users'] as List<dynamic>?)
              ?.map((e) => User.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status'] as int? ?? 0,
      message: json['message'] as String? ?? '',
    );
  }
}

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
      id: json['id'] as String? ?? '',
      uuid: json['uuid'] as String? ?? '',
      roomNumber: json['room_number'] as String? ?? '',
      blockName: json['block_name'] as String? ?? '',
      floorName: json['floor_name'] as String? ?? '',
    );
  }

  String get displayName => '$roomNumber ($blockName / $floorName)';
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
      id: json['id'] as String? ?? '',
      uuid: json['uuid'] as String? ?? '',
      username: json['username'] as String? ?? '',
    );
  }

  String get displayName => username;
}