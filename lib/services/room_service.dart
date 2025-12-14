import 'dart:convert';
import 'dart:io';
import 'package:filevo/services/api_endpoints.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class RoomService {
  /// ✅ إنشاء غرفة مشاركة جديدة
  Future<Map<String, dynamic>> createRoom({
    required String name,
    String? description,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      'name': name,
      if (description != null && description.isNotEmpty)
        'description': description,
    });

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.rooms}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    return jsonDecode(response.body);
  }

  /// ✅ الحصول على جميع الغرف الخاصة بالمستخدم
  Future<Map<String, dynamic>> getRooms() async {
    final token = await StorageService.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.rooms}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }

  /// ✅ الحصول على تفاصيل غرفة معينة
  /// Returns room details with populated data:
  /// - owner (name, email)
  /// - members.user (name, email)
  /// - files.fileId (file details)
  /// - folders.folderId (folder details)
  Future<Map<String, dynamic>> getRoomById(String roomId) async {
    final token = await StorageService.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.roomById(roomId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      // ✅ التأكد من أن الاستجابة تحتوي على room
      if (decodedResponse is Map<String, dynamic> &&
          decodedResponse['room'] != null) {
        return decodedResponse;
      } else {
        throw Exception('Invalid response format: room not found');
      }
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to load room details');
    }
  }

  /// ✅ تحديث غرفة
  /// Route: PUT /api/rooms/:id
  /// الصلاحيات: مالك الروم (owner) أو الأعضاء برتبة editor
  /// الوظيفة: تعديل اسم الروم و/أو وصف الروم
  Future<Map<String, dynamic>> updateRoom({
    required String roomId,
    String? name,
    String? description,
  }) async {
    final token = await StorageService.getToken();

    // ✅ بناء body - إرسال name و description حتى لو كان null (الباك إند يتحقق)
    final body = jsonEncode({
      if (name != null) 'name': name,
      if (description != null) 'description': description,
    });

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.roomById(roomId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    // ✅ معالجة الأخطاء
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 403) {
      // ✅ المستخدم ليس owner أو editor
      final errorBody = jsonDecode(response.body);
      throw Exception(
        errorBody['message'] ??
            'Only room owner or members with editor role can update room details',
      );
    } else if (response.statusCode == 404) {
      // ✅ الغرفة غير موجودة
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Room not found');
    } else if (response.statusCode == 400) {
      // ✅ خطأ في البيانات (مثل اسم فارغ)
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Invalid room data');
    } else {
      // ✅ أخطاء أخرى
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to update room');
    }
  }

  /// ✅ حذف غرفة (فقط مالك الغرفة يمكنه حذفها)
  Future<Map<String, dynamic>> deleteRoom(String roomId) async {
    final token = await StorageService.getToken();

    final response = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.roomById(roomId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to delete room');
    }
  }

  /// ✅ مغادرة غرفة (أي عضو يمكنه مغادرة الغرفة، لكن المالك لا يمكنه)
  Future<Map<String, dynamic>> leaveRoom(String roomId) async {
    final token = await StorageService.getToken();

    final response = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.leaveRoom(roomId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to leave room');
    }
  }

  /// ✅ إرسال دعوة للمستخدم للانضمام للغرفة
  Future<Map<String, dynamic>> sendInvitation({
    required String roomId,
    required String email,
    String? role,
    bool? canShare,
    String? message,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      'email': email,
      if (role != null) 'role': role,
      if (canShare != null) 'canShare': canShare,
      if (message != null && message.isNotEmpty) 'message': message,
    });

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.sendInvitation(roomId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    return jsonDecode(response.body);
  }

  /// ✅ قبول دعوة للانضمام للغرفة
  Future<Map<String, dynamic>> acceptInvitation(String invitationId) async {
    final token = await StorageService.getToken();

    final response = await http.put(
      Uri.parse(
        "${ApiConfig.baseUrl}${ApiEndpoints.acceptInvitation(invitationId)}",
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }

  /// ✅ رفض دعوة للانضمام للغرفة
  Future<Map<String, dynamic>> rejectInvitation(String invitationId) async {
    final token = await StorageService.getToken();

    final response = await http.put(
      Uri.parse(
        "${ApiConfig.baseUrl}${ApiEndpoints.rejectInvitation(invitationId)}",
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }

  /// ✅ الحصول على الدعوات المعلقة
  Future<Map<String, dynamic>> getPendingInvitations() async {
    final token = await StorageService.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.pendingInvitations}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }

  /// ✅ تحديث دور عضو في الغرفة
  Future<Map<String, dynamic>> updateMemberRole({
    required String roomId,
    required String memberId,
    required String role,
    bool? canShare,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      'role': role,
      if (canShare != null) 'canShare': canShare,
    });

    final response = await http.put(
      Uri.parse(
        "${ApiConfig.baseUrl}${ApiEndpoints.roomMemberById(roomId, memberId)}",
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    return jsonDecode(response.body);
  }

  /// ✅ إزالة عضو من الغرفة
  Future<Map<String, dynamic>> removeMember({
    required String roomId,
    required String memberId,
  }) async {
    final token = await StorageService.getToken();

    final response = await http.delete(
      Uri.parse(
        "${ApiConfig.baseUrl}${ApiEndpoints.roomMemberById(roomId, memberId)}",
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }

  /// ✅ مشاركة ملف مع الغرفة
  Future<Map<String, dynamic>> shareFileWithRoom({
    required String roomId,
    required String fileId,
    String? sharedBy,
  }) async {
    final token = await StorageService.getToken();

    // ✅ التحقق من وجود token
    if (token == null || token.isEmpty) {
      print('❌ [shareFileWithRoom] Token is null or empty');
      throw Exception('لا يمكن تحديد هوية المستخدم. يرجى إعادة تسجيل الدخول.');
    }

    final body = jsonEncode({
      'fileId': fileId,
      if (sharedBy != null) 'sharedBy': sharedBy,
    });

    final url = "${ApiConfig.baseUrl}${ApiEndpoints.shareFileWithRoom(roomId)}";
    print('🌐 POST $url');
    print('📦 Body: $body');
    print('🔑 Token: ${token.substring(0, 20)}...');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print('📥 Response Status: ${response.statusCode}');
    print('📥 Response Body: ${response.body}');

    // ✅ معالجة حالة 401 (Unauthorized)
    if (response.statusCode == 401) {
      print('❌ [shareFileWithRoom] 401 Unauthorized - Token may be invalid');
      final errorBody = jsonDecode(response.body);
      throw Exception(
        errorBody['message'] ??
            'لا يمكن تحديد هوية المستخدم. يرجى إعادة تسجيل الدخول.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decodedResponse = jsonDecode(response.body);
        print('✅ [shareFileWithRoom] Success: $decodedResponse');
        return decodedResponse;
      } catch (e) {
        print('❌ Error decoding response: $e');
        throw Exception('خطأ في تنسيق الاستجابة من السيرفر');
      }
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        final errorMessage =
            errorBody['message'] ??
            errorBody['error'] ??
            'Failed to share file with room';
        print('❌ [shareFileWithRoom] Error: $errorMessage');
        throw Exception(errorMessage);
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('خطأ في مشاركة الملف: ${response.statusCode}');
      }
    }
  }

  /// ✅ مشاركة ملف مع الغرفة لمرة واحدة
  Future<Map<String, dynamic>> shareFileWithRoomOneTime({
    required String roomId,
    required String fileId,
    int? expiresInHours,
  }) async {
    final token = await StorageService.getToken();

    // ✅ التحقق من وجود token
    if (token == null || token.isEmpty) {
      print('❌ [shareFileWithRoomOneTime] Token is null or empty');
      throw Exception('لا يمكن تحديد هوية المستخدم. يرجى إعادة تسجيل الدخول.');
    }

    final body = jsonEncode({
      'fileId': fileId,
      if (expiresInHours != null) 'expiresInHours': expiresInHours,
    });

    final url =
        "${ApiConfig.baseUrl}${ApiEndpoints.shareFileWithRoomOneTime(roomId)}";
    print('🌐 POST $url');
    print('📦 Body: $body');
    print('🔑 Token: ${token.substring(0, 20)}...');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print('📥 Response Status: ${response.statusCode}');
    print('📥 Response Body: ${response.body}');

    // ✅ معالجة حالة 401 (Unauthorized)
    if (response.statusCode == 401) {
      print(
        '❌ [shareFileWithRoomOneTime] 401 Unauthorized - Token may be invalid',
      );
      final errorBody = jsonDecode(response.body);
      throw Exception(
        errorBody['message'] ??
            'لا يمكن تحديد هوية المستخدم. يرجى إعادة تسجيل الدخول.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decodedResponse = jsonDecode(response.body);
        print('✅ [shareFileWithRoomOneTime] Success: $decodedResponse');
        return decodedResponse;
      } catch (e) {
        print('❌ Error decoding response: $e');
        throw Exception('خطأ في تنسيق الاستجابة من السيرفر');
      }
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        final errorMessage =
            errorBody['message'] ??
            errorBody['error'] ??
            'Failed to share file with room';
        print('❌ [shareFileWithRoomOneTime] Error: $errorMessage');
        throw Exception(errorMessage);
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('خطأ في مشاركة الملف: ${response.statusCode}');
      }
    }
  }

  /// ✅ الوصول إلى ملف مشترك لمرة واحدة
  /// Returns response with fields:
  /// - message: Success/error message
  /// - file: File data (if not removed)
  /// - wasOneTimeShare: Boolean indicating if it was a one-time share
  /// - fileRemovedFromRoom: Boolean indicating if file was removed
  /// - allMembersViewed: Boolean indicating if all members viewed the file
  /// - accessCount: Number of times the file was accessed
  Future<Map<String, dynamic>> accessOneTimeFile({
    required String roomId,
    required String fileId,
  }) async {
    final token = await StorageService.getToken();

    final response = await http.get(
      Uri.parse(
        "${ApiConfig.baseUrl}${ApiEndpoints.accessOneTimeFile(roomId, fileId)}",
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 410) {
      // ✅ File access expired (410 Gone)
      final errorBody = jsonDecode(response.body);
      return {
        'success': false,
        'error': errorBody['message'] ?? 'File access has expired',
        'expired': true,
      };
    } else {
      // ✅ Other errors (403, 404, etc.)
      final errorBody = jsonDecode(response.body);
      return {
        'success': false,
        'error':
            errorBody['message'] ??
            errorBody['error'] ??
            'Failed to access file',
      };
    }
  }

  /// ✅ إزالة ملف من الغرفة
  Future<Map<String, dynamic>> unshareFileFromRoom({
    required String roomId,
    required String fileId,
  }) async {
    final token = await StorageService.getToken();

    final response = await http.delete(
      Uri.parse(
        "${ApiConfig.baseUrl}${ApiEndpoints.unshareFileFromRoom(roomId, fileId)}",
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(
        errorBody['message'] ?? 'Failed to remove file from room',
      );
    }
  }

  /// ✅ مشاركة مجلد مع الغرفة
  Future<Map<String, dynamic>> shareFolderWithRoom({
    required String roomId,
    required String folderId,
    String? sharedBy,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      'folderId': folderId,
      if (sharedBy != null) 'sharedBy': sharedBy,
    });

    final response = await http.post(
      Uri.parse(
        "${ApiConfig.baseUrl}${ApiEndpoints.shareFolderWithRoom(roomId)}",
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    return jsonDecode(response.body);
  }

  /// ✅ إزالة مجلد من الغرفة
  Future<Map<String, dynamic>> unshareFolderFromRoom({
    required String roomId,
    required String folderId,
  }) async {
    final token = await StorageService.getToken();

    final response = await http.delete(
      Uri.parse(
        "${ApiConfig.baseUrl}${ApiEndpoints.unshareFolderFromRoom(roomId, folderId)}",
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(
        errorBody['message'] ?? 'Failed to remove folder from room',
      );
    }
  }

  /// ✅ إضافة تعليق على ملف/مجلد في الغرفة
  Future<Map<String, dynamic>> addComment({
    required String roomId,
    required String targetType, // 'file', 'folder', or 'room'
    String? targetId,
    required String content,
  }) async {
    final token = await StorageService.getToken();
    final body = jsonEncode({
      'targetType': targetType,
      if (targetId != null && targetId.isNotEmpty) 'targetId': targetId,
      'content': content,
    });

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.roomComments(roomId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    return jsonDecode(response.body);
  }

  /// ✅ الحصول على تعليقات ملف/مجلد في الغرفة
  Future<Map<String, dynamic>> listComments({
    required String roomId,
    required String targetType, // 'file', 'folder', or 'room'
    String? targetId,
  }) async {
    final token = await StorageService.getToken();
    final query = {
      'targetType': targetType,
      if (targetId != null && targetId.isNotEmpty) 'targetId': targetId,
    };
    final uri = Uri.parse(
      "${ApiConfig.baseUrl}${ApiEndpoints.roomComments(roomId)}",
    ).replace(queryParameters: query);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }

  /// ✅ حذف تعليق
  Future<Map<String, dynamic>> deleteComment({
    required String roomId,
    required String commentId,
  }) async {
    final token = await StorageService.getToken();

    final response = await http.delete(
      Uri.parse(
        "${ApiConfig.baseUrl}${ApiEndpoints.deleteComment(roomId, commentId)}",
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }

  /// ✅ تنظيف الدعوات القديمة
  Future<Map<String, dynamic>> cleanupOldInvitations() async {
    final token = await StorageService.getToken();

    final response = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.cleanupInvitations}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }

  /// ✅ الحصول على إحصائيات الدعوات
  Future<Map<String, dynamic>> getInvitationStats() async {
    final token = await StorageService.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.invitationStats}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }

  /// ✅ حفظ ملف من الغرفة إلى حساب المستخدم
  Future<Map<String, dynamic>> saveFileFromRoom({
    required String roomId,
    required String fileId,
    String? parentFolderId,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      if (parentFolderId != null && parentFolderId.isNotEmpty)
        'parentFolderId': parentFolderId,
    });

    final response = await http.post(
      Uri.parse(
        "${ApiConfig.baseUrl}${ApiEndpoints.saveFileFromRoom(roomId, fileId)}",
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
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to save file from room');
    }
  }

  /// ✅ حفظ مجلد من الغرفة إلى حساب المستخدم
  Future<Map<String, dynamic>> saveFolderFromRoom({
    required String roomId,
    required String folderId,
    String? parentFolderId,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      if (parentFolderId != null && parentFolderId.isNotEmpty)
        'parentFolderId': parentFolderId,
    });

    final response = await http.post(
      Uri.parse(
        "${ApiConfig.baseUrl}${ApiEndpoints.saveFolderFromRoom(roomId, folderId)}",
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
      final errorBody = jsonDecode(response.body);
      throw Exception(
        errorBody['message'] ?? 'Failed to save folder from room',
      );
    }
  }

  /// ✅ تحميل ملف مشترك في الروم
  /// Returns: Map with 'success' and 'filePath' or 'error'
  Future<Map<String, dynamic>> downloadRoomFile({
    required String roomId,
    required String fileId,
    String? fileName,
  }) async {
    try {
      final token = await StorageService.getToken();

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

      final url =
          "${ApiConfig.baseUrl}${ApiEndpoints.downloadRoomFile(roomId, fileId)}";
      print("Downloading room file from: $url");

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
        final errorMsg =
            e.response?.data?['message'] ?? 'ليس لديك صلاحية لتحميل هذا الملف';
        if (errorMsg.contains('already viewed') ||
            errorMsg.contains('One-time access')) {
          return {
            'success': false,
            'error': 'تم عرض هذا الملف مسبقاً. المشاركة لمرة واحدة فقط.',
          };
        }
        return {'success': false, 'error': errorMsg};
      } else if (e.response?.statusCode == 404) {
        return {'success': false, 'error': 'الملف غير موجود في هذه الغرفة'};
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

  /// ✅ تحميل مجلد مشترك في الروم كـ ZIP
  /// Returns: Map with 'success' and 'filePath' or 'error'
  Future<Map<String, dynamic>> downloadRoomFolder({
    required String roomId,
    required String folderId,
    String? folderName,
  }) async {
    try {
      final token = await StorageService.getToken();

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

      final url =
          "${ApiConfig.baseUrl}${ApiEndpoints.downloadRoomFolder(roomId, folderId)}";
      print("Downloading room folder from: $url");

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
        return {'success': false, 'error': 'ليس لديك صلاحية لتحميل هذا المجلد'};
      } else if (e.response?.statusCode == 404) {
        return {'success': false, 'error': 'المجلد غير موجود في هذه الغرفة'};
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
}
