import 'dart:io';

import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:filevo/views/folders/share_file_with_room_page.dart';

class FileDetailsPage extends StatefulWidget {
  final String fileId;

  const FileDetailsPage({super.key, required this.fileId});

  @override
  State<FileDetailsPage> createState() => _FileDetailsPageState();
}

class _FileDetailsPageState extends State<FileDetailsPage> {
  Map<String, dynamic>? fileData;
  bool isLoading = true;
  String? videoThumbnailPath;

  @override
  void initState() {
    super.initState();
    _loadFileDetails();
  }

  Future<void> _loadFileDetails() async {
    try {
      final fileController = Provider.of<FileController>(context, listen: false);
      final token = await StorageService.getToken();

      if (token == null) {
        print("⚠️ No token found");
        return;
      }

      print("🔄 Fetching details for file ID: ${widget.fileId}");
      final data = await fileController.getFileDetails(
        fileId: widget.fileId,
        token: token,
      );

      print("📥 Raw Data from backend: $data");

      if (mounted) {
        setState(() {
          fileData = data?['file'];
        });
      }

      // إذا كان الفيديو، إنشاء الثمبنيل
      if (fileData != null && fileData!['category']?.toLowerCase() == "videos") {
        final videoUrl = "http://10.0.2.2:8000/${fileData!['path'] ?? ''}";
        final thumbnail = await _getVideoThumbnail(videoUrl);
        if (mounted) {
          setState(() {
            videoThumbnailPath = thumbnail;
          });
        }
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      print("📦 Final fileData used in UI: $fileData");

    } catch (e) {
      print("❌ Error fetching file details: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<String?> _getVideoThumbnail(String videoUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 200,
        quality: 75,
      );
      print("✅ Thumbnail generated: $thumbnailPath");
      return thumbnailPath;
    } catch (e) {
      print('❌ Error generating thumbnail: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFD),
      appBar: AppBar(
        title: Text(
          'تفاصيل الملف',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Color(0xFF4F6BED),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'share_with_room',
                child: Row(
                  children: [
                    Icon(Icons.meeting_room, color: Color(0xff28336f)),
                    SizedBox(width: 12),
                    Text('مشاركة مع غرفة'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, color: Colors.green),
                    SizedBox(width: 12),
                    Text('مشاركة'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'share_with_room' && fileData != null) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShareFileWithRoomPage(
                      fileId: widget.fileId,
                      fileName: fileData!['name'] ?? 'ملف',
                    ),
                  ),
                );
                if (result == true) {
                  _loadFileDetails();
                }
              } else if (value == 'share') {
                // TODO: Add share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ميزة المشاركة قريباً')),
                );
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFF4F6BED).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F6BED)),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'جاري تحميل بيانات الملف...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (fileData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 50,
                color: Color(0xFFDC2626),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'فشل في تحميل بيانات الملف',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDC2626),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'معرف الملف: ${widget.fileId}',
              style: TextStyle(
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadFileDetails,
              icon: Icon(Icons.refresh_rounded, size: 20),
              label: Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4F6BED),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      );
    }

    final fileName = fileData!['name'] ?? 'بدون اسم';
    final fileType = fileData!['category'] ?? 'غير مصنف';
    final fileUrl = "http://10.0.2.2:8000/${fileData!['path'] ?? ''}";

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          // File Preview Section
          _buildFilePreview(fileName, fileType, fileUrl),
          
          SizedBox(height: 24),
          
          // File Details Section
          _buildFileDetailsSection(),
        ],
      ),
    );
  }

  Widget _buildFilePreview(String fileName, String fileType, String fileUrl) {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F6BED), Color(0xFF6D8BFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4F6BED).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // File Preview
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              height: 200,
              width: double.infinity,
              child: fileType.toLowerCase() == "images" 
                  ? _buildImagePreview(fileUrl, fileType)
                  : fileType.toLowerCase() == "videos"
                      ? _buildVideoPreview(fileUrl, fileType)
                      : _buildFileIcon(fileType),
            ),
          ),
          
          // File Name
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fileName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String url, String fileType) {
    return Stack(
      children: [
        Image.network(
          url,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              color: Colors.white.withOpacity(0.1),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stack) => _buildErrorPreview(),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.photo_filter_rounded, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'صورة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPreview(String videoUrl, String fileType) {
    return Stack(
      children: [
        // عرض الثمبنيل إذا وجد
        if (videoThumbnailPath != null)
          Image.file(
            File(videoThumbnailPath!),
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => _buildVideoPlaceholder(),
          )
        else
          _buildVideoPlaceholder(),

        // زر التشغيل في المنتصف
        Positioned.fill(
          child: Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Color(0xFF4F6BED),
                size: 40,
              ),
            ),
          ),
        ),

        // علامة الفيديو في الأعلى
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam_rounded, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'فيديو',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // مؤشر التحميل إذا كان يجري إنشاء الثمبنيل
        if (videoThumbnailPath == null && !isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEF4444), Color(0xFFF87171)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_rounded,
            color: Colors.white,
            size: 50,
          ),
          SizedBox(height: 8),
          Text(
            'فيديو',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileIcon(String category) {
    final Map<String, Map<String, dynamic>> categoryConfig = {
      "documents": {
        "icon": Icons.description_rounded,
        "color": Color(0xFF10B981),
        "gradient": [Color(0xFF10B981), Color(0xFF34D399)],
        "iconBg": Color(0xFF10B981).withOpacity(0.2),
        "label": "مستند",
      },
      "images": {
        "icon": Icons.photo_library_rounded,
        "color": Color(0xFFF59E0B),
        "gradient": [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        "iconBg": Color(0xFFF59E0B).withOpacity(0.2),
        "label": "صورة",
      },
      "videos": {
        "icon": Icons.videocam_rounded,
        "color": Color(0xFFEF4444),
        "gradient": [Color(0xFFEF4444), Color(0xFFF87171)],
        "iconBg": Color(0xFFEF4444).withOpacity(0.2),
        "label": "فيديو",
      },
      "audio": {
        "icon": Icons.music_note_rounded,
        "color": Color(0xFF8B5CF6),
        "gradient": [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
        "iconBg": Color(0xFF8B5CF6).withOpacity(0.2),
        "label": "صوت",
      },
    };

    final config = categoryConfig[category.toLowerCase()] ?? {
      "icon": Icons.folder_rounded,
      "color": Color(0xFF6B7280),
      "gradient": [Color(0xFF6B7280), Color(0xFF9CA3AF)],
      "iconBg": Color(0xFF6B7280).withOpacity(0.2),
      "label": "ملف",
    };

    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: config["gradient"] as List<Color>,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              config["icon"] as IconData,
              color: Colors.white,
              size: 40,
            ),
          ),
          SizedBox(height: 16),
          Text(
            config["label"] as String,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPreview() {
    return Container(
      height: 200,
      color: Colors.white.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.broken_image_rounded,
              size: 30,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'تعذر تحميل المعاينة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileDetailsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF000000).withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4F6BED), Color(0xFF6D8BFF)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'معلومات الملف',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Details Grid
          _buildDetailItem('folder', '📁', 'التصنيف', fileData!['category'] ?? '—'),
          _buildDetailItem('size', '📊', 'الحجم', fileData!['sizeFormatted'] ?? fileData!['size'] ?? '—'),
          _buildDetailItem('time', '🕒', 'أنشئ في', _formatDate(fileData!['createdAt'])),
          _buildDetailItem('edit', '✏️', 'آخر تعديل', _formatDate(fileData!['updatedAt'])),
          _buildDetailItem('description', '📝', 'الوصف', 
              fileData!['description']?.isNotEmpty == true ? fileData!['description'] : "—"),
          _buildDetailItem('tags', '🏷️', 'الوسوم', 
              (fileData!['tags'] as List?)?.join(', ') ?? "—"),

          // Shared With Section
          if (fileData!['sharedWith'] != null && fileData!['sharedWith'].isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                _buildDetailItem(
                  'share',
                  '👥',
                  'تمت المشاركة مع',
                  fileData!['sharedWith']
                      .map<String>((u) => u['email']?.toString() ?? '')
                      .where((email) => email.isNotEmpty)
                      .join(', ') ?? "—",
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String type, String emoji, String label, String value) {
    Color getIconColor() {
      switch (type) {
        case 'folder': return Color(0xFF10B981);
        case 'size': return Color(0xFFF59E0B);
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: getIconColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '—';
    return date.toString();
  }

  @override
  void dispose() {
    // تنظيف الملفات المؤقتة إذا أردت
    super.dispose();
  }
}