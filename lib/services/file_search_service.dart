import 'dart:convert';
import 'package:filevo/services/api_endpoints.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/storage_service.dart';

/// خدمة البحث الذكي في الملفات
/// 
/// تستخدم Hugging Face Inference API المجاني للبحث الدلالي في:
/// - اسم الملف، الوصف، الوسوم، محتوى الملف
/// 
/// المميزات:
/// - مجاني تماماً (لا يحتاج بطاقة ائتمان)
/// - يدعم العربية والإنجليزية
/// - يعمل مع أو بدون Hugging Face API Key (مع key: حدود أعلى)
/// - البحث الدلالي: يفهم معنى النص وليس فقط الكلمات المطابقة
/// - استخدام تلقائي لعدة endpoints وطرق بديلة عند الفشل
/// 
/// النماذج المستخدمة:
/// - Embeddings: sentence-transformers/all-MiniLM-L6-v2 (384 dimensions)
/// - Embeddings البديل: paraphrase-multilingual-MiniLM-L12-v2 (عند فشل الأول)
/// - Summarization: facebook/bart-large-cnn (للنصوص الإنجليزية)
/// 
/// معالجة الأخطاء (في الباك إند):
/// - استخدام HuggingFace Inference API: POST /pipeline/feature-extraction/{model}
/// - Body: النص مباشرة (string) وليس {inputs: text}
/// - عند خطأ 410 (Gone): استخدام تلقائي لنموذج بديل (paraphrase-multilingual-MiniLM-L12-v2)
/// - عند خطأ 503 (نموذج قيد التحميل): retry تلقائي مع backoff (10s, 20s, 30s)
/// - عند timeout: retry تلقائي مع نموذج بديل
/// - حفظ embeddingError في قاعدة البيانات عند فشل توليد embedding
class FileSearchService {
  final _apiBase = ApiConfig.baseUrl;

  /// البحث الذكي الشامل (نصي + AI)
  /// يستخدم Hugging Face API المجاني للبحث الدلالي في:
  /// - اسم الملف، الوصف، الوسوم، محتوى الملف
  ///
  /// [query]: نص البحث (يدعم العربية والإنجليزية)
  /// [limit]: عدد النتائج (افتراضي: 20)
  /// [minScore]: الحد الأدنى لنتيجة البحث (افتراضي: 0.2)
  /// [category]: تصنيف الملفات (اختياري)
  ///
  /// Returns: Map يحتوي على results, resultsCount, query
  Future<Map<String, dynamic>> smartSearch({
    required String query,
    int limit = 20,
    double minScore = 0.2,
    String? category,
    String? dateRange, // ✅ 'yesterday', 'last7days', 'last30days', 'lastyear', 'custom'
    DateTime? startDate, // ✅ للـ custom date range
    DateTime? endDate, // ✅ للـ custom date range
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'لا يوجد token. يرجى تسجيل الدخول'};
      }

      if (query.trim().isEmpty) {
        return {'success': false, 'error': 'نص البحث مطلوب'};
      }

      print('🔍 [FileSearchService] Smart search using Hugging Face API (FREE)...');
      print('   Query: $query');
      print('   Limit: $limit, MinScore: $minScore');
      print('   Category: ${category ?? "all"}');
      print('   DateRange: ${dateRange ?? "all"}');

      final body = {
        'query': query.trim(),
        'limit': limit,
        'minScore': minScore,
      };

      if (category != null && category.isNotEmpty && category != 'all') {
        body['category'] = category;
      }

      if (dateRange != null && dateRange.isNotEmpty && dateRange != 'all') {
        body['dateRange'] = dateRange;
        
        // ✅ إضافة التواريخ المخصصة إذا كانت موجودة
        if (dateRange == 'custom') {
          if (startDate != null) {
            body['startDate'] = startDate.toIso8601String();
          }
          if (endDate != null) {
            body['endDate'] = endDate.toIso8601String();
          }
        }
      }

