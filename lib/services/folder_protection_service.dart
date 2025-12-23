import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:filevo/config/api_config.dart';
import 'package:filevo/services/storage_service.dart';

/// ✅ Service لإدارة حماية المجلدات (كلمة سر / بصمة)
class FolderProtectionService {
  /// ✅ تعيين حماية للمجلد (كلمة سر أو بصمة)
  static Future<Map<String, dynamic>> setFolderProtection({
    required String folderId,
    String? password,
    String protectionType = 'password', // 'password' or 'biometric'
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'يجب تسجيل الدخول أولاً',
        };
      }

      // ✅ التحقق من البيانات
      if (protectionType == 'password' && (password == null || password.isEmpty)) {
        return {
          'success': false,
          'message': 'كلمة السر مطلوبة',
        };
      }

      if (protectionType == 'biometric' && password != null) {
        return {
          'success': false,
          'message': 'البصمة لا تحتاج كلمة سر',
        };
      }

      final body = <String, dynamic>{
        'protectionType': protectionType,
      };

      if (protectionType == 'password' && password != null) {
        body['password'] = password;
      } else if (protectionType == 'biometric') {
        // ✅ للبصمة، نرسل token (يتم توليده في الفرونت بعد نجاح البصمة)
        body['biometricToken'] = 'biometric_verified';
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/folders/$folderId/protect'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'تم تفعيل الحماية بنجاح',
          'folder': responseData['folder'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'فشل تفعيل الحماية',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ: ${e.toString()}',
      };
    }
  }

  /// ✅ التحقق من الوصول للمجلد (كلمة سر أو بصمة)
  static Future<Map<String, dynamic>> verifyFolderAccess({
    required String folderId,
    String? password,
    String? biometricToken,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'يجب تسجيل الدخول أولاً',
        };
      }

      final body = <String, dynamic>{};
      if (password != null) {
        body['password'] = password;
      }
      if (biometricToken != null) {
        body['biometricToken'] = biometricToken;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/folders/$folderId/verify-access'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'hasAccess': responseData['hasAccess'] ?? true,
          'message': responseData['message'] ?? 'تم التحقق بنجاح',
          'folder': responseData['folder'],
        };
      } else {
        return {
          'success': false,
          'hasAccess': false,
          'message': responseData['message'] ?? 'فشل التحقق',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'hasAccess': false,
        'message': 'حدث خطأ: ${e.toString()}',
      };
    }
  }

  /// ✅ إزالة حماية المجلد
  static Future<Map<String, dynamic>> removeFolderProtection({
    required String folderId,
    required String password, // ✅ مطلوب للتحقق قبل الإزالة
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'يجب تسجيل الدخول أولاً',
        };
      }

      if (password.isEmpty) {
        return {
          'success': false,
          'message': 'كلمة السر مطلوبة لإزالة الحماية',
        };
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/folders/$folderId/protect'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'password': password}),
      ).timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'تم إزالة الحماية بنجاح',
          'folder': responseData['folder'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'فشل إزالة الحماية',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ: ${e.toString()}',
      };
    }
  }

  /// ✅ التحقق من أن المجلد محمي
  static bool isFolderProtected(Map<String, dynamic> folder) {
    return folder['isProtected'] == true || folder['isProtected'] == 'true';
  }

  /// ✅ الحصول على نوع الحماية
  static String getProtectionType(Map<String, dynamic> folder) {
    return folder['protectionType']?.toString() ?? 'none';
  }
}

