import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiConfig {
  // ============================================================================
  // ⚙️ إعدادات السيرفر - عدّل هنا حسب بيئتك
  // ============================================================================
  
  // 🔧 خيار 1: استخدام IP محلي (للتطوير على نفس الشبكة)
  // اطلع IP جهازك: افتح CMD واكتب ipconfig وشوف IPv4 Address
  static const String _localIP = '192.168.0.81';  // 👈 غيّر هنا لـ IP جهازك!
  
  // 🔧 خيار 2: استخدام 10.0.2.2 للـ Android Emulator فقط
  static const String _emulatorIP = '10.0.2.2';
  
  // 🔧 خيار 3: استخدام localhost للتطوير على نفس الجهاز (iOS Simulator)
  static const String _localhost = 'localhost';
  
  // 🔧 خيار 4: استخدام ngrok أو domain حقيقي (للإنتاج أو الاختبار عن بعد)
  // غيّر هنا بالـ URL اللي ngrok يعطيك إياه
  static const String _ngrokURL = 'https://your-url-here.ngrok-free.app/api/v1';
  
  // رقم البورت اللي السيرفر شغّال عليه
  static const String _port = '8000';
  
  // ============================================================================
  
  // ============================================================================
  // 🎯 اختر الطريقة اللي تبيها (true = مفعّل، false = معطّل)
  // ============================================================================
  static const bool _useNgrok = false;  // 👈 غيّر لـ true عشان تستخدم ngrok
  static const bool _useEmulator = false;  // 👈 غيّر لـ true إذا تستخدم Emulator
  
  // Base URL للباك إند (متوافق مع المنصات)
  static String get baseUrl {
    String url;
    
    // ✅ أولوية 1: استخدام ngrok (الحل الأسهل والأضمن!)
    if (_useNgrok) {
      url = _ngrokURL;
      print('🚀 [ApiConfig] Using ngrok URL');
    }
    
    // ✅ أولوية 2: حسب المنصة
    else if (kIsWeb) {
      // للـ Web: استخدام نفس الـ host أو localhost
      final host = Uri.base.host.isEmpty ? _localhost : Uri.base.host;
      url = 'http://$host:$_port/api/v1';
      
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      if (_useEmulator) {
        // 🖥️ Android Emulator
        url = 'http://$_emulatorIP:$_port/api/v1';
        print('🖥️ [ApiConfig] Using Emulator IP');
      } else {
        // 📱 تلفون حقيقي (على نفس الشبكة)
        url = 'http://$_localIP:$_port/api/v1';
        print('📱 [ApiConfig] Using Local IP');
      }
      
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // للـ iOS Simulator: localhost يشتغل مباشرة
      url = 'http://$_localhost:$_port/api/v1';
      
    } else {
      // للمنصات الثانية: استخدام IP المحلي
      url = 'http://$_localIP:$_port/api/v1';
    }

    // طباعة الـ URL للـ debug
    print('🌐 [ApiConfig] Platform: ${defaultTargetPlatform.name}');
    print('🌐 [ApiConfig] Using baseUrl = $url');

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
