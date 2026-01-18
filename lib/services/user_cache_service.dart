import 'dart:async';
import 'package:filevo/services/user_service.dart';

/// 🎯 User Cache Service - لمنع multiple requests لـ getMe
/// 
/// المشاكل اللي بيحلها:
/// 1. ✅ منع 3 طلبات متزامنة لـ /api/v1/users/getMe
/// 2. ✅ تخزين بيانات المستخدم في الذاكرة (in-memory cache)
/// 3. ✅ Request deduplication - لو في طلب شغال، ما يرسل طلب جديد
/// 4. ✅ Auto-refresh بعد فترة معينة (TTL)
/// 
class UserCacheService {
  // ============================================================================
  // 🏗️ Singleton Pattern
  // ============================================================================
  static final UserCacheService _instance = UserCacheService._internal();
  factory UserCacheService() => _instance;
  UserCacheService._internal();

  // ============================================================================
  // 📦 Cache Storage
  // ============================================================================
  
  /// البيانات المخزنة في الذاكرة
  Map<String, dynamic>? _cachedUserData;
  
  /// وقت آخر تحديث للبيانات
  DateTime? _lastFetchTime;
  
  /// مدة صلاحية الـ cache (5 دقائق)
  final Duration _cacheDuration = const Duration(minutes: 5);
  
  /// طلب شغال حالياً (لمنع multiple concurrent requests)
  Future<Map<String, dynamic>>? _pendingRequest;

  // ============================================================================
  // 🎯 Main Methods
  // ============================================================================

  /// الحصول على بيانات المستخدم (مع cache)
  /// 
  /// الخطوات:
  /// 1. إذا في بيانات محفوظة ولسه صالحة → ارجعها مباشرة
  /// 2. إذا في طلب شغال حالياً → انتظره بدلاً من إرسال طلب جديد
  /// 3. إذا مافي شيء → ارسل طلب جديد
  Future<Map<String, dynamic>> getLoggedUserData({
    bool forceRefresh = false,
  }) async {
    print('🔍 [UserCacheService] getLoggedUserData called (forceRefresh: $forceRefresh)');

    // 1️⃣ إذا forceRefresh = true → امسح الـ cache
    if (forceRefresh) {
      print('🔄 [UserCacheService] Force refresh requested - clearing cache');
      _cachedUserData = null;
      _lastFetchTime = null;
    }

    // 2️⃣ إذا في بيانات محفوظة ولسه صالحة → ارجعها
    if (_isCacheValid()) {
      print('✅ [UserCacheService] Returning cached user data (age: ${_getCacheAge()})');
      return _cachedUserData!;
    }

    // 3️⃣ إذا في طلب شغال حالياً → انتظره بدلاً من إرسال طلب جديد
    if (_pendingRequest != null) {
      print('⏳ [UserCacheService] Waiting for pending request...');
      return await _pendingRequest!;
    }

    // 4️⃣ ارسل طلب جديد
    print('📡 [UserCacheService] Fetching fresh user data from API...');
    _pendingRequest = _fetchFromAPI();
    
    try {
      final result = await _pendingRequest!;
      return result;
    } finally {
      // 5️⃣ امسح الـ pending request بعد الانتهاء
      _pendingRequest = null;
    }
  }

  /// جلب البيانات من الـ API
  Future<Map<String, dynamic>> _fetchFromAPI() async {
    try {
      final userService = UserService();
      final result = await userService.getLoggedUserData();

      // ✅ إذا نجح الطلب، احفظ البيانات في الـ cache
      if (result['success'] == true) {
        _cachedUserData = result;
        _lastFetchTime = DateTime.now();
        print('✅ [UserCacheService] User data cached successfully');
      } else {
        print('⚠️ [UserCacheService] Failed to fetch user data: ${result['error']}');
      }

      return result;
    } catch (e) {
      print('❌ [UserCacheService] Error fetching user data: $e');
      rethrow;
    }
  }

  // ============================================================================
  // 🔧 Helper Methods
  // ============================================================================

  /// التحقق من صلاحية الـ cache
  bool _isCacheValid() {
    if (_cachedUserData == null || _lastFetchTime == null) {
      return false;
    }

    final age = DateTime.now().difference(_lastFetchTime!);
    final isValid = age < _cacheDuration;

    if (!isValid) {
      print('⏰ [UserCacheService] Cache expired (age: ${age.inMinutes} minutes)');
    }

    return isValid;
  }

  /// حساب عمر الـ cache
  String _getCacheAge() {
    if (_lastFetchTime == null) return 'N/A';
    
    final age = DateTime.now().difference(_lastFetchTime!);
    if (age.inSeconds < 60) {
      return '${age.inSeconds}s';
    } else {
      return '${age.inMinutes}m ${age.inSeconds % 60}s';
    }
  }

  // ============================================================================
  // 🧹 Cache Management
  // ============================================================================

  /// مسح الـ cache (عند تحديث بيانات المستخدم مثلاً)
  void clearCache() {
    print('🧹 [UserCacheService] Clearing cache...');
    print('   - Old cached data: ${_cachedUserData != null ? "exists" : "null"}');
    print('   - Old cache age: ${_lastFetchTime != null ? DateTime.now().difference(_lastFetchTime!).inMinutes : "N/A"} minutes');
    
    _cachedUserData = null;
    _lastFetchTime = null;
    _pendingRequest = null;  // ✅ امسح الـ pending request أيضاً
    
    print('✅ [UserCacheService] Cache cleared successfully!');
  }

  /// الحصول على البيانات المخزنة (بدون API call)
  Map<String, dynamic>? getCachedData() {
    if (_isCacheValid()) {
      return _cachedUserData;
    }
    return null;
  }

  /// التحقق من وجود بيانات صالحة في الـ cache
  bool hasCachedData() {
    return _isCacheValid();
  }
}
