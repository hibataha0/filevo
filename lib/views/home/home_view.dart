import 'package:filevo/components/FilesGridView.dart';
import 'package:filevo/components/FilesListView.dart';
import 'package:filevo/components/ViewToggleButtons.dart';
import 'package:filevo/responsive.dart';
import 'package:filevo/views/home/components/StorageCard.dart';
import 'package:flutter/material.dart';
import 'package:filevo/constants/app_colors.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:filevo/services/folders_service.dart';
import 'package:filevo/services/file_service.dart';
import 'package:filevo/config/api_config.dart';
import 'package:filevo/views/folders/folders_view.dart';
import 'package:filevo/views/folders/folder_contents_page.dart';
import 'package:filevo/views/fileViewer/FilesGridView1.dart';
import 'package:filevo/views/fileViewer/VideoViewer.dart';
import 'package:filevo/views/fileViewer/audioPlayer.dart';
import 'package:filevo/views/fileViewer/imageViewer.dart';
import 'package:filevo/views/fileViewer/pdfViewer.dart';
import 'package:filevo/views/fileViewer/textViewer.dart';
import 'package:filevo/views/fileViewer/office_file_opener.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeView extends StatefulWidget {
  final VoidCallback? onNavigateToFolders;

  const HomeView({super.key, this.onNavigateToFolders});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool isFilesGridView = true;
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentFolders = [];
  List<Map<String, dynamic>> _recentFiles = [];
  String? _errorMessage;

  final FolderService _folderService = FolderService();
  final FileService _fileService = FileService();
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    _loadRecentData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ جلب المجلدات الحديثة (نحصل على 10 لكن نعرض 3 فقط)
      final foldersResult = await _folderService.getRecentFolders(limit: 10);
      if (!mounted) return;

      if (foldersResult['success'] == true) {
        final folders = List<Map<String, dynamic>>.from(
          foldersResult['folders'] ?? [],
        );
        if (mounted) {
          setState(() {
            // ✅ عرض آخر 3 مجلدات فقط
            _recentFolders = folders.take(3).map((folder) {
              final size = folder['size'];
              final filesCount = folder['filesCount'];
              return {
                'title': folder['name'] ?? S.of(context).noName,
                'name': folder['name'] ?? S.of(context).noName,
                'type': 'folder', // ✅ إضافة type للمجلدات
                'fileCount': (filesCount != null && filesCount is int)
                    ? filesCount
                    : (filesCount != null && filesCount is num)
                    ? filesCount.toInt()
                    : 0,
                'size': _formatBytes(
                  (size != null && size is int)
                      ? size
                      : (size != null && size is num)
                      ? size.toInt()
                      : 0,
                ),
                'folderId': folder['_id'],
                'originalData': folder,
                'folderData': folder, // ✅ إضافة folderData للمجلدات
              };
            }).toList();
          });
        }
      }

      // ✅ جلب الملفات الحديثة (عرض الكل)
      final filesResult = await _fileService.getRecentFiles(limit: 10);
      if (!mounted) return;

      if (filesResult['success'] == true) {
        final files = List<Map<String, dynamic>>.from(
          filesResult['files'] ?? [],
        );
        if (mounted) {
          setState(() {
            // ✅ عرض جميع الملفات
            _recentFiles = files.map((file) {
              final fileName =
                  file['name']?.toString() ?? S.of(context).fileWithoutName;
              final filePath = file['path']?.toString() ?? '';
              final size = file['size'];

              return {
                'name': fileName,
                'url': _getFileUrl(filePath),
                'type': _getFileType(fileName),
                'size': _formatBytes(
                  (size != null && size is int)
                      ? size
                      : (size != null && size is num)
                      ? size.toInt()
                      : 0,
                ),
                'createdAt': file['createdAt'],
                'path': filePath,
                'originalData': file,
                'originalName': fileName,
              };
            }).toList();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '${S.of(context).errorFetchingData}: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // ✅ إذا كان التحديث عن طريق السحب، أوقف المؤشر
        if (_refreshController.isRefresh) {
          _refreshController.refreshCompleted();
        }
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
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

  String _getFileUrl(String path) {
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

  void _handleFolderTap(Map<String, dynamic> folder) {
    final folderId = folder['folderId'] ?? folder['originalData']?['_id'];
    final folderName =
        folder['title'] ??
        folder['name'] ??
        folder['originalData']?['name'] ??
        S.of(context).folder;
    if (folderId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FolderContentsPage(
            folderId: folderId.toString(),
            folderName: folderName,
          ),
        ),
      );
    }
  }

  Future<void> _handleFileTap(Map<String, dynamic> file) async {
    final filePath = file['path'] as String?;
    if (filePath == null || filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).fileUrlNotAvailable),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final originalData = file['originalData'] ?? file;
    final originalName =
        file['originalName'] ?? file['name'] ?? S.of(context).fileWithoutName;
    final name = originalName.toLowerCase();
    final url = _getFileUrl(filePath);

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

        String? getFileExtension() {
          if (originalData is Map) {
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
              }
              if (contentType.contains('video')) {
                if (contentType.contains('mp4')) return 'mp4';
                if (contentType.contains('quicktime')) return 'mov';
              }
              if (contentType.contains('audio')) {
                if (contentType.contains('mpeg')) return 'mp3';
                if (contentType.contains('wav')) return 'wav';
              }
              if (contentType.contains('pdf')) return 'pdf';
            }
          }
          if (name.contains('.')) {
            return name.substring(name.lastIndexOf('.') + 1);
          }
          if (filePath.contains('.')) {
            return filePath
                .substring(filePath.lastIndexOf('.') + 1)
                .toLowerCase();
          }
          return null;
        }

        final extension = getFileExtension();

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PdfViewerPage(pdfUrl: url, fileName: originalName),
            ),
          );
        }
        // فيديو
        else if (isVideoFile()) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VideoViewer(url: url)),
          );
        }
        // صورة
        else if (isImageFile()) {
          final fileId = originalData['_id']?.toString();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageViewer(imageUrl: url, fileId: fileId),
            ),
          );
        }
        // نص
        else if (TextViewerPage.isTextFile(originalName) ||
            contentType.startsWith('text/')) {
          _showLoadingDialog(context);
          try {
            final fullResponse = await http.get(Uri.parse(url));
            if (mounted) Navigator.pop(context);
            if (fullResponse.statusCode == 200) {
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
            }
          } catch (e) {
            if (mounted) Navigator.pop(context);
          }
        }
        // صوت
        else if (isAudioFile()) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AudioPlayerPage(audioUrl: url, fileName: originalName),
            ),
          );
        }
        // باقي الملفات
        else {
          final token = await StorageService.getToken();
          await OfficeFileOpener.openAnyFile(
            url: url,
            context: context,
            token: token,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${S.of(context).errorOpeningFile}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  bool _isValidPdf(List<int> bytes) {
    if (bytes.length < 4) return false;
    return bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46;
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.darkAppBar
          : AppColors.lightAppBar,
      // appBar: AppBar(
      // title: const Text('الرئيسية'),
      // backgroundColor: isDarkMode
      //     ? AppColors.darkAppBar
      //     : AppColors.lightAppBar,
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.search),
      //     onPressed: () {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (context) => SmartSearchPage()),
      //       );
      //     },
      //     tooltip: 'بحث ذكي',
      //   ),
      // ],
      // ),
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          children: [
            StorageCard(),
            SizedBox(
              height: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 15.0,
                tablet: 20.0,
                desktop: 25.0,
              ),
            ),
            Expanded(
              child: Card(
                elevation: 4,
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(
                      ResponsiveUtils.getResponsiveValue(
                        context,
                        mobile: 25.0,
                        tablet: 30.0,
                        desktop: 35.0,
                      ),
                    ),
                  ),
                ),
                color: isDarkMode
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadRecentData,
                              child: Text(S.of(context).retry),
                            ),
                          ],
                        ),
                      )
                    : SmartRefresher(
                        controller: _refreshController,
                        onRefresh: _loadRecentData,
                        header: const WaterDropHeader(),
                        child: ListView(
                          padding: const EdgeInsets.all(16.0),
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: ResponsiveUtils.getResponsiveValue(
                                context,
                                mobile: 10.0,
                                tablet: 15.0,
                                desktop: 20.0,
                              ),
                            ),

                            // ===== قسم المجلدات الحديثة =====
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    S.of(context).recentFolders,
                                    style: TextStyle(
                                      fontSize:
                                          ResponsiveUtils.getResponsiveValue(
                                            context,
                                            mobile: 20.0,
                                            tablet: 24.0,
                                            desktop: 28.0,
                                          ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (widget.onNavigateToFolders != null) {
                                        widget.onNavigateToFolders!();
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FoldersPage(),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      S.of(context).seeAll,
                                      style: TextStyle(
                                        color: const Color(0xFF00BFA5),
                                        fontSize:
                                            ResponsiveUtils.getResponsiveValue(
                                              context,
                                              mobile: 14.0,
                                              tablet: 16.0,
                                              desktop: 18.0,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: ResponsiveUtils.getResponsiveValue(
                                context,
                                mobile: 15.0,
                                tablet: 20.0,
                                desktop: 25.0,
                              ),
                            ),

                            // عرض المجلدات الحديثة
                            if (_recentFolders.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    S.of(context).noRecentFolders,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              )
                            else
                              FilesGridView(
                                items: _recentFolders,
                                showFileCount: true,
                                onItemTap: _handleFolderTap,
                              ),

                            SizedBox(
                              height: ResponsiveUtils.getResponsiveValue(
                                context,
                                mobile: 20.0,
                                tablet: 25.0,
                                desktop: 30.0,
                              ),
                            ),

                            // ===== قسم الملفات الحديثة =====
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    S.of(context).recentFiles,
                                    style: TextStyle(
                                      fontSize:
                                          ResponsiveUtils.getResponsiveValue(
                                            context,
                                            mobile: 20.0,
                                            tablet: 24.0,
                                            desktop: 28.0,
                                          ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ViewToggleButtons(
                                    isGridView: isFilesGridView,
                                    onViewChanged: (isGrid) {
                                      setState(() {
                                        isFilesGridView = isGrid;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: ResponsiveUtils.getResponsiveValue(
                                context,
                                mobile: 15.0,
                                tablet: 20.0,
                                desktop: 25.0,
                              ),
                            ),

                            // عرض الملفات الحديثة
                            if (_recentFiles.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    S.of(context).noRecentFiles,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              )
                            else if (isFilesGridView)
                              FilesGrid(
                                files: _recentFiles,
                                onFileTap: (file) {
                                  _handleFileTap(file);
                                },
                              )
                            else
                              FilesListView(
                                items: _recentFiles.map((f) {
                                  return {
                                    'title':
                                        f['name'] ??
                                        S.of(context).fileWithoutName,
                                    'size': f['size'] ?? '0 B',
                                    'path': f['path'],
                                    'createdAt': f['createdAt'],
                                    'originalName':
                                        f['originalName'] ?? f['name'],
                                    '_id': f['originalData']?['_id']
                                        ?.toString(),
                                    'originalData': f['originalData'] ?? f,
                                  };
                                }).toList(),
                                itemMargin: const EdgeInsets.only(bottom: 10),
                                showMoreOptions: true,
                                onItemTap: (item) {
                                  _handleFileTap(item);
                                },
                              ),

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
