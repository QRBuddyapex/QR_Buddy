class FoodDeliveryResponse {
  FoodDeliveryResponse({
    required this.pendingRounds,
    required this.status,
    required this.message,
  });

  final List<PendingRound> pendingRounds;
  final int? status;
  final String? message;

  factory FoodDeliveryResponse.fromJson(Map<String, dynamic> json) {
    return FoodDeliveryResponse(
      pendingRounds: json["pending_rounds"] == null
          ? []
          : List<PendingRound>.from(
              json["pending_rounds"].map((x) => PendingRound.fromJson(x))),
      status: _parseInt(json["status"]),
      message: json["message"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "pending_rounds": pendingRounds.map((x) => x.toJson()).toList(),
        "status": status,
        "message": message,
      };
}
class PendingRound {
  PendingRound({
    required this.id,
    required this.uuid,
    required this.roomId,
    required this.roomuuid,
    required this.status,
    required this.roomNumber,
    required this.categoryName,
    required this.categoryUuid, // Add categoryUuid
  });

  final int? id;
  final String? uuid;
  final int? roomId;
  final String? roomuuid;
  final int? status;
  final String? roomNumber;
  final String? categoryName;
  final String? categoryUuid; // New field

  factory PendingRound.fromJson(Map<String, dynamic> json) {
    return PendingRound(
      id: _parseInt(json["id"]),
      uuid: json["uuid"]?.toString(),
      roomId: _parseInt(json["room_id"]),
      status: _parseInt(json["status"]),
      roomNumber: json["room_number"]?.toString(),
      roomuuid: json["room_uuid"]?.toString(), // Parse room_uuid
      categoryName: json["category_name"]?.toString(),
      categoryUuid: json["category_uuid"]?.toString(), // Parse category_uuid
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "uuid": uuid,
        "room_id": roomId,
        "status": status,
        "room_number": roomNumber,
        "room_uuid": roomuuid,
        "category_name": categoryName,
        "category_uuid": categoryUuid,
      };
}
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) {
    try {
      return int.parse(value);
    } catch (e) {
      throw FormatException('Invalid integer format for value: $value');
    }
  }
  throw FormatException('Expected int or String for value: $value');
}