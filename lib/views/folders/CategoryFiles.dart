import 'dart:io';
import 'package:filevo/config/api_config.dart';
import 'package:filevo/constants/app_colors.dart';
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
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:filevo/components/FilesListView.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

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
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    _loadViewPreference();
    _loadTokenAndFiles();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGridView = prefs.getBool('isGridView') ?? true;
    });
  }

  Future<void> _saveViewPreference(bool isGridView) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGridView', isGridView);
  }

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

  String _formatFileName(String fileName) {
    if (fileName.isEmpty) return 'ملف بدون اسم';
    String fixedName = _fixArabicText(fileName);
    return _truncateFileName(fixedName, 20);
  }

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

  String _truncateFileName(String fileName, int maxLength) {
    if (fileName.length <= maxLength) return fileName;
    int lastSpace = fileName.lastIndexOf(' ', maxLength);
    if (lastSpace > maxLength ~/ 2) {
      return '${fileName.substring(0, lastSpace)}...';
    }
    return '${fileName.substring(0, maxLength)}...';
  }

  Future<void> _loadTokenAndFiles({bool fromRefresh = false}) async {
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
      if (fromRefresh) {
        _refreshController.refreshCompleted();
      }
    } catch (e) {
      setState(() {
        _isLoadingToken = false;
      });
      if (fromRefresh) {
        _refreshController.refreshFailed();
      }
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

  Widget _buildHeader(int fileCount) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: AppColors.lightAppBar,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(children: []),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(
                  _isGridView ? Icons.list : Icons.grid_view,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                  _saveViewPreference(_isGridView);
                },
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            widget.category,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  // ✅ Shimmer للـ Grid View
  Widget _buildGridShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 80,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ Shimmer للـ List View
  Widget _buildListShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      color: const Color(0xff28336f),
      child: Center(
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
    return Center(
      child: Column(
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
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
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
      ),
    );
  }

  Widget _buildFileContent(FileController fileController) {
    // ✅ استخدام Shimmer بدلاً من CircularProgressIndicator
    if (fileController.isLoading) {
      return _isGridView ? _buildGridShimmer() : _buildListShimmer();
    }

    if (fileController.errorMessage != null) {
      return _buildErrorState(fileController.errorMessage!);
    }

    if (fileController.uploadedFiles.isEmpty) {
      return _buildEmptyState();
    }

    return Consumer<FileController>(
      builder: (context, fileController, child) {
        return _isGridView
            ? FilesGrid(
                files: fileController.uploadedFiles
                    .where(
                      (f) =>
                          f['path'] != null && (f['path'] as String).isNotEmpty,
                    )
                    .map((f) {
                      final fileName = f['name']?.toString() ?? 'ملف بدون اسم';
                      final filePath = f['path']?.toString() ?? '';
                      final formattedName = _formatFileName(fileName);

                      final updatedAtTimestamp =
                          f['updatedAtTimestamp'] ??
                          (f['updatedAt'] != null
                              ? (f['updatedAt'] is String
                                    ? DateTime.parse(
                                        f['updatedAt'],
                                      ).millisecondsSinceEpoch
                                    : (f['updatedAt'] as DateTime)
                                          .millisecondsSinceEpoch)
                              : DateTime.now().millisecondsSinceEpoch);

                      String imageUrl = getFileUrl(filePath);
                      if (_getFileType(fileName) == 'image') {
                        final urlWithoutParams = imageUrl.split('?').first;
                        imageUrl = '$urlWithoutParams?v=$updatedAtTimestamp';
                      }

                      return {
                        'name': formattedName,
                        'url': imageUrl,
                        'type': _getFileType(fileName),
                        'size': _formatFileSize(f['size']?.toString() ?? '0'),
                        'createdAt': f['createdAt'],
                        'updatedAt': f['updatedAt'],
                        'updatedAtTimestamp': updatedAtTimestamp,
                        'path': filePath,
                        'originalData': f,
                        'originalName': fileName,
                      };
                    })
                    .toList(),
                onFileTap: (file) {
                  print('Tapped file: ${file['name']}');
                  final originalData = file['originalData'] ?? file;
                  print('Original data: $originalData');
                  _handleFileTap(originalData, context);
                },
                onFileRemoved: () async {
                  if (mounted && _token != null && _token!.isNotEmpty) {
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
                      setState(() {});
                    }
                  }
                },
                onFileUpdated: () {
                  Future.microtask(() async {
                    PaintingBinding.instance.imageCache.clear();
                    PaintingBinding.instance.imageCache.clearLiveImages();
                    print(
                      '✅ [CategoryFiles] Image cache cleared, reloading files...',
                    );
                    if (mounted && _token != null && _token!.isNotEmpty) {
                      try {
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
                          setState(() {});
                        }
                      } catch (e) {
                        print('❌ [CategoryFiles] Error reloading files: $e');
                      }
                    }
                  });
                },
              )
            : FilesListView(
                items: fileController.uploadedFiles.map((f) {
                  final fileName = f['name']?.toString() ?? 'ملف بدون اسم';
                  final formattedName = _formatFileName(fileName);

                  return {
                    'title': formattedName,
                    'size': _formatFileSize(f['size']?.toString() ?? '0'),
                    'path': f['path'],
                    'createdAt': f['createdAt'],
                    'originalName': fileName,
                    '_id': f['_id']?.toString(),
                    'originalData': f,
                  };
                }).toList(),
                onItemTap: (item) => _handleFileTap(item, context),
                onFileRemoved: () async {
                  if (mounted && _token != null && _token!.isNotEmpty) {
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
                      setState(() {});
                    }
                  }
                },
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileController = Provider.of<FileController>(context);

    // ✅ عرض Shimmer أثناء تحميل التوكن
    if (_isLoadingToken) {
      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(0)),
            SliverToBoxAdapter(
              child: _isGridView ? _buildGridShimmer() : _buildListShimmer(),
            ),
          ],
        ),
      );
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
      backgroundColor: AppColors.lightBackground,
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: false,
        header: const WaterDropHeader(),
        onRefresh: () async => _loadTokenAndFiles(fromRefresh: true),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(fileController.uploadedFiles.length),
            ),
            SliverToBoxAdapter(child: _buildFileContent(fileController)),
          ],
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

    final originalName = file['name'] as String?;
    print('Original name: $originalName');
    final name = (originalName ?? file['title']?.toString() ?? '')
        .toLowerCase();
    print('Name (lowercase): $name');
    final fileName =
        originalName ?? file['title']?.toString() ?? 'ملف بدون اسم';

    String? getFileExtension() {
      if (file['originalData'] is Map) {
        final originalData = file['originalData'] as Map<String, dynamic>;
        final origName = originalData['name']?.toString();
        if (origName != null && origName.contains('.')) {
          return origName
              .substring(origName.lastIndexOf('.') + 1)
              .toLowerCase();
        }
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
      if (name.contains('.')) {
        return name.substring(name.lastIndexOf('.') + 1);
      }
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

        if ((extension == 'pdf' || name.endsWith('.pdf')) && isPdf) {
          print('Opening PDF: $fileName from $url');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PdfViewerPage(pdfUrl: url, fileName: fileName),
            ),
          );
        } else if (isVideoFile()) {
          print('Opening Video: $fileName from $url');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VideoViewer(url: url)),
          );
        } else if (isImageFile()) {
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
        } else if (TextViewerPage.isTextFile(fileName) ||
            contentType.startsWith('text/')) {
          _showLoadingDialog(context);
          try {
            final cacheBustingUrl = url.contains('?')
                ? '$url&_t=${DateTime.now().millisecondsSinceEpoch}'
                : '$url?_t=${DateTime.now().millisecondsSinceEpoch}';

            final fullResponse = await http.get(Uri.parse(cacheBustingUrl));
            if (mounted) Navigator.pop(context);
            if (fullResponse.statusCode == 200) {
              final tempDir = await getTemporaryDirectory();

              final fileId =
                  file['_id']?.toString() ??
                  (file['originalData'] is Map
                      ? file['originalData']['_id']?.toString()
                      : null);

              final tempFileName = fileId != null
                  ? '${fileId}_$fileName'
                  : fileName;
              final tempFile = File('${tempDir.path}/$tempFileName');

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

              await tempFile.writeAsBytes(fullResponse.bodyBytes);

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

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TextViewerPage(
                    filePath: tempFile.path,
                    fileName: fileName,
                    fileId: fileId,
                    fileUrl: url,
                  ),
                ),
              );

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
                  setState(() {});
                }
              }
            } else {
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
        } else if (isAudioFile()) {
          print('Opening Audio: $fileName from $url');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AudioPlayerPage(audioUrl: url, fileName: fileName),
            ),
          );
        } else {
          _showLoadingDialog(context);

          await OfficeFileOpener.openAnyFile(
            url: url,
            context: context,
            token: _token,
            fileName: fileName,
            closeLoadingDialog: true,
            onProgress: (received, total) {
              if (total > 0) {
                final percent = (received / total * 100).toStringAsFixed(0);
                print("📥 Downloading: $percent% ($received / $total bytes)");
              }
            },
          );
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
