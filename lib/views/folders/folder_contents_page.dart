import 'dart:io';
import 'package:filevo/components/FilesListView.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:filevo/responsive.dart';
import 'package:filevo/views/fileViewer/FilesGridView1.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/components/ViewToggleButtons.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/config/api_config.dart';
import 'package:filevo/views/fileViewer/VideoViewer.dart';
import 'package:filevo/views/fileViewer/audioPlayer.dart';
import 'package:filevo/views/fileViewer/imageViewer.dart';
import 'package:filevo/views/fileViewer/office_file_opener.dart';
import 'package:filevo/views/fileViewer/pdfViewer.dart';
import 'package:filevo/views/fileViewer/textViewer.dart';
import 'package:filevo/views/folders/share_folder_with_room_page.dart';
import 'package:filevo/services/api_endpoints.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class FolderContentsPage extends StatefulWidget {
  final String folderId;
  final String folderName;
  final Color? folderColor;

  const FolderContentsPage({
    Key? key,
    required this.folderId,
    required this.folderName,
    this.folderColor,
  }) : super(key: key);

  @override
  State<FolderContentsPage> createState() => _FolderContentsPageState();
}

class _FolderContentsPageState extends State<FolderContentsPage> {
  bool isGridView = true;
  int currentPage = 1;
  int limit = 20;
  bool hasMore = true;
  List<Map<String, dynamic>> contents = [];
  bool isLoading = false;

