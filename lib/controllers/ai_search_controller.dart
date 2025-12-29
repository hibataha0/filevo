import 'package:flutter/material.dart';
import 'package:filevo/services/ai_search_service.dart';

/// Controller for smart search
class AiSearchController with ChangeNotifier {
  final AiSearchService _service = AiSearchService();

  bool isLoading = false;
  String? errorMessage;

  // Search results
  Map<String, dynamic>? searchResults;
  Map<String, dynamic>? interpretedQuery;

  // Results statistics
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

  /// Comprehensive smart search
  Future<bool> search({required String query, String scope = 'all'}) async {
    if (query.trim().isEmpty) {
      setError('Search text is required');
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
        interpretedQuery =
            searchResults!['interpreted'] as Map<String, dynamic>?;

        // Update statistics
        final results = searchResults!;
        filesCount = (results['files'] as List?)?.length ?? 0;
        roomsCount = (results['rooms'] as List?)?.length ?? 0;
        foldersCount = (results['folders'] as List?)?.length ?? 0;
        commentsCount = (results['comments'] as List?)?.length ?? 0;
        totalResults = results['total'] ?? 0;

        notifyListeners();
        return true;
      }

      setError(response['message'] ?? 'Search failed');
      return false;
    } catch (e) {
      setError(e.toString());
      debugPrint('Error in smart search: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Smart search within a specific room
  Future<bool> searchInRoom({
    required String roomId,
    required String query,
  }) async {
    if (query.trim().isEmpty) {
      setError('Search text is required');
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
        interpretedQuery =
            searchResults!['interpreted'] as Map<String, dynamic>?;

        // Update statistics
        final results = searchResults!;
        filesCount = (results['files'] as List?)?.length ?? 0;
        foldersCount = (results['folders'] as List?)?.length ?? 0;
        commentsCount = (results['comments'] as List?)?.length ?? 0;
        roomsCount = 0; // No rooms in room search
        totalResults = results['total'] ?? 0;

        notifyListeners();
        return true;
      }

      setError(response['message'] ?? 'Search failed');
      return false;
    } catch (e) {
      setError(e.toString());
      debugPrint('Error in smart search in room: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Get files from results
  List<Map<String, dynamic>> get files {
    if (searchResults == null) return [];
    return List<Map<String, dynamic>>.from(searchResults!['files'] ?? []);
  }

  /// Get rooms from results
  List<Map<String, dynamic>> get rooms {
    if (searchResults == null) return [];
    return List<Map<String, dynamic>>.from(searchResults!['rooms'] ?? []);
  }

  /// Get folders from results
  List<Map<String, dynamic>> get folders {
    if (searchResults == null) return [];
    return List<Map<String, dynamic>>.from(searchResults!['folders'] ?? []);
  }

  /// Get comments from results
  List<Map<String, dynamic>> get comments {
    if (searchResults == null) return [];
    return List<Map<String, dynamic>>.from(searchResults!['comments'] ?? []);
  }
}
