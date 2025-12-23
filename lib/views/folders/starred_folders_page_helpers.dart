import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/views/folders/share_folder_with_room_page.dart';
import 'package:filevo/views/fileViewer/folder_actions_service.dart';

// ✅ Helper functions للتعامل مع إجراءات المجلدات المفضلة

String _formatBytesHelper(int bytes) {
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

String _formatDateHelper(dynamic date) {
  if (date == null) return "—";
  try {
    final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  } catch (e) {
    return "—";
  }
}

Widget _buildDetailItemHelper(
  String type,
  String emoji,
  String label,
  String value,
) {
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
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[200]!),
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
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
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

Future<void> showFolderInfoHelper(
  BuildContext context,
  Map<String, dynamic> folder,
) async {
  final folderId = folder['folderId'] as String?;
  final folderName = folder['title'] as String;
  final folderColor = folder['color'] as Color? ?? Colors.blue;

  if (folderId == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('خطأ: معرف المجلد غير موجود')));
    return;
  }

  final folderController = Provider.of<FolderController>(
    context,
    listen: false,
  );
  final folderDetails = await folderController.getFolderDetails(
    folderId: folderId,
  );

  if (folderDetails == null || folderDetails['folder'] == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل جلب معلومات المجلد')));
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
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
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
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItemHelper('folder', '📁', 'النوع', 'مجلد'),
                  _buildDetailItemHelper(
                    'size',
                    '💾',
                    'الحجم',
                    _formatBytesHelper(folderData['size'] ?? 0),
                  ),
                  _buildDetailItemHelper(
                    'files',
                    '📄',
                    'عدد الملفات',
                    '${folderData['filesCount'] ?? 0}',
                  ),
                  _buildDetailItemHelper(
                    'subfolders',
                    '📂',
                    'عدد المجلدات الفرعية',
                    '${folderData['subfoldersCount'] ?? 0}',
                  ),
                  _buildDetailItemHelper(
                    'time',
                    '🕐',
                    'تاريخ الإنشاء',
                    _formatDateHelper(folderData['createdAt']),
                  ),
                  _buildDetailItemHelper(
                    'edit',
                    '✏️',
                    'آخر تعديل',
                    _formatDateHelper(folderData['updatedAt']),
                  ),
                  _buildDetailItemHelper(
                    'description',
                    '📝',
                    'الوصف',
                    folderData['description']?.isNotEmpty == true
                        ? folderData['description']
                        : "—",
                  ),
                  _buildDetailItemHelper(
                    'tags',
                    '🏷️',
                    'الوسوم',
                    (folderData['tags'] as List?)?.join(', ') ?? "—",
                  ),
                  if (folderData['sharedWith'] != null &&
                      (folderData['sharedWith'] as List).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        _buildDetailItemHelper(
                          'share',
                          '👥',
                          'تمت المشاركة مع',
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

Future<void> showRenameDialogHelper(
  BuildContext context,
  Map<String, dynamic> folder,
  VoidCallback? onUpdated,
) async {
  final folderName = folder['title'] as String;
  final folderId = folder['folderId'] as String?;
  final folderData = folder['folderData'] as Map<String, dynamic>?;

  final nameController = TextEditingController(text: folderName);
  final descriptionController = TextEditingController(
    text: folderData?['description'] as String? ?? '',
  );
  final tagsController = TextEditingController(
    text: (folderData?['tags'] as List?)?.join(', ') ?? '',
  );

  if (folderId == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('خطأ: معرف المجلد غير موجود')));
    return;
  }

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('تعديل المجلد'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'اسم المجلد',
                hintText: 'اسم المجلد',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.folder),
              ),
              autofocus: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'الوصف',
                hintText: 'وصف المجلد (اختياري)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextField(
              controller: tagsController,
              decoration: InputDecoration(
                labelText: 'الوسوم',
                hintText: 'وسوم مفصولة بفواصل (اختياري)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text('إلغاء'),
        ),
        TextButton(
          onPressed: () {
            final newName = nameController.text.trim();
            if (newName.isEmpty) {
              ScaffoldMessenger.of(
                dialogContext,
              ).showSnackBar(SnackBar(content: Text('يرجى إدخال اسم المجلد')));
              return;
            }
            Navigator.pop(dialogContext, true);
          },
          child: Text('حفظ'),
        ),
      ],
    ),
  );

  if (result == true) {
    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );
    final newName = nameController.text.trim();
    final description = descriptionController.text.trim();
    final tagsString = tagsController.text.trim();
    final tags = tagsString.isNotEmpty
        ? tagsString
              .split(',')
              .map((t) => t.trim())
              .where((t) => t.isNotEmpty)
              .toList()
        : <String>[];

    final success = await folderController.updateFolder(
      folderId: folderId,
      name: newName,
      description: description.isEmpty ? null : description,
      tags: tags.isEmpty ? null : tags,
    );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم تحديث المجلد بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        onUpdated?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              folderController.errorMessage ?? '❌ فشل تحديث المجلد',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

