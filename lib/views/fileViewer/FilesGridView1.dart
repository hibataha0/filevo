import 'dart:io';
import 'package:filevo/views/fileViewer/file_details_page.dart';
import 'package:filevo/views/folders/room_comments_page.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/services/storage_service.dart';
import 'file_actions_service.dart';

class FilesGrid extends StatefulWidget {
  final List<Map<String, dynamic>> files;
  final void Function(Map<String, dynamic> file)? onFileTap;
  final String? roomId; // ✅ معرف الروم (اختياري) - لاستخدام getSharedFileDetailsInRoom
  final VoidCallback? onFileRemoved; // ✅ callback عند إزالة ملف من الغرفة

  const FilesGrid({
    super.key, 
    required this.files, 
    this.onFileTap, 
    this.roomId,
    this.onFileRemoved,
  });

  @override
  State<FilesGrid> createState() => _FilesGridState();
}

class _FilesGridState extends State<FilesGrid> {
  // ✅ إضافة: Map لتتبع حالة النجمة لكل ملف
  final Map<String, bool> _starStates = {};

  @override
  void initState() {
    super.initState();
    _initializeStarStates();
  }

  @override
  void didUpdateWidget(FilesGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ تحديث الحالات عند تغيير القائمة
    if (oldWidget.files != widget.files) {
      _initializeStarStates();
    }
  }

  // ✅ إضافة: تهيئة حالات النجمة من البيانات
  void _initializeStarStates() {
    for (var file in widget.files) {
      final fileId = file['originalData']?['_id'];
      if (fileId != null) {
        _starStates[fileId] = file['originalData']['isStarred'] ?? false;
      }
    }
  }

  // ✅ Cache لـ thumbnails الفيديو لمنع إعادة التوليد عند scroll
  final Map<String, String?> _thumbnailCache = {};

