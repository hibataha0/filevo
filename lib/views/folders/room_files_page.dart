import 'dart:io';
import 'dart:async';
import 'dart:convert';
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
import 'package:open_filex/open_filex.dart';
import 'package:filevo/views/fileViewer/textViewer.dart';
import 'package:filevo/config/api_config.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/services/api_endpoints.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:filevo/responsive.dart';
import 'package:filevo/views/fileViewer/FilesGridView1.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RoomFilesPage extends StatefulWidget {
  final String roomId;

  const RoomFilesPage({super.key, required this.roomId});

  @override
  State<RoomFilesPage> createState() => _RoomFilesPageState();
}

class _RoomFilesPageState extends State<RoomFilesPage> {
  Map<String, dynamic>? roomData;
  bool isLoading = true;
  int _refreshTimestamp =
      DateTime.now().millisecondsSinceEpoch; // ✅ لتحديث الصور بعد التعديل

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoomData();
    });
  }

  Future<void> _loadRoomData() async {
    if (!mounted) return;

    // ✅ تحديث timestamp عند كل تحميل للبيانات لضمان تحديث الصور
    _refreshTimestamp = DateTime.now().millisecondsSinceEpoch;

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

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
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
    String baseClean = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    String finalUrl = '$baseClean/$cleanPath';

    return finalUrl;
  }

  /// ✅ فتح الملف باستخدام endpoint viewRoomFile
  Future<void> _openFileViaEndpoint(
    String fileId,
    Map<String, dynamic> fileData,
  ) async {
    print(
      '📥 [openFileViaEndpoint] Opening file via endpoint - fileId: $fileId',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).pleaseLoginAgain),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // ✅ استخدام endpoint جديد لتحميل الملف
      final url =
          "${ApiConfig.baseUrl}${ApiEndpoints.viewRoomFile(widget.roomId, fileId)}";
      print('🌐 GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (mounted) Navigator.pop(context);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        // ✅ إعادة تحميل بيانات الروم مباشرة بعد نجاح الطلب (ليختفي الملف من القائمة فوراً)
        // ✅ نستخدم scheduleMicrotask لضمان التنفيذ الفوري في الدورة التالية
        scheduleMicrotask(() {
          if (mounted) {
            _loadRoomData();
          }
        });

        // ✅ حفظ الملف مؤقتاً وفتحه
        final fileName =
            fileData['name']?.toString() ??
            fileData['fileId']?['name']?.toString() ??
            'ملف';
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(response.bodyBytes);

        print('✅ File saved to: ${tempFile.path}');

        // ✅ فتح الملف حسب نوعه
        final name = fileName.toLowerCase();

        if (name.endsWith('.pdf')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PdfViewerPage(pdfUrl: tempFile.path, fileName: fileName),
            ),
          );
        } else if (name.endsWith('.mp4') ||
            name.endsWith('.mov') ||
            name.endsWith('.mkv')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VideoViewer(url: tempFile.path)),
          );
        } else if (name.endsWith('.jpg') ||
            name.endsWith('.jpeg') ||
            name.endsWith('.png') ||
            name.endsWith('.gif') ||
            name.endsWith('.bmp') ||
            name.endsWith('.webp')) {
          // ✅ الانتظار للنتيجة وإعادة تحميل البيانات إذا تم التحديث
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => ImageViewer(
                imageUrl: tempFile.path,
                roomId: widget.roomId,
                fileId: fileId,
              ),
            ),
          );
          // ✅ إعادة تحميل بيانات الغرفة إذا تم تحديث الملف
          if (result == true && mounted) {
            _loadRoomData();
          }
        } else if (TextViewerPage.isTextFile(fileName)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TextViewerPage(filePath: tempFile.path, fileName: fileName),
            ),
          );
        } else if (name.endsWith('.mp3') ||
            name.endsWith('.wav') ||
            name.endsWith('.aac') ||
            name.endsWith('.ogg')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AudioPlayerPage(audioUrl: tempFile.path, fileName: fileName),
            ),
          );
        } else {
          // ✅ محاولة فتح الملف باستخدام OpenFilex مباشرة
          try {
            final result = await OpenFilex.open(tempFile.path);
            if (result.type != ResultType.done && mounted) {
              throw Exception(result.message);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context).failedToOpenFile(e.toString())),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      } else {
        // ✅ معالجة الأخطاء من الباك إند
        final errorBody = response.body;
        print('❌ Error response: $errorBody');

        String errorMessage = 'فشل تحميل الملف';
        try {
          final errorJson = jsonDecode(errorBody);
          errorMessage =
              errorJson['message'] ?? errorJson['error'] ?? errorMessage;
        } catch (e) {
          // ✅ إذا لم يكن JSON، استخدم الرسالة الأصلية
          if (response.statusCode == 403) {
            errorMessage =
                'You have already accessed this file. One-time share only.';
          } else if (response.statusCode == 404) {
            errorMessage = 'الملف غير موجود أو انتهت صلاحيته';
          }
        }

        // ✅ رمي exception ليتم التعامل معه في catch block
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Error opening file via endpoint: $e');
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

  Future<void> _openFile(Map<String, dynamic> fileData, String? fileId) async {
    print('📂 [openFile] Starting - fileId: $fileId');
    print('📂 [openFile] fileData: $fileData');

    if (fileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).fileIdNotAvailable),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ التحقق من أن الملف مشترك لمرة واحدة والوصول إليه
    final roomFiles = roomData?['files'] as List?;
    final fileEntry = roomFiles?.firstWhere((f) {
      final fId = f['fileId'];
      if (fId is Map) return fId['_id']?.toString() == fileId;
      if (fId is String) return fId == fileId;
      return fId?.toString() == fileId;
    }, orElse: () => null);

    final isOneTimeShare = fileEntry?['isOneTimeShare'] == true;

    // ✅ التحقق من أن المستخدم الحالي هو صاحب الملف الأصلي أو من شارك الملف
    // ✅ الباك إند يسمح لصاحب الملف ومن شاركه بفتح الملف بدون قيود
    final currentUserId = await StorageService.getUserId();
    bool isFileOwner = false;
    bool isSharedBy = false;

    if (currentUserId != null) {
      // ✅ 1. التحقق من sharedBy في fileEntry (من شارك الملف في الروم)
      final sharedBy = fileEntry?['sharedBy'];
      if (sharedBy != null) {
        String? sharedById;
        if (sharedBy is Map) {
          sharedById =
              sharedBy['_id']?.toString() ??
              sharedBy['id']?.toString() ??
              sharedBy.toString();
        } else {
          sharedById = sharedBy.toString();
        }
        isSharedBy = sharedById == currentUserId;
        print(
          '🔍 [openFile] Checking sharedBy: $sharedById == $currentUserId = $isSharedBy',
        );
      }

      // ✅ 2. التحقق من userId في fileData (صاحب الملف الأصلي)
      if (fileData['userId'] != null) {
        final userId = fileData['userId'];
        String? userIdStr;
        if (userId is Map) {
          userIdStr =
              userId['_id']?.toString() ??
              userId['id']?.toString() ??
              userId.toString();
        } else {
          userIdStr = userId.toString();
        }
        isFileOwner = userIdStr == currentUserId;
        print(
          '🔍 [openFile] Checking fileData userId: $userIdStr == $currentUserId = $isFileOwner',
        );
      }

      // ✅ 3. إذا لم يكن userId، تحقق من owner في fileData
      if (!isFileOwner && fileData['owner'] != null) {
        final owner = fileData['owner'];
        String? ownerId;
        if (owner is Map) {
          ownerId =
              owner['_id']?.toString() ??
              owner['id']?.toString() ??
              owner.toString();
        } else {
          ownerId = owner.toString();
        }
        isFileOwner = ownerId == currentUserId;
        print(
          '🔍 [openFile] Checking fileData owner: $ownerId == $currentUserId = $isFileOwner',
        );
      }

      // ✅ 4. إذا لم يكن في fileData، تحقق من fileId.userId
      if (!isFileOwner && fileData['fileId'] != null) {
        final fileIdData = fileData['fileId'];
        if (fileIdData is Map<String, dynamic>) {
          final fileUserId = fileIdData['userId'];
          if (fileUserId != null) {
            String? fileUserIdStr;
            if (fileUserId is Map) {
              fileUserIdStr =
                  fileUserId['_id']?.toString() ??
                  fileUserId['id']?.toString() ??
                  fileUserId.toString();
            } else {
              fileUserIdStr = fileUserId.toString();
            }
            isFileOwner = fileUserIdStr == currentUserId;
            print(
              '🔍 [openFile] Checking fileId.userId: $fileUserIdStr == $currentUserId = $isFileOwner',
            );
          }
        }
      }

      print(
        '🔍 [openFile] Final isFileOwner: $isFileOwner, isSharedBy: $isSharedBy',
      );
    }

    // ✅ إذا كان الملف مشترك لمرة واحدة
    if (isOneTimeShare) {
      // ✅ إذا كان المستخدم هو صاحب الملف الأصلي أو من شارك الملف، نفتحه مباشرة بدون endpoint
      // ✅ لأن endpoint viewRoomFile يسجل الوصول في accessedBy حتى لصاحب الملف
      // ✅ الباك إند يسمح لصاحب الملف ومن شاركه بفتح الملف بدون قيود
      if (isFileOwner || isSharedBy) {
        print(
          '📥 [openFile] One-time share file (owner or sharer), opening directly without endpoint',
        );
        // ✅ نفتح الملف مباشرة - نستمر في الكود بعد if block
      } else {
        // ✅ إذا لم يكن صاحب الملف، نستخدم endpoint viewRoomFile
        print(
          '📥 [openFile] One-time share file (not owner), using viewRoomFile endpoint',
        );

        try {
          await _openFileViaEndpoint(fileId, fileData);
          // ✅ إعادة تحميل البيانات تتم داخل _openFileViaEndpoint بعد نجاح الطلب
          return; // ✅ تم فتح الملف بنجاح
        } catch (e) {
          // ✅ إذا فشل فتح الملف (مثلاً المستخدم فتحه من قبل أو انتهت صلاحيته)
          // ✅ الباك إند سيرجع خطأ واضح
          print('❌ Error opening one-time file: $e');
          if (mounted) {
            final errorMessage = e.toString();
            // ✅ التحقق من رسائل الخطأ الشائعة
            if (errorMessage.contains('already accessed') ||
                errorMessage.contains('already viewed') ||
                errorMessage.contains('تم الوصول')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ ${S.of(context).fileAlreadyAccessed}'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            } else if (errorMessage.contains('expired') ||
                errorMessage.contains('منتهي')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ انتهت صلاحية الملف'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
              // ✅ إعادة تحميل البيانات لإزالة الملف من القائمة
              _loadRoomData();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '❌ ${S.of(context).errorAccessingFile}: ${e.toString()}',
                  ),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
          return; // ✅ منع فتح الملف في حالة الخطأ
        }
      }
    }

    // ✅ استخراج path من fileData - قد يكون في path مباشرة أو في fileId.path
    String? filePath = fileData['path']?.toString();

    // ✅ إذا لم يكن path موجوداً، حاول استخراجه من fileId
    if ((filePath == null || filePath.isEmpty) && fileData['fileId'] != null) {
      final fileIdData = fileData['fileId'];
      if (fileIdData is Map<String, dynamic>) {
        filePath = fileIdData['path']?.toString();
      }
    }

    // ✅ إذا لم نجد path، استخدم endpoint جديد لتحميل الملف
    if (filePath == null || filePath.isEmpty) {
      print('⚠️ [openFile] No path found, using view endpoint');
      // ✅ استخدام endpoint جديد لتحميل الملف
      await _openFileViaEndpoint(fileId, fileData);
      return;
    }

    final fileName =
        fileData['name']?.toString() ??
        fileData['fileId']?['name']?.toString() ??
        'ملف';
    final name = fileName.toLowerCase();
    final url = _getFileUrl(filePath);

    if (url.isEmpty) {
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
      builder: (context) => Center(child: CircularProgressIndicator()),
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
        } else if (TextViewerPage.isTextFile(fileName)) {
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
                    builder: (_) => TextViewerPage(
                      filePath: tempFile.path,
                      fileName: fileName,
                    ),
                  ),
                );
              }
            }
          } catch (e) {
            if (mounted) Navigator.pop(context);
          }
        } else if (name.endsWith('.mp3') ||
            name.endsWith('.wav') ||
            name.endsWith('.aac') ||
            name.endsWith('.ogg')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AudioPlayerPage(audioUrl: url, fileName: fileName),
            ),
          );
        } else {
          final token = await StorageService.getToken();
          await OfficeFileOpener.openAnyFile(
            url: url,
            context: context,
            token: token,
          );
        }
      } else {
        if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorLoadingFile(e.toString())),
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
              builder: (_) =>
                  TextViewerPage(filePath: tempFile.path, fileName: fileName),
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

      // ✅ Logging للتحقق من البيانات القادمة من الباك إند
      final tempFileId = fileData['_id']?.toString();
      if (tempFileId != null) {
        print(
          '🔍 [room_files_page] File $tempFileId - fileData keys: ${fileData.keys.toList()}',
        );
        print(
          '🔍 [room_files_page] File $tempFileId - fileData[\'isStarred\']: ${fileData['isStarred']}',
        );
      }

      final fileName = fileData['name']?.toString() ?? 'ملف غير معروف';
      final fileId =
          fileData['_id']?.toString() ??
          (fileIdRef is String ? fileIdRef : fileIdRef?.toString());
      final filePath = fileData['path']?.toString() ?? '';
      final size = fileData['size'] ?? 0;
      final category = fileData['category']?.toString() ?? '';
      final createdAt = fileData['createdAt'];
      final updatedAt = fileData['updatedAt'];
      // ✅ استخدام updatedAtTimestamp من الباك إند إذا كان متوفراً (من updateFileContent response)
      final updatedAtTimestamp = fileData['updatedAtTimestamp'];
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
          final expiryDate = expiresAt is String
              ? DateTime.parse(expiresAt)
              : expiresAt as DateTime;
          isExpired = DateTime.now().isAfter(expiryDate);
        } catch (e) {
          print('Error parsing expiry date: $e');
        }
      }

      // ✅ بناء URL للصورة - إذا كان filePath موجوداً، استخدمه، وإلا استخدم endpoint
      String imageUrl = '';
      if (filePath.isNotEmpty) {
        imageUrl = _getFileUrl(filePath);
      } else if (fileId != null && fileId.isNotEmpty) {
        // ✅ إذا لم يكن path موجوداً، استخدم endpoint viewRoomFile للصور
        if (_getFileType(fileName) == 'image') {
          imageUrl =
              "${ApiConfig.baseUrl}${ApiEndpoints.viewRoomFile(widget.roomId, fileId)}";
        }
      }

      // ✅ إضافة cache-busting للصور المشتركة
      // ✅ استخدام timestamp حالي مباشرة لضمان أن كل URL يكون فريداً
      // ✅ هذا يضمن أن الصورة يتم إعادة تحميلها حتى لو لم يتغير updatedAt من السيرفر
      if (imageUrl.isNotEmpty && _getFileType(fileName) == 'image') {
        // ✅ استخدام timestamp حالي مباشرة لضمان cache busting قوي
        final finalTimestamp = DateTime.now().millisecondsSinceEpoch;
        // ✅ إزالة أي timestamp موجود مسبقاً من URL
        final urlWithoutParams = imageUrl.split('?').first;
        imageUrl =
            '$urlWithoutParams?v=$finalTimestamp'; // ✅ استخدام timestamp حالي لضمان cache busting قوي
        print('🖼️ [RoomFilesPage] Image URL with cache busting: $imageUrl');
      }

      // ✅ التأكد من أن isStarred موجود في fileData
      final isStarred = fileData['isStarred'] ?? false;
      if (fileId != null) {
        print(
          '🔍 [room_files_page] File $fileId - isStarred from fileData: ${fileData['isStarred']}, final: $isStarred',
        );
      }

      return {
        'name': fileName,
        'url': imageUrl,
        'type': _getFileType(fileName),
        'size': _formatSize(size),
        'category': category,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'updatedAtTimestamp':
            updatedAtTimestamp ??
            (updatedAt != null
                ? (updatedAt is String
                      ? DateTime.parse(updatedAt).millisecondsSinceEpoch
                      : (updatedAt as DateTime).millisecondsSinceEpoch)
                : DateTime.now()
                      .millisecondsSinceEpoch), // ✅ إضافة updatedAtTimestamp للاستخدام في cache busting
        'sharedAt': sharedAt,
        'path': filePath,
        'originalData': {
          ...fileData,
          'isStarred': isStarred, // ✅ التأكد من وجود isStarred
        },
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
      extendBody: true, // ✅ إخفاء FloatingActionButton من MainPage
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
          // IconButton(
          //   icon: Icon(Icons.create_new_folder),
          //   iconSize: ResponsiveUtils.getResponsiveValue(
          //     context,
          //     mobile: 24.0,
          //     tablet: 26.0,
          //     desktop: 28.0,
          //   ),
          //   tooltip: 'إنشاء مجلد جديد',
          //   onPressed: () => _createNewFolder(),
          // ),
          // IconButton(
          //   icon: Icon(Icons.refresh),
          //   iconSize: ResponsiveUtils.getResponsiveValue(
          //     context,
          //     mobile: 24.0,
          //     tablet: 26.0,
          //     desktop: 28.0,
          //   ),
          //   onPressed: () {
          //     setState(() => isLoading = true);
          //     _loadRoomData();
          //   },
          // ),
        ],
      ),
      floatingActionButton: SizedBox.shrink(), // ✅ إخفاء FloatingActionButton
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : roomData == null
          ? Center(child: Text(S.of(context).failedToLoadRoomData))
          : SmartRefresher(
              controller: _refreshController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              onRefresh: () async {
                await _loadRoomData();
                _refreshController.refreshCompleted();
              },
              header: const WaterDropHeader(),
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
            SizedBox(
              height: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 16.0,
                tablet: 20.0,
                desktop: 24.0,
              ),
            ),
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
            SizedBox(
              height: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 8.0,
                tablet: 12.0,
                desktop: 16.0,
              ),
            ),
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
    final displayFiles = _mapFiles(files);

    return FilesGrid(
      files: displayFiles,
      roomId:
          widget.roomId, // ✅ تمرير roomId لاستخدام getSharedFileDetailsInRoom
      onFileTap: (file) {
        final fileData = file['originalData'] as Map<String, dynamic>? ?? file;
        final fileId = file['fileId'] as String?;
        _openFile(fileData, fileId);
      },
      onFileRemoved: () {
        // ✅ إعادة تحميل بيانات الغرفة بعد إزالة الملف
        _loadRoomData();
      },
      onFileUpdated: () {
        // ✅ إعادة تحميل بيانات الغرفة بعد تحديث الملف
        Future.microtask(() async {
          // ✅ مسح cache الصور قبل إعادة التحميل لضمان ظهور التعديلات
          PaintingBinding.instance.imageCache.clear();
          PaintingBinding.instance.imageCache.clearLiveImages();
          print(
            '✅ [RoomFilesPage] Image cache cleared, reloading room data...',
          );
          if (mounted) {
            await _loadRoomData();
          }
        });
      },
    );
  }

  String _getFileType(String fileName) {
    final name = fileName.toLowerCase();
    if (name.endsWith('.pdf')) return 'pdf';
    if (name.endsWith('.mp4') ||
        name.endsWith('.mov') ||
        name.endsWith('.mkv') ||
        name.endsWith('.avi') ||
        name.endsWith('.wmv'))
      return 'video';
    if (name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.gif') ||
        name.endsWith('.bmp') ||
        name.endsWith('.webp'))
      return 'image';
    if (name.endsWith('.mp3') ||
        name.endsWith('.wav') ||
        name.endsWith('.aac') ||
        name.endsWith('.ogg'))
      return 'audio';
    if (TextViewerPage.isTextFile(fileName)) return 'text';
    return 'file';
  }

  String _formatSize(dynamic size) {
    if (size == null) return '—';
    try {
      final bytes = size is int
          ? size
          : (size is num ? size.toInt() : int.tryParse(size.toString()) ?? 0);
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      if (bytes < 1073741824)
        return '${(bytes / 1048576).toStringAsFixed(1)} MB';
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

  // ✅ إنشاء مجلد جديد
  Future<void> _createNewFolder() async {
    final folderNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).createNewFolder),
        content: TextField(
          controller: folderNameController,
          decoration: InputDecoration(
            hintText: "أدخل اسم المجلد",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.create_new_folder),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final folderName = folderNameController.text.trim();
              if (folderName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('⚠️ ${S.of(context).pleaseEnterFolderName}'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext);
              final folderController = Provider.of<FolderController>(
                context,
                listen: false,
              );
              final success = await folderController.createFolder(
                name: folderName,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '📁 ${S.of(context).folderCreatedSuccessfully(folderName)}'
                          : '❌ ${folderController.errorMessage ?? S.of(context).failedToCreateFolder}',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: Text(S.of(context).create),
          ),
        ],
      ),
    );
  }

  // ✅ استخراج معلومات من شارك الملف/المجلد من room data
  String? _getSharedByInfo(
    Map<String, dynamic> sharedItem,
    Map<String, dynamic> itemData,
  ) {
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
              final userIdStr = userId is Map
                  ? userId['_id']?.toString()
                  : userId?.toString();
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
