import 'dart:convert';
import 'dart:io';
import 'package:filevo/services/api_endpoints.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';

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

    // ✅ التحقق من status code
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      return {
        "success": false,
        "message": errorData['message'] ?? "Error creating folder",
        "error": errorData,
      };
    }
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
        'Files count (${filesData.length}) does not match relativePaths count (${relativePaths.length})',
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
      print(
        "⚠️ WARNING: relativePaths count (${relativePaths.length}) != files count (${filesData.length})",
      );
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
          'files', // اسم الحقل ثابت - الباك يتوقع 'files' كـ array
          bytes,
          filename: fileName,
        ),
      );
    }

    print(
      '🚀 Sending request to: ${ApiConfig.baseUrl}${ApiEndpoints.uploadFolder}',
    );

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

        // محاولة قراءة error message من الـ response وإرجاعه بدلاً من الرمي
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage =
              errorData['message'] ?? errorData['error'] ?? response.body;
          return {
            'success': false,
            'message': errorMessage,
            'error': errorData,
            'statusCode': response.statusCode,
          };
        } catch (e) {
          return {
            'success': false,
            'message':
                'Failed to upload folder: ${response.statusCode} - ${response.body}',
            'statusCode': response.statusCode,
          };
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
        .replace(
          queryParameters: {'page': page.toString(), 'limit': limit.toString()},
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
      throw Exception('Failed to get folders: ${response.body}');
    }
  }

  /// ✅ جلب المجلدات الحديثة
  Future<Map<String, dynamic>> getRecentFolders({int limit = 10}) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'لا يوجد token. يرجى تسجيل الدخول'};
      }

      final uri = Uri.parse(
        "${ApiConfig.baseUrl}${ApiEndpoints.recentFolders}",
      ).replace(queryParameters: {'limit': limit.toString()});

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'folders': data['folders'] ?? []};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'error': data['message'] ?? 'فشل في جلب المجلدات الحديثة',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في جلب المجلدات الحديثة: ${e.toString()}',
      };
    }
  }

  // ✅ جلب محتويات مجلد معين (subfolders + files)
  // ✅ لا نحتاج password هنا لأن الـ backend يستخدم session بعد التحقق
  Future<Map<String, dynamic>> getFolderContents({
    required String folderId,
    int page = 1,
    int limit = 20,
  }) async {
    final token = await StorageService.getToken();

    final uri =
        Uri.parse(
          "${ApiConfig.baseUrl}${ApiEndpoints.folderContents(folderId)}",
        ).replace(
          queryParameters: {
            'page': page.toString(),
            'limit': limit.toString(),
          },
        );

    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      uri,
      headers: headers,
    );

    print('📡 [FolderService] getFolderContents response status: ${response.statusCode}');
    print('📡 [FolderService] getFolderContents response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ [FolderService] getFolderContents success, data keys: ${data.keys}');
      // ✅ الباك إند الجديد يعيد contents, subfolders, files, totalItems
      // ✅ التأكد من أن البيانات في الصيغة الصحيحة
      return data;
    } else if (response.statusCode == 403) {
      print('❌ [FolderService] getFolderContents: Access denied (403)');
      throw Exception(
        'Access denied: You do not have permission to access this folder. Please verify folder protection.',
      );
    } else if (response.statusCode == 404) {
      print('❌ [FolderService] getFolderContents: Folder not found (404)');
      throw Exception('Folder not found');
    } else {
      final errorData = jsonDecode(response.body);
      print('❌ [FolderService] getFolderContents error: ${errorData['message']}');
      throw Exception(
        errorData['message'] ??
            'Failed to get folder contents: ${response.body}',
      );
    }
  }

  // ✅ جلب جميع العناصر (folders + files) بدون parent
  Future<Map<String, dynamic>> getAllItems({
    int page = 1,
    int limit = 20,
  }) async {
    final token = await StorageService.getToken();

    final uri = Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.allItems}")
        .replace(
          queryParameters: {'page': page.toString(), 'limit': limit.toString()},
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

    final url = "${ApiConfig.baseUrl}${ApiEndpoints.moveFolder(folderId)}";
    print('🔄 Moving folder: $folderId to $targetFolderId');
    print('🔄 URL: $url');

    final response = await http
        .put(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(
          Duration(seconds: 60), // ✅ timeout 60 ثانية لنقل المجلدات الكبيرة
          onTimeout: () {
            throw Exception(
              'انتهت مهلة الطلب. قد يكون المجلد كبيراً جداً. يرجى المحاولة مرة أخرى.',
            );
          },
        );

    print('🔄 Response status: ${response.statusCode}');
    print('🔄 Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      // ✅ معالجة خاصة لخطأ 404 (route غير موجود)
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ??
              'Route not found: ${ApiEndpoints.moveFolder(folderId)}. Please check backend implementation.',
        );
      } catch (e) {
        throw Exception(
          'Route not found: ${ApiEndpoints.moveFolder(folderId)}. Please check backend implementation.',
        );
      }
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ??
              'Failed to move folder: ${response.statusCode}',
        );
      } catch (e) {
        throw Exception(
          'Failed to move folder: ${response.statusCode} - ${response.body}',
        );
      }
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
      Uri.parse(
        "${ApiConfig.baseUrl}${ApiEndpoints.getSharedFolderDetailsInRoom(folderId)}",
      ),
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
      throw Exception(
        errorData['message'] ?? 'Failed to get shared folder details in room',
      );
    }
  }

  // ✅ مشاركة مجلد مع مستخدمين
  Future<Map<String, dynamic>> shareFolder({
    required String folderId,
    required List<String> userIds,
    required String permission, // 'view', 'edit', 'delete'
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({'users': userIds, 'permission': permission});

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
    required List<Map<String, dynamic>>
    userPermissions, // [{userId: '...', permission: 'view'}]
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({'userPermissions': userPermissions});

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
      throw Exception(
        errorData['message'] ?? 'Failed to update folder permissions',
      );
    }
  }

  // ✅ إلغاء مشاركة المجلد
  Future<Map<String, dynamic>> unshareFolder({
    required String folderId,
    required List<String> userIds,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({'users': userIds});

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

    final uri =
        Uri.parse(
          "${ApiConfig.baseUrl}${ApiEndpoints.foldersSharedWithMe}",
        ).replace(
          queryParameters: {'page': page.toString(), 'limit': limit.toString()},
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
      throw Exception('Failed to get shared folders: ${response.body}');
    }
  }

  // ✅ حذف مجلد (soft delete)
  Future<Map<String, dynamic>> deleteFolder({required String folderId}) async {
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
  Future<Map<String, dynamic>> restoreFolder({required String folderId}) async {
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
      Uri.parse(
        "${ApiConfig.baseUrl}${ApiEndpoints.deleteFolderPermanent(folderId)}",
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
        errorData['message'] ?? 'Failed to delete folder permanently',
      );
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
      throw Exception(
        errorData['message'] ?? 'Failed to clean expired folders',
      );
    }
  }

  // ✅ إضافة/إزالة علامة النجمة من المجلد
  Future<Map<String, dynamic>> toggleStarFolder({
    required String folderId,
  }) async {
    final token = await StorageService.getToken();

    final response = await http.put(
      Uri.parse(
        "${ApiConfig.baseUrl}${ApiEndpoints.toggleStarFolder(folderId)}",
      ),
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

    final uri = Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.starredFolders}")
        .replace(
          queryParameters: {'page': page.toString(), 'limit': limit.toString()},
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
  Future<Map<String, dynamic>> getFolderSize({required String folderId}) async {
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
      Uri.parse(
        "${ApiConfig.baseUrl}${ApiEndpoints.folderFilesCount(folderId)}",
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
        errorData['message'] ?? 'Failed to get folder files count',
      );
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
      throw Exception(
        errorData['message'] ?? 'Failed to get folder statistics',
      );
    }
  }

  /// ✅ تحميل مجلد خاص بالمستخدم كـ ZIP
  /// Returns: Map with 'success' and 'filePath' or 'error'
  Future<Map<String, dynamic>> downloadFolder({
    required String folderId,
    String? folderName,
  }) async {
    try {
      final token = await StorageService.getToken();

      // ✅ طلب صلاحية الكتابة للتخزين
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          return {'success': false, 'error': 'تم رفض صلاحية التخزين'};
        }
      }

      final url =
          "${ApiConfig.baseUrl}${ApiEndpoints.downloadFolder(folderId)}";
      print("Downloading folder from: $url");

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      // ✅ الحصول على مجلد التحميلات
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        return {'success': false, 'error': 'فشل في الحصول على مجلد التحميلات'};
      }

      final downloadPath = '${directory.path}/Downloads';
      final downloadDir = Directory(downloadPath);
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final finalFileName = folderName ?? 'folder_$folderId.zip';
      final filePath = '$downloadPath/$finalFileName';

      // ✅ تحميل الملف
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            print('Download progress: $progress%');
          }
        },
      );

      return {'success': true, 'filePath': filePath, 'fileName': finalFileName};
    } on DioException catch (e) {
      print("Download error: ${e.response?.statusCode} - ${e.message}");
      if (e.response?.statusCode == 403) {
        return {'success': false, 'error': 'ليس لديك صلاحية لتحميل هذا المجلد'};
      } else if (e.response?.statusCode == 404) {
        return {'success': false, 'error': 'المجلد غير موجود'};
      } else if (e.response?.statusCode == 400) {
        return {'success': false, 'error': 'المجلد فارغ'};
      }
      return {
        'success': false,
        'error': e.response?.data?['message'] ?? 'فشل تحميل المجلد',
      };
    } catch (e) {
      print("Download error: $e");
      return {
        'success': false,
        'error': 'خطأ في تحميل المجلد: ${e.toString()}',
      };
    }
  }


  /// تعيين حماية المجلد (كلمة سر أو بصمة)
  // Future<Map<String, dynamic>> setFolderProtection({
  //   required String folderId,
  //   required String protectionType, // 'password' or 'biometric'
  //   String? password,
  // }) async {
  //   final token = await StorageService.getToken();
  //   if (token == null) {
  //     return {
  //       'success': false,
  //       'message': 'Authentication token not found.',
  //     };
  //   }

  //   final body = jsonEncode({
  //     'protectionType': protectionType,
  //     if (password != null) 'password': password,
  //   });

  //   try {
  //     final response = await http.put(
  //       Uri.parse(
  //         "${ApiConfig.baseUrl}${ApiEndpoints.protectFolder(folderId)}",
  //       ),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //       body: body,
  //     ).timeout(ApiConfig.timeout);

  //     if (response.statusCode >= 200 && response.statusCode < 300) {
  //       return jsonDecode(response.body);
  //     } else {
  //       final errorData = jsonDecode(response.body);
  //       return {
  //         'success': false,
  //         'message': errorData['message'] ?? 'Failed to set protection',
  //       };
  //     }
  //   } catch (e) {
  //     return {
  //       'success': false,
  //       'message': 'Error setting protection: $e',
  //     };
  //   }
  // }

  /// التحقق من الوصول للمجلد (كلمة سر أو بصمة)
  // Future<Map<String, dynamic>> verifyFolderAccess({
  //   required String folderId,
  //   String? password,
  //   String? biometricToken,
  // }) async {
  //   final token = await StorageService.getToken();
  //   if (token == null) {
  //     return {'success': false, 'message': 'Authentication token not found.'};
  //   }

  //   final body = jsonEncode({
  //     if (password != null) 'password': password,
  //     if (biometricToken != null) 'biometricToken': biometricToken,
  //   });

  //   try {
  //     final response = await http
  //         .post(
  //           Uri.parse(
  //             "${ApiConfig.baseUrl}${ApiEndpoints.verifyFolderAccess(folderId)}",
  //           ),
  //           headers: {
  //             'Authorization': 'Bearer $token',
  //             'Content-Type': 'application/json',
  //           },
  //           body: body,
  //         )
  //         .timeout(ApiConfig.timeout);

  //     if (response.statusCode >= 200 && response.statusCode < 300) {
  //       return jsonDecode(response.body);
  //     } else {
  //       final errorData = jsonDecode(response.body);
  //       return {
  //         'success': false,
  //         'message': errorData['message'] ?? 'Access denied',
  //       };
  //     }
  //   } catch (e) {
  //     return {'success': false, 'message': 'Error verifying access: $e'};
  //   }
  // }

  /// إزالة حماية المجلد
  // Future<Map<String, dynamic>> removeFolderProtection({
  //   required String folderId,
  //   required String password,
  // }) async {
  //   final token = await StorageService.getToken();
  //   if (token == null) {
  //     return {'success': false, 'message': 'Authentication token not found.'};
  //   }

  //   final body = jsonEncode({'password': password});

  //   try {
  //     final response = await http
  //         .delete(
  //           Uri.parse(
  //             "${ApiConfig.baseUrl}${ApiEndpoints.protectFolder(folderId)}",
  //           ),
  //           headers: {
  //             'Authorization': 'Bearer $token',
  //             'Content-Type': 'application/json',
  //           },
  //           body: body,
  //         )
  //         .timeout(ApiConfig.timeout);

  //     if (response.statusCode >= 200 && response.statusCode < 300) {
  //       return jsonDecode(response.body);
  //     } else {
  //       final errorData = jsonDecode(response.body);
  //       return {
  //         'success': false,
  //         'message': errorData['message'] ?? 'Failed to remove protection',
  //       };
  //     }
  //   } catch (e) {
  //     return {'success': false, 'message': 'Error removing protection: $e'};
  //   }
  // }

  // ============================================
  // 🔒 Folder Protection Service Methods
  // ============================================

  /// 🔒 تعيين حماية مجلد (password أو biometric)
  Future<Map<String, dynamic>> protectFolder({
    required String folderId,
    required String protectionType, // "password" | "biometric"
    String? password,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      'protectionType': protectionType,
      if (password != null && password.isNotEmpty) 'password': password,
    });

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.protectFolder(folderId)}"),
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
      throw Exception(
        errorData['message'] ?? 'Failed to protect folder',
      );
    }
  }

  /// 🔓 التحقق من الوصول لمجلد محمي
  Future<Map<String, dynamic>> verifyFolderAccess({
    required String folderId,
    String? password,
    String? biometricToken,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      if (password != null && password.isNotEmpty) 'password': password,
      if (biometricToken != null && biometricToken.isNotEmpty)
        'biometricToken': biometricToken,
    });

    final response = await http.post(
      Uri.parse(
        "${ApiConfig.baseUrl}${ApiEndpoints.verifyFolderAccess(folderId)}",
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('🔐 [FolderService] verifyFolderAccess response: $data');
      return data;
    } else {
      final errorData = jsonDecode(response.body);
      print('❌ [FolderService] verifyFolderAccess error: ${errorData['message']}');
      throw Exception(
        errorData['message'] ?? 'Failed to verify folder access',
      );
    }
  }

  /// 🔓 إزالة حماية مجلد
  Future<Map<String, dynamic>> removeFolderProtection({
    required String folderId,
    String? password, // مطلوب إذا كان نوع الحماية password
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      if (password != null && password.isNotEmpty) 'password': password,
    });

    final response = await http.delete(
      Uri.parse(
        "${ApiConfig.baseUrl}${ApiEndpoints.removeFolderProtection(folderId)}",
      ),
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
      throw Exception(
        errorData['message'] ?? 'Failed to remove folder protection',
      );
    }
  }
}
