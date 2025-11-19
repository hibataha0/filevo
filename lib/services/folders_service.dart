import 'dart:convert';
import 'dart:io';
import 'package:filevo/services/api_endpoints.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/storage_service.dart';

class FolderService {
  Future<Map<String, dynamic>> createFolder({
    required String name,
    String? parentId,
  }) async {
    final token = await StorageService.getToken();

    final body = jsonEncode({
      'name': name,
      if (parentId != null) 'parentId': parentId,
    });

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.folders}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    return jsonDecode(response.body);
  }

  // رفع مجلد كامل
  Future<Map<String, dynamic>> uploadFolder({
    required String folderName,
    required List<File> files,
    required List<String> relativePaths,
    String? parentFolderId,
  }) async {
    final token = await StorageService.getToken();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${ApiConfig.baseUrl}${ApiEndpoints.uploadFolder}"),
    );

    request.headers['Authorization'] = "Bearer $token";

    request.fields['folderName'] = folderName;

    if (parentFolderId != null) {
      request.fields['parentFolderId'] = parentFolderId;
    }

    // 🔥 أهم خطوة: إرسال relativePaths كـ Array
    for (final path in relativePaths) {
      request.fields['relativePaths[]'] = path;
    }

    // 🔥 إضافة الملفات بشكل صحيح
    for (int i = 0; i < files.length; i++) {
      final file = files[i];

      request.files.add(
        await http.MultipartFile.fromPath(
          'files',      // ثابت، لا نستخدم مسار نسبي هنا
          file.path,
        ),
      );
    }

    final res = await request.send();
    final response = await http.Response.fromStream(res);

    return jsonDecode(response.body);
  }
}
