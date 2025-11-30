import 'package:flutter/material.dart';
import 'package:filevo/services/user_service.dart';
import 'package:filevo/services/storage_service.dart';

class ProfileController with ChangeNotifier {
  final UserService _userService = UserService();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;

  String? get userName => _userData?['name'] as String?;
  String? get userEmail => _userData?['email'] as String?;
  String? get userPhone => _userData?['phone'] as String?;

  Map<String, dynamic>? _extractUserData(dynamic rawData) {
    if (rawData is Map<String, dynamic>) {
      if (rawData['user'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(rawData['user'] as Map);
      }
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
        print('ProfileController: Fetched user data: $_userData');
        _errorMessage = null;

      } else {
        _errorMessage = result['error'] ?? 'فشل في جلب بيانات المستخدم';
        _userData = null;
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
        _userData = _extractUserData(result['data']);
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
  Future<bool> updateLoggedUserPassword(String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _userService.updateLoggedUserPassword(
        password: password,
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
