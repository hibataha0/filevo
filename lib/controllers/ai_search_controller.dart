import 'package:flutter/material.dart';
import 'package:filevo/services/ai_search_service.dart';

/// Controller للبحث الذكي
class AiSearchController with ChangeNotifier {
  final AiSearchService _service = AiSearchService();

  bool isLoading = false;
  String? errorMessage;
  
  // نتائج البحث
  Map<String, dynamic>? searchResults;
  Map<String, dynamic>? interpretedQuery;

  // إحصائيات النتائج
  int totalResults = 0;
  int filesCount = 0;
  int roomsCount = 0;
  int foldersCount = 0;
  int commentsCount = 0;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setError(String? error) {
    errorMessage = error;
    notifyListeners();
  }

  void clearResults() {
    searchResults = null;
    interpretedQuery = null;
    totalResults = 0;
    filesCount = 0;
    roomsCount = 0;
    foldersCount = 0;
    commentsCount = 0;
    errorMessage = null;
    notifyListeners();
  }

  /// البحث الذكي الشامل
  Future<bool> search({
    required String query,
    String scope = 'all',
  }) async {
    if (query.trim().isEmpty) {
      setError('نص البحث مطلوب');
      return false;
    }

    setLoading(true);
    setError(null);

    try {
      final response = await _service.smartSearch(
        query: query.trim(),
        scope: scope,
      );

      if (response['results'] != null) {
        searchResults = response['results'] as Map<String, dynamic>;
        interpretedQuery = searchResults!['interpreted'] as Map<String, dynamic>?;

        // تحديث الإحصائيات
        final results = searchResults!;
        filesCount = (results['files'] as List?)?.length ?? 0;
        roomsCount = (results['rooms'] as List?)?.length ?? 0;
        foldersCount = (results['folders'] as List?)?.length ?? 0;
        commentsCount = (results['comments'] as List?)?.length ?? 0;
        totalResults = results['total'] ?? 0;

        notifyListeners();
        return true;
      }

      setError(response['message'] ?? 'فشل البحث');
      return false;
    } catch (e) {
      setError(e.toString());
      debugPrint('Error in smart search: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// البحث الذكي داخل روم محدد
  Future<bool> searchInRoom({
    required String roomId,
    required String query,
  }) async {
    if (query.trim().isEmpty) {
      setError('نص البحث مطلوب');
      return false;
    }

    setLoading(true);
    setError(null);

    try {
      final response = await _service.smartSearchInRoom(
        roomId: roomId,
        query: query.trim(),
      );

      if (response['results'] != null) {
        searchResults = response['results'] as Map<String, dynamic>;
        interpretedQuery = searchResults!['interpreted'] as Map<String, dynamic>?;

        // تحديث الإحصائيات
        final results = searchResults!;
        filesCount = (results['files'] as List?)?.length ?? 0;
        foldersCount = (results['folders'] as List?)?.length ?? 0;
        commentsCount = (results['comments'] as List?)?.length ?? 0;
        roomsCount = 0; // لا توجد رومات في البحث داخل روم
        totalResults = results['total'] ?? 0;

        notifyListeners();
        return true;
      }

      setError(response['message'] ?? 'فشل البحث');
      return false;
    } catch (e) {
      setError(e.toString());
      debugPrint('Error in smart search in room: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// الحصول على الملفات من النتائج
  List<Map<String, dynamic>> get files {
    if (searchResults == null) return [];
    return List<Map<String, dynamic>>.from(searchResults!['files'] ?? []);
  }

  /// الحصول على الرومات من النتائج
  List<Map<String, dynamic>> get rooms {
    if (searchResults == null) return [];
    return List<Map<String, dynamic>>.from(searchResults!['rooms'] ?? []);
  }

  /// الحصول على المجلدات من النتائج
  List<Map<String, dynamic>> get folders {
    if (searchResults == null) return [];
    return List<Map<String, dynamic>>.from(searchResults!['folders'] ?? []);
  }

  /// الحصول على التعليقات من النتائج
  List<Map<String, dynamic>> get comments {
    if (searchResults == null) return [];
    return List<Map<String, dynamic>>.from(searchResults!['comments'] ?? []);
  }
}