  Future<void> _loadViewPreference() async {
    final saved = await StorageService.getFolderViewIsGrid();
    if (saved != null && mounted) {
      setState(() {
        isGridView = saved;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadViewPreference();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFolderContents();
    });
  }

  Future<void> _loadFolderContents({
    bool loadMore = false,
    bool resetPage = false,
  }) async {
    if (!mounted) return;
    if (isLoading && !resetPage) return;

    setState(() {
      isLoading = true;
      if (resetPage) {
        currentPage = 1;
        hasMore = true;
        contents = [];
      }
    });

    try {
      final folderController = Provider.of<FolderController>(
        context,
        listen: false,
      );
      final pageToLoad = resetPage
          ? 1
          : (loadMore ? currentPage + 1 : currentPage);
      final result = await folderController.getFolderContents(
        folderId: widget.folderId,
        page: pageToLoad,
        limit: limit,
      );

      if (!mounted) return;

      List<Map<String, dynamic>> newContents = [];

      if (result != null) {
        if (result['contents'] != null) {
          newContents = List<Map<String, dynamic>>.from(result['contents']);
          newContents.sort((a, b) {
            final aType = a['type'] as String?;
            final bType = b['type'] as String?;
            if (aType == 'folder' && bType == 'file') return -1;
            if (aType == 'file' && bType == 'folder') return 1;
            return 0;
          });
        } else if (result['subfolders'] != null || result['files'] != null) {
          final subfolders = List<Map<String, dynamic>>.from(
            result['subfolders'] ?? [],
          );
          final files = List<Map<String, dynamic>>.from(result['files'] ?? []);
          newContents = [
            ...subfolders.map((f) => {...f, 'type': 'folder'}),
            ...files.map((f) => {...f, 'type': 'file'}),
          ];
        }
      }

      if (!mounted) return;

      if (newContents.isNotEmpty) {
        final processedContents = newContents.map((item) {
          final currentType = item['type'] as String?;
          if (currentType != 'file' && currentType != 'folder') {
            if (item['filesCount'] != null || item['subfoldersCount'] != null) {
              item['type'] = 'folder';
            } else {
              item['type'] = 'file';
            }
          }
          return item;
        }).toList();

        if (mounted) {
          setState(() {
            if (loadMore) {
              contents.addAll(processedContents);
              currentPage = pageToLoad;
            } else {
              contents = processedContents;
              currentPage = resetPage ? 1 : pageToLoad;
            }

            final totalItems =
                result?['totalItems'] as int? ?? newContents.length;
            final pagination = result?['pagination'] as Map<String, dynamic>?;
            if (pagination != null) {
              hasMore = pagination['hasNext'] ?? false;
            } else {
              final currentTotal = loadMore
                  ? contents.length
                  : newContents.length;
              hasMore = currentTotal < totalItems;
            }
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            contents = [];
            isLoading = false;
            hasMore = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _handleItemTap(Map<String, dynamic> item) {
    final type = item['type'] as String?;
    if (type == 'folder') {
      final folderId = item['_id'] as String?;
      final folderName = item['name'] as String?;
      if (folderId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FolderContentsPage(
              folderId: folderId,
              folderName: folderName ?? 'مجلد',
              folderColor: widget.folderColor,
            ),
          ),
        );
      }
    } else if (type == 'file') {
      _handleFileTap(item);
    }
  }

  String getFileUrl(String path) {
    if (path.startsWith('http')) return path;
    String cleanPath = path.replaceAll(r'\', '/').replaceAll('//', '/');
    while (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    final base = ApiConfig.baseUrl.replaceAll('/api/v1', '');
    String baseClean = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    return '$baseClean/$cleanPath';
  }

  Future<void> _handleFileTap(Map<String, dynamic> file) async {
    final filePath = file['path'] as String?;
    final fileId = file['_id']?.toString() ?? '';
    String finalPath = filePath ?? '';

    if (finalPath.isEmpty && fileId.isNotEmpty) {
      final token = await StorageService.getToken();
      if (token != null) {
        finalPath = 'download:$fileId';
      }
    }

    if (finalPath.isEmpty) {
      _showSnackBar('رابط الملف غير متوفر', Colors.orange);
      return;
    }

    final originalName = file['name'] as String?;
    final name = originalName?.toLowerCase() ?? '';
    final fileName = originalName ?? 'ملف بدون اسم';

    String url;
    if (finalPath.startsWith('download:')) {
      final fileIdForDownload = finalPath.replaceFirst('download:', '');
      final token = await StorageService.getToken();
      if (token == null) {
        _showSnackBar('يجب تسجيل الدخول أولاً', Colors.red);
        return;
      }
      url =
          "${ApiConfig.baseUrl.replaceAll('/api/v1', '')}${ApiEndpoints.downloadFile(fileIdForDownload)}";
    } else {
      url = getFileUrl(finalPath);
    }

    _showLoadingDialog();

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        Navigator.pop(context);
        _showSnackBar('يجب تسجيل الدخول أولاً', Colors.red);
        return;
      }

      final client = http.Client();
      final response = await client.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Range': 'bytes=0-511'},
      );
      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 206) {
        final bytes = response.bodyBytes;
        bool isValidPdf(List<int> bytes) {
          if (bytes.length < 4) return false;
          final signature = String.fromCharCodes(bytes.sublist(0, 4));
          return signature == '%PDF';
        }

        final isPdf = isValidPdf(bytes);

        if (name.endsWith('.pdf') && !isPdf) {
          _showSnackBar('ملف PDF غير صالح', Colors.red);
          return;
        }

        if (name.endsWith('.pdf')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PdfViewerPage(pdfUrl: url, fileName: fileName),
            ),
          );
        } else if (name.endsWith('.mp4') ||
            name.endsWith('.mov') ||
            name.endsWith('.mkv') ||
            name.endsWith('.avi') ||
            name.endsWith('.wmv')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VideoViewer(url: url)),
          );
        } else if (name.endsWith('.jpg') ||
            name.endsWith('.jpeg') ||
            name.endsWith('.png') ||
            name.endsWith('.gif') ||
            name.endsWith('.bmp') ||
            name.endsWith('.webp')) {
          final fileId = file['_id']?.toString();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageViewer(imageUrl: url, fileId: fileId),
            ),
          );
        } else if (TextViewerPage.isTextFile(fileName)) {
          _showLoadingDialog();
          try {
            final fullResponse = await http.get(Uri.parse(url));
            if (mounted) Navigator.pop(context);
            if (fullResponse.statusCode == 200) {
              final tempDir = await getTemporaryDirectory();
              final tempFile = File('${tempDir.path}/$fileName');
              await tempFile.writeAsBytes(fullResponse.bodyBytes);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TextViewerPage(
                    filePath: tempFile.path,
                    fileName: fileName,
                  ),
                ),
              );
            }
          } catch (e) {
            if (mounted) Navigator.pop(context);
          }
        } else if (name.endsWith('.mp3') ||
            name.endsWith('.wav') ||
            name.endsWith('.aac') ||
            name.endsWith('.ogg') ||
            name.endsWith('.m4a') ||
            name.endsWith('.wma') ||
            name.endsWith('.flac')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AudioPlayerPage(audioUrl: url, fileName: fileName),
            ),
          );
        } else {
          _showLoadingDialog();
          await OfficeFileOpener.openAnyFile(
            url: url,
            context: context,
            token: token,
            fileName: fileName,
            closeLoadingDialog: true,
          );
        }
      } else {
        _showSnackBar('الملف غير متوفر (${response.statusCode})', Colors.red);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('خطأ في تحميل الملف', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: widget.folderColor ?? Colors.blue,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _convertFilesToListFormat(
    List<Map<String, dynamic>> files,
  ) {
    return files.map((file) {
      final fileName = file['name']?.toString() ?? 'ملف بدون اسم';
      final filePath = file['path']?.toString() ?? '';
      final fileId = file['_id']?.toString() ?? '';

      String fileUrl = '';
      if (filePath.isNotEmpty) {
        fileUrl = getFileUrl(filePath);
      } else if (fileId.isNotEmpty) {
        fileUrl =
            "${ApiConfig.baseUrl.replaceAll('/api/v1', '')}${ApiEndpoints.downloadFile(fileId)}";
      }

      String fileType = _getFileType(fileName);

      return {
        'title': fileName,
        'url': fileUrl,
        'type': fileType,
        'size': _formatBytes(file['size'] ?? 0),
        'originalData': file,
        'itemData': file,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _convertFilesToGridFormat(
    List<Map<String, dynamic>> files,
  ) {
    return files.map((file) {
      final fileName = file['name']?.toString() ?? 'ملف بدون اسم';
      final filePath = file['path']?.toString() ?? '';
      final fileId = file['_id']?.toString() ?? '';

      String fileUrl = '';
      if (filePath.isNotEmpty) {
        fileUrl = getFileUrl(filePath);
      } else if (fileId.isNotEmpty) {
        fileUrl =
            "${ApiConfig.baseUrl.replaceAll('/api/v1', '')}${ApiEndpoints.downloadFile(fileId)}";
      }

      String fileType = _getFileType(fileName);

      return {
        'name': fileName,
        'url': fileUrl,
        'type': fileType,
        'size': _formatBytes(file['size'] ?? 0),
        'originalData': file,
        'originalName': fileName,
      };
    }).toList();
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

    return '${size.toStringAsFixed(1)} ${sizes[i]}';
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

  Future<void> _showFolderInfo() async {
    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );
    final token = await StorageService.getToken();

    if (token == null) {
      _showSnackBar('يجب تسجيل الدخول أولاً', Colors.red);
      return;
    }

    final folderDetails = await folderController.getFolderDetails(
      folderId: widget.folderId,
    );

    if (folderDetails == null || folderDetails['folder'] == null) {
      _showSnackBar('فشل جلب معلومات المجلد', Colors.red);
      return;
    }

    final folder = folderDetails['folder'] as Map<String, dynamic>;
    final folderColor = widget.folderColor ?? Colors.blue;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: folderColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.folder, color: folderColor, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        folder['name'] ?? widget.folderName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildInfoRow(
                'النوع',
                'مجلد',
                Icons.folder_outlined,
                Colors.blue,
              ),
              _buildInfoRow(
                'الحجم',
                _formatBytes(folder['size'] ?? 0),
                Icons.storage,
                Colors.green,
              ),
              _buildInfoRow(
                'عدد الملفات',
                '${folder['filesCount'] ?? 0}',
                Icons.insert_drive_file,
                Colors.orange,
              ),
              _buildInfoRow(
                'المجلدات الفرعية',
                '${folder['subfoldersCount'] ?? 0}',
                Icons.folder_copy,
                Colors.purple,
              ),
              _buildInfoRow(
                'تاريخ الإنشاء',
                _formatDate(folder['createdAt']),
                Icons.calendar_today,
                Colors.red,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: folderColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('تم'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
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
                    fontSize: 15,
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

  String _formatDate(dynamic date) {
    if (date == null) return "غير معروف";
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    } catch (e) {
      return "غير معروف";
    }
  }

  Future<void> _showShareDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShareFolderWithRoomPage(
          folderId: widget.folderId,
          folderName: widget.folderName,
        ),
      ),
    );

    if (result == true) {
      _loadFolderContents(resetPage: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final folderColor = widget.folderColor ?? Colors.blue;
    final folders = contents.where((item) => item['type'] == 'folder').toList();
    final files = contents.where((item) => item['type'] == 'file').toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // AppBar
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: folderColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        widget.folderName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: _showFolderInfo,
                    ),
                    IconButton(
                      icon: Icon(Icons.share, color: Colors.white, size: 22),
                      onPressed: _showShareDialog,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.folder,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '${folders.length}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 16,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.insert_drive_file,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '${files.length}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 16,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            ViewToggleButtons(
                              isGridView: isGridView,
                              onViewChanged: (isGrid) {
                                setState(() {
                                  isGridView = isGrid;
                                });
                                StorageService.saveFolderViewIsGrid(isGrid);
                              },
                              backgroundColor: Colors.transparent,
                              iconColor: Colors.white.withOpacity(0.7),
                              activeBackgroundColor: Colors.white,
                              activeIconColor: folderColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: RefreshIndicator(
              color: folderColor,
              onRefresh: () => _loadFolderContents(resetPage: true),
              child: _buildContent(folders, files, folderColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    List<Map<String, dynamic>> folders,
    List<Map<String, dynamic>> files,
    Color folderColor,
  ) {
    if (isLoading && contents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: folderColor),
            SizedBox(height: 16),
            Text(
              'جاري تحميل المحتويات...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (contents.isEmpty && !isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 60, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text(
              'المجلد فارغ',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'يمكنك إضافة ملفات أو مجلدات جديدة',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Folders Section
          if (folders.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.folder, color: folderColor, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'المجلدات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: folderColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      folders.length.toString(),
                      style: TextStyle(
                        color: folderColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: folders.length,
              itemBuilder: (context, index) => _buildFolderCard(folders[index]),
            ),
            SizedBox(height: 24),
          ],

          // Files Section
          if (files.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.insert_drive_file,
                    color: Colors.grey[700],
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'الملفات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: folderColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      files.length.toString(),
                      style: TextStyle(
                        color: folderColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            isGridView
                ? FilesGrid(
                    files: _convertFilesToGridFormat(files),
                    onFileTap: (file) => _handleFileTap(file),
                    onFileRemoved: () => _loadFolderContents(resetPage: true),
                    onFileUpdated: () => _loadFolderContents(resetPage: true),
                  )
                : FilesListView(
                    items: _convertFilesToListFormat(files),
                    onItemTap: (item) => _handleFileTap(item),
                    onFileRemoved: () => _loadFolderContents(resetPage: true),
                  ),
          ],

          // Load More Button
          if (hasMore && !isLoading)
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: ElevatedButton(
                  onPressed: () => _loadFolderContents(loadMore: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: folderColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text('تحميل المزيد'),
                ),
              ),
            ),

          if (isLoading && contents.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(color: folderColor),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ استبدل دالة _buildFolderCard الموجودة بهذا الكود:

  Widget _buildFolderCard(Map<String, dynamic> folder) {
    final name = folder['name'] as String? ?? 'بدون اسم';
    final filesCount = folder['filesCount'] ?? 0;
    final folderColor = widget.folderColor ?? Colors.blue;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _handleItemTap(folder),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ الصف العلوي مع أيقونة المجلد وزر النقاط الثلاث
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: folderColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.folder, color: folderColor, size: 24),
                  ),
                  // ✅ زر النقاط الثلاث
                  GestureDetector(
                    onTap: () => _showNormalFolderMenu(context, folder),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$filesCount ملف',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ أضف هذه الدالة (من FolderFileCard):
  void _showNormalFolderMenu(
    BuildContext context,
    Map<String, dynamic> folder,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 20.0,
                  tablet: 24.0,
                  desktop: 28.0,
                ),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Handle bar
              Container(
                margin: EdgeInsets.only(
                  top: ResponsiveUtils.getResponsiveValue(
                    context,
                    mobile: 12.0,
                    tablet: 14.0,
                    desktop: 16.0,
                  ),
                  bottom: ResponsiveUtils.getResponsiveValue(
                    context,
                    mobile: 8.0,
                    tablet: 10.0,
                    desktop: 12.0,
                  ),
                ),
                width: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 40.0,
                  tablet: 50.0,
                  desktop: 60.0,
                ),
                height: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 4.0,
                  tablet: 5.0,
                  desktop: 6.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ✅ قائمة خيارات المجلدات العادية - قابلة للتمرير
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ فتح المجلد
                      _buildMenuItem(
                        context,
                        icon: Icons.open_in_new,
                        title: S.of(context).open,
                        onTap: () {
                          Navigator.pop(context);
                          _handleItemTap(folder);
                        },
                      ),

                      // ✅ عرض التفاصيل
                      _buildMenuItem(
                        context,
                        icon: Icons.info_outline,
                        title: S.of(context).viewDetails,
                        onTap: () async {
                          Navigator.pop(context);
                          await _showFolderDetailsDialog(folder);
                        },
                      ),

                      // ✅ إعادة التسمية
                      _buildMenuItem(
                        context,
                        icon: Icons.edit,
                        title: S.of(context).update,
                        onTap: () {
                          Navigator.pop(context);
                          _showRenameDialog(context, folder);
                        },
                      ),

                      // ✅ المشاركة
                      _buildMenuItem(
                        context,
                        icon: Icons.share,
                        title: S.of(context).share,
                        onTap: () async {
                          Navigator.pop(context);
                          await _showShareDialog();
                        },
                      ),

                      // ✅ النقل
                      _buildMenuItem(
                        context,
                        icon: Icons.drive_file_move_rounded,
                        title: S.of(context).move,
                        iconColor: Colors.purple,
                        onTap: () {
                          Navigator.pop(context);
                          _showSnackBar(
                            'سيتم إضافة ميزة النقل قريباً',
                            Colors.orange,
                          );
                        },
                      ),

                      // ✅ المفضلة
                      _buildMenuItem(
                        context,
                        icon: Icons.star_border,
                        title: S.of(context).folderRemovedFromFavorites,
                        iconColor: Colors.amber[700],
                        onTap: () {
                          Navigator.pop(context);
                          _showSnackBar('تمت الإضافة للمفضلة', Colors.green);
                        },
                      ),

                      // ✅ خط فاصل قبل الحذف
                      Divider(height: 1),

                      // ✅ الحذف
                      _buildMenuItem(
                        context,
                        icon: Icons.delete,
                        title: S.of(context).delete,
                        textColor: Colors.red,
                        iconColor: Colors.red,
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteFolderDialog(folder);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 8.0,
                  tablet: 12.0,
                  desktop: 16.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ أضف هذه الدالة (من FolderFileCard):
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    final iconSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    final containerSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 40.0,
      tablet: 48.0,
      desktop: 56.0,
    );
    final fontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
    );

    return ListTile(
      leading: Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.grey[700])!.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? Colors.grey[700], size: iconSize),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  // ✅ أضف دالة عرض تفاصيل المجلد:
  Future<void> _showFolderDetailsDialog(Map<String, dynamic> folder) async {
    final folderId = folder['_id'] as String?;
    if (folderId == null) return;

    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );

    final folderDetails = await folderController.getFolderDetails(
      folderId: folderId,
    );

    if (folderDetails == null || folderDetails['folder'] == null) {
      _showSnackBar('فشل جلب معلومات المجلد', Colors.red);
      return;
    }

    final folderData = folderDetails['folder'] as Map<String, dynamic>;
    final folderColor = widget.folderColor ?? Colors.blue;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: folderColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.folder, color: folderColor, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        folderData['name'] ?? folder['name'] ?? 'مجلد',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildInfoRow(
                'النوع',
                'مجلد',
                Icons.folder_outlined,
                Colors.blue,
              ),
              _buildInfoRow(
                'الحجم',
                _formatBytes(folderData['size'] ?? 0),
                Icons.storage,
                Colors.green,
              ),
              _buildInfoRow(
                'عدد الملفات',
                '${folderData['filesCount'] ?? 0}',
                Icons.insert_drive_file,
                Colors.orange,
              ),
              _buildInfoRow(
                'المجلدات الفرعية',
                '${folderData['subfoldersCount'] ?? 0}',
                Icons.folder_copy,
                Colors.purple,
              ),
              _buildInfoRow(
                'تاريخ الإنشاء',
                _formatDate(folderData['createdAt']),
                Icons.calendar_today,
                Colors.red,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: folderColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('تم'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ أضف دالة إعادة التسمية:
  void _showRenameDialog(BuildContext context, Map<String, dynamic> folder) {
    final folderName =
        folder['title']?.toString() ??
        folder['name']?.toString() ??
        S.of(context).folder;
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
      ScaffoldMessenger.of(
        scaffoldContext,
      ).showSnackBar(SnackBar(content: Text(S.of(context).folderIdNotFound)));
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).editFileMetadata),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: S.of(context).folderName,
                  hintText: S.of(context).folderName,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.folder),
                ),
                autofocus: true,
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: S.of(context).folderDescription,
                  hintText: S.of(context).folderDescriptionHint,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextField(
                controller: tagsController,
                decoration: InputDecoration(
                  labelText: S.of(context).folderTags,
                  hintText: S.of(context).folderTagsHint,
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
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(S.of(context).pleaseEnterFolderName)),
                );
                return;
              }

              final description = descriptionController.text.trim();
              final tagsString = tagsController.text.trim();
              final tags = tagsString.isNotEmpty
                  ? tagsString
                        .split(',')
                        .map((t) => t.trim())
                        .where((t) => t.isNotEmpty)
                        .toList()
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
            child: Text(S.of(context).save),
          ),
        ],
      ),
    );
  }

  // ✅ أضف دالة الحذف:
  void _showDeleteFolderDialog(Map<String, dynamic> folder) {
    final folderName = folder['name'] ?? 'المجلد';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('تأكيد الحذف', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف المجلد "$folderName"؟\nسيتم حذف جميع المحتويات بشكل نهائي.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _showSnackBar('سيتم إضافة ميزة الحذف قريباً', Colors.red);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('حذف'),
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
    final folderController = Provider.of<FolderController>(
      scaffoldContext,
      listen: false,
    );

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
            content: Text(S.of(scaffoldContext).folderUpdatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text(
              folderController.errorMessage ??
                  S.of(scaffoldContext).folderUpdateFailed,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
