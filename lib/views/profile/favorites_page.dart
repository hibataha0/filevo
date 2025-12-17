// views/favorites_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/views/fileViewer/FilesGridView1.dart';
import 'package:filevo/config/api_config.dart';
import 'package:filevo/views/fileViewer/VideoViewer.dart';
import 'package:filevo/views/fileViewer/audioPlayer.dart';
import 'package:filevo/views/fileViewer/imageViewer.dart';
import 'package:filevo/views/fileViewer/office_file_opener.dart';
import 'package:filevo/views/fileViewer/pdfViewer.dart';
import 'package:filevo/views/fileViewer/textViewer.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  String? _token;
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = true;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _loadTokenAndFiles();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadTokenAndFiles() async {
    _token = await StorageService.getToken();
    if (_token != null && mounted) {
      final controller = Provider.of<FileController>(context, listen: false);
      await controller.getStarredFiles(token: _token!, limit: 20);
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreFiles();
      }
    });
  }

  Future<void> _loadMoreFiles() async {
    if (_token != null && mounted) {
      final controller = Provider.of<FileController>(context, listen: false);
      if (!controller.isLoading) {
        await controller.getStarredFiles(
          token: _token!,
          limit: 20,
          loadMore: true,
        );
      }
    }
  }

  Future<void> _refreshFiles() async {
    await _loadTokenAndFiles();
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
    if (fileName.length > 20) {
      return '${fileName.substring(0, 17)}...';
    }
    return fileName;
  }

  String getFileUrl(String path) {
    if (path.startsWith('http')) return path;

    try {
      String cleanPath = path.replaceAll(r'\', '/').replaceAll('//', '/');
      while (cleanPath.startsWith('/')) cleanPath = cleanPath.substring(1);

      final base = ApiConfig.baseUrl.replaceAll('/api/v1', '');
      final baseClean = base.endsWith('/')
          ? base.substring(0, base.length - 1)
          : base;

      if (cleanPath.startsWith('/')) cleanPath = cleanPath.substring(1);

      return '$baseClean/$cleanPath';
    } catch (e) {
      return path;
    }
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
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

  Future<void> _handleFileTap(
    Map<String, dynamic> file,
    BuildContext context,
  ) async {
    final filePath = file['path'] as String?;
    if (filePath == null || filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).fileLinkNotAvailable),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final originalName = file['name'] as String? ?? 'ملف بدون اسم';
    final url = getFileUrl(filePath);

    if (!_isValidUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).invalidUrl),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

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

        if (originalName.endsWith('.pdf') && !isPdf) {
          _showPdfErrorDialog(url, originalName, originalName);
          return;
        }

        if (originalName.endsWith('.pdf') && isPdf) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PdfViewerPage(pdfUrl: url, fileName: originalName),
            ),
          );
        } else if (originalName.endsWith('.mp4') ||
            originalName.endsWith('.mov') ||
            originalName.endsWith('.mkv') ||
            originalName.endsWith('.avi') ||
            originalName.endsWith('.wmv')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VideoViewer(url: url)),
          );
        } else if (originalName.endsWith('.jpg') ||
            originalName.endsWith('.jpeg') ||
            originalName.endsWith('.png') ||
            originalName.endsWith('.gif') ||
            originalName.endsWith('.bmp') ||
            originalName.endsWith('.webp')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ImageViewer(imageUrl: url)),
          );
        } else if (TextViewerPage.isTextFile(originalName)) {
          final fullResponse = await http.get(Uri.parse(url));
          if (!mounted) return;
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$originalName');
          await tempFile.writeAsBytes(fullResponse.bodyBytes);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TextViewerPage(
                filePath: tempFile.path,
                fileName: originalName,
              ),
            ),
          );
        } else if (originalName.endsWith('.mp3') ||
            originalName.endsWith('.wav') ||
            originalName.endsWith('.aac') ||
            originalName.endsWith('.ogg')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AudioPlayerPage(audioUrl: url, fileName: originalName),
            ),
          );
        } else {
          await OfficeFileOpener.openAnyFile(
            url: url,
            context: context,
            token: _token,
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
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).errorLoadingFile(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).openFileAsText(fileName))),
              );
            },
            child: Text(S.of(context).openAsText),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(String size) {
    try {
      final bytes = int.tryParse(size) ?? 0;
      if (bytes < 1024) return '$bytes بايت';
      if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} ك.ب';
      return '${(bytes / 1048576).toStringAsFixed(1)} م.ب';
    } catch (e) {
      return size;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ استخدام Consumer بدل Provider.of عشان يتحدث تلقائياً
    return Consumer<FileController>(
      builder: (context, fileController, child) {
        // ✅ القائمة تيجي مباشرة من الـ controller
        final starredFiles = fileController.starredFiles;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              S.of(context).favoriteFiles,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xff28336f),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isGridView ? Icons.list_rounded : Icons.grid_view_rounded,
                ),
                onPressed: () => setState(() => _isGridView = !_isGridView),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _refreshFiles,
              ),
            ],
          ),
          body: SmartRefresher(
            controller: _refreshController,
            onRefresh: () async {
              await _refreshFiles();
              _refreshController.refreshCompleted();
            },
            header: const WaterDropHeader(),
            child: fileController.isLoading && starredFiles.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xff28336f)),
                  )
                : starredFiles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_border_rounded,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          S.of(context).noFavoriteFiles,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          S.of(context).addFilesToFavorites,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : FilesGrid(
                    // ✅ القائمة تيجي من الـ controller مباشرة
                    files: starredFiles.map((f) {
                      final fileName = f['name'] ?? 'ملف بدون اسم';
                      final filePath = f['path'] ?? '';
                      return {
                        'name': _formatFileName(fileName),
                        'url': getFileUrl(filePath),
                        'type': _getFileType(fileName),
                        'size': f['size']?.toString() ?? '0',
                        'originalData': f,
                      };
                    }).toList(),
                    onFileTap: (file) =>
                        _handleFileTap(file['originalData'], context),
                  ),
          ),
        );
      },
    );
  }
}
