import 'package:filevo/services/api_service.dart';
import 'package:filevo/services/api_endpoints.dart';
import 'package:filevo/services/storage_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await _apiService.post(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
    );

    // إذا نجح تسجيل الدخول، احفظ الـ token و userId
    if (result['success'] == true) {
      // ✅ محاولة استخراج البيانات من أماكن مختلفة
      final data = (result['data'] is Map<String, dynamic>)
          ? (result['data'] as Map<String, dynamic>)
          : result;

      if (data.isNotEmpty) {
        final token =
            data['token']?.toString() ??
            data['accessToken']?.toString() ??
            data['access_token']?.toString();

        // ✅ محاولة استخراج userId من أماكن مختلفة
        String? userId =
            data['user_id']?.toString() ??
            data['userId']?.toString() ??
            data['user']?['_id']?.toString() ??
            data['user']?['id']?.toString() ??
            data['user']?['userId']?.toString() ??
            data['user']?['user_id']?.toString();

        if (token != null && token.isNotEmpty) {
          await StorageService.saveToken(token);
          print('✅ [AuthService] Token saved successfully (Login)');
          print('   Token preview: ${token.length > 20 ? token.substring(0, 20) + "..." : token}');
          // التحقق من أن التوكن تم حفظه فعلاً
          final savedToken = await StorageService.getToken();
          if (savedToken != null && savedToken == token) {
            print('✅ [AuthService] Token verified after saving (Login)');
          } else {
            print('⚠️ [AuthService] Token verification failed after saving (Login)');
          }
        } else {
          print('⚠️ [AuthService] Token is null or empty, not saving (Login)');
        }

        if (userId != null && userId.isNotEmpty) {
          await StorageService.saveUserId(userId);
          final displayId = userId.length > 20
              ? '${userId.substring(0, 20)}...'
              : userId;
          print('✅ [AuthService] User ID saved: $displayId');
        } else {
          print('⚠️ [AuthService] User ID not found in login response');
        }
      }
    }

    return result;
  }

  /// تسجيل مستخدم جديد
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String confirmPassword,
    Map<String, dynamic>? additionalData,
  }) async {
    final body = {
      'email': email,
      'password': password,
      'name': name,
      'passwordConfirm':
          confirmPassword, // الباك إند يتوقع passwordConfirm (بسطر واحد)
      if (additionalData != null) ...additionalData,
    };

    print('AuthService: Registering with body: $body');
    print('AuthService: Using endpoint: ${ApiEndpoints.register}');

    final result = await _apiService.post(ApiEndpoints.register, body: body);

    print('AuthService: Register result: $result');

    // إذا نجح التسجيل، احفظ الـ token و userId
    if (result['success'] == true) {
      // ✅ محاولة استخراج البيانات من أماكن مختلفة
      final data = (result['data'] is Map<String, dynamic>)
          ? (result['data'] as Map<String, dynamic>)
          : result;

      if (data.isNotEmpty) {
        final token =
            data['token']?.toString() ??
            data['accessToken']?.toString() ??
            data['access_token']?.toString();

        // ✅ محاولة استخراج userId من أماكن مختلفة
        String? userId =
            data['user_id']?.toString() ??
            data['userId']?.toString() ??
            data['user']?['_id']?.toString() ??
            data['user']?['id']?.toString() ??
            data['user']?['userId']?.toString() ??
            data['user']?['user_id']?.toString();

        if (token != null && token.isNotEmpty) {
          await StorageService.saveToken(token);
          print('✅ [AuthService] Token saved successfully (Registration)');
          print('   Token preview: ${token.length > 20 ? token.substring(0, 20) + "..." : token}');
          // التحقق من أن التوكن تم حفظه فعلاً
          final savedToken = await StorageService.getToken();
          if (savedToken != null && savedToken == token) {
            print('✅ [AuthService] Token verified after saving (Registration)');
          } else {
            print('⚠️ [AuthService] Token verification failed after saving (Registration)');
          }
        } else {
          print('⚠️ [AuthService] Token is null or empty, not saving (Registration)');
        }

        if (userId != null && userId.isNotEmpty) {
          await StorageService.saveUserId(userId);
          final displayId = userId.length > 20
              ? '${userId.substring(0, 20)}...'
              : userId;
          print('✅ [AuthService] User ID saved: $displayId');
        } else {
          print('⚠️ [AuthService] User ID not found in registration response');
        }
      }
    } else {
      print('AuthService: Registration failed - ${result['error']}');
      print('AuthService: Full error details: ${result['data']}');
    }

    return result;
  }

  /// تسجيل الخروج
  Future<Map<String, dynamic>> logout() async {
    final token = await StorageService.getToken();

    final result = await _apiService.post(ApiEndpoints.logout, token: token);

    // احذف الـ token المحفوظ محليًا
    await StorageService.deleteToken();

    return result;
  }

  /// التحقق من حالة تسجيل الدخول
  Future<bool> isLoggedIn() async {
    return await StorageService.isLoggedIn();
  }

  /// استرجاع الـ token الحالي
  Future<String?> getToken() async {
    return await StorageService.getToken();
  }

  // 1️⃣ Forgot Password
  // Forgot Password - تم التصحيح
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final result = await _apiService.post(
      ApiEndpoints.forgotPassword,
      body: {'email': email},
    );

    print('🔐 Forgot Password Response: $result');

    return result;
  }

  // Verify Reset Code - تم التصحيح
  Future<Map<String, dynamic>> verifyResetCode(String code) async {
    final result = await _apiService.post(
      ApiEndpoints.verifyResetCode,
      body: {'resetCode': code},
    );

    print('🔐 Verify Reset Code Response: $result');

    return result;
  }

  // Reset Password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final result = await _apiService.put(
      ApiEndpoints.resetPassword,
      body: {
        'email': email,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );

    print('🔐 Reset Password Response: $result');
    return result;
  }
}
