import 'dart:convert';
import 'dart:io';
import 'package:filevo/services/api_endpoints.dart' show ApiEndpoints;
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/services/file_search_service.dart';
import 'package:http/http.dart' as http;
import 'package:filevo/config/api_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:filevo/utils/file_security.dart';

class FileService {
  final _apiBase = ApiConfig.baseUrl;
  final _fileSearchService = FileSearchService();

  /// معالجة ملف في الخلفية بعد الرفع
  Future<void> _processFileInBackground(String fileId, String token) async {
    try {
      print('🔄 [FileService] Processing file $fileId in background...');
      final result = await _fileSearchService.processFile(fileId);
      
      if (result['success'] == true) {
        final hasExtractedText = result['hasExtractedText'] ?? false;
        final hasEmbedding = result['hasEmbedding'] ?? false;
        final hasSummary = result['hasSummary'] ?? false;
        final extractedTextLength = result['extractedTextLength'] ?? 0;
        final embeddingDimensions = result['embeddingDimensions'] ?? 0;
        
        print('✅ [FileService] File processed successfully in background');
        print('   - Extracted Text: ${hasExtractedText ? "✅ ($extractedTextLength chars)" : "❌"}');
        print('   - Embedding: ${hasEmbedding ? "✅ ($embeddingDimensions dimensions)" : "❌"}');
        print('   - Summary: ${hasSummary ? "✅" : "❌"}');
        
        if (result['hasEmbeddingError'] == true) {
          print('⚠️ [FileService] Embedding generation had issues: ${result['embeddingError']}');
          print('   Note: Backend tried multiple endpoints automatically');
        }
        
        if (result['textExtractionError'] != null) {
          print('⚠️ [FileService] Text extraction error: ${result['textExtractionError']}');
        }
      } else {
        print('⚠️ [FileService] Background processing failed: ${result['error']}');
        if (result['originalError'] != null) {
          print('   Original error: ${result['originalError']}');
        }
      }
    } catch (e) {
      print('❌ [FileService] Error in background processing: $e');
    }
  }

  /// رفع ملف واحد
  Future<Map<String, dynamic>> uploadSingleFile({
    required File file,
    required String token,
    String? parentFolderId,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      print('═══════════════════════════════════════════════════════');
      print('📤 [FileService] Uploading file: ${file.path}');
      final originalFileName = file.path.split('/').last;
      print('📤 [FileService] File name: $originalFileName');
      print('📤 [FileService] File size: ${await file.length()} bytes');
      print('📤 [FileService] Parent folder ID: ${parentFolderId ?? "null"}');

      // 🔐 Security: Check and convert dangerous files
      File fileToUpload = file;
      String fileNameToUpload = originalFileName;
      
      if (isDangerousExtension(originalFileName)) {
        print('🔐 [FileService] Dangerous file detected: $originalFileName');
        print('🔐 [FileService] Converting to safe text file...');
        fileToUpload = await convertDangerousFileToText(
          originalFile: file,
          originalFileName: originalFileName,
        );
        fileNameToUpload = convertToSafeTextFile(originalFileName);
        print('🔐 [FileService] Converted to: $fileNameToUpload');
      }

      final uri = "$_apiBase${ApiEndpoints.uploadSingleFile}";

      final dio = Dio()
        ..options.headers['Authorization'] = 'Bearer $token';

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(fileToUpload.path,
            filename: fileToUpload.path.split('/').last),
        if (parentFolderId != null && parentFolderId.isNotEmpty)
          'parentFolderId': parentFolderId,
      });

