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
    // ✅ التحقق من مشاركة المجلد في Rooms قبل الحذف
    String? roomWarning;
    try {
      final folderId = folder['_id'] ?? 
                      folder['originalData']?['_id'] ?? 
                      folder['folderData']?['_id'];
      if (folderId != null) {
        final folderService = FolderService();
        final sharedDetails = await folderService.getSharedFolderDetailsInRoom(
          folderId: folderId.toString(),
        );
        // ✅ التحقق من وجود room في sharedDetails
        if (sharedDetails != null) {
          // ✅ محاولة قراءة room من folder.room أو rooms
          final folderData = sharedDetails['folder'] as Map<String, dynamic>?;
          final room = folderData?['room'] as Map<String, dynamic>?;
          final rooms = sharedDetails['rooms'] as List?;
          
          if (room != null) {
            // ✅ إذا كان هناك room واحد
            final roomName = room['name'] ?? 'Unknown';
            roomWarning = S.of(context).folderSharedInRoom(roomName);
          } else if (rooms != null && rooms.isNotEmpty) {
            // ✅ إذا كان هناك قائمة rooms
            final roomNames = rooms.map((r) => r['name'] ?? 'Unknown').join(', ');
            roomWarning = S.of(context).folderSharedInMultipleRooms(rooms.length, roomNames);
          }
        }
      }
    } catch (e) {
      print('⚠️ [FolderActionsService] Error checking room sharing: $e');
      // لا نعرض خطأ للمستخدم، فقط نتابع الحذف
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(S.of(context).deleteFolder),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).confirmDeleteFolder(folder['name'] ?? ''),
              ),
              if (roomWarning != null) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Text(
                    roomWarning!,
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  S.of(context).folderWillBeRemovedFromAllRooms,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
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

      final result = await folderController.deleteFolder(
        folderId: folderId.toString(),
      );

      if (!context.mounted) return;

      if (result['success'] == true) {
        if (onLocalUpdate != null) onLocalUpdate();

        // ✅ بناء رسالة النجاح مع معلومات الـ Rooms إذا كانت موجودة
        String successMessage = S.of(context).folderDeletedSuccessfully(folder['name'] ?? '');
        final warning = result['warning'];
        final roomsRemovedFrom = result['roomsRemovedFrom'] as List? ?? [];
        
        if (warning != null && warning.toString().isNotEmpty) {
          successMessage += '\n\n$warning';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
            duration: roomsRemovedFrom.isNotEmpty 
              ? Duration(seconds: 5) 
              : Duration(seconds: 3),
          ),
        );
      } else {
        final errorMsg =
            result['message'] ?? 
            folderController.errorMessage ?? 
            S.of(context).errorDeletingFolder;
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

      final result = await folderController.restoreFolder(
        folderId: folderId.toString(),
      );

      if (!context.mounted) return;

      if (result['success'] == true) {
        if (onLocalUpdate != null) onLocalUpdate();

        // ✅ بناء رسالة النجاح مع عدد الملفات المسترجعة
        final filesRestored = result['filesRestored'] as int? ?? 0;
        String successMessage = S.of(context).folderRestoredSuccessfully(folder['name'] ?? '');
        
        if (filesRestored > 0) {
          successMessage += S.of(context).filesRestoredWithFolder(filesRestored);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
            duration: filesRestored > 0 
              ? Duration(seconds: 4) 
              : Duration(seconds: 3),
          ),
        );
      } else {
        final errorMsg =
            result['message'] ?? 
            folderController.errorMessage ?? 
            S.of(context).errorRestoringFolder;
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

      final result = await folderController.deleteFolderPermanent(
        folderId: folderId.toString(),
      );

      if (!context.mounted) return;

      if (result['success'] == true) {
        if (onLocalUpdate != null) onLocalUpdate();

        // ✅ بناء رسالة النجاح مع معلومات الـ Rooms إذا كانت موجودة
        String successMessage = S
            .of(context)
            .folderPermanentlyDeletedSuccessfully(folder['name'] ?? '');
        final warning = result['warning'];
        final roomsRemovedFrom = result['roomsRemovedFrom'] as List? ?? [];
        
        if (warning != null && warning.toString().isNotEmpty) {
          successMessage += '\n\n$warning';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
            duration: roomsRemovedFrom.isNotEmpty 
              ? Duration(seconds: 5) 
              : Duration(seconds: 3),
          ),
        );
      } else {
        final errorMsg =
            result['message'] ?? 
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
    // ✅ الحصول على folderId من جميع الأماكن المحتملة (للمجلدات الأصلية، الفرعية، والمشتركة)
    final folderId = folder['folderId'] ??
        folder['_id'] ??
        folder['folderData']?['_id'] ??
        folder['originalData']?['_id'];

    final folderName = folder['name'] ??
        folder['title'] ??
        folder['folderData']?['name'] ??
        folder['originalData']?['name'] ??
        'folder';

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
