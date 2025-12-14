import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/services/folders_service.dart';

/// خدمة لإدارة إجراءات المجلدات (حذف، استعادة، إلخ)
class FolderActionsService {
  /// حذف المجلد
  static Future<void> deleteFolder(
    BuildContext context,
    FolderController folderController,
    Map<String, dynamic> folder, {
    VoidCallback? onLocalUpdate,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("حذف المجلد"),
          content: Text(
            "هل أنت متأكد من حذف المجلد '${folder['name']}'؟ سيتم حذف جميع الملفات والمجلدات الفرعية أيضاً.",
          ),
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

    folderController.setLoading(true);
    folderController.errorMessage = null;

    try {
      final folderId =
          folder['_id'] ??
          folder['originalData']?['_id'] ??
          folder['folderData']?['_id'];

      if (folderId == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ خطأ: معرف المجلد غير متوفر."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await folderController.deleteFolder(
        folderId: folderId.toString(),
      );

      if (!context.mounted) return;

      if (success) {
        if (onLocalUpdate != null) onLocalUpdate();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ تم حذف المجلد '${folder['name']}' بنجاح"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorMsg =
            folderController.errorMessage ?? "❌ حدث خطأ أثناء حذف المجلد";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ حدث خطأ أثناء حذف المجلد: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      folderController.setLoading(false);
    }
  }

  /// استعادة مجلد من المهملات
  static Future<void> restoreFolder(
    BuildContext context,
    FolderController folderController,
    Map<String, dynamic> folder, {
    VoidCallback? onLocalUpdate,
  }) async {
    folderController.setLoading(true);
    folderController.errorMessage = null;

    try {
      final folderId =
          folder['_id'] ??
          folder['originalData']?['_id'] ??
          folder['folderData']?['_id'];

      if (folderId == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ خطأ: معرف المجلد غير متوفر."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await folderController.restoreFolder(
        folderId: folderId.toString(),
      );

      if (!context.mounted) return;

      if (success) {
        if (onLocalUpdate != null) onLocalUpdate();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ تم استعادة المجلد '${folder['name']}' بنجاح"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorMsg =
            folderController.errorMessage ?? "❌ حدث خطأ أثناء استعادة المجلد";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ حدث خطأ أثناء استعادة المجلد: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      folderController.setLoading(false);
    }
  }

  /// حذف مجلد نهائياً
  static Future<void> deleteFolderPermanent(
    BuildContext context,
    FolderController folderController,
    Map<String, dynamic> folder, {
    VoidCallback? onLocalUpdate,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("تأكيد الحذف النهائي"),
          content: Text(
            "هل أنت متأكد من الحذف النهائي للمجلد '${folder['name']}'؟ لا يمكن التراجع عن هذا الإجراء. سيتم حذف جميع الملفات والمجلدات الفرعية نهائياً.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text("حذف نهائي"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    folderController.setLoading(true);
    folderController.errorMessage = null;

    try {
      final folderId =
          folder['_id'] ??
          folder['originalData']?['_id'] ??
          folder['folderData']?['_id'];

      if (folderId == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ خطأ: معرف المجلد غير متوفر."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await folderController.deleteFolderPermanent(
        folderId: folderId.toString(),
      );

      if (!context.mounted) return;

      if (success) {
        if (onLocalUpdate != null) onLocalUpdate();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "✅ تم الحذف النهائي للمجلد '${folder['name']}' بنجاح",
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorMsg =
            folderController.errorMessage ??
            "❌ حدث خطأ أثناء الحذف النهائي للمجلد";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ حدث خطأ أثناء الحذف النهائي للمجلد: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      folderController.setLoading(false);
    }
  }

  /// ✅ تحميل مجلد خاص بالمستخدم
  static Future<void> downloadFolder(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    final folderId = folder['_id'] ?? folder['folderData']?['_id'];
    final folderName =
        folder['name'] ?? folder['folderData']?['name'] ?? 'folder';

    if (folderId == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ خطأ: لا يمكن تحديد المجلد'),
          backgroundColor: Colors.red,
        ),
      );
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
            const Text('جاري تحميل المجلد...'),
          ],
        ),
        duration: const Duration(seconds: 60),
      ),
    );

    try {
      final folderService = FolderService();
      final result = await folderService.downloadFolder(
        folderId: folderId,
        folderName: '$folderName.zip',
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم تحميل المجلد بنجاح: ${result['fileName']}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'فشل تحميل المجلد'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ خطأ في تحميل المجلد: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// ✅ تحميل مجلد مشترك في الروم
  static Future<void> downloadRoomFolder(
    BuildContext context,
    RoomController roomController,
    String roomId,
    String folderId,
    String? folderName,
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
            const Text('جاري تحميل المجلد...'),
          ],
        ),
        duration: const Duration(seconds: 60),
      ),
    );

    try {
      final result = await roomController.downloadRoomFolder(
        roomId: roomId,
        folderId: folderId,
        folderName: folderName != null ? '$folderName.zip' : null,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم تحميل المجلد بنجاح: ${result['fileName']}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'فشل تحميل المجلد'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ خطأ في تحميل المجلد: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
