import 'dart:convert';

class RoomInvitationModel {
  final String id;
  final RoomInvitationRoom room;
  final RoomInvitationUser sender;
  final RoomInvitationUser receiver;
  final String permission; // "view", "edit", "delete"
  final String? message;
  final String status; // "pending", "accepted", "rejected", "cancelled"
  final DateTime? respondedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoomInvitationModel({
    required this.id,
    required this.room,
    required this.sender,
    required this.receiver,
    required this.permission,
    this.message,
    required this.status,
    this.respondedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoomInvitationModel.fromJson(Map<String, dynamic> json) {
    return RoomInvitationModel(
      id: json["_id"] ?? json["id"] ?? '',
      room: RoomInvitationRoom.fromJson(json["room"] ?? {}),
      sender: RoomInvitationUser.fromJson(json["sender"] ?? {}),
      receiver: RoomInvitationUser.fromJson(json["receiver"] ?? {}),
      permission: json["permission"] ?? 'view',
      message: json["message"],
      status: json["status"] ?? 'pending',
      respondedAt: json["respondedAt"] != null
          ? (json["respondedAt"] is String
              ? DateTime.parse(json["respondedAt"])
              : json["respondedAt"] as DateTime)
          : null,
      createdAt: json["createdAt"] != null
          ? (json["createdAt"] is String
              ? DateTime.parse(json["createdAt"])
              : json["createdAt"] as DateTime)
          : DateTime.now(),
      updatedAt: json["updatedAt"] != null
          ? (json["updatedAt"] is String
              ? DateTime.parse(json["updatedAt"])
              : json["updatedAt"] as DateTime)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "room": room.toJson(),
      "sender": sender.toJson(),
      "receiver": receiver.toJson(),
      "permission": permission,
      "message": message,
      "status": status,
      "respondedAt": respondedAt?.toIso8601String(),
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';
}

class RoomInvitationRoom {
  final String id;
  final String? name;
  final String? description;

  RoomInvitationRoom({
    required this.id,
    this.name,
    this.description,
  });

  factory RoomInvitationRoom.fromJson(Map<String, dynamic> json) {
    return RoomInvitationRoom(
      id: json["_id"] ?? json["id"] ?? '',
      name: json["name"],
      description: json["description"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "description": description,
    };
  }
}

class RoomInvitationUser {
  final String id;
  final String? name;
  final String? email;

  RoomInvitationUser({
    required this.id,
    this.name,
    this.email,
  });

  factory RoomInvitationUser.fromJson(Map<String, dynamic> json) {
    return RoomInvitationUser(
      id: json["_id"] ?? json["id"] ?? '',
      name: json["name"],
      email: json["email"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "email": email,
    };
  }
}

