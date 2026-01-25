import 'dart:io';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

/// ✅ خدمة حماية الشاشة من Screenshot و Screen Recording
/// ✅ تعمل فقط على Android (flutter_windowmanager لا يدعم iOS)
class ScreenProtectionService {
  static bool _isProtectionEnabled = false;

  /// ✅ تفعيل الحماية من السكرين شوت والريكورد
  static Future<void> enableProtection() async {
    // ✅ التحقق من أن المنصة هي Android
    if (!Platform.isAndroid) {
      print('⚠️ Screen protection is only available on Android');
      print('   Current platform: ${Platform.operatingSystem}');
      return;
    }

    // ✅ تجنب التفعيل المتكرر
    if (_isProtectionEnabled) {
      print('ℹ️ Screen protection is already enabled');
      return;
    }

    try {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      _isProtectionEnabled = true;
      print('✅ Screen protection enabled successfully');
      print('   - Screenshots: BLOCKED');
      print('   - Screen recording: BLOCKED');
    } catch (e) {
      print('❌ Error enabling screen protection: $e');
      print('   Make sure flutter_windowmanager is properly configured');
      _isProtectionEnabled = false;
    }
  }

  /// ✅ إلغاء تفعيل الحماية من السكرين شوت والريكورد
  static Future<void> disableProtection() async {
    // ✅ التحقق من أن المنصة هي Android
    if (!Platform.isAndroid) {
      print('⚠️ Screen protection is only available on Android');
      return;
    }

    // ✅ تجنب الإلغاء المتكرر
    if (!_isProtectionEnabled) {
      print('ℹ️ Screen protection is already disabled');
      return;
    }

    try {
      await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      _isProtectionEnabled = false;
      print('✅ Screen protection disabled successfully');
      print('   - Screenshots: ALLOWED');
      print('   - Screen recording: ALLOWED');
    } catch (e) {
      print('❌ Error disabling screen protection: $e');
      _isProtectionEnabled = false;
    }
  }

  /// ✅ التحقق من حالة الحماية
  static bool get isProtectionEnabled => _isProtectionEnabled;

  /// ✅ التحقق من دعم المنصة
  static bool get isPlatformSupported => Platform.isAndroid;
}



