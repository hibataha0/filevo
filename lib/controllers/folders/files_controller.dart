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
  
  // ✅ إحصائيات التصنيفات
  Map<String, Map<String, dynamic>> _categoriesStats = {};

  // Getters
  List<Map<String, dynamic>> get trashFiles => _trashFiles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<Map<String, dynamic>> get uploadedFiles => _uploadedFiles;
  Map<String, dynamic>? get fileDetails => _fileDetails;
  List<Map<String, dynamic>> get starredFiles => _starredFiles;
  Map<String, dynamic> get pagination => _pagination;
  
  // ✅ Getter لإحصائيات التصنيفات
  Map<String, Map<String, dynamic>> get categoriesStats => _categoriesStats;
  
  // ✅ Getter لإحصائيات تصنيف معين
  Map<String, dynamic>? getCategoryStats(String category) {
    return _categoriesStats[category.toLowerCase()];
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

  /// ✅ جلب جميع الملفات بدون parentFolder (مع pagination و category filter)
  Future<Map<String, dynamic>?> getAllFiles({
    required String token,
    int page = 1,
    int limit = 10,
    String? category,
    String? sortBy,
    String? sortOrder,
  }) async {
    setLoading(true);
    setError(null);
    try {
      final result = await _fileService.getAllFiles(
        token: token,
        page: page,
        limit: limit,
        category: category,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      if (result['files'] != null) {
        _uploadedFiles = List<Map<String, dynamic>>.from(result['files']);
        _pagination = Map<String, dynamic>.from(result['pagination'] ?? {});
        _currentPage = page;
        _hasMore = result['pagination']?['hasNext'] ?? false;
        _safeNotifyListeners();
      }
      
      return result;
    } catch (e) {
      setError('خطأ في جلب الملفات: ${e.toString()}');
      _uploadedFiles = [];
      _pagination = {};
      _safeNotifyListeners();
      return null;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> unshareFile({
    required String fileId,
    required List<String> userIds,
    required String token,
  }) async {
    setLoading(true);
    setError(null);
    setSuccess(null);

    try {
      final result = await _fileService.unshareFile(
        fileId: fileId,
        userIds: userIds,
        token: token,
      );

      setSuccess(result['message'] ?? 'تم إلغاء مشاركة الملف بنجاح');
      return true;
    } catch (e) {
      setError('فشل في إلغاء مشاركة الملف: ${e.toString()}');
      return false;
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

  /// جلب إحصائيات التصنيفات (عدد الملفات والحجم لكل تصنيف)
  Future<Map<String, dynamic>?> getCategoriesStats({
    required String token,
  }) async {
    // ✅ لا نضبط loading لأن هذا استدعاء خلفي ولا نريد أن يؤثر على UI
    try {
      final result = await _fileService.getCategoriesStats(token: token);
      
      // ✅ حفظ إحصائيات التصنيفات في Controller
      if (result != null && result['categories'] != null) {
        final statsList = result['categories'] as List;
        
        // ✅ تحديث _categoriesStats
        _categoriesStats.clear();
        for (var stat in statsList) {
          final categoryName = (stat['category'] as String).toLowerCase();
          dynamic filesCountValue = stat['filesCount'];
          dynamic totalSizeValue = stat['totalSize'];
          
          int filesCount = 0;
          int totalSize = 0;
          
          if (filesCountValue != null) {
            if (filesCountValue is int) {
              filesCount = filesCountValue;
            } else if (filesCountValue is num) {
              filesCount = filesCountValue.toInt();
            } else if (filesCountValue is String) {
              filesCount = int.tryParse(filesCountValue) ?? 0;
            }
          }
          
          if (totalSizeValue != null) {
            if (totalSizeValue is int) {
              totalSize = totalSizeValue;
            } else if (totalSizeValue is num) {
              totalSize = totalSizeValue.toInt();
            } else if (totalSizeValue is String) {
              totalSize = int.tryParse(totalSizeValue) ?? 0;
            }
          }
          
          _categoriesStats[categoryName] = {
            'filesCount': filesCount,
            'totalSize': totalSize,
            'category': stat['category'] as String,
          };
        }
        
        // ✅ إشعار الـ listeners بالتحديث
        _safeNotifyListeners();
      }
      
      return result;
    } catch (e) {
      // ✅ لا نضبط error لأن هذا استدعاء اختياري - سنستخدم القيم الافتراضية
      return null;
    }
  }

  /// 📊 جلب إحصائيات التصنيفات في الجذر فقط (عدد الملفات والحجم لكل تصنيف)
  Future<Map<String, dynamic>?> getRootCategoriesStats({
    required String token,
  }) async {
    // ✅ لا نضبط loading لأن هذا استدعاء خلفي ولا نريد أن يؤثر على UI
    try {
      final result = await _fileService.getRootCategoriesStats(token: token);
      
      // ✅ حفظ إحصائيات التصنيفات في Controller
      if (result != null && result['categories'] != null) {
        final statsList = result['categories'] as List;
        
        // ✅ تحديث _categoriesStats
        _categoriesStats.clear();
        for (var stat in statsList) {
          final categoryName = (stat['category'] as String).toLowerCase();
          dynamic filesCountValue = stat['filesCount'];
          dynamic totalSizeValue = stat['totalSize'];
          
          int filesCount = 0;
          int totalSize = 0;
          
          if (filesCountValue != null) {
            if (filesCountValue is int) {
              filesCount = filesCountValue;
            } else if (filesCountValue is num) {
              filesCount = filesCountValue.toInt();
            } else if (filesCountValue is String) {
              filesCount = int.tryParse(filesCountValue) ?? 0;
            }
          }
          
          if (totalSizeValue != null) {
            if (totalSizeValue is int) {
              totalSize = totalSizeValue;
            } else if (totalSizeValue is num) {
              totalSize = totalSizeValue.toInt();
            } else if (totalSizeValue is String) {
              totalSize = int.tryParse(totalSizeValue) ?? 0;
            }
          }
          
          _categoriesStats[categoryName] = {
            'filesCount': filesCount,
            'totalSize': totalSize,
            'category': stat['category'] as String,
          };
        }
        
        // ✅ إشعار الـ listeners بالتحديث
        _safeNotifyListeners();
      }
      
      return result;
    } catch (e) {
      print('⚠️ Error fetching root categories stats: $e');
      return null;
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
        print('Fetched file details: $_fileDetails');
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

  Future<Map<String, dynamic>?> getSharedFileDetailsInRoom({
    required String fileId,
    required String token,
  }) async {
    setLoading(true);
    setError(null);
    clearFileDetails();
    try {
      final data = await _fileService.getSharedFileDetailsInRoom(fileId: fileId, token: token);
      if (data != null) {
        _fileDetails = data;
        _safeNotifyListeners();
        return _fileDetails;
      } else {
        setError('فشل في جلب تفاصيل الملف المشترك في الروم');
        return null;
      }
    } catch (e) {
      setError('خطأ في جلب تفاصيل الملف المشترك في الروم: ${e.toString()}');
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

  /// 🔄 نقل ملف من مجلد إلى آخر
  Future<bool> moveFile({
    required String fileId,
    required String token,
    String? targetFolderId, // null للجذر أو folderId للمجلد
  }) async {
    setLoading(true);
    setError(null);
    setSuccess(null);
    try {
      final result = await _fileService.moveFile(
        fileId: fileId,
        token: token,
        targetFolderId: targetFolderId,
      );

      if (result['success'] == true) {
        if (result['file'] != null) {
          final movedFile = Map<String, dynamic>.from(result['file']);
          final newParentFolderId = movedFile['parentFolderId'];
          final oldParentFolderId = result['fromFolder'];
          
          // ✅ التحقق من الملف القديم في _uploadedFiles
          final index = _uploadedFiles.indexWhere((f) => f['_id']?.toString() == fileId.toString());
          final oldFile = index != -1 ? _uploadedFiles[index] : null;
          
          // ✅ التحقق من الموقع القديم: إذا كان oldParentFolderId null أو كان الملف في _uploadedFiles بدون parentFolderId
          final wasInRoot = oldParentFolderId == null || 
                           oldParentFolderId == 'null' || 
                           oldParentFolderId == '' ||
                           (oldFile != null && (oldFile['parentFolderId'] == null || oldFile['parentFolderId'] == 'null' || oldFile['parentFolderId'] == ''));
          
          // ✅ التحقق من الموقع الجديد
          final isNowInRoot = newParentFolderId == null || 
                             newParentFolderId == 'null' || 
                             newParentFolderId == '' ||
                             newParentFolderId.toString().isEmpty;
          
          // ✅ إذا كان الملف في الجذر ونُقل لمجلد، يجب إزالته من _uploadedFiles
          if (wasInRoot && !isNowInRoot) {
            // ✅ إزالة الملف من _uploadedFiles لأنه لم يعد في الجذر
            if (index != -1) {
              _uploadedFiles.removeAt(index);
              print('✅ تم إزالة الملف من _uploadedFiles بعد نقله من الجذر لمجلد');
            }
          }
          // ✅ إذا كان الملف في مجلد ونُقل للجذر، يجب إضافته لـ _uploadedFiles
          else if (!wasInRoot && isNowInRoot) {
            // ✅ إضافة الملف لـ _uploadedFiles لأنه الآن في الجذر
            if (index == -1) {
              _uploadedFiles.add(movedFile);
              print('✅ تم إضافة الملف لـ _uploadedFiles بعد نقله للجذر');
            } else {
              _uploadedFiles[index] = movedFile;
            }
          }
          // ✅ إذا كان في مجلد ونُقل لمجلد آخر، أو في الجذر ونُقل للجذر، فقط تحديث البيانات
          else if (index != -1) {
            _uploadedFiles[index] = movedFile;
          }
          
          // ✅ تحديث تفاصيل الملف إذا كان هو الملف الحالي
          if (_fileDetails != null && _fileDetails!['_id']?.toString() == fileId.toString()) {
            _fileDetails = movedFile;
          }
          
          // ✅ إذا كان الملف في المفضلة، قم بتحديثه هناك أيضاً
          final starredIndex = _starredFiles.indexWhere((f) => f['_id']?.toString() == fileId.toString());
          if (starredIndex != -1) {
            _starredFiles[starredIndex] = movedFile;
          }
        }
        
        // ✅ إعادة جلب إحصائيات التصنيفات بعد نقل الملف
        try {
          await getRootCategoriesStats(token: token);
          print('✅ تم تحديث إحصائيات التصنيفات في الجذر بعد نقل الملف');
        } catch (e) {
          // ✅ في حالة الخطأ، نستمر بدون إيقاف العملية
          print('⚠️ Error refreshing categories stats: $e');
        }
        
        setSuccess(result['message'] ?? 'تم نقل الملف بنجاح');
        _safeNotifyListeners();
        return true;
      } else {
        setError(result['message'] ?? 'فشل في نقل الملف');
        return false;
      }
    } catch (e) {
      setError('خطأ في نقل الملف: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<Map<String, dynamic>> toggleStar({required String fileId, required String token}) async {
    // ✅ لا نستخدم setLoading لأن هذا تحديث بسيط لا يحتاج refresh للصفحة كلها
    setError(null);

    try {
      final result = await _fileService.toggleStarFile(fileId: fileId, token: token);
      
      if (result['success'] == true && result['file'] != null) {
        final updatedFile = Map<String, dynamic>.from(result['file']);
        final isStarred = updatedFile['isStarred'] ?? false;
        
        // ✅ تحديث قائمة الملفات المرفوعة
        final uploadedIndex = _uploadedFiles.indexWhere((f) => f['_id'] == fileId);
        if (uploadedIndex != -1) {
          _uploadedFiles[uploadedIndex] = updatedFile;
        }
        
        // ✅ تحديث قائمة المفضلة فوراً
        final existingIndex = _starredFiles.indexWhere((f) => f['_id'] == fileId);
        
        if (isStarred) {
          // ✅ إذا تم إضافة للمفضلة، أضفه للقائمة إذا لم يكن موجوداً
          if (existingIndex == -1) {
            _starredFiles.insert(0, updatedFile); // ✅ إضافة في البداية
          } else {
            // ✅ تحديث الملف الموجود
            _starredFiles[existingIndex] = updatedFile;
          }
        } else {
          // ✅ إذا تم إزالته من المفضلة، احذفه من القائمة
          if (existingIndex != -1) {
            _starredFiles.removeAt(existingIndex);
          }
        }
        
        _safeNotifyListeners();
        return {
          'success': true,
          'isStarred': isStarred,
          'file': updatedFile,
        };
      }
      
      final errorMsg = result['message'] ?? 'فشل في تحديث حالة النجمة';
      setError(errorMsg);
      return {'success': false, 'isStarred': false, 'message': errorMsg};
    } catch (e) {
      final errorMsg = 'خطأ في تحديث حالة النجمة: ${e.toString()}';
      setError(errorMsg);
      return {'success': false, 'isStarred': false, 'message': errorMsg};
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

        _safeNotifyListeners();
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
