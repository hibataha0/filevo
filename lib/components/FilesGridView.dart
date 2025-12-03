import 'package:filevo/components/FolderFileCard.dart';
import 'package:filevo/responsive.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/views/folders/share_folder_with_room_page.dart';
import 'package:filevo/views/fileViewer/folder_actions_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

// ✅ Helper functions للتعامل مع إجراءات المجلد
void _showFolderInfo(BuildContext context, Map<String, dynamic> folder) async {
  final folderId = folder['folderId'] as String?;
  final folderName = folder['title'] as String;
  final folderColor = folder['color'] as Color? ?? Colors.blue;
  
  if (folderId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('خطأ: معرف المجلد غير موجود')),
    );
    return;
  }

  // ✅ جلب تفاصيل المجلد من الباك إند
  final folderController = Provider.of<FolderController>(context, listen: false);
  final folderDetails = await folderController.getFolderDetails(folderId: folderId);
  
  if (folderDetails == null || folderDetails['folder'] == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل جلب معلومات المجلد')),
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
        color: Colors.white,
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
                  _buildDetailItem('folder', '📁', 'النوع', 'مجلد'),
                  _buildDetailItem('size', '💾', 'الحجم', _formatBytes(folderData['size'] ?? 0)),
                  _buildDetailItem('files', '📄', 'عدد الملفات', '${folderData['filesCount'] ?? 0}'),
                  _buildDetailItem('subfolders', '📂', 'عدد المجلدات الفرعية', '${folderData['subfoldersCount'] ?? 0}'),
                  _buildDetailItem('time', '🕐', 'تاريخ الإنشاء', _formatDate(folderData['createdAt'])),
                  _buildDetailItem('edit', '✏️', 'آخر تعديل', _formatDate(folderData['updatedAt'])),
                  _buildDetailItem('description', '📝', 'الوصف', 
                      folderData['description']?.isNotEmpty == true ? folderData['description'] : "—"),
                  _buildDetailItem('tags', '🏷️', 'الوسوم', 
                      (folderData['tags'] as List?)?.join(', ') ?? "—"),
                  
                  // ✅ Shared With Section
                  if (folderData['sharedWith'] != null && (folderData['sharedWith'] as List).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        _buildDetailItem(
                          'share',
                          '👥',
                          'تمت المشاركة مع',
                          (folderData['sharedWith'] as List)
                              .map<String>((u) => u['user']?['email']?.toString() ?? u['email']?.toString() ?? '')
                              .where((email) => email.isNotEmpty)
                              .join(', ') ?? "—",
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

Widget _buildDetailItem(String type, String emoji, String label, String value) {
  Color getIconColor() {
    switch (type) {
      case 'folder': return Color(0xFF10B981);
      case 'size': return Color(0xFFF59E0B);
      case 'files': return Color(0xFF3B82F6);
      case 'subfolders': return Color(0xFF8B5CF6);
      case 'time': return Color(0xFFEF4444);
      case 'edit': return Color(0xFF8B5CF6);
      case 'description': return Color(0xFF4F6BED);
      case 'tags': return Color(0xFFEC4899);
      case 'share': return Color(0xFF06B6D4);
      default: return Color(0xFF6B7280);
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

// ✅ دالة لعرض تفاصيل التصنيف (Category)
void _showCategoryDetails(BuildContext context, Map<String, dynamic> category) {
  final categoryTitle = category['title'] as String? ?? 'تصنيف';
  final fileCount = category['fileCount'] as int? ?? 0;
  final size = category['size'] as String? ?? '0';
  final color = category['color'] as Color? ?? Colors.blue;
  final icon = category['icon'] as IconData? ?? Icons.folder;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.5,
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
                  _buildDetailItem('folder', '📁', 'النوع', 'تصنيف'),
                  _buildDetailItem('files', '📄', 'عدد الملفات', '$fileCount'),
                  _buildDetailItem('size', '💾', 'الحجم الإجمالي', size),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _showRenameDialog(BuildContext context, Map<String, dynamic> folder) {
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
  
  final scaffoldContext = context; // ✅ حفظ context الأصلي
  
  if (folderId == null) {
    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      SnackBar(content: Text('خطأ: معرف المجلد غير موجود')),
    );
    return;
  }
  
  showDialog(
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
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('إلغاء'),
        ),
        TextButton(
          onPressed: () {
            final newName = nameController.text.trim();
            if (newName.isEmpty) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(content: Text('يرجى إدخال اسم المجلد')),
              );
              return;
            }
            
            final description = descriptionController.text.trim();
            final tagsString = tagsController.text.trim();
            final tags = tagsString.isNotEmpty 
                ? tagsString.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList()
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
          child: Text('حفظ'),
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
  final folderController = Provider.of<FolderController>(scaffoldContext, listen: false);
  
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
          content: Text('✅ تم تحديث المجلد بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text(folderController.errorMessage ?? '❌ فشل تحديث المجلد'),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('خطأ: معرف المجلد غير موجود')),
    );
    return;
  }
  
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ShareFolderWithRoomPage(
        folderId: folderId,
        folderName: folderName,
      ),
    ),
  );
  
  // ✅ إعادة تحميل البيانات بعد المشاركة (إذا لزم الأمر)
  if (result == true) {
    // يمكن إضافة منطق لإعادة تحميل البيانات هنا
  }
}

void _showMoveFolderDialog(BuildContext context, Map<String, dynamic> folder, void Function()? onFileRemoved) async {
  // ✅ حفظ context الأصلي قبل فتح الـ modal
  final scaffoldContext = context;
  
  final folderData = folder['folderData'] as Map<String, dynamic>? ?? {};
  final folderId = folder['folderId'] as String? ?? folderData['_id'] as String?;
  final folderName = folder['title'] as String ?? folderData['name'] ?? 'مجلد';
  final currentParentId = folderData['parentId']?.toString();
  
  if (folderId == null) {
    if (scaffoldContext.mounted) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(content: Text('خطأ: معرف المجلد غير موجود')),
      );
    }
    return;
  }

  if (!scaffoldContext.mounted) return;

  showModalBottomSheet(
    context: scaffoldContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) => _FolderNavigationDialog(
      title: 'نقل المجلد: $folderName',
      excludeFolderId: folderId,
      excludeParentId: currentParentId,
      onSelect: (targetFolderId) async {
        Navigator.pop(modalContext);
        if (scaffoldContext.mounted) {
          await _moveFolder(scaffoldContext, folderId, targetFolderId, folderName, onFileRemoved);
        }
      },
    ),
  );
}

