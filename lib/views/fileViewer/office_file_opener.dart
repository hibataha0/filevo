import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:filevo/services/large_file_downloader.dart';

class OfficeFileOpener {
  /// فتح أي ملف باستخدام تطبيق خارجي (docx, pptx, zip, apk, exe ...)
  /// ✅ يستخدم open_filex الأحدث والأقوى
  /// ✅ يحمّل الملف أولاً إلى الـ cache ثم يفتحه (مثل Google Drive)
  /// ✅ يغلق Loading Dialog تلقائياً بعد الانتهاء
  static Future<void> openAnyFile({
    required String url,
    required BuildContext context,
    String? token,
    String? fileName, // ✅ اسم الملف المخصص (اختياري)
    Function(int received, int total)? onProgress, // ✅ Progress callback
    bool closeLoadingDialog = true, // ✅ إغلاق Loading Dialog تلقائياً (افتراضي: true)
  }) async {
    try {
      // ✅ الحصول على اسم الملف من URL أو استخدام الاسم المخصص
      final finalFileName = fileName ?? _getFileName(url);
      
      // ✅ الحصول على مسار الـ cache
      final dir = await getTemporaryDirectory();
      final filePath = "${dir.path}/$finalFileName";
      
      print('📥 Downloading file to cache: $filePath');
      
      // ✅ التحقق من حجم الملف أولاً لتحديد طريقة التحميل
      // ✅ 100 MB = 100 * 1024 * 1024 = 104857600 bytes
      const int largeFileThreshold = 100 * 1024 * 1024; // 100 MB
      
      File? file;
      
      // ✅ محاولة الحصول على حجم الملف من Content-Length header مع timeout قصير
      // ✅ إذا فشل أو استغرق وقتاً طويلاً، نستخدم الطريقة العادية مباشرة
      int? fileSize;
      try {
        final headRequest = http.Request('HEAD', Uri.parse(url));
        if (token != null) {
          headRequest.headers['Authorization'] = 'Bearer $token';
        }
        
        // ✅ إضافة timeout قصير للـ HEAD request (3 ثواني فقط)
        final headResponse = await headRequest.send().timeout(
          Duration(seconds: 3),
          onTimeout: () {
            print('⚠️ HEAD request timeout - using regular download');
            throw TimeoutException('HEAD request timeout');
          },
        );
        
        fileSize = headResponse.contentLength;
        print('📊 File size from HEAD request: ${fileSize ?? 'unknown'} bytes');
      } catch (e) {
        // ✅ إذا فشل HEAD request، نستخدم الطريقة العادية مباشرة
        print('⚠️ Could not get file size from HEAD request: $e - using regular download');
        fileSize = null;
      }
      
      // ✅ إذا كان حجم الملف >= 100 MB، استخدم LargeFileDownloader
      if (fileSize != null && fileSize >= largeFileThreshold) {
        print('📦 Using LargeFileDownloader for file >= 100 MB (${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB)');
        try {
          final downloadedPath = await LargeFileDownloader.downloadFileWithProgress(
            url: url,
            fileName: finalFileName,
            token: token,
            timeout: Duration(minutes: 30), // ✅ timeout طويل للملفات الكبيرة
            filePath: filePath, // ✅ تمرير المسار المحدد
            onProgress: onProgress ?? (received, total) {
              if (total > 0) {
                final percent = (received / total * 100).toStringAsFixed(0);
                print("📥 Downloading: $percent% ($received / $total bytes)");
              }
            },
          );
          
          if (downloadedPath != null) {
            file = File(downloadedPath);
          }
        } catch (e) {
          print('❌ LargeFileDownloader failed: $e');
          // ✅ في حالة الفشل، جرب الطريقة العادية
          file = await _downloadFileToCache(
            url,
            finalFileName,
            token,
            context,
            filePath: filePath,
            onProgress: onProgress,
          );
        }
      } else {
        // ✅ للملفات < 100 MB أو إذا لم نتمكن من معرفة الحجم، استخدم الطريقة العادية
        print('📦 Using regular download for file < 100 MB or unknown size');
        file = await _downloadFileToCache(
          url,
          finalFileName,
          token,
          context,
          filePath: filePath, // ✅ تمرير مسار الملف المحدد
          onProgress: onProgress,
        );
      }

      if (file != null && file.existsSync()) {
        print('✅ File downloaded successfully: ${file.path}');
        
        try {
          // ✅ استخدام open_filex لفتح الملف من الـ cache
          final result = await OpenFilex.open(file.path);
          
          print('📂 OpenFilex result: ${result.type}, message: ${result.message}');
          
          if (result.type != ResultType.done) {
            // ✅ إذا فشل الفتح، خاصة إذا لم يكن هناك تطبيق، اعرض خيارات اختيار التطبيق
            if (result.type == ResultType.noAppToOpen) {
              // ✅ استخدام share_plus لإظهار خيارات اختيار التطبيق (Open with)
              if (context.mounted) {
                if (closeLoadingDialog) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
                
                try {
                  // ✅ استخدام Share.shareXFiles لإظهار خيارات "Open with" و "Share"
                  // ✅ في Android، سيعرض هذا Intent chooser مع خيارات فتح الملف
                  await Share.shareXFiles(
                    [XFile(file.path)],
                    subject: finalFileName,
                  );
                  print('✅ File opened via chooser');
                } catch (e) {
                  print('❌ Error opening file with chooser: $e');
                  _showError(context, 'فشل فتح الملف. يرجى تثبيت تطبيق مناسب (مثل Microsoft Office أو Google Slides)');
                }
              }
            } else {
              // ✅ لأخطاء أخرى، اعرض رسالة خطأ
              String errorMessage = 'فشل فتح الملف';
              if (result.type == ResultType.fileNotFound) {
                errorMessage = 'الملف غير موجود';
              } else if (result.type == ResultType.permissionDenied) {
                errorMessage = 'تم رفض الصلاحية';
              } else if (result.message.isNotEmpty) {
                errorMessage = result.message;
              }
              
              if (context.mounted) {
                if (closeLoadingDialog) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
                _showError(context, errorMessage);
              }
            }
          } else {
            print('✅ File opened successfully');
            // ✅ إغلاق Loading Dialog بعد فتح الملف بنجاح
            if (context.mounted && closeLoadingDialog) {
              Navigator.of(context, rootNavigator: true).pop();
            }
          }
        } catch (e) {
          print("❌ Open File Error: $e");
          if (context.mounted) {
            // ✅ إغلاق Loading Dialog قبل عرض الخطأ
            if (closeLoadingDialog) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            _showError(context, "فشل فتح الملف: $e");
          }
        }
      } else {
        print('❌ File download failed or file does not exist');
        if (context.mounted) {
          // ✅ إغلاق Loading Dialog قبل عرض الخطأ
          if (closeLoadingDialog) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          _showError(context, "فشل تحميل الملف.");
        }
      }
    } catch (e) {
      print("❌ OfficeFileOpener Error: $e");
      if (context.mounted) {
        // ✅ إغلاق Loading Dialog قبل عرض الخطأ
        if (closeLoadingDialog) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        _showError(context, "خطأ في فتح الملف: $e");
      }
    }
  }

