import 'package:flutter/services.dart';

class SAF {
  static const MethodChannel _channel = MethodChannel('saf_channel');

  static Future<String?> openFolderPicker() async {
    final uri = await _channel.invokeMethod('openFolder');
    return uri;
  }

  static Future<List<String>> loadFiles(String folderUri) async {
    final files = await _channel.invokeMethod('listFiles', {
      "uri": folderUri,
    });
    return List<String>.from(files);
  }
}
