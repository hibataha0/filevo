import 'package:filevo/services/storage_service.dart';
import 'package:filevo/services/user_service.dart';

/// ✅ Utility class للتحقق من صلاحيات الأعضاء في الغرف
class RoomPermissions {
  /// ✅ الحصول على role المستخدم الحالي في الغرفة
  static Future<String?> getCurrentUserRole(
    Map<String, dynamic> roomData,
  ) async {
    // ✅ محاولة جلب currentUserId من StorageService أولاً
    String? currentUserId = await StorageService.getUserId();

    // ✅ إذا لم يكن موجوداً في StorageService، نحاول جلب userId من roomData مباشرة
    if (currentUserId == null || currentUserId.isEmpty) {
      final roomUserId =
          roomData['userId']?.toString() ??
          roomData['user_id']?.toString() ??
          roomData['currentUserId']?.toString();

      if (roomUserId != null && roomUserId.isNotEmpty) {
        currentUserId = roomUserId;
      } else {
        return null;
      }
    }

    // ✅ التحقق من أن المستخدم هو owner
    final owner = roomData['owner'];
    if (owner != null) {
      String? ownerId;
      if (owner is Map<String, dynamic>) {
        ownerId =
            owner['_id']?.toString() ??
            owner['id']?.toString() ??
            owner['userId']?.toString() ??
            owner['user_id']?.toString();
      } else if (owner is String) {
        ownerId = owner;
      } else {
        ownerId = owner.toString();
      }

      if (ownerId != null && ownerId.isNotEmpty) {
        // ✅ المقارنة بعد تطبيع القيم
        if (ownerId.trim().toLowerCase() ==
            currentUserId.trim().toLowerCase()) {
          return 'owner';
        }
      }
    }

    // ✅ البحث عن المستخدم في members
    final members = roomData['members'] as List?;
    if (members != null) {
      for (final member in members) {
        final user = member['user'];
        String? userId;
        if (user is Map<String, dynamic>) {
          userId =
              user['_id']?.toString() ??
              user['id']?.toString() ??
              user['userId']?.toString() ??
              user['user_id']?.toString();
        } else if (user is String) {
          userId = user;
        } else {
          userId = user?.toString();
        }

        if (userId != null && userId.isNotEmpty) {
          // ✅ المقارنة بعد تطبيع القيم
          if (userId.trim().toLowerCase() ==
              currentUserId.trim().toLowerCase()) {
            return member['role']?.toString() ?? 'viewer';
          }
        }
      }
    }

    return null;
  }

  /// ✅ التحقق من أن المستخدم هو owner الحقيقي للغرفة (room.owner)
  /// ✅ ملاحظة: هذا يتحقق من room.owner وليس member.role == 'owner'
  static Future<String?> _getCurrentUserIdFromAPI() async {
    try {
      // ✅ محاولة جلب userId من API مباشرة للتأكد من أنه صحيح
      final userService = UserService();
      final result = await userService.getLoggedUserData();

      if (result['success'] == true) {
        Map<String, dynamic>? data;
        final rawData = result['data'];

        if (rawData is Map<String, dynamic>) {
          if (rawData['user'] is Map<String, dynamic>) {
            data = Map<String, dynamic>.from(rawData['user'] as Map);
          } else if (rawData['data'] is Map<String, dynamic>) {
            data = Map<String, dynamic>.from(rawData['data'] as Map);
          } else {
            data = rawData;
          }
        }

        if (data != null) {
          final fetchedId =
              data['_id']?.toString() ??
              data['id']?.toString() ??
              data['userId']?.toString() ??
              data['user_id']?.toString();

          if (fetchedId != null && fetchedId.isNotEmpty) {
            // ✅ حفظ userId الجديد في StorageService
            await StorageService.saveUserId(fetchedId);
            return fetchedId;
          }
        }
      }
    } catch (e) {
      print('❌ [isOwner] Error fetching userId from API: $e');
    }

    return null;
  }

