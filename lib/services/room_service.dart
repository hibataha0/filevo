import 'dart:convert';
import 'package:filevo/services/api_endpoints.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/storage_service.dart';

class RoomService {
  /// ✅ إنشاء غرفة مشاركة جديدة
  Future<Map<String, dynamic>> createRoom({
    required String name,
    String? description,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      'name': name,
      if (description != null && description.isNotEmpty) 'description': description,
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
  Future<Map<String, dynamic>> getRoomById(String roomId) async {
    final token = await StorageService.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.roomById(roomId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }

  /// ✅ تحديث غرفة
  Future<Map<String, dynamic>> updateRoom({
    required String roomId,
    String? name,
    String? description,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      if (name != null && name.isNotEmpty) 'name': name,
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

    return jsonDecode(response.body);
  }

  /// ✅ حذف غرفة
  Future<Map<String, dynamic>> deleteRoom(String roomId) async {
    final token = await StorageService.getToken();

    final response = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.roomById(roomId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }

  /// ✅ إرسال دعوة للمستخدم للانضمام للغرفة
  Future<Map<String, dynamic>> sendInvitation({
    required String roomId,
    required String receiverId,
    String? permission,
    String? message,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      'receiverId': receiverId,
      if (permission != null) 'permission': permission,
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
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.acceptInvitation(invitationId)}"),
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
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.rejectInvitation(invitationId)}"),
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

  /// ✅ تحديث صلاحيات عضو في الغرفة
  Future<Map<String, dynamic>> updateMemberPermission({
    required String roomId,
    required String memberId,
    String? permission,
    String? role,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      if (permission != null) 'permission': permission,
      if (role != null) 'role': role,
    });

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.roomMemberById(roomId, memberId)}"),
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
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.roomMemberById(roomId, memberId)}"),
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
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      'fileId': fileId,
    });

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.shareFileWithRoom(roomId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    return jsonDecode(response.body);
  }

  /// ✅ مشاركة مجلد مع الغرفة
  Future<Map<String, dynamic>> shareFolderWithRoom({
    required String roomId,
    required String folderId,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      'folderId': folderId,
    });

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.shareFolderWithRoom(roomId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    return jsonDecode(response.body);
  }

  /// ✅ إضافة تعليق على ملف/مجلد في الغرفة
  Future<Map<String, dynamic>> addComment({
    required String roomId,
    required String targetType, // 'file' or 'folder'
    required String targetId,
    required String content,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      'targetType': targetType,
      'targetId': targetId,
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
    required String targetType, // 'file' or 'folder'
    required String targetId,
  }) async {
    final token = await StorageService.getToken();

    final uri = Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.roomComments(roomId)}").replace(
      queryParameters: {
        'targetType': targetType,
        'targetId': targetId,
      },
    );

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
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.deleteComment(roomId, commentId)}"),
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
}

