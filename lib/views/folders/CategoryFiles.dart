import 'dart:io';
import 'package:filevo/config/api_config.dart';
import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/views/fileViewer/FilesGridView1.dart';
import 'package:filevo/views/fileViewer/VideoViewer.dart';
import 'package:filevo/views/fileViewer/audioPlayer.dart';
import 'package:filevo/views/fileViewer/imageViewer.dart';
import 'package:filevo/views/fileViewer/office_file_opener.dart';
import 'package:filevo/views/fileViewer/pdfViewer.dart';
import 'package:filevo/views/fileViewer/textViewer.dart';
import 'package:flutter/material.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:flutter/painting.dart'; // ✅ لـ PaintingBinding.instance.imageCache
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:filevo/components/FilesListView.dart';

class CategoryPage extends StatefulWidget {
  final String category;
  final Color color;
  final IconData icon;

  const CategoryPage({
    Key? key,
    required this.category,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String? _token;
  bool _isLoadingToken = true;
  bool _isGridView = true;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFiles();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  // دالة تحديد نوع الملف
  String _getFileType(String fileName) {
    final name = fileName.toLowerCase();

    if (name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.gif') ||
        name.endsWith('.bmp') ||
        name.endsWith('.webp')) {
      return 'image';
    } else if (name.endsWith('.mp4') ||
        name.endsWith('.mov') ||
        name.endsWith('.avi') ||
        name.endsWith('.mkv') ||
        name.endsWith('.wmv')) {
      return 'video';
    } else if (name.endsWith('.pdf')) {
      return 'pdf';
    } else if (name.endsWith('.mp3') ||
        name.endsWith('.wav') ||
        name.endsWith('.aac') ||
        name.endsWith('.ogg')) {
      return 'audio';
    } else {
      return 'file';
    }
  }

  // دالة معالجة وتقصير اسم الملف
  String _formatFileName(String fileName) {
    if (fileName.isEmpty) return 'ملف بدون اسم';

    // إصلاح الرموز العربية إذا كانت موجودة
    String fixedName = _fixArabicText(fileName);

    // تقصير الاسم إذا كان طويلاً
    return _truncateFileName(fixedName, 20);
  }

  // دالة إصلاح النصوص العربية
  String _fixArabicText(String text) {
    return text
        .replaceAll('Ã', 'ا')
        .replaceAll('Ã¡', 'أ')
        .replaceAll('Ã¢', 'آ')
        .replaceAll('Ã£', 'ة')
        .replaceAll('Ã¤', 'ء')
        .replaceAll('Ã¥', 'ى')
        .replaceAll('Ã¦', 'ئ')
        .replaceAll('Ã§', 'إ')
        .replaceAll('Ã¨', 'ؤ')
        .replaceAll('Ã©', 'ء')
        .replaceAll('Ãª', 'ئ')
        .replaceAll('Ã«', 'ئ')
        .replaceAll('Ã¬', 'ئ')
        .replaceAll('Ã­', 'ئ')
        .replaceAll('Ã®', 'ئ')
        .replaceAll('Ã¯', 'ئ')
        .replaceAll('Ã°', 'ئ')
        .replaceAll('Ã±', 'ئ')
        .replaceAll('Ã²', 'ئ')
        .replaceAll('Ã³', 'ئ')
        .replaceAll('Ã´', 'ئ')
        .replaceAll('Ãµ', 'ئ')
        .replaceAll('Ã¶', 'ئ')
        .replaceAll('Ã·', 'ئ')
        .replaceAll('Ã¸', 'ئ')
        .replaceAll('Ã¹', 'ئ')
        .replaceAll('Ãº', 'ئ')
        .replaceAll('Ã»', 'ئ')
        .replaceAll('Ã¼', 'ئ')
        .replaceAll('Ã½', 'ئ')
        .replaceAll('Ã¾', 'ئ')
        .replaceAll('Ã¿', 'ئ');
  }

  // دالة تقصير اسم الملف
  String _truncateFileName(String fileName, int maxLength) {
    if (fileName.length <= maxLength) return fileName;

    // البحث عن آخر مسافة قبل الحد الأقصى لتجنب قطع الكلمات
    int lastSpace = fileName.lastIndexOf(' ', maxLength);
    if (lastSpace > maxLength ~/ 2) {
      return '${fileName.substring(0, lastSpace)}...';
    }

    return '${fileName.substring(0, maxLength)}...';
  }

  Future<void> _loadTokenAndFiles() async {
    try {
      _token = await StorageService.getToken();
      setState(() {
        _isLoadingToken = false;
      });

      if (_token != null && _token!.isNotEmpty) {
        final fileController = Provider.of<FileController>(
          context,
          listen: false,
        );
        await fileController.getFilesByCategory(
          category: widget.category,
          token: _token!,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).mustLogin),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingToken = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${S.of(context).errorFetchingData}: ${e.toString()}',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String getFileUrl(String path) {
    print('Original path: $path');

    if (path.startsWith('http')) {
      return path;
    }

    String cleanPath = path.replaceAll(r'\', '/').replaceAll('//', '/');
    while (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    final base = ApiConfig.baseUrl.replaceAll('/api/v1', '');
    String baseClean = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    String finalUrl = '$baseClean/$cleanPath';

    print('Generated URL: $finalUrl');
    return finalUrl;
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  bool _isValidPdf(List<int> bytes) {
    try {
      if (bytes.length < 4) return false;
      final signature = String.fromCharCodes(bytes.sublist(0, 4));
      return signature == '%PDF';
    } catch (e) {
      return false;
    }
  }

  void _openAsTextFile(String url, String fileName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).openFileAsText(fileName)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    final maxHeight = 120.0;
    final minHeight = 80.0;
    final scrollRange = 100.0;

    double height = maxHeight;
    double opacity = 1.0;

    if (_scrollOffset > 0) {
      height =
          maxHeight -
          (_scrollOffset / scrollRange * (maxHeight - minHeight)).clamp(
            0.0,
            maxHeight - minHeight,
          );
      opacity = 1.0 - (_scrollOffset / scrollRange).clamp(0.0, 1.0);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [widget.color, widget.color.withOpacity(0.8)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -50,
            top: -50,
            child: Opacity(
              opacity: 0.1,
              child: Icon(widget.icon, size: 150, color: Colors.white),
            ),
          ),
          Center(
            child: Opacity(
              opacity: opacity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: height * 0.4, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileCountCard(int fileCount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.insert_drive_file,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'عدد الملفات',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              fileCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: const Color(0xff28336f),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      widget.icon,
                      color: Colors.white.withOpacity(0.7),
                      size: 40,
                    ),
                  ),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                    strokeWidth: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'جاري التحميل...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      backgroundColor: const Color(0xff28336f),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red.withOpacity(0.7),
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                error,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadTokenAndFiles,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: Text(S.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.folder_open,
            color: Colors.white.withOpacity(0.5),
            size: 60,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          S.of(context).noFilesInCategory,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loadTokenAndFiles,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: Text(S.of(context).updated),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileController = Provider.of<FileController>(context);

    if (_isLoadingToken) {
      return _buildLoadingState();
    }

    if (_token == null || _token!.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xff28336f),
        appBar: AppBar(
          backgroundColor: widget.color,
          title: Text(widget.category),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Text(
            S.of(context).loginRequiredToAccessFiles,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xff28336f),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: widget.color,
              expandedHeight: 120,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildAnimatedHeader(),
                title: Text(
                  widget.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadTokenAndFiles,
                ),
                IconButton(
                  icon: Icon(
                    _isGridView ? Icons.list : Icons.grid_view,
                    color: Colors.white,
                  ),
                  tooltip: _isGridView ? 'عرض كقائمة' : 'عرض كشبكة',
                  onPressed: () {
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                  },
                ),
              ],
            ),
          ];
        },
        body: fileController.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : fileController.errorMessage != null
            ? _buildErrorState(fileController.errorMessage!)
            : fileController.uploadedFiles.isEmpty
            ? _buildEmptyState()
            : Container(
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Column(
                  children: [
                    _buildFileCountCard(fileController.uploadedFiles.length),
                    Expanded(
                      child: Consumer<FileController>(
                        builder: (context, fileController, child) {
                          // ✅ استخدام Consumer للاستماع للتغييرات في FileController
                          return _isGridView
                              ? FilesGrid(
                                  files: fileController.uploadedFiles
                                      .where(
                                        (f) =>
                                            f['path'] != null &&
                                            (f['path'] as String).isNotEmpty,
                                      )
                                      .map((f) {
                                        final fileName =
                                            f['name']?.toString() ??
                                            'ملف بدون اسم';
                                        final filePath =
                                            f['path']?.toString() ?? '';
                                        final formattedName = _formatFileName(
                                          fileName,
                                        );

                                        // ✅ حساب updatedAtTimestamp أولاً
                                        final updatedAtTimestamp =
                                            f['updatedAtTimestamp'] ??
                                            (f['updatedAt'] != null
                                                ? (f['updatedAt'] is String
                                                      ? DateTime.parse(
                                                          f['updatedAt'],
                                                        ).millisecondsSinceEpoch
                                                      : (f['updatedAt']
                                                                as DateTime)
                                                            .millisecondsSinceEpoch)
                                                : DateTime.now()
                                                      .millisecondsSinceEpoch);

                                        // ✅ إضافة cache busting للصور باستخدام updatedAtTimestamp
                                        String imageUrl = getFileUrl(filePath);
                                        if (_getFileType(fileName) == 'image') {
                                          // ✅ استخدام updatedAtTimestamp من البيانات لضمان cache busting صحيح
                                          final urlWithoutParams = imageUrl
                                              .split('?')
                                              .first;
                                          imageUrl =
                                              '$urlWithoutParams?v=$updatedAtTimestamp';
                                        }

                                        return {
                                          'name': formattedName,
                                          'url':
                                              imageUrl, // ✅ URL مع cache busting
                                          'type': _getFileType(fileName),
                                          'size': _formatFileSize(
                                            f['size']?.toString() ?? '0',
                                          ),
                                          'createdAt': f['createdAt'],
                                          'updatedAt': f['updatedAt'],
                                          'updatedAtTimestamp':
                                              updatedAtTimestamp, // ✅ إضافة updatedAtTimestamp للاستخدام في ValueKey
                                          'path': filePath,
                                          'originalData': f,
                                          'originalName': fileName,
                                        };
                                      })
                                      .toList(),
                                  onFileTap: (file) {
                                    print('Tapped file: ${file['name']}');
                                    final originalData =
                                        file['originalData'] ?? file;
                                    print('Original data: $originalData');
                                    _handleFileTap(originalData, context);
                                  },
                                  onFileRemoved: () async {
                                    // ✅ إعادة تحميل الملفات بعد نقل الملف
                                    if (mounted &&
                                        _token != null &&
                                        _token!.isNotEmpty) {
                                      final fileController =
                                          Provider.of<FileController>(
                                            context,
                                            listen: false,
                                          );
                                      // ✅ إعادة جلب الملفات من API (من الجذر فقط)
                                      await fileController.getFilesByCategory(
                                        category: widget.category,
                                        token: _token!,
                                        parentFolderId:
                                            null, // ✅ فقط الملفات من الجذر
                                      );
                                      if (mounted) {
                                        setState(() {}); // ✅ تحديث الواجهة
                                      }
                                    }
                                  },
                                  onFileUpdated: () {
                                    // ✅ إعادة تحميل الملفات بعد تحديث الملف
                                    // ✅ استخدام Future.microtask لتأجيل الاستدعاء وتجنب التعليق
                                    Future.microtask(() async {
                                      // ✅ مسح cache الصور قبل إعادة التحميل
                                      PaintingBinding.instance.imageCache
                                          .clear();
                                      PaintingBinding.instance.imageCache
                                          .clearLiveImages();
                                      print(
                                        '✅ [CategoryFiles] Image cache cleared, reloading files...',
                                      );
                                      if (mounted &&
                                          _token != null &&
                                          _token!.isNotEmpty) {
                                        try {
                                          final fileController =
                                              Provider.of<FileController>(
                                                context,
                                                listen: false,
                                              );
                                          await fileController
                                              .getFilesByCategory(
                                                category: widget.category,
                                                token: _token!,
                                                parentFolderId: null,
                                              );
                                          if (mounted) {
                                            setState(() {}); // ✅ تحديث الواجهة
                                          }
                                        } catch (e) {
                                          print(
                                            '❌ [CategoryFiles] Error reloading files: $e',
                                          );
                                        }
                                      }
                                    });
                                  },
                                )
                              : FilesListView(
                                  items: fileController.uploadedFiles.map((f) {
                                    final fileName =
                                        f['name']?.toString() ?? 'ملف بدون اسم';
                                    final formattedName = _formatFileName(
                                      fileName,
                                    );

                                    return {
                                      'title': formattedName,
                                      'size': _formatFileSize(
                                        f['size']?.toString() ?? '0',
                                      ),
                                      'path': f['path'],
                                      'createdAt': f['createdAt'],
                                      'originalName': fileName,
                                      '_id': f['_id']?.toString(),
                                      'originalData': f,
                                    };
                                  }).toList(),
                                  onItemTap: (item) =>
                                      _handleFileTap(item, context),
                                  onFileRemoved: () async {
                                    // ✅ إعادة تحميل الملفات بعد نقل الملف
                                    if (mounted &&
                                        _token != null &&
                                        _token!.isNotEmpty) {
                                      final fileController =
                                          Provider.of<FileController>(
                                            context,
                                            listen: false,
                                          );
                                      // ✅ إعادة جلب الملفات من API
                                      await fileController.getFilesByCategory(
                                        category: widget.category,
                                        token: _token!,
                                        parentFolderId:
                                            null, // ✅ فقط الملفات من الجذر
                                      );
                                      if (mounted) {
                                        setState(() {}); // ✅ تحديث الواجهة
                                      }
                                    }
                                  },
                                );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _handleFileTap(
    Map<String, dynamic> file,
    BuildContext context,
  ) async {
    print('Handling tap for file: $file');

    final filePath = file['path'] as String?;
    if (filePath == null || filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).fileLinkNotAvailable),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    print(file['originalData']);
    // ✅ استخدام الاسم الأصلي إذا كان متوفراً
    final originalName = file['name'] as String?;
    print('Original name: $originalName');
    final name = (originalName ?? file['title']?.toString() ?? '')
        .toLowerCase();
    print('Name (lowercase): $name');
    final fileName =
        originalName ?? file['title']?.toString() ?? 'ملف بدون اسم';

    // ✅ الحصول على extension من عدة مصادر
    String? getFileExtension() {
      // 1. من originalData إذا كان متوفراً
      if (file['originalData'] is Map) {
        final originalData = file['originalData'] as Map<String, dynamic>;
        final origName = originalData['name']?.toString();
        if (origName != null && origName.contains('.')) {
          return origName
              .substring(origName.lastIndexOf('.') + 1)
              .toLowerCase();
        }
        // 2. من contentType أو mimeType
        final contentType =
            originalData['contentType']?.toString() ??
            originalData['mimeType']?.toString();
        if (contentType != null) {
          if (contentType.contains('image')) {
            if (contentType.contains('jpeg')) return 'jpg';
            if (contentType.contains('png')) return 'png';
            if (contentType.contains('gif')) return 'gif';
            if (contentType.contains('webp')) return 'webp';
            if (contentType.contains('bmp')) return 'bmp';
          }
          if (contentType.contains('video')) {
            if (contentType.contains('mp4')) return 'mp4';
            if (contentType.contains('quicktime')) return 'mov';
            if (contentType.contains('avi')) return 'avi';
          }
          if (contentType.contains('audio')) {
            if (contentType.contains('mpeg')) return 'mp3';
            if (contentType.contains('wav')) return 'wav';
            if (contentType.contains('aac')) return 'aac';
          }
          if (contentType.contains('pdf')) return 'pdf';
        }
      }
      // 3. من الاسم
      if (name.contains('.')) {
        return name.substring(name.lastIndexOf('.') + 1);
      }
      // 4. من filePath
      if (filePath.contains('.')) {
        return filePath.substring(filePath.lastIndexOf('.') + 1).toLowerCase();
      }
      return null;
    }

    final extension = getFileExtension();
    print('File extension: $extension');

    final url = getFileUrl(filePath);

    if (!_isValidUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).invalidUrl),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _showLoadingDialog(context);

    try {
      final client = http.Client();
      final response = await client.get(
        Uri.parse(url),
        headers: {'Range': 'bytes=0-511'},
      );
      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 206) {
        final bytes = response.bodyBytes;
        final isPdf = _isValidPdf(bytes);
        final contentType =
            response.headers['content-type']?.toLowerCase() ?? '';

        // ✅ التحقق من نوع الملف من extension أو contentType
        bool isImageFile() {
          if (extension != null) {
            return [
              'jpg',
              'jpeg',
              'png',
              'gif',
              'bmp',
              'webp',
            ].contains(extension);
          }
          return contentType.startsWith('image/');
        }

        bool isVideoFile() {
          if (extension != null) {
            return [
              'mp4',
              'mov',
              'mkv',
              'avi',
              'wmv',
              'webm',
              'm4v',
              '3gp',
              'flv',
            ].contains(extension);
          }
          return contentType.startsWith('video/');
        }

        bool isAudioFile() {
          if (extension != null) {
            return [
              'mp3',
              'wav',
              'aac',
              'ogg',
              'm4a',
              'wma',
              'flac',
            ].contains(extension);
          }
          return contentType.startsWith('audio/');
        }

        // PDF
        if ((extension == 'pdf' || name.endsWith('.pdf')) && isPdf) {
          print('Opening PDF: $fileName from $url');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PdfViewerPage(pdfUrl: url, fileName: fileName),
            ),
          );
        }
        // فيديو
        else if (isVideoFile()) {
          print('Opening Video: $fileName from $url');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VideoViewer(url: url)),
          );
        }
        // صورة
        else if (isImageFile()) {
          print('Opening Image: $fileName from $url');
          final fileId =
              file['_id']?.toString() ??
              (file['originalData'] is Map
                  ? file['originalData']['_id']?.toString()
                  : null);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageViewer(imageUrl: url, fileId: fileId),
            ),
          );
        }
        // نص
        else if (TextViewerPage.isTextFile(fileName) ||
            contentType.startsWith('text/')) {
          _showLoadingDialog(context);
          try {
            // ✅ إضافة timestamp للـ URL لتجنب الـ cache
            final cacheBustingUrl = url.contains('?')
                ? '$url&_t=${DateTime.now().millisecondsSinceEpoch}'
                : '$url?_t=${DateTime.now().millisecondsSinceEpoch}';

            final fullResponse = await http.get(Uri.parse(cacheBustingUrl));
            if (mounted) Navigator.pop(context);
            if (fullResponse.statusCode == 200) {
              final tempDir = await getTemporaryDirectory();

              // ✅ استخراج fileId من بيانات الملف
              final fileId =
                  file['_id']?.toString() ??
                  (file['originalData'] is Map
                      ? file['originalData']['_id']?.toString()
                      : null);

              // ✅ استخدام اسم الملف الأصلي فقط (بدون timestamp) للعرض
              // ✅ لكن نستخدم fileId في اسم الملف المؤقت لتجنب التعارض
              final tempFileName = fileId != null
                  ? '${fileId}_$fileName'
                  : fileName;
              final tempFile = File('${tempDir.path}/$tempFileName');

              // ✅ حذف الملف المؤقت القديم إذا كان موجوداً (نفس fileId)
              if (fileId != null) {
                try {
                  final oldFiles = tempDir
                      .listSync()
                      .where(
                        (f) =>
                            f is File &&
                            f.path.contains('${fileId}_') &&
                            f.path != tempFile.path,
                      )
                      .cast<File>();
                  for (final oldFile in oldFiles) {
                    try {
                      await oldFile.delete();
                      print('🗑️ تم حذف الملف المؤقت القديم: ${oldFile.path}');
                    } catch (e) {
                      print('⚠️ خطأ في حذف ملف مؤقت: $e');
                    }
                  }
                } catch (e) {
                  print('⚠️ خطأ في حذف الملفات المؤقتة القديمة: $e');
                }
              }

              // ✅ كتابة الملف المؤقت
              await tempFile.writeAsBytes(fullResponse.bodyBytes);

              // ✅ التحقق من وجود الملف قبل فتحه
              if (!await tempFile.exists()) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(S.of(context).failedToCreateTempFile),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              // ✅ الانتظار حتى يتم إغلاق TextViewerPage ثم إعادة تحميل الملفات
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TextViewerPage(
                    filePath: tempFile.path,
                    fileName: fileName, // ✅ استخدام الاسم الأصلي فقط
                    fileId: fileId,
                    fileUrl: url,
                  ),
                ),
              );

              // ✅ إذا تم حفظ الملف (result == true)، أعد تحميل قائمة الملفات
              if (result == true &&
                  mounted &&
                  _token != null &&
                  _token!.isNotEmpty) {
                final fileController = Provider.of<FileController>(
                  context,
                  listen: false,
                );
                await fileController.getFilesByCategory(
                  category: widget.category,
                  token: _token!,
                  parentFolderId: null,
                );
                if (mounted) {
                  setState(() {}); // ✅ تحديث الواجهة
                }
              }
            } else {
              // ✅ إذا فشل التحميل، عرض رسالة خطأ
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      S
                          .of(context)
                          .failedToLoadFileStatus(
                            fullResponse.statusCode.toString(),
                          ),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } catch (e) {
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context).errorOpeningFile(e.toString())),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
        // صوت
        else if (isAudioFile()) {
          print('Opening Audio: $fileName from $url');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AudioPlayerPage(audioUrl: url, fileName: fileName),
            ),
          );
        }
        // ✅ باقي الملفات (Office, ZIP, إلخ) - تفتح خارج التطبيق
        else {
          // ✅ إظهار Loading Dialog للملفات الخارجية
          _showLoadingDialog(context);

          await OfficeFileOpener.openAnyFile(
            url: url,
            context: context,
            token: _token,
            fileName: fileName, // ✅ تمرير اسم الملف الأصلي
            closeLoadingDialog: true, // ✅ إغلاق Loading Dialog تلقائياً
            onProgress: (received, total) {
              // ✅ يمكن إضافة Progress indicator هنا لاحقاً
              if (total > 0) {
                final percent = (received / total * 100).toStringAsFixed(0);
                print("📥 Downloading: $percent% ($received / $total bytes)");
              }
            },
          );

          // ✅ لا حاجة لإغلاق Loading Dialog يدوياً - يتم إغلاقه تلقائياً في OfficeFileOpener
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S
                  .of(context)
                  .fileNotAvailableError(response.statusCode.toString()),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorLoadingFile(e.toString())),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPdfErrorDialog(String url, String fileName, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).unsupportedFile),
        content: Text(S.of(context).fileNotValidPdf),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openAsTextFile(url, fileName);
            },
            child: Text(S.of(context).openAsText),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'جاري تحميل الملف...',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFileSize(String size) {
    try {
      final bytes = int.tryParse(size) ?? 0;
      if (bytes < 1024) return '$bytes bytes';
      if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    } catch (e) {
      return size;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}
