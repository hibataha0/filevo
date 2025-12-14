import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiConfig {
  // Base URL للباك إند (متوافق مع المنصات)
  static String get baseUrl {
    String url;
    if (kIsWeb) {
      final host = Uri.base.host.isEmpty ? 'localhost' : Uri.base.host;
      url = 'http://$host:8000/api/v1';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator يتطلب 10.0.2.2 للوصول إلى المضيف (localhost)
      url = 'http://10.0.2.2:8000/api/v1';
    } else {
      url = 'http://localhost:8000/api/v1';
    }

    // طباعة الـ URL للـ debug
    print('ApiConfig: Using baseUrl = $url');

    return url;
  }

  // Headers افتراضية
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // إضافة token للـ headers عند الحاجة
  static Map<String, String> headersWithToken(String token) {
    return {...defaultHeaders, 'Authorization': 'Bearer $token'};
  }

  // Timeout للطلبات (بالثواني)
  static const Duration timeout = Duration(seconds: 30);
}
