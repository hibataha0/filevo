import 'dart:io';
import 'package:filevo/components/FilesListView.dart';
import 'package:filevo/generated/l10n.dart';
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
import 'package:shimmer/shimmer.dart';
import 'package:filevo/views/folders/starred_folders_page_helpers.dart';
import 'package:filevo/components/FolderFileCard.dart';
import 'package:filevo/views/folders/folder_protection_dialogs.dart';
import 'package:filevo/services/folder_protection_service.dart';
import 'package:filevo/utils/folder_protection_helper.dart';

class FolderContentsPage extends StatefulWidget {
  final String folderId;
  final String folderName;
  final Color? folderColor;
  final VoidCallback?
  onFolderUpdated; // ✅ callback لإعادة التحميل في الصفحة الأم

  const FolderContentsPage({
    Key? key,
    required this.folderId,
    required this.folderName,
    this.folderColor,
    this.onFolderUpdated, // ✅ callback لإعادة التحميل
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
      _checkProtectionAndLoad();
    });
  }

  // ✅ التحقق من الحماية قبل تحميل المحتويات
  Future<void> _checkProtectionAndLoad() async {
    if (!mounted) return;

    print(
      '🔍 [FolderContentsPage] Starting _checkProtectionAndLoad for folder: ${widget.folderId}',
    );

    try {
      final folderController = Provider.of<FolderController>(
        context,
        listen: false,
      );

      // ✅ جلب تفاصيل المجلد للتحقق من الحماية
      final folderDetails = await folderController.getFolderDetails(
        folderId: widget.folderId,
      );

      if (!mounted) return;

      print(
        '🔍 [FolderContentsPage] Folder details received: ${folderDetails != null}',
      );

      if (folderDetails != null && folderDetails['folder'] != null) {
        final folderData = folderDetails['folder'] as Map<String, dynamic>;
        final isProtected = FolderProtectionService.isFolderProtected(
          folderData,
        );

        print('🔍 [FolderContentsPage] isProtected: $isProtected');
        print(
          '🔍 [FolderContentsPage] folderData: ${folderData['isProtected']}, ${folderData['protectionType']}',
        );

        if (isProtected) {
          // ✅ المجلد محمي، طلب كلمة السر أو البصمة
          final protectionType = FolderProtectionService.getProtectionType(
            folderData,
          );

          print('🔍 [FolderContentsPage] Protection type: $protectionType');
          print('🔍 [FolderContentsPage] Showing VerifyFolderAccessDialog');

          // ✅ إظهار Dialog للتحقق من الوصول - مهم جداً!
          final hasAccess = await showDialog<bool>(
            context: context,
            barrierDismissible: false, // ✅ منع الإغلاق بدون التحقق
            builder: (dialogContext) => VerifyFolderAccessDialog(
              folderId: widget.folderId,
              folderName: widget.folderName,
              protectionType: protectionType,
            ),
          );

          print('🔍 [FolderContentsPage] Dialog result: $hasAccess');

          if (!mounted) return;

          // ✅ إذا لم يتم التحقق بنجاح، العودة للصفحة السابقة
          if (hasAccess != true) {
            print('❌ [FolderContentsPage] Access denied or cancelled, popping');
            if (mounted) {
              Navigator.pop(context);
              rootScaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text('❌ يجب التحقق من الوصول لفتح المجلد'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          print('✅ [FolderContentsPage] Access granted, loading contents');
        } else {
          print(
            '✅ [FolderContentsPage] Folder is not protected, loading contents',
          );
        }
      } else {
        print(
          '⚠️ [FolderContentsPage] Folder details is null, loading contents anyway',
        );
      }

      // ✅ تحميل المحتويات فقط بعد التحقق الناجح من الحماية (أو إذا لم يكن محمياً)
      if (mounted) {
        _loadFolderContents();
      }
    } catch (e) {
      // ✅ في حالة الخطأ، التحقق من أن الخطأ ليس بسبب الحماية
      print('❌ [FolderContentsPage] Error in _checkProtectionAndLoad: $e');

      // ✅ إذا كان الخطأ بسبب الحماية، لا نحاول تحميل المحتويات
      if (e.toString().contains('protected') ||
          e.toString().contains('Access denied') ||
          e.toString().contains('403')) {
        if (mounted) {
          Navigator.pop(context);
          rootScaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text('❌ المجلد محمي. يجب التحقق من الوصول أولاً'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // ✅ في حالة خطأ آخر، محاولة تحميل المحتويات مباشرة
      if (mounted) {
        _loadFolderContents();
      }
    }
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

  Future<void> _handleItemTap(Map<String, dynamic> item) async {
    final type = item['type'] as String?;
    if (type == 'folder') {
      final folderId = item['_id'] as String?;
      final folderName = item['name'] as String?;
      if (folderId != null) {
        // ✅ التحقق من الحماية قبل فتح المجلد
        final isProtected = FolderProtectionService.isFolderProtected(item);
        if (isProtected) {
          final protectionType = FolderProtectionService.getProtectionType(
            item,
          );
          final hasAccess = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => VerifyFolderAccessDialog(
              folderId: folderId,
              folderName: folderName ?? 'مجلد',
              protectionType: protectionType,
            ),
          );

          if (hasAccess != true) {
            // ✅ المستخدم لم يتحقق أو ألغى العملية
            return;
          }
        }

        // ✅ فتح المجلد بعد التحقق من الحماية
        if (mounted) {
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
    // ✅ محاولة الحصول على البيانات من originalData أولاً
    final originalData = file['originalData'] as Map<String, dynamic>?;
    final fileData = originalData ?? file;

    // ✅ محاولة الحصول على path من عدة مصادر
    String? filePath = fileData['path'] as String?;
    if (filePath == null || filePath.isEmpty) {
      filePath = file['path'] as String?;
    }

    // ✅ محاولة الحصول على fileId من عدة مصادر
    String fileId = fileData['_id']?.toString() ?? '';
    if (fileId.isEmpty) {
      fileId = file['_id']?.toString() ?? '';
    }
    if (fileId.isEmpty) {
      fileId = file['fileId']?.toString() ?? '';
    }

    String finalPath = filePath ?? '';

    // ✅ إذا لم يكن path موجوداً ولكن fileId موجود، استخدم endpoint التحميل
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

    // ✅ الحصول على اسم الملف من عدة مصادر
    final originalName = fileData['name'] as String? ?? file['name'] as String?;
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
    if (!mounted) return;
    // ✅ استخدام GlobalKey بدلاً من ScaffoldMessenger.of(context)
    rootScaffoldMessengerKey.currentState?.showSnackBar(
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

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: isGridView
          ? Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(6, (index) {
                // ✅ تحديد نوع العنصر (ملف أو مجلد)
                final isFolder = index % 3 == 0; // كل ثالث عنصر يكون مجلد
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 40) / 2,
                  child: isFolder
                      ? _buildFolderShimmerCard()
                      : _buildFileShimmerCard(),
                );
              }),
            )
          : Column(
              children: List.generate(6, (index) {
                final isFolder = index % 3 == 0;
                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: isFolder
                      ? _buildFolderListShimmerCard()
                      : _buildFileListShimmerCard(),
                );
              }),
            ),
    );
  }

  Widget _buildLoadingMoreShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 50,
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
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

  Widget _buildFolderListShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 80,
        padding: EdgeInsets.all(12),
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
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
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
  }

  Widget _buildFileListShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 80,
        padding: EdgeInsets.all(12),
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
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
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
  }

  Widget _buildContent(
    List<Map<String, dynamic>> folders,
    List<Map<String, dynamic>> files,
    Color folderColor,
  ) {
    if (isLoading && contents.isEmpty) {
      return _buildShimmerLoading();
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
                    onFileRemoved: () {
                      _loadFolderContents(resetPage: true);
                      // ✅ إعادة تحميل في الصفحة الأم (folders_view) لتحديث عدد الملفات
                      if (widget.onFolderUpdated != null) {
                        widget.onFolderUpdated!();
                      }
                    },
                    onFileUpdated: () {
                      _loadFolderContents(resetPage: true);
                      // ✅ إعادة تحميل في الصفحة الأم (folders_view) لتحديث عدد الملفات
                      if (widget.onFolderUpdated != null) {
                        widget.onFolderUpdated!();
                      }
                    },
                  )
                : FilesListView(
                    items: _convertFilesToListFormat(files),
                    onItemTap: (item) => _handleFileTap(item),
                    onFileRemoved: () {
                      _loadFolderContents(resetPage: true);
                      // ✅ إعادة تحميل في الصفحة الأم (folders_view) لتحديث عدد الملفات
                      if (widget.onFolderUpdated != null) {
                        widget.onFolderUpdated!();
                      }
                    },
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
              child: _buildLoadingMoreShimmer(),
            ),
        ],
      ),
    );
  }

  // ✅ استخدام FolderFileCard بدلاً من _buildFolderCard المخصص
  Widget _buildFolderCard(Map<String, dynamic> folder) {
    final name = folder['name'] as String? ?? 'بدون اسم';
    final filesCount = folder['filesCount'] ?? 0;
    final folderColor = widget.folderColor ?? Colors.blue;
    final folderSize = folder['size'] ?? 0;
    final isStarred = folder['isStarred'] == true;

    // ✅ حساب الحجم بشكل صحيح
    String sizeText;
    if (folderSize is num) {
      sizeText = _formatBytes(folderSize.toInt());
    } else {
      sizeText = _formatBytes(0);
    }

    return FolderFileCard(
      title: name,
      fileCount: filesCount is int
          ? filesCount
          : (filesCount is num ? filesCount.toInt() : 0),
      size: sizeText,
      color: folderColor,
      showFileCount: true,
      isStarred: isStarred,
      folderData: folder,
      onOpenTap: () => _handleItemTap(folder),
      onInfoTap: () => _showFolderDetailsDialog(folder),
      onRenameTap: () => _showRenameDialog(context, folder),
      onShareTap: () => _showShareFolderDialog(folder),
      onMoveTap: () => _showMoveFolderDialog(folder),
      onFavoriteTap: () => _toggleFolderStar(folder),
      onDeleteTap: () => _showDeleteFolderDialog(folder),
      onProtectTap: () => _showProtectFolderDialog(folder),
    );
  }

  // ✅ أضف دالة عرض تفاصيل المجلد:
  Future<void> _showFolderDetailsDialog(Map<String, dynamic> folder) async {
    if (!mounted) return;

    // ✅ التحقق من كلمة السر قبل عرض التفاصيل
    final hasAccess = await FolderProtectionHelper.verifyAccessBeforeAction(
      context: context,
      folder: folder,
      actionName: 'عرض التفاصيل',
    );

    if (!hasAccess) {
      return; // ✅ المستخدم لم يتحقق أو ألغى العملية
    }

    if (!mounted) return;

    final folderId = _getFolderId(folder);
    if (folderId == null) {
      if (mounted) {
        _showSnackBar('معرف المجلد غير متوفر', Colors.red);
      }
      return;
    }

    if (!mounted) return;
    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );

    final folderDetails = await folderController.getFolderDetails(
      folderId: folderId,
    );

    if (!mounted) return;

    if (folderDetails == null || folderDetails['folder'] == null) {
      if (mounted) {
        _showSnackBar('فشل جلب معلومات المجلد', Colors.red);
      }
      return;
    }

    final folderData = folderDetails['folder'] as Map<String, dynamic>;
    final folderColor = widget.folderColor ?? Colors.blue;

    if (!mounted) return;
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

  // ✅ استخراج folderId من المجلد (يدعم _id و folderId)
  String? _getFolderId(Map<String, dynamic> folder) {
    // ✅ محاولة استخراج folderId بطرق مختلفة
    if (folder['folderId'] != null) {
      final folderId = folder['folderId'];
      if (folderId is String) return folderId;
      if (folderId is Map) return folderId['_id']?.toString();
    }
    if (folder['_id'] != null) {
      return folder['_id'].toString();
    }
    return null;
  }

  // ✅ أضف دالة إعادة التسمية:
  Future<void> _showRenameDialog(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    if (!mounted) return;

    // ✅ التحقق من كلمة السر قبل التعديل
    final hasAccess = await FolderProtectionHelper.verifyAccessBeforeAction(
      context: context,
      folder: folder,
      actionName: 'تعديل',
    );

    if (!hasAccess) {
      return; // ✅ المستخدم لم يتحقق أو ألغى العملية
    }

    if (!mounted) return;

    final folderName =
        folder['title']?.toString() ??
        folder['name']?.toString() ??
        S.of(context).folder;
    final folderId = _getFolderId(folder);
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
      if (mounted) {
        // ✅ استخدام GlobalKey بدلاً من ScaffoldMessenger.maybeOf(context)
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(S.of(context).folderIdNotFound)),
        );
      }
      return;
    }

    if (!mounted) return;
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
                // ✅ استخدام GlobalKey بدلاً من ScaffoldMessenger.of(context)
                rootScaffoldMessengerKey.currentState?.showSnackBar(
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

  // ✅ Dialog لقفل/إلغاء قفل المجلد
  Future<void> _showProtectFolderDialog(Map<String, dynamic> folder) async {
    if (!mounted) return;

    final folderId = _getFolderId(folder);
    if (folderId == null) {
      if (mounted) {
        _showSnackBar('معرف المجلد غير متوفر', Colors.red);
      }
      return;
    }

    final folderName = folder['name'] ?? 'المجلد';
    final isProtected = FolderProtectionService.isFolderProtected(folder);

    if (isProtected) {
      // ✅ إذا كان المجلد محمياً، نعرض خيار إزالة الحماية
      final passwordController = TextEditingController();
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('إزالة حماية المجلد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('يرجى إدخال كلمة السر لإزالة الحماية:'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة السر',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final password = passwordController.text;
                if (password.isEmpty) {
                  // ✅ استخدام GlobalKey بدلاً من ScaffoldMessenger.maybeOf(context)
                  rootScaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(
                      content: Text('⚠️ يرجى إدخال كلمة السر'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final removeResult =
                    await FolderProtectionService.removeFolderProtection(
                      folderId: folderId,
                      password: password,
                    );

                if (!context.mounted) return;

                if (removeResult['success'] == true) {
                  Navigator.pop(context, true);
                  if (mounted) {
                    // ✅ استخدام GlobalKey بدلاً من ScaffoldMessenger.of(context)
                    rootScaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text(
                          removeResult['message'] ?? '✅ تم إزالة الحماية بنجاح',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadFolderContents(resetPage: true);
                  }
                } else {
                  // ✅ استخدام GlobalKey بدلاً من ScaffoldMessenger.maybeOf(context)
                  rootScaffoldMessengerKey.currentState?.showSnackBar(
                    SnackBar(
                      content: Text(
                        removeResult['message'] ?? '❌ فشل إزالة الحماية',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('إزالة الحماية'),
            ),
          ],
        ),
      );

      passwordController.dispose();
    } else {
      // ✅ إذا لم يكن محمياً، نعرض Dialog لتعيين الحماية
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => SetFolderProtectionDialog(
          folderId: folderId,
          folderName: folderName,
          isCurrentlyProtected: false,
        ),
      );

      if (result == true && mounted) {
        // ✅ تم تفعيل الحماية بنجاح، إعادة تحميل المحتويات
        _loadFolderContents(resetPage: true);
      }
    }
  }

  // ✅ أضف دالة الحذف:
  Future<void> _showDeleteFolderDialog(Map<String, dynamic> folder) async {
    if (!mounted) return;

    // ✅ التحقق من كلمة السر قبل الحذف
    final hasAccess = await FolderProtectionHelper.verifyAccessBeforeAction(
      context: context,
      folder: folder,
      actionName: 'حذف',
    );

    if (!hasAccess) {
      return; // ✅ المستخدم لم يتحقق أو ألغى العملية
    }

    if (!mounted) return;

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
              await _deleteFolder(folder);
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

  // ✅ إضافة/إزالة من المفضلة
  Future<void> _toggleFolderStar(Map<String, dynamic> folder) async {
    if (!mounted) return;

    final folderId = _getFolderId(folder);
    if (folderId == null) {
      if (mounted) {
        _showSnackBar('معرف المجلد غير متوفر', Colors.red);
      }
      return;
    }

    try {
      if (!mounted) return;
      final folderController = Provider.of<FolderController>(
        context,
        listen: false,
      );

      final result = await folderController.toggleStarFolder(
        folderId: folderId,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final updatedIsStarred = result['isStarred'] as bool? ?? false;
        final updatedFolder = result['folder'] as Map<String, dynamic>?;

        // ✅ تحديث البيانات المحلية مباشرة بدون refresh
        // ✅ تحديث folder مباشرة
        folder['isStarred'] = updatedIsStarred;
        if (updatedFolder != null) {
          // ✅ تحديث جميع البيانات من الـ response
          folder.addAll(updatedFolder);
        }

        // ✅ تحديث folderData أيضاً إذا كان موجوداً
        final folderData = folder['folderData'] as Map<String, dynamic>?;
        if (folderData != null) {
          folderData['isStarred'] = updatedIsStarred;
          if (updatedFolder != null) {
            folderData.addAll(updatedFolder);
          }
        }

        // ✅ تحديث المجلد في قائمة contents
        final index = contents.indexWhere((item) {
          final itemId = _getFolderId(item);
          return itemId == folderId;
        });

        if (index != -1 && mounted) {
          setState(() {
            contents[index]['isStarred'] = updatedIsStarred;
            if (updatedFolder != null) {
              contents[index].addAll(updatedFolder);
            }
            // ✅ تحديث folderData في contents أيضاً
            final itemFolderData =
                contents[index]['folderData'] as Map<String, dynamic>?;
            if (itemFolderData != null) {
              itemFolderData['isStarred'] = updatedIsStarred;
              if (updatedFolder != null) {
                itemFolderData.addAll(updatedFolder);
              }
            }
          });
        }

        if (mounted) {
          _showSnackBar(
            updatedIsStarred ? 'تمت الإضافة للمفضلة' : 'تمت الإزالة من المفضلة',
            updatedIsStarred ? Colors.green : Colors.orange,
          );
        }
      } else {
        if (mounted) {
          _showSnackBar(
            result['message'] ?? 'فشل تحديث حالة المفضلة',
            Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('حدث خطأ: ${e.toString()}', Colors.red);
      }
    }
  }

  // ✅ مشاركة المجلد الفرعي
  Future<void> _showShareFolderDialog(Map<String, dynamic> folder) async {
    if (!mounted) return;

    final folderId = _getFolderId(folder);
    if (folderId == null) {
      if (mounted) {
        _showSnackBar('معرف المجلد غير متوفر', Colors.red);
      }
      return;
    }

    final folderName =
        folder['name']?.toString() ?? folder['title']?.toString() ?? 'مجلد';

    if (!mounted) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ShareFolderWithRoomPage(folderId: folderId, folderName: folderName),
      ),
    );

    if (mounted && result == true) {
      _loadFolderContents(resetPage: true);
    }
  }

  // ✅ نقل المجلد
  Future<void> _showMoveFolderDialog(Map<String, dynamic> folder) async {
    if (!mounted) return;

    // ✅ التحقق من كلمة السر قبل النقل
    final hasAccess = await FolderProtectionHelper.verifyAccessBeforeAction(
      context: context,
      folder: folder,
      actionName: 'نقل',
    );

    if (!hasAccess) {
      return; // ✅ المستخدم لم يتحقق أو ألغى العملية
    }

    if (!mounted) return;

    final folderId = _getFolderId(folder);
    if (folderId == null) {
      if (mounted) {
        _showSnackBar('معرف المجلد غير متوفر', Colors.red);
      }
      return;
    }

    // ✅ إعداد folder مع folderId صحيح للدالة المساعدة
    final folderForMove = {
      ...folder,
      'folderId': folderId,
      'title': folder['name'] ?? folder['title'] ?? 'مجلد',
    };

    if (!mounted) return;
    // ✅ استخدام الدالة المساعدة من starred_folders_page_helpers
    await showMoveFolderDialogHelper(
      context,
      folderForMove,
      onUpdated: () {
        // ✅ إعادة تحميل المحتويات بعد النقل
        if (mounted) {
          _loadFolderContents(resetPage: true);
        }
        // ✅ إعادة تحميل في الصفحة الأم (folders_view) لتحديث عدد الملفات
        if (mounted && widget.onFolderUpdated != null) {
          widget.onFolderUpdated!();
        }
      },
    );
  }

  // ✅ حذف المجلد
  Future<void> _deleteFolder(Map<String, dynamic> folder) async {
    if (!mounted) return;

    final folderId = _getFolderId(folder);
    if (folderId == null) {
      if (mounted) {
        _showSnackBar('معرف المجلد غير متوفر', Colors.red);
      }
      return;
    }

    try {
      if (!mounted) return;
      final folderController = Provider.of<FolderController>(
        context,
        listen: false,
      );

      final success = await folderController.deleteFolder(folderId: folderId);

      if (!mounted) return;

      if (success) {
        if (mounted) {
          _showSnackBar('تم حذف المجلد بنجاح', Colors.green);
        }
        // ✅ إعادة تحميل المحتويات لإزالة المجلد المحذوف
        if (mounted) {
          _loadFolderContents(resetPage: true);
        }
        // ✅ إعادة تحميل في الصفحة الأم (folders_view) لتحديث عدد الملفات
        if (mounted && widget.onFolderUpdated != null) {
          widget.onFolderUpdated!();
        }
      } else {
        if (mounted) {
          _showSnackBar(
            folderController.errorMessage ?? 'فشل حذف المجلد',
            Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('حدث خطأ: ${e.toString()}', Colors.red);
      }
    }
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
        // ✅ استخدام GlobalKey بدلاً من ScaffoldMessenger.of(context)
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(S.of(scaffoldContext).folderUpdatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        // ✅ إعادة تحميل المحتويات بعد التحديث الناجح
        if (mounted) {
          _loadFolderContents(resetPage: true);
        }
      } else {
        // ✅ استخدام GlobalKey بدلاً من ScaffoldMessenger.of(context)
        rootScaffoldMessengerKey.currentState?.showSnackBar(
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
