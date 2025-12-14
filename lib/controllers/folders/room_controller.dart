import 'package:filevo/services/room_service.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/services/user_service.dart';
import 'package:flutter/material.dart';

class RoomController with ChangeNotifier {
  final RoomService _service = RoomService();
  final UserService _userService = UserService();

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

  Future<String?> _getCurrentUserId() async {
    print('🔍 [getCurrentUserId] Starting...');

    // ✅ محاولة جلب الـ ID من الـ cache أولاً
    final cachedId = await StorageService.getUserId();
    if (cachedId != null && cachedId.isNotEmpty) {
      print(
        '✅ [getCurrentUserId] Found cached ID: ${cachedId.substring(0, 10)}...',
      );
      return cachedId;
    }

    print('⚠️ [getCurrentUserId] No cached ID, fetching from API...');

    try {
      final result = await _userService.getLoggedUserData();
      print('📥 [getCurrentUserId] API Response: $result');

      if (result['success'] == true) {
        Map<String, dynamic>? data;
        final rawData = result['data'];

        print('📦 [getCurrentUserId] Raw data: $rawData');

        if (rawData is Map<String, dynamic>) {
          // ✅ محاولة استخراج البيانات من 'user' أولاً
          if (rawData['user'] is Map<String, dynamic>) {
            data = Map<String, dynamic>.from(rawData['user'] as Map);
            print('✅ [getCurrentUserId] Found user in rawData[\'user\']');
          }
          // ✅ إذا كان هناك 'data' داخل rawData (مثل: {data: {_id: ...}})
          else if (rawData['data'] is Map<String, dynamic>) {
            data = Map<String, dynamic>.from(rawData['data'] as Map);
            print('✅ [getCurrentUserId] Found data in rawData[\'data\']');
          }
          // ✅ إذا لم يكن هناك 'user' أو 'data'، استخدم rawData مباشرة
          else {
            data = rawData;
            print('✅ [getCurrentUserId] Using rawData directly');
          }
        } else if (rawData != null) {
          // ✅ إذا كان rawData ليس Map، حاول تحويله
          print(
            '⚠️ [getCurrentUserId] rawData is not Map, type: ${rawData.runtimeType}',
          );
        }

        if (data != null) {
          print('📋 [getCurrentUserId] Extracted data: $data');

          // ✅ محاولة استخراج الـ ID بطرق مختلفة
          final fetchedId =
              data['_id']?.toString() ??
              data['id']?.toString() ??
              data['userId']?.toString() ??
              data['user_id']?.toString();

          if (fetchedId != null && fetchedId.isNotEmpty) {
            print(
              '✅ [getCurrentUserId] Found ID: ${fetchedId.substring(0, 10)}...',
            );
            await StorageService.saveUserId(fetchedId);
            return fetchedId;
          } else {
            print(
              '❌ [getCurrentUserId] No ID found in data. Available keys: ${data.keys.toList()}',
            );
          }
        } else {
          print('❌ [getCurrentUserId] Could not extract data from response');
        }
      } else {
        final error = result['error'] ?? 'Unknown error';
        debugPrint('❌ RoomController: getLoggedUserData failed - $error');
        print('❌ [getCurrentUserId] API call failed: $error');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ RoomController: Failed to fetch user id: $e');
      print('❌ [getCurrentUserId] Exception: $e');
      print('📚 Stack trace: $stackTrace');
    }

    print('❌ [getCurrentUserId] Returning null');
    return null;
  }

  /// ✅ الحصول على معرف المستخدم الحالي (public method)
  Future<String?> getCurrentUserId() async {
    return await _getCurrentUserId();
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
  /// Route: PUT /api/rooms/:id
  /// الصلاحيات: مالك الروم (owner) أو الأعضاء برتبة editor
  /// الوظيفة: تعديل اسم الروم و/أو وصف الروم
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
        final index = rooms.indexWhere(
          (room) => room['_id']?.toString() == roomId.toString(),
        );
        if (index != -1 && index < rooms.length) {
          rooms[index] = response['room'] as Map<String, dynamic>;
          notifyListeners();
        }
        print('✅ Room updated successfully: ${response['message']}');
        return true;
      }

      setError(response['message'] ?? 'فشل تحديث الغرفة');
      return false;
    } catch (e) {
      final errorMessage = e.toString();
      print('❌ Error updating room: $errorMessage');

      // ✅ تحسين رسالة الخطأ
      if (errorMessage.contains('Only room owner') ||
          errorMessage.contains('editor role')) {
        setError('فقط مالك الغرفة أو الأعضاء برتبة محرر يمكنهم تعديل الغرفة');
      } else if (errorMessage.contains('Room not found')) {
        setError('الغرفة غير موجودة');
      } else if (errorMessage.contains('cannot be empty') ||
          errorMessage.contains('empty')) {
        setError('اسم الغرفة لا يمكن أن يكون فارغاً');
      } else {
        setError(errorMessage.replaceFirst('Exception: ', ''));
      }
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ حذف غرفة

  /// ✅ إرسال دعوة للمستخدم للانضمام للغرفة
  Future<Map<String, dynamic>?> sendInvitation({
    required String roomId,
    required String email,
    String? role,
    bool? canShare,
    String? message,
  }) async {
    setLoading(true);
    setError(null);

    try {
      final response = await _service.sendInvitation(
        roomId: roomId,
        email: email,
        role: role,
        canShare: canShare,
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
        final roomExists = rooms.any(
          (room) => room['_id'] == response['room']['_id'],
        );
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

  /// ✅ تحديث دور عضو في الغرفة
  Future<bool> updateMemberRole({
    required String roomId,
    required String memberId,
    required String role,
    bool? canShare,
  }) async {
    setLoading(true);
    setError(null);

    try {
      final response = await _service.updateMemberRole(
        roomId: roomId,
        memberId: memberId,
        role: role,
        canShare: canShare,
      );

      if (response['room'] != null) {
        // ✅ تحديث الغرفة في القائمة
        final index = rooms.indexWhere(
          (room) => room['_id']?.toString() == roomId.toString(),
        );
        if (index != -1 && index < rooms.length) {
          rooms[index] = response['room'] as Map<String, dynamic>;
          notifyListeners();
        }
        return true;
      }

      setError(response['message'] ?? 'فشل تحديث دور العضو');
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
        final index = rooms.indexWhere(
          (room) => room['_id']?.toString() == roomId.toString(),
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

  /// ✅ حذف غرفة (فقط مالك الغرفة يمكنه حذفها)
  Future<bool> deleteRoom(String roomId) async {
    setLoading(true);
    setError(null);

    try {
      final response = await _service.deleteRoom(roomId);

      if (response['message'] != null) {
        // ✅ إزالة الغرفة من القائمة
        rooms.removeWhere(
          (room) => room['_id']?.toString() == roomId.toString(),
        );
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

  /// ✅ مغادرة غرفة (أي عضو يمكنه مغادرة الغرفة، لكن المالك لا يمكنه)
  Future<bool> leaveRoom(String roomId) async {
    setLoading(true);
    setError(null);

    try {
      final response = await _service.leaveRoom(roomId);

      if (response['message'] != null) {
        // ✅ إزالة الغرفة من القائمة
        rooms.removeWhere(
          (room) => room['_id']?.toString() == roomId.toString(),
        );
        notifyListeners();
        return true;
      }

      setError(response['message'] ?? 'فشل مغادرة الغرفة');
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
    bool isOneTime = false,
    int? expiresInHours,
  }) async {
    setLoading(true);
    setError(null);

    try {
      print(
        '📤 [shareFileWithRoom] Starting - roomId: $roomId, fileId: $fileId, isOneTime: $isOneTime',
      );

      // ✅ التحقق من وجود token أولاً
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        print('❌ [shareFileWithRoom] Token is null or empty');
        setError('لا يمكن تحديد هوية المستخدم. يرجى إعادة تسجيل الدخول.');
        return false;
      }
      print('✅ [shareFileWithRoom] Token exists: ${token.substring(0, 20)}...');

      // ✅ جلب userId - مهم جداً للمشاركة العادية
      print('🔍 [shareFileWithRoom] Fetching userId...');
      final sharedBy = await _getCurrentUserId();

      // ✅ إذا لم نحصل على userId، نرسل null (الباك إند يستخرجه من الـ token)
      if (sharedBy == null) {
        print(
          '⚠️ [shareFileWithRoom] sharedBy is null, but continuing anyway...',
        );
        print(
          'ℹ️ [shareFileWithRoom] Backend should extract userId from token',
        );
      } else {
        print(
          '✅ [shareFileWithRoom] Got userId: ${sharedBy.substring(0, 10)}...',
        );
      }

      Map<String, dynamic> response;

      try {
        if (isOneTime) {
          // ✅ استخدام endpoint المشاركة لمرة واحدة (لا يحتاج sharedBy)
          print('📤 Calling shareFileWithRoomOneTime API...');
          response = await _service.shareFileWithRoomOneTime(
            roomId: roomId,
            fileId: fileId,
            expiresInHours: expiresInHours,
          );
        } else {
          // ✅ استخدام endpoint المشاركة العادية
          print('📤 Calling shareFileWithRoom API...');
          // ✅ إرسال sharedBy حتى لو كان null (الباك إند يستخرجه من token)
          response = await _service.shareFileWithRoom(
            roomId: roomId,
            fileId: fileId,
            sharedBy: sharedBy, // يمكن أن يكون null
          );
        }

        print('📥 API Response: $response');

        // ✅ التحقق من وجود room في الـ response
        if (response['room'] != null) {
          // ✅ تحديث الغرفة في القائمة
          final index = rooms.indexWhere(
            (room) => room['_id']?.toString() == roomId.toString(),
          );
          if (index != -1 && index < rooms.length) {
            rooms[index] = response['room'] as Map<String, dynamic>;
            notifyListeners();
          } else if (index == -1) {
            // ✅ إذا لم تكن الغرفة في القائمة، أضفها
            rooms.insert(0, response['room'] as Map<String, dynamic>);
            notifyListeners();
          }
          print('✅ File shared successfully with room.');
          return true;
        }

        // ✅ إذا لم يكن هناك room، لكن هناك message نجاح، نعتبره نجاح
        final message = response['message']?.toString() ?? '';
        if (message.isNotEmpty &&
            (message.contains('✅') ||
                message.toLowerCase().contains('success') ||
                message.toLowerCase().contains('shared'))) {
          print('✅ File shared successfully with room (message: $message).');
          // ✅ إعادة تحميل بيانات الروم للتأكد من التحديث
          try {
            await getRoomById(roomId);
          } catch (e) {
            print('⚠️ Warning: Failed to reload room details: $e');
            // لا نعتبر هذا خطأ فادح، الملف تمت مشاركته بنجاح
          }
          return true;
        }

        // ✅ التحقق من وجود خطأ في الـ response
        final error =
            response['error']?.toString() ??
            response['message']?.toString() ??
            'فشل مشاركة الملف';

        // ✅ إذا كان الخطأ يتعلق بأن الملف مشارك بالفعل، نعتبره نجاح مع رسالة
        if (error.toLowerCase().contains('already shared') ||
            error.toLowerCase().contains('مشارك بالفعل')) {
          print(
            'ℹ️ [shareFileWithRoom] File already shared - treating as success',
          );
          setError('الملف مشارك بالفعل مع هذه الغرفة');
          // ✅ إعادة تحميل بيانات الروم للتأكد من التحديث
          try {
            await getRoomById(roomId);
          } catch (e) {
            print('⚠️ Warning: Failed to reload room details: $e');
          }
          // ✅ نعتبر هذا نجاح (الملف مشارك بالفعل)
          return true;
        }

        // ✅ إذا كان الخطأ يتعلق بالمصادقة
        if (error.contains('authenticated') ||
            error.contains('token') ||
            error.contains('login') ||
            error.contains('هوية المستخدم')) {
          setError('يرجى إعادة تسجيل الدخول');
        } else {
          setError(error);
        }

        print('❌ Error sharing file with room: $error');
        return false;
      } catch (e) {
        print('❌ Exception in shareFileWithRoom: $e');
        final errorMessage = e.toString();

        // ✅ تحسين رسالة الخطأ
        if (errorMessage.contains('Exception:')) {
          final cleanError = errorMessage.replaceFirst('Exception: ', '');
          setError(cleanError);
        } else if (errorMessage.contains('SocketException') ||
            errorMessage.contains('Failed host lookup')) {
          setError('لا يمكن الاتصال بالسيرفر. تأكد من أن السيرفر يعمل');
        } else {
          setError(errorMessage);
        }
        return false;
      }
    } catch (e) {
      setError(e.toString());
      print('Exception sharing file with room: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ الوصول إلى ملف مشترك لمرة واحدة
  /// ✅ يسجل أن المستخدم الحالي قد فتح الملف (لكل مستخدم مرة واحدة فقط)
  /// ✅ إذا تمت إزالة الملف تلقائياً (allMembersViewed أو fileRemovedFromRoom)، يتم تحديث القائمة
  Future<Map<String, dynamic>> accessOneTimeFile({
    required String roomId,
    required String fileId,
  }) async {
    setLoading(true);
    setError(null);

    try {
      print('Accessing one-time file $fileId in room $roomId');

      final response = await _service.accessOneTimeFile(
        roomId: roomId,
        fileId: fileId,
      );

      // ✅ التحقق من حالة انتهاء الصلاحية أولاً
      if (response['expired'] == true) {
        // ✅ إزالة الملف من القائمة المحلية إذا انتهت صلاحيته
        final roomIndex = rooms.indexWhere(
          (room) => room['_id']?.toString() == roomId.toString(),
        );

        if (roomIndex != -1) {
          final roomFiles = rooms[roomIndex]['files'] as List?;
          if (roomFiles != null) {
            final fileIndex = roomFiles.indexWhere((f) {
              final fId = f['fileId'];
              if (fId is Map) return fId['_id']?.toString() == fileId;
              if (fId is String) return fId == fileId;
              return fId?.toString() == fileId;
            });

            if (fileIndex != -1) {
              roomFiles.removeAt(fileIndex);
              rooms[roomIndex]['files'] = roomFiles;
              notifyListeners();
              print('One-time file removed from room (expired).');
            }
          }
        }

        setError(response['error'] ?? 'File access has expired');
        return response;
      }

      // ✅ التحقق من نجاح الوصول (دعم الحقول الجديدة: oneTime, hideFromThisUser)
      final isOneTime =
          response['oneTime'] == true || response['wasOneTimeShare'] == true;
      // final fileRemovedFromRoom = response['fileRemovedFromRoom'] == true; // قد نحتاجه لاحقاً
      final hideFromThisUser = response['hideFromThisUser'] == true;

      if (response['message'] != null ||
          response['success'] == true ||
          isOneTime) {
        // ✅ تحديث بيانات الملف في القائمة المحلية
        final roomIndex = rooms.indexWhere(
          (room) => room['_id']?.toString() == roomId.toString(),
        );

        if (roomIndex != -1) {
          final roomFiles = rooms[roomIndex]['files'] as List?;
          if (roomFiles != null) {
            final fileIndex = roomFiles.indexWhere((f) {
              final fId = f['fileId'];
              if (fId is Map) return fId['_id']?.toString() == fileId;
              if (fId is String) return fId == fileId;
              return fId?.toString() == fileId;
            });

            // ✅ إذا كان ملف لمرة واحدة وتم تسجيل الوصول
            // ✅ الملف يبقى في Room ولكن سيختفي عند إعادة تحميل البيانات (الباك إند يفلتره)
            if (isOneTime && hideFromThisUser && fileIndex != -1) {
              // ✅ تحديث accessCount من الاستجابة
              final currentFileEntry = Map<String, dynamic>.from(
                roomFiles[fileIndex] as Map<String, dynamic>,
              );

              if (response['accessCount'] != null) {
                currentFileEntry['accessCount'] = response['accessCount'];
              }

              // ✅ تحديث fileId إذا كان file متوفراً في الاستجابة
              if (response['file'] != null) {
                final fileFromResponse =
                    response['file'] as Map<String, dynamic>;
                currentFileEntry['fileId'] = fileFromResponse;
              }

              roomFiles[fileIndex] = currentFileEntry;
              rooms[roomIndex]['files'] = roomFiles;
              notifyListeners();
              print(
                '✅ One-time file accessed (will be hidden from user on next room reload).',
              );
            }
            // ✅ إذا كان ملف عادي
            else if (fileIndex != -1 && !isOneTime) {
              // ✅ تحديث بيانات الملف العادي
              if (response['file'] != null) {
                final currentFileEntry = Map<String, dynamic>.from(
                  roomFiles[fileIndex] as Map<String, dynamic>,
                );
                final fileFromResponse =
                    response['file'] as Map<String, dynamic>;
                currentFileEntry['fileId'] = fileFromResponse;
                roomFiles[fileIndex] = currentFileEntry;
                rooms[roomIndex]['files'] = roomFiles;
                notifyListeners();
              }
            }
          }
        }

        return response;
      }

      setError(
        response['message'] ?? response['error'] ?? 'فشل الوصول إلى الملف',
      );
      return response;
    } catch (e) {
      setError(e.toString());
      print('Exception accessing one-time file: $e');
      return {'success': false, 'error': e.toString()};
    } finally {
      setLoading(false);
    }
  }

  /// ✅ إزالة ملف من الغرفة
  Future<bool> unshareFileFromRoom({
    required String roomId,
    required String fileId,
  }) async {
    setLoading(true);
    setError(null);

    try {
      final response = await _service.unshareFileFromRoom(
        roomId: roomId,
        fileId: fileId,
      );

      if (response['room'] != null || response['message'] != null) {
        // ✅ تحديث الغرفة في القائمة
        final index = rooms.indexWhere(
          (room) => room['_id']?.toString() == roomId.toString(),
        );
        if (index != -1 && index < rooms.length) {
          rooms[index] =
              response['room'] as Map<String, dynamic>? ?? rooms[index];
          notifyListeners();
        }
        return true;
      }

      setError(response['message'] ?? 'فشل إزالة الملف من الغرفة');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ إزالة مجلد من الغرفة
  Future<bool> unshareFolderFromRoom({
    required String roomId,
    required String folderId,
  }) async {
    setLoading(true);
    setError(null);

    try {
      final response = await _service.unshareFolderFromRoom(
        roomId: roomId,
        folderId: folderId,
      );

      if (response['room'] != null || response['message'] != null) {
        // ✅ تحديث الغرفة في القائمة
        final index = rooms.indexWhere(
          (room) => room['_id']?.toString() == roomId.toString(),
        );
        if (index != -1 && index < rooms.length) {
          rooms[index] =
              response['room'] as Map<String, dynamic>? ?? rooms[index];
          notifyListeners();
        }
        return true;
      }

      setError(response['message'] ?? 'فشل إزالة المجلد من الغرفة');
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
      final sharedBy = await _getCurrentUserId();
      if (sharedBy == null) {
        setError('لا يمكن تحديد هوية المستخدم. يرجى إعادة تسجيل الدخول.');
        return false;
      }

      final response = await _service.shareFolderWithRoom(
        roomId: roomId,
        folderId: folderId,
        sharedBy: sharedBy,
      );

      if (response['room'] != null) {
        // ✅ تحديث الغرفة في القائمة
        final index = rooms.indexWhere(
          (room) => room['_id']?.toString() == roomId.toString(),
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
    required String targetType, // 'file', 'folder', أو 'room'
    String? targetId,
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
    required String targetType, // 'file', 'folder', أو 'room'
    String? targetId,
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

  /// ✅ حفظ ملف من الغرفة إلى حساب المستخدم
  Future<bool> saveFileFromRoom({
    required String roomId,
    required String fileId,
    String? parentFolderId,
  }) async {
    setLoading(true);
    setError(null);

    try {
      final response = await _service.saveFileFromRoom(
        roomId: roomId,
        fileId: fileId,
        parentFolderId: parentFolderId,
      );

      if (response['message'] != null) {
        return true;
      }

      setError(response['message'] ?? 'فشل حفظ الملف');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ حفظ مجلد من الغرفة إلى حساب المستخدم
  Future<bool> saveFolderFromRoom({
    required String roomId,
    required String folderId,
    String? parentFolderId,
  }) async {
    setLoading(true);
    setError(null);

    try {
      final response = await _service.saveFolderFromRoom(
        roomId: roomId,
        folderId: folderId,
        parentFolderId: parentFolderId,
      );

      if (response['message'] != null) {
        return true;
      }

      setError(response['message'] ?? 'فشل حفظ المجلد');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ تحميل ملف مشترك في الروم
  Future<Map<String, dynamic>> downloadRoomFile({
    required String roomId,
    required String fileId,
    String? fileName,
  }) async {
    try {
      setLoading(true);
      setError(null);

      final result = await _service.downloadRoomFile(
        roomId: roomId,
        fileId: fileId,
        fileName: fileName,
      );

      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  /// ✅ تحميل مجلد مشترك في الروم
  Future<Map<String, dynamic>> downloadRoomFolder({
    required String roomId,
    required String folderId,
    String? folderName,
  }) async {
    try {
      setLoading(true);
      setError(null);

      final result = await _service.downloadRoomFolder(
        roomId: roomId,
        folderId: folderId,
        folderName: folderName,
      );

      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }
}
