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
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

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
          await OfficeFileOpener.openAnyFile(url: url, fileName: fileName, context: context);
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
    final name = fileName.toLowerCase();
    if (name.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (name.endsWith('.mp4') || name.endsWith('.mov') || name.endsWith('.mkv') ||
        name.endsWith('.avi') || name.endsWith('.wmv')) return Icons.videocam;
    if (name.endsWith('.jpg') || name.endsWith('.jpeg') || name.endsWith('.png') ||
        name.endsWith('.gif') || name.endsWith('.bmp') || name.endsWith('.webp')) return Icons.image;
    if (name.endsWith('.mp3') || name.endsWith('.wav') || name.endsWith('.aac') ||
        name.endsWith('.ogg')) return Icons.audiotrack;
    if (TextViewerPage.isTextFile(fileName)) return Icons.description;
    return Icons.insert_drive_file;
  }

  Color _getFileIconColor(String fileName) {
    final name = fileName.toLowerCase();
    if (name.endsWith('.pdf')) return Color(0xFFF44336);
    if (name.endsWith('.mp4') || name.endsWith('.mov') || name.endsWith('.mkv') ||
        name.endsWith('.avi') || name.endsWith('.wmv')) return Color(0xFFE91E63);
    if (name.endsWith('.jpg') || name.endsWith('.jpeg') || name.endsWith('.png') ||
        name.endsWith('.gif') || name.endsWith('.bmp') || name.endsWith('.webp')) return Color(0xFF4CAF50);
    if (name.endsWith('.mp3') || name.endsWith('.wav') || name.endsWith('.aac') ||
        name.endsWith('.ogg')) return Color(0xFF9C27B0);
    return Color(0xFF607D8B);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الملفات المشتركة'),
        backgroundColor: Color(0xff28336f),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
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
            Icon(Icons.insert_drive_file_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد ملفات مشتركة',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'قم بمشاركة ملفات مع هذه الغرفة',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        final fileIdRef = file['fileId'];
        final fileData = fileIdRef is Map<String, dynamic> 
            ? fileIdRef 
            : <String, dynamic>{};
        final fileName = fileData['name']?.toString() ?? 'ملف غير معروف';
        final fileId = fileData['_id']?.toString() ?? 
                       (fileIdRef is String ? fileIdRef : fileIdRef?.toString());
        final sharedAt = file['sharedAt'];

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getFileIconColor(fileName).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getFileIcon(fileName),
                color: _getFileIconColor(fileName),
              ),
            ),
            title: Text(
              fileName,
              style: TextStyle(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                if (fileData['size'] != null)
                  Text(
                    _formatSize(fileData['size']),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                if (sharedAt != null)
                  Text(
                    'مشارك في: ${_formatDate(sharedAt)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () => _openFile(fileData, fileId),
          ),
        );
      },
    );
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
}

