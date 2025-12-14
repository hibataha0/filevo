import 'dart:convert';
import 'dart:io';
import 'package:filevo/services/api_service.dart';
import 'package:filevo/services/api_endpoints.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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
    if (email != null && email.isNotEmpty) {
      // ✅ التحقق من صحة البريد الإلكتروني قبل الإرسال
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(email.trim())) {
        return {
          'success': false,
          'error': 'Invalid email address',
        };
      }
      body['email'] = email.trim();
    }
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;

    // ✅ طباعة البيانات المرسلة للتحقق
    print('📤 Updating user data with: $body');

    final result = await _apiService.put(
      ApiEndpoints.updateMe,
      body: body,
      token: token,
    );

    return result;
  }

  /// تحديث كلمة مرور المستخدم المسجل
  Future<Map<String, dynamic>> updateLoggedUserPassword({
    required String currentPassword,
    required String password,
    required String passwordConfirm,
  }) async {
    final token = await StorageService.getToken();
    if (token == null) {
      return {
        'success': false,
        'error': 'لا يوجد token. يرجى تسجيل الدخول',
      };
    }

    // ✅ التحقق من أن كلمة المرور الجديدة وتأكيدها متطابقان
    if (password != passwordConfirm) {
      return {
        'success': false,
        'error': 'Password confirmation does not match',
      };
    }

    // ✅ التحقق من طول كلمة المرور
    if (password.length < 6) {
      return {
        'success': false,
        'error': 'Password must be at least 6 characters',
      };
    }

    final result = await _apiService.put(
      ApiEndpoints.changeMyPassword,
      body: {
        'currentPassword': currentPassword,
        'password': password,
        'passwordConfirm': passwordConfirm,
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

  /// رفع صورة البروفايل
  Future<Map<String, dynamic>> uploadProfileImage({
    required File imageFile,
  }) async {
    final token = await StorageService.getToken();
    if (token == null) {
      return {
        'success': false,
        'error': 'لا يوجد token. يرجى تسجيل الدخول',
      };
    }

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiEndpoints.updateMe}');
      final request = http.MultipartRequest('PUT', uri);

      print('📤 Uploading profile image to: $uri');
      print('📁 File path: ${imageFile.path}');
      print('📏 File size: ${await imageFile.length()} bytes');

      // ✅ إضافة الصورة مع اسم الحقل الصحيح
      // ✅ استخدام filename من path للحصول على اسم الملف
      final fileName = imageFile.path.split('/').last;
      
      // ✅ تحديد MIME type بناءً على امتداد الملف
      String? contentType;
      final extension = fileName.toLowerCase().split('.').last;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        case 'gif':
          contentType = 'image/gif';
          break;
        case 'webp':
          contentType = 'image/webp';
          break;
        default:
          contentType = 'image/jpeg'; // ✅ افتراضي
      }
      
      print('✅ File extension: $extension');
      print('✅ Content type: $contentType');
      
      final multipartFile = await http.MultipartFile.fromPath(
        'profileImg', 
        imageFile.path,
        filename: fileName,
        contentType: MediaType.parse(contentType), // ✅ إضافة MIME type صريح
      );
      request.files.add(multipartFile);
      
      print('✅ Added file to request: profileImg');
      print('✅ File name: $fileName');
      print('✅ Multipart file field name: ${multipartFile.field}');
      print('✅ Multipart file filename: ${multipartFile.filename}');
      print('✅ Multipart file content type: ${multipartFile.contentType}');

      // ✅ إضافة الـ token
      request.headers['Authorization'] = 'Bearer $token';
      // ✅ لا نضيف Content-Type يدوياً - MultipartRequest يضيفه تلقائياً مع boundary

      print('📤 Sending request...');
      
      // ✅ إرسال الطلب
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: $responseBody');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = jsonDecode(responseBody);
          print('✅ Upload successful');
          print('📦 Response data keys: ${data.keys.toList()}');
          
          // ✅ التحقق من وجود user في الـ response
          Map<String, dynamic>? userData;
          if (data['user'] != null) {
            print('✅ User data found in response');
            userData = data['user'] as Map<String, dynamic>;
            print('📝 User keys: ${userData.keys.toList()}');
          } else if (data['data'] != null) {
            print('✅ Data found in response');
            userData = data['data'] as Map<String, dynamic>;
            print('📝 Data keys: ${userData.keys.toList()}');
          } else {
            print('⚠️ No user or data field found, using entire response');
            userData = data as Map<String, dynamic>;
          }
          
          // ✅ التحقق من وجود profileImg في الـ response
          if (!userData.containsKey('profileImg')) {
            print('⚠️ WARNING: profileImg not found in response!');
            print('⚠️ This means the backend did not save/return the profile image.');
            print('⚠️ Please check the backend code to ensure profileImg is saved and returned.');
            print('⚠️ Full response data: $userData');
          } else if (userData['profileImg'] != null) {
            print('✅ profileImg found in response: ${userData['profileImg']}');
          } else {
            print('⚠️ WARNING: profileImg exists in response but is null!');
            print('⚠️ This means the backend did not save the profile image to the database.');
            print('⚠️ Please check:');
            print('  1. Is resizeProfileImage middleware saving the file?');
            print('  2. Is req.body.profileImg being set correctly?');
            print('  3. Is updateLoggedUserData saving req.body.profileImg to the database?');
            print('⚠️ Full response data: $userData');
          }
          
          // ✅ التحقق من profileImgUrl أيضاً
          if (userData.containsKey('profileImgUrl')) {
            if (userData['profileImgUrl'] != null) {
              print('✅ profileImgUrl found in response: ${userData['profileImgUrl']}');
            } else {
              print('⚠️ WARNING: profileImgUrl exists but is null!');
              print('⚠️ This usually means profileImg is null, so profileImgUrl cannot be built.');
            }
          }
          
          return {
            'success': true,
            'data': data,
          };
        } catch (e) {
          print('❌ Error parsing response: $e');
          print('❌ Response body (raw): $responseBody');
          return {
            'success': false,
            'error': 'خطأ في قراءة الاستجابة: ${e.toString()}',
          };
        }
      } else {
        try {
          final errorData = jsonDecode(responseBody);
          print('❌ Upload failed: ${errorData['message'] ?? errorData['error'] ?? 'Unknown error'}');
          print('❌ Error data: $errorData');
          return {
            'success': false,
            'error': errorData['message'] ?? errorData['error'] ?? 'فشل رفع الصورة',
            'statusCode': response.statusCode,
          };
        } catch (e) {
          print('❌ Error parsing error response: $e');
          print('❌ Response body (raw): $responseBody');
          return {
            'success': false,
            'error': 'فشل رفع الصورة: ${response.statusCode}',
            'statusCode': response.statusCode,
            'rawResponse': responseBody,
          };
        }
      }
    } catch (e) {
      print('❌ Error uploading profile image: $e');
      print('❌ Error type: ${e.runtimeType}');
      return {
        'success': false,
        'error': 'خطأ في رفع الصورة: ${e.toString()}',
      };
    }
  }
}










