import 'dart:io';
import 'package:filevo/services/folders_service.dart';
import 'package:flutter/material.dart';

class FolderController with ChangeNotifier {
  final FolderService _service = FolderService();

  bool isLoading = false;
  String? errorMessage;
  bool _isDisposed = false;
  
  // ✅ قائمة المجلدات المحذوفة
  List<Map<String, dynamic>> _trashFolders = [];
  List<Map<String, dynamic>> get trashFolders => _trashFolders;
  
  // ✅ قائمة المجلدات المفضلة
  List<Map<String, dynamic>> _starredFolders = [];
  List<Map<String, dynamic>> get starredFolders => _starredFolders;
  
  // ✅ معلومات الصفحة (pagination)
  Map<String, dynamic> _pagination = {};
  Map<String, dynamic> get pagination => _pagination;
  
  // ✅ معلومات الصفحة للمجلدات المفضلة
  Map<String, dynamic> _starredPagination = {};
  Map<String, dynamic> get starredPagination => _starredPagination;
  
  int _currentPage = 1;
  bool _hasMore = true;
  
  // ✅ متغيرات pagination للمجلدات المفضلة
  int _starredCurrentPage = 1;
  bool _starredHasMore = true;

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

  Future<bool> createFolder({
    required String name,
    String? parentId,
  }) async {
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

      errorMessage = response['message'] ?? 'فشل إنشاء المجلد';
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

  // ✅ جلب جميع المجلدات بدون parent
  Future<Map<String, dynamic>?> getAllFolders({
    int page = 1,
    int limit = 10,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.getAllFolders(
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

  // ✅ جلب محتويات مجلد معين
  Future<Map<String, dynamic>?> getFolderContents({
    required String folderId,
    int page = 1,
    int limit = 20,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.getFolderContents(
        folderId: folderId,
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

  // ✅ جلب جميع العناصر (folders + files) بدون parent
  Future<Map<String, dynamic>?> getAllItems({
    int page = 1,
    int limit = 20,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.getAllItems(
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

  // ✅ تحديث مجلد
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

      errorMessage = response['message'] ?? 'فشل تحديث المجلد';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ✅ نقل مجلد من مجلد إلى آخر
  Future<bool> moveFolder({
    required String folderId,
    String? targetFolderId, // null للجذر أو folderId للمجلد
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

      errorMessage = response['message'] ?? 'فشل نقل المجلد';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ✅ جلب تفاصيل مجلد
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
      final response = await _service.getSharedFolderDetailsInRoom(folderId: folderId);
      return response;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      setLoading(false);
    }
  }

  // ✅ مشاركة مجلد مع مستخدمين
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

      errorMessage = response['message'] ?? 'فشل مشاركة المجلد';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ✅ تحديث صلاحيات مشاركة المجلد
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

      errorMessage = response['message'] ?? 'فشل تحديث الصلاحيات';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ✅ إلغاء مشاركة المجلد
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

      errorMessage = response['message'] ?? 'فشل إلغاء المشاركة';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ✅ جلب المجلدات المشتركة معي
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













  // ✅ حذف مجلد (soft delete)
  Future<bool> deleteFolder({
    required String folderId,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.deleteFolder(folderId: folderId);
      if (response['message'] != null || response['folder'] != null) {
        return true;
      }
      errorMessage = response['message'] ?? 'فشل حذف المجلد';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ✅ استعادة مجلد من المهملات
  Future<bool> restoreFolder({
    required String folderId,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.restoreFolder(folderId: folderId);
      if (response['message'] != null || response['folder'] != null) {
        return true;
      }
      errorMessage = response['message'] ?? 'فشل استعادة المجلد';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ✅ حذف مجلد نهائياً
  Future<bool> deleteFolderPermanent({
    required String folderId,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.deleteFolderPermanent(folderId: folderId);
      if (response['message'] != null) {
        return true;
      }
      errorMessage = response['message'] ?? 'فشل الحذف النهائي للمجلد';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ✅ جلب المجلدات المحذوفة (trash)
  Future<void> getTrashFolders({
    int page = 1,
    bool loadMore = false,
  }) async {
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
      final response = await _service.getTrashFolders();
      
      if (response['folders'] != null) {
        final List<Map<String, dynamic>> newFolders =
            List<Map<String, dynamic>>.from(response['folders'] ?? []);

        if (loadMore) {
          _trashFolders.addAll(newFolders);
        } else {
          _trashFolders = newFolders;
        }

        // تحديد إذا كان هناك المزيد من المجلدات
        _hasMore = newFolders.length >= 20; // إذا كان العدد = الحد الأقصى، قد يكون هناك المزيد
        
        // تحديث معلومات الصفحة
        _pagination = {
          'currentPage': _currentPage,
          'hasNext': _hasMore,
        };

        _safeNotifyListeners();
      } else {
        errorMessage = response['message'] ?? 'فشل في جلب المجلدات المحذوفة';
        if (!loadMore) {
          _trashFolders = [];
          _safeNotifyListeners();
        }
      }
    } catch (e) {
      errorMessage = 'خطأ في جلب المجلدات المحذوفة: ${e.toString()}';
      if (!loadMore) {
        _trashFolders = [];
        _safeNotifyListeners();
      }
    } finally {
      setLoading(false);
    }
  }

  // ✅ تنظيف المجلدات المنتهية الصلاحية
  Future<bool> cleanExpiredFolders() async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.cleanExpiredFolders();
      if (response['message'] != null) {
        return true;
      }
      errorMessage = response['message'] ?? 'فشل تنظيف المجلدات المنتهية';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ✅ إضافة/إزالة علامة النجمة من المجلد
  // ✅ نرجع Map يحتوي على success و isStarred
  Future<Map<String, dynamic>> toggleStarFolder({
    required String folderId,
  }) async {
    // ✅ لا نستخدم setLoading لأن هذا تحديث بسيط لا يحتاج refresh للصفحة كلها
    errorMessage = null;

    try {
      final response = await _service.toggleStarFolder(folderId: folderId);
      if (response['folder'] != null) {
        final updatedFolder = Map<String, dynamic>.from(response['folder']);
        final isStarred = updatedFolder['isStarred'] ?? false;
        
        // ✅ تحديث قائمة المفضلة فوراً
        final existingIndex = _starredFolders.indexWhere((f) => f['_id'] == folderId);
        
        if (isStarred) {
          // ✅ إذا تم إضافة للمفضلة، أضفه للقائمة إذا لم يكن موجوداً
          if (existingIndex == -1) {
            _starredFolders.insert(0, updatedFolder); // ✅ إضافة في البداية
          } else {
            // ✅ تحديث المجلد الموجود
            _starredFolders[existingIndex] = updatedFolder;
          }
        } else {
          // ✅ إذا تم إزالته من المفضلة، احذفه من القائمة
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
      errorMessage = response['message'] ?? 'فشل في تحديث حالة النجمة';
      return {'success': false, 'isStarred': false, 'message': errorMessage};
    } catch (e) {
      errorMessage = e.toString();
      return {'success': false, 'isStarred': false, 'message': errorMessage};
    }
  }

  // ✅ جلب المجلدات المميزة
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
        
        // تحديث معلومات الصفحة إذا كانت متوفرة
        if (response['pagination'] != null) {
          _starredPagination = Map<String, dynamic>.from(response['pagination']);
          final totalPages = _starredPagination['totalPages'] ?? 1;
          _starredHasMore = _starredCurrentPage < totalPages;
        } else {
          // إذا لم تكن pagination متوفرة، نحدد بناءً على عدد النتائج
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
        errorMessage = response['message'] ?? 'فشل في جلب المجلدات المميزة';
        if (!loadMore) {
          _starredFolders = [];
          _safeNotifyListeners();
        }
      }
    } catch (e) {
      errorMessage = 'خطأ في جلب المجلدات المميزة: ${e.toString()}';
      if (!loadMore) {
        _starredFolders = [];
        _safeNotifyListeners();
      }
    } finally {
      setLoading(false);
    }
  }

  // ✅ حساب حجم مجلد معين
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

  // ✅ حساب عدد الملفات في مجلد معين
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

  // ✅ حساب إحصائيات المجلد (الحجم + عدد الملفات) - الأكثر كفاءة
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

}
