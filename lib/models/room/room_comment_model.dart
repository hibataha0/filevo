class RoomCommentModel {
  final String id;
  final String roomId;
  final String targetType; // "file" or "folder"
  final String targetId;
  final RoomCommentUser user;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoomCommentModel({
    required this.id,
    required this.roomId,
    required this.targetType,
    required this.targetId,
    required this.user,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoomCommentModel.fromJson(Map<String, dynamic> json) {
    return RoomCommentModel(
      id: json["_id"] ?? json["id"] ?? '',
      roomId: json["room"] is String
          ? json["room"]
          : (json["room"]?["_id"] ?? json["room"]?["id"] ?? ''),
      targetType: json["targetType"] ?? '',
      targetId: json["targetId"]?.toString() ?? '',
      user: RoomCommentUser.fromJson(json["user"] ?? {}),
      content: json["content"] ?? '',
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
      "room": roomId,
      "targetType": targetType,
      "targetId": targetId,
      "user": user.toJson(),
      "content": content,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  bool get isFileComment => targetType == 'file';
  bool get isFolderComment => targetType == 'folder';
}

class RoomCommentUser {
  final String id;
  final String? name;
  final String? email;
  final String? profileImg; // ✅ إضافة صورة البروفايل

  RoomCommentUser({
    required this.id,
    this.name,
    this.email,
    this.profileImg, // ✅ إضافة profileImg
  });

  factory RoomCommentUser.fromJson(Map<String, dynamic> json) {
    return RoomCommentUser(
      id: json["_id"] ?? json["id"] ?? '',
      name: json["name"],
      email: json["email"],
      profileImg: json["profileImg"], // ✅ إضافة profileImg
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "email": email,
      "profileImg": profileImg, // ✅ إضافة profileImg
    };
  }
}














