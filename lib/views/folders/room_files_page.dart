import 'dart:io';
import 'package:filevo/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/constants/app_colors.dart';
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
        SnackBar(content: Text(S.of(context).fileIdNotAvailable), backgroundColor: Colors.red),
      );
      return;
    }

    // ✅ التحقق من أن الملف مشترك لمرة واحدة والوصول إليه
    final roomFiles = roomData?['files'] as List?;
    final fileEntry = roomFiles?.firstWhere(
      (f) {
        final fId = f['fileId'];
        if (fId is Map) return fId['_id']?.toString() == fileId;
        if (fId is String) return fId == fileId;
        return fId?.toString() == fileId;
      },
      orElse: () => null,
    );
    
    final isOneTimeShare = fileEntry?['isOneTimeShare'] == true;
    
    // ✅ إذا كان الملف مشترك لمرة واحدة، استدعي endpoint الوصول أولاً
    // ✅ هذا يسجل أن المستخدم الحالي قد فتح الملف
    if (isOneTimeShare) {
      // ✅ التحقق من أن المستخدم لم يفتح الملف من قبل
      final accessedBy = fileEntry?['accessedBy'] as List?;
      final currentUserId = await StorageService.getUserId();
      
      if (currentUserId != null && accessedBy != null) {
        final hasAccessed = accessedBy.any((access) {
          final accessUserId = access['user'];
          if (accessUserId is Map) return accessUserId['_id']?.toString() == currentUserId;
          if (accessUserId is String) return accessUserId == currentUserId;
          return accessUserId?.toString() == currentUserId;
        });
        
        if (hasAccessed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${S.of(context).fileAlreadyAccessed}'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          return; // ✅ منع فتح الملف
        }
      }
      
      // ✅ محاولة الوصول إلى الملف
      try {
        final roomController = Provider.of<RoomController>(context, listen: false);
        final response = await roomController.accessOneTimeFile(
          roomId: widget.roomId,
          fileId: fileId,
        );
        
        // ✅ التحقق من حالة انتهاء الصلاحية أولاً
        if (response['expired'] == true) {
          // ✅ إعادة تحميل بيانات الروم لإزالة الملف من القائمة
          await _loadRoomData();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${response['error'] ?? 'File access has expired'}'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return; // ✅ منع فتح الملف
        }

        // ✅ التحقق من نجاح الوصول (دعم الحقول الجديدة: oneTime, hideFromThisUser)
        final isOneTime = response['oneTime'] == true || response['wasOneTimeShare'] == true;
        final fileRemovedFromRoom = response['fileRemovedFromRoom'] == true;
        final hideFromThisUser = response['hideFromThisUser'] == true;
        
        if (response['message'] != null || response['success'] == true || isOneTime) {
          // ✅ تحديث fileData من الاستجابة إذا كانت متوفرة
          if (response['file'] != null) {
            fileData = response['file'] as Map<String, dynamic>;
          }
          
          // ✅ إذا كان ملف لمرة واحدة وتم تسجيل الوصول
          // ✅ الملف يبقى في Room ولكن سيختفي عن هذا المستخدم عند إعادة تحميل البيانات
          if (isOneTime && hideFromThisUser) {
            // ✅ عرض رسالة مناسبة
            if (mounted) {
              final message = response['message']?.toString() ?? 
                           '⚠️ تم الوصول للملف (مشاركة لمرة واحدة - سيختفي الملف من القائمة بعد التحديث)';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
            }
            
            // ✅ إعادة تحميل البيانات في الخلفية بعد فتح الملف (ليختفي الملف من القائمة)
            // ✅ الباك إند يفلتر الملف في getRoomDetails لأنه في accessedBy
            _loadRoomData();
            
            // ✅ الاستمرار في فتح الملف (الكود يستمر بعد if block)
          } else {
            // ✅ ملف عادي
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ تم فتح الملف'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
            
            // ✅ إعادة تحميل البيانات في الخلفية (بعد فتح الملف)
            _loadRoomData();
            
            // ✅ الاستمرار في فتح الملف (الكود يستمر بعد if block)
          }
        } else {
          // ✅ إذا فشل الوصول (مثلاً المستخدم فتحه من قبل)
          final errorMsg = response['message'] ?? response['error'] ?? S.of(context).cannotAccessFile;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ $errorMsg'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return; // ✅ منع فتح الملف
        }
      } catch (e) {
        print('Error accessing one-time file: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${S.of(context).errorAccessingFile}: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return; // ✅ منع فتح الملف في حالة الخطأ
      }
    }

    final filePath = fileData['path']?.toString();
    if (filePath == null || filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).fileUrlNotAvailable), backgroundColor: Colors.orange),
      );
      return;
    }

    final fileName = fileData['name']?.toString() ?? 'ملف';
    final name = fileName.toLowerCase();
    final url = _getFileUrl(filePath);

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).invalidUrl), backgroundColor: Colors.red),
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
                  title: Text(S.of(context).unsupportedFile),
                  content: Text(S.of(context).invalidPdfFile),
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

  List<Map<String, dynamic>> _mapFiles(List files) {
    // ✅ تحويل الملفات إلى format مناسب لـ FilesGrid (Grid View)
    // ✅ ملاحظة: الـ backend يقوم بفلترة الملفات المشتركة لمرة واحدة تلقائياً
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
      
      // ✅ التحقق من أن الملف مشترك لمرة واحدة
      final isOneTimeShare = file['isOneTimeShare'] == true;
      final expiresAt = file['expiresAt'];
      final accessCount = file['accessCount'] ?? 0;
      final accessedAt = file['accessedAt'];
      final accessedBy = file['accessedBy'] as List?;
      
      // ✅ معلومات إضافية لصاحب الملف (من الباك اند)
      final shareStatus = file['shareStatus']; // 'active' أو 'viewed_by_all'
      final totalEligibleMembers = file['totalEligibleMembers'];
      final viewedByAllAt = file['viewedByAllAt'];
      final allMembersViewed = file['allMembersViewed'] == true;
      
      // ✅ التحقق من انتهاء الصلاحية
      bool isExpired = false;
      if (expiresAt != null) {
        try {
          final expiryDate = expiresAt is String ? DateTime.parse(expiresAt) : expiresAt as DateTime;
          isExpired = DateTime.now().isAfter(expiryDate);
        } catch (e) {
          print('Error parsing expiry date: $e');
        }
      }
      
      return {
        'name': fileName,
        'url': _getFileUrl(filePath),
        'type': _getFileType(fileName),
        'size': _formatSize(size),
        'category': category,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'sharedAt': sharedAt,
        'path': filePath,
        'originalData': fileData,
        'originalName': fileName,
        'fileId': fileId,
        'sharedBy': sharedBy,
        'isOneTimeShare': isOneTimeShare,
        'expiresAt': expiresAt,
        'accessCount': accessCount,
        'accessedAt': accessedAt,
        'accessedBy': accessedBy,
        'isExpired': isExpired,
        'shareStatus': shareStatus, // 'active' أو 'viewed_by_all'
        'totalEligibleMembers': totalEligibleMembers,
        'viewedByAllAt': viewedByAllAt,
        'allMembersViewed': allMembersViewed,
      };
    }).toList();
    
    return displayFiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).sharedFiles,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 18.0,
              tablet: 20.0,
              desktop: 22.0,
            ),
          ),
        ),
        backgroundColor: AppColors.lightAppBar,
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
              S.of(context).noSharedFiles,
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
              S.of(context).shareFilesWithRoom,
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

    // ✅ تحويل الملفات إلى format مناسب لـ FilesGrid
    // ✅ ملاحظة: الـ backend يقوم بفلترة الملفات المشتركة لمرة واحدة تلقائياً
    final displayFiles = _mapFiles(files);
    
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

