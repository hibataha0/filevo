import 'package:filevo/components/FolderFileCard.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:filevo/responsive.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/views/folders/share_folder_with_room_page.dart';
import 'package:filevo/views/fileViewer/folder_actions_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:filevo/dialogs/folder_protection_dialogs.dart';
import 'package:filevo/views/fileViewer/file_actions_service.dart';
import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/views/fileViewer/file_details_page.dart';
import 'package:filevo/constants/app_colors.dart';

// ✅ Helper functions للتعامل مع إجراءات المجلد

/// 🔍 الحصول على folderId من جميع الأماكن المحتملة (للمجلدات الفرعية)
String? _getFolderId(Map<String, dynamic> folder) {
  return folder['folderId'] as String? ??
      folder['_id'] as String? ??
      folder['folderData']?['_id'] as String? ??
      folder['originalData']?['_id'] as String?;
}

/// 🔐 التحقق من الوصول لمجلد محمي قبل تنفيذ أي عملية
Future<bool> _verifyProtectedFolderAccess(
  BuildContext context,
  Map<String, dynamic> folder,
) async {
  // ✅ البحث عن isProtected في جميع الأماكن المحتملة (للمجلدات الفرعية أيضاً)
  Map<String, dynamic>? folderData;
  bool isProtected = false;
  String protectionType = 'none';

  // ✅ محاولة 1: folder['folderData']
  folderData = folder['folderData'] as Map<String, dynamic>?;
  if (folderData != null) {
    isProtected = folderData['isProtected'] == true;
    protectionType = folderData['protectionType']?.toString() ?? 'none';
  }

  // ✅ محاولة 2: folder['originalData'] (للمجلدات الفرعية)
  if (!isProtected && folder['originalData'] != null) {
    final originalData = folder['originalData'] as Map<String, dynamic>?;
    if (originalData != null) {
      isProtected = originalData['isProtected'] == true;
      protectionType = originalData['protectionType']?.toString() ?? 'none';
      if (isProtected) {
        folderData = originalData;
      }
    }
  }

  // ✅ محاولة 3: folder مباشرة
  if (!isProtected) {
    isProtected = folder['isProtected'] == true;
    protectionType = folder['protectionType']?.toString() ?? 'none';
    if (isProtected) {
      folderData = folder;
    }
  }

  // ✅ محاولة 4: folder['itemData']?['folderData'] (للمجلدات في القوائم)
  if (!isProtected && folder['itemData'] != null) {
    final itemData = folder['itemData'] as Map<String, dynamic>?;
    if (itemData != null) {
      final itemFolderData = itemData['folderData'] as Map<String, dynamic>?;
      if (itemFolderData != null) {
        isProtected = itemFolderData['isProtected'] == true;
        protectionType = itemFolderData['protectionType']?.toString() ?? 'none';
        if (isProtected) {
          folderData = itemFolderData;
        }
      }
    }
  }

  // ✅ إذا لم يكن المجلد محمياً، لا حاجة للتحقق
  if (!isProtected || protectionType == 'none') {
    return true;
  }

  // ✅ الحصول على folderId و folderName من جميع الأماكن المحتملة
  final folderId = folder['folderId'] as String? ??
      folderData?['_id'] as String? ??
      folder['_id'] as String? ??
      folder['originalData']?['_id'] as String?;

  final folderName = folder['title'] as String? ??
      folderData?['name'] as String? ??
      folder['name'] as String? ??
      folder['originalData']?['name'] as String? ??
      S.of(context).folder;

  if (folderId == null) {
    return false;
  }

  // ✅ طلب كلمة السر
  final result = await showVerifyFolderAccessDialog(
    context,
    folderId,
    folderName,
    protectionType,
  );

  // ✅ إرجاع true إذا تم التحقق بنجاح
  return result['success'] == true;
}

