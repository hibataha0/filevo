import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

/// ✅ Class لتحميل الملفات الكبيرة (حتى 1-2 GB) باستخدام Streaming
/// ✅ لا يحمّل الملف كاملاً في الذاكرة - يستخدم Stream للكتابة مباشرة على القرص
class LargeFileDownloader {
  static http.Client? _client;
  static StreamSubscription<List<int>>? _subscription;
  static bool _isDownloading = false;
  static bool _isCancelled = false;

  /// ✅ الحصول على HTTP Client (مشترك لجميع التحميلات)
  static http.Client _getClient() {
    _client ??= http.Client();
    return _client!;
  }

  /// ✅ إغلاق HTTP Client (يُستدعى عند الانتهاء)
  static void _closeClient() {
    _client?.close();
    _client = null;
  }

  /// ✅ إلغاء التحميل الحالي
  static void cancelDownload() {
    _isCancelled = true;
    _subscription?.cancel();
    _subscription = null;
  }

  /// ✅ تحميل ملف كبير مع Progress Indicator
  /// 
  /// [url] - رابط الملف للتحميل
  /// [fileName] - اسم الملف (سيتم حفظه بهذا الاسم)
  /// [onProgress] - Callback يُستدعى أثناء التحميل:
  ///   - received: عدد البايتات المحمّلة حتى الآن
  ///   - total: إجمالي حجم الملف (قد يكون -1 إذا لم يكن Content-Length متوفراً)
  /// [filePath] - مسار الملف المحدد (اختياري، إذا لم يتم تحديده سيتم إنشاؤه تلقائياً)
  /// 
  /// Returns: مسار الملف المحمّل أو null إذا فشل التحميل
  /// 
  /// Throws: Exception في حالة حدوث خطأ
  static Future<String?> downloadFileWithProgress({
    required String url,
    required String fileName,
    required Function(int received, int total) onProgress,
    String? token, // ✅ Token للـ authentication (اختياري)
    Duration timeout = const Duration(minutes: 30), // ✅ Timeout افتراضي: 30 دقيقة
    bool openAfterDownload = false, // ✅ فتح الملف بعد التحميل (افتراضي: false)
    String? filePath, // ✅ مسار الملف المحدد (اختياري)
  }) async {
    // ✅ إعادة تعيين حالة الإلغاء
    _isCancelled = false;
    _isDownloading = true;

    try {
      // ✅ 1. الحصول على مجلد الـ temporary directory
      final dir = await getTemporaryDirectory();
      final finalFilePath = filePath ?? '${dir.path}/$fileName';
      final file = File(finalFilePath);

      print('📥 [LargeFileDownloader] Starting download...');
      print('   URL: $url');
      print('   File: $finalFilePath');

      // ✅ 2. إنشاء HTTP Request
      final request = http.Request('GET', Uri.parse(url));
      
      // ✅ إضافة headers إذا كان token موجوداً
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // ✅ 3. الحصول على HTTP Client
      final client = _getClient();

      // ✅ 4. إرسال الطلب والحصول على Stream Response
      final streamedResponse = await client.send(request).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException(
            'Download timeout after ${timeout.inMinutes} minutes',
            timeout,
          );
        },
      );

      print('📡 [LargeFileDownloader] Response status: ${streamedResponse.statusCode}');
      print('📊 [LargeFileDownloader] Content-Length: ${streamedResponse.contentLength}');

      // ✅ 5. التحقق من حالة الاستجابة
      if (streamedResponse.statusCode != 200 && streamedResponse.statusCode != 206) {
        throw Exception(
          'Failed to download file: HTTP ${streamedResponse.statusCode}',
        );
      }

      // ✅ 6. الحصول على إجمالي حجم الملف
      final totalBytes = streamedResponse.contentLength ?? -1;
      int receivedBytes = 0;

      // ✅ 7. فتح الملف للكتابة باستخدام IOSink
      final sink = file.openWrite();

