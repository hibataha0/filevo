import 'package:filevo/services/storage_service.dart';
import 'package:filevo/services/user_cache_service.dart';
import 'package:filevo/services/notification_service.dart'; // ✅ إضافة خدمة الإشعارات
import 'package:flutter/material.dart';
import 'package:filevo/services/auth_service.dart';
import 'package:filevo/generated/l10n.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserCacheService _userCacheService = UserCacheService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _needsEmailVerification = false;
  String? _unverifiedEmail;
  String? _unverifiedUserId; // ✅ إضافة حقل لحفظ معرف المستخدم غير المفعل

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get needsEmailVerification => _needsEmailVerification;
  String? get unverifiedEmail => _unverifiedEmail;
  String? get unverifiedUserId => _unverifiedUserId; // ✅ getter للمعرف

  Future<bool> login({
    required String emailOrUsername,
    required String password,
    BuildContext? context, // ✅ لإظهار الرسائل intl
  }) async {
    _setLoading(true);
    _setError(null);
    _needsEmailVerification = false;
    _unverifiedEmail = null;
    _unverifiedUserId = null; // ✅ تعيين المعرف للقيمة null عند كل محاولة تسجيل دخول

    print('AuthController: Attempting login...');
    final result = await _authService.login(
      email: emailOrUsername,
      password: password,
    );
    _setLoading(false);

    print('AuthController: Login result: $result');

    if (result['success'] == true) {
      // ✅ مسح الـ cache عند تسجيل دخول جديد
      _userCacheService.clearCache();
      print('🎯 AuthController: Login successful! Starting cleanup...');

      // ✅ 1. مسح كل البيانات القديمة أولاً
      print('🧹 [Step 1/5] Clearing old user cache...');
      _userCacheService.clearCache();

      print('🧹 [Step 2/5] Deleting old token...');
      await StorageService.deleteToken();

      print('🧹 [Step 3/5] Deleting old userId...');
      await StorageService.deleteUserId();

      print("===============token221: ${result['data']['data']['token']}");
      print("===============userId221: ${result['data']['data']['email']}");

      print('result ${result.toString()}');

      // ✅ 2. حفظ التوكن الجديد
      if (result["data"]["data"]["token"] != null) {
        final newToken = result["data"]["data"]["token"] as String;
        print('💾 [Step 4/5] Saving new token (length: ${newToken.length})...');
        await StorageService.saveToken(newToken);

        // ✅ التحقق من أن التوكن تم حفظه فعلاً
        final savedToken = await StorageService.getToken();
        if (savedToken == newToken) {
          print('✅ [Step 5/5] New token verified and saved correctly!');
        } else {
          print('❌ [Step 5/5] ERROR: Token verification failed!');
          print('   Expected: ${newToken.substring(0, 20)}...');
          print('   Got: ${savedToken?.substring(0, 20)}...');
        }
      } else {
        print('⚠️ WARNING: No token in login response!');
        print('   Response keys: ${result.keys.toList()}');
      }

      print('✅ AuthController: Login process completed successfully!');

      // ✅ تحديث الـ FCM Token للسيرفر بعد تسجيل الدخول
      print('🔍 [AuthController] Checking for FCM Token...');
      final fcmToken = await StorageService.getFCMToken();
      print('================🔍 [AuthController] FCM Token found: $fcmToken');
      if (fcmToken != null) {
        print('📱 [AuthController] Updating FCM Token on server...');
        await NotificationService().updateTokenOnServer(fcmToken);
      } else {
        print('⚠️ [AuthController] No FCM Token found in storage to update');
      }

      return true;
    } else {
      final errorMsg =
          result['error'] as String? ??
          result['message'] as String? ??
          (context != null ? S.of(context).unknownError : 'حدث خطأ غير معروف');

      final errorData = result['data'] as Map<String, dynamic>?;

      if (errorData != null && errorData['isVerified'] == false) {
        _needsEmailVerification = true;
        _unverifiedEmail = emailOrUsername;
        _unverifiedUserId = errorData['userId']?.toString() ?? errorData['_id']?.toString(); // ✅ جلب المعرف من الرد
        print('AuthController: Account needs email verification (from isVerified flag)');
        print('AuthController: Unverified email: $_unverifiedEmail, UserId: $_unverifiedUserId');
      } else if (result['requiresVerification'] == true ||
          errorMsg.contains('تفعيل') ||
          errorMsg.contains('emailVerified') ||
          errorMsg.contains('email verification') ||
          errorMsg.contains('يرجى تفعيل')) {
        _needsEmailVerification = true;
        _unverifiedEmail =
            result['email'] as String? ??
            (emailOrUsername.contains('@') ? emailOrUsername : null);
        _unverifiedUserId = result['userId']?.toString() ?? result['data']?['userId']?.toString(); // ✅ جلب المعرف
        if (_unverifiedEmail == null) {
          _unverifiedEmail = emailOrUsername;
        }
        print('AuthController: Account needs email verification (from fallback check)');
        print('AuthController: Unverified email: $_unverifiedEmail, UserId: $_unverifiedUserId');
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
    BuildContext? context,
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
      return {
        'success': true,
        'userId': result['userId'],
        'email': result['email'] ?? email,
      };
    } else {
      final errorMsg =
          result['error'] as String? ??
          (context != null ? S.of(context).unknownError : 'حدث خطأ غير معروف');
      print('AuthController: Register failed: $errorMsg');
      print('AuthController: Error details: ${result['details']}');
      _setError(errorMsg);
      return {'success': false, 'error': errorMsg};
    }
  }

  Future<bool> verifyEmailCode({
    required String email,
    required String? userId, // ✅ إضافة userId هنا
    required String verificationCode,
    BuildContext? context,
  }) async {
    _setLoading(true);
    _setError(null);
    _setSuccess(null);

    print('AuthController: Verifying email code for UserId: $userId...');
    final result = await _authService.verifyEmailCode(
      email: email,
      userId: userId, // ✅ تمرير userId للخدمة
      verificationCode: verificationCode,
    );
    _setLoading(false);

    print('AuthController: Verify email code result: $result');

    if (result['success'] == true) {
      if (result['token'] != null) {
        await StorageService.saveToken(result['token']);

        // ✅ تحديث الـ FCM Token للسيرفر بعد التفعيل الناجح (لأنه يعتبر تسجيل دخول)
        final fcmToken = await StorageService.getFCMToken();
        if (fcmToken != null) {
          print('📱 [AuthController] Updating FCM Token after verification...');
          await NotificationService().updateTokenOnServer(fcmToken);
        }
      }
      _setSuccess(
        result['message'] ??
            (context != null
                ? S.of(context).emailVerifiedSuccess
                : 'تم تفعيل الحساب بنجاح'),
      );
      return true;
    } else {
      final errorMsg =
          result['error'] as String? ??
          result['message'] ??
          (context != null
              ? S.of(context).verificationCodeIncorrect
              : 'كود التحقق غير صحيح');
      _setError(errorMsg);
      return false;
    }
  }

  Future<bool> resendVerificationCode(
    String email, {
    BuildContext? context,
  }) async {
    _setLoading(true);
    _setError(null);
    _setSuccess(null);

    print('AuthController: Resending verification code...');
    final result = await _authService.resendVerificationCode(email);
    _setLoading(false);

    print('AuthController: Resend verification code result: $result');

    if (result['success'] == true) {
      _setSuccess(
        result['message'] ??
            (context != null
                ? S.of(context).verificationCodeSent
                : 'تم إرسال كود التحقق إلى بريدك الإلكتروني'),
      );
      return true;
    } else {
      final errorMsg =
          result['error'] as String? ??
          result['message'] ??
          (context != null
              ? S.of(context).verificationCodeResendFailed
              : 'فشل في إرسال كود التحقق');
      _setError(errorMsg);
      return false;
    }
  }

  Future<void> logout() async {
    // ✅ مسح الـ cache عند تسجيل الخروج
    _userCacheService.clearCache();

    // ✅ مسح الـ cache قبل تسجيل الخروج
    print('🧹 AuthController: Clearing user cache on logout...');
    _userCacheService.clearCache();

    await _authService.logout();
    print('✅ AuthController: Logout completed');
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
    _unverifiedUserId = null;
    notifyListeners();
  }

  Future<bool> forgotPassword(String email, {BuildContext? context}) async {
    _setLoading(true);
    _setError(null);
    _setSuccess(null);

    final result = await _authService.forgotPassword(email);
    _setLoading(false);

    print('🎯 Forgot Password Result: $result');

    if (result['status'] == 'Success' ||
        result['success'] == true ||
        result['message']?.toString().contains('sent') == true) {
      _setSuccess(
        result['message'] ??
            (context != null
                ? S.of(context).forgotPasswordSuccess
                : 'تم إرسال رمز التحقق إلى بريدك الإلكتروني'),
      );
      return true;
    } else {
      _setError(
        result['message'] ??
            result['error'] ??
            (context != null
                ? S.of(context).forgotPasswordFailed
                : 'فشل في إرسال رمز التحقق'),
      );
      return false;
    }
  }

  Future<bool> verifyResetCode(String code, {BuildContext? context}) async {
    _setLoading(true);
    _setError(null);
    _setSuccess(null);

    final result = await _authService.verifyResetCode(code);
    _setLoading(false);

    print('🎯 Verify Reset Code Result: $result');

    if (result['status'] == 'Success' ||
        result['success'] == true ||
        result['data'] != null) {
      _setSuccess(
        result['message'] ??
            (context != null
                ? S.of(context).resetCodeVerified
                : 'تم التحقق من الرمز بنجاح'),
      );
      return true;
    } else {
      _setError(
        result['message'] ??
            result['error'] ??
            (context != null
                ? S.of(context).resetCodeInvalid
                : 'الرمز غير صالح أو منتهي الصلاحية'),
      );
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
    BuildContext? context,
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

    if (result['token'] != null ||
        result['status'] == 'Success' ||
        result['success'] == true) {
      _setSuccess(
        result['message'] ??
            (context != null
                ? S.of(context).resetPasswordSuccess
                : 'تم إعادة تعيين كلمة المرور بنجاح'),
      );
      return true;
    } else {
      _setError(
        result['message'] ??
            result['error'] ??
            (context != null
                ? S.of(context).resetPasswordFailed
                : 'فشل في إعادة تعيين كلمة المرور'),
      );
      return false;
    }
  }
}
