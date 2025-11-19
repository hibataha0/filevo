import 'package:filevo/services/room_service.dart';
import 'package:flutter/material.dart';

class RoomController with ChangeNotifier {
  final RoomService _service = RoomService();

  bool isLoading = false;
  String? errorMessage;
  List<Map<String, dynamic>> rooms = [];

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setError(String? error) {
    errorMessage = error;
    notifyListeners();
  }

  /// ✅ إنشاء غرفة مشاركة جديدة
  Future<Map<String, dynamic>?> createRoom({
    required String name,
    String? description,
  }) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _service.createRoom(
        name: name,
        description: description,
      );

      if (response['room'] != null) {
        // ✅ إضافة الغرفة الجديدة للقائمة
        rooms.insert(0, response['room']);
        notifyListeners();
        return response;
      }

      setError(response['message'] ?? 'فشل إنشاء الغرفة');
      return null;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ الحصول على جميع الغرف
  Future<bool> getRooms() async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _service.getRooms();

      if (response['rooms'] != null) {
        rooms = List<Map<String, dynamic>>.from(response['rooms']);
        notifyListeners();
        return true;
      }

      setError(response['message'] ?? 'فشل تحميل الغرف');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ الحصول على تفاصيل غرفة معينة
  Future<Map<String, dynamic>?> getRoomById(String roomId) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _service.getRoomById(roomId);

      if (response['room'] != null) {
        return response;
      }

      setError(response['message'] ?? 'فشل تحميل تفاصيل الغرفة');
      return null;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ تحديث غرفة
  Future<bool> updateRoom({
    required String roomId,
    String? name,
    String? description,
  }) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _service.updateRoom(
        roomId: roomId,
        name: name,
        description: description,
      );

      if (response['room'] != null) {
        // ✅ تحديث الغرفة في القائمة
        final index = rooms.indexWhere((room) => 
          room['_id']?.toString() == roomId.toString()
        );
        if (index != -1 && index < rooms.length) {
          rooms[index] = response['room'] as Map<String, dynamic>;
          notifyListeners();
        }
        return true;
      }

      setError(response['message'] ?? 'فشل تحديث الغرفة');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ حذف غرفة
  Future<bool> deleteRoom(String roomId) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _service.deleteRoom(roomId);

      if (response['message'] != null) {
        // ✅ إزالة الغرفة من القائمة
        rooms.removeWhere((room) => room['_id'] == roomId);
        notifyListeners();
        return true;
      }

      setError(response['message'] ?? 'فشل حذف الغرفة');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ إرسال دعوة للمستخدم للانضمام للغرفة
  Future<Map<String, dynamic>?> sendInvitation({
    required String roomId,
    required String receiverId,
    String? permission,
    String? message,
  }) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _service.sendInvitation(
        roomId: roomId,
        receiverId: receiverId,
        permission: permission,
        message: message,
      );

      if (response['invitation'] != null) {
        return response;
      }

      setError(response['message'] ?? 'فشل إرسال الدعوة');
      return null;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ قبول دعوة للانضمام للغرفة
  Future<Map<String, dynamic>?> acceptInvitation(String invitationId) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _service.acceptInvitation(invitationId);

      if (response['room'] != null) {
        // ✅ إضافة الغرفة الجديدة للقائمة
        final roomExists = rooms.any((room) => room['_id'] == response['room']['_id']);
        if (!roomExists) {
          rooms.insert(0, response['room']);
          notifyListeners();
        }
        return response;
      }

      setError(response['message'] ?? 'فشل قبول الدعوة');
      return null;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ رفض دعوة للانضمام للغرفة
  Future<bool> rejectInvitation(String invitationId) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _service.rejectInvitation(invitationId);

      if (response['invitation'] != null) {
        return true;
      }

      setError(response['message'] ?? 'فشل رفض الدعوة');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ الحصول على الدعوات المعلقة
  Future<List<Map<String, dynamic>>> getPendingInvitations() async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _service.getPendingInvitations();

      if (response['invitations'] != null) {
        return List<Map<String, dynamic>>.from(response['invitations']);
      }