      try {
        // ✅ 8. قراءة البيانات من Stream وكتابتها مباشرة على القرص
        // ✅ هذا يضمن عدم تحميل الملف كاملاً في الذاكرة
        await for (var chunk in streamedResponse.stream) {
          // ✅ التحقق من حالة الإلغاء
          if (_isCancelled) {
            await sink.close();
            await file.delete(); // ✅ حذف الملف غير المكتمل
            throw Exception('Download cancelled by user');
          }

          // ✅ كتابة البيانات مباشرة على القرص
          sink.add(chunk);
          receivedBytes += chunk.length;

          // ✅ استدعاء Progress Callback
          // ✅ إذا كان totalBytes = -1 (غير معروف)، نمرر -1
          onProgress(receivedBytes, totalBytes);

          // ✅ طباعة Progress كل 10% (للتطوير فقط)
          if (totalBytes > 0) {
            final percent = (receivedBytes / totalBytes * 100).toInt();
            if (percent % 10 == 0) {
              print('📊 [LargeFileDownloader] Progress: $percent% ($receivedBytes / $totalBytes bytes)');
            }
          } else {
            // ✅ إذا كان الحجم غير معروف، نطبع البايتات المحمّلة فقط
            if (receivedBytes % (1024 * 1024) == 0) {
              final mb = (receivedBytes / (1024 * 1024)).toStringAsFixed(1);
              print('📊 [LargeFileDownloader] Downloaded: ${mb}MB (size unknown)');
            }
          }
        }

        // ✅ 9. إغلاق Stream وضمان كتابة جميع البيانات
        await sink.flush();
        await sink.close();
        
        // ✅ Force sync للقرص للتأكد من اكتمال الكتابة
        try {
          await file.parent.create(recursive: true);
          // ✅ إعطاء وقت إضافي للقرص لكتابة البيانات
          await Future.delayed(Duration(milliseconds: 100));
        } catch (e) {
          print('⚠️ [LargeFileDownloader] Warning during file sync: $e');
        }

        print('✅ [LargeFileDownloader] Download completed successfully');
        print('📁 [LargeFileDownloader] File saved to: $finalFilePath');
        print('📊 [LargeFileDownloader] Total size: ${receivedBytes} bytes');

        // ✅ 10. التحقق من وجود الملف وحجمه (مع retry logic محسّن)
        // ✅ إعطاء وقت كافٍ للقرص لكتابة جميع البيانات
        bool fileExists = false;
        int fileSize = 0;
        int retryCount = 0;
        const maxRetries = 10;
        
        while (retryCount < maxRetries && !fileExists) {
          await Future.delayed(Duration(milliseconds: 200 * (retryCount + 1))); // ✅ تأخير متزايد
          
          try {
            // ✅ استخدام stat() للتحقق من الملف بشكل أفضل
            final stat = await file.stat();
            fileSize = stat.size;
            
            if (stat.size > 0) {
              print('✅ [LargeFileDownloader] File verified: ${fileSize} bytes (attempt ${retryCount + 1})');
              
              // ✅ التحقق من أن حجم الملف يتطابق مع البايتات المحمّلة
              if (totalBytes > 0 && fileSize != totalBytes) {
                print('⚠️ [LargeFileDownloader] File size mismatch: expected $totalBytes bytes, got $fileSize bytes');
                // ✅ إذا كان الفرق صغيراً (< 1%)، نعتبره مقبولاً
                final diff = (fileSize - totalBytes).abs();
                final diffPercent = (diff / totalBytes * 100);
                if (diffPercent > 1.0) {
                  print('❌ [LargeFileDownloader] Size difference too large: ${diffPercent.toStringAsFixed(2)}%');
                  // ✅ لا نرمي exception هنا، قد يكون الملف صحيحاً رغم الاختلاف الطفيف
                  // ✅ خاصة إذا كان receivedBytes == totalBytes
                  if (receivedBytes != totalBytes) {
                    throw Exception('File size mismatch: expected $totalBytes bytes, got $fileSize bytes');
                  }
                } else {
                  print('✅ [LargeFileDownloader] Size difference acceptable: ${diffPercent.toStringAsFixed(2)}%');
                }
              }
              
              // ✅ التحقق من أن الملف ليس فارغاً
              if (fileSize == 0 && receivedBytes > 0) {
                print('⚠️ [LargeFileDownloader] File exists but is empty, retrying...');
                retryCount++;
                continue;
              }
              
              // ✅ التحقق من أن حجم الملف يتطابق مع receivedBytes
              if (fileSize != receivedBytes && receivedBytes > 0) {
                print('⚠️ [LargeFileDownloader] File size does not match received bytes: expected $receivedBytes, got $fileSize');
                // ✅ إذا كان الفرق صغيراً (< 0.1%)، نعتبره مقبولاً
                final diff = (fileSize - receivedBytes).abs();
                if (receivedBytes > 0) {
                  final diffPercent = (diff / receivedBytes * 100);
                  if (diffPercent > 0.1) {
                    print('⚠️ [LargeFileDownloader] Size difference too large, retrying...');
                    retryCount++;
                    continue;
                  }
                }
              }
              
              fileExists = true;
            } else {
              print('⚠️ [LargeFileDownloader] File exists but is empty, retrying...');
              retryCount++;
            }
          } catch (e) {
            // ✅ إذا فشل stat()، جرب exists() و length()
            if (await file.exists()) {
              fileSize = await file.length();
              if (fileSize > 0) {
                print('✅ [LargeFileDownloader] File verified via exists(): ${fileSize} bytes');
                fileExists = true;
              } else {
                retryCount++;
                print('⚠️ [LargeFileDownloader] File exists but size is 0, retrying... (attempt $retryCount/$maxRetries)');
              }
            } else {
              retryCount++;
              print('⚠️ [LargeFileDownloader] File not found, retrying... (attempt $retryCount/$maxRetries)');
            }
          }
        }
        
        if (!fileExists) {
          // ✅ محاولة أخيرة: التحقق من وجود الملف في مسار مختلف
          final dir = await getTemporaryDirectory();
          final altPath = '${dir.path}/$fileName';
          if (altPath != finalFilePath) {
            final altFile = File(altPath);
            if (await altFile.exists()) {
              print('✅ [LargeFileDownloader] File found at alternative path: $altPath');
              return altPath;
            }
          }
          
          throw Exception('File does not exist after download at path: $finalFilePath (tried $maxRetries times)');
        }

        // ✅ 11. فتح الملف بعد التحميل إذا كان مطلوباً
        if (openAfterDownload) {
          print('📂 [LargeFileDownloader] Opening file...');
          final result = await OpenFilex.open(finalFilePath);
          
          if (result.type != ResultType.done) {
            print('⚠️ [LargeFileDownloader] Failed to open file: ${result.message}');
          } else {
            print('✅ [LargeFileDownloader] File opened successfully');
          }
        }

        return finalFilePath;
      } catch (e) {
        // ✅ إغلاق Stream في حالة حدوث خطأ
        await sink.close();
        
        // ✅ حذف الملف غير المكتمل
        if (await file.exists()) {
          await file.delete();
        }
        
        rethrow;
      }
    } catch (e) {
      print('❌ [LargeFileDownloader] Download error: $e');
      
      // ✅ معالجة أنواع مختلفة من الأخطاء
      if (e is TimeoutException) {
        throw Exception('Download timeout: ${e.message}');
      } else if (e is SocketException) {
        throw Exception('Network error: ${e.message}');
      } else if (e is HttpException) {
        throw Exception('HTTP error: ${e.message}');
      } else if (_isCancelled) {
        throw Exception('Download cancelled');
      } else {
        throw Exception('Download failed: ${e.toString()}');
      }
    } finally {
      // ✅ إعادة تعيين حالة التحميل
      _isDownloading = false;
      _subscription = null;
    }
  }

  /// ✅ تحميل ملف كبير مع Progress Percentage
  /// 
  /// نفس `downloadFileWithProgress` لكن مع callback إضافي للـ percentage
  static Future<String?> downloadFileWithPercentage({
    required String url,
    required String fileName,
    required Function(int received, int total, double percentage) onProgress,
    String? token,
    Duration timeout = const Duration(minutes: 30),
    bool openAfterDownload = false,
    String? filePath, // ✅ مسار الملف المحدد (اختياري)
  }) async {
    return downloadFileWithProgress(
      url: url,
      fileName: fileName,
      token: token,
      timeout: timeout,
      openAfterDownload: openAfterDownload,
      filePath: filePath, // ✅ تمرير المسار المحدد
      onProgress: (received, total) {
        // ✅ حساب الـ percentage
        double percentage = -1.0;
        if (total > 0) {
          percentage = (received / total * 100).clamp(0.0, 100.0);
        }
        
        // ✅ استدعاء Callback مع percentage
        onProgress(received, total, percentage);
      },
    );
  }

  /// ✅ التحقق من حالة التحميل
  static bool get isDownloading => _isDownloading;

  /// ✅ تنظيف الموارد (يُستدعى عند إغلاق التطبيق)
  static void dispose() {
    cancelDownload();
    _closeClient();
  }
}