  Future<String?> _getVideoThumbnail(String videoUrl) async {
    // ✅ التحقق من cache أولاً
    if (_thumbnailCache.containsKey(videoUrl)) {
      final cachedPath = _thumbnailCache[videoUrl];
      if (cachedPath != null) {
        final file = File(cachedPath);
        if (await file.exists()) {
          return cachedPath; // ✅ إرجاع thumbnail من cache
        }
      }
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 200,
        quality: 75,
        timeMs: 1000, // ✅ أخذ thumbnail من الثانية الأولى
      );
      
      // ✅ حفظ في cache
      if (thumbnailPath != null) {
        _thumbnailCache[videoUrl] = thumbnailPath;
      }
      
      return thumbnailPath;
    } catch (e) {
      print('Error generating thumbnail: $e');
      _thumbnailCache[videoUrl] = null; // ✅ حفظ null في cache لتجنب إعادة المحاولة
      return null;
    }
  }

  void _handleMenuAction(String action, Map<String, dynamic> file) {
    if (!mounted) return;
    
    final fileController = Provider.of<FileController>(context, listen: false);

    switch (action) {
      case 'open':
        FileActionsService.openFile(file, widget.onFileTap);
        break;
      case 'info':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FileDetailsPage(
              fileId: file['originalData']['_id'],
              roomId: widget.roomId, // ✅ تمرير roomId إذا كان موجوداً
            ),
          ),
        );
        break;
      case 'comments':
        if (widget.roomId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RoomCommentsPage(
                roomId: widget.roomId!,
                targetType: 'file',
                targetId: file['originalData']['_id'],
              ),
            ),
          );
        }
        break;
      case 'edit':
        FileActionsService.editFile(context, file);
        break;
      case 'share':
        FileActionsService.shareFile(context, file);
        break;
      case 'move':
        // ✅ نقل الملف
        _showMoveFileDialog(file);
        break;
     case 'favorite':
      FileActionsService.toggleStar(
        context, 
        fileController, 
        file,
        onToggle: () {
          final fileId = file['originalData']?['_id'];
          if (fileId != null && mounted) {
            setState(() {
              // ✅ نحدث من البيانات مباشرة
              _starStates[fileId] = file['originalData']['isStarred'] ?? false;
              print('🎨 UI Updated - Star state: ${_starStates[fileId]}');
            });
          }
        },
      );
      break;
      case 'unshare':
        FileActionsService.unshareFile(context, fileController, file);
        break;
      case 'delete':
        FileActionsService.deleteFile(context, fileController, file);
        break;
    }
  }

  /// ✅ بناء قائمة الملفات المشتركة في الغرف
  List<PopupMenuEntry<String>> _buildSharedFileMenuItems(Map<String, dynamic> file, bool isStarred) {
    return [
      _buildMenuItem('open', Icons.open_in_new_rounded, 'فتح', Colors.blue),
      _buildMenuItem('info', Icons.info_outline_rounded, 'عرض التفاصيل', Colors.teal),
      _buildMenuItem('comments', Icons.comment_rounded, 'التعليقات', Color(0xFFF59E0B)),
      const PopupMenuDivider(),
      _buildMenuItem(
        'favorite',
        isStarred ? Icons.star_rounded : Icons.star_border_rounded,
        isStarred ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
        Colors.amber[700]!,
      ),
      const PopupMenuDivider(),
      _buildMenuItem('remove_from_room', Icons.link_off_rounded, 'إزالة من الغرفة', Colors.red),
    ];
  }

  /// ✅ بناء قائمة الملفات العادية
  List<PopupMenuEntry<String>> _buildNormalFileMenuItems(Map<String, dynamic> file, bool isStarred) {
    return [
      _buildMenuItem('open', Icons.open_in_new_rounded, 'فتح', Colors.blue),
      _buildMenuItem('info', Icons.info_outline_rounded, 'عرض المعلومات', Colors.teal),
      _buildMenuItem('edit', Icons.edit_rounded, 'تعديل', Colors.orange),
      _buildMenuItem('share', Icons.share_rounded, 'مشاركة', Colors.green),
      _buildMenuItem('move', Icons.drive_file_move_rounded, 'نقل', Colors.purple),
      _buildMenuItem(
        'favorite',
        isStarred ? Icons.star_rounded : Icons.star_border_rounded,
        isStarred ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
        Colors.amber[700]!,
      ),
      const PopupMenuDivider(),
      _buildMenuItem('delete', Icons.delete_outline_rounded, 'حذف', Colors.red),
    ];
  }

  /// ✅ معالجة إجراءات الملفات المشتركة في الغرف
  void _handleSharedFileMenuAction(String action, Map<String, dynamic> file) {
    if (!mounted) return;
    
    final fileController = Provider.of<FileController>(context, listen: false);

    switch (action) {
      case 'open':
        FileActionsService.openFile(file, widget.onFileTap);
        break;
      case 'info':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FileDetailsPage(
              fileId: file['originalData']['_id'],
              roomId: widget.roomId,
            ),
          ),
        );
        break;
      case 'comments':
        if (widget.roomId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RoomCommentsPage(
                roomId: widget.roomId!,
                targetType: 'file',
                targetId: file['originalData']['_id'],
              ),
            ),
          );
        }
        break;
      case 'favorite':
        FileActionsService.toggleStar(
          context, 
          fileController, 
          file,
          onToggle: () {
            final fileId = file['originalData']?['_id'];
            if (fileId != null && mounted) {
              setState(() {
                _starStates[fileId] = file['originalData']['isStarred'] ?? false;
              });
            }
          },
        );
        break;
      case 'remove_from_room':
        _showRemoveFileFromRoomDialog(file);
        break;
    }
  }

  /// ✅ عرض dialog لتأكيد إزالة الملف من الغرفة
  void _showRemoveFileFromRoomDialog(Map<String, dynamic> file) {
    final fileName = file['name']?.toString() ?? file['originalName']?.toString() ?? 'الملف';
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('إزالة الملف من الغرفة'),
        content: Text('هل أنت متأكد من إزالة "$fileName" من هذه الغرفة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _removeFileFromRoom(file);
            },
            child: Text('إزالة', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// ✅ إزالة الملف من الغرفة
  Future<void> _removeFileFromRoom(Map<String, dynamic> file) async {
    if (widget.roomId == null) return;
    
    final fileId = file['originalData']?['_id'] ?? file['fileId'];
    if (fileId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ معرف الملف غير موجود'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    try {
      final roomController = Provider.of<RoomController>(context, listen: false);
      final success = await roomController.unshareFileFromRoom(
        roomId: widget.roomId!,
        fileId: fileId,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تم إزالة الملف من الغرفة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          // ✅ إعادة تحميل البيانات بعد إزالة الملف
          if (widget.onFileRemoved != null) {
            widget.onFileRemoved!();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(roomController.errorMessage ?? '❌ فشل إزالة الملف من الغرفة'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// ✅ دالة لعرض dialog لاختيار المجلد الهدف لنقل الملف
  void _showMoveFileDialog(Map<String, dynamic> file) async {
    final originalData = file['originalData'] ?? {};
    final fileId = originalData['_id']?.toString();
    final fileName = file['name'] ?? originalData['name'] ?? 'ملف';
    final currentParentId = originalData['parentFolderId']?.toString();
    
    if (fileId == null || !mounted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: معرف الملف غير موجود')),
        );
      }
      return;
    }

    // ✅ جلب قائمة المجلدات
    final folderController = Provider.of<FolderController>(context, listen: false);
    final foldersResponse = await folderController.getAllFolders(page: 1, limit: 100);
    
    if (foldersResponse == null || foldersResponse['folders'] == null || !mounted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل جلب قائمة المجلدات')),
        );
      }
      return;
    }

    final folders = List<Map<String, dynamic>>.from(foldersResponse['folders'] ?? []);
    
    // ✅ تصفية المجلد الحالي (إذا كان الملف في مجلد)
    final availableFolders = folders.where((folder) {
      final folderId = folder['_id']?.toString();
      return folderId != currentParentId;
    }).toList();

    if (!mounted) return;

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
                  Icon(Icons.drive_file_move_rounded, color: Colors.white, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'نقل الملف: $fileName',
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
                    subtitle: Text('نقل الملف للجذر (بدون مجلد)'),
                    onTap: () {
                      Navigator.pop(context);
                      _moveFile(fileId, null, fileName);
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
                              final folder = availableFolders[index];
                              final folderId = folder['_id']?.toString();
                              final folderName = folder['name'] ?? 'مجلد بدون اسم';
                              
                              return ListTile(
                                leading: Icon(Icons.folder_rounded, color: Colors.orange),
                                title: Text(folderName),
                                subtitle: Text('${folder['filesCount'] ?? 0} ملف'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _moveFile(fileId, folderId, fileName);
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

  /// ✅ دالة لنقل الملف
  Future<void> _moveFile(String fileId, String? targetFolderId, String fileName) async {
    if (!mounted) return;
    
    final fileController = Provider.of<FileController>(context, listen: false);
    final token = await StorageService.getToken();
    
    if (token == null || !mounted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: يجب تسجيل الدخول أولاً')),
        );
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 16),
            Text('جاري نقل الملف...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    final success = await fileController.moveFile(
      fileId: fileId,
      token: token,
      targetFolderId: targetFolderId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم نقل الملف بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        
        // ✅ إعادة تحميل البيانات إذا كان هناك callback
        if (widget.onFileRemoved != null) {
          widget.onFileRemoved!();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(fileController.errorMessage ?? '❌ فشل نقل الملف'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getFileTypeColor(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'image':
        return const Color(0xFF4CAF50);
      case 'video':
        return const Color(0xFFE91E63);
      case 'pdf':
        return const Color(0xFFF44336);
      case 'audio':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF607D8B);
    }
  }

  IconData _getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'image':
        return Icons.image_rounded;
      case 'video':
        return Icons.video_library_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'audio':
        return Icons.audio_file_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 80,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد ملفات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بإضافة ملفات جديدة',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.files.length,
      // ✅ إعدادات cache للـ GridView لمنع إعادة التحميل عند Scroll
      cacheExtent: 500, // ✅ الاحتفاظ بـ 500 بكسل من الصور المحملة خارج الشاشة
      addAutomaticKeepAlives: true, // ✅ الاحتفاظ بالـ widgets محملة
      addRepaintBoundaries: true, // ✅ تحسين الأداء
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final file = widget.files[index];
        final fileName = file['name'] ?? 'ملف بدون اسم';
        final fileUrl = file['url'] ?? '';
        final fileType = file['type'] ?? 'file';
        return _buildFileCard(fileType, fileUrl, fileName, file);
      },
    );
  }

  Widget _buildFileCard(String fileType, String fileUrl, String fileName, Map<String, dynamic> file) {
    // ✅ الحصول على حالة النجمة من الـ state المحلي
    final fileId = file['originalData']?['_id'];
    final isStarred = fileId != null ? (_starStates[fileId] ?? false) : false;

    return GestureDetector(
      onTap: () => widget.onFileTap?.call(file),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                    ),
                    child: _buildFileContent(fileType, fileUrl, fileName),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 20, color: Colors.grey[700]),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 8,
                      itemBuilder: (context) {
                        // ✅ قائمة منفصلة للملفات المشتركة في الغرف
                        if (widget.roomId != null) {
                          return _buildSharedFileMenuItems(file, isStarred);
                        } else {
                          // ✅ قائمة الملفات العادية
                          return _buildNormalFileMenuItems(file, isStarred);
                        }
                      },
                      onSelected: (value) {
                        if (widget.roomId != null) {
                          _handleSharedFileMenuAction(value, file);
                        } else {
                          _handleMenuAction(value, file);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A), height: 1.3),
                  ),
                  // ✅ عرض معلومات إضافية للملفات المشتركة في الروم
                  if (file['sharedBy'] != null || file['category'] != null || file['createdAt'] != null) ...[
                    const SizedBox(height: 6),
                    // ✅ التصنيف
                    if (file['category'] != null && file['category'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            Icon(Icons.category_outlined, size: 11, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                file['category'].toString(),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // ✅ من شارك الملف
                    if (file['sharedBy'] != null && file['sharedBy'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            Icon(Icons.person_outline, size: 11, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'شاركه: ${file['sharedBy']}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // ✅ تاريخ الإنشاء
                    if (file['createdAt'] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 11, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _formatDate(file['createdAt']),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // ✅ تاريخ التعديل
                    if (file['updatedAt'] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 11, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'عدل: ${_formatDate(file['updatedAt'])}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, IconData icon, String label, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildFileContent(String fileType, String fileUrl, String fileName) {
    switch (fileType.toLowerCase()) {
      case 'image':
        return _buildImageContent(fileUrl);
      case 'video':
        return _buildVideoContent(fileUrl, fileName);
      case 'pdf':
        return _buildIconContent(Icons.picture_as_pdf_rounded, const Color(0xFFF44336));
      case 'audio':
        return _buildIconContent(Icons.audio_file_rounded, const Color(0xFF9C27B0));
      default:
        return _buildIconContent(Icons.insert_drive_file_rounded, const Color(0xFF607D8B));
    }
  }

  Widget _buildImageContent(String url) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        // ✅ إعدادات Cache لمنع إعادة التحميل عند Scroll
        cacheKey: url, // ✅ مفتاح cache فريد للـ URL
        maxWidthDiskCache: 800, // ✅ تقليل حجم الصورة المحفوظة
        maxHeightDiskCache: 800,
        memCacheWidth: 400, // ✅ تحسين استخدام الذاكرة
        memCacheHeight: 400,
        fadeInDuration: const Duration(milliseconds: 200), // ✅ تأثير fade-in سلس
        fadeOutDuration: const Duration(milliseconds: 100),
        // ✅ إظهار placeholder فقط عند أول تحميل
        placeholder: (context, url) => Container(
          color: Colors.grey.shade50, 
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2))
        ),
        // ✅ إظهار placeholder فوري من cache بدون إعادة تحميل
        placeholderFadeInDuration: const Duration(milliseconds: 100),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey.shade50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text('فشل التحميل', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent(String url, String fileName) {
    return FutureBuilder<String?>(
      future: _getVideoThumbnail(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(color: Colors.grey.shade50, child: const Center(child: CircularProgressIndicator(strokeWidth: 2)));
        } else if (snapshot.hasData && snapshot.data != null) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                child: Image.file(File(snapshot.data!), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Color(0xFFE91E63), size: 32),
                  ),
                ),
              ),
            ],
          );
        } else {
          return _buildIconContent(Icons.video_library_rounded, const Color(0xFFE91E63));
        }
      },
    );
  }

  Widget _buildIconContent(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(icon, size: 48, color: color),
        ),
      ),
    );
  }

  // ✅ تنسيق التاريخ
  String _formatDate(dynamic date) {
    if (date == null) return '—';
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return '—';
    }
  }
}