void _showFolderInfo(BuildContext context, Map<String, dynamic> folder, {String? roomId}) async {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  // ✅ التحقق من كلمة السر إذا كان المجلد محمياً
  final hasAccess = await _verifyProtectedFolderAccess(context, folder);
  if (!hasAccess) {
    return; // ✅ إيقاف العملية إذا لم يتم التحقق
  }

  final folderId = folder['folderId'] as String?;
  final folderName = folder['title'] as String;
  final folderColor = folder['color'] as Color? ?? AppColors.getPrimary(isDarkMode);

  if (folderId == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(S.of(context).folderIdNotFound)));
    return;
  }

  // ✅ جلب تفاصيل المجلد من الباك إند
  final folderController = Provider.of<FolderController>(
    context,
    listen: false,
  );
  
  // ✅ إذا كان المجلد مشترك في الروم، استخدم getSharedFolderDetailsInRoom
  Map<String, dynamic>? folderDetails;
  if (roomId != null && roomId.isNotEmpty) {
    try {
      folderDetails = await folderController.getSharedFolderDetailsInRoom(
        folderId: folderId,
      );
    } catch (e) {
      // ✅ إذا فشل، حاول جلب تفاصيل المجلد العادية
      folderDetails = await folderController.getFolderDetails(
        folderId: folderId,
      );
    }
  } else {
    folderDetails = await folderController.getFolderDetails(
      folderId: folderId,
    );
  }

  if (folderDetails == null || folderDetails['folder'] == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).failedToFetchFolderInfo)),
      );
    }
    return;
  }

  final folderData = folderDetails['folder'] as Map<String, dynamic>;

  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: AppColors.getCardColor(isDarkMode),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ✅ Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: folderColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(Icons.folder, color: Colors.white, size: 32),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    folderData['name'] ?? folderName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // ✅ Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem(
                    context,
                    'folder',
                    '📁',
                    S.of(context).type,
                    S.of(context).folder,
                  ),
                  _buildDetailItem(
                    context,
                    'size',
                    '💾',
                    S.of(context).size,
                    _formatBytes(folderData['size'] ?? 0),
                  ),
                  _buildDetailItem(
                    context,
                    'files',
                    '📄',
                    S.of(context).filesCount,
                    '${folderData['filesCount'] ?? 0}',
                  ),
                  _buildDetailItem(
                    context,
                    'subfolders',
                    '📂',
                    S.of(context).subfoldersCount,
                    '${folderData['subfoldersCount'] ?? 0}',
                  ),
                  _buildDetailItem(
                    context,
                    'time',
                    '🕐',
                    S.of(context).createdAt,
                    _formatDate(folderData['createdAt']),
                  ),
                  _buildDetailItem(
                    context,
                    'edit',
                    '✏️',
                    S.of(context).detailUpdatedAt,
                    _formatDate(folderData['updatedAt']),
                  ),
                  _buildDetailItem(
                    context,
                    'description',
                    '📝',
                    S.of(context).description,
                    folderData['description']?.isNotEmpty == true
                        ? folderData['description']
                        : "—",
                  ),
                  _buildDetailItem(
                    context,
                    'tags',
                    '🏷️',
                    S.of(context).tags,
                    (folderData['tags'] as List?)?.join(', ') ?? "—",
                  ),

                  // ✅ Shared With Section
                  if (folderData['sharedWith'] != null &&
                      (folderData['sharedWith'] as List).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        _buildDetailItem(
                          context,
                          'share',
                          '👥',
                          S.of(context).sharedWith,
                          (folderData['sharedWith'] as List)
                                  .map<String>(
                                    (u) =>
                                        u['user']?['email']?.toString() ??
                                        u['email']?.toString() ??
                                        '',
                                  )
                                  .where((email) => email.isNotEmpty)
                                  .join(', ') ??
                              "—",
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

String _formatBytes(int bytes) {
  if (bytes == 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];

  int i = 0;
  double size = bytes.toDouble();

  while (size >= k && i < sizes.length - 1) {
    size /= k;
    i++;
  }

  if (i >= sizes.length) {
    i = sizes.length - 1;
  }

  return '${size.toStringAsFixed(1)} ${sizes[i]}';
}

String _formatDate(dynamic date) {
  if (date == null) return "—";
  try {
    final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  } catch (e) {
    return "—";
  }
}

Widget _buildDetailItem(BuildContext context, String type, String emoji, String label, String value) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  Color getIconColor() {
    switch (type) {
      case 'folder':
        return Color(0xFF10B981);
      case 'size':
        return Color(0xFFF59E0B);
      case 'files':
        return Color(0xFF3B82F6);
      case 'subfolders':
        return Color(0xFF8B5CF6);
      case 'time':
        return Color(0xFFEF4444);
      case 'edit':
        return Color(0xFF8B5CF6);
      case 'description':
        return Color(0xFF4F6BED);
      case 'tags':
        return Color(0xFFEC4899);
      case 'share':
        return Color(0xFF06B6D4);
      default:
        return Color(0xFF6B7280);
    }
  }

  return Container(
    margin: EdgeInsets.only(bottom: 20),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDarkMode 
          ? AppColors.darkSurface 
          : Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDarkMode 
            ? AppColors.darkSurface 
            : Colors.grey[200]!,
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: getIconColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(emoji, style: TextStyle(fontSize: 20)),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getTextSecondary(isDarkMode),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.getTextPrimary(isDarkMode),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ✅ دالة لعرض تفاصيل التصنيف (Category)
void _showCategoryDetails(BuildContext context, Map<String, dynamic> category) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final categoryTitle = category['title'] as String? ?? S.of(context).category;
  final fileCount = category['fileCount'] as int? ?? 0;
  final size = category['size'] as String? ?? '0';
  final color = category['color'] as Color? ?? AppColors.getPrimary(isDarkMode);
  final icon = category['icon'] as IconData? ?? Icons.folder;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: AppColors.getCardColor(isDarkMode),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ✅ Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 32),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    categoryTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // ✅ Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem(
                    context,
                    'folder',
                    '📁',
                    S.of(context).type,
                    S.of(context).category,
                  ),
                  _buildDetailItem(
                    context,
                    'files',
                    '📄',
                    S.of(context).filesCount,
                    '$fileCount',
                  ),
                  _buildDetailItem(
                    context,
                    'size', 
                    '💾', 
                    S.of(context).totalSize, 
                    size,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _showRenameDialog(BuildContext context, Map<String, dynamic> folder) async {
  // ✅ التحقق من كلمة السر إذا كان المجلد محمياً
  final hasAccess = await _verifyProtectedFolderAccess(context, folder);
  if (!hasAccess) {
    return; // ✅ إيقاف العملية إذا لم يتم التحقق
  }

  // ✅ الحصول على folderId من جميع الأماكن المحتملة (للمجلدات الفرعية)
  final folderId = folder['folderId'] as String? ??
      folder['_id'] as String? ??
      folder['folderData']?['_id'] as String? ??
      folder['originalData']?['_id'] as String?;

  final folderName = folder['title'] as String? ??
      folder['name'] as String? ??
      folder['folderData']?['name'] as String? ??
      folder['originalData']?['name'] as String? ??
      S.of(context).folder;

  final folderData = folder['folderData'] as Map<String, dynamic>? ??
      folder['originalData'] as Map<String, dynamic>? ??
      folder;

  final nameController = TextEditingController(text: folderName);
  final descriptionController = TextEditingController(
    text: folderData?['description'] as String? ?? '',
  );
  final tagsController = TextEditingController(
    text: (folderData?['tags'] as List?)?.join(', ') ?? '',
  );

  final scaffoldContext = context; // ✅ حفظ context الأصلي

  if (folderId == null) {
    ScaffoldMessenger.of(
      scaffoldContext,
    ).showSnackBar(SnackBar(content: Text(S.of(context).folderIdNotFound)));
    return;
  }

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(S.of(context).editFolder),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: S.of(context).folderName,
                hintText: S.of(context).folderNameHint,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.folder),
              ),
              autofocus: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: S.of(context).description,
                hintText: S.of(context).descriptionHint,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextField(
              controller: tagsController,
              decoration: InputDecoration(
                labelText: S.of(context).tags,
                hintText: S.of(context).tagsHint,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('إلغاء'),
        ),
        TextButton(
          onPressed: () {
            final newName = nameController.text.trim();
            if (newName.isEmpty) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(content: Text(S.of(context).enterFolderName)),
              );
              return;
            }

            final description = descriptionController.text.trim();
            final tagsString = tagsController.text.trim();
            final tags = tagsString.isNotEmpty
                ? tagsString
                      .split(',')
                      .map((t) => t.trim())
                      .where((t) => t.isNotEmpty)
                      .toList()
                : <String>[];

            _performUpdate(
              dialogContext,
              scaffoldContext,
              folderId,
              newName,
              description.isEmpty ? null : description,
              tags.isEmpty ? null : tags,
            );
          },
          child: Text(S.of(context).save),
        ),
      ],
    ),
  );
}

void _performUpdate(
  BuildContext dialogContext,
  BuildContext scaffoldContext,
  String folderId,
  String newName,
  String? description,
  List<String>? tags,
) async {
  final folderController = Provider.of<FolderController>(
    scaffoldContext,
    listen: false,
  );

  Navigator.pop(dialogContext);

  final success = await folderController.updateFolder(
    folderId: folderId,
    name: newName,
    description: description,
    tags: tags,
  );

  if (scaffoldContext.mounted) {
    if (success) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text(S.of(scaffoldContext).folderUpdateSuccess),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text(
            folderController.errorMessage ??
                S.of(scaffoldContext).folderUpdateFailed,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

void _showShareDialog(BuildContext context, Map<String, dynamic> folder) async {
  final folderId = folder['folderId'] as String?;
  final folderName = folder['title'] as String;

  if (folderId == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(S.of(context).folderIdNotFound)));
    return;
  }

  // ✅ تم السماح بمشاركة المجلدات المحمية في الرومات (يتم طلب كلمة السر عند فتحها)
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          ShareFolderWithRoomPage(folderId: folderId, folderName: folderName),
    ),
  );

  // ✅ إعادة تحميل البيانات بعد المشاركة (إذا لزم الأمر)
  if (result == true) {
    // يمكن إضافة منطق لإعادة تحميل البيانات هنا
  }
}

