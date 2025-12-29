import 'dart:io';
import 'package:filevo/services/file_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

  // ✅ Category statistics
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

  // ✅ Getter for category statistics
  Map<String, Map<String, dynamic>> get categoriesStats => _categoriesStats;

  // ✅ Getter for specific category statistics
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

  /// Upload single file
  Future<bool> uploadSingleFile({
    required File file,
    required String token,
    String? parentFolderId,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    setLoading(true);
    setError(null);
    setSuccess(null);
    try {
      final result = await _fileService.uploadSingleFile(
        file: file,
        token: token,
        parentFolderId: parentFolderId,
        onSendProgress: onSendProgress,
      );

      if (result['file'] != null) {
        _uploadedFiles.add(Map<String, dynamic>.from(result['file']));
        _safeNotifyListeners();
        setSuccess(result['message'] ?? 'File uploaded successfully');
        return true;
      } else {
        final viruses =
            (result['viruses'] as List?)?.map((e) => e.toString()).toList() ??
            [];
        if (result['virusDetected'] == true || viruses.isNotEmpty) {
          final virusMsg = viruses.isNotEmpty
              ? 'Virus detected in file (${viruses.join(", ")})'
              : result['message'] ?? 'File rejected due to virus scan';
          setError(virusMsg);
        } else {
          setError(result['message'] ?? 'Failed to upload file');
        }
        return false;
      }
    } catch (e) {
      setError('Error uploading file: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Upload multiple files
  Future<Map<String, dynamic>> uploadMultipleFiles({
    required List<File> files,
    required String token,
    String? parentFolderId,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    setLoading(true);
    setError(null);
    setSuccess(null);
    try {
      final result = await _fileService.uploadMultipleFiles(
        files: files,
        token: token,
        parentFolderId: parentFolderId,
        onSendProgress: onSendProgress,
      );

      final uploadedList = result['files'] != null && result['files'] is List
          ? List<Map<String, dynamic>>.from(result['files'])
          : <Map<String, dynamic>>[];
      final errorsRaw = (result['errors'] as List?) ?? [];
      final errors = errorsRaw
          .map(
            (e) => e is Map<String, dynamic>
                ? Map<String, dynamic>.from(e)
                : {'error': e.toString()},
          )
          .toList();

      if (uploadedList.isNotEmpty) {
        _uploadedFiles.addAll(uploadedList);
        _safeNotifyListeners();
      }

      final uploadedCount = uploadedList.length;
      final errorsCount = errors.length;

      if (uploadedCount > 0) {
        final successText = errorsCount > 0
            ? '$uploadedCount file(s) uploaded, $errorsCount file(s) rejected after scan'
            : (result['message'] ??
                  '$uploadedCount file(s) uploaded successfully');
        setSuccess(successText);
      }

      if (uploadedCount == 0 || errorsCount > 0) {
        if (errorsCount > 0) {
          final errorNames = errors
              .map((e) => e['filename'] ?? e['error'] ?? '')
              .where((e) => e.toString().isNotEmpty)
              .take(3)
              .join(', ');
          final errorText = errorsCount == 1
              ? 'File rejected after scan: $errorNames'
              : '$errorsCount file(s) rejected after scan: $errorNames';
          setError(errorText);
        } else if (uploadedCount == 0) {
          setError(result['message'] ?? 'Failed to upload file');
        }
      }
      return result;
    } catch (e) {
      setError('Error uploading file: ${e.toString()}');
      return {'success': false, 'message': e.toString()};
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Get all files without parentFolder (with pagination and category filter)
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
      setError('Error fetching files: ${e.toString()}');
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

      setSuccess(result['message'] ?? 'File sharing cancelled successfully');
      return true;
    } catch (e) {
      setError('Failed to unshare file: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Get files by category
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
      setError('Error fetching files by category: ${e.toString()}');
      _uploadedFiles = [];
      notifyListeners();
      return [];
    } finally {
      setLoading(false);
    }
  }

  /// Get category statistics (file count and size per category)
  Future<Map<String, dynamic>?> getCategoriesStats({
    required String token,
  }) async {
    // ✅ Don't set loading because this is a background call that shouldn't affect UI
    try {
      final result = await _fileService.getCategoriesStats(token: token);

      // ✅ Save category statistics in Controller
      if (result != null && result['categories'] != null) {
        final statsList = result['categories'] as List;

        // ✅ Update _categoriesStats
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

        // ✅ Notify listeners of the update
        _safeNotifyListeners();
      }

      return result;
    } catch (e) {
      // ✅ Don't set error because this is an optional call - we'll use default values
      return null;
    }
  }

  /// 📊 Get category statistics only at root (file count and size per category)
  Future<Map<String, dynamic>?> getRootCategoriesStats({
    required String token,
  }) async {
    // ✅ Don't set loading because this is a background call that shouldn't affect UI
    try {
      final result = await _fileService.getRootCategoriesStats(token: token);

      // ✅ Save category statistics in Controller
      if (result != null && result['categories'] != null) {
        final statsList = result['categories'] as List;

        // ✅ Update _categoriesStats
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

        // ✅ Notify listeners of the update
        _safeNotifyListeners();
      }

      return result;
    } catch (e) {
      print('⚠️ Error fetching root categories stats: $e');
      return null;
    }
  }

  /// Get single file details
  Future<Map<String, dynamic>?> getFileDetails({
    required String fileId,
    required String token,
  }) async {
    setLoading(true);
    setError(null);
    clearFileDetails();
    try {
      final data = await _fileService.getFileDetails(
        fileId: fileId,
        token: token,
      );
      if (data != null) {
        _fileDetails = data;
        _safeNotifyListeners();
        print('Fetched file details: $_fileDetails');
        return _fileDetails;
      } else {
        setError('Failed to fetch file details');
        return null;
      }
    } catch (e) {
      setError('Error fetching file details: ${e.toString()}');
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
      final data = await _fileService.getSharedFileDetailsInRoom(
        fileId: fileId,
        token: token,
      );
      if (data != null) {
        _fileDetails = data;
        _safeNotifyListeners();
        return _fileDetails;
      } else {
        setError('Failed to fetch shared file details in room');
        return null;
      }
    } catch (e) {
      setError('Error fetching shared file details in room: ${e.toString()}');
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Delete file
  Future<bool> deleteFile({
    required String fileId,
    required String token,
  }) async {
    setLoading(true);
    setError(null);
    setSuccess(null);
    try {
      final result = await FileService.deleteFile(fileId: fileId, token: token);
      if (result['success'] == true) {
        _uploadedFiles.removeWhere((file) => file['_id'] == fileId);
        _safeNotifyListeners();
        setSuccess(result['message'] ?? 'File deleted successfully');
        return true;
      } else {
        setError(result['message'] ?? 'Failed to delete file');
        return false;
      }
    } catch (e) {
      setError('Error deleting file: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Update file data
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
        setSuccess(result['message'] ?? 'File updated successfully');
        _safeNotifyListeners();
        return true;
      } else {
        setError(result['message'] ?? 'Failed to update file');
        return false;
      }
    } catch (e) {
      setError('Error updating file: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// 📝 Update file content (replace old file with new file)
  Future<bool> updateFileContent({
    required String fileId,
    required File file,
    required String token,
    bool? replaceMode,
  }) async {
    setLoading(true);
    setError(null);
    setSuccess(null);
    try {
      final result = await _fileService.updateFileContent(
        fileId: fileId,
        file: file,
        token: token,
        replaceMode: replaceMode,
      );

      if (result['success'] == true) {
        if (result['file'] != null) {
          final updatedFile = Map<String, dynamic>.from(result['file']);
          final index = _uploadedFiles.indexWhere((f) => f['_id'] == fileId);
          if (index != -1) _uploadedFiles[index] = updatedFile;
          _fileDetails = updatedFile;
        }
        setSuccess(result['message'] ?? 'File content updated successfully');
        _safeNotifyListeners();
        return true;
      } else {
        setError(result['message'] ?? 'Failed to update file content');
        return false;
      }
    } catch (e) {
      setError('Error updating file content: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// 🔄 Move file from one folder to another
  Future<bool> moveFile({
    required String fileId,
    required String token,
    String? targetFolderId, // null for root or folderId for folder
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

          // ✅ Check old file in _uploadedFiles
          final index = _uploadedFiles.indexWhere(
            (f) => f['_id']?.toString() == fileId.toString(),
          );
          final oldFile = index != -1 ? _uploadedFiles[index] : null;

          // ✅ Check old location: if oldParentFolderId is null or file was in _uploadedFiles without parentFolderId
          final wasInRoot =
              oldParentFolderId == null ||
              oldParentFolderId == 'null' ||
              oldParentFolderId == '' ||
              (oldFile != null &&
                  (oldFile['parentFolderId'] == null ||
                      oldFile['parentFolderId'] == 'null' ||
                      oldFile['parentFolderId'] == ''));

          // ✅ Check new location
          final isNowInRoot =
              newParentFolderId == null ||
              newParentFolderId == 'null' ||
              newParentFolderId == '' ||
              newParentFolderId.toString().isEmpty;

          // ✅ If file was in root and moved to folder, remove from _uploadedFiles
          if (wasInRoot && !isNowInRoot) {
            // ✅ Remove file from _uploadedFiles because it's no longer in root
            if (index != -1) {
              _uploadedFiles.removeAt(index);
              print(
                '✅ File removed from _uploadedFiles after moving from root to folder',
              );
            }
          }
          // ✅ If file was in folder and moved to root, add to _uploadedFiles
          else if (!wasInRoot && isNowInRoot) {
            // ✅ Add file to _uploadedFiles because it's now in root
            if (index == -1) {
              _uploadedFiles.add(movedFile);
              print('✅ File added to _uploadedFiles after moving to root');
            } else {
              _uploadedFiles[index] = movedFile;
            }
          }
          // ✅ If in folder and moved to another folder, or in root and moved to root, just update data
          else if (index != -1) {
            _uploadedFiles[index] = movedFile;
          }

          // ✅ Update file details if it's the current file
          if (_fileDetails != null &&
              _fileDetails!['_id']?.toString() == fileId.toString()) {
            _fileDetails = movedFile;
          }

          // ✅ If file is in starred, update it there too
          final starredIndex = _starredFiles.indexWhere(
            (f) => f['_id']?.toString() == fileId.toString(),
          );
          if (starredIndex != -1) {
            _starredFiles[starredIndex] = movedFile;
          }
        }

        // ✅ Re-fetch category statistics after moving file
        try {
          await getRootCategoriesStats(token: token);
          print('✅ Root category statistics updated after moving file');
        } catch (e) {
          // ✅ In case of error, continue without stopping the operation
          print('⚠️ Error refreshing categories stats: $e');
        }

        setSuccess(result['message'] ?? 'File moved successfully');
        _safeNotifyListeners();
        return true;
      } else {
        setError(result['message'] ?? 'Failed to move file');
        return false;
      }
    } catch (e) {
      setError('Error moving file: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<Map<String, dynamic>> toggleStar({
    required String fileId,
    required String token,
  }) async {
    // ✅ Don't use setLoading because this is a simple update that doesn't need full page refresh
    setError(null);

    try {
      final result = await _fileService.toggleStarFile(
        fileId: fileId,
        token: token,
      );

      if (result['success'] == true && result['file'] != null) {
        final updatedFile = Map<String, dynamic>.from(result['file']);
        final isStarred = updatedFile['isStarred'] ?? false;

        // ✅ Update uploaded files list
        final uploadedIndex = _uploadedFiles.indexWhere(
          (f) => f['_id'] == fileId,
        );
        if (uploadedIndex != -1) {
          _uploadedFiles[uploadedIndex] = updatedFile;
        }

        // ✅ Update starred list immediately
        final existingIndex = _starredFiles.indexWhere(
          (f) => f['_id'] == fileId,
        );

        if (isStarred) {
          // ✅ If added to starred, add to list if not exists
          if (existingIndex == -1) {
            _starredFiles.insert(0, updatedFile); // ✅ Add at the beginning
          } else {
            // ✅ Update existing file
            _starredFiles[existingIndex] = updatedFile;
          }
        } else {
          // ✅ If removed from starred, delete from list
          if (existingIndex != -1) {
            _starredFiles.removeAt(existingIndex);
          }
        }

        _safeNotifyListeners();
        return {'success': true, 'isStarred': isStarred, 'file': updatedFile};
      }

      final errorMsg = result['message'] ?? 'Failed to update starred status';
      setError(errorMsg);
      return {'success': false, 'isStarred': false, 'message': errorMsg};
    } catch (e) {
      final errorMsg = 'Error updating starred status: ${e.toString()}';
      setError(errorMsg);
      return {'success': false, 'isStarred': false, 'message': errorMsg};
    }
  }

  /// Get starred files
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
        final pagination = Map<String, dynamic>.from(
          result['pagination'] ?? {},
        );
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
        setError(result['message'] ?? 'Failed to fetch starred files');
      }
    } catch (e) {
      setError('Error fetching starred files: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Get deleted files
  /// Get trash files
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
        final pagination = Map<String, dynamic>.from(
          result['pagination'] ?? {},
        );
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
        setError(result['message'] ?? 'Failed to fetch trash files');
        if (!loadMore) {
          _trashFiles = [];
          _safeNotifyListeners();
        }
      }
    } catch (e) {
      setError('Error fetching trash files: ${e.toString()}');
      if (!loadMore) {
        _trashFiles = [];
        _safeNotifyListeners();
      }
    } finally {
      setLoading(false);
    }
  }

  /// Restore files from trash
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
        // Remove restored files from local list
        _trashFiles.removeWhere((file) => fileIds.contains(file['_id']));
        setSuccess(result['message'] ?? 'Files restored successfully');
        _safeNotifyListeners();
        return true;
      } else {
        setError(result['message'] ?? 'Failed to restore files');
        return false;
      }
    } catch (e) {
      setError('Error restoring files: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Permanent file deletion
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
        // Remove deleted files from local list
        _trashFiles.removeWhere((file) => fileIds.contains(file['_id']));
        setSuccess(
          result['message'] ?? 'Files permanently deleted successfully',
        );
        _safeNotifyListeners();
        return true;
      } else {
        setError(result['message'] ?? 'Failed to permanently delete files');
        return false;
      }
    } catch (e) {
      setError('Error permanently deleting files: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }
}
