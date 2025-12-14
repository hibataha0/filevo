import 'dart:convert';
import 'package:filevo/services/api_endpoints.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/config/api_config.dart';
import 'package:http/http.dart' as http;

class ActivityService {
  final String _apiBase = ApiConfig.baseUrl;

  /// ✅ جلب سجل النشاط للمستخدم
  Future<Map<String, dynamic>> getUserActivityLog({
    int page = 1,
    int limit = 20,
    String? action,
    String? entityType,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'لا يوجد token. يرجى تسجيل الدخول'};
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (action != null && action.isNotEmpty) {
        queryParams['action'] = action;
      }
      if (entityType != null && entityType.isNotEmpty) {
        queryParams['entityType'] = entityType;
      }
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['startDate'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['endDate'] = endDate;
      }

      final uri = Uri.parse(
        '$_apiBase${ApiEndpoints.activityLog}',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'activities': data['activities'] ?? [],
          'pagination': data['pagination'] ?? {},
          'filters': data['filters'] ?? {},
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'error': data['message'] ?? 'فشل في جلب سجل النشاط',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في جلب سجل النشاط: ${e.toString()}',
      };
    }
  }

  /// ✅ جلب إحصائيات النشاط
  Future<Map<String, dynamic>> getActivityStatistics({int days = 30}) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'لا يوجد token. يرجى تسجيل الدخول'};
      }

      final uri = Uri.parse(
        '$_apiBase${ApiEndpoints.activityStatistics}',
      ).replace(queryParameters: {'days': days.toString()});

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'statistics': data['statistics'] ?? {}};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'error': data['message'] ?? 'فشل في جلب إحصائيات النشاط',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في جلب إحصائيات النشاط: ${e.toString()}',
      };
    }
  }

  /// ✅ حذف سجلات النشاط القديمة
  Future<Map<String, dynamic>> clearOldActivityLogs({
    int daysToKeep = 90,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'لا يوجد token. يرجى تسجيل الدخول'};
      }

      final uri = Uri.parse(
        '$_apiBase${ApiEndpoints.clearOldActivityLogs}',
      ).replace(queryParameters: {'days': daysToKeep.toString()});

      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'تم حذف السجلات القديمة بنجاح',
          'deletedCount': data['deletedCount'] ?? 0,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'error': data['message'] ?? 'فشل في حذف السجلات القديمة',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في حذف السجلات القديمة: ${e.toString()}',
      };
    }
  }
}



