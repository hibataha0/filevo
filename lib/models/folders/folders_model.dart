import 'dart:convert';

class FolderModel {
  final String id;
  final String name;
  final String userId;
  final String? parentId;
  final int size;
  final String path;
  final bool isShared;
  final List<SharedUser> sharedWith;
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime? deleteExpiryDate;
  final bool isStarred;
  final String? description;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  FolderModel({
    required this.id,
    required this.name,
    required this.userId,
    this.parentId,
    required this.size,
    required this.path,
    required this.isShared,
    required this.sharedWith,
    required this.isDeleted,
    this.deletedAt,
    this.deleteExpiryDate,
    required this.isStarred,
    this.description,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: json["_id"],
      name: json["name"],
      userId: json["userId"],
      parentId: json["parentId"],
      size: json["size"] ?? 0,
      path: json["path"],
      isShared: json["isShared"] ?? false,
      sharedWith: json["sharedWith"] != null
          ? List<SharedUser>.from(
              json["sharedWith"].map((x) => SharedUser.fromJson(x)))
          : [],
      isDeleted: json["isDeleted"] ?? false,
      deletedAt:
          json["deletedAt"] != null ? DateTime.parse(json["deletedAt"]) : null,
      deleteExpiryDate: json["deleteExpiryDate"] != null
          ? DateTime.parse(json["deleteExpiryDate"])
          : null,
      isStarred: json["isStarred"] ?? false,
      description: json["description"],
      tags: json["tags"] != null ? List<String>.from(json["tags"]) : [],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }
}

class SharedUser {
  final String user;
  final String permission;
  final DateTime sharedAt;

  SharedUser({
    required this.user,
    required this.permission,
    required this.sharedAt,
  });

  factory SharedUser.fromJson(Map<String, dynamic> json) {
    return SharedUser(
      user: json["user"],
      permission: json["permission"],
      sharedAt: DateTime.parse(json["sharedAt"]),
    );
  }
}