  static String _getFileName(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.pathSegments.isNotEmpty) return uri.pathSegments.last;
    } catch (_) {}
    return "file.unknown";
  }

  /// تحميل الملف باستخدام Stream لتجنب مشاكل الملفات الكبيرة
  /// ✅ مع دعم Progress Indicator
  /// ✅ يحمّل الملف إلى مسار محدد في الـ cache
  static Future<File?> _downloadFileToCache(
    String url,
    String fileName,
    String? token,
    BuildContext context, {
    String? filePath, // ✅ مسار الملف المحدد (اختياري)
    Function(int received, int total)? onProgress,
  }) async {
    try {
      // ✅ استخدام المسار المحدد أو إنشاء مسار جديد
      final dir = await getTemporaryDirectory();
      final finalFilePath = filePath ?? '${dir.path}/$fileName';
      final file = File(finalFilePath);

      print('📥 Starting download from: $url');
      print('📁 Saving to: $finalFilePath');

      // ✅ إنشاء request مع headers
      final request = http.Request('GET', Uri.parse(url));
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // ✅ إرسال الطلب والحصول على response stream مع timeout
      final response = await request.send().timeout(
        Duration(minutes: 10), // ✅ timeout 10 دقائق للملفات الصغيرة/المتوسطة
        onTimeout: () {
          throw TimeoutException('Download timeout after 10 minutes');
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📊 Content-Length: ${response.contentLength}');
      
      // ✅ إذا كان الملف كبير جداً (> 200 MB) ولم نستخدم LargeFileDownloader، نحذره
      if (response.contentLength != null && response.contentLength! > 200 * 1024 * 1024) {
        print('⚠️ Large file detected (${(response.contentLength! / (1024 * 1024)).toStringAsFixed(1)} MB) - consider using LargeFileDownloader');
      }

      if (response.statusCode == 200 || response.statusCode == 206) {
        final total = response.contentLength ?? 0;
        int received = 0;

        // ✅ فتح الملف للكتابة
        final sink = file.openWrite();
        
        try {
          // ✅ قراءة البيانات بشكل stream (للملفات الكبيرة)
          await for (var chunk in response.stream) {
            received += chunk.length;
            sink.add(chunk);

            // ✅ إرسال Progress إذا كان callback موجوداً
            if (onProgress != null && total > 0) {
              onProgress(received, total);
            }
            
            // ✅ طباعة Progress كل 10%
            if (total > 0) {
              final percent = (received / total * 100).toInt();
              if (percent % 10 == 0) {
                print('📊 Download progress: $percent% ($received / $total bytes)');
              }
            }
          }

          await sink.flush();
          await sink.close();

          // ✅ التحقق من وجود الملف وحجمه
          if (await file.exists()) {
            final fileSize = await file.length();
            print('✅ File downloaded successfully: ${file.path}');
            print('📊 File size: $fileSize bytes');
            return file;
          } else {
            print('❌ File does not exist after download');
            return null;
          }
        } catch (e) {
          await sink.close();
          print('❌ Error writing file: $e');
          rethrow;
        }
      } else {
        print("❌ Download failed with status: ${response.statusCode}");
        if (context.mounted) {
          _showError(context, "فشل تحميل الملف (خطأ ${response.statusCode})");
        }
      }
    } catch (e) {
      print("❌ Download error: $e");
      if (context.mounted) {
        _showError(context, "خطأ أثناء تحميل الملف: $e");
      }
    }
    return null;
  }

  static void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("خطأ"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("موافق"),
          )
        ],
      ),
    );
  }

  /// ✅ عرض dialog لاختيار: فتح مع تطبيق أو مشاركة
  static Future<String?> _showAppChooserDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('اختر إجراء'),
          content: const Text('لا يوجد تطبيق مثبت لفتح هذا الملف. اختر إجراء:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'open'),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.open_in_new, size: 20),
                  SizedBox(width: 8),
                  Text('فتح مع تطبيق'),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'share'),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.share, size: 20),
                  SizedBox(width: 8),
                  Text('مشاركة'),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('إلغاء'),
            ),
          ],
        );
      },
    );
  }
}