  /// ✅ التحقق من أن المستخدم هو owner الحقيقي للغرفة (room.owner)
  /// ✅ ملاحظة: هذا يتحقق من room.owner وليس member.role == 'owner'
  static Future<bool> isOwner(Map<String, dynamic> roomData) async {
    // ✅ استخراج ownerId أولاً
    final owner = roomData['owner'];
    if (owner == null) {
      print('🔍 [isOwner] owner is null');
      return false;
    }

    String? ownerId;
    if (owner is Map<String, dynamic>) {
      ownerId =
          owner['_id']?.toString() ??
          owner['id']?.toString() ??
          owner['userId']?.toString() ??
          owner['user_id']?.toString();
    } else if (owner is String) {
      ownerId = owner;
    } else {
      ownerId = owner.toString();
    }

    if (ownerId == null || ownerId.isEmpty) {
      print('🔍 [isOwner] ownerId is null or empty');
      return false;
    }

    // ✅ دائماً نجلب userId من API مباشرة للتأكد من أنه صحيح
    // ✅ لا نعتمد على StorageService لأنه قد يكون محفوظ من حساب سابق
    print(
      '🔍 [isOwner] Fetching currentUserId from API (not using cached value)...',
    );
    final currentUserId = await _getCurrentUserIdFromAPI();

    if (currentUserId == null || currentUserId.isEmpty) {
      print('❌ [isOwner] Could not get currentUserId from API');
      return false;
    }

    // ✅ تحديث StorageService بالـ userId الصحيح من API
    await StorageService.saveUserId(currentUserId);

    // ✅ المقارنة بعد تطبيع القيم (إزالة المسافات والتحويل إلى lowercase للتأكد)
    final normalizedOwnerId = ownerId.trim().toLowerCase();
    final normalizedCurrentUserId = currentUserId.trim().toLowerCase();
    final isOwnerResult = normalizedOwnerId == normalizedCurrentUserId;

    print(
      '🔍 [isOwner] currentUserId (from API): ${currentUserId.substring(0, currentUserId.length > 20 ? 20 : currentUserId.length)}...',
    );
    print(
      '🔍 [isOwner] ownerId: ${ownerId.substring(0, ownerId.length > 20 ? 20 : ownerId.length)}...',
    );
    print(
      '🔍 [isOwner] normalized comparison: $normalizedCurrentUserId == $normalizedOwnerId = $isOwnerResult',
    );

    return isOwnerResult;
  }

  /// ✅ التحقق من أن المستخدم هو owner أو editor
  static Future<bool> isOwnerOrEditor(Map<String, dynamic> roomData) async {
    final role = await getCurrentUserRole(roomData);
    return role == 'owner' || role == 'editor';
  }

  /// ✅ التحقق من أن المستخدم يمكنه تعديل الروم (owner أو editor)
  static Future<bool> canEditRoom(Map<String, dynamic> roomData) async {
    return await isOwnerOrEditor(roomData);
  }

  /// ✅ التحقق من أن المستخدم يمكنه مشاركة الملفات/المجلدات
  /// ✅ يسمح لـ: room owner أو members مع canShare = true
  static Future<bool> canShareFiles(Map<String, dynamic> roomData) async {
    // ✅ 1. التحقق من أن المستخدم هو owner
    final isRoomOwner = await isOwner(roomData);
    if (isRoomOwner) {
      print('✅ [canShareFiles] User is room owner, can share');
      return true;
    }

    // ✅ 2. التحقق من أن المستخدم عضو مع canShare = true
    final currentUserId = await StorageService.getUserId();
    if (currentUserId == null || currentUserId.isEmpty) {
      print('❌ [canShareFiles] No currentUserId found');
      return false;
    }

    final members = roomData['members'] as List?;
    if (members != null) {
      for (final member in members) {
        final user = member['user'];
        String? userId;
        if (user is Map<String, dynamic>) {
          userId =
              user['_id']?.toString() ??
              user['id']?.toString() ??
              user['userId']?.toString() ??
              user['user_id']?.toString();
        } else if (user is String) {
          userId = user;
        } else {
          userId = user?.toString();
        }

        if (userId != null && userId.isNotEmpty) {
          if (userId.trim().toLowerCase() == currentUserId.trim().toLowerCase()) {
            final canShare = member['canShare'] == true;
            print('🔍 [canShareFiles] User found in members, canShare: $canShare');
            return canShare;
          }
        }
      }
    }

    print('❌ [canShareFiles] User cannot share files');
    return false;
  }

