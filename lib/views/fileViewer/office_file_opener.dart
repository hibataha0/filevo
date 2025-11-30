import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';

class OfficeFileOpener {
  static const MethodChannel _channel = MethodChannel("file_chooser_channel");

  /// فتح أي ملف باستخدام تطبيق خارجي (docx, pptx, zip, apk, exe ...)
  static Future<void> openAnyFile({
    required String url,
    required BuildContext context,
    String? token,
  }) async {
    final fileName = _getFileName(url);
    final file = await _downloadFileToCache(url, fileName, token, context);

    if (file != null) {
      try {
        if (Platform.isAndroid) {
          // فتح الملف مع اختيار التطبيق على أندرويد
          await _channel.invokeMethod("openWithChooser", {"path": file.path});
        } else {
          // iOS وغيره يفتح مباشرة
          await OpenFile.open(file.path);
        }
      } catch (e) {
        print("Open File Error: $e");
        _showError(context, "فشل فتح الملف: $e");
      }
    } else {
      _showError(context, "فشل تحميل الملف.");
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
  static Future<File?> _downloadFileToCache(
      String url, String fileName, String? token, BuildContext context) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');

      final request = http.Request('GET', Uri.parse(url));
      if (token != null) request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send();

      if (response.statusCode == 200) {
        final total = response.contentLength ?? 0;
        int received = 0;

        final sink = file.openWrite();
        await for (var chunk in response.stream) {
          received += chunk.length;
          sink.add(chunk);

          // اختياري: يمكن إضافة شريط تحميل
          // print("Downloading ${((received / total) * 100).toStringAsFixed(0)}%");
        }

        await sink.flush();
        await sink.close();

        return file;
      } else {
        print("Download failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("Download error: $e");
      _showError(context, "خطأ أثناء تحميل الملف: $e");
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
}
