import 'package:shared_preferences/shared_preferences.dart';

/// خدمة لحفظ واسترجاع البيانات المحلية مثل الـ token
class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _folderViewModeKey = 'folder_view_is_grid';

  // حفظ الـ token
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      print('✅ [StorageService] Token saved successfully');
      print('   Token length: ${token.length}');
      // التحقق من أن التوكن تم حفظه فعلاً
      final savedToken = await prefs.getString(_tokenKey);
      if (savedToken != null && savedToken == token) {
        print('✅ [StorageService] Token verified - saved correctly');
      } else {
        print('⚠️ [StorageService] Token verification failed');
      }
    } catch (e) {
      print('❌ [StorageService] Error saving token: $e');
      rethrow;
    }
  }

  // استرجاع الـ token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null) {
        print(
          '✅ [StorageService] Token retrieved successfully (length: ${token.length})',
        );
      } else {
        print('⚠️ [StorageService] No token found in storage');
      }
      return token;
    } catch (e) {
      print('❌ [StorageService] Error retrieving token: $e');
      return null;
    }
  }

  // حذف الـ token (للخروج)
  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // حفظ معرف المستخدم
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  // استرجاع معرف المستخدم
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // حذف معرف المستخدم
  static Future<void> deleteUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  // التحقق من وجود token (المستخدم مسجل دخول)
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    final isLoggedIn = token != null && token.isNotEmpty;
    print('🔑 [StorageService] isLoggedIn check: $isLoggedIn');
    return isLoggedIn;
  }

  // ✅ حفظ المود (Dark/Light)
  static Future<void> saveThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_mode', isDarkMode);
  }

  // ✅ جلب المود المحفوظ
  static Future<bool?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('theme_mode');
  }

  // ✅ حفظ تفضيل عرض المجلدات (Grid/List)
  static Future<void> saveFolderViewIsGrid(bool isGrid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_folderViewModeKey, isGrid);
  }

  // ✅ استرجاع تفضيل عرض المجلدات (Grid/List)
  static Future<bool?> getFolderViewIsGrid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_folderViewModeKey);
  }
}