  /// ✅ التحقق من أن المستخدم يمكنه إزالة الملفات/المجلدات (owner أو editor)
  static Future<bool> canRemoveFiles(Map<String, dynamic> roomData) async {
    return await isOwnerOrEditor(roomData);
  }

  /// ✅ التحقق من أن المستخدم يمكنه إزالة ملف محدد من الغرفة
  /// ✅ يسمح لـ: room owner, file owner (الذي رفع الملف), file sharer (الذي شارك الملف), أو members مع owner/editor role
  static Future<bool> canRemoveFileFromRoom(
    Map<String, dynamic> roomData,
    Map<String, dynamic>? fileEntry, // ✅ fileEntry من room.files
    Map<String, dynamic>? fileData, // ✅ fileData (fileId populated)
  ) async {
    // ✅ 1. التحقق من أن المستخدم هو room owner أو member مع owner/editor role
    final canRemoveAsRoomMember = await isOwnerOrEditor(roomData);
    if (canRemoveAsRoomMember) {
      print('✅ [canRemoveFileFromRoom] User can remove as room owner/editor');
      return true;
    }

    // ✅ 2. التحقق من أن المستخدم هو من شارك الملف (sharedBy)
    if (fileEntry != null) {
      final currentUserId = await StorageService.getUserId();
      if (currentUserId != null) {
        final sharedBy = fileEntry['sharedBy'];
        if (sharedBy != null) {
          String? sharedById;
          if (sharedBy is Map<String, dynamic>) {
            sharedById = sharedBy['_id']?.toString() ?? 
                        sharedBy['id']?.toString() ?? 
                        sharedBy.toString();
          } else {
            sharedById = sharedBy.toString();
          }
          
          if (sharedById != null && sharedById.isNotEmpty) {
            final isFileSharer = sharedById.trim().toLowerCase() == 
                               currentUserId.trim().toLowerCase();
            if (isFileSharer) {
              print('✅ [canRemoveFileFromRoom] User is file sharer');
              return true;
            }
          }
        }
      }
    }

    // ✅ 3. التحقق من أن المستخدم هو صاحب الملف (file owner - الذي رفع الملف)
    if (fileData != null) {
      final currentUserId = await StorageService.getUserId();
      if (currentUserId != null) {
        final fileUserId = fileData['userId'];
        if (fileUserId != null) {
          String? fileUserIdStr;
          if (fileUserId is Map<String, dynamic>) {
            fileUserIdStr = fileUserId['_id']?.toString() ?? 
                           fileUserId['id']?.toString() ?? 
                           fileUserId.toString();
          } else {
            fileUserIdStr = fileUserId.toString();
          }
          
          if (fileUserIdStr != null && fileUserIdStr.isNotEmpty) {
            final isFileOwner = fileUserIdStr.trim().toLowerCase() == 
                              currentUserId.trim().toLowerCase();
            if (isFileOwner) {
              print('✅ [canRemoveFileFromRoom] User is file owner');
              return true;
            }
          }
        }
      }
    }

    print('❌ [canRemoveFileFromRoom] User cannot remove file');
    return false;
  }