void _showMoveFolderDialog(
  BuildContext context,
  Map<String, dynamic> folder,
  void Function()? onFileRemoved,
) async {
  // ✅ التحقق من كلمة السر إذا كان المجلد محمياً
  final hasAccess = await _verifyProtectedFolderAccess(context, folder);
  if (!hasAccess) {
    return; // ✅ إيقاف العملية إذا لم يتم التحقق
  }

  // ✅ حفظ context الأصلي قبل فتح الـ modal
  final scaffoldContext = context;

  // ✅ الحصول على folderId من جميع الأماكن المحتملة (للمجلدات الفرعية)
  final folderId = folder['folderId'] as String? ??
      folder['_id'] as String? ??
      folder['folderData']?['_id'] as String? ??
      folder['originalData']?['_id'] as String?;

  final folderName = folder['title'] as String? ??
      folder['name'] as String? ??
      folder['folderData']?['name'] as String? ??
      folder['originalData']?['name'] as String? ??
      S.of(context).folder;

  final folderData = folder['folderData'] as Map<String, dynamic>? ??
      folder['originalData'] as Map<String, dynamic>? ??
      folder;

  final currentParentId = folderData['parentId']?.toString();
  if (folderId == null) {
    if (scaffoldContext.mounted) {
      ScaffoldMessenger.of(
        scaffoldContext,
      ).showSnackBar(SnackBar(content: Text(S.of(context).folderIdNotFound)));
    }
    return;
  }

  if (!scaffoldContext.mounted) return;

  showModalBottomSheet(
    context: scaffoldContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) => _FolderNavigationDialog(
      title: '${S.of(context).moveFolder} : $folderName',
      excludeFolderId: folderId,
      excludeParentId: currentParentId,
      onSelect: (targetFolderId) async {
        Navigator.pop(modalContext);
        if (scaffoldContext.mounted) {
          await _moveFolder(
            scaffoldContext,
            folderId,
            targetFolderId,
            folderName,
            onFileRemoved,
          );
        }
      },
    ),
  );
}

/// ✅ دالة لنقل المجلد
Future<void> _moveFolder(
  BuildContext scaffoldContext,
  String folderId,
  String? targetFolderId,
  String folderName,
  void Function()? onFileRemoved,
) async {
  final folderController = Provider.of<FolderController>(
    scaffoldContext,
    listen: false,
  );

  if (!scaffoldContext.mounted) return;

  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(width: 16),
          Text(S.of(scaffoldContext).movingFolder),
        ],
      ),
      duration: Duration(seconds: 30),
    ),
  );

  // ✅ نقل المجلد
  final success = await folderController.moveFolder(
    folderId: folderId,
    targetFolderId: targetFolderId,
  );

  if (scaffoldContext.mounted) {
    ScaffoldMessenger.of(scaffoldContext).hideCurrentSnackBar();

    if (success) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text(S.of(scaffoldContext).folderMoveSuccess),
          backgroundColor: AppColors.success,
        ),
      );

      // ✅ إعادة تحميل البيانات - استخدام callback إذا كان موجوداً
      if (onFileRemoved != null) {
        onFileRemoved();
      }
    } else {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text(
            folderController.errorMessage ??
                S.of(scaffoldContext).folderMoveFailed,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

void _toggleFavorite(
  BuildContext context,
  Map<String, dynamic> folder, {
  void Function()? onUpdate,
}) async {
  // ✅ الحصول على folderId من جميع الأماكن المحتملة (للمجلدات الفرعية)
  final folderId = folder['folderId'] as String? ??
      folder['_id'] as String? ??
      folder['folderData']?['_id'] as String? ??
      folder['originalData']?['_id'] as String?;

  if (folderId == null) return;

  final folderController = Provider.of<FolderController>(
    context,
    listen: false,
  );

  // ✅ حفظ الحالة الحالية قبل التبديل (للتأكد من التحديث الصحيح)
  final folderData = folder['folderData'] as Map<String, dynamic>?;

  // ✅ إظهار مؤشر التحميل
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
          Text(S.of(context).updating),
        ],
      ),
      duration: Duration(seconds: 2),
    ),
  );

  // ✅ استدعاء API لإضافة/إزالة من المفضلة
  final result = await folderController.toggleStarFolder(folderId: folderId);

  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  if (result['success'] == true) {
    // ✅ قراءة القيمة المحدثة من originalData مباشرة
    final updatedIsStarred = result['isStarred'] as bool? ?? false;
    final updatedFolder = result['folder'] as Map<String, dynamic>?;

    // ✅ تحديث بيانات المجلد المحلية فوراً لتغيير لون النجمة
    if (folderData != null) {
      folderData['isStarred'] = updatedIsStarred;
      if (updatedFolder != null) {
        // ✅ تحديث جميع البيانات من الـ response
        folderData.addAll(updatedFolder);
      }
    }

    // ✅ تحديث folder أيضاً مباشرة
    if (updatedFolder != null) {
      folder['folderData'] = updatedFolder;
      // ✅ تحديث isStarred مباشرة في item أيضاً
      folder['isStarred'] = updatedIsStarred;

      // ✅ تحديث itemData أيضاً إذا كان موجوداً
      final itemData = folder['itemData'] as Map<String, dynamic>?;
      if (itemData != null) {
        final itemFolderData = itemData['folderData'] as Map<String, dynamic>?;
        if (itemFolderData != null) {
          itemFolderData['isStarred'] = updatedIsStarred;
        }
      }
    } else {
      folder['isStarred'] = updatedIsStarred;

      // ✅ تحديث itemData أيضاً إذا كان موجوداً
      final itemData = folder['itemData'] as Map<String, dynamic>?;
      if (itemData != null) {
        final itemFolderData = itemData['folderData'] as Map<String, dynamic>?;
        if (itemFolderData != null) {
          itemFolderData['isStarred'] = updatedIsStarred;
        }
      }
    }

    // ✅ تحديث البيانات في widget.items أيضاً لضمان استمرار التحديث
    // ✅ ملاحظة: FilesGridView ليس StatefulWidget، لذا لا يمكننا استخدام setState
    // ✅ لكن يمكننا تحديث البيانات مباشرة في items إذا كان متاحاً
    // ✅ سيتم تحديث الـ UI تلقائياً عند إعادة بناء الـ widget من الصفحة الأم

    // ✅ إظهار رسالة النجاح
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updatedIsStarred
              ? S.of(context).folderAddedToFavorite
              : S.of(context).folderRemovedFromFavorite,
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // ✅ لا نستدعي onUpdate هنا - التحديث يحدث تلقائياً في البيانات المحلية
    // ✅ مثل الملفات، لا نحتاج لإعادة تحميل الصفحة

    // ✅ إجبار إعادة بناء الـ widget إذا كان في StatefulWidget
    // سيعمل notifyListeners() على تحديث Consumer widgets تلقائياً
  } else {
    // ✅ إظهار رسالة الخطأ
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          folderController.errorMessage ?? S.of(context).favoriteUpdateFaile,
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// 🔒 Dialog لقفل/إلغاء قفل المجلد
void _showProtectFolderDialog(
  BuildContext context,
  Map<String, dynamic> folder,
  void Function()? onFileRemoved,
) async {
  final scaffoldContext = context;

  final folderData = folder['folderData'] as Map<String, dynamic>? ?? {};
  final folderId =
      folder['folderId'] as String? ?? folderData['_id'] as String?;
  final folderName =
      folder['title'] as String ?? folderData['name'] ?? S.of(context).folder;

  if (folderId == null) {
    if (scaffoldContext.mounted) {
      ScaffoldMessenger.of(
        scaffoldContext,
      ).showSnackBar(SnackBar(content: Text(S.of(context).folderIdNotFound)));
    }
    return;
  }

  // ✅ جلب معلومات الحماية الحالية من السيرفر (للتأكد من أحدث البيانات)
  final folderController = Provider.of<FolderController>(
    scaffoldContext,
    listen: false,
  );
  
  bool isCurrentlyProtected = false;
  String currentProtectionType = 'none';
  
  // ✅ التحقق من البيانات المحلية أولاً
  isCurrentlyProtected = folderData['isProtected'] == true;
  currentProtectionType = folderData['protectionType']?.toString() ?? 'none';
  
  // ✅ محاولة جلب أحدث البيانات من السيرفر
  try {
    final folderDetails = await folderController.getFolderDetails(
      folderId: folderId,
    );
    
    if (folderDetails != null && folderDetails['folder'] != null) {
      final serverFolderData = folderDetails['folder'] as Map<String, dynamic>;
      final serverIsProtected = serverFolderData['isProtected'] == true;
      final serverProtectionType = serverFolderData['protectionType']?.toString() ?? 'none';
      
      // ✅ استخدام بيانات السيرفر إذا كانت متوفرة
      if (serverIsProtected || serverProtectionType != 'none') {
        isCurrentlyProtected = serverIsProtected;
        currentProtectionType = serverProtectionType;
      }
    }
  } catch (e) {
    // ✅ في حالة الخطأ، نستخدم البيانات المحلية
    print('⚠️ [FilesGridView] Error fetching folder details: $e');
  }
  
  // ✅ طباعة للتحقق من البيانات
  print('🔐 [FilesGridView] Folder protection status:');
  print('   - isCurrentlyProtected: $isCurrentlyProtected');
  print('   - currentProtectionType: $currentProtectionType');

  // ✅ فتح dialog الحماية
  await showSetFolderProtectionDialog(
    scaffoldContext,
    folderId,
    folderName,
    isCurrentlyProtected,
    currentProtectionType,
    onFileRemoved, // ✅ callback لإعادة تحميل البيانات بعد تغيير الحماية
  );
}

void _showDeleteDialog(BuildContext context, Map<String, dynamic> folder) async {
  // ✅ التحقق من كلمة السر إذا كان المجلد محمياً
  final hasAccess = await _verifyProtectedFolderAccess(context, folder);
  if (!hasAccess) {
    return; // ✅ إيقاف العملية إذا لم يتم التحقق
  }

  final folderController = Provider.of<FolderController>(
    context,
    listen: false,
  );
  final folderData = folder['folderData'] ?? folder;

  FolderActionsService.deleteFolder(
    context,
    folderController,
    {
      'name': folder['title'] ?? folderData['name'],
      '_id': folder['folderId'] ?? folderData['_id'],
      'folderData': folderData,
    },
    onLocalUpdate: () {
      // ✅ تحديث القائمة بعد الحذف
      // يمكن إضافة callback هنا لتحديث القائمة في الصفحة الأم
    },
  );
}

/// ✅ تحميل مجلد خاص بالمستخدم
void _downloadFolder(BuildContext context, Map<String, dynamic> folder) {
  FolderActionsService.downloadFolder(context, folder);
}

Widget _buildInfoRow(String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
      ),
      SizedBox(width: 10),
      Expanded(
        child: Text(value, style: TextStyle(color: Colors.black87)),
      ),
    ],
  );
}

