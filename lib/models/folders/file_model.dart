class FileModel {
  final String id;
  final String name;
  final String type;
  final int size;
  final String path;
  final String category;
  final bool isShared;
  final bool isStarred;
  final String? description;
  final DateTime? updatedAt;
  final int? updatedAtTimestamp; // ✅ للاستخدام في cache busting

  FileModel({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.path,
    required this.category,
    this.isShared = false,
    this.isStarred = false,
    this.description,
    this.updatedAt,
    this.updatedAtTimestamp,
  });

  // ✅ دالة للحصول على URL مع cache busting
  String getCacheBustedUrl(String baseUrl) {
    // ✅ بناء URL من path أو استخدام baseUrl
    final cleanUrl = baseUrl.split('?').first;
    final timestamp = updatedAtTimestamp ?? 
        (updatedAt != null ? updatedAt!.millisecondsSinceEpoch : DateTime.now().millisecondsSinceEpoch);
    return '$cleanUrl?v=$timestamp';
  }

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      size: json['size'] ?? 0,
      path: json['path'] ?? '',
      category: json['category'] ?? '',
      isShared: json['isShared'] ?? false,
      isStarred: json['isStarred'] ?? false,
      description: json['description'],
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is String
              ? DateTime.parse(json['updatedAt'])
              : json['updatedAt'] as DateTime)
          : null,
      updatedAtTimestamp: json['updatedAtTimestamp'] ??
          (json['updatedAt'] != null
              ? (json['updatedAt'] is String
                  ? DateTime.parse(json['updatedAt']).millisecondsSinceEpoch
                  : (json['updatedAt'] as DateTime).millisecondsSinceEpoch)
              : null),
    );
  }
}
