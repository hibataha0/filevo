import 'package:flutter/material.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/services/folders_service.dart';
import 'package:filevo/generated/l10n.dart';

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
          title: Text(S.of(context).deleteFolder),
          content: Text(
            S.of(context).confirmDeleteFolder(folder['name'] ?? ''),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(S.of(context).cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(S.of(context).delete),
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
          SnackBar(
            content: Text(S.of(context).folderIdNotAvailable),
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
            content: Text(
              S.of(context).folderDeletedSuccessfully(folder['name'] ?? ''),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorMsg =
            folderController.errorMessage ?? S.of(context).errorDeletingFolder;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).errorDeletingFolderWithError(e.toString()),
          ),
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
          SnackBar(
            content: Text(S.of(context).folderIdNotAvailable),
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
            content: Text(
              S.of(context).folderRestoredSuccessfully(folder['name'] ?? ''),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorMsg =
            folderController.errorMessage ?? S.of(context).errorRestoringFolder;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).errorRestoringFolderWithError(e.toString()),
          ),
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
          title: Text(S.of(context).confirmPermanentDelete),
          content: Text(
            S.of(context).confirmPermanentDeleteFolder(folder['name'] ?? ''),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(S.of(context).cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(S.of(context).permanentDelete),
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
          SnackBar(
            content: Text(S.of(context).folderIdNotAvailable),
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
              S
                  .of(context)
                  .folderPermanentlyDeletedSuccessfully(folder['name'] ?? ''),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorMsg =
            folderController.errorMessage ??
            S.of(context).errorPermanentlyDeletingFolder;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).errorPermanentlyDeletingFolderWithError(e.toString()),
          ),
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
        SnackBar(
          content: Text(S.of(context).cannotIdentifyFolder),
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
            Text(S.of(context).downloadingFolder),
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
            content: Text(
              S
                  .of(context)
                  .folderDownloadedSuccessfully(result['fileName'] ?? ''),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['error'] ?? S.of(context).failedToDownloadFolder,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).errorDownloadingFolder(e.toString())),
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
            Text(S.of(context).downloadingFolder),
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
            content: Text(
              S
                  .of(context)
                  .folderDownloadedSuccessfully(result['fileName'] ?? ''),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['error'] ?? S.of(context).failedToDownloadFolder,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).errorDownloadingFolder(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
