import 'package:filevo/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:filevo/services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _needsEmailVerification = false; // ✅ يحتاج إلى تفعيل البريد الإلكتروني
  String? _unverifiedEmail; // ✅ البريد الإلكتروني غير المفعل

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get needsEmailVerification => _needsEmailVerification;
  String? get unverifiedEmail => _unverifiedEmail;

  Future<bool> login({
    required String emailOrUsername,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    _needsEmailVerification = false;
    _unverifiedEmail = null;

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
      final errorMsg =
          result['error'] as String? ??
          result['message'] as String? ??
          'حدث خطأ غير معروف';

      // ✅ التحقق من أن الخطأ متعلق بعدم تفعيل البريد الإلكتروني
      // ✅ التحقق من requiresVerification في الـ response
      if (result['requiresVerification'] == true ||
          errorMsg.contains('تفعيل') ||
          errorMsg.contains('emailVerified') ||
          errorMsg.contains('email verification') ||
          errorMsg.contains('يرجى تفعيل')) {
        _needsEmailVerification = true;
        // ✅ استخدام email من الـ response إذا كان موجوداً
        _unverifiedEmail =
            result['email'] as String? ??
            (emailOrUsername.contains('@') ? emailOrUsername : null);
        // ✅ إذا لم يكن email، نحتاج إلى جلب email من السيرفر
        // لكن في هذه الحالة، سنستخدم emailOrUsername مباشرة
        if (_unverifiedEmail == null) {
          _unverifiedEmail = emailOrUsername; // ✅ سنستخدمه كـ email محتمل
        }
        print('AuthController: Account needs email verification');
        print('AuthController: Unverified email: $_unverifiedEmail');
      }

      print('AuthController: Login failed: $errorMsg');
      print('AuthController: Error details: ${result['details']}');
      _setError(errorMsg);
      return false;
    }
  }

  Future<Map<String, dynamic>> register({
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
      confirmPassword: confirmPassword,
    );
    _setLoading(false);

    print('AuthController: Register result: $result');

    if (result['success'] == true) {
      // ✅ بعد التسجيل، لا يتم إرجاع token مباشرة
      // ✅ يتم إرجاع userId و email فقط - يحتاج المستخدم للتحقق من البريد الإلكتروني
      return {
        'success': true,
        'userId': result['userId'],
        'email': result['email'] ?? email,
      };
    } else {
      final errorMsg = result['error'] as String? ?? 'حدث خطأ غير معروف';
      print('AuthController: Register failed: $errorMsg');
      print('AuthController: Error details: ${result['details']}');
      _setError(errorMsg);
      return {'success': false, 'error': errorMsg};
    }
  }

  // ✅ التحقق من كود البريد الإلكتروني
  Future<bool> verifyEmailCode({
    required String email,
    required String verificationCode,
  }) async {
    _setLoading(true);
    _setError(null);
    _setSuccess(null);

    print('AuthController: Verifying email code...');
    final result = await _authService.verifyEmailCode(
      email: email,
      verificationCode: verificationCode,
    );
    _setLoading(false);

    print('AuthController: Verify email code result: $result');

    if (result['success'] == true) {
      // ✅ حفظ token إذا كان موجوداً
      if (result['token'] != null) {
        await StorageService.saveToken(result['token']);
      }
      _setSuccess(result['message'] ?? 'تم تفعيل الحساب بنجاح');
      return true;
    } else {
      final errorMsg =
          result['error'] as String? ??
          result['message'] ??
          'كود التحقق غير صحيح';
      _setError(errorMsg);
      return false;
    }
  }

  // ✅ إعادة إرسال كود التحقق
  Future<bool> resendVerificationCode(String email) async {
    _setLoading(true);
    _setError(null);
    _setSuccess(null);

    print('AuthController: Resending verification code...');
    final result = await _authService.resendVerificationCode(email);
    _setLoading(false);

    print('AuthController: Resend verification code result: $result');

    if (result['success'] == true) {
      _setSuccess(
        result['message'] ?? 'تم إرسال كود التحقق إلى بريدك الإلكتروني',
      );
      return true;
    } else {
      final errorMsg =
          result['error'] as String? ??
          result['message'] ??
          'فشل في إرسال كود التحقق';
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
    _needsEmailVerification = false;
    _unverifiedEmail = null;
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
      _setSuccess(
        result['message'] ?? 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
      );
      return true;
    } else {
      _setError(
        result['message'] ?? result['error'] ?? 'فشل في إرسال رمز التحقق',
      );
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
      _setError(
        result['message'] ??
            result['error'] ??
            'الرمز غير صالح أو منتهي الصلاحية',
      );
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
      _setError(
        result['message'] ??
            result['error'] ??
            'فشل في إعادة تعيين كلمة المرور',
      );
      return false;
    }
  }
}
