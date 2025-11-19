import 'dart:io';
import 'package:filevo/views/fileViewer/file_details_page.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/files_controller.dart';
import 'file_actions_service.dart';

class FilesGrid extends StatefulWidget {
  final List<Map<String, dynamic>> files;
  final void Function(Map<String, dynamic> file)? onFileTap;

  const FilesGrid({super.key, required this.files, this.onFileTap});

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
            builder: (_) => FileDetailsPage(fileId: file['originalData']['_id']),
          ),
        );
        break;
      case 'edit':
        FileActionsService.editFile(context, file);
        break;
      case 'share':
        FileActionsService.shareFile(file);
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
      case 'delete':
        FileActionsService.deleteFile(context, fileController, file);
        break;
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
                      itemBuilder: (context) => [
                        _buildMenuItem('open', Icons.open_in_new_rounded, 'فتح', Colors.blue),
                        _buildMenuItem('info', Icons.info_outline_rounded, 'عرض المعلومات', Colors.teal),
                        _buildMenuItem('edit', Icons.edit_rounded, 'تعديل', Colors.orange),
                        _buildMenuItem('share', Icons.share_rounded, 'مشاركة', Colors.green),
                        // ✅ تعديل: استخدام الحالة المحلية بدلاً من البيانات مباشرة
                        _buildMenuItem(
                          'favorite',
                          isStarred ? Icons.star_rounded : Icons.star_border_rounded,
                          isStarred ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
                          Colors.amber[700]!,
                        ),
                        const PopupMenuDivider(),
                        _buildMenuItem('delete', Icons.delete_outline_rounded, 'حذف', Colors.red),
                      ],
                      onSelected: (value) => _handleMenuAction(value, file),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                fileName,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A), height: 1.3),
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
}