import 'dart:async';
import 'package:filevo/services/user_service.dart';

/// 🎯 User Cache Service - لمنع multiple requests لـ getMe
class UserCacheService {
  static final UserCacheService _instance = UserCacheService._internal();
  factory UserCacheService() => _instance;
  UserCacheService._internal();

  /// البيانات المخزنة في الذاكرة
  Map<String, dynamic>? _cachedUserData;
  
  /// وقت آخر تحديث للبيانات
  DateTime? _lastFetchTime;
  
  /// مدة صلاحية الـ cache (دقيقة واحدة فقط)
  final Duration _cacheDuration = const Duration(seconds: 30);
  
  /// طلب شغال حالياً
  Future<Map<String, dynamic>>? _pendingRequest;

  /// الحصول على بيانات المستخدم (مع cache)
  Future<Map<String, dynamic>> getLoggedUserData({
    bool forceRefresh = false,
  }) async {
    // إذا forceRefresh → امسح الـ cache
    if (forceRefresh) {
      _cachedUserData = null;
      _lastFetchTime = null;
    }

    // إذا في بيانات محفوظة ولسه صالحة → ارجعها
    if (_isCacheValid()) {
      return _cachedUserData!;
    }

    // إذا في طلب شغال → انتظره
    if (_pendingRequest != null) {
      return await _pendingRequest!;
    }

    // ارسل طلب جديد
    _pendingRequest = _fetchFromAPI();
    
    try {
      final result = await _pendingRequest!;
      
      // احفظ البيانات في الـ cache
      if (result['success'] == true) {
        _cachedUserData = result;
        _lastFetchTime = DateTime.now();
      }
      
      return result;
    } finally {
      _pendingRequest = null;
    }
  }

  /// جلب البيانات من الـ API
  Future<Map<String, dynamic>> _fetchFromAPI() async {
    try {
      final userService = UserService();
      final result = await userService.getLoggedUserData();
      return result;
    } catch (e) {
      print('❌ [UserCacheService] Error fetching user data: $e');
      rethrow;
    }
  }

  /// التحقق من صلاحية الـ cache
  bool _isCacheValid() {
    if (_cachedUserData == null || _lastFetchTime == null) {
      return false;
    }

    final age = DateTime.now().difference(_lastFetchTime!);
    return age < _cacheDuration;
  }

  /// مسح الـ cache
  void clearCache() {
    _cachedUserData = null;
    _lastFetchTime = null;
    _pendingRequest = null;
  }
}
