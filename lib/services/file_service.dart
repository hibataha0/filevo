import 'dart:convert';
import 'dart:io';
import 'package:filevo/services/api_endpoints.dart' show ApiEndpoints;
import 'package:http/http.dart' as http;
import 'package:filevo/config/api_config.dart';

class FileService {
  final _apiBase = ApiConfig.baseUrl;

  /// رفع ملف واحد
  Future<Map<String, dynamic>> uploadSingleFile({
    required File file,
    required String token,
    String? parentFolderId,
  }) async {
    try {
      var uri = Uri.parse("$_apiBase${ApiEndpoints.uploadSingleFile}");
      var request = http.MultipartRequest("POST", uri);

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      if (parentFolderId != null && parentFolderId.isNotEmpty) {
        request.fields['parentFolderId'] = parentFolderId;
      }

      request.headers['Authorization'] = 'Bearer $token';

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print('backend response--------------------------: $responseBody');
      return jsonDecode(responseBody);

    } catch (e) {
      print("Upload error: $e");
      return {"success": false, "message": "Error uploading file"};
    }
  }

  /// رفع عدة ملفات
  Future<Map<String, dynamic>> uploadMultipleFiles({
    required List<File> files,
    required String token,
    String? parentFolderId,
  }) async {
    try {
      var uri = Uri.parse("$_apiBase${ApiEndpoints.uploadMultipleFiles}");
      var request = http.MultipartRequest("POST", uri);

      for (var file in files) {
        request.files.add(await http.MultipartFile.fromPath('files', file.path));
      }

      if (parentFolderId != null && parentFolderId.isNotEmpty) {
        request.fields['parentFolderId'] = parentFolderId;
      }

      request.headers['Authorization'] = 'Bearer $token';

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print('backend response--------------------------: $responseBody');
      return jsonDecode(responseBody);
    } catch (e) {
      print("Upload multiple error: $e");
      return {"success": false, "message": "Error uploading multiple files"};
    }
  }