  /// ✅ التحقق من أن المستخدم يمكنه إزالة مجلد محدد من الغرفة
  /// ✅ يسمح لـ: room owner, folder owner (الذي رفع المجلد), folder sharer (الذي شارك المجلد), أو members مع owner/editor role
  static Future<bool> canRemoveFolderFromRoom(
    Map<String, dynamic> roomData,
    Map<String, dynamic>? folderEntry, // ✅ folderEntry من room.folders
    Map<String, dynamic>? folderData, // ✅ folderData (folderId populated)
  ) async {
    // ✅ 1. التحقق من أن المستخدم هو room owner أو member مع owner/editor role
    final canRemoveAsRoomMember = await isOwnerOrEditor(roomData);
    if (canRemoveAsRoomMember) {
      print('✅ [canRemoveFolderFromRoom] User can remove as room owner/editor');
      return true;
    }

    // ✅ 2. التحقق من أن المستخدم هو من شارك المجلد (sharedBy)
    if (folderEntry != null) {
      final currentUserId = await StorageService.getUserId();
      if (currentUserId != null) {
        final sharedBy = folderEntry['sharedBy'];
        if (sharedBy != null) {
          String? sharedById;
          if (sharedBy is Map<String, dynamic>) {
            sharedById = sharedBy['_id']?.toString() ?? 
                        sharedBy['id']?.toString() ?? 
                        sharedBy.toString();
          } else {
            sharedById = sharedBy.toString();
          }
          
          if (sharedById != null && sharedById.isNotEmpty) {
            final isFolderSharer = sharedById.trim().toLowerCase() == 
                                 currentUserId.trim().toLowerCase();
            if (isFolderSharer) {
              print('✅ [canRemoveFolderFromRoom] User is folder sharer');
              return true;
            }
          }
        }
      }
    }

    // ✅ 3. التحقق من أن المستخدم هو صاحب المجلد (folder owner - الذي رفع المجلد)
    if (folderData != null) {
      final currentUserId = await StorageService.getUserId();
      if (currentUserId != null) {
        final folderUserId = folderData['userId'];
        if (folderUserId != null) {
          String? folderUserIdStr;
          if (folderUserId is Map<String, dynamic>) {
            folderUserIdStr = folderUserId['_id']?.toString() ?? 
                             folderUserId['id']?.toString() ?? 
                             folderUserId.toString();
          } else {
            folderUserIdStr = folderUserId.toString();
          }
          
          if (folderUserIdStr != null && folderUserIdStr.isNotEmpty) {
            final isFolderOwner = folderUserIdStr.trim().toLowerCase() == 
                                currentUserId.trim().toLowerCase();
            if (isFolderOwner) {
              print('✅ [canRemoveFolderFromRoom] User is folder owner');
              return true;
            }
          }
        }
      }
    }

    print('❌ [canRemoveFolderFromRoom] User cannot remove folder');
    return false;
  }

  /// ✅ التحقق من أن المستخدم يمكنه إضافة تعليقات (owner, editor, commenter)
  static Future<bool> canAddComments(Map<String, dynamic> roomData) async {
    final role = await getCurrentUserRole(roomData);
    return role == 'owner' || role == 'editor' || role == 'commenter';
  }

  /// ✅ التحقق من أن المستخدم يمكنه حذف تعليق (owner, editor, أو صاحب التعليق)
  static Future<bool> canDeleteComment(
    Map<String, dynamic> roomData,
    String? commentUserId,
  ) async {
    final role = await getCurrentUserRole(roomData);
    if (role == 'owner' || role == 'editor') {
      return true;
    }

    // ✅ التحقق من أن المستخدم هو صاحب التعليق
    if (commentUserId != null) {
      final currentUserId = await StorageService.getUserId();
      return currentUserId == commentUserId;
    }

    return false;
  }

  /// ✅ التحقق من أن المستخدم يمكنه إرسال دعوات (owner فقط)
  static Future<bool> canSendInvitations(Map<String, dynamic> roomData) async {
    final result = await isOwner(roomData);
    print('🔍 [canSendInvitations] result: $result');
    print('🔍 [canSendInvitations] roomData owner: ${roomData['owner']}');
    return result;
  }

  /// ✅ التحقق من أن المستخدم يمكنه تعديل صلاحيات الأعضاء (owner فقط)
  static Future<bool> canUpdateMemberRoles(
    Map<String, dynamic> roomData,
  ) async {
    return await isOwner(roomData);
  }

  /// ✅ التحقق من أن المستخدم يمكنه إزالة الأعضاء (owner فقط)
  static Future<bool> canRemoveMembers(Map<String, dynamic> roomData) async {
    return await isOwner(roomData);
  }

  /// ✅ التحقق من أن المستخدم يمكنه حذف الغرفة (owner فقط)
  static Future<bool> canDeleteRoom(Map<String, dynamic> roomData) async {
    return await isOwner(roomData);
  }

  /// ✅ التحقق من أن المستخدم يمكنه حفظ الملفات/المجلدات (كل الأعضاء)
  static Future<bool> canSaveFiles(Map<String, dynamic> roomData) async {
    final role = await getCurrentUserRole(roomData);
    return role != null; // أي عضو يمكنه الحفظ
  }

  /// ✅ التحقق من أن المستخدم يمكنه مشاهدة الملفات (كل الأعضاء)
  static Future<bool> canViewFiles(Map<String, dynamic> roomData) async {
    final role = await getCurrentUserRole(roomData);
    return role != null; // أي عضو يمكنه المشاهدة
  }
}
