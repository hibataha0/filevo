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
import 'package:shimmer/shimmer.dart';
import 'package:filevo/dialogs/folder_protection_dialogs.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';

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
          // ✅ جلب تفاصيل كل مجلد بشكل متسلسل (لتجنب Too many requests)
          final folderController = Provider.of<FolderController>(
            context,
            listen: false,
          );

          final foldersWithStats = <Map<String, dynamic>>[];
          for (final folder in folders.take(3)) {
            try {
              final folderId = folder['_id']?.toString();
              if (folderId == null || folderId.isEmpty) {
                foldersWithStats.add({...folder, 'size': 0, 'filesCount': 0});
                continue;
              }

              // ✅ جلب تفاصيل المجلد (نفس الطريقة في _showFolderInfo)
              final folderDetails = await folderController.getFolderDetails(
                folderId: folderId,
              );

              if (folderDetails != null && folderDetails['folder'] != null) {
                final folderData =
                    folderDetails['folder'] as Map<String, dynamic>;
                // ✅ نسخ جميع البيانات من folderData بما في ذلك معلومات الحماية
                foldersWithStats.add({
                  ...folder,
                  ...folderData, // ✅ نسخ جميع البيانات من folderData أولاً
                  'size': folderData['size'] is int
                      ? folderData['size']
                      : (folderData['size'] is num
                            ? folderData['size'].toInt()
                            : 0),
                  'filesCount': folderData['filesCount'] is int
                      ? folderData['filesCount']
                      : (folderData['filesCount'] is num
                            ? folderData['filesCount'].toInt()
                            : 0),
                  // ✅ التأكد من وجود معلومات الحماية
                  'isProtected':
                      folderData['isProtected'] ??
                      folder['isProtected'] ??
                      false,
                  'protectionType':
                      folderData['protectionType'] ??
                      folder['protectionType'] ??
                      'none',
                });
              } else {
                // ✅ fallback إلى القيم من البيانات الأصلية
                foldersWithStats.add({
                  ...folder,
                  'size': folder['size'] ?? folder['totalSize'] ?? 0,
                  'filesCount':
                      folder['filesCount'] ?? folder['totalFiles'] ?? 0,
                });
              }
            } catch (e) {
              print(
                '❌ [HomeView] Error getting details for folder ${folder['name']}: $e',
              );
              // ✅ fallback إلى القيم من البيانات الأصلية
              foldersWithStats.add({
                ...folder,
                'size': folder['size'] ?? folder['totalSize'] ?? 0,
                'filesCount': folder['filesCount'] ?? folder['totalFiles'] ?? 0,
                // ✅ التأكد من وجود معلومات الحماية حتى في fallback
                'isProtected': folder['isProtected'] ?? false,
                'protectionType': folder['protectionType'] ?? 'none',
              });
            }
          }

          if (!mounted) return;

          setState(() {
            // ✅ بناء البيانات بنفس الطريقة المستخدمة في folders_view (السطر 389-426)
            _recentFolders = foldersWithStats.map((folder) {
              final folderData = folder;
              dynamic sizeValue = folderData['size'];
              dynamic filesCountValue = folderData['filesCount'];

              int size = 0;
              int filesCount = 0;

              if (sizeValue != null) {
                if (sizeValue is int) {
                  size = sizeValue;
                } else if (sizeValue is num) {
                  size = sizeValue.toInt();
                } else if (sizeValue is String) {
                  size = int.tryParse(sizeValue) ?? 0;
                }
              }

              if (filesCountValue != null) {
                if (filesCountValue is int) {
                  filesCount = filesCountValue;
                } else if (filesCountValue is num) {
                  filesCount = filesCountValue.toInt();
                } else if (filesCountValue is String) {
                  filesCount = int.tryParse(filesCountValue) ?? 0;
                }
              }

              // ✅ نفس البنية المستخدمة في folders_view (السطر 417-426)
              // ✅ استخدام folderData مباشرة (يحتوي على جميع البيانات من السيرفر بما في ذلك isProtected و protectionType)
              return {
                "title": folderData['name'] ?? S.of(context).unnamedFolder,
                "fileCount": filesCount,
                "size": _formatBytes(size),
                "icon": Icons.folder,
                "color": Color(0xff28336f),
                "type": "folder",
                "folderId": folderData['_id'],
                "folderData":
                    folderData, // ✅ استخدام folderData مباشرة (مثل folders_view) - يحتوي على جميع البيانات من السيرفر
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
              final fileId = file['_id']?.toString() ?? '';
              final size = file['size'];

              // ✅ بناء URL - إذا كان path موجوداً استخدمه، وإلا استخدم fileId
              String fileUrl = '';
              if (filePath.isNotEmpty) {
                fileUrl = _getFileUrl(filePath);
              } else if (fileId.isNotEmpty) {
                // ✅ استخدام viewFile endpoint للصور
                final baseUrl = ApiConfig.baseUrl;
                fileUrl = "$baseUrl/files/$fileId/view";
              }

              return {
                'name': fileName,
                'url': fileUrl,
                'type': _getFileType(fileName),
                'size': _formatBytes(
                  (size != null && size is int)
                      ? size
                      : (size != null && size is num)
                      ? size.toInt()
                      : 0,
                ),
                'createdAt':
                    file['uploadedAt'] ??
                    file['createdAt'], // ✅ استخدام uploadedAt من الباك إند
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

  Future<void> _handleFolderTap(Map<String, dynamic> folder) async {
    // ✅ استخدام نفس الكود من folders_view (السطر 2405-2471)
    final type = folder['type'] as String?;
    if (type == 'folder') {
      final folderId =
          folder['folderId']?.toString() ?? folder['_id']?.toString();
      if (folderId == null || folderId.isEmpty) return;

      final folderName =
          folder['title']?.toString() ??
          folder['name']?.toString() ??
          S.of(context).folder;

      // ✅ التحقق من أن المجلد محمي (نفس الكود من folders_view)
      final folderData = folder['folderData'] ?? folder;
      final isProtected = folderData['isProtected'] == true;
      final protectionType = folderData['protectionType']?.toString() ?? 'none';

      // ✅ إذا كان المجلد محمي، نطلب كلمة السر أولاً (قبل فتح المجلد)
      if (isProtected && protectionType != 'none') {
        final result = await showVerifyFolderAccessDialog(
          context,
          folderId,
          folderName,
          protectionType,
        );

        // ✅ إذا لم يتم التحقق بنجاح، نوقف العملية
        if (result['success'] != true) {
          return;
        }
      }

      // ✅ بعد التحقق (إذا كان محمياً) أو مباشرة (إذا لم يكن محمياً)، نفتح المجلد
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FolderContentsPage(folderId: folderId, folderName: folderName),
          ),
        );
      }
    }
  }

  Future<void> _handleFileTap(Map<String, dynamic> file) async {
    final originalData = file['originalData'] ?? file;
    final originalName =
        file['originalName'] ?? file['name'] ?? S.of(context).fileWithoutName;
    final name = originalName.toLowerCase();

    // ✅ استخدام url من البيانات إذا كان موجوداً، وإلا استخدام path
    String? url = file['url'] as String?;
    String? filePath = file['path'] as String?;

    if (url == null || url.isEmpty) {
      if (filePath != null && filePath.isNotEmpty) {
        url = _getFileUrl(filePath);
      } else {
        // ✅ إذا لم يكن هناك path أو url، استخدم fileId لبناء URL
        final fileId =
            originalData['_id']?.toString() ?? file['_id']?.toString();
        if (fileId != null && fileId.isNotEmpty) {
          final baseUrl = ApiConfig.baseUrl.replaceAll('/api/v1', '');
          url = "$baseUrl/files/$fileId/view";
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).fileUrlNotAvailable),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      }
    }

    final finalUrl = url; // ✅ بعد الفحص، url لن يكون null

    if (!_isValidUrl(finalUrl)) {
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
      // ✅ جلب token لإضافته إلى headers
      final token = await StorageService.getToken();
      final headers = <String, String>{'Range': 'bytes=0-511'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final client = http.Client();
      final response = await client.get(Uri.parse(finalUrl), headers: headers);
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
          if (filePath != null &&
              filePath.isNotEmpty &&
              filePath.contains('.')) {
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
                  PdfViewerPage(pdfUrl: finalUrl, fileName: originalName),
            ),
          );
        }
        // فيديو
        else if (isVideoFile()) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VideoViewer(url: finalUrl)),
          );
        }
        // صورة
        else if (isImageFile()) {
          final fileId = originalData['_id']?.toString();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageViewer(imageUrl: finalUrl, fileId: fileId),
            ),
          );
        }
        // نص
        else if (TextViewerPage.isTextFile(originalName) ||
            contentType.startsWith('text/')) {
          _showLoadingDialog(context);
          try {
            // ✅ جلب token لإضافته إلى headers
            final textToken = await StorageService.getToken();
            final textHeaders = <String, String>{};
            if (textToken != null && textToken.isNotEmpty) {
              textHeaders['Authorization'] = 'Bearer $textToken';
            }
            final fullResponse = await http.get(
              Uri.parse(finalUrl),
              headers: textHeaders,
            );
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
                  AudioPlayerPage(audioUrl: finalUrl, fileName: originalName),
            ),
          );
        }
        // باقي الملفات
        else {
          final token = await StorageService.getToken();
          await OfficeFileOpener.openAnyFile(
            url: finalUrl,
            context: context,
            token: token,
            fileName: originalName,
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

  Widget _buildShimmerLoading() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        SizedBox(height: 20),
        // Shimmer للمجلدات
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            3,
            (index) => SizedBox(
              width: (MediaQuery.of(context).size.width - 48) / 3,
              child: _buildFolderShimmerCard(),
            ),
          ),
        ),
        SizedBox(height: 30),
        // Shimmer للملفات
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            6,
            (index) => SizedBox(
              width: (MediaQuery.of(context).size.width - 40) / 2,
              child: _buildFileShimmerCard(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFolderShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: 12),
            Container(
              height: 14,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 12,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
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
                    ? _buildShimmerLoading()
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
                                        color: const Color(0xFF28336F),
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
                                onFileRemoved: () {
                                  // ✅ إعادة تحميل البيانات بعد تغيير الحماية أو حذف المجلد
                                  _loadRecentData();
                                },
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
                                onFileRemoved: () {
                                  // ✅ إعادة تحميل البيانات بعد حذف ملف
                                  _loadRecentData();
                                },
                                onFileUpdated: () {
                                  // ✅ إعادة تحميل البيانات بعد تعديل ملف
                                  _loadRecentData();
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
                                onFileRemoved: () {
                                  // ✅ إعادة تحميل البيانات بعد حذف ملف
                                  _loadRecentData();
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