  /// ✅ جلب جميع الملفات بدون parentFolder (مع pagination و category filter)
  Future<Map<String, dynamic>> getAllFiles({
    required String token,
    int page = 1,
    int limit = 10,
    String? category,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (category != null && category.isNotEmpty && category != 'all') {
        queryParams['category'] = category;
      }
      
      if (sortBy != null) {
        queryParams['sortBy'] = sortBy;
      }
      
      if (sortOrder != null) {
        queryParams['sortOrder'] = sortOrder;
      }

      final uri = Uri.parse("$_apiBase${ApiEndpoints.files}")
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Get all files response: ${response.statusCode}");
      print("Get all files body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error fetching files: ${response.body}");
        throw Exception('Failed to get files: ${response.body}');
      }
    } catch (e) {
      print("Get all files error: $e");
      rethrow;
    }
  }

  /// جلب الملفات حسب الفئة (category)
  Future<List<dynamic>> getFilesByCategory({
    required String category,
    required String token,
    String? parentFolderId,
  }) async {
    try {
      String url = "$_apiBase${ApiEndpoints.filesByCategory(category)}";
      if (parentFolderId != null) {
        url += "?parentFolderId=$parentFolderId";
      }

      var uri = Uri.parse(url);
      var response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("Get files by category response: ${response.body}");

      if (response.statusCode == 200) {
        print('Fetched files-------------: ${jsonDecode(response.body)['files']}');
        return jsonDecode(response.body)['files'];
      } else {
        print("Error fetching files: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Get files by category error: $e");
      return [];
    }
  }

  /// 📊 جلب إحصائيات التصنيفات (عدد الملفات والحجم لكل تصنيف)
  Future<Map<String, dynamic>?> getCategoriesStats({
    required String token,
  }) async {
    try {
      final url = "$_apiBase${ApiEndpoints.categoriesStats}";
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Categories stats data: $data');
        return data;
      } else {
        // ✅ لا نطبع الخطأ في console - فقط نعيد null بهدوء
        // الـ route غير موجود بعد، سنستخدم القيم الافتراضية
        return null;
      }
    } catch (e) {
      // ✅ لا نطبع الخطأ في console - فقط نعيد null بهدوء
      // الـ route غير موجود بعد، سنستخدم القيم الافتراضية
      return null;
    }
  }

  /// 📊 جلب إحصائيات التصنيفات في الجذر فقط (عدد الملفات والحجم لكل تصنيف)
  Future<Map<String, dynamic>?> getRootCategoriesStats({
    required String token,
  }) async {
    try {
      final url = "$_apiBase${ApiEndpoints.rootCategoriesStats}";
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Root categories stats data: $data');
        
        // ✅ معالجة format الجديد: { "status": "success", "data": ... }
        if (data['status'] == 'success' && data['data'] != null) {
          // ✅ تحويل format إلى نفس format القديم للتوافق مع الكود الحالي
          return {
            'categories': data['data'], // ✅ data يحتوي على قائمة التصنيفات
          };
        }
        print( 'Root categories stats data----------: $data');
        return data;
      } else {
        print('Error fetching root categories stats: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching root categories stats: $e');
      return null;
    }
  }

  /// 🔍 جلب تفاصيل ملف واحد حسب ID
  Future<Map<String, dynamic>?> getFileDetails({
    required String fileId,
    required String token,
  }) async {
    try {
      // استخدام نفس الـ endpoint الموجود في ApiEndpoints
      final url = "$_apiBase${ApiEndpoints.fileById(fileId)}";
      print("Fetching file details from: $url");
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Get file details response status: ${response.statusCode}");
      print("Get file details response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('File details data----------: $data');
        // التأكد من وجود 'file' في الـ response
        if (data['file'] != null) {
          return data; // إرجاع كامل الـ response بما فيه message و file
        } else {
          print("File data is null in response");
          return {"error": "File data not found in response"};
        }
      } else if (response.statusCode == 403) {
        return {"error": "Access denied"};
      } else if (response.statusCode == 404) {
        return {"error": "File not found"};
      } else {
        final data = jsonDecode(response.body);
        return {"error": data['message'] ?? "Error retrieving file details"};
      }
    } catch (e) {
      print("Get file details error: $e");
      return {"error": e.toString()};
    }
  }

  /// 🔍 جلب تفاصيل ملف مشترك في روم
  Future<Map<String, dynamic>?> getSharedFileDetailsInRoom({
    required String fileId,
    required String token,
  }) async {
    try {
      final url = "$_apiBase${ApiEndpoints.getSharedFileDetailsInRoom(fileId)}";
      print("Fetching shared file details in room from: $url");
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Get shared file details in room response status: ${response.statusCode}");
      print("Get shared file details in room response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['file'] != null) {
          return data;
        } else {
          print("No file data in response");
          return null;
        }
      } else if (response.statusCode == 404) {
        print("File not found in room");
        return null;
      } else {
        print("Error getting shared file details in room: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error getting shared file details in room: $e");
      return null;
    }
  }




  /// 🔄 تحديث بيانات ملف
  Future<Map<String, dynamic>> updateFile({
    required String fileId,
    required String token,
    String? name,
    String? description,
    List<String>? tags,
    String? parentFolderId,
  }) async {
    try {
      final url = "$_apiBase${ApiEndpoints.updateFile(fileId)}";
      print("Updating file: $url");
      
      final Map<String, dynamic> body = {};
      
      // إضافة الحقول المطلوبة فقط
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (tags != null) body['tags'] = tags;
      if (parentFolderId != null) body['parentFolderId'] = parentFolderId;

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("Update file response status: ${response.statusCode}");
      print("Update file response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('data massage: ${data['message']}');
        return {
          'success': true,
          'message': data['message'] ?? 'تم تحديث الملف بنجاح',
          
          'file': data['file']
        };
        
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في تحديث الملف'
        };
      }
    } catch (e) {
      print("Update file error: $e");
      return {
        'success': false,
        'message': 'خطأ في تحديث الملف: ${e.toString()}'
      };
    }
  }

  /// 🔄 نقل ملف من مجلد إلى آخر
  Future<Map<String, dynamic>> moveFile({
    required String fileId,
    required String token,
    String? targetFolderId, // null للجذر أو folderId للمجلد
  }) async {
    try {
      final url = "$_apiBase${ApiEndpoints.moveFile(fileId)}";
      print("Moving file: $url");
      
      final Map<String, dynamic> body = {
        'targetFolderId': targetFolderId, // يمكن أن يكون null
      };

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("Move file response status: ${response.statusCode}");
      print("Move file response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'تم نقل الملف بنجاح',
          'file': data['file'],
          'fromFolder': data['fromFolder'],
          'toFolder': data['toFolder'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في نقل الملف',
        };
      }
    } catch (e) {
      print("Move file error: $e");
      return {
        'success': false,
        'message': 'خطأ في نقل الملف: ${e.toString()}',
      };
    }
  }

 Future<Map<String, dynamic>> toggleStarFile({
    required String fileId,
    required String token,
  }) async {
    try {
      final url = "$_apiBase${ApiEndpoints.toggleStarFile(fileId)}";
      print("Toggling star: $url");

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Toggle star response status: ${response.statusCode}");
      print("Toggle star response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('data message: ${data['message']}');
        return {
          'success': true,
          'message': data['message'] ?? 'تم تحديث حالة النجمة بنجاح',
          'file': data['file'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في تحديث حالة النجمة',
        };
      }
    } catch (e) {
      print("Toggle star error: $e");
      return {
        'success': false,
        'message': 'خطأ في تحديث حالة النجمة: ${e.toString()}',
      };
    }
  }

 // الملفات المميزة (Starred)
  Future<Map<String, dynamic>> getStarredFiles({
    required String token,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final url = Uri.parse("$_apiBase${ApiEndpoints.starredFiles}?page=$page&limit=$limit");
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'files': data['files'] ?? [],
          'pagination': data['pagination'] ?? {},
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في جلب الملفات المفضلة',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'خطأ في جلب الملفات المفضلة: ${e.toString()}',
      };
    }
  }

  /// ❌ إلغاء مشاركة الملف مع مستخدمين محددين
  Future<Map<String, dynamic>> unshareFile({
    required String fileId,
    required List<String> userIds,
    required String token,
  }) async {
    final url = "$_apiBase${ApiEndpoints.unshareFile(fileId)}";

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'users': userIds}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to unshare file');
    }
  }



  static Future<Map<String, dynamic>> deleteFile({
    required String fileId,
    required String token,
  }) async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.deleteFile(fileId)}");

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'تم نقل الملف للمحذوفات بنجاح',
          'file': data['file'],
          'deleteExpiryDate': data['deleteExpiryDate'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في حذف الملف',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء حذف الملف: ${e.toString()}',
      };
    }
  }
  