      print('📤 [FileService] Sending request to: $uri');
      final response = await dio.post(
        uri,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          // ✅ لا ترمِ استثناء عند 4xx/5xx، خليه يرجع response عادي ونتعامل معه يدوياً
          validateStatus: (status) => true,
        ),
      );

      final responseBody = response.data is String
          ? response.data
          : jsonEncode(response.data);

      print('📥 [FileService] Response status: ${response.statusCode}');
      print('📥 [FileService] Response body: $responseBody');

      final statusCode = response.statusCode ?? 0;

      // ✅ التحقق من خطأ المساحة التخزينية أولاً
      if (statusCode == 403) {
        Map<String, dynamic> errorData = {};
        try {
          errorData = jsonDecode(responseBody);
        } catch (_) {
          errorData = {};
        }
        
        final message = errorData['message']?.toString() ?? '';
        if (message.toLowerCase().contains('storage') || 
            message.toLowerCase().contains('limit')) {
          final storageMessage = message.isNotEmpty 
              ? message
              : 'تم الوصول للحد الأقصى من المساحة التخزينية (10 GB). يرجى حذف بعض الملفات أو شراء مساحة إضافية';
          print('❌ [FileService] Storage limit exceeded: $storageMessage');
          print('═══════════════════════════════════════════════════════');
          return {
            "success": false,
            "message": storageMessage,
            "error": errorData,
            "storageLimitExceeded": true,
            "statusCode": 403,
          };
        }
      }

      if (statusCode >= 200 && statusCode < 300) {
        final data = jsonDecode(responseBody);
        final fileData = data['file'];

        // ✅ التحقق من حالة المعالجة
        if (fileData != null) {
          final fileId = fileData['_id']?.toString();
          final embedding = fileData['embedding'];
          final isProcessed = fileData['isProcessed'] ?? false;

          print('✅ [FileService] File uploaded successfully');
          print('   - File ID: $fileId');
          print('   - File name: ${fileData['name']}');
          print('   - Is Processed: $isProcessed');
          print(
            '   - Embedding: ${embedding != null ? "✅ Generated" : "❌ Null"}',
          );

          // ✅ معالجة تلقائية للملف إذا لم يكن معالجاً
          if (!isProcessed && fileId != null) {
            print('🔄 [FileService] File not processed yet. Starting automatic processing...');
            
            // ✅ معالجة الملف في الخلفية (لا ننتظر النتيجة)
            _processFileInBackground(fileId, token).catchError((error) {
              print('⚠️ [FileService] Background processing failed: $error');
              // ✅ لا نعرض خطأ للمستخدم لأن الرفع نجح
            });
          } else if (embedding == null && !isProcessed) {
            print('⚠️ [FileService] Embedding is null and file not processed');
            final embeddingError = fileData['embeddingError'];
            if (embeddingError != null) {
              print('   - Error: $embeddingError');
            } else {
              print('   - File will be processed automatically in background');
            }
          }
        }

        print('═══════════════════════════════════════════════════════');
        return data;
      } else {
        Map<String, dynamic> errorData = {};
        try {
          errorData = jsonDecode(responseBody);
        } catch (_) {
          errorData = {};
        }

        // ✅ التحقق من خطأ المساحة التخزينية (403)
        final statusCode = response.statusCode ?? 0;
        final isStorageError = statusCode == 403 && 
            (errorData['message']?.toString().toLowerCase() ?? '').contains('storage');

        if (isStorageError) {
          final storageMessage = errorData['message'] ?? 
              'تم الوصول للحد الأقصى من المساحة التخزينية. يرجى حذف بعض الملفات أو شراء مساحة إضافية';
          print('❌ [FileService] Storage limit exceeded: $storageMessage');
          print('═══════════════════════════════════════════════════════');
          return {
            "success": false,
            "message": storageMessage,
            "error": errorData,
            "storageLimitExceeded": true,
            "statusCode": statusCode,
          };
        }

        final viruses = (errorData['viruses'] as List?)?.cast<String>() ?? [];
        final virusDetected = viruses.isNotEmpty ||
            (errorData['message']?.toString().toLowerCase() ?? '')
                .contains('virus');
        final message = virusDetected && viruses.isNotEmpty
            ? 'تم اكتشاف فيروس في الملف: ${viruses.join(", ")}'
            : errorData['message'] ?? "Error uploading file";

        print('❌ [FileService] Upload failed: $message');
        print('═══════════════════════════════════════════════════════');
        return {
          "success": false,
          "message": message,
          "error": errorData,
          "virusDetected": virusDetected,
          "viruses": viruses,
          "statusCode": statusCode,
        };
      }
    } catch (e) {
      print("❌ [FileService] Upload error: $e");
      print('═══════════════════════════════════════════════════════');
      return {
        "success": false,
        "message": "Error uploading file: ${e.toString()}",
      };
    }
  }

  /// رفع عدة ملفات
  Future<Map<String, dynamic>> uploadMultipleFiles({
    required List<File> files,
    required String token,
    String? parentFolderId,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      print('═══════════════════════════════════════════════════════');
      print('📤 [FileService] Uploading ${files.length} files');
      print('📤 [FileService] Parent folder ID: ${parentFolderId ?? "null"}');

      // 🔐 Security: Process dangerous files
      List<File> filesToUpload = [];
      
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final originalFileName = file.path.split('/').last;
        final fileSize = await file.length();
        
        File processedFile = file;
        
        if (isDangerousExtension(originalFileName)) {
          print('🔐 [FileService] Dangerous file detected: $originalFileName');
          print('🔐 [FileService] Converting to safe text file...');
          processedFile = await convertDangerousFileToText(
            originalFile: file,
            originalFileName: originalFileName,
          );
          final safeFileName = convertToSafeTextFile(originalFileName);
          print('   ${i + 1}. $originalFileName -> $safeFileName (${await processedFile.length()} bytes)');
        } else {
          print('   ${i + 1}. $originalFileName (${fileSize} bytes)');
        }
        
        filesToUpload.add(processedFile);
      }

      final uri = "$_apiBase${ApiEndpoints.uploadMultipleFiles}";
      final dio = Dio()
        ..options.headers['Authorization'] = 'Bearer $token';

      final formData = FormData();

      for (var file in filesToUpload) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }

      if (parentFolderId != null && parentFolderId.isNotEmpty) {
        formData.fields.add(MapEntry('parentFolderId', parentFolderId));
      }

      print('📤 [FileService] Sending request to: $uri');
      final response = await dio.post(
        uri,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          // ✅ لا ترمِ استثناء عند 4xx/5xx، خليه يرجع response عادي ونتعامل معه يدوياً
          validateStatus: (status) => true,
        ),
      );

      final responseBody = response.data is String
          ? response.data
          : jsonEncode(response.data);

      print('📥 [FileService] Response status: ${response.statusCode}');
      print('📥 [FileService] Response body: $responseBody');

      // ✅ التحقق من status code
      final statusCode = response.statusCode ?? 0;

      // ✅ التحقق من خطأ المساحة التخزينية أولاً
      if (statusCode == 403) {
        Map<String, dynamic> errorData = {};
        try {
          errorData = jsonDecode(responseBody);
        } catch (_) {
          errorData = {};
        }
        
        final message = errorData['message']?.toString() ?? '';
        if (message.toLowerCase().contains('storage') || 
            message.toLowerCase().contains('limit')) {
          final storageMessage = message.isNotEmpty 
              ? message
              : 'تم الوصول للحد الأقصى من المساحة التخزينية (10 GB). يرجى حذف بعض الملفات أو شراء مساحة إضافية';
          print('❌ [FileService] Storage limit exceeded: $storageMessage');
          print('═══════════════════════════════════════════════════════');
          return {
            "success": false,
            "message": storageMessage,
            "error": errorData,
            "storageLimitExceeded": true,
            "statusCode": 403,
            "files": [],
            "errors": [],
          };
        }
      }

      if (statusCode >= 200 && statusCode < 300) {
        final data = jsonDecode(responseBody);
        final uploadedFiles = data['files'] as List? ?? [];
        final errors = (data['errors'] as List?) ?? [];

        print('✅ [FileService] Files uploaded successfully');
        print('   - Uploaded files count: ${uploadedFiles.length}');
        if (errors.isNotEmpty) {
          print('   - Errors count: ${errors.length}');
        }

        // ✅ التحقق من حالة المعالجة لكل ملف ومعالجة تلقائية
        int processedCount = 0;
        int failedCount = 0;

        for (var fileData in uploadedFiles) {
          final fileId = fileData['_id']?.toString();
          final embedding = fileData['embedding'];
          final isProcessed = fileData['isProcessed'] ?? false;
          final embeddingError = fileData['embeddingError'];

          if (embedding != null || isProcessed) {
            processedCount++;
          } else {
            failedCount++;
            print('   ⚠️ File "${fileData['name']}" - Embedding: ❌ Null, IsProcessed: $isProcessed');
            
            // ✅ معالجة تلقائية للملف إذا لم يكن معالجاً
            if (!isProcessed && fileId != null) {
              print('   🔄 Starting automatic processing for file $fileId...');
              _processFileInBackground(fileId, token).catchError((error) {
                print('   ⚠️ Background processing failed: $error');
              });
            }
            
            if (embeddingError != null) {
              print('      Previous Error: $embeddingError');
            }
          }
        }

        print('   - Processed (with embedding): $processedCount');
        print('   - Failed (no embedding): $failedCount');
        print('═══════════════════════════════════════════════════════');

        data['uploadedCount'] = uploadedFiles.length;
        data['errorsCount'] = errors.length;

        return data;
      } else {
        Map<String, dynamic> errorData = {};
        try {
          errorData = jsonDecode(responseBody);
        } catch (_) {
          errorData = {};
        }

        // ✅ التحقق من خطأ المساحة التخزينية (403)
        final statusCode = response.statusCode ?? 0;
        final isStorageError = statusCode == 403 && 
            (errorData['message']?.toString().toLowerCase() ?? '').contains('storage');

        if (isStorageError) {
          final storageMessage = errorData['message'] ?? 
              'تم الوصول للحد الأقصى من المساحة التخزينية. يرجى حذف بعض الملفات أو شراء مساحة إضافية';
          print('❌ [FileService] Storage limit exceeded: $storageMessage');
          print('═══════════════════════════════════════════════════════');
          return {
            "success": false,
            "message": storageMessage,
            "error": errorData,
            "storageLimitExceeded": true,
            "statusCode": statusCode,
            "errors": [],
            "files": [],
          };
        }

        final errors = (errorData['errors'] as List?) ?? [];
        final viruses = (errorData['viruses'] as List?) ?? [];
        final virusDetected = viruses.isNotEmpty ||
            errors.any((e) =>
                e.toString().toLowerCase().contains('virus'));

        final message = errorData['message'] ??
            (virusDetected
                ? 'تم رفض الرفع بسبب اكتشاف فيروس'
                : "Error uploading multiple files");

        print('❌ [FileService] Upload failed: $message');
        print('═══════════════════════════════════════════════════════');
        return {
          "success": false,
          "message": message,
          "error": errorData,
          "errors": errors,
          "virusDetected": virusDetected,
          "viruses": viruses,
          "statusCode": statusCode,
        };
      }
    } catch (e) {
      print("❌ [FileService] Upload multiple error: $e");
      print('═══════════════════════════════════════════════════════');
      return {
        "success": false,
        "message": "Error uploading multiple files: ${e.toString()}",
      };
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

      final uri = Uri.parse(
        "$_apiBase${ApiEndpoints.files}",
      ).replace(queryParameters: queryParams);

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

  /// ✅ جلب الملفات الحديثة
  Future<Map<String, dynamic>> getRecentFiles({int limit = 10}) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'لا يوجد token. يرجى تسجيل الدخول'};
      }

      final uri = Uri.parse(
        "$_apiBase${ApiEndpoints.recentFiles}",
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
        return {
          'success': true,
          'files': data['files'] ?? [],
          'count': data['count'] ?? 0,
        };
      } else {
        // ✅ معالجة آمنة للأخطاء - قد يكون response نصاً وليس JSON
        try {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'error': data['message'] ?? 'فشل في جلب الملفات الحديثة',
          };
        } catch (e) {
          // ✅ إذا كان response نصاً عادياً وليس JSON
          return {
            'success': false,
            'error': response.body.isNotEmpty 
                ? response.body 
                : 'فشل في جلب الملفات الحديثة',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في جلب الملفات الحديثة: ${e.toString()}',
      };
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
        print(
          'Fetched files-------------: ${jsonDecode(response.body)['files']}',
        );
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
    // ✅ التحقق من وجود token قبل إرسال الطلب
    if (token.isEmpty) {
      print('⚠️ [FileService] getCategoriesStats: Token is empty');
      return null;
    }
    
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
      } else if (response.statusCode == 401) {
        print('⚠️ [FileService] getCategoriesStats: 401 Unauthorized - Token may be invalid or expired');
        return null;
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
        print('Root categories stats data----------: $data');
        return data;
      } else {
        print(
          'Error fetching root categories stats: ${response.statusCode} - ${response.body}',
        );
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

      print(
        "Get shared file details in room response status: ${response.statusCode}",
      );
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

      // ✅ معالجة خطأ 429 (Too Many Requests)
      if (response.statusCode == 429) {
        return {
          'success': false,
          'message': 'Too many requests from this IP, please try again later.',
        };
      }

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('data massage: ${data['message']}');
          return {
            'success': true,
            'message': data['message'] ?? 'تم تحديث الملف بنجاح',
            'file': data['file'],
          };
        } catch (e) {
          // ✅ إذا كان response body ليس JSON صالح
          print('❌ [FileService] Error parsing JSON response: $e');
          return {
            'success': false,
            'message': 'خطأ في قراءة استجابة السيرفر: ${response.body}',
          };
        }
      } else {
        try {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message'] ?? 'فشل في تحديث الملف',
          };
        } catch (e) {
          // ✅ إذا كان response body ليس JSON صالح
          print('❌ [FileService] Error parsing JSON error response: $e');
          return {
            'success': false,
            'message': response.body.isNotEmpty 
                ? response.body 
                : 'فشل في تحديث الملف (${response.statusCode})',
          };
        }
      }
    } catch (e) {
      print("Update file error: $e");
      return {
        'success': false,
        'message': 'خطأ في تحديث الملف: ${e.toString()}',
      };
    }
  }

  /// ✅ تحديث محتوى الملف (استبدال الملف القديم بملف جديد)
  /// @param fileId: معرف الملف المراد تحديثه
  /// @param file: الملف الجديد
  /// @param token: رمز الوصول
  /// @param replaceMode: true للاستبدال بنفس الاسم والمسار، false لإنشاء نسخة جديدة (اختياري، للملفات النصية يكون true تلقائياً)
  Future<Map<String, dynamic>> updateFileContent({
    required String fileId,
    required File file,
    required String token,
    bool? replaceMode,
  }) async {
    try {
      print('═══════════════════════════════════════════════════════');
      print('📝 [FileService] Updating file content: $fileId');
      print('📝 [FileService] File path: ${file.path}');
      final originalFileName = file.path.split('/').last;
      print('📝 [FileService] File name: $originalFileName');
      print('📝 [FileService] File size: ${await file.length()} bytes');
      print('📝 [FileService] Replace mode: ${replaceMode ?? "auto"}');

      // 🔐 Security: Check and convert dangerous files
      File fileToUpload = file;
      
      if (isDangerousExtension(originalFileName)) {
        print('🔐 [FileService] Dangerous file detected: $originalFileName');
        print('🔐 [FileService] Converting to safe text file...');
        fileToUpload = await convertDangerousFileToText(
          originalFile: file,
          originalFileName: originalFileName,
        );
        print('🔐 [FileService] Converted to safe text file');
      }

      final url = "$_apiBase${ApiEndpoints.updateFileContent(fileId)}";
      final request = http.MultipartRequest("PUT", Uri.parse(url));

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Connection'] = 'keep-alive';

      // ✅ إضافة الملف (الآمن)
      request.files.add(await http.MultipartFile.fromPath('file', fileToUpload.path));

      // ✅ إضافة replaceMode إذا كان محدداً (للملفات غير النصية)
      if (replaceMode != null) {
        request.fields['replaceMode'] = replaceMode.toString();
      }

      print('📤 [FileService] Sending request to: $url');
      final response = await request.send().timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          throw Exception('انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.');
        },
      );

      final responseBody = await response.stream.bytesToString();

      print('📥 [FileService] Response status: ${response.statusCode}');
      print('📥 [FileService] Response body: $responseBody');

      // ✅ معالجة خطأ 429 (Too Many Requests)
      if (response.statusCode == 429) {
        print('❌ [FileService] Too many requests (429)');
        print('═══════════════════════════════════════════════════════');
        return {
          'success': false,
          'message': 'Too many requests from this IP, please try again later.',
        };
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = jsonDecode(responseBody);
          // ✅ إذا كان success موجوداً و false، أو غير موجود ولكن status code 200، نعتبره نجاح
          // ✅ إذا كان success موجوداً و true، نعتبره نجاح
          final isSuccess = data['success'] != false; // true إذا success غير موجود أو true
          
          if (isSuccess) {
            print('✅ [FileService] File content updated successfully');
            print('   - File name: ${data['file']?['name'] ?? 'N/A'}');
            print('   - Replace mode: ${data['replaceMode'] ?? 'N/A'}');
            print('═══════════════════════════════════════════════════════');
            return {
              'success': true,
              'message': data['message'] ?? 'تم تحديث محتوى الملف بنجاح',
              'file': data['file'],
              'replaceMode': data['replaceMode'],
            };
          } else {
            print('❌ [FileService] Update failed: ${data['message']}');
            print('═══════════════════════════════════════════════════════');
            return {
              'success': false,
              'message': data['message'] ?? 'فشل في تحديث محتوى الملف',
            };
          }
        } catch (e) {
          // ✅ إذا كان response body ليس JSON صالح
          print('❌ [FileService] Error parsing JSON response: $e');
          print('   Response body: $responseBody');
          print('═══════════════════════════════════════════════════════');
          return {
            'success': false,
            'message': 'خطأ في قراءة استجابة السيرفر: ${responseBody.isNotEmpty ? responseBody : "استجابة فارغة"}',
          };
        }
      } else {
        try {
          final data = jsonDecode(responseBody);
          print('❌ [FileService] Update failed: ${data['message'] ?? 'Unknown error'}');
          print('═══════════════════════════════════════════════════════');
          return {
            'success': false,
            'message': data['message'] ?? 'فشل في تحديث محتوى الملف',
          };
        } catch (e) {
          // ✅ إذا كان response body ليس JSON صالح
          print('❌ [FileService] Error parsing JSON error response: $e');
          print('   Response body: $responseBody');
          print('═══════════════════════════════════════════════════════');
          return {
            'success': false,
            'message': responseBody.isNotEmpty 
                ? responseBody 
                : 'فشل في تحديث محتوى الملف (${response.statusCode})',
          };
        }
      }
    } catch (e) {
      print('❌ [FileService] Update file content error: $e');
      print('═══════════════════════════════════════════════════════');
      return {
        'success': false,
        'message': 'خطأ في تحديث محتوى الملف: ${e.toString()}',
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
      return {'success': false, 'message': 'خطأ في نقل الملف: ${e.toString()}'};
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
    // ✅ التحقق من وجود token قبل إرسال الطلب
    if (token.isEmpty) {
      return {
        'success': false,
        'message': 'لا يوجد token. يرجى تسجيل الدخول',
      };
    }
    
    try {
      final url = Uri.parse(
        "$_apiBase${ApiEndpoints.starredFiles}?page=$page&limit=$limit",
      );
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
      } else if (response.statusCode == 401) {
        print('⚠️ [FileService] getStarredFiles: 401 Unauthorized - Token may be invalid or expired');
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'انتهت صلاحية جلسة العمل. يرجى تسجيل الدخول مرة أخرى',
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
      final url = Uri.parse(
        "${ApiConfig.baseUrl}${ApiEndpoints.deleteFile(fileId)}",
      );

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
          'warning': data['warning'], // ✅ تحذير إذا كان الملف مشاركاً في Rooms
          'roomsRemovedFrom': data['roomsRemovedFrom'] ?? [], // ✅ قائمة الـ Rooms المتأثرة
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
      final url =
          "${ApiConfig.baseUrl}${ApiEndpoints.trashFiles}?page=$page&limit=$limit";
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
          'message': data['message'] ?? 'تم جلب ملفات المهملات بنجاح',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في جلب ملفات المهملات',
          'files': [],
          'pagination': {},
        };
      }
    } catch (e) {
      print("ERROR in FileService.fetchTrashFiles: $e");
      return {
        'success': false,
        'message': 'خطأ في جلب ملفات المهملات: ${e.toString()}',
        'files': [],
        'pagination': {},
      };
    }
  }

  /// استعادة ملف من المهملات
  static Future<Map<String, dynamic>> restoreFiles({
    required List<String> fileIds,
    required String token,
  }) async {
    try {
      final url =
          "${ApiConfig.baseUrl}${ApiEndpoints.restoreTrashFile(fileIds.join(','))}";
      print("Restoring files: $url");

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'fileIds': fileIds}),
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
      final url =
          "${ApiConfig.baseUrl}${ApiEndpoints.deleteFilePermanent(fileIds.join(','))}";
      print("Permanently deleting files: $url");

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'fileIds': fileIds}),
      );

      print("Permanent delete response status: ${response.statusCode}");
      print("Permanent delete response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'تم الحذف النهائي للملفات بنجاح',
          'deletedCount': data['data']?['deletedCount'] ?? fileIds.length,
          'warning': data['warning'], // ✅ تحذير إذا كان الملف مشاركاً في Rooms
          'roomsRemovedFrom': data['roomsRemovedFrom'] ?? [], // ✅ قائمة الـ Rooms المتأثرة
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

  /// ✅ عرض ملف خاص بالمستخدم (للعرض في المتصفح)
  /// Returns: Map with 'success', 'url', and 'fileName' or 'error'
  /// Note: This endpoint returns the file directly for viewing, not JSON
  Future<Map<String, dynamic>> viewFile({
    required String fileId,
    required String token,
  }) async {
    try {
      if (token.isEmpty) {
        return {
          'success': false,
          'error': 'لا يمكن تحديد هوية المستخدم. يرجى إعادة تسجيل الدخول.',
        };
      }

      // ✅ استخدام endpoint لعرض الملف
      final url = "$_apiBase${ApiEndpoints.viewFile(fileId)}";
      print("🌐 [viewFile] GET $url");

      // ✅ إرجاع URL للاستخدام في المتصفح
      return {
        'success': true,
        'url': url,
        'token': token,
      };
    } catch (e) {
      print("❌ [viewFile] Error: $e");
      return {
        'success': false,
        'error': 'خطأ في عرض الملف: ${e.toString()}',
      };
    }
  }

  /// ✅ تحميل ملف خاص بالمستخدم
  /// Returns: Map with 'success' and 'filePath' or 'error'
  Future<Map<String, dynamic>> downloadFile({
    required String fileId,
    required String token,
    String? fileName,
  }) async {
    try {
      // ✅ طلب صلاحية الكتابة للتخزين
      if (Platform.isAndroid) {
        // ✅ للـ Android 13+ (API 33+)
        bool hasPermission = false;
        if (await Permission.photos.isGranted ||
            await Permission.videos.isGranted ||
            await Permission.audio.isGranted) {
          hasPermission = true;
        }
        // ✅ للـ Android 11-12 (API 30-32) - SAF يغطيها
        // ✅ للـ Android 10 وأقل (API 29-)
        else if (await Permission.storage.isGranted) {
          hasPermission = true;
        }

        // ✅ إذا لم تكن الصلاحية موجودة، اطلبها
        if (!hasPermission) {
          // ✅ محاولة طلب صلاحيات Media أولاً (Android 13+)
          if (await Permission.photos.request().isGranted ||
              await Permission.videos.request().isGranted ||
              await Permission.audio.request().isGranted) {
            hasPermission = true;
          }
          // ✅ إذا فشل، جرب storage (Android 10-)
          else {
            final status = await Permission.storage.request();
            if (!status.isGranted) {
              return {
                'success': false,
                'error':
                    'تم رفض صلاحية التخزين. يرجى منح الصلاحية من الإعدادات',
              };
            }
            hasPermission = true;
          }
        }
      } else if (Platform.isIOS) {
        // ✅ iOS - استخدام Photos permission
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          return {
            'success': false,
            'error': 'تم رفض صلاحية التخزين. يرجى منح الصلاحية من الإعدادات',
          };
        }
      }

      final url = "$_apiBase${ApiEndpoints.downloadFile(fileId)}";
      print("Downloading file from: $url");

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      // ✅ الحصول على مجلد التحميلات العام
      Directory? downloadDir;
      String? downloadPath;

      if (Platform.isAndroid) {
        // ✅ Android: استخدام مجلد التحميلات العام
        try {
          // ✅ محاولة استخدام getDownloadsDirectory أولاً
          downloadDir = await getDownloadsDirectory();
          if (downloadDir != null && await downloadDir.exists()) {
            downloadPath = downloadDir.path;
            print('✅ Using getDownloadsDirectory: $downloadPath');
          } else {
            // ✅ Fallback: بناء المسار يدوياً لمجلد التحميلات العام
            final externalStorage = await getExternalStorageDirectory();
            if (externalStorage != null) {
              // ✅ الحصول على المسار الأساسي (بدون مجلد التطبيق)
              // مثال: /storage/emulated/0/Android/data/com.example.filevo/files
              // إلى: /storage/emulated/0
              String basePath = externalStorage.path;
              if (basePath.contains('/Android/')) {
                basePath = basePath.split('/Android/')[0];
              }
              // ✅ استخدام Download (بدون s) لأن Android يستخدم Download
              downloadPath = '$basePath/Download';
              downloadDir = Directory(downloadPath);
              print('✅ Using manual path: $downloadPath');
            }
          }
        } catch (e) {
          print('❌ Error getting downloads directory: $e');
          // ✅ Fallback: استخدام مجلد التطبيق
          final directory = await getExternalStorageDirectory();
          if (directory != null) {
            downloadPath = '${directory.path}/Downloads';
            downloadDir = Directory(downloadPath);
            print('✅ Using fallback path: $downloadPath');
          }
        }
      } else if (Platform.isIOS) {
        // ✅ iOS: استخدام مجلد المستندات
        downloadDir = await getApplicationDocumentsDirectory();
        downloadPath = downloadDir.path;
      } else {
        // ✅ Desktop/Web: استخدام مجلد التحميلات
        downloadDir = await getDownloadsDirectory();
        if (downloadDir != null) {
          downloadPath = downloadDir.path;
        } else {
          final directory = await getApplicationDocumentsDirectory();
          downloadPath = directory.path;
          downloadDir = directory;
        }
      }

      if (downloadDir == null || downloadPath == null) {
        return {'success': false, 'error': 'فشل في الحصول على مجلد التحميلات'};
      }

      // ✅ إنشاء المجلد إذا لم يكن موجوداً
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
        print('✅ Created download directory: $downloadPath');
      }

      print('✅ Download path: $downloadPath');

      // ✅ التأكد من أن اسم الملف يحتوي على امتداد صحيح
      String finalFileName = fileName ?? 'file_$fileId';
      
      // ✅ دالة للتحقق من وجود امتداد صحيح
      bool hasValidExtension(String name) {
        if (!name.contains('.')) return false;
        final parts = name.split('.');
        if (parts.length < 2) return false;
        final extension = parts.last.toLowerCase();
        // ✅ قائمة بالامتدادات المعروفة
        const validExtensions = [
          'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg',
          'mp4', 'mov', 'avi', 'mkv', 'wmv', 'webm', 'm4v', '3gp', 'flv',
          'mp3', 'wav', 'aac', 'ogg', 'm4a', 'wma', 'flac',
          'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
          'zip', 'rar', '7z', 'tar', 'gz',
          'txt', 'json', 'xml', 'csv',
        ];
        return validExtensions.contains(extension) && extension.length >= 2;
      }
      
      // ✅ إذا لم يكن الاسم يحتوي على امتداد صحيح، نحاول استخراجه من content-type
      if (!hasValidExtension(finalFileName)) {
        try {
          print('⚠️ File name "$finalFileName" does not have valid extension, trying to get from content-type...');
          // ✅ عمل HEAD request للحصول على content-type
          final headResponse = await dio.head(url);
          final contentType = headResponse.headers.value('content-type')?.toLowerCase() ?? '';
          print('📄 Content-Type: $contentType');
          
          String? extension;
          if (contentType.contains('image')) {
            if (contentType.contains('jpeg')) extension = 'jpg';
            else if (contentType.contains('png')) extension = 'png';
            else if (contentType.contains('gif')) extension = 'gif';
            else if (contentType.contains('webp')) extension = 'webp';
            else if (contentType.contains('bmp')) extension = 'bmp';
            else if (contentType.contains('svg')) extension = 'svg';
            else extension = 'jpg'; // افتراضي للصور
          } else if (contentType.contains('video')) {
            if (contentType.contains('mp4')) extension = 'mp4';
            else if (contentType.contains('quicktime')) extension = 'mov';
            else if (contentType.contains('avi')) extension = 'avi';
            else if (contentType.contains('webm')) extension = 'webm';
            else if (contentType.contains('x-matroska')) extension = 'mkv';
            else extension = 'mp4'; // افتراضي للفيديو
          } else if (contentType.contains('audio')) {
            if (contentType.contains('mpeg')) extension = 'mp3';
            else if (contentType.contains('wav')) extension = 'wav';
            else if (contentType.contains('aac')) extension = 'aac';
            else if (contentType.contains('ogg')) extension = 'ogg';
            else if (contentType.contains('x-m4a')) extension = 'm4a';
            else extension = 'mp3'; // افتراضي للصوت
          } else if (contentType.contains('pdf')) {
            extension = 'pdf';
          } else if (contentType.contains('zip')) {
            extension = 'zip';
          } else if (contentType.contains('json')) {
            extension = 'json';
          } else if (contentType.contains('text')) {
            extension = 'txt';
          } else if (contentType.contains('application/octet-stream')) {
            // ✅ إذا كان content-type هو octet-stream، نحاول تخمينه من الاسم الأصلي
            if (fileName != null && fileName.contains('.')) {
              final parts = fileName.split('.');
              if (parts.length > 1) {
                final lastPart = parts.last.toLowerCase();
                if (lastPart.length >= 2 && lastPart.length <= 5) {
                  extension = lastPart;
                  print('✅ Guessed extension from original filename: $extension');
                }
              }
            }
            // ✅ إذا لم نستطع التخمين، نستخدم 'bin' كامتداد افتراضي
            if (extension == null) {
              extension = 'bin';
            }
          }
          
          if (extension != null) {
            // ✅ إزالة أي امتداد موجود مسبقاً وإضافة الامتداد الصحيح
            if (finalFileName.contains('.')) {
              final nameWithoutExt = finalFileName.substring(0, finalFileName.lastIndexOf('.'));
              finalFileName = '$nameWithoutExt.$extension';
            } else {
              finalFileName = '$finalFileName.$extension';
            }
            print('✅ Added extension from content-type: $extension -> Final name: $finalFileName');
          } else {
            print('⚠️ Could not determine extension from content-type: $contentType');
          }
        } catch (e) {
          print('⚠️ Could not get content-type, using filename as is: $e');
          // ✅ محاولة أخيرة: إذا كان الاسم يحتوي على نقطة لكن الامتداد غير صحيح، نضيف 'bin'
          if (finalFileName.contains('.') && !hasValidExtension(finalFileName)) {
            final nameWithoutExt = finalFileName.substring(0, finalFileName.lastIndexOf('.'));
            finalFileName = '$nameWithoutExt.bin';
            print('⚠️ Added .bin extension as fallback');
          }
        }
      } else {
        print('✅ File name already has valid extension: $finalFileName');
      }
      
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

      // ✅ إضافة الملف إلى MediaStore للظهور في التحميلات (Android فقط)
      if (Platform.isAndroid) {
        bool addedToMediaStore = false;
        try {
          const platform = MethodChannel('com.example.filevo/download');
          final result = await platform.invokeMethod('addToDownloads', {
            'filePath': filePath,
            'fileName': finalFileName,
          });
          final success = result as bool? ?? false;
          if (success) {
            print('✅ File added to MediaStore successfully');
            addedToMediaStore = true;
          } else {
            print(
              '⚠️ Failed to add file to MediaStore, but file is saved at: $filePath',
            );
          }
        } on MissingPluginException catch (e) {
          print('⚠️ MethodChannel not registered. Trying fallback method: $e');
          // ✅ Fallback: نسخ الملف مباشرة إلى مجلد التحميلات العام
          addedToMediaStore = await _copyToDownloadsFallback(
            filePath,
            finalFileName,
          );
        } catch (e) {
          print('⚠️ Error adding file to MediaStore: $e');
          // ✅ Fallback: نسخ الملف مباشرة إلى مجلد التحميلات العام
          addedToMediaStore = await _copyToDownloadsFallback(
            filePath,
            finalFileName,
          );
        }

        if (!addedToMediaStore) {
          print('ℹ️ File is saved at: $filePath');
          print('ℹ️ Please rebuild the app to enable MediaStore integration');
        }
      }

      return {'success': true, 'filePath': filePath, 'fileName': finalFileName};
    } on DioException catch (e) {
      print("Download error: ${e.response?.statusCode} - ${e.message}");
      if (e.response?.statusCode == 403) {
        return {'success': false, 'error': 'ليس لديك صلاحية لتحميل هذا الملف'};
      } else if (e.response?.statusCode == 404) {
        return {'success': false, 'error': 'الملف غير موجود'};
      }
      return {
        'success': false,
        'error': e.response?.data?['message'] ?? 'فشل تحميل الملف',
      };
    } catch (e) {
      print("Download error: $e");
      return {'success': false, 'error': 'خطأ في تحميل الملف: ${e.toString()}'};
    }
  }

  /// ✅ Fallback: نسخ الملف مباشرة إلى مجلد التحميلات العام
  Future<bool> _copyToDownloadsFallback(
    String sourcePath,
    String fileName,
  ) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        return false;
      }

      // ✅ الحصول على مجلد التحميلات العام
      Directory? downloadsDir;
      try {
        downloadsDir = await getDownloadsDirectory();
        if (downloadsDir == null || !await downloadsDir.exists()) {
          final externalStorage = await getExternalStorageDirectory();
          if (externalStorage != null) {
            String basePath = externalStorage.path;
            if (basePath.contains('/Android/')) {
              basePath = basePath.split('/Android/')[0];
            }
            downloadsDir = Directory('$basePath/Download');
          }
        }
      } catch (e) {
        print('Error getting downloads directory: $e');
        return false;
      }

      if (downloadsDir == null) {
        return false;
      }

      // ✅ إنشاء المجلد إذا لم يكن موجوداً
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // ✅ نسخ الملف
      final targetFile = File('${downloadsDir.path}/$fileName');
      await sourceFile.copy(targetFile.path);

      print('✅ File copied to downloads folder: ${targetFile.path}');
      return true;
    } catch (e) {
      print('❌ Error in fallback copy: $e');
      return false;
    }
  }

  /// ✅ جلب معلومات المساحة التخزينية
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'error': 'لا يوجد token. يرجى تسجيل الدخول',
        };
      }

      final uri = Uri.parse("$_apiBase${ApiEndpoints.storageInfo}");

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📊 [FileService] Get storage info response: ${response.statusCode}');
      print('📊 [FileService] Get storage info response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          // ✅ دعم كلا التنسيقين: data أو storage
          final storageData = data['data'] ?? data['storage'] ?? {};
          
          print('✅ [FileService] Storage data retrieved: $storageData');
          
          return {
            'success': true,
            'storage': {
              'limit': storageData['limit'] ?? 0,
              'limitFormatted': storageData['limitFormatted'] ?? '0 Bytes',
              'used': storageData['used'] ?? 0,
              'usedFormatted': storageData['usedFormatted'] ?? '0 Bytes',
              'available': storageData['available'] ?? 0,
              'availableFormatted': storageData['availableFormatted'] ?? '0 Bytes',
              'percentage': storageData['percentage'] ?? 0.0,
              'isFull': storageData['isFull'] ?? false,
              'canUpload': storageData['canUpload'] ?? true,
            },
          };
        } catch (e) {
          print('❌ [FileService] Error parsing storage info response: $e');
          return {
            'success': false,
            'error': 'خطأ في تحليل بيانات المساحة: ${e.toString()}',
          };
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          print('❌ [FileService] Storage info error: ${errorData['message'] ?? 'Unknown error'}');
          return {
            'success': false,
            'error': errorData['message'] ?? 'فشل في جلب معلومات المساحة',
          };
        } catch (e) {
          print('❌ [FileService] Error parsing error response: $e');
          return {
            'success': false,
            'error': 'فشل في جلب معلومات المساحة (Status: ${response.statusCode})',
          };
        }
      }
    } catch (e) {
      print('❌ [FileService] Get storage info error: $e');
      return {
        'success': false,
        'error': 'خطأ في جلب معلومات المساحة: ${e.toString()}',
      };
    }
  }

  /// ✅ جلب المساحة الإجمالية المستخدمة في التطبيق (جميع المستخدمين)
  Future<Map<String, dynamic>> getTotalStorageInfo() async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'error': 'لا يوجد token. يرجى تسجيل الدخول',
        };
      }

      final uri = Uri.parse("$_apiBase${ApiEndpoints.totalStorageInfo}");

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📊 [FileService] Get total storage info response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final totalStorageData = data['totalStorage'] ?? {};
        
        return {
          'success': true,
          'totalStorage': {
            'totalUsed': totalStorageData['totalUsed'] ?? 0,
            'totalUsedFormatted': totalStorageData['totalUsedFormatted'] ?? '0 Bytes',
            'totalFiles': totalStorageData['totalFiles'] ?? 0,
            'totalUsers': totalStorageData['totalUsers'] ?? 0,
          },
        };
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'error': errorData['message'] ?? 'فشل في جلب المساحة الإجمالية',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'فشل في جلب المساحة الإجمالية',
          };
        }
      }
    } catch (e) {
      print('❌ [FileService] Get total storage info error: $e');
      return {
        'success': false,
        'error': 'خطأ في جلب المساحة الإجمالية: ${e.toString()}',
      };
    }
  }
}
