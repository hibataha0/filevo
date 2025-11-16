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
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['_id'],
      name: json['name'],
      type: json['type'],
      size: json['size'],
      path: json['path'],
      category: json['category'],
      isShared: json['isShared'] ?? false,
      isStarred: json['isStarred'] ?? false,
      description: json['description'],
    );
  }
}
