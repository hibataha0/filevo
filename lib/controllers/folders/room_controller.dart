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

    // ✅ Try to get ID from cache first
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
          // ✅ Try to extract data from 'user' first
          if (rawData['user'] is Map<String, dynamic>) {
            data = Map<String, dynamic>.from(rawData['user'] as Map);
            print('✅ [getCurrentUserId] Found user in rawData[\'user\']');
          }
          // ✅ If there's 'data' inside rawData (e.g., {data: {_id: ...}})
          else if (rawData['data'] is Map<String, dynamic>) {
            data = Map<String, dynamic>.from(rawData['data'] as Map);
            print('✅ [getCurrentUserId] Found data in rawData[\'data\']');
          }
          // ✅ If there's no 'user' or 'data', use rawData directly
          else {
            data = rawData;
            print('✅ [getCurrentUserId] Using rawData directly');
          }
        } else if (rawData != null) {
          // ✅ If rawData is not a Map, try to convert it
          print(
            '⚠️ [getCurrentUserId] rawData is not Map, type: ${rawData.runtimeType}',
          );
        }

        if (data != null) {
          print('📋 [getCurrentUserId] Extracted data: $data');

          // ✅ Try to extract ID using different methods
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

  /// ✅ Get current user ID (public method)
  Future<String?> getCurrentUserId() async {
    return await _getCurrentUserId();
  }

  /// ✅ Create new sharing room
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
        // ✅ Add new room to the list
        rooms.insert(0, response['room']);
        notifyListeners();
        return response;
      }

      setError(response['message'] ?? 'Failed to create room');
      return null;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Get all rooms
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

      setError(response['message'] ?? 'Failed to load rooms');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Get details of a specific room
  Future<Map<String, dynamic>?> getRoomById(String roomId) async {
    setLoading(true);
    setError(null);

    try {
      final response = await _service.getRoomById(roomId);

      if (response['room'] != null) {
        return response;
      }

      setError(response['message'] ?? 'Failed to load room details');
      return null;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Update room
  /// Route: PUT /api/rooms/:id
  /// Permissions: Room owner or members with editor role
  /// Function: Modify room name and/or description
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
        // ✅ Update room in the list
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

      setError(response['message'] ?? 'Failed to update room');
      return false;
    } catch (e) {
      final errorMessage = e.toString();
      print('❌ Error updating room: $errorMessage');

      // ✅ Improve error message
      if (errorMessage.contains('Only room owner') ||
          errorMessage.contains('editor role')) {
        setError(
          'Only room owner or members with editor role can modify the room',
        );
      } else if (errorMessage.contains('Room not found')) {
        setError('Room not found');
      } else if (errorMessage.contains('cannot be empty') ||
          errorMessage.contains('empty')) {
        setError('Room name cannot be empty');
      } else {
        setError(errorMessage.replaceFirst('Exception: ', ''));
      }
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Delete room

  /// ✅ Send invitation to user to join room
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

      setError(response['message'] ?? 'Failed to send invitation');
      return null;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Accept invitation to join room
  Future<Map<String, dynamic>?> acceptInvitation(String invitationId) async {
    setLoading(true);
    setError(null);

    try {
      final response = await _service.acceptInvitation(invitationId);

      if (response['room'] != null) {
        // ✅ Add new room to the list
        final roomExists = rooms.any(
          (room) => room['_id'] == response['room']['_id'],
        );
        if (!roomExists) {
          rooms.insert(0, response['room']);
          notifyListeners();
        }
        return response;
      }

      setError(response['message'] ?? 'Failed to accept invitation');
      return null;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Reject invitation to join room
  Future<bool> rejectInvitation(String invitationId) async {
    setLoading(true);
    setError(null);

    try {
      final response = await _service.rejectInvitation(invitationId);

      if (response['invitation'] != null) {
        return true;
      }

      setError(response['message'] ?? 'Failed to reject invitation');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Get pending invitations
  Future<List<Map<String, dynamic>>> getPendingInvitations() async {
    setLoading(true);
    setError(null);

    try {
      final response = await _service.getPendingInvitations();

      if (response['invitations'] != null) {
        return List<Map<String, dynamic>>.from(response['invitations']);
      }

      setError(response['message'] ?? 'Failed to load invitations');
      return [];
    } catch (e) {
      setError(e.toString());
      return [];
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Update member role in room
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
        // ✅ Update room in the list
        final index = rooms.indexWhere(
          (room) => room['_id']?.toString() == roomId.toString(),
        );
        if (index != -1 && index < rooms.length) {
          rooms[index] = response['room'] as Map<String, dynamic>;
          notifyListeners();
        }
        return true;
      }

      setError(response['message'] ?? 'Failed to update member role');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Remove member from room
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
        // ✅ Update room in the list
        final index = rooms.indexWhere(
          (room) => room['_id']?.toString() == roomId.toString(),
        );
        if (index != -1 && index < rooms.length) {
          rooms[index] = response['room'] as Map<String, dynamic>;
          notifyListeners();
        }
        return true;
      }

      setError(response['message'] ?? 'Failed to remove member');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Delete room (only room owner can delete)
  Future<bool> deleteRoom(String roomId) async {
    setLoading(true);
    setError(null);

    try {
      final response = await _service.deleteRoom(roomId);

      if (response['message'] != null) {
        // ✅ Remove room from the list
        rooms.removeWhere(
          (room) => room['_id']?.toString() == roomId.toString(),
        );
        notifyListeners();
        return true;
      }

      setError(response['message'] ?? 'Failed to delete room');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Leave room (any member can leave, but owner cannot)
  /// ✅ Returns: Map with 'success' and 'details' (filesRemoved, foldersRemoved)
  Future<Map<String, dynamic>> leaveRoom(String roomId) async {
    setLoading(true);
    setError(null);

    try {
      final response = await _service.leaveRoom(roomId);

      if (response['message'] != null) {
        // ✅ Remove room from the list
        rooms.removeWhere(
          (room) => room['_id']?.toString() == roomId.toString(),
        );
        notifyListeners();
        
        // ✅ إرجاع النتيجة مع التفاصيل (عدد الملفات والمجلدات المحذوفة)
        return {
          'success': true,
          'message': response['message'],
          'details': response['details'] ?? {
            'filesRemoved': 0,
            'foldersRemoved': 0,
          },
        };
      }

      setError(response['message'] ?? 'Failed to leave room');
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to leave room',
        'details': {'filesRemoved': 0, 'foldersRemoved': 0},
      };
    } catch (e) {
      setError(e.toString());
      return {
        'success': false,
        'message': e.toString(),
        'details': {'filesRemoved': 0, 'foldersRemoved': 0},
      };
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Share file with room
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

      // ✅ Check if token exists first
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        print('❌ [shareFileWithRoom] Token is null or empty');
        setError('Cannot determine user identity. Please log in again.');
        return false;
      }
      print('✅ [shareFileWithRoom] Token exists: ${token.substring(0, 20)}...');

      // ✅ Get userId - very important for regular sharing
      print('🔍 [shareFileWithRoom] Fetching userId...');
      final sharedBy = await _getCurrentUserId();

      // ✅ If we don't get userId, send null (backend extracts it from token)
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
          // ✅ Use one-time sharing endpoint (doesn't need sharedBy)
          print('📤 Calling shareFileWithRoomOneTime API...');
          response = await _service.shareFileWithRoomOneTime(
            roomId: roomId,
            fileId: fileId,
            expiresInHours: expiresInHours,
          );
        } else {
          // ✅ Use regular sharing endpoint
          print('📤 Calling shareFileWithRoom API...');
          // ✅ Send sharedBy even if null (backend extracts it from token)
          response = await _service.shareFileWithRoom(
            roomId: roomId,
            fileId: fileId,
            sharedBy: sharedBy, // can be null
          );
        }

        print('📥 API Response: $response');

        // ✅ Check if room exists in response
        if (response['room'] != null) {
          // ✅ Update room in the list
          final index = rooms.indexWhere(
            (room) => room['_id']?.toString() == roomId.toString(),
          );
          if (index != -1 && index < rooms.length) {
            rooms[index] = response['room'] as Map<String, dynamic>;
            notifyListeners();
          } else if (index == -1) {
            // ✅ If room not in list, add it
            rooms.insert(0, response['room'] as Map<String, dynamic>);
            notifyListeners();
          }
          print('✅ File shared successfully with room.');
          return true;
        }

        // ✅ If no room but there's success message, consider it success
        final message = response['message']?.toString() ?? '';
        if (message.isNotEmpty &&
            (message.contains('✅') ||
                message.toLowerCase().contains('success') ||
                message.toLowerCase().contains('shared'))) {
          print('✅ File shared successfully with room (message: $message).');
          // ✅ Reload room data to ensure update
          try {
            await getRoomById(roomId);
          } catch (e) {
            print('⚠️ Warning: Failed to reload room details: $e');
            // Don't consider this a critical error, file was shared successfully
          }
          return true;
        }

        // ✅ Check for error in response
        final error =
            response['error']?.toString() ??
            response['message']?.toString() ??
            'Failed to share file';

        // ✅ If error is about file already being shared, consider it success with message
        if (error.toLowerCase().contains('already shared') ||
            error.toLowerCase().contains('مشارك بالفعل')) {
          print(
            'ℹ️ [shareFileWithRoom] File already shared - treating as success',
          );
          setError('File already shared with this room');
          // ✅ Reload room data to ensure update
          try {
            await getRoomById(roomId);
          } catch (e) {
            print('⚠️ Warning: Failed to reload room details: $e');
          }
          // ✅ Consider this success (file already shared)
          return true;
        }

        // ✅ If error is about authentication
        if (error.contains('authenticated') ||
            error.contains('token') ||
            error.contains('login') ||
            error.contains('user identity')) {
          setError('Please log in again');
        } else {
          setError(error);
        }

        print('❌ Error sharing file with room: $error');
        return false;
      } catch (e) {
        print('❌ Exception in shareFileWithRoom: $e');
        final errorMessage = e.toString();

        // ✅ Improve error message
        if (errorMessage.contains('Exception:')) {
          final cleanError = errorMessage.replaceFirst('Exception: ', '');
          setError(cleanError);
        } else if (errorMessage.contains('SocketException') ||
            errorMessage.contains('Failed host lookup')) {
          setError('Cannot connect to server. Make sure server is running');
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

  /// ✅ Access one-time shared file
  /// ✅ Records that current user has opened the file (only once per user)
  /// ✅ If file is automatically removed (allMembersViewed or fileRemovedFromRoom), list is updated
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

      // ✅ Check expiration status first
      if (response['expired'] == true) {
        // ✅ Remove file from local list if expired
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

      // ✅ Check access success (support new fields: oneTime, hideFromThisUser)
      final isOneTime =
          response['oneTime'] == true || response['wasOneTimeShare'] == true;
      // final fileRemovedFromRoom = response['fileRemovedFromRoom'] == true; // Might need later
      final hideFromThisUser = response['hideFromThisUser'] == true;

      if (response['message'] != null ||
          response['success'] == true ||
          isOneTime) {
        // ✅ Update file data in local list
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

            // ✅ If it's a one-time file and access was recorded
            // ✅ File stays in Room but will disappear when data is reloaded (backend filters it)
            if (isOneTime && hideFromThisUser && fileIndex != -1) {
              // ✅ Update accessCount from response
              final currentFileEntry = Map<String, dynamic>.from(
                roomFiles[fileIndex] as Map<String, dynamic>,
              );

              if (response['accessCount'] != null) {
                currentFileEntry['accessCount'] = response['accessCount'];
              }

              // ✅ Update fileId if file is available in response
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
            // ✅ If it's a regular file
            else if (fileIndex != -1 && !isOneTime) {
              // ✅ Update regular file data
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
        response['message'] ?? response['error'] ?? 'Failed to access file',
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

  /// ✅ Remove file from room
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
        // ✅ Update room in the list
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

      setError(response['message'] ?? 'Failed to remove file from room');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Remove folder from room
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
        // ✅ Update room in the list
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

      setError(response['message'] ?? 'Failed to remove folder from room');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Share folder with room
  Future<bool> shareFolderWithRoom({
    required String roomId,
    required String folderId,
  }) async {
    setLoading(true);
    setError(null);

    try {
      final sharedBy = await _getCurrentUserId();
      if (sharedBy == null) {
        setError('Cannot determine user identity. Please log in again.');
        return false;
      }

      final response = await _service.shareFolderWithRoom(
        roomId: roomId,
        folderId: folderId,
        sharedBy: sharedBy,
      );

      if (response['room'] != null) {
        // ✅ Update room in the list
        final index = rooms.indexWhere(
          (room) => room['_id']?.toString() == roomId.toString(),
        );
        if (index != -1 && index < rooms.length) {
          rooms[index] = response['room'] as Map<String, dynamic>;
          notifyListeners();
        }
        return true;
      }

      setError(response['message'] ?? 'Failed to share folder');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Add comment on file/folder in room
  Future<Map<String, dynamic>?> addComment({
    required String roomId,
    required String targetType, // 'file', 'folder', or 'room'
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

      setError(response['message'] ?? 'Failed to add comment');
      return null;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Get comments of file/folder in room
  Future<List<Map<String, dynamic>>> listComments({
    required String roomId,
    required String targetType, // 'file', 'folder', or 'room'
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

      setError(response['message'] ?? 'Failed to load comments');
      return [];
    } catch (e) {
      setError(e.toString());
      return [];
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Delete comment
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

      setError(response['message'] ?? 'Failed to delete comment');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Clean up old invitations
  Future<int?> cleanupOldInvitations() async {
    setLoading(true);
    setError(null);

    try {
      final response = await _service.cleanupOldInvitations();

      if (response['deletedCount'] != null) {
        return response['deletedCount'] as int;
      }

      setError(response['message'] ?? 'Failed to clean invitations');
      return null;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Get invitation statistics
  Future<Map<String, dynamic>?> getInvitationStats() async {
    setLoading(true);
    setError(null);

    try {
      final response = await _service.getInvitationStats();

      if (response['stats'] != null) {
        return response['stats'];
      }

      setError(response['message'] ?? 'Failed to load statistics');
      return null;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Save file from room to user account
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

      setError(response['message'] ?? 'Failed to save file');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Save folder from room to user account
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

      setError(response['message'] ?? 'Failed to save folder');
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Download shared file in room
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

  /// ✅ Download shared folder in room
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