Future<void> showShareDialogHelper(
  BuildContext context,
  Map<String, dynamic> folder,
) async {
  final folderId = folder['folderId'] as String?;
  final folderName = folder['title'] as String;

  if (folderId == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('خطأ: معرف المجلد غير موجود')));
    return;
  }

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          ShareFolderWithRoomPage(folderId: folderId, folderName: folderName),
    ),
  );
}

void showDeleteDialogHelper(
  BuildContext context,
  Map<String, dynamic> folder,
  VoidCallback? onDeleted,
) {
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
      onDeleted?.call();
    },
  );
}

Future<void> showMoveFolderDialogHelper(
  BuildContext context,
  Map<String, dynamic> folder, {
  VoidCallback? onUpdated,
}) async {
  final folderData = folder['folderData'] as Map<String, dynamic>? ?? {};
  final folderId =
      folder['folderId'] as String? ?? folderData['_id'] as String?;
  final folderName = folder['title'] as String ?? folderData['name'] ?? 'مجلد';
  final currentParentId = folderData['parentId']?.toString();

  if (folderId == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('خطأ: معرف المجلد غير موجود')));
    return;
  }

  // ✅ جلب قائمة المجلدات
  final folderController = Provider.of<FolderController>(
    context,
    listen: false,
  );
  final foldersResponse = await folderController.getAllFolders(
    page: 1,
    limit: 100,
  );

  if (foldersResponse == null || foldersResponse['folders'] == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('فشل جلب قائمة المجلدات')));
    return;
  }

  final folders = List<Map<String, dynamic>>.from(
    foldersResponse['folders'] ?? [],
  );

  // ✅ تصفية المجلد الحالي والمجلدات الفرعية (لتجنب الحلقات)
  final availableFolders = folders.where((f) {
    final fId = f['_id']?.toString();
    return fId != folderId && fId != currentParentId;
  }).toList();

  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ✅ Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple,
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
                    'نقل المجلد: $folderName',
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

          // ✅ Content
          Expanded(
            child: Column(
              children: [
                // ✅ خيار "الجذر"
                ListTile(
                  leading: Icon(Icons.home_rounded, color: Colors.blue),
                  title: Text('الجذر'),
                  subtitle: Text('نقل المجلد للجذر (بدون مجلد أب)'),
                  onTap: () {
                    Navigator.pop(context);
                    _moveFolderHelper(
                      context,
                      folderId,
                      null,
                      folderName,
                      onUpdated: onUpdated,
                    );
                  },
                ),
                Divider(),

                // ✅ قائمة المجلدات
                Expanded(
                  child: availableFolders.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد مجلدات متاحة',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: availableFolders.length,
                          itemBuilder: (context, index) {
                            final f = availableFolders[index];
                            final fId = f['_id']?.toString();
                            final fName = f['name'] ?? 'مجلد بدون اسم';

                            return ListTile(
                              leading: Icon(
                                Icons.folder_rounded,
                                color: Colors.orange,
                              ),
                              title: Text(fName),
                              subtitle: Text('${f['filesCount'] ?? 0} ملف'),
                              onTap: () {
                                Navigator.pop(context);
                                _moveFolderHelper(
                                  context,
                                  folderId,
                                  fId,
                                  folderName,
                                  onUpdated: onUpdated,
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// ✅ دالة مساعدة لنقل المجلد
Future<void> _moveFolderHelper(
  BuildContext context,
  String folderId,
  String? targetFolderId,
  String folderName, {
  VoidCallback? onUpdated,
}) async {
  final folderController = Provider.of<FolderController>(
    context,
    listen: false,
  );

  // ✅ إظهار مؤشر تحميل محسّن
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              targetFolderId == null
                  ? 'جاري نقل المجلد للجذر...'
                  : 'جاري نقل المجلد...',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
      duration: Duration(seconds: 120), // ✅ زيادة المدة للمجلدات الكبيرة
      backgroundColor: Colors.blue[700],
    ),
  );

  // ✅ نقل المجلد مع معالجة الأخطاء
  bool success = false;
  try {
    success = await folderController.moveFolder(
      folderId: folderId,
      targetFolderId: targetFolderId,
    );
  } catch (e) {
    // ✅ معالجة timeout أو أخطاء أخرى
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('timeout') || e.toString().contains('مهلة')
                ? 'انتهت مهلة الطلب. قد يكون المجلد كبيراً جداً. يرجى المحاولة مرة أخرى.'
                : 'حدث خطأ أثناء نقل المجلد: ${e.toString()}',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
    }
    return;
  }

  if (context.mounted) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم نقل المجلد بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      // ✅ استدعاء callback لإعادة تحميل البيانات بعد النقل الناجح
      if (onUpdated != null) {
        onUpdated();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(folderController.errorMessage ?? '❌ فشل نقل المجلد'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
