import 'dart:io';
import 'package:flutter/services.dart';

class SAF {
  static const MethodChannel _channel = MethodChannel('saf_channel');

  /// فتح Folder Picker
  static Future<String?> openFolderPicker() async {
    try {
      print("📁 Opening SAF folder picker...");
      final uri = await _channel.invokeMethod<String>('openFolder');

      if (uri != null) {
        print("✅ Folder selected: $uri");
      } else {
        print("ℹ️ User cancelled.");
      }

      return uri;
    } catch (e) {
      print("❌ Error in openFolderPicker: $e");
      return null;
    }
  }

  /// قراءة جميع الملفات (من native)
  static Future<(List<File>, List<String>, int)> loadFiles(String folderUri) async {
    try {
      print("📁 Loading files from SAF $folderUri");

      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'listFiles',
        {"uri": folderUri},
      );

      if (result == null) return (<File>[], <String>[], 0);

      final filePaths = List<String>.from(result['files']);
      final relativePaths = List<String>.from(result['relativePaths']);
      final count = result['count'] as int;

      final files = filePaths.map((path) => File(path)).toList();

      return (files, relativePaths, count);
    } catch (e) {
      print("❌ Error in loadFiles: $e");
      return (<File>[], <String>[], 0);
    }
  }
}