class FilesGridView extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool showFileCount;
  final int? crossAxisCount;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final double? childAspectRatio;
  final void Function(Map<String, dynamic>)? onItemTap; // <--- أضفنا
  final void Function(Map<String, dynamic>)?
  onRoomDetailsTap; // ✅ callback لعرض تفاصيل الغرفة
  final void Function(Map<String, dynamic>)?
  onRoomEditTap; // ✅ callback لتعديل الغرفة
  final void Function(Map<String, dynamic>)?
  onFolderCommentTap; // ✅ callback للتعليق على المجلد
  final void Function(Map<String, dynamic>)?
  onRemoveFolderFromRoomTap; // ✅ callback لإزالة المجلد من الغرفة
  final void Function(Map<String, dynamic>)?
  onSaveFolderFromRoomTap; // ✅ callback لحفظ المجلد من الغرفة
  final void Function(Map<String, dynamic>)?
  onDownloadFolderFromRoomTap; // ✅ callback لتحميل المجلد من الغرفة
  final void Function()?
  onFileRemoved; // ✅ callback لإعادة تحميل البيانات بعد نقل ملف
  final String? roomId; // ✅ معرف الغرفة (لتمييز المجلدات المشتركة)

  const FilesGridView({
    Key? key,
    required this.items,
    required this.showFileCount,
    this.crossAxisCount,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio,
    this.onItemTap, // <--- أضفنا
    this.onRoomDetailsTap, // ✅ callback لعرض تفاصيل الغرفة
    this.onRoomEditTap, // ✅ callback لتعديل الغرفة
    this.onFolderCommentTap, // ✅ callback للتعليق على المجلد
    this.onRemoveFolderFromRoomTap, // ✅ callback لإزالة المجلد من الغرفة
    this.onSaveFolderFromRoomTap, // ✅ callback لحفظ المجلد من الغرفة
    this.onDownloadFolderFromRoomTap, // ✅ callback لتحميل المجلد من الغرفة
    this.onFileRemoved, // ✅ callback لإعادة تحميل البيانات بعد نقل ملف
    this.roomId, // ✅ معرف الغرفة
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            crossAxisCount ??
            ResponsiveUtils.getResponsiveValue(
              context,
              mobile: showFileCount ? 3 : 2,
              tablet: showFileCount ? 4 : 4,
              desktop: showFileCount ? 5 : 5,
            ).toInt(),
        mainAxisSpacing:
            mainAxisSpacing ??
            ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 10.0,
              tablet: 14.0,
              desktop: 18.0,
            ),
        crossAxisSpacing:
            crossAxisSpacing ??
            ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 10.0,
              tablet: 14.0,
              desktop: 18.0,
            ),
        childAspectRatio:
            childAspectRatio ??
            ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 0.95,
              tablet: 1.1,
              desktop: 1.2,
            ),
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final type = item['type'] as String?;
        final folderId = type == 'folder'
            ? (item['folderId'] as String? ??
                  item['folderData']?['_id'] as String?)
            : null;

        // ✅ استخدام Consumer للتحقق من حالة isStarred من الـ controller
        if (type == 'folder' && folderId != null) {
          return Consumer<FolderController>(
            builder: (context, folderController, child) {
              // ✅ التحقق من حالة isStarred من البيانات المحلية أولاً، ثم من starredFolders
              final folderData = item['folderData'] as Map<String, dynamic>?;
              var isStarred = folderData?['isStarred'] ?? false;

              // ✅ التحقق من starredFolders إذا لم تكن البيانات محدثة
              final starredFolder = folderController.starredFolders.firstWhere(
                (f) => f['_id'] == folderId,
                orElse: () => {},
              );
              if (starredFolder.isNotEmpty) {
                isStarred =
                    starredFolder['isStarred'] ??
                    true; // ✅ إذا موجود في starredFolders، فهو مفضل
              }

              return GestureDetector(
                onTap: () {
                  if (onItemTap != null) {
                    onItemTap!(item);
                  }
                },
                child: FolderFileCard(
                  title: item['title'] as String,
                  fileCount: (item['fileCount'] is int)
                      ? item['fileCount'] as int
                      : (item['fileCount'] is num)
                      ? (item['fileCount'] as num).toInt()
                      : 0,
                  size: item['size'] as String,
                  showFileCount: showFileCount,
                  color: item['color'] as Color? ?? const Color(0xFF00BFA5),
                  // ✅ تمرير folderData من item - التأكد من أن folderData موجود
                  folderData: item['folderData'] as Map<String, dynamic>? ?? item,
                  isStarred: isStarred,
                  sharedBy: item['sharedBy'] as String?,
                  roomId: (type == 'folder' && roomId != null) ? roomId : null,
                  onOpenTap: (type == 'folder' || type == 'room')
                      ? () {
                          if (onItemTap != null) {
                            onItemTap!(item);
                          }
                        }
                      : null,
                  onInfoTap: (type == 'folder')
                      ? () {
                          _showFolderInfo(context, item, roomId: roomId);
                        }
                      : null,
                  onRenameTap: (type == 'folder' && roomId == null)
                      ? () {
                          _showRenameDialog(context, item);
                        }
                      : (type == 'room' && onRoomEditTap != null)
                      ? () {
                          onRoomEditTap!(item);
                        }
                      : null,
                  onShareTap: (type == 'folder' && roomId == null)
                      ? () {
                          _showShareDialog(context, item);
                        }
                      : null,
                  onDownloadTap: (type == 'folder' && roomId == null)
                      ? () {
                          _downloadFolder(context, item);
                        }
                      : (type == 'folder' && roomId != null && onDownloadFolderFromRoomTap != null)
                      ? () {
                          onDownloadFolderFromRoomTap!(item);
                        }
                      : null,
                  onMoveTap: (type == 'folder' && roomId == null)
                      ? () {
                          _showMoveFolderDialog(context, item, onFileRemoved);
                        }
                      : null,
                  onFavoriteTap: type == 'folder'
                      ? () {
                          _toggleFavorite(
                            context,
                            item,
                            onUpdate: onFileRemoved,
                          );
                        }
                      : null,
                  onProtectTap: (type == 'folder' && roomId == null)
                      ? () {
                          _showProtectFolderDialog(context, item, onFileRemoved);
                        }
                      : null,
                  onDeleteTap: (type == 'folder' && roomId == null)
                      ? () {
                          _showDeleteDialog(context, item);
                        }
                      : null,
                  onCommentTap:
                      (type == 'folder' &&
                          onFolderCommentTap != null &&
                          roomId != null)
                      ? () {
                          onFolderCommentTap!(item);
                        }
                      : null,
                  onRemoveFromRoomTap:
                      (type == 'folder' &&
                          onRemoveFolderFromRoomTap != null &&
                          roomId != null)
                      ? () {
                          onRemoveFolderFromRoomTap!(item);
                        }
                      : null,
                  onSaveTap:
                      (type == 'folder' &&
                          onSaveFolderFromRoomTap != null &&
                          roomId != null)
                      ? () {
                          onSaveFolderFromRoomTap!(item);
                        }
                      : null,
                  onDetailsTap: type == 'room'
                      ? () {
                          if (onRoomDetailsTap != null) {
                            onRoomDetailsTap!(item);
                          }
                        }
                      : null,
                ),
              );
            },
          );
        }

        // ✅ للملفات أو الأنواع الأخرى (بدون Consumer)
        // ✅ للـ categories نضيف callbacks للقائمة "3 نقاط"
        
        // ✅ إذا كان ملف، نضيف قائمة 3 نقاط
        if (type != 'folder' && type != 'category' && type != 'room') {
          // ✅ بناء fileData بشكل صحيح مثل FilesListView
          final fileOriginalData = item['originalData'] ?? item['itemData'] ?? item;
          final fileIdValue = fileOriginalData['_id']?.toString() ?? item['_id']?.toString();
          final isStarredValue = fileIdValue != null
              ? (fileOriginalData['isStarred'] ?? false)
              : false;

          final fileData = {
            'name': item['title'] ?? item['name'] ?? fileOriginalData['name'],
            'url': item['url'] ?? '',
            'type': item['type'] ?? 'file',
            'path': item['path'] ?? fileOriginalData['path'],
            'originalData': fileOriginalData,
          };

          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  // ✅ استخدام FileActionsService.openFile مثل FilesListView
                  FileActionsService.openFile(fileData, onItemTap);
                },
                child: FolderFileCard(
                  title: item['title'] as String,
                  fileCount: 0,
                  size: item['size'] as String,
                  showFileCount: false,
                  color: item['color'] as Color? ?? const Color(0xFF00BFA5),
                  folderData: null,
                  isStarred: false,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: Colors.grey[700],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  itemBuilder: (context) {
                    return roomId != null
                        ? _buildSharedFileMenuItems(context, item, isStarredValue)
                        : _buildNormalFileMenuItems(context, item, isStarredValue);
                  },
                  onSelected: (value) {
                    if (roomId != null) {
                      _handleSharedFileMenuAction(context, value, item, roomId: roomId);
                    } else {
                      _handleNormalFileMenuAction(context, value, item, onFileRemoved);
                    }
                  },
                ),
              ),
            ],
          );
        }

        return GestureDetector(
          onTap: () {
            if (onItemTap != null) {
              onItemTap!(item);
            }
          },
          child: FolderFileCard(
            title: item['title'] as String,
            fileCount: (item['fileCount'] is int)
                ? item['fileCount'] as int
                : (item['fileCount'] is num)
                ? (item['fileCount'] as num).toInt()
                : 0,
            size: item['size'] as String,
            showFileCount: showFileCount,
            color: item['color'] as Color? ?? const Color(0xFF00BFA5),
            folderData:
                (type == 'folder' || type == 'category' || type == 'room')
                ? item
                : null,
            isStarred: type == 'folder'
                ? (item['folderData']?['isStarred'] ?? false)
                : false,
            sharedBy: item['sharedBy'] as String?,
            roomId: (type == 'folder' && roomId != null) ? roomId : null,
            // ✅ للـ categories: فتح وعرض التفاصيل
            onOpenTap: type == 'category'
                ? () {
                    if (onItemTap != null) {
                      onItemTap!(item);
                    }
                  }
                : (type == 'folder' || type == 'room')
                ? () {
                    if (onItemTap != null) {
                      onItemTap!(item);
                    }
                  }
                : null,
            onInfoTap: type == 'category'
                ? () {
                    _showCategoryDetails(context, item);
                  }
                : (type == 'folder')
                ? () {
                    _showFolderInfo(context, item, roomId: roomId);
                  }
                : null,
            onRenameTap: (type == 'folder' && roomId == null)
                ? () {
                    _showRenameDialog(context, item);
                  }
                : (type == 'room' && onRoomEditTap != null)
                ? () {
                    onRoomEditTap!(item);
                  }
                : null,
            onShareTap: (type == 'folder' && roomId == null)
                ? () {
                    _showShareDialog(context, item);
                  }
                : null,
            onDownloadTap: (type == 'folder')
                ? () {
                    if (roomId != null && onDownloadFolderFromRoomTap != null) {
                      onDownloadFolderFromRoomTap!(item);
                    } else if (roomId == null) {
                      _downloadFolder(context, item);
                    }
                  }
                : null,
            onMoveTap: (type == 'folder' && roomId == null)
                ? () {
                    _showMoveFolderDialog(context, item, onFileRemoved);
                  }
                : null,
            onFavoriteTap: type == 'folder'
                ? () {
                    _toggleFavorite(context, item, onUpdate: onFileRemoved);
                  }
                : null,
            onProtectTap: (type == 'folder' && roomId == null)
                ? () {
                    _showProtectFolderDialog(context, item, onFileRemoved);
                  }
                : null,
            onDeleteTap: (type == 'folder' && roomId == null)
                ? () {
                    _showDeleteDialog(context, item);
                  }
                : null,
            onCommentTap:
                (type == 'folder' &&
                    onFolderCommentTap != null &&
                    roomId != null)
                ? () {
                    onFolderCommentTap!(item);
                  }
                : null,
            onRemoveFromRoomTap:
                (type == 'folder' &&
                    onRemoveFolderFromRoomTap != null &&
                    roomId != null)
                ? () {
                    onRemoveFolderFromRoomTap!(item);
                  }
                : null,
            onSaveTap:
                (type == 'folder' &&
                    onSaveFolderFromRoomTap != null &&
                    roomId != null)
                ? () {
                    onSaveFolderFromRoomTap!(item);
                  }
                : null,
            onDetailsTap: type == 'room'
                ? () {
                    if (onRoomDetailsTap != null) {
                      onRoomDetailsTap!(item);
                    }
                  }
                : null,
          ),
        );
      },
    );
  }
}

