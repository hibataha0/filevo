import 'package:filevo/services/api_service.dart';
import 'package:filevo/services/api_endpoints.dart';
import 'package:filevo/services/storage_service.dart';

/// خدمة للتعامل مع المجلدات (Folders)
/// مثال على كيفية استخدام ApiService مع token
class FoldersService {
  final ApiService _apiService = ApiService();

  /// الحصول على جميع المجلدات
  /// 
  /// مثال:
  /// ```dart
  /// final foldersService = FoldersService();
  /// final result = await foldersService.getAllFolders();
  /// 
  /// if (result['success']) {
  ///   final folders = result['data']['folders'] as List;
  ///   // استخدم المجلدات في UI
  /// } else {
  ///   print('Error: ${result['error']}');
  /// }
  /// ```
  Future<Map<String, dynamic>> getAllFolders({
    Map<String, String>? queryParameters,
  }) async {
    final token = await StorageService.getToken();
    
    return await _apiService.get(
      ApiEndpoints.folders,
      token: token,
      queryParameters: queryParameters,
    );
  }

  /// الحصول على مجلد محدد بالـ ID
  Future<Map<String, dynamic>> getFolderById(String folderId) async {
    final token = await StorageService.getToken();
    
    return await _apiService.get(
      ApiEndpoints.folderById(folderId),
      token: token,
    );
  }

  /// الحصول على ملفات مجلد معين
  Future<Map<String, dynamic>> getFolderFiles(
    String folderId, {
    Map<String, String>? queryParameters,
  }) async {
    final token = await StorageService.getToken();
    
    return await _apiService.get(
      ApiEndpoints.folderFiles(folderId),
      token: token,
      queryParameters: queryParameters,
    );
  }

  /// إنشاء مجلد جديد
  Future<Map<String, dynamic>> createFolder({
    required String name,
    String? parentId,
    Map<String, dynamic>? additionalData,
  }) async {
    final token = await StorageService.getToken();
    
    final body = {
      'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (additionalData != null) ...additionalData,
    };

    return await _apiService.post(
      ApiEndpoints.folders,
      body: body,
      token: token,
    );
  }

  /// تحديث مجلد
  Future<Map<String, dynamic>> updateFolder(
    String folderId, {
    String? name,
    Map<String, dynamic>? additionalData,
  }) async {
    final token = await StorageService.getToken();
    
    final body = {
      if (name != null) 'name': name,
      if (additionalData != null) ...additionalData,
    };

    return await _apiService.put(
      ApiEndpoints.folderById(folderId),
      body: body,
      token: token,
    );
  }

  /// حذف مجلد
  Future<Map<String, dynamic>> deleteFolder(String folderId) async {
    final token = await StorageService.getToken();
    
    return await _apiService.delete(
      ApiEndpoints.folderById(folderId),
      token: token,
    );
  }
}

