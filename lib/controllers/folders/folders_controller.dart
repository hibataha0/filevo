import 'package:filevo/services/folders_service.dart';
import 'package:filevo/controllers/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FolderController with ChangeNotifier {
  final FolderService _service = FolderService();

  bool isLoading = false;
  String? errorMessage;
  bool _isDisposed = false;
  
  // ✅ context للوصول إلى ProfileController
  BuildContext? _context;
  
  void setContext(BuildContext context) {
    _context = context;
  }

  // ✅ Deleted folders list
  List<Map<String, dynamic>> _trashFolders = [];
  List<Map<String, dynamic>> get trashFolders => _trashFolders;

  // ✅ Starred folders list
  List<Map<String, dynamic>> _starredFolders = [];
  List<Map<String, dynamic>> get starredFolders => _starredFolders;

  // ✅ Page information (pagination)
  Map<String, dynamic> _pagination = {};
  Map<String, dynamic> get pagination => _pagination;

  // ✅ Starred folders page information
  Map<String, dynamic> _starredPagination = {};
  Map<String, dynamic> get starredPagination => _starredPagination;

  int _currentPage = 1;
  bool _hasMore = true;

  // ✅ Pagination variables for starred folders
  int _starredCurrentPage = 1;
  bool _starredHasMore = true;

  // ✅ Refresh trigger for updating views
  int _refreshTrigger = 0;
  int get refreshTrigger => _refreshTrigger;

  void triggerRefresh() {
    _refreshTrigger++;
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (_isDisposed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) notifyListeners();
    });
  }

  void setLoading(bool value) {
    isLoading = value;
    _safeNotifyListeners();
  }

  Future<bool> createFolder({required String name, String? parentId}) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.createFolder(
        name: name,
        parentId: parentId,
      );

      if (response['folder'] != null) {
        return true;
      }

      errorMessage = response['message'] ?? 'Failed to create folder';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> uploadFolder({
    required String folderName,
    required List<Map<String, dynamic>> filesData,
    required List<String> relativePaths,
    String? parentFolderId,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      print('🔄 FolderController: Starting upload...');
      final response = await _service.uploadFolder(
        folderName: folderName,
        filesData: filesData,
        relativePaths: relativePaths,
        parentFolderId: parentFolderId,
      );

      print('✅ FolderController: Upload successful, response: $response');
      if (response['success'] == false) {
        errorMessage = response['message']?.toString();
      }
      return response;
    } catch (e, stackTrace) {
      print('❌ FolderController: Upload failed');
      print('❌ Error: $e');
      print('❌ Stack trace: $stackTrace');
      errorMessage = e.toString();
      print('❌ FolderController: Error message set: $errorMessage');
      return null;
    } finally {
      setLoading(false);
      print('🔄 FolderController: Upload completed, isLoading: $isLoading');
    }
  }

  // ✅ Get all folders without parent
  Future<Map<String, dynamic>?> getAllFolders({
    int page = 1,
    int limit = 10,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.getAllFolders(page: page, limit: limit);
      return response;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      setLoading(false);
    }
  }

  // ✅ Get contents of a specific folder
  Future<Map<String, dynamic>?> getFolderContents({
    required String folderId,
    int page = 1,
    int limit = 20,
    String? roomId, // ✅ معامل اختياري للغرفة
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.getFolderContents(
        folderId: folderId,
        page: page,
        limit: limit,
        roomId: roomId, // ✅ تمرير roomId
      );
      return response;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      setLoading(false);
    }
  }

  // ✅ Get all items (folders + files) without parent
  Future<Map<String, dynamic>?> getAllItems({
    int page = 1,
    int limit = 20,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.getAllItems(page: page, limit: limit);
      return response;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      setLoading(false);
    }
  }

  // ✅ Update folder
  Future<bool> updateFolder({
    required String folderId,
    String? name,
    String? description,
    List<String>? tags,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.updateFolder(
        folderId: folderId,
        name: name,
        description: description,
        tags: tags,
      );

      if (response['folder'] != null) {
        return true;
      }

      errorMessage = response['message'] ?? 'Failed to update folder';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ✅ Move folder from one folder to another
  Future<bool> moveFolder({
    required String folderId,
    String? targetFolderId, // null for root or folderId for folder
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.moveFolder(
        folderId: folderId,
        targetFolderId: targetFolderId,
      );

      if (response['folder'] != null || response['message'] != null) {
        return true;
      }

      errorMessage = response['message'] ?? 'Failed to move folder';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ✅ Get folder details
  Future<Map<String, dynamic>?> getFolderDetails({
    required String folderId,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.getFolderDetails(folderId: folderId);
      return response;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> getSharedFolderDetailsInRoom({
    required String folderId,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.getSharedFolderDetailsInRoom(
        folderId: folderId,
      );
      return response;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      setLoading(false);
    }
  }


  // ✅ Share folder with users
  Future<bool> shareFolder({
    required String folderId,
    required List<String> userIds,
    required String permission,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.shareFolder(
        folderId: folderId,
        userIds: userIds,
        permission: permission,
      );

      if (response['folder'] != null) {
        return true;
      }

      errorMessage = response['message'] ?? 'Failed to share folder';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ✅ Update folder sharing permissions
  Future<bool> updateFolderPermissions({
    required String folderId,
    required List<Map<String, dynamic>> userPermissions,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.updateFolderPermissions(
        folderId: folderId,
        userPermissions: userPermissions,
      );

      if (response['folder'] != null) {
        return true;
      }

      errorMessage = response['message'] ?? 'Failed to update permissions';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ✅ Unshare folder
  Future<bool> unshareFolder({
    required String folderId,
    required List<String> userIds,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.unshareFolder(
        folderId: folderId,
        userIds: userIds,
      );

      if (response['folder'] != null || response['message'] != null) {
        return true;
      }

      errorMessage = response['message'] ?? 'Failed to unshare folder';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ✅ Get folders shared with me
  Future<Map<String, dynamic>?> getFoldersSharedWithMe({
    int page = 1,
    int limit = 10,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.getFoldersSharedWithMe(
        page: page,
        limit: limit,
      );
      return response;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      setLoading(false);
    }
  }

  // ✅ Delete folder (soft delete)
  /// Returns: Map with 'success', 'warning', and 'roomsRemovedFrom' if successful
  Future<Map<String, dynamic>> deleteFolder({required String folderId}) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.deleteFolder(folderId: folderId);
      if (response['message'] != null || response['folder'] != null) {
        return {
          'success': true,
          'message': response['message'],
          'warning': response['warning'],
          'roomsRemovedFrom': response['roomsRemovedFrom'] ?? [],
        };
      }
      errorMessage = response['message'] ?? 'Failed to delete folder';
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to delete folder',
      };
    } catch (e) {
      errorMessage = e.toString();
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      setLoading(false);
    }
  }

  // ✅ Restore folder from trash
  /// Returns: Map with 'success', 'filesRestored' count, and 'message' if successful
  Future<Map<String, dynamic>> restoreFolder({required String folderId}) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.restoreFolder(folderId: folderId);
      if (response['message'] != null || response['folder'] != null) {
        // ✅ تحديث معلومات المساحة بعد الاستعادة
        _refreshStorageInfo();
        return {
          'success': true,
          'message': response['message'] ?? 'Folder restored successfully',
          'filesRestored': response['filesRestored'] ?? 0,
          'folder': response['folder'],
        };
      }
      errorMessage = response['message'] ?? 'Failed to restore folder';
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      errorMessage = e.toString();
      return {
        'success': false,
        'message': errorMessage,
      };
    } finally {
      setLoading(false);
    }
  }

  // ✅ Permanently delete folder
  /// Returns: Map with 'success', 'warning', and 'roomsRemovedFrom' if successful
  Future<Map<String, dynamic>> deleteFolderPermanent({required String folderId}) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.deleteFolderPermanent(folderId: folderId);
      if (response['message'] != null) {
        // ✅ تحديث معلومات المساحة بعد الحذف النهائي
        _refreshStorageInfo();
        return {
          'success': true,
          'message': response['message'],
          'warning': response['warning'],
          'roomsRemovedFrom': response['roomsRemovedFrom'] ?? [],
        };
      }
      errorMessage =
          response['message'] ?? 'Failed to permanently delete folder';
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to permanently delete folder',
      };
    } catch (e) {
      errorMessage = e.toString();
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      setLoading(false);
    }
  }

  /// ✅ تحديث معلومات المساحة التخزينية (بدون loading state)
  Future<void> _refreshStorageInfo() async {
    try {
      if (_context != null) {
        final profileController = Provider.of<ProfileController>(
          _context!,
          listen: false,
        );
        profileController.getStorageInfo(forceRefresh: true);
        print('✅ [FolderController] Storage info refreshed');
      }
    } catch (e) {
      print('⚠️ [FolderController] Error refreshing storage info: $e');
    }
  }

  // ✅ Get deleted folders (trash)
  Future<void> getTrashFolders({int page = 1, bool loadMore = false}) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      setLoading(true);
    } else {
      if (!_hasMore || isLoading) return;
      _currentPage++;
    }

    errorMessage = null;

    try {
      final response = await _service.getTrashFolders(
        page: _currentPage,
        limit: 20,
      );

      if (response['folders'] != null) {
        final List<Map<String, dynamic>> newFolders =
            List<Map<String, dynamic>>.from(response['folders'] ?? []);
        final pagination = Map<String, dynamic>.from(
          response['pagination'] ?? {},
        );

        if (loadMore) {
          _trashFolders.addAll(newFolders);
        } else {
          _trashFolders = newFolders;
        }

        // ✅ استخدام pagination من الـ response
        _pagination = pagination;
        final totalPages = pagination['totalPages'] ?? 1;
        _hasMore = _currentPage < totalPages;

        _safeNotifyListeners();
      } else {
        errorMessage = response['message'] ?? 'Failed to fetch deleted folders';
        if (!loadMore) {
          _trashFolders = [];
          _safeNotifyListeners();
        }
      }
    } catch (e) {
      errorMessage = 'Error fetching deleted folders: ${e.toString()}';
      if (!loadMore) {
        _trashFolders = [];
        _safeNotifyListeners();
      }
    } finally {
      setLoading(false);
    }
  }

  // ✅ Clean expired folders
  Future<bool> cleanExpiredFolders() async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.cleanExpiredFolders();
      if (response['message'] != null) {
        return true;
      }
      errorMessage = response['message'] ?? 'Failed to clean expired folders';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ✅ Add/remove star from folder
  Future<Map<String, dynamic>> toggleStarFolder({
    required String folderId,
  }) async {
    // ✅ Don't use setLoading because this is a simple update that doesn't need page refresh
    errorMessage = null;

    try {
      final response = await _service.toggleStarFolder(folderId: folderId);
      if (response['folder'] != null) {
        final updatedFolder = Map<String, dynamic>.from(response['folder']);
        final isStarred = updatedFolder['isStarred'] ?? false;

        // ✅ Immediately update starred list
        final existingIndex = _starredFolders.indexWhere(
          (f) => f['_id'] == folderId,
        );

        if (isStarred) {
          // ✅ If added to starred, add to list if not exists
          if (existingIndex == -1) {
            _starredFolders.insert(0, updatedFolder); // ✅ Add at the beginning
          } else {
            // ✅ Update existing folder
            _starredFolders[existingIndex] = updatedFolder;
          }
        } else {
          // ✅ If removed from starred, delete from list
          if (existingIndex != -1) {
            _starredFolders.removeAt(existingIndex);
          }
        }

        _safeNotifyListeners();
        return {
          'success': true,
          'isStarred': isStarred,
          'folder': updatedFolder,
        };
      }
      errorMessage = response['message'] ?? 'Failed to update starred status';
      return {'success': false, 'isStarred': false, 'message': errorMessage};
    } catch (e) {
      errorMessage = e.toString();
      return {'success': false, 'isStarred': false, 'message': errorMessage};
    }
  }

  // ✅ Get starred folders
  Future<void> getStarredFolders({
    int page = 1,
    int limit = 20,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      _starredCurrentPage = 1;
      _starredHasMore = true;
      setLoading(true);
    } else {
      if (!_starredHasMore || isLoading) return;
      _starredCurrentPage++;
    }

    errorMessage = null;

    try {
      final response = await _service.getStarredFolders(
        page: _starredCurrentPage,
        limit: limit,
      );

      if (response['folders'] != null) {
        final List<Map<String, dynamic>> newFolders =
            List<Map<String, dynamic>>.from(response['folders'] ?? []);

        // Update page information if available
        if (response['pagination'] != null) {
          _starredPagination = Map<String, dynamic>.from(
            response['pagination'],
          );
          final totalPages = _starredPagination['totalPages'] ?? 1;
          _starredHasMore = _starredCurrentPage < totalPages;
        } else {
          // If pagination not available, determine based on result count
          _starredHasMore = newFolders.length >= limit;
          _starredPagination = {
            'currentPage': _starredCurrentPage,
            'hasNext': _starredHasMore,
          };
        }

        if (loadMore) {
          _starredFolders.addAll(newFolders);
        } else {
          _starredFolders = newFolders;
        }

        _safeNotifyListeners();
      } else {
        errorMessage = response['message'] ?? 'Failed to fetch starred folders';
        if (!loadMore) {
          _starredFolders = [];
          _safeNotifyListeners();
        }
      }
    } catch (e) {
      errorMessage = 'Error fetching starred folders: ${e.toString()}';
      if (!loadMore) {
        _starredFolders = [];
        _safeNotifyListeners();
      }
    } finally {
      setLoading(false);
    }
  }

  // ✅ Calculate folder size
  Future<Map<String, dynamic>?> getFolderSize({
    required String folderId,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.getFolderSize(folderId: folderId);
      return response;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      setLoading(false);
    }
  }

  // ✅ Calculate file count in a folder
  Future<Map<String, dynamic>?> getFolderFilesCount({
    required String folderId,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.getFolderFilesCount(folderId: folderId);
      return response;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      setLoading(false);
    }
  }

  // ✅ Calculate folder statistics (size + file count) - more efficient
  Future<Map<String, dynamic>?> getFolderStats({
    required String folderId,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.getFolderStats(folderId: folderId);
      return response;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      setLoading(false);
    }
  }

  // ============================================
  // 🔒 Folder Protection Controller Methods
  // ============================================

  /// 🔒 Enable folder protection (password or biometric)
  Future<bool> protectFolder({
    required String folderId,
    required String protectionType, // password | biometric
    String? password,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.protectFolder(
        folderId: folderId,
        protectionType: protectionType,
        password: password,
      );

      if (response['message'] != null) {
        return true;
      }

      errorMessage =
          response['message'] ?? 'Failed to enable folder protection';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// 🔐 Verify access to protected folder (password or biometric)
  Future<bool> verifyFolderAccess({
    required String folderId,
    String? password,
    String? biometricToken,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.verifyFolderAccess(
        folderId: folderId,
        password: password,
        biometricToken: biometricToken,
      );

      print('🔐 [FolderController] verifyFolderAccess response: $response');

      if (response['hasAccess'] == true) {
        // ✅ If there's a session token, save it for future requests
        if (response['sessionToken'] != null) {
          // Can save session token here if needed
          print(
            '✅ [FolderController] Session token received: ${response['sessionToken']}',
          );
        }
        return true;
      }

      errorMessage = response['message'] ?? 'Failed to verify access';
      return false;
    } catch (e) {
      print('❌ [FolderController] verifyFolderAccess error: $e');
      errorMessage = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ❌ Remove folder protection
  Future<bool> removeFolderProtection({
    required String folderId,
    String? password, // Required if protection is password
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.removeFolderProtection(
        folderId: folderId,
        password: password,
      );

      if (response['message'] != null) {
        return true;
      }

      errorMessage =
          response['message'] ?? 'Failed to remove folder protection';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }
}
