import 'dart:convert';

class RoomModel {
  final String id;
  final String name;
  final String? description;
  final RoomOwner owner;
  final List<RoomMember> members;
  final List<RoomFile> files;
  final List<RoomFolder> folders;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoomModel({
    required this.id,
    required this.name,
    this.description,
    required this.owner,
    required this.members,
    required this.files,
    required this.folders,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json["_id"] ?? json["id"] ?? '',
      name: json["name"] ?? '',
      description: json["description"],
      owner: RoomOwner.fromJson(json["owner"] ?? {}),
      members: (json["members"] as List?)
              ?.map((m) => RoomMember.fromJson(m))
              .toList() ??
          [],
      files: (json["files"] as List?)
              ?.map((f) => RoomFile.fromJson(f))
              .toList() ??
          [],
      folders: (json["folders"] as List?)
              ?.map((f) => RoomFolder.fromJson(f))
              .toList() ??
          [],
      isActive: json["isActive"] ?? true,
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
      "name": name,
      "description": description,
      "owner": owner.toJson(),
      "members": members.map((m) => m.toJson()).toList(),
      "files": files.map((f) => f.toJson()).toList(),
      "folders": folders.map((f) => f.toJson()).toList(),
      "isActive": isActive,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}

class RoomOwner {
  final String id;
  final String? name;
  final String? email;

  RoomOwner({
    required this.id,
    this.name,
    this.email,
  });

  factory RoomOwner.fromJson(Map<String, dynamic> json) {
    return RoomOwner(
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

class RoomMember {
  final String id;
  final RoomMemberUser user;
  final String role; // "owner", "editor", "viewer", "commenter"
  final DateTime joinedAt;

  RoomMember({
    required this.id,
    required this.user,
    required this.role,
    required this.joinedAt,
  });

  factory RoomMember.fromJson(Map<String, dynamic> json) {
    return RoomMember(
      id: json["_id"]?.toString() ?? json["id"]?.toString() ?? '',
      user: RoomMemberUser.fromJson(json["user"] ?? {}),
      role: json["role"] ?? 'viewer',
      joinedAt: json["joinedAt"] != null
          ? (json["joinedAt"] is String
              ? DateTime.parse(json["joinedAt"])
              : json["joinedAt"] as DateTime)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "user": user.toJson(),
      "role": role,
      "joinedAt": joinedAt.toIso8601String(),
    };
  }
}

class RoomMemberUser {
  final String id;
  final String? name;
  final String? email;

  RoomMemberUser({
    required this.id,
    this.name,
    this.email,
  });

  factory RoomMemberUser.fromJson(Map<String, dynamic> json) {
    return RoomMemberUser(
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

class RoomFile {
  final String id;
  final RoomFileRef fileId;
  final RoomMemberUser? sharedBy;
  final DateTime sharedAt;

  RoomFile({
    required this.id,
    required this.fileId,
    this.sharedBy,
    required this.sharedAt,
  });

  factory RoomFile.fromJson(Map<String, dynamic> json) {
    return RoomFile(
      id: json["_id"]?.toString() ?? json["id"]?.toString() ?? '',
      fileId: RoomFileRef.fromJson(json["fileId"] ?? {}),
      sharedBy: json["sharedBy"] != null
          ? RoomMemberUser.fromJson(json["sharedBy"])
          : null,
      sharedAt: json["sharedAt"] != null
          ? (json["sharedAt"] is String
              ? DateTime.parse(json["sharedAt"])
              : json["sharedAt"] as DateTime)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "fileId": fileId.toJson(),
      if (sharedBy != null) "sharedBy": sharedBy!.toJson(),
      "sharedAt": sharedAt.toIso8601String(),
    };
  }
}

class RoomFileRef {
  final String id;
  final String? name;
  final String? path;
  final String? category;

  RoomFileRef({
    required this.id,
    this.name,
    this.path,
    this.category,
  });

  factory RoomFileRef.fromJson(Map<String, dynamic> json) {
    return RoomFileRef(
      id: json["_id"] ?? json["id"] ?? '',
      name: json["name"],
      path: json["path"],
      category: json["category"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "path": path,
      "category": category,
    };
  }
}

class RoomFolder {
  final String id;
  final RoomFolderRef folderId;
  final RoomMemberUser? sharedBy;
  final DateTime sharedAt;

  RoomFolder({
    required this.id,
    required this.folderId,
    this.sharedBy,
    required this.sharedAt,
  });

  factory RoomFolder.fromJson(Map<String, dynamic> json) {
    return RoomFolder(
      id: json["_id"]?.toString() ?? json["id"]?.toString() ?? '',
      folderId: RoomFolderRef.fromJson(json["folderId"] ?? {}),
      sharedBy: json["sharedBy"] != null
          ? RoomMemberUser.fromJson(json["sharedBy"])
          : null,
      sharedAt: json["sharedAt"] != null
          ? (json["sharedAt"] is String
              ? DateTime.parse(json["sharedAt"])
              : json["sharedAt"] as DateTime)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "folderId": folderId.toJson(),
      if (sharedBy != null) "sharedBy": sharedBy!.toJson(),
      "sharedAt": sharedAt.toIso8601String(),
    };
  }
}

class RoomFolderRef {
  final String id;
  final String? name;
  final String? path;

  RoomFolderRef({
    required this.id,
    this.name,
    this.path,
  });

  factory RoomFolderRef.fromJson(Map<String, dynamic> json) {
    return RoomFolderRef(
      id: json["_id"] ?? json["id"] ?? '',
      name: json["name"],
      path: json["path"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "path": path,
    };
  }
}









