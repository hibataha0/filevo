import 'package:flutter/material.dart';
import 'package:filevo/services/storage_service.dart';

class ThemeController extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isLoading = true;

  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;

  ThemeController() {
    _loadThemeMode();
  }

  /// ✅ تحميل المود المحفوظ
  Future<void> _loadThemeMode() async {
    try {
      final savedMode = await StorageService.getThemeMode();
      if (savedMode != null) {
        _isDarkMode = savedMode;
      }
    } catch (e) {
      print('Error loading theme mode: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ تغيير المود وحفظه
  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners(); // ✅ تحديث فوري للـ UI
    
    try {
      await StorageService.saveThemeMode(value);
      print('✅ Theme mode saved: $value');
    } catch (e) {
      print('❌ Error saving theme mode: $e');
    }
  }
}
