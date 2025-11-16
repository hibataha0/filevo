import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:filevo/config/api_config.dart';

class ApiService {
  // دالة GET عامة
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    String? token,
  }) async {
    try {
      Uri uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      
      // إضافة query parameters إن وجدت
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }
      
      // إعداد الـ headers
      Map<String, String> requestHeaders = token != null
          ? ApiConfig.headersWithToken(token)
          : ApiConfig.defaultHeaders;
      
      if (headers != null) {
        requestHeaders.addAll(headers);
      }
      
      final response = await http
          .get(uri, headers: requestHeaders)
          .timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // دالة POST عامة
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      
      // طباعة معلومات الطلب للـ debug
      print('POST Request to: $uri');
      print('Body: $body');
      
      // إعداد الـ headers
      Map<String, String> requestHeaders = token != null
          ? ApiConfig.headersWithToken(token)
          : ApiConfig.defaultHeaders;
      
      if (headers != null) {
        requestHeaders.addAll(headers);
      }
      
      final response = await http
          .post(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);
      
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      print('POST Error caught: $e');
      return _handleError(e);
    }
  }
  
  // دالة PUT عامة
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      
      // إعداد الـ headers
      Map<String, String> requestHeaders = token != null
          ? ApiConfig.headersWithToken(token)
          : ApiConfig.defaultHeaders;
      
      if (headers != null) {
        requestHeaders.addAll(headers);
      }
      
      final response = await http
          .put(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // دالة DELETE عامة
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      
      // إعداد الـ headers
      Map<String, String> requestHeaders = token != null
          ? ApiConfig.headersWithToken(token)
          : ApiConfig.defaultHeaders;
      
      if (headers != null) {
        requestHeaders.addAll(headers);
      }
      
      final response = await http
          .delete(uri, headers: requestHeaders)
          .timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // دالة PATCH عامة
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      
      // إعداد الـ headers
      Map<String, String> requestHeaders = token != null
          ? ApiConfig.headersWithToken(token)
          : ApiConfig.defaultHeaders;
      
      if (headers != null) {
        requestHeaders.addAll(headers);
      }
      
      final response = await http
          .patch(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // معالجة الاستجابة من السيرفر
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    
    try {
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      if (statusCode >= 200 && statusCode < 300) {
        return {
          'success': true,
          'data': data,
          'statusCode': statusCode,
        };
      } else {
        // محاولة استخراج رسالة الخطأ من الرد
        String errorMessage = 'حدث خطأ ما';
        
        if (data['message'] != null) {
          errorMessage = data['message'].toString();
        } else if (data['error'] != null) {
          errorMessage = data['error'].toString();
        } else if (data['errors'] != null) {
          // إذا كان errors array
          final errors = data['errors'];
          if (errors is List && errors.isNotEmpty) {
            // محاولة استخراج msg من error object
            final firstError = errors[0];
            if (firstError is Map && firstError['msg'] != null) {
              errorMessage = firstError['msg'].toString();
            } else {
              errorMessage = firstError.toString();
            }
          } else if (errors is Map && errors.isNotEmpty) {
            // إذا كان errors map (field: message)
            final firstValue = errors.values.first;
            if (firstValue is List && firstValue.isNotEmpty) {
              errorMessage = firstValue[0].toString();
            } else if (firstValue is Map && firstValue['msg'] != null) {
              errorMessage = firstValue['msg'].toString();
            } else {
              errorMessage = firstValue.toString();
            }
          }
        }
        
        print('API Error Response: Status=$statusCode, Message=$errorMessage');
        print('Full Error Data: $data');
        
        return {
          'success': false,
          'error': errorMessage,
          'data': data,
          'statusCode': statusCode,
        };
      }
    } catch (e) {
      // إذا كان الرد ليس JSON
      return {
        'success': statusCode >= 200 && statusCode < 300,
        'data': response.body,
        'statusCode': statusCode,
        'error': statusCode >= 300 ? 'حدث خطأ ما' : null,
      };
    }
  }
  
  // معالجة الأخطاء
  Map<String, dynamic> _handleError(dynamic error) {
    String errorMessage = 'حدث خطأ في الاتصال';
    
    // طباعة الخطأ للـ debug
    print('API Error: $error');
    print('Error Type: ${error.runtimeType}');
    
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('timeoutexception') || errorStr.contains('timeout')) {
      errorMessage = 'انتهت مهلة الاتصال، يرجى التأكد من أن السيرفر يعمل';
    } else if (errorStr.contains('socketexception') || errorStr.contains('failed host lookup') || errorStr.contains('connection refused')) {
      errorMessage = 'لا يمكن الاتصال بالسيرفر. تأكد من:\n- السيرفر يعمل على http://localhost:8000\n- CORS مفعّل في الباك إند';
    } else if (errorStr.contains('formatexception')) {
      errorMessage = 'خطأ في تنسيق البيانات';
    } else if (errorStr.contains('os error')) {
      errorMessage = 'خطأ في الاتصال بالشبكة';
    }
    
    return {
      'success': false,
      'error': errorMessage,
      'statusCode': 0,
      'details': error.toString(),
    };
  }




  
}

