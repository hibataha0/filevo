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
      if (decodedResponse is Map<String, dynamic> && decodedResponse['room'] != null) {
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
    String? message,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      'email': email,
      if (role != null) 'role': role,
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

  /// ✅ تحديث دور عضو في الغرفة
  Future<Map<String, dynamic>> updateMemberRole({
    required String roomId,
    required String memberId,
    required String role,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      'role': role,
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
    String? sharedBy,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      'fileId': fileId,
      if (sharedBy != null) 'sharedBy': sharedBy,
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

  /// ✅ إزالة ملف من الغرفة
  Future<Map<String, dynamic>> unshareFileFromRoom({
    required String roomId,
    required String fileId,
  }) async {
    final token = await StorageService.getToken();

    final response = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.unshareFileFromRoom(roomId, fileId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to remove file from room');
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
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.shareFolderWithRoom(roomId)}"),
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
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.unshareFolderFromRoom(roomId, folderId)}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to remove folder from room');
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
    final uri = Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.roomComments(roomId)}")
        .replace(queryParameters: query);

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

