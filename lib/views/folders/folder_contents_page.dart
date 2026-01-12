import 'dart:convert';
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
import 'package:filevo/dialogs/folder_protection_dialogs.dart';
import 'package:filevo/views/folders/starred_folders_page_helpers.dart';

class FolderContentsPage extends StatefulWidget {
  final String folderId;
  final String folderName;
  final Color? folderColor;
  final String? roomId; // ✅ معرف الغرفة للمجلدات المشتركة

  const FolderContentsPage({
    Key? key,
    required this.folderId,
    required this.folderName,
    this.folderColor,
    this.roomId, // ✅ معامل اختياري للغرفة
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
      
      // ✅ إذا كان المجلد مشترك في الروم، أرسل roomId كـ query parameter
      final result = await folderController.getFolderContents(
        folderId: widget.folderId,
        page: pageToLoad,
        limit: limit,
        roomId: widget.roomId, // ✅ تمرير roomId للمجلدات المشتركة
      );

      if (!mounted) return;
      
      // ✅ التحقق من خطأ 403 (مجلد محمي)
      if (result == null && folderController.errorMessage != null) {
        final errorMessage = folderController.errorMessage!.toLowerCase();
        if (errorMessage.contains('403') || 
            errorMessage.contains('protected') || 
            errorMessage.contains('verify access') ||
            errorMessage.contains('access denied')) {
          print('🔐 [FolderContentsPage] Protected folder detected (403), requesting password...');
          
          // ✅ جلب معلومات المجلد للتحقق من نوع الحماية
          try {
            final folderDetails = await folderController.getFolderDetails(
              folderId: widget.folderId,
            );
            
            String protectionType = 'password'; // ✅ افتراضي: password
            bool isProtected = true; // ✅ إذا حصل 403، المجلد محمي بالتأكيد
            
            if (folderDetails != null && folderDetails['folder'] != null) {
              final folderData = folderDetails['folder'] as Map<String, dynamic>;
              isProtected = folderData['isProtected'] == true;
              protectionType = folderData['protectionType']?.toString() ?? 'password';
              
              print('🔐 [FolderContentsPage] Folder protection info:');
              print('   - isProtected: $isProtected');
              print('   - protectionType: $protectionType');
            } else {
              print('⚠️ [FolderContentsPage] Could not get folder details, using default: password');
            }
            
            // ✅ طلب كلمة السر (حتى لو لم نتمكن من جلب نوع الحماية)
            final verifyResult = await showVerifyFolderAccessDialog(
              context,
              widget.folderId,
              widget.folderName,
              protectionType,
            );
            
            // ✅ إذا تم التحقق بنجاح، إعادة المحاولة
            if (verifyResult['success'] == true && mounted) {
              print('✅ [FolderContentsPage] Password verified, retrying...');
              // ✅ إعادة تحميل المحتويات بعد التحقق
              await _loadFolderContents(resetPage: true);
              return;
            } else {
              print('❌ [FolderContentsPage] Password verification failed');
              // ✅ العودة للصفحة السابقة
              if (mounted) {
                Navigator.pop(context);
              }
              return;
            }
          } catch (verifyError) {
            print('❌ [FolderContentsPage] Error verifying folder access: $verifyError');
            // ✅ حتى في حالة الخطأ، حاول طلب كلمة السر (افتراضي: password)
            try {
              final verifyResult = await showVerifyFolderAccessDialog(
                context,
                widget.folderId,
                widget.folderName,
                'password', // ✅ افتراضي: password
              );
              
              if (verifyResult['success'] == true && mounted) {
                print('✅ [FolderContentsPage] Password verified (fallback), retrying...');
                await _loadFolderContents(resetPage: true);
                return;
              }
            } catch (e) {
              print('❌ [FolderContentsPage] Error in fallback verification: $e');
            }
            
            if (mounted) {
              Navigator.pop(context);
            }
            return;
          }
        }
      }
      
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
      // ✅ التحقق من خطأ 403 (مجلد محمي)
      final errorString = e.toString();
      if (errorString.contains('403') || 
          errorString.contains('protected') || 
          errorString.contains('verify access')) {
        print('🔐 [FolderContentsPage] Protected folder detected (403), requesting password...');
        
        // ✅ جلب معلومات المجلد للتحقق من نوع الحماية
        try {
          final folderController = Provider.of<FolderController>(
            context,
            listen: false,
          );
          final folderDetails = await folderController.getFolderDetails(
            folderId: widget.folderId,
          );
          
          if (folderDetails != null && folderDetails['folder'] != null) {
            final folderData = folderDetails['folder'] as Map<String, dynamic>;
            final isProtected = folderData['isProtected'] == true;
            final protectionType = folderData['protectionType']?.toString() ?? 'none';
            
            if (isProtected && protectionType != 'none') {
              // ✅ طلب كلمة السر
              final result = await showVerifyFolderAccessDialog(
                context,
                widget.folderId,
                widget.folderName,
                protectionType,
              );
              
              // ✅ إذا تم التحقق بنجاح، إعادة المحاولة
              if (result['success'] == true && mounted) {
                print('✅ [FolderContentsPage] Password verified, retrying...');
                // ✅ إعادة تحميل المحتويات بعد التحقق
                await _loadFolderContents(resetPage: true);
                return;
              } else {
                print('❌ [FolderContentsPage] Password verification failed');
                // ✅ العودة للصفحة السابقة
                if (mounted) {
                  Navigator.pop(context);
                }
                return;
              }
            }
          }
        } catch (verifyError) {
          print('❌ [FolderContentsPage] Error verifying folder access: $verifyError');
        }
      }
      
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        // ✅ عرض رسالة خطأ للمستخدم
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorString.contains('403') || errorString.contains('protected')
                  ? 'المجلد محمي. يرجى التحقق من كلمة السر أولاً'
                  : 'خطأ في تحميل محتويات المجلد: ${e.toString()}'
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleItemTap(Map<String, dynamic> item) async {
    final type = item['type'] as String?;
    if (type == 'folder') {
      final folderId = item['_id'] as String?;
      final folderName = item['name'] as String? ?? S.of(context).folder;
      
      if (folderId == null) return;

      // ✅ التحقق من أن المجلد محمي
      final isProtected = item['isProtected'] == true;
      final protectionType = item['protectionType']?.toString() ?? 'none';

      // ✅ إذا كان المجلد محمي، نطلب كلمة السر أولاً
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
      // ✅ تمرير roomId إذا كان المجلد الأب مشترك في الروم
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FolderContentsPage(
              folderId: folderId,
              folderName: folderName,
              folderColor: widget.folderColor,
              roomId: widget.roomId, // ✅ تمرير roomId للمجلدات الفرعية
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

  // ✅ فتح ملف من الروم باستخدام endpoint الروم
  Future<void> _openRoomFile(String fileId, Map<String, dynamic> file) async {
    print('📥 [openRoomFile] Starting - fileId: $fileId, roomId: ${widget.roomId}');
    print('📥 [openRoomFile] File data: $file');
    
    if (widget.roomId == null || widget.roomId!.isEmpty) {
      print('❌ [openRoomFile] RoomId is null or empty');
      _showSnackBar(S.of(context).fileLinkUnavailable, Colors.orange);
      return;
    }
    
    if (fileId.isEmpty) {
      print('❌ [openRoomFile] FileId is empty');
      _showSnackBar(S.of(context).fileIdNotAvailable, Colors.red);
      return;
    }

    _showLoadingDialog();

    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        if (mounted) {
          Navigator.pop(context);
          _showSnackBar(S.of(context).mustLogin, Colors.red);
        }
        return;
      }

      // ✅ استخدام endpoint الروم لعرض الملف
      final url =
          "${ApiConfig.baseUrl}${ApiEndpoints.viewRoomFile(widget.roomId!, fileId)}";
      print('🌐 [openRoomFile] GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (mounted) Navigator.pop(context);
      
      print('📥 [openRoomFile] Response Status: ${response.statusCode}');
      print('📥 [openRoomFile] Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        // ✅ حفظ الملف مؤقتاً وفتحه
        // ✅ استخراج fileName من البيانات - قد يكون في name أو originalData
        final originalData = file['originalData'] as Map<String, dynamic>? ?? file;
        final fileName = (file['name']?.toString() ?? 
                         file['originalName']?.toString() ??
                         originalData['name']?.toString() ?? 
                         S.of(context).unnamedFile);
        final name = fileName.toLowerCase();
        print('📥 [openRoomFile] File name: $fileName');
        print('📥 [openRoomFile] File data keys: ${file.keys.toList()}');
        print('📥 [openRoomFile] OriginalData keys: ${originalData.keys.toList()}');
        
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(response.bodyBytes);
        print('📥 [openRoomFile] File saved to: ${tempFile.path}');
        
        // ✅ فتح الملف حسب نوعه
        if (name.endsWith('.pdf')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PdfViewerPage(
                pdfUrl: tempFile.path,
                fileName: fileName,
              ),
            ),
          );
        } else if (name.endsWith('.mp4') ||
            name.endsWith('.mov') ||
            name.endsWith('.mkv') ||
            name.endsWith('.avi') ||
            name.endsWith('.wmv')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoViewer(url: tempFile.path),
            ),
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
                imageUrl: tempFile.path,
                fileId: fileId,
                roomId: widget.roomId,
              ),
            ),
          );
        } else if (TextViewerPage.isTextFile(fileName)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TextViewerPage(
                filePath: tempFile.path,
                fileName: fileName,
              ),
            ),
          );
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
                  AudioPlayerPage(audioUrl: tempFile.path, fileName: fileName),
            ),
          );
        } else {
          _showLoadingDialog();
          await OfficeFileOpener.openAnyFile(
            url: tempFile.path,
            context: context,
            token: token,
            fileName: fileName,
            closeLoadingDialog: true,
          );
        }
      } else if (response.statusCode == 429) {
        // ✅ معالجة خطأ Rate Limiting
        print('⚠️ [openRoomFile] Rate limit exceeded (429)');
        
        // ✅ محاولة استخدام endpoint العادي كبديل
        print('⚠️ [openRoomFile] Trying regular endpoint instead...');
        
        final originalData = file['originalData'] as Map<String, dynamic>? ?? file;
        final fileName = (file['name']?.toString() ?? 
                         file['originalName']?.toString() ??
                         originalData['name']?.toString() ?? 
                         S.of(context).unnamedFile);
        final name = fileName.toLowerCase();
        final filePath = (file['path'] as String?) ?? (originalData['path'] as String?);
        final fileType = _getFileType(fileName);
        
        String url;
        if (filePath != null && filePath.isNotEmpty) {
          url = getFileUrl(filePath);
        } else if (fileId.isNotEmpty) {
          if (fileType == 'image' || fileType == 'video') {
            url = "${ApiConfig.baseUrl}${ApiEndpoints.viewFile(fileId)}";
          } else {
            url = "${ApiConfig.baseUrl}${ApiEndpoints.downloadFile(fileId)}";
          }
        } else {
          _showSnackBar(
            'تم تجاوز الحد المسموح من الطلبات. يرجى المحاولة لاحقاً.',
            Colors.orange,
          );
          return;
        }
        
        print('📂 [openRoomFile] Using regular endpoint: $url');
        try {
          await _openFileFromUrl(url, fileName, name, fileId);
        } catch (e) {
          print('❌ [openRoomFile] Error opening file from regular endpoint: $e');
          _showSnackBar(
            'تم تجاوز الحد المسموح من الطلبات. يرجى المحاولة لاحقاً.',
            Colors.orange,
          );
        }
      } else if (response.statusCode == 404) {
        // ✅ الملف غير موجود في الروم مباشرة أو داخل مجلد مشترك
        // ✅ الباك إند يجب أن يتحقق من أن الملف داخل مجلد مشترك
        print('❌ [openRoomFile] File not found in room (404)');
        
        try {
          final errorJson = jsonDecode(response.body);
          final errorMessage = errorJson['message'] ?? 
                             'الملف غير موجود في هذه الغرفة أو داخل مجلد مشترك';
          _showSnackBar(errorMessage, Colors.red);
        } catch (e) {
          _showSnackBar(
            'الملف غير موجود في هذه الغرفة أو داخل مجلد مشترك',
            Colors.red,
          );
        }
      } else {
        // ✅ معالجة الأخطاء الأخرى
        print('❌ [openRoomFile] Error response: ${response.statusCode}');
        print('❌ [openRoomFile] Error body: ${response.body}');
        
        String errorMessage = S.of(context).failedToDownloadFile;
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage =
              errorJson['message'] ?? errorJson['error'] ?? errorMessage;
        } catch (e) {
          // ✅ إذا لم يكن JSON، استخدم الرسالة الأصلية
          if (response.statusCode == 403) {
            errorMessage = 'Access denied or file already accessed';
          }
        }
        _showSnackBar(errorMessage, Colors.red);
      }
    } catch (e, stackTrace) {
      print('❌ [openRoomFile] Exception: $e');
      print('❌ [openRoomFile] Stack trace: $stackTrace');
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar(
          S.of(context).errorDownloadingFile1,
          Colors.red,
        );
      }
    }
  }

  // ✅ دالة مساعدة لفتح الملف من URL
  Future<void> _openFileFromUrl(String url, String fileName, String name, String fileId) async {
    print('🌐 [openFileFromUrl] Starting - URL: $url, fileName: $fileName, fileId: $fileId');
    _showLoadingDialog();

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        Navigator.pop(context);
        _showSnackBar(S.of(context).mustLogin, Colors.red);
        return;
      }

      final client = http.Client();
      print('🌐 [openFileFromUrl] Sending GET request to: $url');
      final response = await client.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Range': 'bytes=0-511'},
      );
      if (!mounted) return;
      Navigator.pop(context);

      print('📥 [openFileFromUrl] Response Status: ${response.statusCode}');
      print('📥 [openFileFromUrl] Response Headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 206) {
        print('✅ [openFileFromUrl] Success - Opening file: $fileName');
        final bytes = response.bodyBytes;
        bool isValidPdf(List<int> bytes) {
          if (bytes.length < 4) return false;
          final signature = String.fromCharCodes(bytes.sublist(0, 4));
          return signature == '%PDF';
        }

        final isPdf = isValidPdf(bytes);

        if (name.endsWith('.pdf') && !isPdf) {
          _showSnackBar(S.of(context).invalidPdfFile, Colors.red);
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
          print('🎥 [openFileFromUrl] Opening video file');
          // ✅ تحميل الفيديو مؤقتاً لأن VideoPlayerController.network لا يدعم headers مخصصة
          _showLoadingDialog();
          try {
            final fullResponse = await http.get(
              Uri.parse(url),
              headers: {'Authorization': 'Bearer $token'},
            );
            if (mounted) Navigator.pop(context);
            if (fullResponse.statusCode == 200) {
              final tempDir = await getTemporaryDirectory();
              final tempFile = File('${tempDir.path}/$fileName');
              await tempFile.writeAsBytes(fullResponse.bodyBytes);
              print('🎥 [openFileFromUrl] Video saved to: ${tempFile.path}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoViewer(url: tempFile.path),
                ),
              );
            } else {
              _showSnackBar('فشل تحميل الفيديو: ${fullResponse.statusCode}', Colors.red);
            }
          } catch (e) {
            if (mounted) {
              Navigator.pop(context);
              _showSnackBar('خطأ في تحميل الفيديو: $e', Colors.red);
            }
          }
        } else if (name.endsWith('.jpg') ||
            name.endsWith('.jpeg') ||
            name.endsWith('.png') ||
            name.endsWith('.gif') ||
            name.endsWith('.bmp') ||
            name.endsWith('.webp')) {
          print('🖼️ [openFileFromUrl] Opening image file');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageViewer(imageUrl: url, fileId: fileId),
            ),
          );
        } else if (TextViewerPage.isTextFile(fileName)) {
          print('📝 [openFileFromUrl] Opening text file');
          _showLoadingDialog();
          try {
            final fullResponse = await http.get(
              Uri.parse(url),
              headers: {'Authorization': 'Bearer $token'},
            );
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
        print('❌ [openFileFromUrl] Error response: ${response.statusCode}');
        print('❌ [openFileFromUrl] Error body: ${response.body}');
        
        String errorMessage = S.of(context).failedToDownloadFile;
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['message'] ?? 
                        errorJson['error'] ?? 
                        errorMessage;
          print('❌ [openFileFromUrl] Error message: $errorMessage');
        } catch (e) {
          print('❌ [openFileFromUrl] Could not parse error JSON: $e');
          if (response.statusCode == 403) {
            errorMessage = 'ليس لديك صلاحية للوصول إلى هذا الملف';
          } else if (response.statusCode == 404) {
            errorMessage = 'الملف غير موجود';
          } else if (response.statusCode == 401) {
            errorMessage = 'يرجى إعادة تسجيل الدخول';
          } else {
            errorMessage = S.of(context).fileUnavailableWithCode(response.statusCode.toString());
          }
        }
        
        _showSnackBar(errorMessage, Colors.red);
      }
    } catch (e, stackTrace) {
      print('❌ [openFileFromUrl] Exception: $e');
      print('❌ [openFileFromUrl] Stack trace: $stackTrace');
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar(S.of(context).errorDownloadingFile1, Colors.red);
      }
    }
  }

  // ✅ دالة مساعدة لفتح الملف من المسار المحلي
  Future<void> _openFileFromPath(String filePath, String fileName, String name) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        _showSnackBar('File not found', Colors.red);
        return;
      }

      if (name.endsWith('.pdf')) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfViewerPage(pdfUrl: filePath, fileName: fileName),
          ),
        );
      } else if (name.endsWith('.mp4') ||
          name.endsWith('.mov') ||
          name.endsWith('.mkv') ||
          name.endsWith('.avi') ||
          name.endsWith('.wmv')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VideoViewer(url: filePath)),
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
            builder: (_) => ImageViewer(imageUrl: filePath, fileId: null),
          ),
        );
      } else if (TextViewerPage.isTextFile(fileName)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TextViewerPage(
              filePath: filePath,
              fileName: fileName,
            ),
          ),
        );
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
            builder: (_) => AudioPlayerPage(audioUrl: filePath, fileName: fileName),
          ),
        );
      } else {
        final token = await StorageService.getToken();
        if (token == null) {
          _showSnackBar(S.of(context).mustLogin, Colors.red);
          return;
        }
        _showLoadingDialog();
        await OfficeFileOpener.openAnyFile(
          url: filePath,
          context: context,
          token: token,
          fileName: fileName,
          closeLoadingDialog: true,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error opening file: $e', Colors.red);
      }
    }
  }

  Future<void> _handleFileTap(Map<String, dynamic> file) async {
    print('📂 [handleFileTap] Opening file: ${file['name']}');
    print('📂 [handleFileTap] File data keys: ${file.keys.toList()}');
    print('📂 [handleFileTap] File path: ${file['path']}');
    print('📂 [handleFileTap] File _id: ${file['_id']}');
    print('📂 [handleFileTap] File originalData: ${file['originalData']}');
    
    // ✅ استخراج البيانات من originalData إذا كانت موجودة
    final originalData = file['originalData'] as Map<String, dynamic>? ?? file;
    
    // ✅ استخراج fileId - قد يكون في _id مباشرة أو في originalData
    String fileId = _extractId(file['_id']);
    if (fileId.isEmpty) {
      fileId = _extractId(originalData['_id']);
    }
    
    final filePath = (file['path'] as String?) ?? 
                     (originalData['path'] as String?);
    final originalName = (file['name'] as String?) ?? 
                         (originalData['name'] as String?);
    final name = originalName?.toLowerCase() ?? '';
    final fileName = originalName ?? S.of(context).unnamedFile;
    
    print('📂 [handleFileTap] After extraction - fileId: $fileId, path: $filePath');
    print('📂 [handleFileTap] originalData keys: ${originalData.keys.toList()}');
    print('📂 [handleFileTap] originalData _id: ${originalData['_id']}');
    
    // ✅ إذا كان المجلد مشترك في الروم، استخدم endpoint الروم
    if (widget.roomId != null && widget.roomId!.isNotEmpty && fileId.isNotEmpty) {
      print('📂 [handleFileTap] Using room endpoint for file: $fileId');
      print('📂 [handleFileTap] RoomId: ${widget.roomId}');
      print('📂 [handleFileTap] FileId: $fileId');
      // ✅ استخدام endpoint الروم لعرض الملف
      // ✅ تمرير originalData أيضاً لضمان وجود جميع البيانات
      await _openRoomFile(fileId, originalData);
      return;
    }

    // ✅ إذا لم يكن هناك path و fileId موجود، استخدم endpoint
    String? filePathToUse = filePath;
    
    // ✅ إذا لم يكن path موجوداً، حاول استخراجه من fileId (إذا كان object)
    if ((filePathToUse == null || filePathToUse.isEmpty) && file['fileId'] != null) {
      final fileIdData = file['fileId'];
      if (fileIdData is Map<String, dynamic>) {
        filePathToUse = fileIdData['path']?.toString();
        print('📂 [handleFileTap] Extracted path from fileId: $filePathToUse');
      }
    }

    String url;
    
    // ✅ إذا كان هناك path، استخدمه
    if (filePathToUse != null && filePathToUse.isNotEmpty) {
      print('📂 [handleFileTap] Using path: $filePathToUse');
      url = getFileUrl(filePathToUse);
      print('📂 [handleFileTap] Generated URL from path: $url');
    } else if (fileId.isNotEmpty) {
      // ✅ إذا لم يكن path موجوداً، استخدم endpoint حسب نوع الملف
      print('📂 [handleFileTap] No path found, using endpoint for fileId: $fileId');
      final token = await StorageService.getToken();
      if (token == null) {
        _showSnackBar(S.of(context).mustLogin, Colors.red);
        return;
      }
      
      // ✅ استخدام viewFile endpoint للصور والفيديو، downloadFile للملفات الأخرى
      final fileType = _getFileType(fileName);
      print('📂 [handleFileTap] File type: $fileType');
      if (fileType == 'image' || fileType == 'video') {
        // ✅ للصور والفيديو، استخدام viewFile endpoint
        url = "${ApiConfig.baseUrl}${ApiEndpoints.viewFile(fileId)}";
        print('📂 [handleFileTap] Using viewFile endpoint: $url');
      } else {
        // ✅ للملفات الأخرى (PDF, etc.)، استخدام downloadFile endpoint
        // ✅ downloadFile يحتاج إلى المسار الكامل مع /api/v1
        url = "${ApiConfig.baseUrl}${ApiEndpoints.downloadFile(fileId)}";
        print('📂 [handleFileTap] Using downloadFile endpoint: $url');
      }
    } else {
      print('❌ [handleFileTap] No path and no fileId available');
      _showSnackBar(S.of(context).fileLinkUnavailable, Colors.orange);
      return;
    }

    _showLoadingDialog();

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        Navigator.pop(context);
        _showSnackBar(S.of(context).mustLogin, Colors.red);
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
          _showSnackBar(S.of(context).invalidPdfFile, Colors.red);
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
        // ✅ استخدام المتغير المترجم وتمرير كود الحالة
        _showSnackBar(
          S.of(context).fileUnavailableWithCode(response.statusCode.toString()),
          Colors.red,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        // ✅ رسالة خطأ عامة مترجمة
        _showSnackBar(S.of(context).errorDownloadingFile1, Colors.red);
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

  // ✅ دالة مساعدة لاستخراج _id من البيانات
  String _extractId(dynamic idValue) {
    if (idValue == null) return '';
    if (idValue is String && idValue.isNotEmpty) {
      return idValue;
    } else if (idValue is Map && idValue['\$oid'] != null) {
      return idValue['\$oid'].toString();
    } else {
      final idStr = idValue.toString();
      return idStr.isNotEmpty ? idStr : '';
    }
  }

  List<Map<String, dynamic>> _convertFilesToListFormat(
    List<Map<String, dynamic>> files,
  ) {
    return files.map((file) {
      final fileName = file['name']?.toString() ?? S.of(context).unnamedFile;
      final filePath = file['path']?.toString() ?? '';
      final fileId = _extractId(file['_id']);

      // ✅ الحصول على نوع الملف أولاً
      String fileType = _getFileType(fileName);

      String fileUrl = '';
      if (filePath.isNotEmpty) {
        fileUrl = getFileUrl(filePath);
      } else if (fileId.isNotEmpty) {
        // ✅ استخدام viewFile endpoint للصور والفيديو، downloadFile للملفات الأخرى
        if (fileType == 'image' || fileType == 'video') {
          // ✅ للصور والفيديو، استخدام /view endpoint
          fileUrl = "${ApiConfig.baseUrl}${ApiEndpoints.viewFile(fileId)}";
        } else {
          // ✅ للملفات الأخرى (PDF, etc.)، استخدام /download endpoint
          fileUrl = "${ApiConfig.baseUrl}${ApiEndpoints.downloadFile(fileId)}";
        }
      }

      return {
        'title': fileName,
        'name': fileName,
        'url': fileUrl,
        'type': fileType,
        'size': _formatBytes(file['size'] ?? 0),
        'path': filePath,
        '_id': fileId, // ✅ إضافة _id مباشرة في البيانات
        'originalData': file,
        'itemData': file,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _convertFilesToGridFormat(
    List<Map<String, dynamic>> files,
  ) {
    return files.map((file) {
      final fileName = file['name']?.toString() ?? S.of(context).unnamedFile;
      final filePath = file['path']?.toString() ?? '';
      final fileId = _extractId(file['_id']);

      // ✅ الحصول على نوع الملف أولاً
      String fileType = _getFileType(fileName);

      String fileUrl = '';
      if (filePath.isNotEmpty) {
        fileUrl = getFileUrl(filePath);
      } else if (fileId.isNotEmpty) {
        // ✅ استخدام viewFile endpoint للصور والفيديو، downloadFile للملفات الأخرى
        if (fileType == 'image' || fileType == 'video') {
          // ✅ للصور والفيديو، استخدام /view endpoint
          fileUrl = "${ApiConfig.baseUrl}${ApiEndpoints.viewFile(fileId)}";
        } else {
          // ✅ للملفات الأخرى (PDF, etc.)، استخدام /download endpoint
          fileUrl = "${ApiConfig.baseUrl}${ApiEndpoints.downloadFile(fileId)}";
        }
      }

      return {
        'title': fileName,
        'name': fileName,
        'url': fileUrl,
        'type': fileType,
        'size': _formatBytes(file['size'] ?? 0),
        'path': filePath,
        '_id': fileId, // ✅ إضافة _id مباشرة في البيانات
        'originalData': file,
        'itemData': file,
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
      _showSnackBar(S.of(context).mustLogin, Colors.red);
      return;
    }

    final folderDetails = await folderController.getFolderDetails(
      folderId: widget.folderId,
    );

    if (folderDetails == null || folderDetails['folder'] == null) {
      _showSnackBar(S.of(context).failedToFetchFolderInfo, Colors.red);
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
                S.of(context).type, // ✅ "النوع"
                S.of(context).folder, // ✅ "مجلد"
                Icons.folder_outlined,
                Colors.blue,
              ),
              _buildInfoRow(
                S.of(context).size, // ✅ "الحجم"
                _formatBytes(folder['size'] ?? 0),
                Icons.storage,
                Colors.green,
              ),
              _buildInfoRow(
                S.of(context).filesCount, // ✅ "عدد الملفات"
                '${folder['filesCount'] ?? 0}',
                Icons.insert_drive_file,
                Colors.orange,
              ),
              _buildInfoRow(
                S.of(context).subfoldersCount, // ✅ "المجلدات الفرعية"
                '${folder['subfoldersCount'] ?? 0}',
                Icons.folder_copy,
                Colors.purple,
              ),
              _buildInfoRow(
                S.of(context).createdAt, // ✅ "تاريخ الإنشاء"
                _formatDate(folder['createdAt']),
                Icons.calendar_today,
                Colors.red,
              ),
              const SizedBox(height: 20),
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(S.of(context).done), // ✅ "تم"
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
    if (date == null) return S.of(context).unknown;
    ;
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    } catch (e) {
      return S.of(context).unknown;
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
              S.of(context).loadingContents, // ✅ نص مترجم
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
              S.of(context).emptyFolderTitle, // ✅ "المجلد فارغ"
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              S
                  .of(context)
                  .emptyFolderSubtitle, // ✅ "يمكنك إضافة ملفات أو مجلدات جديدة"
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
                    S.of(context).folders, // ✅ "المجلدات"
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
                    S.of(context).files, // ✅ "الملفات"
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
                  child: Text(S.of(context).loadMore),
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
    final name = folder['name'] as String? ?? S.of(context).unnamedFolder;
    final filesCount = folder['filesCount'] ?? 0;
    final folderColor = widget.folderColor ?? Colors.blue;

    // ✅ استخراج الحجم وتنسيقه
    int size = 0;
    final sizeValue = folder['size'];
    if (sizeValue != null) {
      if (sizeValue is int) {
        size = sizeValue;
      } else if (sizeValue is num) {
        size = sizeValue.toInt();
      } else if (sizeValue is String) {
        size = int.tryParse(sizeValue) ?? 0;
      }
    }
    final formattedSize = _formatBytes(size);

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
              // ✅ عرض عدد الملفات والحجم
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$filesCount ${S.of(context).files}', // ✅ "ملفات"
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                  Text(
                    formattedSize, // ✅ عرض الحجم
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                        onTap: () async {
                          Navigator.pop(context);
                          // ✅ التحقق من كلمة السر إذا كان المجلد محمياً
                          final folderData = folder['folderData'] ?? folder;
                          final isProtected = folderData['isProtected'] == true;
                          final protectionType = folderData['protectionType']?.toString() ?? 'none';

                          if (isProtected && protectionType != 'none') {
                            final folderId = folder['folderId'] ?? folder['_id'];
                            final folderName = folder['title'] ?? folder['name'] ?? S.of(context).folder;
                            
                            if (folderId != null) {
                              final result = await showVerifyFolderAccessDialog(
                                context,
                                folderId.toString(),
                                folderName,
                                protectionType,
                              );

                              if (result['success'] != true) {
                                return;
                              }
                            }
                          }
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
                          // ✅ التحقق من كلمة السر إذا كان المجلد محمياً
                          final folderData = folder['folderData'] ?? folder;
                          final isProtected = folderData['isProtected'] == true;
                          final protectionType = folderData['protectionType']?.toString() ?? 'none';

                          if (isProtected && protectionType != 'none') {
                            final folderId = folder['folderId'] ?? folder['_id'];
                            final folderName = folder['title'] ?? folder['name'] ?? S.of(context).folder;
                            
                            if (folderId != null) {
                              final result = await showVerifyFolderAccessDialog(
                                context,
                                folderId.toString(),
                                folderName,
                                protectionType,
                              );

                              if (result['success'] != true) {
                                return;
                              }
                            }
                          }
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
                          // ✅ إضافة folderId إذا لم يكن موجوداً (للمجلدات الفرعية)
                          final folderWithId = {
                            ...folder,
                            'folderId': folder['folderId'] ?? folder['_id'],
                            'title': folder['title'] ?? folder['name'],
                            'folderData': folder['folderData'] ?? folder,
                          };
                          _showRenameDialog(context, folderWithId);
                        },
                      ),

                      // ✅ المشاركة
                      _buildMenuItem(
                        context,
                        icon: Icons.share,
                        title: S.of(context).share,
                        onTap: () async {
                          Navigator.pop(context);
                          // ✅ التحقق من أن المجلد محمي - منع المشاركة
                          final folderData = folder['folderData'] ?? folder;
                          final isProtected = folderData['isProtected'] == true;
                          final protectionType = folderData['protectionType']?.toString() ?? 'none';

                          if (isProtected && protectionType != 'none') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('لا يمكن مشاركة المجلدات المحمية'),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return;
                          }
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
                          // ✅ إضافة folderId إذا لم يكن موجوداً (للمجلدات الفرعية)
                          final folderWithId = {
                            ...folder,
                            'folderId': folder['folderId'] ?? folder['_id'],
                            'title': folder['title'] ?? folder['name'],
                            'folderData': folder['folderData'] ?? folder,
                          };
                          _showMoveFolderDialog(context, folderWithId);
                        },
                      ),

                      // ✅ المفضلة
                      _buildMenuItem(
                        context,
                        icon: folder['isStarred'] == true
                            ? Icons.star
                            : Icons.star_border,
                        title: folder['isStarred'] == true
                            ? S.of(context).folderAddedToFavorites
                            : S.of(context).folderRemovedFromFavorites,
                        iconColor: Colors.amber[700],
                        onTap: () {
                          Navigator.pop(context);
                          // ✅ إضافة folderId إذا لم يكن موجوداً (للمجلدات الفرعية)
                          final folderWithId = {
                            ...folder,
                            'folderId': folder['folderId'] ?? folder['_id'],
                            'title': folder['title'] ?? folder['name'],
                            'folderData': folder['folderData'] ?? folder,
                          };
                          _toggleFavorite(context, folderWithId);
                        },
                      ),

                      // ✅ خط فاصل قبل الحذف
                      Divider(height: 1),

                      // ✅ قفل/إلغاء قفل المجلد
                      _buildMenuItem(
                        context,
                        icon: (folder['folderData'] ?? folder)['isProtected'] == true
                            ? Icons.lock_open
                            : Icons.lock,
                        title: (folder['folderData'] ?? folder)['isProtected'] == true
                            ? 'إلغاء قفل المجلد'
                            : 'قفل المجلد',
                        iconColor: Colors.orange,
                        onTap: () {
                          Navigator.pop(context);
                          // ✅ إضافة folderId إذا لم يكن موجوداً (للمجلدات الفرعية)
                          final folderWithId = {
                            ...folder,
                            'folderId': folder['folderId'] ?? folder['_id'],
                            'title': folder['title'] ?? folder['name'],
                            'folderData': folder['folderData'] ?? folder,
                          };
                          _showProtectFolderDialog(context, folderWithId);
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
                        onTap: () async {
                          Navigator.pop(context);
                          // ✅ التحقق من كلمة السر إذا كان المجلد محمياً
                          final folderData = folder['folderData'] ?? folder;
                          final isProtected = folderData['isProtected'] == true;
                          final protectionType = folderData['protectionType']?.toString() ?? 'none';

                          if (isProtected && protectionType != 'none') {
                            final folderId = folder['folderId'] ?? folder['_id'];
                            final folderName = folder['title'] ?? folder['name'] ?? S.of(context).folder;
                            
                            if (folderId != null) {
                              final result = await showVerifyFolderAccessDialog(
                                context,
                                folderId.toString(),
                                folderName,
                                protectionType,
                              );

                              if (result['success'] != true) {
                                return;
                              }
                            }
                          }
                          // ✅ إضافة folderId إذا لم يكن موجوداً (للمجلدات الفرعية)
                          final folderWithId = {
                            ...folder,
                            'folderId': folder['folderId'] ?? folder['_id'],
                            'title': folder['title'] ?? folder['name'],
                            'folderData': folder['folderData'] ?? folder,
                          };
                          _showDeleteFolderDialog(folderWithId);
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
    // ✅ الحصول على folderId من جميع الأماكن المحتملة (للمجلدات الفرعية)
    final folderId = folder['folderId'] ?? folder['_id'] ?? folder['folderData']?['_id'];
    if (folderId == null) return;

    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );

    final folderDetails = await folderController.getFolderDetails(
      folderId: folderId,
    );

    if (folderDetails == null || folderDetails['folder'] == null) {
      _showSnackBar(S.of(context).failedToFetchFolderInfo, Colors.red);
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
                        folderData['name'] ??
                            folder['name'] ??
                            S.of(context).folder,
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
                S.of(context).type, // ✅ "النوع"
                S.of(context).folder, // ✅ "مجلد"
                Icons.folder_outlined,
                Colors.blue,
              ),
              _buildInfoRow(
                S.of(context).size, // ✅ "الحجم"
                _formatBytes(folderData['size'] ?? 0),
                Icons.storage,
                Colors.green,
              ),
              _buildInfoRow(
                S.of(context).filesCount, // ✅ "عدد الملفات"
                '${folderData['filesCount'] ?? 0}',
                Icons.insert_drive_file,
                Colors.orange,
              ),
              _buildInfoRow(
                S.of(context).subfoldersCount, // ✅ "المجلدات الفرعية"
                '${folderData['subfoldersCount'] ?? 0}',
                Icons.folder_copy,
                Colors.purple,
              ),
              _buildInfoRow(
                S.of(context).createdAt, // ✅ "تاريخ الإنشاء"
                _formatDate(folderData['createdAt']),
                Icons.calendar_today,
                Colors.red,
              ),
              const SizedBox(height: 20),
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(S.of(context).done), // ✅ "تم"
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ أضف دالة إعادة التسمية:
  void _showRenameDialog(BuildContext context, Map<String, dynamic> folder) async {
    // ✅ استخدام context من State بدلاً من context الممرر
    if (!mounted) return;

    // ✅ التحقق من كلمة السر إذا كان المجلد محمياً
    final folderData = folder['folderData'] ?? folder;
    final isProtected = folderData['isProtected'] == true;
    final protectionType = folderData['protectionType']?.toString() ?? 'none';

    if (isProtected && protectionType != 'none') {
      final folderId = folder['folderId'] ?? folder['_id'];
      final folderName = folder['title'] ?? folder['name'] ?? S.of(this.context).folder;
      
      if (folderId != null) {
        final result = await showVerifyFolderAccessDialog(
          this.context,
          folderId.toString(),
          folderName,
          protectionType,
        );

        if (result['success'] != true) {
          return;
        }
      }
    }

    final folderName =
        folder['title']?.toString() ??
        folder['name']?.toString() ??
        S.of(this.context).folder;
    final folderId = folder['folderId'] ?? folder['_id'];
    final folderDataMap = folder['folderData'] as Map<String, dynamic>?;

    final nameController = TextEditingController(text: folderName);
    final descriptionController = TextEditingController(
      text: folderDataMap?['description'] as String? ?? '',
    );
    final tagsController = TextEditingController(
      text: (folderDataMap?['tags'] as List?)?.join(', ') ?? '',
    );

    if (folderId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text(S.of(this.context).folderIdNotFound)),
      );
      return;
    }

    if (!mounted) return;
    showDialog(
      context: this.context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(this.context).editFileMetadata),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: S.of(this.context).folderName,
                  hintText: S.of(this.context).folderName,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.folder),
                ),
                autofocus: true,
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: S.of(this.context).folderDescription,
                  hintText: S.of(this.context).folderDescriptionHint,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextField(
                controller: tagsController,
                decoration: InputDecoration(
                  labelText: S.of(this.context).folderTags,
                  hintText: S.of(this.context).folderTagsHint,
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
            child: Text(S.of(this.context).cancel),
          ),
          TextButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(S.of(this.context).pleaseEnterFolderName)),
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
                folderId.toString(),
                newName,
                description.isEmpty ? null : description,
                tags.isEmpty ? null : tags,
              );
            },
            child: Text(S.of(this.context).save),
          ),
        ],
      ),
    );
  }

  // ✅ دالة قفل/إلغاء قفل المجلد:
  void _showProtectFolderDialog(BuildContext context, Map<String, dynamic> folder) async {
    // ✅ استخدام context من State بدلاً من context الممرر
    if (!mounted) return;

    final folderData = folder['folderData'] ?? folder;
    final folderId = folder['folderId'] ?? folder['_id'];
    final folderName = folder['title'] ?? folder['name'] ?? S.of(this.context).folder;
    final isCurrentlyProtected = folderData['isProtected'] == true;
    final currentProtectionType = folderData['protectionType']?.toString() ?? 'none';

    if (folderId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text(S.of(this.context).folderIdNotFound)),
      );
      return;
    }

    await showSetFolderProtectionDialog(
      this.context,
      folderId.toString(),
      folderName,
      isCurrentlyProtected,
      currentProtectionType,
      () {
        if (mounted) {
          _loadFolderContents(resetPage: true);
        }
      },
    );
  }

  // ✅ دالة الحذف:
  void _showDeleteFolderDialog(Map<String, dynamic> folder) {
    showDeleteDialogHelper(
      context,
      folder,
      () => _loadFolderContents(resetPage: true),
    );
  }

  // ✅ دالة النقل:
  void _showMoveFolderDialog(BuildContext context, Map<String, dynamic> folder) {
    // ✅ استخدام context من State بدلاً من context الممرر
    if (!mounted) return;
    
    showMoveFolderDialogHelper(
      this.context,
      folder,
      onUpdated: () {
        if (mounted) {
          _loadFolderContents(resetPage: true);
        }
      },
    );
  }

  // ✅ دالة المفضلة:
  void _toggleFavorite(BuildContext context, Map<String, dynamic> folder) async {
    final folderId = folder['folderId'] as String?;
    if (folderId == null) return;

    // ✅ استخدام context من State بدلاً من context الممرر
    if (!mounted) return;

    final folderController = Provider.of<FolderController>(
      this.context,
      listen: false,
    );

    // ✅ إظهار مؤشر التحميل
    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text(S.of(this.context).updating),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    final result = await folderController.toggleStarFolder(folderId: folderId);

    ScaffoldMessenger.of(this.context).hideCurrentSnackBar();

    // ✅ التحقق من mounted قبل استخدام context
    if (!mounted) return;

    if (result['success'] == true) {
      final isStarred = result['isStarred'] as bool? ?? false;
      final updatedFolder = result['folder'] as Map<String, dynamic>?;

      // ✅ تحديث البيانات المحلية بدون refresh كامل للصفحة
      if (folder['folderData'] != null) {
        folder['folderData']['isStarred'] = isStarred;
        if (updatedFolder != null) {
          folder['folderData'].addAll(updatedFolder);
        }
      }
      folder['isStarred'] = isStarred;

      // ✅ تحديث البيانات في contents list محلياً
      final folderIndex = contents.indexWhere((item) {
        final itemId = item['_id']?.toString() ?? item['folderId']?.toString();
        return itemId == folderId;
      });

      if (folderIndex != -1) {
        setState(() {
          contents[folderIndex]['isStarred'] = isStarred;
          if (contents[folderIndex]['folderData'] != null) {
            contents[folderIndex]['folderData']['isStarred'] = isStarred;
            if (updatedFolder != null) {
              contents[folderIndex]['folderData'].addAll(updatedFolder);
            }
          }
        });
      }

      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(
            isStarred
                ? S.of(this.context).folderAddedToFavorite
                : S.of(this.context).folderRemovedFromFavorite,
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? S.of(this.context).failedToUpdateFavorite,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _performUpdate(
    BuildContext dialogContext,
    String folderId,
    String newName,
    String? description,
    List<String>? tags,
  ) async {
    // ✅ استخدام context من State بدلاً من context الممرر
    if (!mounted) return;

    final folderController = Provider.of<FolderController>(
      this.context,
      listen: false,
    );

    Navigator.pop(dialogContext);

    final success = await folderController.updateFolder(
      folderId: folderId,
      name: newName,
      description: description,
      tags: tags,
    );

    // ✅ التحقق من mounted قبل استخدام context
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(S.of(this.context).folderUpdatedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
      // ✅ إعادة تحميل المحتويات بعد التحديث
      _loadFolderContents(resetPage: true);
    } else {
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(
            folderController.errorMessage ??
                S.of(this.context).folderUpdateFailed,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
