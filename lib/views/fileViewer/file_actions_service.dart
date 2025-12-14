import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/services/file_service.dart';
import 'package:filevo/views/folders/share_file_with_room_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FileActionsService {
  static bool _isLoading = false;
  static String? _errorMessage;
  static String? _successMessage;

  // Getters
  static bool get isLoading => _isLoading;
  static String? get errorMessage => _errorMessage;
  static String? get successMessage => _successMessage;

  static void _setLoading(bool value) => _isLoading = value;
  static void _setError(String? message) => _errorMessage = message;
  static void _setSuccess(String? message) => _successMessage = message;
  static void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  /// فتح الملف (فقط يستدعي callback)
  static void openFile(
    Map<String, dynamic> file,
    void Function(Map<String, dynamic>)? onFileTap,
  ) {
    if (onFileTap != null) onFileTap(file);
  }

  /// تعديل الملف
  static void editFile(BuildContext context, Map<String, dynamic> file) {
    final fileController = Provider.of<FileController>(context, listen: false);
    final originalName = file['originalData']['name'] ?? '';
    final originalExtension = originalName.contains('.')
        ? '.' + originalName.split('.').last
        : '';
    final baseName = originalExtension.isNotEmpty
        ? originalName.replaceAll(originalExtension, '')
        : originalName;

    final TextEditingController nameCtrl = TextEditingController(
      text: baseName,
    );
    final TextEditingController descCtrl = TextEditingController(
      text: file['originalData']['description'] ?? '',
    );
    final TextEditingController tagsCtrl = TextEditingController(
      text: (file['originalData']['tags'] as List?)?.join(', ') ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "تعديل الملف",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SizedBox(
            width: 350,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: "اسم الملف",
                      suffixText: originalExtension,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: "الوصف",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tagsCtrl,
                    decoration: const InputDecoration(
                      labelText: "الوسوم (افصل بينها بفاصلة)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              onPressed: () async {
                final token = await StorageService.getToken();
                if (token == null) return;

                final success = await fileController.updateFile(
                  fileId: file['originalData']['_id'],
                  token: token,
                  name: nameCtrl.text.trim() + originalExtension,
                  description: descCtrl.text.trim(),
                  tags: tagsCtrl.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                );

                Navigator.pop(context);

                if (success == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✅ تم حفظ التعديلات بنجاح"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("❌ فشل حفظ التعديلات"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("حفظ التعديلات"),
            ),
          ],
        );
      },
    );
  }

  /// مشاركة الملف مع غرفة
  static Future<void> shareFile(
    BuildContext context,
    Map<String, dynamic> file,
  ) async {
    final fileId = file['originalData']?['_id'] ?? file['_id'];
    final fileName = file['name'] ?? file['originalData']?['name'] ?? 'ملف';

    if (fileId == null) {
      _showErrorSnackBar(context, 'لا يمكن تحديد الملف');
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => RoomController(),
          child: ShareFileWithRoomPage(fileId: fileId, fileName: fileName),
        ),
      ),
    );

    if (result == true && context.mounted) {
      _showSuccessSnackBar(context, '✅ تم إرسال طلب المشاركة للغرفة');
    }
  }

  /// حذف الملف
  static Future<void> deleteFile(
    BuildContext context,
    FileController fileController,
    Map<String, dynamic> file, {
    VoidCallback? onLocalUpdate,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("حذف الملف"),
          content: Text("هل أنت متأكد من حذف الملف '${file['name']}'؟"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text("حذف"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final token = await StorageService.getToken();
    if (token == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ خطأ: لا يوجد توكن."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    fileController.setLoading(true);
    fileController.setError(null);
    fileController.setSuccess(null);

    try {
      final success = await fileController.deleteFile(
        fileId: file['_id'] ?? file['originalData']?['_id'],
        token: token,
      );

      if (!context.mounted) return;

      if (success) {
        fileController.starredFiles.removeWhere(
          (f) => f['_id'] == (file['_id'] ?? file['originalData']?['_id']),
        );
        if (onLocalUpdate != null) onLocalUpdate();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ تم حذف الملف '${file['name']}' بنجاح"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorMsg =
            fileController.errorMessage ?? "❌ حدث خطأ أثناء حذف الملف";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ حدث خطأ أثناء حذف الملف: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      fileController.setLoading(false);
    }
  }

  /// إلغاء مشاركة ملف
  static Future<void> unshareFile(
    BuildContext context,
    FileController fileController,
    Map<String, dynamic> file, {
    VoidCallback? onLocalUpdate,
  }) async {
    final sharedWith = (file['originalData']?['sharedWith'] as List?) ?? [];
    if (sharedWith.isEmpty) {
      _showErrorSnackBar(context, "لا يوجد مستخدمون مشارك معهم الملف");
      return;
    }

    final userIds = sharedWith
        .map((user) {
          final userObj = user['user'];
          if (userObj is Map && userObj['_id'] != null) {
            return userObj['_id'].toString();
          } else if (userObj is String) {
            return userObj;
          }
          return user['userId']?.toString();
        })
        .whereType<String>()
        .toList();

    if (userIds.isEmpty) {
      _showErrorSnackBar(context, "لا يمكن تحديد المستخدمين لإلغاء المشاركة");
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("إلغاء مشاركة الملف"),
        content: const Text(
          "هل أنت متأكد من إلغاء مشاركة هذا الملف مع جميع المستخدمين؟",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("إلغاء المشاركة"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final token = await StorageService.getToken();
    if (token == null) {
      _showErrorSnackBar(context, "❌ خطأ: لا يوجد توكن");
      return;
    }

    final success = await fileController.unshareFile(
      fileId: file['originalData']?['_id'] ?? file['_id'],
      userIds: userIds,
      token: token,
    );

    if (!context.mounted) return;

    if (success) {
      file['originalData']['sharedWith'] = [];
      file['originalData']['isShared'] = false;
      onLocalUpdate?.call();
      _showSuccessSnackBar(context, "✅ تم إلغاء مشاركة الملف");
    } else {
      _showErrorSnackBar(
        context,
        fileController.errorMessage ?? "فشل إلغاء المشاركة",
      );
    }
  }

  /// toggle favorite بدون ريفريش كامل
  /// toggle favorite بدون ريفريش كامل
  /// toggle favorite بدون ريفريش كامل
  /// toggle favorite بدون ريفريش كامل
  /// toggle favorite بدون ريفريش كامل
  static Future<void> toggleStar(
    BuildContext context,
    FileController controller,
    Map<String, dynamic> file, {
    VoidCallback? onToggle,
  }) async {
    final fileId = file['originalData']['_id'];
    if (fileId == null) return;

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        _showErrorSnackBar(context, "❌ خطأ: لا يوجد توكن");
        return;
      }

      // ✅ إظهار مؤشر التحميل (مثل المجلدات)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('جاري التحديث...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // ✅ نستدعي الـ backend ونجيب النتيجة (Map بدلاً من bool)
      final result = await controller.toggleStar(fileId: fileId, token: token);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (result['success'] == true) {
        final isStarred = result['isStarred'] as bool? ?? false;
        final updatedFile = result['file'] as Map<String, dynamic>?;

        // ✅ نحدث البيانات المحلية بالقيمة الحقيقية من الـ backend
        if (updatedFile != null) {
          file['originalData'] = updatedFile;
          file['originalData']['isStarred'] = isStarred;
        } else {
          file['originalData']['isStarred'] = isStarred;
        }

        // ✅ نستدعي الـ callback عشان يحدث الـ UI
        onToggle?.call();

        // ✅ عرض رسالة نجاح
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isStarred
                    ? '✅ تم إضافة الملف إلى المفضلة'
                    : '✅ تم إزالة الملف من المفضلة',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        print('✅ Star updated successfully to: $isStarred');
      } else {
        _showErrorSnackBar(
          context,
          result['message'] ?? "❌ حدث خطأ أثناء التحديث",
        );
      }
    } catch (e) {
      print('❌ Error in toggleStar: $e');
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showErrorSnackBar(context, "❌ حدث خطأ أثناء التحديث");
    }
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ✅ إضافة helper للرسائل الإيجابية
  static void _showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// ✅ تحميل ملف خاص بالمستخدم
  static Future<void> downloadFile(
    BuildContext context,
    Map<String, dynamic> file,
  ) async {
    final fileId = file['originalData']?['_id'] ?? file['_id'];
    final fileName = file['name'] ?? file['originalData']?['name'] ?? 'file';

    if (fileId == null) {
      _showErrorSnackBar(context, 'لا يمكن تحديد الملف');
      return;
    }

    final token = await StorageService.getToken();
    if (token == null) {
      _showErrorSnackBar(context, '❌ خطأ: يجب تسجيل الدخول أولاً');
      return;
    }

    // ✅ إظهار مؤشر التحميل
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            const Text('جاري تحميل الملف...'),
          ],
        ),
        duration: const Duration(seconds: 30),
      ),
    );

    try {
      final fileService = FileService();
      final result = await fileService.downloadFile(
        fileId: fileId,
        token: token,
        fileName: fileName,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (result['success'] == true) {
        _showSuccessSnackBar(
          context,
          '✅ تم تحميل الملف بنجاح: ${result['fileName']}',
        );
      } else {
        _showErrorSnackBar(context, result['error'] ?? 'فشل تحميل الملف');
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showErrorSnackBar(context, '❌ خطأ في تحميل الملف: ${e.toString()}');
    }
  }

  /// ✅ تحميل ملف مشترك في الروم
  static Future<void> downloadRoomFile(
    BuildContext context,
    RoomController roomController,
    String roomId,
    String fileId,
    String? fileName,
  ) async {
    // ✅ إظهار مؤشر التحميل
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            const Text('جاري تحميل الملف...'),
          ],
        ),
        duration: const Duration(seconds: 30),
      ),
    );

    try {
      final result = await roomController.downloadRoomFile(
        roomId: roomId,
        fileId: fileId,
        fileName: fileName,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (result['success'] == true) {
        _showSuccessSnackBar(
          context,
          '✅ تم تحميل الملف بنجاح: ${result['fileName']}',
        );
      } else {
        _showErrorSnackBar(context, result['error'] ?? 'فشل تحميل الملف');
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showErrorSnackBar(context, '❌ خطأ في تحميل الملف: ${e.toString()}');
    }
  }
}