/// ✅ دالة لنقل المجلد
Future<void> _moveFolder(BuildContext scaffoldContext, String folderId, String? targetFolderId, String folderName, void Function()? onFileRemoved) async {
  final folderController = Provider.of<FolderController>(scaffoldContext, listen: false);
  
  if (!scaffoldContext.mounted) return;
  
  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(width: 16),
          Text('جاري نقل المجلد...'),
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
          content: Text('✅ تم نقل المجلد بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      
      // ✅ إعادة تحميل البيانات - استخدام callback إذا كان موجوداً
      if (onFileRemoved != null) {
        onFileRemoved();
      }
    } else {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text(folderController.errorMessage ?? '❌ فشل نقل المجلد'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

void _toggleFavorite(BuildContext context, Map<String, dynamic> folder) async {
  final folderId = folder['folderId'] as String?;
  if (folderId == null) return;
  
  final folderController = Provider.of<FolderController>(context, listen: false);
  
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
          Text('جاري التحديث...'),
        ],
      ),
      duration: Duration(seconds: 2),
    ),
  );
  
  // ✅ استدعاء API لإضافة/إزالة من المفضلة
  final result = await folderController.toggleStarFolder(folderId: folderId);
  
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  
  if (result['success'] == true) {
    final isStarred = result['isStarred'] as bool? ?? false;
    final updatedFolder = result['folder'] as Map<String, dynamic>?;
    
    // ✅ تحديث بيانات المجلد المحلية فوراً لتغيير لون النجمة
    if (folderData != null) {
      folderData['isStarred'] = isStarred;
      if (updatedFolder != null) {
        // ✅ تحديث جميع البيانات من الـ response
        folderData.addAll(updatedFolder);
      }
    }
    
    // ✅ تحديث folder أيضاً مباشرة
    if (updatedFolder != null) {
      folder['folderData'] = updatedFolder;
      // ✅ تحديث isStarred مباشرة في item أيضاً
      folder['isStarred'] = isStarred;
    } else {
      folder['isStarred'] = isStarred;
    }
    
    // ✅ إظهار رسالة النجاح
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isStarred 
            ? '✅ تم إضافة المجلد إلى المفضلة' 
            : '✅ تم إزالة المجلد من المفضلة',
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    
    // ✅ إجبار إعادة بناء الـ widget إذا كان في StatefulWidget
    // سيعمل notifyListeners() على تحديث Consumer widgets تلقائياً
  } else {
    // ✅ إظهار رسالة الخطأ
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          folderController.errorMessage ?? '❌ فشل تحديث حالة المفضلة',
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

void _showDeleteDialog(BuildContext context, Map<String, dynamic> folder) {
  final folderController = Provider.of<FolderController>(context, listen: false);
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

Widget _buildInfoRow(String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: Text(
          value,
          style: TextStyle(color: Colors.black87),
        ),
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
  final void Function(Map<String, dynamic>)? onRoomDetailsTap; // ✅ callback لعرض تفاصيل الغرفة
  final void Function(Map<String, dynamic>)? onFolderCommentTap; // ✅ callback للتعليق على المجلد
  final void Function(Map<String, dynamic>)? onRemoveFolderFromRoomTap; // ✅ callback لإزالة المجلد من الغرفة
  final void Function()? onFileRemoved; // ✅ callback لإعادة تحميل البيانات بعد نقل ملف
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
    this.onFolderCommentTap, // ✅ callback للتعليق على المجلد
    this.onRemoveFolderFromRoomTap, // ✅ callback لإزالة المجلد من الغرفة
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
        crossAxisCount: crossAxisCount ?? ResponsiveUtils.getResponsiveValue(
          context,
          mobile: showFileCount ? 3 : 2,
          tablet: showFileCount ? 4 : 4,
          desktop: showFileCount ? 5 : 5,
        ).toInt(),
        mainAxisSpacing: mainAxisSpacing ?? ResponsiveUtils.getResponsiveValue(
          context,
          mobile: 10.0,
          tablet: 14.0,
          desktop: 18.0,
        ),
        crossAxisSpacing: crossAxisSpacing ?? ResponsiveUtils.getResponsiveValue(
          context,
          mobile: 10.0,
          tablet: 14.0,
          desktop: 18.0,
        ),
        childAspectRatio: childAspectRatio ?? ResponsiveUtils.getResponsiveValue(
          context,
          mobile: 0.95,
          tablet: 1.1,
          desktop: 1.2,
        ),
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final type = item['type'] as String?;
        final folderId = type == 'folder' ? (item['folderId'] as String? ?? item['folderData']?['_id'] as String?) : null;
        
        // ✅ استخدام Consumer للتحقق من حالة isStarred من الـ controller
        if (type == 'folder' && folderId != null) {
          return Consumer<FolderController>(
            builder: (context, folderController, child) {
              // ✅ التحقق من حالة isStarred من البيانات المحلية أولاً، ثم من starredFolders
              final folderData = item['folderData'] as Map<String, dynamic>?;
              var isStarred = folderData?['isStarred'] ?? false;
              
              // ✅ التحقق من starredFolders إذا لم تكن البيانات محدثة
              final starredFolder = folderController.starredFolders
                  .firstWhere((f) => f['_id'] == folderId, orElse: () => {});
              if (starredFolder.isNotEmpty) {
                isStarred = starredFolder['isStarred'] ?? true; // ✅ إذا موجود في starredFolders، فهو مفضل
              }
              
              return GestureDetector(
                onTap: () {
                  if (onItemTap != null) {
                    onItemTap!(item);
                  }
                },
                child: FolderFileCard(
                  title: item['title'] as String,
                  fileCount: item['fileCount'] as int,
                  size: item['size'] as String,
                  showFileCount: showFileCount,
                  color: item['color'] as Color? ?? const Color(0xFF00BFA5),
                  folderData: item,
                  isStarred: isStarred,
                  sharedBy: item['sharedBy'] as String?,
                  roomId: (type == 'folder' && roomId != null) ? roomId : null,
                  onOpenTap: type == 'folder' ? () {
                    if (onItemTap != null) {
                      onItemTap!(item);
                    }
                  } : null,
                  onInfoTap: (type == 'folder' && roomId == null) ? () {
                    _showFolderInfo(context, item);
                  } : (type == 'folder' && roomId != null) ? () {
                    _showFolderInfo(context, item);
                  } : null,
                  onRenameTap: (type == 'folder' && roomId == null) ? () {
                    _showRenameDialog(context, item);
                  } : null,
                  onShareTap: (type == 'folder' && roomId == null) ? () {
                    _showShareDialog(context, item);
                  } : null,
                  onMoveTap: (type == 'folder' && roomId == null) ? () {
                    _showMoveFolderDialog(context, item, onFileRemoved);
                  } : null,
                  onFavoriteTap: type == 'folder' ? () {
                    _toggleFavorite(context, item);
                  } : null,
                  onDeleteTap: (type == 'folder' && roomId == null) ? () {
                    _showDeleteDialog(context, item);
                  } : null,
                  onCommentTap: (type == 'folder' && onFolderCommentTap != null && roomId != null) ? () {
                    onFolderCommentTap!(item);
                  } : null,
                  onRemoveFromRoomTap: (type == 'folder' && onRemoveFolderFromRoomTap != null && roomId != null) ? () {
                    onRemoveFolderFromRoomTap!(item);
                  } : null,
                  onDetailsTap: type == 'room' ? () {
                    if (onRoomDetailsTap != null) {
                      onRoomDetailsTap!(item);
                    }
                  } : null,
                ),
              );
            },
          );
        }
        
        // ✅ للملفات أو الأنواع الأخرى (بدون Consumer)
        // ✅ للـ categories نضيف callbacks للقائمة "3 نقاط"
        return GestureDetector(
          onTap: () {
            if (onItemTap != null) {
              onItemTap!(item);
            }
          },
          child: FolderFileCard(
            title: item['title'] as String,
            fileCount: item['fileCount'] as int,
            size: item['size'] as String,
            showFileCount: showFileCount,
            color: item['color'] as Color? ?? const Color(0xFF00BFA5),
            folderData: (type == 'folder' || type == 'category') ? item : null,
            isStarred: type == 'folder' ? (item['folderData']?['isStarred'] ?? false) : false,
            sharedBy: item['sharedBy'] as String?,
            roomId: (type == 'folder' && roomId != null) ? roomId : null,
            // ✅ للـ categories: فتح وعرض التفاصيل
            onOpenTap: type == 'category' ? () {
              if (onItemTap != null) {
                onItemTap!(item);
              }
            } : type == 'folder' ? () {
              if (onItemTap != null) {
                onItemTap!(item);
              }
            } : null,
            onInfoTap: type == 'category' ? () {
              _showCategoryDetails(context, item);
            } : (type == 'folder' && roomId == null) ? () {
              _showFolderInfo(context, item);
            } : (type == 'folder' && roomId != null) ? () {
              _showFolderInfo(context, item);
            } : null,
            onRenameTap: (type == 'folder' && roomId == null) ? () {
              _showRenameDialog(context, item);
            } : null,
            onShareTap: (type == 'folder' && roomId == null) ? () {
              _showShareDialog(context, item);
            } : null,
            onMoveTap: (type == 'folder' && roomId == null) ? () {
              _showMoveFolderDialog(context, item, onFileRemoved);
            } : null,
            onFavoriteTap: type == 'folder' ? () {
              _toggleFavorite(context, item);
            } : null,
            onDeleteTap: (type == 'folder' && roomId == null) ? () {
              _showDeleteDialog(context, item);
            } : null,
            onCommentTap: (type == 'folder' && onFolderCommentTap != null && roomId != null) ? () {
              onFolderCommentTap!(item);
            } : null,
            onRemoveFromRoomTap: (type == 'folder' && onRemoveFolderFromRoomTap != null && roomId != null) ? () {
              onRemoveFolderFromRoomTap!(item);
            } : null,
            onDetailsTap: type == 'room' ? () {
              if (onRoomDetailsTap != null) {
                onRoomDetailsTap!(item);
              }
            } : null,
          ),
        );
      },
    );
  }
}