      setError(response['message'] ?? 'فشل تحميل الدعوات');
      return [];
    } catch (e) {
      setError(e.toString());
      return [];
    } finally {
      setLoading(false);
    }
  }

  /// ✅ تحديث صلاحيات عضو في الغرفة
  Future<bool> updateMemberPermission({
    required String roomId,
    required String memberId,
    String? permission,
    String? role,
  }) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _service.updateMemberPermission(
        roomId: roomId,
        memberId: memberId,
        permission: permission,
        role: role,
      );

      if (response['room'] != null) {
        // ✅ تحديث الغرفة في القائمة
        final index = rooms.indexWhere((room) => 
          room['_id']?.toString() == roomId.toString()
        );
        if (index != -1 && index < rooms.length) {
          rooms[index] = response['room'] as Map<String, dynamic>;
          notifyListeners();
        }
        return true;
      }

      setError(response['message'] ?? 'فشل تحديث صلاحيات العضو');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ إزالة عضو من الغرفة
  Future<bool> removeMember({
    required String roomId,
    required String memberId,
  }) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _service.removeMember(
        roomId: roomId,
        memberId: memberId,
      );

      if (response['room'] != null) {
        // ✅ تحديث الغرفة في القائمة
        final index = rooms.indexWhere((room) => 
          room['_id']?.toString() == roomId.toString()
        );
        if (index != -1 && index < rooms.length) {
          rooms[index] = response['room'] as Map<String, dynamic>;
          notifyListeners();
        }
        return true;
      }

      setError(response['message'] ?? 'فشل إزالة العضو');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ مشاركة ملف مع الغرفة
  Future<bool> shareFileWithRoom({
    required String roomId,
    required String fileId,
  }) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _service.shareFileWithRoom(
        roomId: roomId,
        fileId: fileId,
      );

      if (response['room'] != null) {
        // ✅ تحديث الغرفة في القائمة
        final index = rooms.indexWhere((room) => 
          room['_id']?.toString() == roomId.toString()
        );
        if (index != -1 && index < rooms.length) {
          rooms[index] = response['room'] as Map<String, dynamic>;
          notifyListeners();
        }
        return true;
      }

      setError(response['message'] ?? 'فشل مشاركة الملف');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ مشاركة مجلد مع الغرفة
  Future<bool> shareFolderWithRoom({
    required String roomId,
    required String folderId,
  }) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _service.shareFolderWithRoom(
        roomId: roomId,
        folderId: folderId,
      );

      if (response['room'] != null) {
        // ✅ تحديث الغرفة في القائمة
        final index = rooms.indexWhere((room) => 
          room['_id']?.toString() == roomId.toString()
        );
        if (index != -1 && index < rooms.length) {
          rooms[index] = response['room'] as Map<String, dynamic>;
          notifyListeners();
        }
        return true;
      }

      setError(response['message'] ?? 'فشل مشاركة المجلد');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ إضافة تعليق على ملف/مجلد في الغرفة
  Future<Map<String, dynamic>?> addComment({
    required String roomId,
    required String targetType, // 'file' or 'folder'
    required String targetId,
    required String content,
  }) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _service.addComment(
        roomId: roomId,
        targetType: targetType,
        targetId: targetId,
        content: content,
      );

      if (response['comment'] != null) {
        return response;
      }

      setError(response['message'] ?? 'فشل إضافة التعليق');
      return null;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ الحصول على تعليقات ملف/مجلد في الغرفة
  Future<List<Map<String, dynamic>>> listComments({
    required String roomId,
    required String targetType, // 'file' or 'folder'
    required String targetId,
  }) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _service.listComments(
        roomId: roomId,
        targetType: targetType,
        targetId: targetId,
      );

      if (response['comments'] != null) {
        return List<Map<String, dynamic>>.from(response['comments']);
      }

      setError(response['message'] ?? 'فشل تحميل التعليقات');
      return [];
    } catch (e) {
      setError(e.toString());
      return [];
    } finally {
      setLoading(false);
    }
  }

  /// ✅ حذف تعليق
  Future<bool> deleteComment({
    required String roomId,
    required String commentId,
  }) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _service.deleteComment(
        roomId: roomId,
        commentId: commentId,
      );

      if (response['message'] != null) {
        return true;
      }

      setError(response['message'] ?? 'فشل حذف التعليق');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ تنظيف الدعوات القديمة
  Future<int?> cleanupOldInvitations() async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _service.cleanupOldInvitations();

      if (response['deletedCount'] != null) {
        return response['deletedCount'] as int;
      }

      setError(response['message'] ?? 'فشل تنظيف الدعوات');
      return null;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ الحصول على إحصائيات الدعوات
  Future<Map<String, dynamic>?> getInvitationStats() async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await _service.getInvitationStats();

      if (response['stats'] != null) {
        return response['stats'];
      }

      setError(response['message'] ?? 'فشل تحميل الإحصائيات');
      return null;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }
}

