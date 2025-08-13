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
    required this.status,
  });

  final int? id;
  final String? uuid;
  final int? roomId;
  final int? status;

  factory PendingRound.fromJson(Map<String, dynamic> json) {
    return PendingRound(
      id: _parseInt(json["id"]),
      uuid: json["uuid"]?.toString(),
      roomId: _parseInt(json["room_id"]),
      status: _parseInt(json["status"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "uuid": uuid,
        "room_id": roomId,
        "status": status,
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