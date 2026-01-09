class FolderModel {
  final String id;
  final String name;
  final String userId;
  final String? parentId;
  final int size;
  final int filesCount; // ✅ عدد الملفات الكلي (recursive)
  final String path;
  final bool isShared;
  final List<SharedUser> sharedWith;
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime? deleteExpiryDate;
  final bool isStarred;
  final String? description;
  final List<String> tags;

  // 🔒 Folder protection
  final bool isProtected;
  final String protectionType; // none | password | biometric

  final DateTime createdAt;
  final DateTime updatedAt;

  FolderModel({
    required this.id,
    required this.name,
    required this.userId,
    this.parentId,
    required this.size,
    required this.filesCount,
    required this.path,
    required this.isShared,
    required this.sharedWith,
    required this.isDeleted,
    this.deletedAt,
    this.deleteExpiryDate,
    required this.isStarred,
    this.description,
    required this.tags,
    required this.isProtected,
    required this.protectionType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    // ✅ تحويل size إلى int بشكل آمن
    int size = 0;
    final sizeValue = json["size"];
    if (sizeValue != null) {
      if (sizeValue is int) {
        size = sizeValue;
      } else if (sizeValue is num) {
        size = sizeValue.toInt();
      } else if (sizeValue is String) {
        size = int.tryParse(sizeValue) ?? 0;
      }
    }

    // ✅ تحويل filesCount إلى int بشكل آمن
    int filesCount = 0;
    final filesCountValue = json["filesCount"];
    if (filesCountValue != null) {
      if (filesCountValue is int) {
        filesCount = filesCountValue;
      } else if (filesCountValue is num) {
        filesCount = filesCountValue.toInt();
      } else if (filesCountValue is String) {
        filesCount = int.tryParse(filesCountValue) ?? 0;
      }
    }

    return FolderModel(
      id: json["_id"],
      name: json["name"],
      userId: json["userId"],
      parentId: json["parentId"],
      size: size,
      filesCount: filesCount,
      path: json["path"],
      isShared: json["isShared"] ?? false,
      sharedWith: json["sharedWith"] != null
          ? List<SharedUser>.from(
              json["sharedWith"].map((x) => SharedUser.fromJson(x)),
            )
          : [],
      isDeleted: json["isDeleted"] ?? false,
      deletedAt: json["deletedAt"] != null
          ? DateTime.parse(json["deletedAt"])
          : null,
      deleteExpiryDate: json["deleteExpiryDate"] != null
          ? DateTime.parse(json["deleteExpiryDate"])
          : null,
      isStarred: json["isStarred"] ?? false,
      description: json["description"],
      tags: json["tags"] != null ? List<String>.from(json["tags"]) : [],

      // 🔒
      isProtected: json["isProtected"] ?? false,
      protectionType: json["protectionType"] ?? "none",

      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "userId": userId,
      "parentId": parentId,
      "size": size,
      "filesCount": filesCount,
      "path": path,
      "isShared": isShared,
      "sharedWith": sharedWith.map((x) => x.toJson()).toList(),
      "isDeleted": isDeleted,
      "deletedAt": deletedAt?.toIso8601String(),
      "deleteExpiryDate": deleteExpiryDate?.toIso8601String(),
      "isStarred": isStarred,
      "description": description,
      "tags": tags,
      "isProtected": isProtected,
      "protectionType": protectionType,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
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

  Map<String, dynamic> toJson() {
    return {
      "user": user,
      "permission": permission,
      "sharedAt": sharedAt.toIso8601String(),
    };
  }
}