      final response = await http
          .post(
            Uri.parse("$_apiBase${ApiEndpoints.aiSmartSearch}"),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resultsCount = data['resultsCount'] ?? 0;
        print('✅ [FileSearchService] Search completed: $resultsCount results found');
        
        return {
          'success': true,
          'results': data['results'] ?? [],
          'resultsCount': resultsCount,
          'query': data['query'] ?? query,
        };
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'فشل البحث الذكي';
        
        // ✅ رسائل خطأ محسّنة لـ Hugging Face API
        String userFriendlyError = errorMessage;
        
        if (errorMessage.contains('410') || errorMessage.contains('endpoint')) {
          userFriendlyError = 'تم استخدام طريقة بديلة للبحث. جاري المحاولة...';
        } else if (errorMessage.contains('503') || errorMessage.contains('loading')) {
          userFriendlyError = 'النموذج قيد التحميل. يرجى المحاولة بعد لحظات...';
        } else if (errorMessage.contains('timeout')) {
          userFriendlyError = 'انتهت مهلة الاتصال. الباك إند يحاول طرق بديلة...';
        } else if (errorMessage.contains('alternative') || errorMessage.contains('fallback')) {
          userFriendlyError = 'تم استخدام طريقة بديلة. قد يستغرق وقتاً أطول...';
        }
        
        print('❌ [FileSearchService] Search failed: $errorMessage');
        return {
          'success': false,
          'error': userFriendlyError,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ [FileSearchService] Search error: ${e.toString()}');
      String errorMessage = 'حدث خطأ في الاتصال: ${e.toString()}';
      
      // ✅ معالجة أخطاء timeout
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى...';
      }
      
      return {'success': false, 'error': errorMessage};
    }
  }

  /// البحث في محتوى الملفات فقط (extractedText)
  Future<Map<String, dynamic>> searchInContent({
    required String query,
    int limit = 20,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'لا يوجد token. يرجى تسجيل الدخول'};
      }

      if (query.trim().isEmpty) {
        return {'success': false, 'error': 'نص البحث مطلوب'};
      }

      final response = await http
          .post(
            Uri.parse("$_apiBase${ApiEndpoints.aiSearchContent}"),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'query': query.trim(), 'limit': limit}),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'results': data['results'] ?? [],
          'resultsCount': data['resultsCount'] ?? 0,
          'query': data['query'] ?? query,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'فشل البحث في المحتوى',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'حدث خطأ في الاتصال: ${e.toString()}'};
    }
  }

  /// البحث في اسم الملف فقط
  Future<Map<String, dynamic>> searchByFilename({
    required String query,
    int limit = 20,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'لا يوجد token. يرجى تسجيل الدخول'};
      }

      if (query.trim().isEmpty) {
        return {'success': false, 'error': 'نص البحث مطلوب'};
      }

      final response = await http
          .post(
            Uri.parse("$_apiBase${ApiEndpoints.aiSearchFilename}"),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'query': query.trim(), 'limit': limit}),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'results': data['results'] ?? [],
          'resultsCount': data['resultsCount'] ?? 0,
          'query': data['query'] ?? query,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'فشل البحث في اسم الملف',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'حدث خطأ في الاتصال: ${e.toString()}'};
    }
  }

  /// البحث عن طريق Tags (الوسوم)
  /// يبحث في tags الملفات والمجلدات
  ///
  /// [tag]: Tag للبحث عنه
  /// [limit]: عدد النتائج (افتراضي: 20)
  ///
  /// Returns: Map يحتوي على results, resultsCount, tag
  Future<Map<String, dynamic>> searchByTags({
    required String tag,
    int limit = 20,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'لا يوجد token. يرجى تسجيل الدخول'};
      }

      if (tag.trim().isEmpty) {
        return {'success': false, 'error': 'Tag مطلوب'};
      }

      print('🏷️ [FileSearchService] Searching by tag: $tag');
      print('   Limit: $limit');

      final response = await http
          .post(
            Uri.parse("$_apiBase${ApiEndpoints.aiSearchByTags}"),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'tag': tag.trim(), 'limit': limit}),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resultsCount = data['resultsCount'] ?? 0;
        print('✅ [FileSearchService] Tag search completed: $resultsCount results found');
        
        // ✅ تحويل النتائج إلى نفس format المستخدم في smartSearch
        final results = List<Map<String, dynamic>>.from(data['results'] ?? []);
        final processedResults = results.map<Map<String, dynamic>>((r) {
          // ✅ الباك إند يرسل: { type, _id, name, category, ... }
          // ✅ نحتاج إلى نفس format المستخدم في smartSearch
          final file = Map<String, dynamic>.from(r);
          
          // ✅ التأكد من وجود _id و name
          if (file['_id'] == null && file['id'] != null) {
            file['_id'] = file['id'];
          }
          
          // ✅ إضافة معلومات إضافية للتوافق مع smartSearch format
          file['type'] = file['type'] ?? 'file';
          file['searchType'] = file['searchType'] ?? 'tags';
          file['relevanceScore'] = file['relevanceScore'] ?? 0.95;
          
          return file;
        }).toList();
        
        return {
          'success': true,
          'results': processedResults,
          'resultsCount': resultsCount,
          'tag': data['tag'] ?? tag,
        };
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'فشل البحث عن طريق Tags';
        print('❌ [FileSearchService] Tag search failed: $errorMessage');
        return {
          'success': false,
          'error': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ [FileSearchService] Tag search error: ${e.toString()}');
      String errorMessage = 'حدث خطأ في الاتصال: ${e.toString()}';
      
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى...';
      }
      
      return {'success': false, 'error': errorMessage};
    }
  }

  /// معالجة ملف (استخراج نص، توليد embedding باستخدام Hugging Face، تلخيص)
  /// يستخدم Hugging Face Inference API المجاني لمعالجة الملفات
  /// الباك إند يستخدم:
  /// - HuggingFace Inference API: /models/{model} مباشرة
  /// - Retry logic تلقائي عند 503 (النموذج قيد التحميل)
  /// - نموذج بديل تلقائياً عند 410 (endpoint قديم)
  Future<Map<String, dynamic>> processFile(String fileId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'لا يوجد token. يرجى تسجيل الدخول'};
      }

      print('🔄 [FileSearchService] Processing file using Hugging Face Inference API (FREE)...');
      print('   File ID: $fileId');
      print('   Note: Backend uses /pipeline/feature-extraction/{model} with automatic retry and fallback');

      final response = await http
          .post(
            Uri.parse("$_apiBase${ApiEndpoints.aiProcessFile(fileId)}"),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(Duration(seconds: 120)); // ✅ زيادة timeout لأن الباك إند قد يحاول retry عدة مرات

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final file = data['file'];
        
        // ✅ عرض معلومات تفصيلية عن المعالجة
        if (file != null) {
          final hasExtractedText = file['hasExtractedText'] ?? false;
          final hasEmbedding = file['hasEmbedding'] ?? false;
          final hasSummary = file['hasSummary'] ?? false;
          final extractedTextLength = file['extractedTextLength'] ?? 0;
          final embeddingDimensions = file['embeddingDimensions'] ?? 0;
          final summaryLength = file['summaryLength'] ?? 0;
          final textExtractionError = file['textExtractionError'];
          final embeddingError = file['embeddingError'];
          
          print('✅ [FileSearchService] File processed successfully');
          print('   - Has Extracted Text: $hasExtractedText (${extractedTextLength} chars)');
          print('   - Has Embedding: $hasEmbedding (${embeddingDimensions} dimensions)');
          print('   - Has Summary: $hasSummary (${summaryLength} chars)');
          
          if (textExtractionError != null) {
            print('⚠️ [FileSearchService] Text extraction error: $textExtractionError');
          }
          
          if (embeddingError != null) {
            print('⚠️ [FileSearchService] Embedding generation error: $embeddingError');
            print('   Note: File was still processed, but search may be limited');
          }
        }
        
        return {
          'success': true,
          'file': file,
          'message': data['message'] ?? 'تم معالجة الملف بنجاح',
          'hasExtractedText': file?['hasExtractedText'] ?? false,
          'hasEmbedding': file?['hasEmbedding'] ?? false,
          'hasSummary': file?['hasSummary'] ?? false,
          'extractedTextLength': file?['extractedTextLength'] ?? 0,
          'embeddingDimensions': file?['embeddingDimensions'] ?? 0,
          'summaryLength': file?['summaryLength'] ?? 0,
          'hasEmbeddingError': file?['embeddingError'] != null,
          'embeddingError': file?['embeddingError'],
          'textExtractionError': file?['textExtractionError'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'فشل معالجة الملف';
        
        // ✅ رسائل خطأ محسّنة لجميع الحالات
        String userFriendlyError = errorMessage;
        
        if (errorMessage.contains('410') || errorMessage.contains('Gone')) {
          userFriendlyError = 'تم استخدام نموذج بديل تلقائياً. جاري المعالجة...';
        } else if (errorMessage.contains('503') || errorMessage.contains('loading')) {
          userFriendlyError = 'النموذج قيد التحميل. الباك إند يحاول تلقائياً...';
        } else if (errorMessage.contains('timeout')) {
          userFriendlyError = 'انتهت مهلة الاتصال. الباك إند يحاول retry تلقائياً...';
        } else if (errorMessage.contains('alternative') || errorMessage.contains('fallback')) {
          userFriendlyError = 'تم استخدام نموذج بديل. قد يستغرق وقتاً أطول...';
        } else if (errorMessage.contains('retry') || errorMessage.contains('attempt')) {
          userFriendlyError = 'الباك إند يحاول إعادة المعالجة تلقائياً...';
        }
        
        print('❌ [FileSearchService] File processing failed: $errorMessage');
        print('   Status Code: ${response.statusCode}');
        
        return {
          'success': false,
          'error': userFriendlyError,
          'originalError': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ [FileSearchService] File processing error: ${e.toString()}');
      String errorMessage = 'حدث خطأ في الاتصال: ${e.toString()}';
      
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'انتهت مهلة الاتصال. الباك إند قد يحاول retry أو استخدام نموذج بديل تلقائياً...';
      }
      
      return {'success': false, 'error': errorMessage};
    }
  }

  /// إعادة معالجة ملف
  /// الباك إند سيحاول عدة endpoints وطرق بديلة تلقائياً
  Future<Map<String, dynamic>> reprocessFile(String fileId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'لا يوجد token. يرجى تسجيل الدخول'};
      }

      print('🔄 [FileSearchService] Reprocessing file using Hugging Face Inference API (FREE)...');
      print('   File ID: $fileId');
      print('   Note: Backend uses /pipeline/feature-extraction/{model} with retry logic and alternative model fallback');

      final response = await http
          .post(
            Uri.parse("$_apiBase${ApiEndpoints.aiReprocessFile(fileId)}"),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(Duration(seconds: 120)); // ✅ زيادة timeout للسماح بـ retry

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final file = data['file'];
        
        // ✅ عرض معلومات تفصيلية عن إعادة المعالجة
        if (file != null) {
          final hasExtractedText = file['hasExtractedText'] ?? false;
          final hasEmbedding = file['hasEmbedding'] ?? false;
          final hasSummary = file['hasSummary'] ?? false;
          final embeddingError = file['embeddingError'];
          
          print('✅ [FileSearchService] File reprocessed successfully');
          print('   - Has Extracted Text: $hasExtractedText');
          print('   - Has Embedding: $hasEmbedding');
          print('   - Has Summary: $hasSummary');
          
          if (embeddingError != null) {
            print('⚠️ [FileSearchService] Embedding generation error: $embeddingError');
          }
        }
        
        return {
          'success': true,
          'file': file,
          'message': data['message'] ?? 'تم إعادة معالجة الملف بنجاح',
          'hasExtractedText': file?['hasExtractedText'] ?? false,
          'hasEmbedding': file?['hasEmbedding'] ?? false,
          'hasSummary': file?['hasSummary'] ?? false,
          'hasEmbeddingError': file?['embeddingError'] != null,
          'embeddingError': file?['embeddingError'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'فشل إعادة معالجة الملف';
        
        // ✅ رسائل خطأ محسّنة
        String userFriendlyError = errorMessage;
        
        if (errorMessage.contains('410') || errorMessage.contains('Gone')) {
          userFriendlyError = 'تم استخدام نموذج بديل تلقائياً. جاري إعادة المعالجة...';
        } else if (errorMessage.contains('503') || errorMessage.contains('loading')) {
          userFriendlyError = 'النموذج قيد التحميل. الباك إند يحاول retry تلقائياً...';
        } else if (errorMessage.contains('timeout')) {
          userFriendlyError = 'انتهت مهلة الاتصال. الباك إند يحاول retry تلقائياً...';
        } else if (errorMessage.contains('retry') || errorMessage.contains('attempt')) {
          userFriendlyError = 'الباك إند يحاول إعادة المعالجة تلقائياً...';
        }
        
        print('❌ [FileSearchService] File reprocessing failed: $errorMessage');
        return {
          'success': false,
          'error': userFriendlyError,
          'originalError': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ [FileSearchService] File reprocessing error: ${e.toString()}');
      String errorMessage = 'حدث خطأ في الاتصال: ${e.toString()}';
      
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'انتهت مهلة الاتصال. الباك إند قد يحاول retry أو استخدام نموذج بديل تلقائياً...';
      }
      
      return {'success': false, 'error': errorMessage};
    }
  }

  /// التحقق من حالة Hugging Face API
  /// يعرض معلومات عن استخدام Hugging Face API المجاني
  Future<Map<String, dynamic>> checkHFStatus() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'لا يوجد token. يرجى تسجيل الدخول'};
      }

      print('🔍 [FileSearchService] Checking Hugging Face API status (FREE)...');

      final response = await http
          .get(
            Uri.parse("$_apiBase${ApiEndpoints.aiHFStatus}"),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print('✅ [FileSearchService] Hugging Face API status (FREE):');
        print('   - Connected: ${data['connected'] ?? false}');
        print('   - Model: ${data['model'] ?? 'N/A'}');
        if (data['embeddingDimensions'] != null) {
          print('   - Embedding Dimensions: ${data['embeddingDimensions']}');
        }
        if (data['hasToken'] != null) {
          print('   - Has API Key: ${data['hasToken']}');
        }
        if (data['note'] != null) {
          print('   - Note: ${data['note']}');
        }
        if (data['error'] != null) {
          print('   - Error: ${data['error']}');
        }

        return {
          'success': true,
          'connected': data['connected'] ?? false,
          'model': data['model'],
          'embeddingDimensions': data['embeddingDimensions'],
          'hasToken': data['hasToken'],
          'note': data['note'],
          'error': data['error'],
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        print(
          '❌ [FileSearchService] Failed to check Hugging Face status: ${errorData['message']}',
        );
        return {
          'success': false,
          'error':
              errorData['message'] ?? 'فشل التحقق من حالة Hugging Face API',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print(
        '❌ [FileSearchService] Error checking Hugging Face status: ${e.toString()}',
      );
      return {'success': false, 'error': 'حدث خطأ في الاتصال: ${e.toString()}'};
    }
  }
}
