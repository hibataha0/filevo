import 'package:filevo/services/api_service.dart';
import 'package:filevo/services/api_endpoints.dart';
import 'package:filevo/services/storage_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  /// الحصول على بيانات المستخدم المسجل
  Future<Map<String, dynamic>> getLoggedUserData() async {
    final token = await StorageService.getToken();
    if (token == null) {
      return {
        'success': false,
        'error': 'لا يوجد token. يرجى تسجيل الدخول',
      };
    }

    final result = await _apiService.get(
      ApiEndpoints.getMe,
      token: token,
    );

    return result;
  }

  /// تحديث بيانات المستخدم المسجل
  Future<Map<String, dynamic>> updateLoggedUserData({
    String? name,
    String? email,
    String? phone,
  }) async {
    final token = await StorageService.getToken();
    if (token == null) {
      return {
        'success': false,
        'error': 'لا يوجد token. يرجى تسجيل الدخول',
      };
    }

    final body = <String, dynamic>{};
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;

    final result = await _apiService.put(
      ApiEndpoints.updateMe,
      body: body,
      token: token,
    );

    return result;
  }

  /// تحديث كلمة مرور المستخدم المسجل
  Future<Map<String, dynamic>> updateLoggedUserPassword({
    required String password,
  }) async {
    final token = await StorageService.getToken();
    if (token == null) {
      return {
        'success': false,
        'error': 'لا يوجد token. يرجى تسجيل الدخول',
      };
    }

    final result = await _apiService.put(
      ApiEndpoints.changeMyPassword,
      body: {
        'password': password,
      },
      token: token,
    );

    // ✅ إذا نجح تحديث كلمة المرور، احفظ الـ token الجديد
    if (result['success'] == true && result['data'] != null) {
      final data = result['data'] as Map<String, dynamic>;
      final newToken = data['token'] as String?;
      if (newToken != null) {
        await StorageService.saveToken(newToken);
      }
    }

    return result;
  }

  /// حذف حساب المستخدم المسجل
  Future<Map<String, dynamic>> deleteLoggedUserData() async {
    final token = await StorageService.getToken();
    if (token == null) {
      return {
        'success': false,
        'error': 'لا يوجد token. يرجى تسجيل الدخول',
      };
    }

    final result = await _apiService.delete(
      ApiEndpoints.deleteMe,
      token: token,
    );

    // ✅ إذا نجح الحذف، احذف الـ token
    if (result['success'] == true) {
      await StorageService.deleteToken();
      await StorageService.deleteUserId();
    }

    return result;
  }
}