// ✅ Widget للتنقل داخل المجلدات عند النقل - نفس folder_contents_page.dart
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
  State<_FolderNavigationDialog> createState() => _FolderNavigationDialogState();
}

class _FolderNavigationDialogState extends State<_FolderNavigationDialog> {
  List<Map<String, dynamic>> _currentFolders = [];
  List<Map<String, String?>> _breadcrumb = []; // [{id: null, name: 'الجذر'}]
  bool _isLoading = false;
  String? _currentFolderId;

  @override
  void initState() {
    super.initState();
    _breadcrumb.add({'id': null, 'name': 'الجذر'});
    _loadRootFolders();
  }

  // ✅ جلب المجلدات الجذرية
  Future<void> _loadRootFolders() async {
    setState(() {
      _isLoading = true;
      _currentFolderId = null;
    });

    try {
      final folderController = Provider.of<FolderController>(context, listen: false);
      final response = await folderController.getAllFolders(page: 1, limit: 100);
      
      if (response != null && response['folders'] != null) {
        final folders = List<Map<String, dynamic>>.from(response['folders'] ?? []);
        
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
      final folderController = Provider.of<FolderController>(context, listen: false);
      
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
          subfolders = List<Map<String, dynamic>>.from(response['subfolders'] ?? []);
          print('📁 Found ${subfolders.length} subfolders from subfolders field');
        }
        // ✅ إذا لم تكن موجودة، جرب من contents (لكن هذا قد يكون محدود بـ pagination)
        if (subfolders.isEmpty && response['contents'] != null) {
          final contents = List<Map<String, dynamic>>.from(response['contents'] ?? []);
          subfolders = contents.where((item) => item['type'] == 'folder').toList();
          print('📁 Found ${subfolders.length} subfolders from contents field');
        }
        
        // ✅ إذا لم نجد أي مجلدات، جرب من folders مباشرة (fallback)
        if (subfolders.isEmpty && response['folders'] != null) {
          subfolders = List<Map<String, dynamic>>.from(response['folders'] ?? []);
          print('📁 Found ${subfolders.length} subfolders from folders field (fallback)');
        }
      }
      
      print('📁 Total found: ${subfolders.length} subfolders for folder $folderId ($folderName)');
      
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
            content: Text('خطأ في جلب المجلدات الفرعية: ${e.toString()}'),
            backgroundColor: Colors.red,
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
        _breadcrumb = [{'id': null, 'name': 'الجذر'}];
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
          final folderName = _breadcrumb.last['name'] ?? 'مجلد';
          _loadSubfolders(folderId, folderName);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Icon(Icons.drive_file_move_rounded, color: Colors.white, size: 32),
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
              color: Colors.grey[100],
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
                            onTap: isLast ? null : () => _navigateToFolder(item['id']),
                            child: Row(
                              children: [
                                if (index > 0) ...[
                                  Icon(Icons.chevron_left, size: 16, color: Colors.grey),
                                  SizedBox(width: 4),
                                ],
                                Text(
                                  item['name'] ?? 'الجذر',
                                  style: TextStyle(
                                    color: isLast ? Colors.purple : Colors.blue,
                                    fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                                    decoration: isLast ? null : TextDecoration.underline,
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
                    leading: Icon(Icons.home_rounded, color: Colors.blue),
                    title: Text('نقل إلى الجذر'),
                    subtitle: Text('نقل المجلد إلى المجلد الرئيسي'),
                    onTap: () => widget.onSelect(null),
                  ),
                // ✅ خيار "اختيار المجلد الحالي" (إذا كنا داخل مجلد)
                if (_currentFolderId != null)
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('اختيار "${_breadcrumb.last['name'] ?? 'مجلد'}"'),
                    subtitle: Text('نقل إلى هذا المجلد'),
                    onTap: () => widget.onSelect(_currentFolderId),
                  ),
                // ✅ Divider بين الخيارات وقائمة المجلدات
                Divider(),
                
                // ✅ قائمة المجلدات
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : _currentFolders.isEmpty
                          ? Center(
                              child: Text(
                                _currentFolderId == null
                                    ? 'لا توجد مجلدات متاحة'
                                    : 'لا توجد مجلدات فرعية',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _currentFolders.length,
                              itemBuilder: (context, index) {
                                final folder = _currentFolders[index];
                                final folderId = folder['_id']?.toString();
                                final folderName = folder['name'] ?? 'مجلد بدون اسم';
                                
                                return InkWell(
                                  onTap: () {
                                    // ✅ فتح المجلد لعرض المجلدات الفرعية
                                    if (folderId != null) {
                                      print('📂 Opening folder: $folderId ($folderName)');
                                      _loadSubfolders(folderId, folderName);
                                    } else {
                                      print('⚠️ Folder ID is null for folder: $folderName');
                                    }
                                  },
                                  child: ListTile(
                                    leading: Icon(Icons.folder_rounded, color: Colors.orange),
                                    title: Text(folderName),
                                    subtitle: Text('${folder['filesCount'] ?? 0} ملف'),
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
                                              child: Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        // ✅ أيقونة chevron للإشارة إلى إمكانية فتح المجلد
                                        Icon(Icons.chevron_right, color: Colors.grey),
                                      ],
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
