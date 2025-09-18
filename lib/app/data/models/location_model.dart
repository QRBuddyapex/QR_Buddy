class LocationResponse {
  final List<Block> blocks;
  final List<Floor> floors;
  final List<Room> rooms;
  final int status;
  final String message;

  LocationResponse({
    required this.blocks,
    required this.floors,
    required this.rooms,
    required this.status,
    required this.message,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      blocks: (json['blocks'] as List<dynamic>)
          .map((e) => Block.fromJson(e as Map<String, dynamic>))
          .toList(),
      floors: (json['floors'] as List<dynamic>)
          .map((e) => Floor.fromJson(e as Map<String, dynamic>))
          .toList(),
      rooms: (json['rooms'] as List<dynamic>)
          .map((e) => Room.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as int,
      message: json['message'] as String,
    );
  }
}

class Block {
  final String id;
  final String blockName;
  final String status;

  Block({
    required this.id,
    required this.blockName,
    required this.status,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      id: json['id'] as String,
      blockName: json['block_name'] as String,
      status: json['status'] as String,
    );
  }
}

class Floor {
  final String id;
  final String floorName;
  final String blockName;
  final String status;

  Floor({
    required this.id,
    required this.floorName,
    required this.blockName,
    required this.status,
  });

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      id: json['id'] as String,
      floorName: json['floor_name'] as String,
      blockName: json['block_name'] as String,
      status: json['status'] as String,
    );
  }
}

class Room {
  final String id;
  final String blockId;
  final String floorId;
  final String blockName;
  final String floorName;
  final String roomNumber;
  final String? locationId;

  Room({
    required this.id,
    required this.blockId,
    required this.floorId,
    required this.blockName,
    required this.floorName,
    required this.roomNumber,
    this.locationId,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      blockId: json['block_id'] as String,
      floorId: json['floor_id'] as String,
      blockName: json['block_name'] as String,
      floorName: json['floor_name'] as String,
      roomNumber: json['room_number'] as String,
      locationId: json['location_id'] as String?,
    );
  }
}

class SaveLocationResponse {
  final String rooms;
  final int status;
  final String message;

  SaveLocationResponse({
    required this.rooms,
    required this.status,
    required this.message,
  });

  factory SaveLocationResponse.fromJson(Map<String, dynamic> json) {
    return SaveLocationResponse(
      rooms: json['rooms'] as String,
      status: json['status'] as int,
      message: json['message'] as String,
    );
  }
}

class SelectedRoom {
  final String blockId;
  final String floorId;
  final String roomId;

  SelectedRoom({
    required this.blockId,
    required this.floorId,
    required this.roomId,
  });

  Map<String, String> toJson() {
    return {
      'block_id': blockId,
      'floor_id': floorId,
      'room_id': roomId,
    };
  }
}