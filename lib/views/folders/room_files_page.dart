import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/views/fileViewer/pdfViewer.dart';
import 'package:filevo/views/fileViewer/VideoViewer.dart';
import 'package:filevo/views/fileViewer/audioPlayer.dart';
import 'package:filevo/views/fileViewer/imageViewer.dart';
import 'package:filevo/views/fileViewer/office_file_opener.dart';
import 'package:filevo/views/fileViewer/textViewer.dart';
import 'package:filevo/config/api_config.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:filevo/responsive.dart';
import 'package:filevo/views/fileViewer/FilesGridView1.dart';

class RoomFilesPage extends StatefulWidget {
  final String roomId;

  const RoomFilesPage({super.key, required this.roomId});

  @override
  State<RoomFilesPage> createState() => _RoomFilesPageState();
}

class _RoomFilesPageState extends State<RoomFilesPage> {
  Map<String, dynamic>? roomData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoomData();
    });
  }

  Future<void> _loadRoomData() async {
    if (!mounted) return;

    final roomController = Provider.of<RoomController>(context, listen: false);
    final response = await roomController.getRoomById(widget.roomId);
     print('RoomFilesPage: Loaded room data: $response');
    if (mounted) {
      setState(() {
        roomData = response?['room'];
        isLoading = false;
      });
    }
  }

  String _getFileUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    if (path.startsWith('http')) {
      return path;
    }

    String cleanPath = path.replaceAll(r'\', '/').replaceAll('//', '/');
    while (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    final base = ApiConfig.baseUrl.replaceAll('/api/v1', '');
    String baseClean = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    String finalUrl = '$baseClean/$cleanPath';

    return finalUrl;
  }

  Future<void> _openFile(Map<String, dynamic> fileData, String? fileId) async {
    if (fileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('معرف الملف غير متوفر'), backgroundColor: Colors.red),
      );
      return;
    }

    final filePath = fileData['path']?.toString();
    if (filePath == null || filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('رابط الملف غير متوفر'), backgroundColor: Colors.orange),
      );
      return;
    }

    final fileName = fileData['name']?.toString() ?? 'ملف';
    final name = fileName.toLowerCase();
    final url = _getFileUrl(filePath);

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('رابط غير صالح'), backgroundColor: Colors.red),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final client = http.Client();
      final response = await client.get(Uri.parse(url), headers: {'Range': 'bytes=0-511'});
      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 206) {
        final bytes = response.bodyBytes;
        final isPdf = _isValidPdf(bytes);

        if (name.endsWith('.pdf')) {
          if (!isPdf) {
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('ملف غير مدعوم'),
                  content: Text('هذا الملف ليس PDF صالح أو قد يكون تالفاً.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _openAsTextFile(url, fileName);
                      },
                      child: Text('فتح كنص'),
                    ),
                  ],
                ),
              );
            }
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PdfViewerPage(pdfUrl: url, fileName: fileName)),
          );
        }
        else if (name.endsWith('.mp4') || name.endsWith('.mov') || name.endsWith('.mkv') ||
            name.endsWith('.avi') || name.endsWith('.wmv')) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => VideoViewer(url: url)));
        }
        else if (name.endsWith('.jpg') || name.endsWith('.jpeg') || name.endsWith('.png') ||
            name.endsWith('.gif') || name.endsWith('.bmp') || name.endsWith('.webp')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageViewer(
                imageUrl: url,
                roomId: widget.roomId,
                fileId: fileId,
              ),
            ),
          );
        }
        else if (TextViewerPage.isTextFile(fileName)) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(child: CircularProgressIndicator()),
          );
          try {
            final fullResponse = await http.get(Uri.parse(url));
            if (mounted) Navigator.pop(context);
            if (fullResponse.statusCode == 200) {
              final tempDir = await getTemporaryDirectory();
              final tempFile = File('${tempDir.path}/$fileName');
              await tempFile.writeAsBytes(fullResponse.bodyBytes);
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => TextViewerPage(filePath: tempFile.path, fileName: fileName)),
                );
              }
            }
          } catch (e) {
            if (mounted) Navigator.pop(context);
          }
        }
        else if (name.endsWith('.mp3') ||
            name.endsWith('.wav') ||
            name.endsWith('.aac') ||
            name.endsWith('.ogg')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AudioPlayerPage(audioUrl: url, fileName: fileName)),
          );
        }
        else {
          final token = await StorageService.getToken();
          await OfficeFileOpener.openAnyFile(url: url, context: context, token: token);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('الملف غير متاح (خطأ ${response.statusCode})'),
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
            content: Text('خطأ في تحميل الملف: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isValidPdf(List<int> bytes) {
    if (bytes.length < 4) return false;
    final pdfHeader = [0x25, 0x50, 0x44, 0x46]; // %PDF
    for (int i = 0; i < 4; i++) {
      if (bytes[i] != pdfHeader[i]) return false;
    }
    return true;
  }

  Future<void> _openAsTextFile(String url, String fileName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    try {
      final fullResponse = await http.get(Uri.parse(url));
      if (mounted) Navigator.pop(context);
      if (fullResponse.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(fullResponse.bodyBytes);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => TextViewerPage(filePath: tempFile.path, fileName: fileName)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في فتح الملف: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
        return Icons.videocam;
      case 'mp3':
      case 'wav':
      case 'flac':
      case 'aac':
      case 'ogg':
        return Icons.audiotrack;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip;
      default:
        if (TextViewerPage.isTextFile(fileName)) return Icons.description;
        return Icons.insert_drive_file;
    }
  }

  Color _getFileIconColor(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Colors.blue;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
        return Colors.red;
      case 'mp3':
      case 'wav':
      case 'flac':
      case 'aac':
      case 'ogg':
        return Colors.purple;
      case 'pdf':
        return Color(0xFFF44336);
      case 'doc':
      case 'docx':
        return Colors.brown;
      case 'zip':
      case 'rar':
      case '7z':
        return Colors.orange;
      default:
        return Color(0xFF607D8B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الملفات المشتركة',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 18.0,
              tablet: 20.0,
              desktop: 22.0,
            ),
          ),
        ),
        backgroundColor: Color(0xff28336f),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            iconSize: ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 24.0,
              tablet: 26.0,
              desktop: 28.0,
            ),
            onPressed: () {
              setState(() => isLoading = true);
              _loadRoomData();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : roomData == null
              ? Center(child: Text('فشل تحميل بيانات الغرفة'))
              : RefreshIndicator(
                  onRefresh: _loadRoomData,
                  child: _buildFilesList(),
                ),
    );
  }

  Widget _buildFilesList() {
    final files = roomData!['files'] as List? ?? [];

    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_drive_file_outlined,
              size: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 64.0,
                tablet: 80.0,
                desktop: 96.0,
              ),
              color: Colors.grey,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 16.0,
              tablet: 20.0,
              desktop: 24.0,
            )),
            Text(
              'لا توجد ملفات مشتركة',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 18.0,
                  tablet: 20.0,
                  desktop: 22.0,
                ),
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 8.0,
              tablet: 12.0,
              desktop: 16.0,
            )),
            Text(
              'قم بمشاركة ملفات مع هذه الغرفة',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 14.0,
                  tablet: 16.0,
                  desktop: 18.0,
                ),
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // ✅ تحويل الملفات إلى format مناسب لـ FilesGrid (Grid View)
    final displayFiles = files.map((file) {
      final fileIdRef = file['fileId'];
      final fileData = fileIdRef is Map<String, dynamic> 
          ? fileIdRef 
          : <String, dynamic>{};
      final fileName = fileData['name']?.toString() ?? 'ملف غير معروف';
      final fileId = fileData['_id']?.toString() ?? 
                     (fileIdRef is String ? fileIdRef : fileIdRef?.toString());
      final filePath = fileData['path']?.toString() ?? '';
      final size = fileData['size'] ?? 0;
      final category = fileData['category']?.toString() ?? '';
      final createdAt = fileData['createdAt'];
      final updatedAt = fileData['updatedAt'];
      final sharedAt = file['sharedAt'];
      
      // ✅ استخراج معلومات من شارك الملف من room data
      final sharedBy = _getSharedByInfo(file, fileData);
      
      return {
        'name': fileName,
        'url': _getFileUrl(filePath),
        'type': _getFileType(fileName),
        'size': _formatSize(size),
        'category': category, // ✅ التصنيف
        'createdAt': createdAt, // ✅ تاريخ الإنشاء
        'updatedAt': updatedAt, // ✅ تاريخ التعديل
        'sharedAt': sharedAt, // ✅ تاريخ المشاركة في الروم
        'path': filePath,
        'originalData': fileData,
        'originalName': fileName,
        'fileId': fileId,
        'sharedBy': sharedBy, // ✅ معلومات من شارك الملف من أعضاء الروم
      };
    }).toList();

    return FilesGrid(
      files: displayFiles,
      roomId: widget.roomId, // ✅ تمرير roomId لاستخدام getSharedFileDetailsInRoom
      onFileTap: (file) {
        final fileData = file['originalData'] as Map<String, dynamic>? ?? file;
        final fileId = file['fileId'] as String?;
        _openFile(fileData, fileId);
      },
      onFileRemoved: () {
        // ✅ إعادة تحميل بيانات الغرفة بعد إزالة الملف
        _loadRoomData();
      },
    );
  }

  String _getFileType(String fileName) {
    final name = fileName.toLowerCase();
    if (name.endsWith('.pdf')) return 'pdf';
    if (name.endsWith('.mp4') || name.endsWith('.mov') || name.endsWith('.mkv') ||
        name.endsWith('.avi') || name.endsWith('.wmv')) return 'video';
    if (name.endsWith('.jpg') || name.endsWith('.jpeg') || name.endsWith('.png') ||
        name.endsWith('.gif') || name.endsWith('.bmp') || name.endsWith('.webp')) return 'image';
    if (name.endsWith('.mp3') || name.endsWith('.wav') || name.endsWith('.aac') ||
        name.endsWith('.ogg')) return 'audio';
    if (TextViewerPage.isTextFile(fileName)) return 'text';
    return 'file';
  }

  String _formatSize(dynamic size) {
    if (size == null) return '—';
    try {
      final bytes = size is int ? size : (size is num ? size.toInt() : int.tryParse(size.toString()) ?? 0);
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
      return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    } catch (e) {
      return '—';
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '—';
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return '—';
    }
  }

  // ✅ استخراج معلومات من شارك الملف/المجلد من room data
  String? _getSharedByInfo(Map<String, dynamic> sharedItem, Map<String, dynamic> itemData) {
    // ✅ 1. من sharedItem مباشرة (من room data - sharedBy)
    if (sharedItem['sharedBy'] != null) {
      final sharedBy = sharedItem['sharedBy'];
      if (sharedBy is Map<String, dynamic>) {
        return sharedBy['name'] ?? sharedBy['email'] ?? 'مستخدم';
      }
      if (sharedBy is String) {
        // ✅ إذا كان sharedBy هو ID، ابحث في room members
        if (roomData != null && roomData!['members'] != null) {
          final members = roomData!['members'] as List?;
          if (members != null) {
            for (final member in members) {
              final userId = member['user'];
              final userIdStr = userId is Map ? userId['_id']?.toString() : userId?.toString();
              if (userIdStr == sharedBy) {
                final user = userId is Map ? userId : member['user'];
                if (user is Map<String, dynamic>) {
                  return user['name'] ?? user['email'] ?? 'مستخدم';
                }
              }
            }
          }
        }
        return null;
      }
    }
    
    // ✅ 2. من userId في itemData (fallback)
    if (itemData['userId'] != null) {
      final userId = itemData['userId'];
      if (userId is Map<String, dynamic>) {
        return userId['name'] ?? userId['email'] ?? 'مستخدم';
      }
    }
    
    // ✅ 3. من owner في itemData (fallback)
    if (itemData['owner'] != null) {
      final owner = itemData['owner'];
      if (owner is Map<String, dynamic>) {
        return owner['name'] ?? owner['email'] ?? 'مستخدم';
      }
    }
    
    return null;
  }
}

