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
      body: {
        'email': email,
        'password': password,
      },
    );

    // إذا نجح تسجيل الدخول، احفظ الـ token
    if (result['success'] == true && result['data'] != null) {
      final data = result['data'] as Map<String, dynamic>;
      final token = data['token'] as String?;
      final userId = data['user_id']?.toString() ?? data['userId']?.toString();

      if (token != null) {
        await StorageService.saveToken(token);
      }
      if (userId != null) {
        await StorageService.saveUserId(userId);
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
      'passwordConfirm': confirmPassword, // الباك إند يتوقع passwordConfirm (بسطر واحد)
      if (additionalData != null) ...additionalData,
    };

    print('AuthService: Registering with body: $body');
    print('AuthService: Using endpoint: ${ApiEndpoints.register}');

    final result = await _apiService.post(
      ApiEndpoints.register,
      body: body,
    );

    print('AuthService: Register result: $result');

    // إذا نجح التسجيل، احفظ الـ token
    if (result['success'] == true && result['data'] != null) {
      final data = result['data'] as Map<String, dynamic>;
      final token = data['token'] as String?;
      final userId = data['user_id']?.toString() ?? data['userId']?.toString();

      if (token != null) {
        await StorageService.saveToken(token);
        print('AuthService: Token saved successfully');
      }
      if (userId != null) {
        await StorageService.saveUserId(userId);
        print('AuthService: User ID saved: $userId');
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
    
    final result = await _apiService.post(
      ApiEndpoints.logout,
      token: token,
    );

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