// ✅ Widget للتنقل داخل المجلدات عند النقل - نفس folder_contents_page.dart
// ==================== FILE MENU ITEMS ====================

List<PopupMenuEntry<String>> _buildSharedFileMenuItems(
  BuildContext context,
  Map<String, dynamic> item,
  bool isStarred,
) {
  return [
    PopupMenuItem<String>(
      value: 'open',
      child: Row(
        children: [
          const Icon(Icons.open_in_new_rounded, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Text(S.of(context).open),
        ],
      ),
    ),
    PopupMenuItem<String>(
      value: 'info',
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.teal, size: 20),
          const SizedBox(width: 8),
          Text(S.of(context).viewDetails),
        ],
      ),
    ),
    PopupMenuItem<String>(
      value: 'download',
      child: Row(
        children: [
          const Icon(Icons.download_rounded, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Text(S.of(context).download),
        ],
      ),
    ),
    PopupMenuItem<String>(
      value: 'comments',
      child: Row(
        children: [
          const Icon(Icons.comment_rounded, color: Color(0xFFF59E0B), size: 20),
          const SizedBox(width: 8),
          Text(S.of(context).comments),
        ],
      ),
    ),
    const PopupMenuDivider(),
    PopupMenuItem<String>(
      value: 'favorite',
      child: Row(
        children: [
          Icon(
            isStarred ? Icons.star_rounded : Icons.star_border_rounded,
            color: Colors.amber[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isStarred
                ? S.of(context).removeFromFavorites
                : S.of(context).addToFavorites,
          ),
        ],
      ),
    ),
    PopupMenuItem<String>(
      value: 'save',
      child: Row(
        children: [
          const Icon(Icons.save_rounded, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Text(S.of(context).saveToMyAccount),
        ],
      ),
    ),
    const PopupMenuDivider(),
    PopupMenuItem<String>(
      value: 'remove_from_room',
      child: Row(
        children: [
          const Icon(Icons.link_off_rounded, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Text(
            S.of(context).removeFromRoom,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    ),
  ];
}

List<PopupMenuEntry<String>> _buildNormalFileMenuItems(
  BuildContext context,
  Map<String, dynamic> item,
  bool isStarred,
) {
  return [
    PopupMenuItem<String>(
      value: 'open',
      child: Row(
        children: [
          const Icon(Icons.open_in_new_rounded, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Text(S.of(context).open),
        ],
      ),
    ),
    PopupMenuItem<String>(
      value: 'info',
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.teal, size: 20),
          const SizedBox(width: 8),
          Text(S.of(context).viewInfo),
        ],
      ),
    ),
    PopupMenuItem<String>(
      value: 'download',
      child: Row(
        children: [
          const Icon(Icons.download_rounded, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Text(S.of(context).download),
        ],
      ),
    ),
    PopupMenuItem<String>(
      value: 'edit',
      child: Row(
        children: [
          const Icon(Icons.edit_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Text(S.of(context).edit),
        ],
      ),
    ),
    PopupMenuItem<String>(
      value: 'share',
      child: Row(
        children: [
          const Icon(Icons.share_rounded, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Text(S.of(context).share),
        ],
      ),
    ),
    PopupMenuItem<String>(
      value: 'move',
      child: Row(
        children: [
          const Icon(Icons.drive_file_move_rounded, color: Colors.purple, size: 20),
          const SizedBox(width: 8),
          Text(S.of(context).move),
        ],
      ),
    ),
    PopupMenuItem<String>(
      value: 'favorite',
      child: Row(
        children: [
          Icon(
            isStarred ? Icons.star_rounded : Icons.star_border_rounded,
            color: Colors.amber[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isStarred
                ? S.of(context).removeFromFavorites
                : S.of(context).addToFavorites,
          ),
        ],
      ),
    ),
    const PopupMenuDivider(),
    PopupMenuItem<String>(
      value: 'delete',
      child: Row(
        children: [
          const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Text(
            S.of(context).delete,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    ),
  ];
}

void _handleSharedFileMenuAction(
  BuildContext context,
  String action,
  Map<String, dynamic> item, {
  String? roomId,
}) {
  final originalData = item['originalData'] ?? item['itemData'] ?? {};
  final fileId = originalData['_id']?.toString();
  final fileData = {
    'name': item['title'] ?? item['name'],
    'url': item['url'] ?? '',
    'type': item['type'] ?? 'file',
    'originalData': originalData,
  };

  switch (action) {
    case 'open':
      FileActionsService.openFile(fileData, null);
      break;
    case 'info':
      if (fileId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FileDetailsPage(fileId: fileId, roomId: roomId),
          ),
        );
      }
      break;
    case 'download':
      FileActionsService.downloadFile(context, fileData);
      break;
    case 'comments':
      // TODO: Implement comments for files in rooms
      break;
    case 'favorite':
      final fileController = Provider.of<FileController>(
        context,
        listen: false,
      );
      FileActionsService.toggleStar(
        context,
        fileController,
        fileData,
      );
      break;
    case 'save':
      // TODO: Implement save file from room
      break;
    case 'remove_from_room':
      if (fileId != null && roomId != null) {
        final roomController = Provider.of<RoomController>(
          context,
          listen: false,
        );
        
        // عرض ديالوج التأكيد
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(S.of(context).removeFromRoom),
            content: Text(
              S.of(context).removeFileFromRoomConfirm(item['title'] ?? S.of(context).file),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(S.of(context).cancel),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  
                  // محاولة جلب بيانات الغرفة للتحقق من المشاركة المباشرة
                  final response = await roomController.getRoomById(roomId);
                  final roomData = response?['room'];
                  
                  bool isDirectlyShared = false;
                  if (roomData != null && roomData['files'] != null) {
                    final roomFiles = roomData['files'] as List;
                    isDirectlyShared = roomFiles.any((f) {
                      final fId = f['file'] is Map ? f['file']['_id'] : f['file'];
                      return fId.toString() == fileId.toString();
                    });
                  }

                  if (!isDirectlyShared) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '⚠️ ${S.of(context).cannotRemoveSubItemFromRoom}',
                          ),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                    }
                    return;
                  }

                  final success = await roomController.unshareFileFromRoom(
                    roomId: roomId,
                    fileId: fileId,
                  );

                  if (context.mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ ${S.of(context).fileRemovedFromRoom}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // إعادة تحميل البيانات
                      // في هذا الكومبوننت لا نملك callback مباشر لتحديث الصفحة الأم بسهولة 
                      // لكن notifyListeners في الكنترولر سيقوم بالمهمة إذا كانت الصفحة تستمع له
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            roomController.errorMessage ??
                                '❌ ${S.of(context).failedToRemoveFile}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  S.of(context).remove,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      }
      break;
  }
}

void _handleNormalFileMenuAction(
  BuildContext context,
  String action,
  Map<String, dynamic> item,
  void Function()? onFileRemoved,
) {
  // ✅ الحصول على originalData من جميع الأماكن المحتملة
  final originalData = item['originalData'] ?? item['itemData'] ?? item;
  
  // ✅ الحصول على path من جميع الأماكن المحتملة
  final path = item['path'] ?? 
      originalData['path'] ?? 
      item['filePath'] ?? 
      originalData['filePath'];
  
  // ✅ الحصول على _id من جميع الأماكن المحتملة
  final fileId = originalData['_id'] ?? 
      item['_id'] ?? 
      originalData['id'] ?? 
      item['id'];
  
  final fileData = {
    'name': item['title'] ?? item['name'] ?? originalData['name'],
    'url': item['url'] ?? '',
    'type': item['type'] ?? 'file',
    'path': path,
    '_id': fileId?.toString(),
    'originalData': originalData,
  };

  switch (action) {
    case 'open':
      FileActionsService.openFile(fileData, null);
      break;
    case 'info':
      final fileId = originalData['_id']?.toString();
      if (fileId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FileDetailsPage(fileId: fileId)),
        );
      }
      break;
    case 'download':
      FileActionsService.downloadFile(context, fileData);
      break;
    case 'edit':
      FileActionsService.editFile(context, fileData).then((updated) {
        // ✅ إذا تم تحديث الملف، استدعي callback لإعادة تحميل البيانات
        print('🔄 [FilesGridView] Edit file result: $updated');
        print('🔄 [FilesGridView] onFileRemoved is null: ${onFileRemoved == null}');
        if (updated == true) {
          print('✅ [FilesGridView] File updated, calling onFileRemoved callback');
          if (onFileRemoved != null) {
            onFileRemoved();
          } else {
            print('⚠️ [FilesGridView] onFileRemoved is null, cannot refresh');
          }
        } else {
          print('❌ [FilesGridView] File not updated, skipping refresh');
        }
      }).catchError((error) {
        print('❌ [FilesGridView] Error in editFile: $error');
      });
      break;
    case 'share':
      FileActionsService.shareFile(context, fileData);
      break;
    case 'move':
      // TODO: Implement move file
      break;
    case 'favorite':
      final fileController = Provider.of<FileController>(
        context,
        listen: false,
      );
      FileActionsService.toggleStar(
        context,
        fileController,
        fileData,
      );
      break;
    case 'delete':
      final fileController = Provider.of<FileController>(
        context,
        listen: false,
      );
      // ✅ تمرير callback لإعادة تحميل الصفحة بعد الحذف
      FileActionsService.deleteFile(
        context,
        fileController,
        fileData,
        onLocalUpdate: () {
          // ✅ استدعاء onFileRemoved إذا كان موجوداً لإعادة تحميل الصفحة
          if (onFileRemoved != null) {
            onFileRemoved!();
          }
        },
      );
      break;
  }
}

class _FolderNavigationDialog extends StatefulWidget {
  final String title;
  final String? excludeFolderId;
  final String? excludeParentId;
  final Function(String?) onSelect;

  const _FolderNavigationDialog({
    required this.title,
    this.excludeFolderId,
    this.excludeParentId,
    required this.onSelect,
  });

  @override
  State<_FolderNavigationDialog> createState() =>
      _FolderNavigationDialogState();
}

class _FolderNavigationDialogState extends State<_FolderNavigationDialog> {
  List<Map<String, dynamic>> _currentFolders = [];
  List<Map<String, String?>> _breadcrumb = []; // [{id: null, name: 'الجذر'}]
  bool _isLoading = false;
  String? _currentFolderId;
  bool _initializedBreadcrumb = false;

  @override
  void initState() {
    super.initState();
    // ✅ تأخير تحميل المجلدات حتى يكون الـ context جاهزاً
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadRootFolders();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ هنا مسموح نستخدم S.of(context) لأنه بعد initState وتم تهيئة Localizations
    if (!_initializedBreadcrumb) {
      _breadcrumb.add({'id': null, 'name': S.of(context).root});
      _initializedBreadcrumb = true;
    }
  }

  // ✅ جلب المجلدات الجذرية
  Future<void> _loadRootFolders() async {
    setState(() {
      _isLoading = true;
      _currentFolderId = null;
    });

    try {
      final folderController = Provider.of<FolderController>(
        context,
        listen: false,
      );
      final response = await folderController.getAllFolders(
        page: 1,
        limit: 100,
      );

      if (response != null && response['folders'] != null) {
        final folders = List<Map<String, dynamic>>.from(
          response['folders'] ?? [],
        );

        // ✅ تصفية المجلدات المستبعدة
        final filteredFolders = folders.where((f) {
          final fId = f['_id']?.toString();
          return fId != widget.excludeFolderId && fId != widget.excludeParentId;
        }).toList();

        setState(() {
          _currentFolders = filteredFolders;
          _isLoading = false;
        });
      } else {
        setState(() {
          _currentFolders = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading root folders: $e');
      setState(() {
        _currentFolders = [];
        _isLoading = false;
      });
    }
  }

  // ✅ جلب المجلدات الفرعية لمجلد معين
  Future<void> _loadSubfolders(String folderId, String folderName) async {
    setState(() {
      _isLoading = true;
      _currentFolderId = folderId;
    });

    // ✅ إضافة المجلد إلى breadcrumb
    setState(() {
      _breadcrumb.add({'id': folderId, 'name': folderName});
    });

    try {
      final folderController = Provider.of<FolderController>(
        context,
        listen: false,
      );

      // ✅ جلب جميع المجلدات الفرعية (limit كبير لضمان جلب جميع المجلدات)
      final response = await folderController.getFolderContents(
        folderId: folderId,
        page: 1,
        limit: 1000, // ✅ limit كبير لضمان جلب جميع المجلدات الفرعية
      );

      print('📁 Response for folder $folderId: ${response?.keys}');
      print('📁 Full response: $response');

      // ✅ محاولة جلب المجلدات الفرعية من response
      List<Map<String, dynamic>> subfolders = [];

      if (response != null) {
        // ✅ محاولة من subfolders مباشرة (الأولوية) - هذا يحتوي على جميع المجلدات الفرعية
        if (response['subfolders'] != null) {
          subfolders = List<Map<String, dynamic>>.from(
            response['subfolders'] ?? [],
          );
          print(
            '📁 Found ${subfolders.length} subfolders from subfolders field',
          );
        }
        // ✅ إذا لم تكن موجودة، جرب من contents (لكن هذا قد يكون محدود بـ pagination)
        if (subfolders.isEmpty && response['contents'] != null) {
          final contents = List<Map<String, dynamic>>.from(
            response['contents'] ?? [],
          );
          subfolders = contents
              .where((item) => item['type'] == 'folder')
              .toList();
          print('📁 Found ${subfolders.length} subfolders from contents field');
        }

        // ✅ إذا لم نجد أي مجلدات، جرب من folders مباشرة (fallback)
        if (subfolders.isEmpty && response['folders'] != null) {
          subfolders = List<Map<String, dynamic>>.from(
            response['folders'] ?? [],
          );
          print(
            '📁 Found ${subfolders.length} subfolders from folders field (fallback)',
          );
        }
      }

      print(
        '📁 Total found: ${subfolders.length} subfolders for folder $folderId ($folderName)',
      );

      // ✅ تصفية المجلدات المستبعدة
      final filteredFolders = subfolders.where((f) {
        final fId = f['_id']?.toString();
        return fId != widget.excludeFolderId && fId != widget.excludeParentId;
      }).toList();

      setState(() {
        _currentFolders = filteredFolders;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading subfolders: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      setState(() {
        _currentFolders = [];
        _isLoading = false;
      });

      // ✅ إظهار رسالة خطأ للمستخدم
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).subfoldersFetchError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ✅ العودة إلى مجلد سابق
  void _navigateToFolder(String? folderId) {
    if (folderId == null) {
      // ✅ العودة للجذر
      setState(() {
        _breadcrumb = [
          {'id': null, 'name': S.of(context).root},
        ];
      });
      _loadRootFolders();
    } else {
      // ✅ العودة لمجلد معين
      final index = _breadcrumb.indexWhere((b) => b['id'] == folderId);
      if (index >= 0) {
        setState(() {
          _breadcrumb = _breadcrumb.sublist(0, index + 1);
        });

        if (folderId == null) {
          _loadRootFolders();
        } else {
          final folderName = _breadcrumb.last['name'] ?? S.of(context).folder;
          _loadSubfolders(folderId, folderName);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final s = S.of(context);
    final folderName = _breadcrumb.last['name'] ?? s.folder;
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.getCardColor(isDarkMode),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ✅ Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.getPrimary(isDarkMode),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.drive_file_move_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // ✅ Breadcrumb
          if (_breadcrumb.length > 1)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDarkMode 
                  ? AppColors.darkSurface 
                  : Colors.grey[100],
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _breadcrumb.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final isLast = index == _breadcrumb.length - 1;

                          return GestureDetector(
                            onTap: isLast
                                ? null
                                : () => _navigateToFolder(item['id']),
                            child: Row(
                              children: [
                                if (index > 0) ...[
                                  Icon(
                                    Icons.chevron_left,
                                    size: 16,
                                    color: AppColors.getTextSecondary(isDarkMode),
                                  ),
                                  SizedBox(width: 4),
                                ],
                                Text(
                                  item['name'] ?? S.of(context).root,
                                  style: TextStyle(
                                    color: isLast 
                                        ? AppColors.getPrimary(isDarkMode) 
                                        : AppColors.getPrimary(isDarkMode).withOpacity(0.8),
                                    fontWeight: isLast
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    decoration: isLast
                                        ? null
                                        : TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ✅ Content
          Expanded(
            child: Column(
              children: [
                // ✅ خيار "اختيار الجذر" (إذا كنا في الجذر)
                if (_currentFolderId == null)
                  ListTile(
                    tileColor: AppColors.getCardColor(isDarkMode),
                    leading: Icon(
                      Icons.home_rounded, 
                      color: AppColors.getPrimary(isDarkMode),
                    ),
                    title: Text(
                      S.of(context).moveToRoot,
                      style: TextStyle(
                        color: AppColors.getTextPrimary(isDarkMode),
                      ),
                    ),
                    subtitle: Text(
                      S.of(context).moveFolderToRoot,
                      style: TextStyle(
                        color: AppColors.getTextSecondary(isDarkMode),
                      ),
                    ),
                    onTap: () => widget.onSelect(null),
                  ),
                // ✅ خيار "اختيار المجلد الحالي" (إذا كنا داخل مجلد)
                if (_currentFolderId != null)
                  ListTile(
                    tileColor: AppColors.getCardColor(isDarkMode),
                    leading: Icon(
                      Icons.check_circle, 
                      color: AppColors.success,
                    ),
                    title: Text(
                      s.selectFolderNamed(folderName),
                      style: TextStyle(
                        color: AppColors.getTextPrimary(isDarkMode),
                      ),
                    ),
                    subtitle: Text(
                      S.of(context).moveToThisFolder,
                      style: TextStyle(
                        color: AppColors.getTextSecondary(isDarkMode),
                      ),
                    ),
                    onTap: () => widget.onSelect(_currentFolderId),
                  ),
                // ✅ Divider بين الخيارات وقائمة المجلدات
                Divider(
                  color: isDarkMode 
                      ? AppColors.darkSurface 
                      : Colors.grey[300],
                ),

                // ✅ قائمة المجلدات
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.getPrimary(
                                Theme.of(context).brightness == Brightness.dark,
                              ),
                            ),
                          ),
                        )
                      : _currentFolders.isEmpty
                      ? Center(
                          child: Text(
                            _currentFolderId == null
                                ? S.of(context).noFoldersAvailable
                                : S.of(context).noSubfoldersAvailable,
                            style: TextStyle(
                              color: AppColors.getTextSecondary(isDarkMode),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _currentFolders.length,
                          itemBuilder: (context, index) {
                            final folder = _currentFolders[index];
                            final folderId = folder['_id']?.toString();
                            final folderName =
                                folder['name'] ?? S.of(context).unnamedFolder;

                            return InkWell(
                              onTap: () {
                                // ✅ فتح المجلد لعرض المجلدات الفرعية
                                if (folderId != null) {
                                  print(
                                    '📂 Opening folder: $folderId ($folderName)',
                                  );
                                  _loadSubfolders(folderId, folderName);
                                } else {
                                  print(
                                    '⚠️ Folder ID is null for folder: $folderName',
                                  );
                                }
                              },
                              child: Container(
                                color: AppColors.getCardColor(isDarkMode),
                                child: ListTile(
                                  tileColor: AppColors.getCardColor(isDarkMode),
                                  leading: Icon(
                                    Icons.folder_rounded,
                                    color: AppColors.warning,
                                  ),
                                  title: Text(
                                    folderName,
                                    style: TextStyle(
                                      color: AppColors.getTextPrimary(isDarkMode),
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${folder['filesCount'] ?? 0}${S.of(context).file}',
                                    style: TextStyle(
                                      color: AppColors.getTextSecondary(isDarkMode),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // ✅ زر اختيار المجلد (checkmark)
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            // ✅ اختيار المجلد مباشرة
                                            widget.onSelect(folderId);
                                          },
                                          borderRadius: BorderRadius.circular(20),
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            child: Icon(
                                              Icons.check_circle_outline,
                                              color: AppColors.success,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      // ✅ أيقونة chevron للإشارة إلى إمكانية فتح المجلد
                                      Icon(
                                        Icons.chevron_right,
                                        color: AppColors.getTextSecondary(isDarkMode),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
