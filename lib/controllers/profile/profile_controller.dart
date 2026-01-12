import 'dart:io';
import 'package:flutter/material.dart';
import 'package:filevo/services/user_service.dart';
import 'package:filevo/services/file_service.dart';

class ProfileController with ChangeNotifier {
  final UserService _userService = UserService();
  final FileService _fileService = FileService();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _storageInfo;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;
  Map<String, dynamic>? get storageInfo => _storageInfo;

  String? get userName => _userData?['name'] as String?;
  String? get userEmail => _userData?['email'] as String?;
  String? get userPhone => _userData?['phone'] as String?;
  String? get profileImage => _userData?['profileImg'] as String?;

  Map<String, dynamic>? _extractUserData(dynamic rawData) {
    if (rawData is Map<String, dynamic>) {
      // ✅ التحقق من وجود 'user' أولاً
      if (rawData['user'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(rawData['user'] as Map);
      }
      // ✅ التحقق من وجود 'data' (التنسيق الجديد من الـ backend)
      if (rawData['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(rawData['data'] as Map);
      }
      // ✅ إذا كانت البيانات مباشرة في rawData
      print('ProfileController: Extracted user data: $rawData');
      return Map<String, dynamic>.from(rawData);
    }
    return null;
  }

  /// جلب بيانات المستخدم
  Future<void> getLoggedUserData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _userService.getLoggedUserData();

      if (result['success'] == true) {
        _userData = _extractUserData(result['data']);
        print('✅ ProfileController: Fetched user data: $_userData');
        if (_userData != null) {
          print('✅ ProfileController: User data keys: ${_userData!.keys.toList()}');
          print('✅ ProfileController: User name: ${_userData!['name']}');
          print('✅ ProfileController: User email: ${_userData!['email']}');
        } else {
          print('⚠️ ProfileController: User data is null after extraction');
        }
        _errorMessage = null;

      } else {
        final errorMsg = result['error'] ?? result['message'] ?? 'فشل في جلب بيانات المستخدم';
        _errorMessage = errorMsg;
        print('❌ ProfileController: Failed to fetch user data: $errorMsg');
        // ✅ عدم حذف userData الموجودة عند الفشل - قد تكون البيانات موجودة من قبل
        if (_userData == null) {
          _userData = null;
        }
      }
    } catch (e) {
      _errorMessage = 'خطأ في جلب بيانات المستخدم: ${e.toString()}';
      _userData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث بيانات المستخدم
  Future<bool> updateLoggedUserData({
    String? name,
    String? email,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _userService.updateLoggedUserData(
        name: name,
        email: email,
        phone: phone,
      );

      if (result['success'] == true) {
        // ✅ تحديث البيانات من الـ response إذا كانت موجودة
        if (result['data'] != null) {
          final userData = _extractUserData(result['data']);
          if (userData != null) {
            _userData = userData;
            print('✅ ProfileController: Updated user data from response');
          }
        }
        
        // ✅ إعادة جلب البيانات من السيرفر للتأكد من التحديث
        print('🔄 ProfileController: Refetching user data from server...');
        await getLoggedUserData();
        
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = result['error'] ?? 'فشل في تحديث البيانات';
        return false;
      }
    } catch (e) {
      _errorMessage = 'خطأ في تحديث البيانات: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث كلمة المرور
  Future<bool> updateLoggedUserPassword({
    required String currentPassword,
    required String password,
    required String passwordConfirm,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _userService.updateLoggedUserPassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirm: passwordConfirm,
      );

      if (result['success'] == true) {
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = result['error'] ?? 'فشل في تحديث كلمة المرور';
        return false;
      }
    } catch (e) {
      _errorMessage = 'خطأ في تحديث كلمة المرور: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// حذف حساب المستخدم
  Future<bool> deleteLoggedUserData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _userService.deleteLoggedUserData();

      if (result['success'] == true) {
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = result['error'] ?? 'فشل في حذف الحساب';
        return false;
      }
    } catch (e) {
      _errorMessage = 'خطأ في حذف الحساب: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// رفع صورة البروفايل
  Future<bool> uploadProfileImage({
    required File imageFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _userService.uploadProfileImage(
        imageFile: imageFile,
      );

      if (result['success'] == true) {
        // ✅ تحديث بيانات المستخدم بعد رفع الصورة
        // ✅ التحقق من وجود بيانات المستخدم في الـ response
        if (result['data'] != null) {
          final userData = _extractUserData(result['data']);
          if (userData != null) {
            print('✅ ProfileController: User data from upload response:');
            print('  - profileImg: ${userData['profileImg']}');
            print('  - profileImgUrl: ${userData['profileImgUrl']}');
            print('  - All keys: ${userData.keys.toList()}');
            
            _userData = userData;
            print('✅ ProfileController: Updated user data after image upload');
          }
        }
        // ✅ إعادة جلب البيانات من السيرفر للتأكد من التحديث
        print('🔄 ProfileController: Refetching user data from server...');
        await getLoggedUserData();
        
        // ✅ التحقق من أن profileImg تم حفظه
        if (_userData != null) {
          print('✅ ProfileController: User data after refetch:');
          print('  - profileImg: ${_userData!['profileImg']}');
          print('  - profileImgUrl: ${_userData!['profileImgUrl']}');
          if (_userData!['profileImg'] == null && _userData!['profileImgUrl'] == null) {
            print('⚠️ WARNING: profileImg is still null after refetch!');
            print('⚠️ This means the backend did not save the profile image.');
            print('⚠️ Please check the backend code.');
          }
        }
        
        _errorMessage = null;
        return true;
      } else {
        final errorMsg = result['error'] ?? result['message'] ?? 'فشل في رفع الصورة';
        _errorMessage = errorMsg;
        print('❌ ProfileController: Upload failed: $errorMsg');
        return false;
      }
    } catch (e) {
      _errorMessage = 'خطأ في رفع الصورة: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ جلب معلومات المساحة التخزينية
  Future<void> getStorageInfo() async {
    // ✅ منع الاستدعاء المتكرر إذا كان هناك طلب قيد التنفيذ
    if (_isLoading && _storageInfo != null) {
      return; // ✅ إذا كانت البيانات موجودة وتحميل قيد التنفيذ، لا نستدعي مرة أخرى
    }
    
    try {
      final result = await _fileService.getStorageInfo();
      
      if (result['success'] == true) {
        _storageInfo = result['storage'] as Map<String, dynamic>?;
        notifyListeners();
      } else {
        // ✅ فقط تحديث إذا كانت البيانات غير موجودة
        if (_storageInfo == null) {
          _storageInfo = null;
          notifyListeners();
        }
      }
    } catch (e) {
      print('❌ ProfileController: Error getting storage info: $e');
      // ✅ فقط تحديث في حالة الخطأ إذا كانت البيانات غير موجودة
      if (_storageInfo == null) {
        _storageInfo = null;
        notifyListeners();
      }
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
