import 'dart:convert';
import 'dart:io';
import 'package:filevo/services/api_endpoints.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/storage_service.dart';

class FolderService {
  Future<Map<String, dynamic>> createFolder({
    required String name,
    String? parentId,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      'name': name,
      if (parentId != null) 'parentId': parentId,
    });

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.folders}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    return jsonDecode(response.body);
  }

  // رفع مجلد - اختيار ملفات ورفعهم في مجلد
  Future<Map<String, dynamic>> uploadFolder({
    required String folderName,
    required List<Map<String, dynamic>> filesData,
    required List<String> relativePaths,
    String? parentFolderId,
  }) async {
    final token = await StorageService.getToken();

    // ✅ التحقق من أن عدد الملفات يطابق عدد المسارات النسبية
    if (filesData.length != relativePaths.length) {
      throw Exception(
        'Files count (${filesData.length}) does not match relativePaths count (${relativePaths.length})'
      );
    }

    // ✅ التحقق من أن جميع الملفات تحتوي على بيانات
    for (var fileData in filesData) {
      final bytes = fileData['bytes'] as List<int>;
      if (bytes.isEmpty) {
        throw Exception('File is empty: ${fileData['fileName']}');
      }
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.uploadFolder}"),
    );
     
    
    request.headers['Authorization'] = "Bearer $token";

    request.fields['folderName'] = folderName;

    if (parentFolderId != null) {
      request.fields['parentFolderId'] = parentFolderId;
    }

    // ✅ إرسال relativePaths كـ JSON string
    // الباك يتوقع string أو array، وسيحول string إلى array تلقائياً
    // ✅ التأكد من أن relativePaths تطابق عدد الملفات
    if (relativePaths.length != filesData.length) {
      print("⚠️ WARNING: relativePaths count (${relativePaths.length}) != files count (${filesData.length})");
      print("⚠️ Fixing relativePaths...");
      // ✅ إصلاح: إضافة relativePaths ناقصة
      while (relativePaths.length < filesData.length) {
        int index = relativePaths.length;
        relativePaths.add(filesData[index]['fileName'] as String);
      }
      // ✅ إزالة relativePaths الزائدة
      if (relativePaths.length > filesData.length) {
        relativePaths = relativePaths.sublist(0, filesData.length);
      }
      print("✅ Fixed relativePaths count: ${relativePaths.length}");
    }
    
    // ✅ إرسال relativePaths كـ JSON string فقط
    // لا نرسل relativePaths[] كحقول منفصلة لأن multer يحسبها كملفات
    String relativePathsJson = jsonEncode(relativePaths);
    request.fields['relativePaths'] = relativePathsJson;
    
    print("📋 Final relativePaths to send:");
    print("   Count: ${relativePaths.length}");
    print("   List: $relativePaths");
    print("   JSON string: $relativePathsJson");
    
    // ✅ التحقق من أن JSON صحيح
    try {
      final decoded = jsonDecode(relativePathsJson);
      print("   ✅ JSON is valid, decoded count: ${decoded.length}");
      if (decoded.length != relativePaths.length) {
        print("   ⚠️ WARNING: Decoded count doesn't match!");
      }
    } catch (e) {
      print("   ❌ ERROR: JSON is invalid! $e");
    }

    print('📤 Uploading folder: $folderName');
    print('📁 Files count: ${filesData.length}');
    print('📂 Relative paths: ${relativePaths.length}');
    print('📋 Request fields:');
    print('   folderName: $folderName');
    print('   parentFolderId: ${parentFolderId ?? "null"}');
    print('   relativePaths (JSON): ${request.fields['relativePaths']}');
    print('   relativePaths (decoded): $relativePaths');

    // 🔥 إضافة الملفات بشكل صحيح
    // جميع الملفات ترسل بنفس الاسم 'files' (multipart/form-data)
    for (int i = 0; i < filesData.length; i++) {
      final fileData = filesData[i];
      final bytes = fileData['bytes'] as List<int>;
      final fileName = fileData['fileName'] as String;
      final relativePath = relativePaths[i];

      print('📄 Adding file ${i + 1}/${filesData.length}: $fileName');
      print('   Size: ${bytes.length} bytes');
      print('   Relative path: $relativePath');

      // ✅ استخدام MultipartFile.fromBytes
      request.files.add(
        http.MultipartFile.fromBytes(
          'files',      // اسم الحقل ثابت - الباك يتوقع 'files' كـ array
          bytes,
          filename: fileName,
        ),
      );
    }

    print('🚀 Sending request to: ${ApiConfig.baseUrl}${ApiEndpoints.uploadFolder}');

    try {
      final res = await request.send();
      print('📥 Response received with status code: ${res.statusCode}');
      final response = await http.Response.fromStream(res);

      print('📥 Response status code: ${response.statusCode}');
      print('📥 Response headers: ${response.headers}');
      print('📥 Response body length: ${response.body.length}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final decodedResponse = jsonDecode(response.body);
          print('✅ Folder uploaded successfully');
          print('✅ Response data: $decodedResponse');
          return decodedResponse;
        } catch (e) {
          print('❌ Failed to decode JSON response: $e');
          print('❌ Response body: ${response.body}');
          throw Exception('Invalid JSON response: ${response.body}');
        }
      } else {
        print('❌ Upload failed with status: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        
        // محاولة قراءة error message من الـ response
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? errorData['error'] ?? response.body;
          throw Exception('Failed to upload folder: $errorMessage');
        } catch (e) {
          if (e.toString().contains('Failed to upload folder')) {
            rethrow;
          }
          throw Exception('Failed to upload folder: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('❌ Exception during upload: $e');
      print('❌ Exception type: ${e.runtimeType}');
      rethrow;
    }
  }

  // ✅ جلب جميع المجلدات بدون parent (parentId = null)
  Future<Map<String, dynamic>> getAllFolders({
    int page = 1,
    int limit = 10,
  }) async {
    final token = await StorageService.getToken();

    final uri = Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.allFolders}")
        .replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
    });

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get folders: ${response.body}');
    }
  }

  // ✅ جلب محتويات مجلد معين (subfolders + files)
  Future<Map<String, dynamic>> getFolderContents({
    required String folderId,
    int page = 1,
    int limit = 20,
  }) async {
    final token = await StorageService.getToken();

    final uri = Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.folderContents(folderId)}")
        .replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
    });

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // ✅ الباك إند الجديد يعيد contents, subfolders, files, totalItems
      // ✅ التأكد من أن البيانات في الصيغة الصحيحة
      return data;
    } else if (response.statusCode == 403) {
      throw Exception('Access denied: You do not have permission to access this folder');
    } else if (response.statusCode == 404) {
      throw Exception('Folder not found');
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to get folder contents: ${response.body}');
    }
  }

  // ✅ جلب جميع العناصر (folders + files) بدون parent
  Future<Map<String, dynamic>> getAllItems({
    int page = 1,
    int limit = 20,
  }) async {
    final token = await StorageService.getToken();

    final uri = Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.allItems}")
        .replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
    });

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get all items: ${response.body}');
    }
  }

  // ✅ تحديث مجلد
  Future<Map<String, dynamic>> updateFolder({
    required String folderId,
    String? name,
    String? description,
    List<String>? tags,
  }) async {
    final token = await StorageService.getToken();

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (tags != null) body['tags'] = tags;

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.updateFolder(folderId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to update folder');
    }
  }

  /// 🔄 نقل مجلد من مجلد إلى آخر
  Future<Map<String, dynamic>> moveFolder({
    required String folderId,
    String? targetFolderId, // null للجذر أو folderId للمجلد
  }) async {
    final token = await StorageService.getToken();

    final body = <String, dynamic>{
      'targetFolderId': targetFolderId, // يمكن أن يكون null
    };

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.moveFolder(folderId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to move folder');
    }
  }

  // ✅ جلب تفاصيل مجلد
  Future<Map<String, dynamic>> getFolderDetails({
    required String folderId,
  }) async {
    final token = await StorageService.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.folderById(folderId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to get folder details');
    }
  }

  // ✅ جلب تفاصيل مجلد مشترك في روم
  Future<Map<String, dynamic>> getSharedFolderDetailsInRoom({
    required String folderId,
  }) async {
    final token = await StorageService.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.getSharedFolderDetailsInRoom(folderId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Folder not found in room');
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to get shared folder details in room');
    }
  }

  // ✅ مشاركة مجلد مع مستخدمين
  Future<Map<String, dynamic>> shareFolder({
    required String folderId,
    required List<String> userIds,
    required String permission, // 'view', 'edit', 'delete'
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      'users': userIds,
      'permission': permission,
    });

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.shareFolder(folderId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to share folder');
    }
  }

  // ✅ تحديث صلاحيات مشاركة المجلد
  Future<Map<String, dynamic>> updateFolderPermissions({
    required String folderId,
    required List<Map<String, dynamic>> userPermissions, // [{userId: '...', permission: 'view'}]
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      'userPermissions': userPermissions,
    });

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.shareFolder(folderId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to update folder permissions');
    }
  }

  // ✅ إلغاء مشاركة المجلد
  Future<Map<String, dynamic>> unshareFolder({
    required String folderId,
    required List<String> userIds,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      'users': userIds,
    });

    final response = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.shareFolder(folderId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to unshare folder');
    }
  }

  // ✅ جلب المجلدات المشتركة معي
  Future<Map<String, dynamic>> getFoldersSharedWithMe({
    int page = 1,
    int limit = 10,
  }) async {
    final token = await StorageService.getToken();

    final uri = Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.foldersSharedWithMe}")
        .replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
    });

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get shared folders: ${response.body}');
    }
  }

  // ✅ حذف مجلد (soft delete)
  Future<Map<String, dynamic>> deleteFolder({
    required String folderId,
  }) async {
    final token = await StorageService.getToken();

    final response = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.deleteFolder(folderId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to delete folder');
    }
  }

  // ✅ استعادة مجلد من المهملات
  Future<Map<String, dynamic>> restoreFolder({
    required String folderId,
  }) async {
    final token = await StorageService.getToken();

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.restoreFolder(folderId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to restore folder');
    }
  }

  // ✅ حذف مجلد نهائياً
  Future<Map<String, dynamic>> deleteFolderPermanent({
    required String folderId,
  }) async {
    final token = await StorageService.getToken();

    final response = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.deleteFolderPermanent(folderId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to delete folder permanently');
    }
  }

  // ✅ جلب المجلدات المحذوفة (trash)
  Future<Map<String, dynamic>> getTrashFolders() async {
    final token = await StorageService.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.trashFolders}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to get trash folders');
    }
  }

  // ✅ تنظيف المجلدات المنتهية الصلاحية
  Future<Map<String, dynamic>> cleanExpiredFolders() async {
    final token = await StorageService.getToken();

    final response = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.cleanExpiredFolders}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to clean expired folders');
    }
  }

  // ✅ إضافة/إزالة علامة النجمة من المجلد
  Future<Map<String, dynamic>> toggleStarFolder({
    required String folderId,
  }) async {
    final token = await StorageService.getToken();

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.toggleStarFolder(folderId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to toggle star folder');
    }
  }

  // ✅ جلب المجلدات المميزة
  Future<Map<String, dynamic>> getStarredFolders({
    int page = 1,
    int limit = 20,
  }) async {
    final token = await StorageService.getToken();

    final uri = Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.starredFolders}").replace(
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to get starred folders');
    }
  }

  // ✅ حساب حجم مجلد معين
  Future<Map<String, dynamic>> getFolderSize({
    required String folderId,
  }) async {
    final token = await StorageService.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.folderSize(folderId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to get folder size');
    }
  }

  // ✅ حساب عدد الملفات في مجلد معين
  Future<Map<String, dynamic>> getFolderFilesCount({
    required String folderId,
  }) async {
    final token = await StorageService.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.folderFilesCount(folderId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to get folder files count');
    }
  }

  // ✅ حساب إحصائيات المجلد (الحجم + عدد الملفات) - الأكثر كفاءة
  Future<Map<String, dynamic>> getFolderStats({
    required String folderId,
  }) async {
    final token = await StorageService.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.folderStats(folderId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to get folder statistics');
    }
  }

}
