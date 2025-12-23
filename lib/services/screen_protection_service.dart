import 'package:flutter_windowmanager/flutter_windowmanager.dart';

class ScreenProtectionService {
  /// ✅ تفعيل الحماية من السكرين شوت والريكورد
  static Future<void> enableProtection() async {
    try {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      print('✅ Screen protection enabled');
    } catch (e) {
      print('❌ Error enabling screen protection: $e');
    }
  }

  /// ✅ إلغاء تفعيل الحماية من السكرين شوت والريكورد
  static Future<void> disableProtection() async {
    try {
      await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      print('✅ Screen protection disabled');
    } catch (e) {
      print('❌ Error disabling screen protection: $e');
    }
  }
}


