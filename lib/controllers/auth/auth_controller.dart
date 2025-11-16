import 'package:filevo/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:filevo/services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
String? get successMessage => _successMessage;

 
  Future<bool> login({
    required String emailOrUsername,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    print('AuthController: Attempting login...');
    final result = await _authService.login(
      email: emailOrUsername,
      password: password,
    );
    _setLoading(false);

    print('AuthController: Login result: $result');
    
    if (result['success'] == true) {
      // حفظ التوكن لو موجود
      if (result['token'] != null) {
        await StorageService.saveToken(result['token']);
      }
      return true;
    } else {
      final errorMsg = result['error'] as String? ?? 'حدث خطأ غير معروف';
      print('AuthController: Login failed: $errorMsg');
      print('AuthController: Error details: ${result['details']}');
      _setError(errorMsg);
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
     required String confirmPassword, 
  }) async {
    _setLoading(true);
    _setError(null);
    print('AuthController: Attempting register...');
    final result = await _authService.register(
      name: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword, // ✅ أرسله هنا
    );
    _setLoading(false);

    print('AuthController: Register result: $result');
    
    if (result['success'] == true) {
      if (result['token'] != null) {
        await StorageService.saveToken(result['token']);
      }
      return true;
    } else {
      final errorMsg = result['error'] as String? ?? 'حدث خطأ غير معروف';
      print('AuthController: Register failed: $errorMsg');
      print('AuthController: Error details: ${result['details']}');
      _setError(errorMsg);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
  void _setSuccess(String? message) {
    _successMessage = message;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
  // Forgot password
 // Forgot password - تم التصحيح
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _setError(null);
    _setSuccess(null);

    final result = await _authService.forgotPassword(email);
    _setLoading(false);

    print('🎯 Forgot Password Result: $result');

    // التحقق من الاستجابة بطرق مختلفة
    if (result['status'] == 'Success' || 
        result['success'] == true || 
        result['message']?.toString().contains('sent') == true) {
      _setSuccess(result['message'] ?? 'تم إرسال رمز التحقق إلى بريدك الإلكتروني');
      return true;
    } else {
      _setError(result['message'] ?? result['error'] ?? 'فشل في إرسال رمز التحقق');
      return false;
    }
  }

  // Verify reset code - تم التصحيح
  Future<bool> verifyResetCode(String code) async {
    _setLoading(true);
    _setError(null);
    _setSuccess(null);

    final result = await _authService.verifyResetCode(code);
    _setLoading(false);

    print('🎯 Verify Reset Code Result: $result');

    // التحقق من الاستجابة بطرق مختلفة
    if (result['status'] == 'Success' || 
        result['success'] == true || 
        result['data'] != null) {
      _setSuccess(result['message'] ?? 'تم التحقق من الرمز بنجاح');
      return true;
    } else {
      _setError(result['message'] ?? result['error'] ?? 'الرمز غير صالح أو منتهي الصلاحية');
      return false;
    }
  }

    // Reset Password
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _setError(null);
    _setSuccess(null);

    final result = await _authService.resetPassword(
      email: email,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    _setLoading(false);

    print('🎯 Reset Password Result: $result');

    if (result['token'] != null) {
      _setSuccess(result['message'] ?? 'تم إعادة تعيين كلمة المرور بنجاح');
      return true;
    } else if (result['status'] == 'Success') {
      _setSuccess(result['message'] ?? 'تم إعادة تعيين كلمة المرور بنجاح');
      return true;
    } else if (result['success'] == true) {
      _setSuccess('تم إعادة تعيين كلمة المرور بنجاح');
      return true;
    } else {
      _setError(result['message'] ?? result['error'] ?? 'فشل في إعادة تعيين كلمة المرور');
      return false;
    }
  }

}