/// جلب ملفات المهملات من الباك
  /// جلب ملفات المهملات
  static Future<Map<String, dynamic>> fetchTrashFiles({
    required String token,
    required int page,
    int limit = 20,
  }) async {
    try {
      final url = "${ApiConfig.baseUrl}${ApiEndpoints.trashFiles}?page=$page&limit=$limit";
      print("Fetching TRASH files from: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Trash files response status: ${response.statusCode}");
      print("Trash files response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'files': data['files'] ?? [],
          'pagination': data['pagination'] ?? {},
          'message': data['message'] ?? 'تم جلب ملفات المهملات بنجاح'
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في جلب ملفات المهملات',
          'files': [],
          'pagination': {}
        };
      }
    } catch (e) {
      print("ERROR in FileService.fetchTrashFiles: $e");
      return {
        'success': false,
        'message': 'خطأ في جلب ملفات المهملات: ${e.toString()}',
        'files': [],
        'pagination': {}
      };
    }
  }

/// استعادة ملف من المهملات
  static Future<Map<String, dynamic>> restoreFiles({
    required List<String> fileIds,
    required String token,
  }) async {
    try {
      final url = "${ApiConfig.baseUrl}${ApiEndpoints.restoreTrashFile(fileIds.join(','))}";
      print("Restoring files: $url");

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fileIds': fileIds,
        }),
      );

      print("Restore files response status: ${response.statusCode}");
      print("Restore files response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'تم استعادة الملفات بنجاح',
          'restoredCount': data['data']?['restoredCount'] ?? fileIds.length,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في استعادة الملفات',
        };
      }
    } catch (e) {
      print("ERROR in FileService.restoreFiles: $e");
      return {
        'success': false,
        'message': 'خطأ في استعادة الملفات: ${e.toString()}',
      };
    }
  }

/// حذف نهائي لملفات
  static Future<Map<String, dynamic>> permanentDelete({
    required List<String> fileIds,
    required String token,
  }) async {
    try {
      final url = "${ApiConfig.baseUrl}${ApiEndpoints.deleteFilePermanent(fileIds.join(','))}";
      print("Permanently deleting files: $url");

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fileIds': fileIds,
        }),
      );

      print("Permanent delete response status: ${response.statusCode}");
      print("Permanent delete response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'تم الحذف النهائي للملفات بنجاح',
          'deletedCount': data['data']?['deletedCount'] ?? fileIds.length,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في الحذف النهائي',
        };
      }
    } catch (e) {
      print("ERROR in FileService.permanentDelete: $e");
      return {
        'success': false,
        'message': 'خطأ في الحذف النهائي: ${e.toString()}',
      };
    }
  }


  
}