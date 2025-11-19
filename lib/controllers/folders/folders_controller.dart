import 'dart:io';
import 'package:filevo/services/folders_service.dart';
import 'package:flutter/material.dart';

class FolderController with ChangeNotifier {
  final FolderService _service = FolderService();

  bool isLoading = false;
  String? errorMessage;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
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
    required List<File> files,
    required List<String> relativePaths,
    String? parentFolderId,
  }) async {
    setLoading(true);
    errorMessage = null;

    try {
      final response = await _service.uploadFolder(
        folderName: folderName,
        files: files,
        relativePaths: relativePaths,
        parentFolderId: parentFolderId,
      );

      return response;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      setLoading(false);
    }
  }
}
