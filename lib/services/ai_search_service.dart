import 'dart:convert';
import 'package:filevo/services/api_endpoints.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/storage_service.dart';

/// خدمة البحث الذكي باستخدام AI
/// تدعم البحث الشامل والبحث داخل روم محدد
class AiSearchService {
  /// البحث الذكي الشامل
  /// 
  /// [query]: نص البحث (عربي/إنجليزي)
  /// [scope]: نطاق البحث - "all", "my-files", "shared", "rooms"
  /// 
  /// Returns:
  /// - results: تحتوي على files, rooms, folders, comments
  /// - interpreted: تحليل الاستعلام (searchText, searchType, filters, intent)
  /// - total: العدد الإجمالي للنتائج
  Future<Map<String, dynamic>> smartSearch({
    required String query,
    String scope = 'all',
  }) async {
    final token = await StorageService.getToken();
    
    // ✅ إضافة فحص للـ token
    if (token == null) {
      return {
        'success': false,
        'error': 'لا يوجد token. يرجى تسجيل الدخول',
      };
    }

    try {
      final uri = Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.smartSearch}")
          .replace(queryParameters: {
        'query': query,
        'scope': scope,
      });

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 30)); // ✅ إضافة timeout

      // ✅ معالجة أفضل للأخطاء
      if (response.statusCode == 200) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {
            'success': false,
            'error': 'خطأ في قراءة الاستجابة',
            'details': e.toString(),
          };
        }
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return {
            'success': false,
            'error': errorBody['message'] ?? 'فشل البحث الذكي',
            'statusCode': response.statusCode,
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'فشل البحث الذكي: ${response.statusCode}',
            'statusCode': response.statusCode,
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'حدث خطأ في الاتصال: ${e.toString()}',
      };
    }
  }

  /// البحث الذكي داخل روم محدد
  /// 
  /// [roomId]: معرف الروم
  /// [query]: نص البحث (عربي/إنجليزي)
  /// 
  /// Returns:
  /// - results: تحتوي على files, folders, comments داخل الروم
  /// - interpreted: تحليل الاستعلام
  /// - total: العدد الإجمالي للنتائج
  Future<Map<String, dynamic>> smartSearchInRoom({
    required String roomId,
    required String query,
  }) async {
    final token = await StorageService.getToken();

    final uri = Uri.parse(
            "${ApiConfig.baseUrl}${ApiEndpoints.smartSearchInRoom(roomId)}")
        .replace(queryParameters: {
      'query': query,
    });

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'فشل البحث داخل الروم');
    }
  }
}

