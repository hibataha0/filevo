import 'package:flutter/foundation.dart';
import 'package:filevo/services/activity_service.dart';

class ActivityController extends ChangeNotifier {
  final ActivityService _activityService = ActivityService();

  List<Map<String, dynamic>> _activities = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _pagination;

  // Getters
  List<Map<String, dynamic>> get activities => _activities;
  Map<String, dynamic>? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get pagination => _pagination;

  /// ✅ جلب سجل النشاط
  Future<void> getUserActivityLog({
    int page = 1,
    int limit = 20,
    String? action,
    String? entityType,
    String? startDate,
    String? endDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _activityService.getUserActivityLog(
        page: page,
        limit: limit,
        action: action,
        entityType: entityType,
        startDate: startDate,
        endDate: endDate,
      );

      if (result['success'] == true) {
        _activities = List<Map<String, dynamic>>.from(
          result['activities'] ?? [],
        );
        _pagination = result['pagination'] ?? {};
        _errorMessage = null;
      } else {
        _errorMessage = result['error'] ?? 'فشل في جلب سجل النشاط';
        _activities = [];
      }
    } catch (e) {
      _errorMessage = 'خطأ في جلب سجل النشاط: ${e.toString()}';
      _activities = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ جلب إحصائيات النشاط
  Future<void> getActivityStatistics({int days = 30}) async {
    try {
      final result = await _activityService.getActivityStatistics(days: days);

      if (result['success'] == true) {
        _statistics = result['statistics'];
      }
    } catch (e) {
      print('Error getting activity statistics: $e');
    }
    notifyListeners();
  }

  /// ✅ حذف السجلات القديمة
  Future<bool> clearOldActivityLogs({int daysToKeep = 90}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _activityService.clearOldActivityLogs(
        daysToKeep: daysToKeep,
      );

      if (result['success'] == true) {
        _errorMessage = null;
        // ✅ إعادة جلب السجلات بعد الحذف
        await getUserActivityLog();
        return true;
      } else {
        _errorMessage = result['error'] ?? 'فشل في حذف السجلات القديمة';
        return false;
      }
    } catch (e) {
      _errorMessage = 'خطأ في حذف السجلات القديمة: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ إعادة تعيين الحالة
  void reset() {
    _activities = [];
    _statistics = null;
    _isLoading = false;
    _errorMessage = null;
    _pagination = null;
    notifyListeners();
  }
}



