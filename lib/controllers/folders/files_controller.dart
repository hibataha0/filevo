import 'dart:convert';
import 'dart:io';
import 'package:filevo/services/file_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:filevo/config/api_config.dart';
import 'package:filevo/services/api_endpoints.dart';

class FileController extends ChangeNotifier {
  final FileService _fileService = FileService();
  String? _currentFileId;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
    List<Map<String, dynamic>> _trashFiles = [];

  List<Map<String, dynamic>> _uploadedFiles = [];
  Map<String, dynamic>? _fileDetails;
  bool _isDisposed = false;
  List<Map<String, dynamic>> _starredFiles = [];
  Map<String, dynamic> _pagination = {};
  int _currentPage = 1;
  bool _hasMore = true;

  // Getters
  List<Map<String, dynamic>> get trashFiles => _trashFiles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<Map<String, dynamic>> get uploadedFiles => _uploadedFiles;
  Map<String, dynamic>? get fileDetails => _fileDetails;
  List<Map<String, dynamic>> get starredFiles => _starredFiles;
  Map<String, dynamic> get pagination => _pagination;

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
    _isLoading = value;
    _safeNotifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    _safeNotifyListeners();
  }

  void setSuccess(String? message) {
    _successMessage = message;
    _safeNotifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _safeNotifyListeners();
  }

  void clearFileDetails() {
    _fileDetails = null;
    _safeNotifyListeners();
  }

  /// رفع ملف واحد
  Future<bool> uploadSingleFile({
    required File file,
    required String token,
    String? parentFolderId,
  }) async {
    setLoading(true);
    setError(null);
    setSuccess(null);
    try {
      final result = await _fileService.uploadSingleFile(
        file: file,
        token: token,
        parentFolderId: parentFolderId,
      );

      if (result['file'] != null) {
        _uploadedFiles.add(Map<String, dynamic>.from(result['file']));
        _safeNotifyListeners();
        setSuccess(result['message'] ?? 'تم رفع الملف بنجاح');
        return true;
      } else {
        setError(result['message'] ?? 'فشل في رفع الملف');
        return false;
      }
    } catch (e) {
      setError('خطأ في رفع الملف: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// رفع ملفات متعددة
  Future<Map<String, dynamic>> uploadMultipleFiles({
    required List<File> files,
    required String token,
    String? parentFolderId,
  }) async {
    setLoading(true);
    setError(null);
    setSuccess(null);
    try {
      final result = await _fileService.uploadMultipleFiles(
        files: files,
        token: token,
        parentFolderId: parentFolderId,
      );

      if (result['files'] != null && result['files'] is List) {
        _uploadedFiles.addAll(List<Map<String, dynamic>>.from(result['files']));
        _safeNotifyListeners();
        setSuccess(result['message'] ?? 'تم رفع ${files.length} ملف بنجاح');
      } else {
        setError(result['message'] ?? 'فشل في رفع الملفات');
      }
      return result;
    } catch (e) {
      setError('خطأ في رفع الملفات: ${e.toString()}');
      return {'success': false, 'message': e.toString()};
    } finally {
      setLoading(false);
    }
  }

  /// جلب الملفات حسب التصنيف
  Future<List<Map<String, dynamic>>> getFilesByCategory({
    required String category,
    required String token,
    String? parentFolderId,
  }) async {
    setLoading(true);
    setError(null);
    try {
      final result = await _fileService.getFilesByCategory(
        category: category,
        token: token,
        parentFolderId: parentFolderId,
      );

      _uploadedFiles = List<Map<String, dynamic>>.from(result);
      notifyListeners();
      return _uploadedFiles;
    } catch (e) {
      setError('خطأ في جلب الملفات حسب التصنيف: ${e.toString()}');
      _uploadedFiles = [];
      notifyListeners();
      return [];
    } finally {
      setLoading(false);
    }
  }

  /// جلب تفاصيل ملف واحد
  Future<Map<String, dynamic>?> getFileDetails({
    required String fileId,
    required String token,
  }) async {
    setLoading(true);
    setError(null);
    clearFileDetails();
    try {
      final data = await _fileService.getFileDetails(fileId: fileId, token: token);
      if (data != null) {
        _fileDetails = data;
        _safeNotifyListeners();
        return _fileDetails;
      } else {
        setError('فشل في جلب تفاصيل الملف');
        return null;
      }
    } catch (e) {
      setError('خطأ في جلب تفاصيل الملف: ${e.toString()}');
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// حذف ملف
  Future<bool> deleteFile({required String fileId, required String token}) async {
    setLoading(true);
    setError(null);
    setSuccess(null);
    try {
      final result = await FileService.deleteFile(fileId: fileId, token: token);
      if (result['success'] == true) {
        _uploadedFiles.removeWhere((file) => file['_id'] == fileId);
        _safeNotifyListeners();
        setSuccess(result['message'] ?? 'تم حذف الملف بنجاح');
        return true;
      } else {
        setError(result['message'] ?? 'فشل في حذف الملف');
        return false;
      }
    } catch (e) {
      setError('خطأ في حذف الملف: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// تحديث بيانات ملف
  Future<bool> updateFile({
    required String fileId,
    required String token,
    String? name,
    String? description,
    List<String>? tags,
    String? parentFolderId,
  }) async {
    setLoading(true);
    setError(null);
    setSuccess(null);
    try {
      final result = await _fileService.updateFile(
        fileId: fileId,
        token: token,
        name: name,
        description: description,
        tags: tags,
        parentFolderId: parentFolderId,
      );

      if (result['success'] == true) {
        if (result['file'] != null) {
          final updatedFile = Map<String, dynamic>.from(result['file']);
          final index = _uploadedFiles.indexWhere((f) => f['_id'] == fileId);
          if (index != -1) _uploadedFiles[index] = updatedFile;
          _fileDetails = updatedFile;
        }
        setSuccess(result['message'] ?? 'تم تحديث الملف بنجاح');
        _safeNotifyListeners();
        return true;
      } else {
        setError(result['message'] ?? 'فشل في تحديث الملف');
        return false;
      }
    } catch (e) {
      setError('خطأ في تحديث الملف: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> toggleStar({required String fileId, required String token}) async {
  try {
    final result = await _fileService.toggleStarFile(fileId: fileId, token: token);
    
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔍 Full Response: $result');
    print('🔍 isStarred: ${result['file']?['isStarred']}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    if (result['success'] == true && result['file'] != null) {
      final updatedFile = Map<String, dynamic>.from(result['file']);
      final index = _uploadedFiles.indexWhere((f) => f['_id'] == fileId);
      if (index != -1) {
        _uploadedFiles[index] = updatedFile;
      }
      
      // ✅ نرجع القيمة الحقيقية من الـ backend
      final isStarred = updatedFile['isStarred'] ?? false;
      print('✅ Returning isStarred: $isStarred');
      return isStarred;
      
    } else {
      setError(result['message'] ?? 'فشل في تحديث حالة النجمة');
      return false; // ⚠️ هنا المشكلة - بيرجع false دايماً
    }
  } catch (e) {
    print('❌ Exception: $e');
    setError('خطأ في تحديث حالة النجمة: ${e.toString()}');
    return false;
  }
}

  /// جلب الملفات المفضلة
  Future<void> getStarredFiles({
    required String token,
    int page = 1,
    int limit = 20,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      setLoading(true);
    } else {
      if (!_hasMore || _isLoading) return;
      _currentPage++;
    }

    setError(null);
    try {
      final result = await _fileService.getStarredFiles(
        token: token,
        page: _currentPage,
        limit: limit,
      );

      if (result['success'] == true) {
        final List<Map<String, dynamic>> newFiles =
            List<Map<String, dynamic>>.from(result['files'] ?? []);
        final pagination = Map<String, dynamic>.from(result['pagination'] ?? {});
        _pagination = pagination;
        final totalPages = pagination['totalPages'] ?? 1;
        _hasMore = _currentPage < totalPages;

        if (loadMore) {
          _starredFiles.addAll(newFiles);
        } else {
          _starredFiles = newFiles;
        }

        notifyListeners();
      } else {
        setError(result['message'] ?? 'فشل في جلب الملفات المفضلة');
      }
    } catch (e) {
      setError('خطأ في جلب الملفات المفضلة: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

/// جلب الملفات المحذوفة
 /// جلب ملفات المهملات
  Future<void> getTrashFiles({
    required String token,
    int page = 1,
    int limit = 20,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      setLoading(true);
    } else {
      if (!_hasMore || _isLoading) return;
      _currentPage++;
    }

    setError(null);

    try {
      final result = await FileService.fetchTrashFiles(
        token: token,
        page: _currentPage,
        limit: limit,
      );
      
      print('Fetched trash files result: $result');
      
      if (result['success'] == true) {
        final List<Map<String, dynamic>> newFiles =
            List<Map<String, dynamic>>.from(result['files'] ?? []);
        final pagination = Map<String, dynamic>.from(result['pagination'] ?? {});
        _pagination = pagination;

        final totalPages = pagination['totalPages'] ?? 1;
        _hasMore = _currentPage < totalPages;

        if (loadMore) {
          _trashFiles.addAll(newFiles);
        } else {
          _trashFiles = newFiles;
        }

        setSuccess(result['message']);
        _safeNotifyListeners();
      } else {
        setError(result['message'] ?? 'فشل في جلب ملفات المهملات');
        if (!loadMore) {
          _trashFiles = [];
          _safeNotifyListeners();
        }
      }
    } catch (e) {
      setError('خطأ في جلب ملفات المهملات: ${e.toString()}');
      if (!loadMore) {
        _trashFiles = [];
        _safeNotifyListeners();
      }
    } finally {
      setLoading(false);
    }
  }




 /// استعادة ملفات من المهملات
  Future<bool> restoreFiles({
    required List<String> fileIds,
    required String token,
  }) async {
    setLoading(true);
    setError(null);
    setSuccess(null);
    
    try {
      final result = await FileService.restoreFiles(
        fileIds: fileIds,
        token: token,
      );
      print('Restore files result: $result');

      if (result['success'] == true) {
        // إزالة الملفات المستعادة من القائمة المحلية
        _trashFiles.removeWhere((file) => fileIds.contains(file['_id']));
        setSuccess(result['message'] ?? 'تم استعادة الملفات بنجاح');
        _safeNotifyListeners();
        return true;
      } else {
        setError(result['message'] ?? 'فشل في استعادة الملفات');
        return false;
      }
    } catch (e) {
      setError('خطأ في استعادة الملفات: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// حذف نهائي لملفات
  Future<bool> permanentDelete({
    required List<String> fileIds,
    required String token,
  }) async {
    setLoading(true);
    setError(null);
    setSuccess(null);
    
    try {
      final result = await FileService.permanentDelete(
        fileIds: fileIds,
        token: token,
      );

      if (result['success'] == true) {
        // إزالة الملفات المحذوفة من القائمة المحلية
        _trashFiles.removeWhere((file) => fileIds.contains(file['_id']));
        setSuccess(result['message'] ?? 'تم الحذف النهائي للملفات بنجاح');
        _safeNotifyListeners();
        return true;
      } else {
        setError(result['message'] ?? 'فشل في الحذف النهائي');
        return false;
      }
    } catch (e) {
      setError('خطأ في الحذف النهائي: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

}
