import 'dart:io';

import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:filevo/views/folders/share_file_with_room_page.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:filevo/constants/app_colors.dart';

class FileDetailsPage extends StatefulWidget {
  final String fileId;
  final String?
  roomId; // ✅ معرف الروم (اختياري) - إذا كان موجوداً، نستخدم getSharedFileDetailsInRoom

  const FileDetailsPage({super.key, required this.fileId, this.roomId});

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
      final fileController = Provider.of<FileController>(
        context,
        listen: false,
      );
      final token = await StorageService.getToken();

      if (token == null) {
        print("⚠️ No token found");
        return;
      }

      print("🔄 Fetching details for file ID: ${widget.fileId}");

      // ✅ إذا كان roomId موجوداً، استخدم getSharedFileDetailsInRoom
      final data = widget.roomId != null
          ? await fileController.getSharedFileDetailsInRoom(
              fileId: widget.fileId,
              token: token,
            )
          : await fileController.getFileDetails(
              fileId: widget.fileId,
              token: token,
            );

      print("📥 Raw Data from backend: $data");

      // ✅ التحقق من وجود خطأ في الاستجابة
      if (data != null && data['error'] != null) {
        if (mounted) {
          setState(() {
            isLoading = false;
            fileData = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['error'] ??
                    S.of(context).errorLoadingFileData(data['error'] ?? ''),
              ),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      if (mounted) {
        setState(() {
          fileData = data?['file'];
          print('📦 File data loaded: ${fileData != null ? fileData!.keys.toList() : "null"}');
        });
      }

      // ✅ حالة خاصة: إذا كان roomId موجوداً ولكن لم نجد البيانات أو الـ path مفقود
      if (widget.roomId != null && (fileData == null || fileData?['path'] == null || fileData!['path'].toString().isEmpty)) {
        print('⚠️ File data or path missing in room details, attempting regular details fetch...');
        // ✅ جلب التفاصيل العادية مباشرة لضمان اكتمال البيانات قبل إغلاق حالة التحميل
        await _loadFilePathFromRegularDetails();
      }

      // إذا كان الفيديو، إنشاء الثمبنيل
      if (fileData != null &&
          fileData!['category']?.toLowerCase() == "videos") {
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
      if (mounted) {
        setState(() {
          isLoading = false;
          fileData = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorLoadingFileDetails(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: S.of(context).retry, // استخدمنا intl للزر
              textColor: Colors.white,
              onPressed: _loadFileDetails,
            ),
          ),
        );
      }
    }
  }

  // ✅ جلب path من تفاصيل الملف العادية إذا لم يكن موجوداً في shared details
  Future<void> _loadFilePathFromRegularDetails() async {
    try {
      final fileController = Provider.of<FileController>(
        context,
        listen: false,
      );
      final token = await StorageService.getToken();

      if (token == null) return;

      final data = await fileController.getFileDetails(
        fileId: widget.fileId,
        token: token,
      );

      if (data != null && data['file'] != null) {
        if (mounted) {
          setState(() {
            if (fileData == null) {
              // ✅ إذا كان fileData نل، نأخذ البيانات العادية بالكامل
              fileData = Map<String, dynamic>.from(data['file']);
              print('✅ Full file data loaded from regular details');
            } else {
              // ✅ إذا كان موجوداً، نحدث فقط الـ path أو أي حقول مفقودة
              fileData!['path'] = data['file']['path'];
              print('✅ Path updated from regular details: ${fileData!['path']}');
            }
          });
        }
      }
    } catch (e) {
      print('❌ Error loading file path: $e');
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppColors.getBackground(isDarkMode),
      appBar: AppBar(
        title: Text(
          S.of(context).fileDetails,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.getPrimary(isDarkMode),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
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
                    Text(S.of(context).shareWithRoom),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, color: Colors.green),
                    SizedBox(width: 12),
                    Text(S.of(context).share),
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
                      fileName: fileData!['name'] ?? S.of(context).file,
                    ),
                  ),
                );
                if (result == true) {
                  _loadFileDetails();
                }
              } else if (value == 'share') {
                // TODO: Add share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(S.of(context).shareFeatureComingSoon)),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.getPrimary(isDarkMode).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.getPrimary(isDarkMode),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              S.of(context).loadingFileData,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.getTextSecondary(isDarkMode),
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
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 50,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 20),
            Text(
              S.of(context).failedToLoadFileData,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 12),
            Text(
              S
                  .of(context)
                  .fileIdLabel(widget.fileId), // استخدم intl مع المتغير
              style: TextStyle(
                color: AppColors.getTextSecondary(isDarkMode),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadFileDetails,
              icon: Icon(Icons.refresh_rounded, size: 20),
              label: Text(S.of(context).retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getPrimary(isDarkMode),
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

    final fileName = fileData!['name'] ?? S.of(context).noName;
    final fileType = fileData!['category'] ?? S.of(context).unclassified;
    // ✅ الحصول على path من البيانات - قد يكون في path مباشرة أو في originalData
    final filePath = fileData!['path']?.toString() ?? '';
    // ✅ بناء URL بشكل صحيح
    String fileUrl = '';
    if (filePath.isNotEmpty) {
      // ✅ تنظيف path وإزالة الشرطات المزدوجة
      String cleanPath = filePath.replaceAll(r'\', '/').replaceAll('//', '/');
      while (cleanPath.startsWith('/')) {
        cleanPath = cleanPath.substring(1);
      }
      fileUrl = "http://10.0.2.2:8000/$cleanPath";
    }

    print(
      '🖼️ File preview - Name: $fileName, Type: $fileType, Path: $filePath, URL: $fileUrl',
    );

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.getPrimary(isDarkMode),
            AppColors.getPrimary(isDarkMode).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.getPrimary(isDarkMode).withOpacity(0.3),
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
              child: fileUrl.isNotEmpty && fileType.toLowerCase() == "images"
                  ? _buildImagePreview(fileUrl, fileType)
                  : fileUrl.isNotEmpty && fileType.toLowerCase() == "videos"
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
                  S.of(context).image,
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
                color: AppColors.getPrimary(
                  Theme.of(context).brightness == Brightness.dark,
                ),
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
                  S.of(context).video,
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
          Icon(Icons.videocam_rounded, color: Colors.white, size: 50),
          SizedBox(height: 8),
          Text(
            S.of(context).video,
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
        "label": S.of(context).document,
      },
      "images": {
        "icon": Icons.photo_library_rounded,
        "color": Color(0xFFF59E0B),
        "gradient": [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        "iconBg": Color(0xFFF59E0B).withOpacity(0.2),
        "label": S.of(context).image,
      },
      "videos": {
        "icon": Icons.videocam_rounded,
        "color": Color(0xFFEF4444),
        "gradient": [Color(0xFFEF4444), Color(0xFFF87171)],
        "iconBg": Color(0xFFEF4444).withOpacity(0.2),
        "label": S.of(context).video,
      },
      "audio": {
        "icon": Icons.music_note_rounded,
        "color": Color(0xFF8B5CF6),
        "gradient": [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
        "iconBg": Color(0xFF8B5CF6).withOpacity(0.2),
        "label": S.of(context).audio,
      },
    };

    final config =
        categoryConfig[category.toLowerCase()] ??
        {
          "icon": Icons.folder_rounded,
          "color": Color(0xFF6B7280),
          "gradient": [Color(0xFF6B7280), Color(0xFF9CA3AF)],
          "iconBg": Color(0xFF6B7280).withOpacity(0.2),
          "label": S.of(context).file,
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
            S.of(context).failedToLoadPreview,
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
    // ✅ إذا كان ملف/مجلد مشترك في روم، اعرض معلومات محددة فقط
    final isSharedInRoom =
        widget.roomId != null &&
        fileData != null &&
        fileData!['sharedBy'] != null;

    if (isSharedInRoom) {
      return _buildSharedInRoomDetails();
    }

    // ✅ عرض التفاصيل العادية للملفات/المجلدات العادية
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(isDarkMode),
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
                    colors: [
                      AppColors.getPrimary(
                        Theme.of(context).brightness == Brightness.dark,
                      ),
                      AppColors.getPrimary(
                        Theme.of(context).brightness == Brightness.dark,
                      ).withOpacity(0.8),
                    ],
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
                S.of(context).fileInfo,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.getTextPrimary(
                    Theme.of(context).brightness == Brightness.dark,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Details Grid
          _buildDetailItem(
            'folder',
            '📁',
            'التصنيف',
            fileData!['category'] ?? '—',
          ),

          // ✅ عرض الامتداد إذا كان متاحاً
          if (fileData!['extension'] != null)
            _buildDetailItem(
              'extension',
              '📄',
              S.of(context).extension,
              fileData!['extension'] ?? '—',
            ),

          _buildDetailItem(
            'size',
            '📊',
            S.of(context).size,
            fileData!['sizeFormatted'] ?? _formatSize(fileData!['size']) ?? '—',
          ),
          _buildDetailItem(
            'time',
            '🕒',
            S.of(context).createdAt,
            _formatDate(fileData!['createdAt']),
          ),
          _buildDetailItem(
            'edit',
            '✏️',
            S.of(context).modified,
            _formatDate(fileData!['updatedAt'] ?? fileData!['lastModified']),
          ),

          // ✅ عرض معلومات المالك (owner)
          if (fileData!['owner'] != null)
            _buildDetailItem(
              'owner',
              '👤',
              S.of(context).owner,
              fileData!['owner']['name'] ?? fileData!['owner']['email'] ?? '—',
            ),

          _buildDetailItem(
            'description',
            '📝',
            S.of(context).description,
            fileData!['description']?.isNotEmpty == true
                ? fileData!['description']
                : "—",
          ),
          _buildDetailItem(
            'tags',
            '🏷️',
            S.of(context).tags,
            (fileData!['tags'] as List?)?.join(', ') ?? "—",
          ),

          // Shared With Section
          if (fileData!['sharedWith'] != null &&
              fileData!['sharedWith'].isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                _buildDetailItem(
                  'share',
                  '👥',
                  S
                      .of(context)
                      .sharedWithCount(
                        fileData!['sharedWithCount'] ??
                            fileData!['sharedWith'].length,
                      ),
                  fileData!['sharedWith']
                          .map<String>((u) {
                            // ✅ محاولة الحصول على name أو email من user object
                            if (u['user'] != null && u['user'] is Map) {
                              return u['user']['name'] ??
                                  u['user']['email'] ??
                                  '';
                            }
                            return u['name'] ?? u['email'] ?? '';
                          })
                          .where((name) => name.isNotEmpty)
                          .join(', ') ??
                      "—",
                ),
              ],
            ),

          // ✅ عرض حالة الملف
          if (fileData!['isOwner'] != null)
            _buildDetailItem(
              'status',
              fileData!['isOwner'] == true ? '⭐' : '🔗',
              S.of(context).status,
              fileData!['isOwner'] == true
                  ? S.of(context).youAreOwner
                  : S.of(context).sharedFile,
            ),
        ],
      ),
    );
  }

  // ✅ بناء قسم تفاصيل الملف/المجلد المشترك في الروم
  Widget _buildSharedInRoomDetails() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(isDarkMode),
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
                    colors: [
                      AppColors.getPrimary(
                        Theme.of(context).brightness == Brightness.dark,
                      ),
                      AppColors.getPrimary(
                        Theme.of(context).brightness == Brightness.dark,
                      ).withOpacity(0.8),
                    ],
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
                S.of(context).fileInfo,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.getTextPrimary(
                    Theme.of(context).brightness == Brightness.dark,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // ✅ التصنيف
          if (fileData!['category'] != null)
            _buildDetailItem(
              'folder',
              '📁',
              S.of(context).category,
              fileData!['category'] ?? '—',
            ),

          // ✅ الامتداد
          if (fileData!['extension'] != null)
            _buildDetailItem(
              'extension',
              '📄',
              S.of(context).extension,
              fileData!['extension'] ?? '—',
            ),

          // ✅ الحجم
          _buildDetailItem(
            'size',
            '📊',
            S.of(context).size,
            fileData!['sizeFormatted'] ?? _formatSize(fileData!['size']) ?? '—',
          ),

          // ✅ تاريخ الإنشاء (إذا كان متاحاً)
          if (fileData!['createdAt'] != null || fileData!['uploadedAt'] != null)
            _buildDetailItem(
              'time',
              '🕒',
              S.of(context).createdAt,
              _formatDate(fileData!['createdAt'] ?? fileData!['uploadedAt']),
            ),

          // ✅ تاريخ آخر تعديل
          if (fileData!['lastModified'] != null ||
              fileData!['updatedAt'] != null)
            _buildDetailItem(
              'edit',
              '✏️',
              S.of(context).modified,
              _formatDate(fileData!['lastModified'] ?? fileData!['updatedAt']),
            ),

          // ✅ المالك (owner)
          if (fileData!['owner'] != null)
            _buildDetailItem(
              'owner',
              '👤',
              S.of(context).owner,
              fileData!['owner']['name'] ?? fileData!['owner']['email'] ?? '—',
            ),

          // ✅ من شارك الملف/المجلد (sharedBy)
          if (fileData!['sharedBy'] != null)
            _buildDetailItem(
              'sharedBy',
              '🔗',
              S.of(context).sharedBy,
              fileData!['sharedBy']['name'] ??
                  fileData!['sharedBy']['email'] ??
                  '—',
            ),

          // ✅ الوصف (إذا كان متاحاً)
          _buildDetailItem(
            'description',
            '📝',
            S.of(context).description,
            (fileData!['description'] != null &&
                    fileData!['description'].toString().isNotEmpty)
                ? fileData!['description'].toString()
                : "—",
          ),

          // ✅ التاغات (إذا كانت متاحة)
          _buildDetailItem(
            'tags',
            '🏷️',
            S.of(context).tags,
            (fileData!['tags'] != null &&
                    (fileData!['tags'] as List?)?.isNotEmpty == true)
                ? (fileData!['tags'] as List).join(', ')
                : "—",
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
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
        case 'owner':
          return Color(0xFF10B981);
        case 'extension':
          return Color(0xFF8B5CF6);
        case 'status':
          return Color(0xFFF59E0B);
        default:
          return Color(0xFF6B7280);
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
            child: Center(child: Text(emoji, style: TextStyle(fontSize: 18))),
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
                    color: AppColors.getTextSecondary(
                      Theme.of(context).brightness == Brightness.dark,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.getTextPrimary(
                      Theme.of(context).brightness == Brightness.dark,
                    ),
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
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return date.toString();
    }
  }

  // ✅ تنسيق حجم الملف
  String? _formatSize(dynamic size) {
    if (size == null) return null;
    try {
      final bytes = size is int
          ? size
          : (size is num ? size.toInt() : int.tryParse(size.toString()) ?? 0);
      if (bytes == 0) return '0 B';
      const k = 1024;
      const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
      int i = 0;
      double sizeInUnit = bytes.toDouble();

      while (sizeInUnit >= k && i < sizes.length - 1) {
        sizeInUnit /= k;
        i++;
      }

      return '${sizeInUnit.toStringAsFixed(2)} ${sizes[i]}';
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    // تنظيف الملفات المؤقتة إذا أردت
    super.dispose();
  }
}
