import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/components/FilesGridView.dart';
import 'package:filevo/components/FilesListView.dart';
import 'package:filevo/components/ViewToggleButtons.dart';
import 'package:filevo/responsive.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/config/api_config.dart';
import 'package:filevo/views/fileViewer/FilesGridView1.dart';
import 'package:filevo/views/fileViewer/file_details_page.dart';
import 'package:filevo/views/fileViewer/VideoViewer.dart';
import 'package:filevo/views/fileViewer/audioPlayer.dart';
import 'package:filevo/views/fileViewer/imageViewer.dart';
import 'package:filevo/views/fileViewer/office_file_opener.dart';
import 'package:filevo/views/fileViewer/pdfViewer.dart';
import 'package:filevo/views/fileViewer/textViewer.dart';
import 'package:filevo/views/folders/share_folder_with_room_page.dart';
import 'package:filevo/views/folders/starred_folders_page_helpers.dart';
import 'package:filevo/views/fileViewer/folder_actions_service.dart';
import 'package:filevo/views/fileViewer/file_actions_service.dart';
import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:filevo/services/file_search_service.dart';
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

  // ✅ البحث الذكي
  final TextEditingController _searchController = TextEditingController();
  final FileSearchService _searchService = FileSearchService();
  bool _isSearching = false;
  bool _isSearchLoading = false;
  List<Map<String, dynamic>> _searchResults = [];
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    // ✅ تحميل المحتويات بعد اكتمال البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFolderContents();
    });

    // ✅ إضافة listener للبحث
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ معالجة تغيير نص البحث
  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
        _searchQuery = null;
      });
    } else {
      // ✅ البحث بعد تأخير قصير (debounce)
      Future.delayed(Duration(milliseconds: 500), () {
        if (_searchController.text.trim() == query && query.isNotEmpty) {
          _performSearch(query);
        }
      });
    }
  }

  // ✅ تنفيذ البحث الذكي
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
        _searchQuery = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isSearchLoading = true;
      _searchQuery = query;
    });

    try {
      final result = await _searchService.smartSearch(query: query, limit: 50);

      if (!mounted) return;

      if (result['success'] == true) {
        final results = List<Map<String, dynamic>>.from(
          result['results'] ?? [],
        );

        // ✅ فلترة النتائج لتكون فقط الملفات في هذا المجلد
        final folderId = widget.folderId;
        final filteredResults = results
            .where((item) {
              final file = item['item'] ?? item;
              final parentFolderId = file['parentFolderId'];
              return parentFolderId == folderId;
            })
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        setState(() {
          _searchResults = filteredResults.map<Map<String, dynamic>>((r) {
            final file = Map<String, dynamic>.from(r['item'] ?? r);
            return {
              ...file,
              'type': 'file',
              'relevanceScore': r['relevanceScore'] ?? 0,
              'searchType': r['searchType'] ?? 'text',
            };
          }).toList();
          _isSearchLoading = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isSearchLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'فشل البحث'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearchLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).searchError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadFolderContents({
    bool loadMore = false,
    bool resetPage = false,
  }) async {
    if (!mounted) return;

    // ✅ إذا كان resetPage = true، نتجاوز شرط isLoading لإجبار التحديث
    if (isLoading && !resetPage) return;

    // ✅ إذا كان resetPage = true وكان isLoading = true، ننتظر قليلاً
    if (isLoading && resetPage) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    if (!mounted) return;

    setState(() {
      isLoading = true;
      if (resetPage) {
        currentPage = 1;
        hasMore = true;
        contents = []; // ✅ مسح المحتويات القديمة عند إعادة التعيين
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

      // ✅ الباك إند الجديد يعيد contents, subfolders, files, totalItems
      // ✅ يمكن استخدام contents مباشرة أو دمج subfolders و files
      List<Map<String, dynamic>> newContents = [];

      if (result != null) {
        if (result['contents'] != null) {
          // ✅ إذا كان contents موجوداً، استخدمه مباشرة
          newContents = List<Map<String, dynamic>>.from(result['contents']);

          // ✅ ترتيب: المجلدات أولاً ثم الملفات
          newContents.sort((a, b) {
            final aType = a['type'] as String?;
            final bType = b['type'] as String?;

            // ✅ المجلدات دائماً قبل الملفات
            if (aType == 'folder' && bType == 'file') return -1;
            if (aType == 'file' && bType == 'folder') return 1;

            // ✅ إذا كان نفس النوع، ترتيب حسب createdAt (الأحدث أولاً)
            final aDate = a['createdAt'];
            final bDate = b['createdAt'];
            if (aDate != null && bDate != null) {
              try {
                final aDateTime = aDate is DateTime
                    ? aDate
                    : DateTime.parse(aDate.toString());
                final bDateTime = bDate is DateTime
                    ? bDate
                    : DateTime.parse(bDate.toString());
                return bDateTime.compareTo(aDateTime);
              } catch (e) {
                return 0;
              }
            }
            return 0;
          });
        } else if (result['subfolders'] != null || result['files'] != null) {
          // ✅ إذا لم يكن contents موجوداً، دمج subfolders و files
          final subfolders = List<Map<String, dynamic>>.from(
            result['subfolders'] ?? [],
          );
          final files = List<Map<String, dynamic>>.from(result['files'] ?? []);

          // ✅ إضافة type لكل عنصر - المجلدات أولاً ثم الملفات
          newContents = [
            ...subfolders.map((f) => {...f, 'type': 'folder'}),
            ...files.map((f) => {...f, 'type': 'file'}),
          ];
        }
      }

      if (!mounted) return;

      // ✅ تحديث الصفحة الحالية
      if (loadMore) {
        if (mounted) {
          setState(() {
            currentPage = pageToLoad;
          });
        }
      } else if (resetPage) {
        if (mounted) {
          setState(() {
            currentPage = 1;
          });
        }
      }

      // ✅ Logging للتحقق من البيانات
      print('📁 Folder contents loaded: ${newContents.length} items');

      if (newContents.isNotEmpty) {
        // ✅ إضافة type للملفات والمجلدات إذا لم يكن موجوداً
        final processedContents = newContents.map((item) {
          // ✅ إذا كان type موجوداً وليس 'file' أو 'folder'، نحتاج لتمييزه
          final currentType = item['type'] as String?;

          // ✅ تمييز الملفات من المجلدات
          if (currentType != 'file' && currentType != 'folder') {
            // ✅ إذا كان يحتوي على filesCount أو subfoldersCount، فهو مجلد
            if (item['filesCount'] != null || item['subfoldersCount'] != null) {
              item['type'] = 'folder';
            }
            // ✅ إذا كان يحتوي على path وليس parentId (أو parentId مختلف)، فهو ملف
            else if (item['path'] != null &&
                item['path'].toString().isNotEmpty) {
              item['type'] = 'file';
            }
            // ✅ إذا كان يحتوي على mimetype (type يحتوي على '/')، فهو ملف
            else if (currentType != null && currentType.contains('/')) {
              item['type'] = 'file';
            }
            // ✅ افتراض أنه ملف إذا لم يكن مجلد
            else {
              item['type'] = 'file';
            }
          }

          print(
            '  - Type: ${item['type']}, Name: ${item['name']}, Path: ${item['path']}',
          );
          return item;
        }).toList();

        if (mounted) {
          setState(() {
            if (loadMore) {
              contents.addAll(processedContents);
              currentPage = pageToLoad;
            } else {
              contents = processedContents;
              if (resetPage) {
                currentPage = 1;
              } else {
                currentPage = pageToLoad;
              }
            }

            // ✅ حساب pagination من totalItems إذا كان متاحاً
            final totalItems =
                result?['totalItems'] as int? ?? newContents.length;
            final pagination = result?['pagination'] as Map<String, dynamic>?;

            if (pagination != null) {
              hasMore = pagination['hasNext'] ?? false;
            } else {
              // ✅ حساب hasMore من totalItems و limit
              final currentTotal = loadMore
                  ? contents.length + newContents.length
                  : newContents.length;
              hasMore = currentTotal < totalItems;
            }

            isLoading = false;
          });
        }
      } else {
        // ✅ المجلد فارغ - هذا طبيعي
        print('📁 Folder is empty');
        if (mounted) {
          setState(() {
            contents = [];
            isLoading = false;
            hasMore = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error loading folder contents: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      if (mounted) {
        final errorMessage = e.toString();
        String userMessage = 'خطأ في تحميل محتويات المجلد';

        if (errorMessage.contains('Access denied') ||
            errorMessage.contains('403')) {
          userMessage = 'ليس لديك صلاحية للوصول إلى هذا المجلد';
        } else if (errorMessage.contains('not found') ||
            errorMessage.contains('404')) {
          userMessage = 'المجلد غير موجود';
        } else {
          userMessage = 'خطأ في تحميل محتويات المجلد: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'إعادة المحاولة',
              textColor: Colors.white,
              onPressed: () => _loadFolderContents(),
            ),
          ),
        );
      }
    }
  }

  void _handleItemTap(Map<String, dynamic> item) {
    final type = item['type'] as String?;

    if (type == 'folder') {
      // ✅ إذا كان مجلد فرعي، افتح محتوياته
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
      // ✅ إذا كان ملف، افتحه بنفس منطق CategoryPage
      _handleFileTap(item, context);
    }
  }

  // ✅ التحقق إذا كان الملف صورة
  bool _isImageFile(String fileName) {
    final name = fileName.toLowerCase();
    return name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.gif') ||
        name.endsWith('.webp') ||
        name.endsWith('.bmp');
  }

  // ✅ الحصول على URL الصورة مع token
  Future<Map<String, String>> _getImageUrlWithToken(
    Map<String, dynamic> item,
  ) async {
    final fileId =
        item['_id']?.toString() ??
        item['originalData']?['_id']?.toString() ??
        '';
    final url = item['url'] as String? ?? '';
    final token = await StorageService.getToken() ?? '';

    if (url.isEmpty && fileId.isNotEmpty && token.isNotEmpty) {
      // ✅ إذا لم يكن url موجوداً، استخدم endpoint download
      final downloadUrl =
          "${ApiConfig.baseUrl.replaceAll('/api/v1', '')}${ApiEndpoints.downloadFile(fileId)}";
      return {'url': downloadUrl, 'token': token};
    }

    if (url.isNotEmpty) {
      return {'url': url, 'token': token};
    }

    return {'url': '', 'token': ''};
  }

  // ✅ بناء URL الملف
  String getFileUrl(String path) {
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

    print('🔗 Building file URL:');
    print('  - Original path: $path');
    print('  - Clean path: $cleanPath');
    print('  - Base URL: $baseClean');
    print('  - Final URL: $finalUrl');

    return finalUrl;
  }

  // ✅ فتح الملف حسب نوعه - نفس منطق CategoryPage
  Future<void> _handleFileTap(
    Map<String, dynamic> file,
    BuildContext context,
  ) async {
    final filePath = file['path'] as String?;
    final fileId = file['_id']?.toString() ?? '';

    // ✅ إذا لم يكن path موجوداً، استخدم endpoint download
    String finalPath = filePath ?? '';
    if (finalPath.isEmpty && fileId.isNotEmpty) {
      // ✅ استخدام endpoint download بدلاً من path
      final token = await StorageService.getToken();
      if (token != null) {
        // ✅ سنستخدم endpoint download مباشرة في فتح الملف
        finalPath = 'download:$fileId'; // ✅ علامة لاستخدام endpoint download
      }
    }

    if (finalPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).fileUrlNotAvailable),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ✅ استخدام الاسم الأصلي
    final originalName = file['name'] as String?;
    final name = originalName?.toLowerCase() ?? '';
    final fileName = originalName ?? 'ملف بدون اسم';

    // ✅ إذا كان path يبدأ بـ "download:"، استخدم endpoint download
    String url;
    if (finalPath.startsWith('download:')) {
      final fileIdForDownload = finalPath.replaceFirst('download:', '');
      final token = await StorageService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('يجب تسجيل الدخول أولاً'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      url =
          "${ApiConfig.baseUrl.replaceAll('/api/v1', '')}${ApiEndpoints.downloadFile(fileIdForDownload)}";
    } else {
      url = getFileUrl(finalPath);
    }

    // ✅ التحقق من صحة URL
    bool _isValidUrl(String url) {
      try {
        final uri = Uri.parse(url);
        return uri.isAbsolute &&
            (uri.scheme == 'http' || uri.scheme == 'https') &&
            uri.host.isNotEmpty;
      } catch (e) {
        return false;
      }
    }

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

    // ✅ عرض loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      // ✅ الحصول على token
      final token = await StorageService.getToken();
      if (token == null) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('يجب تسجيل الدخول أولاً'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // ✅ التحقق من أن الملف موجود
      final client = http.Client();
      final response = await client.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Range': 'bytes=0-511'},
      );
      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 206) {
        final bytes = response.bodyBytes;

        // ✅ التحقق من صحة PDF
        bool _isValidPdf(List<int> bytes) {
          try {
            if (bytes.length < 4) return false;
            final signature = String.fromCharCodes(bytes.sublist(0, 4));
            return signature == '%PDF';
          } catch (e) {
            return false;
          }
        }

        final isPdf = _isValidPdf(bytes);

        if (name.endsWith('.pdf') && !isPdf) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).invalidPdfFile),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // ✅ PDF
        if (name.endsWith('.pdf')) {
          // ✅ إذا كان PDF صالح، افتحه مباشرة
          if (isPdf) {
            print('✅ Opening PDF: $fileName from $url');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PdfViewerPage(pdfUrl: url, fileName: fileName),
              ),
            );
          } else {
            // ✅ إذا لم يكن PDF صالح، حاول فتحه مباشرة (قد يكون مشفر أو يحتاج تحميل كامل)
            print('⚠️ PDF validation failed, trying to open anyway: $fileName');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PdfViewerPage(pdfUrl: url, fileName: fileName),
              ),
            );
          }
        }
        // ✅ فيديو
        else if (name.endsWith('.mp4') ||
            name.endsWith('.mov') ||
            name.endsWith('.mkv') ||
            name.endsWith('.avi') ||
            name.endsWith('.wmv')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VideoViewer(url: url)),
          );
        }
        // ✅ صورة
        else if (name.endsWith('.jpg') ||
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
        }
        // ✅ نص
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
        }
        // ✅ صوت
        else if (name.endsWith('.mp3') ||
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
        }
        // ✅ باقي الملفات (Office, ZIP, إلخ) - تفتح خارج التطبيق
        else {
          // ✅ إظهار Loading Dialog للملفات الخارجية
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(child: CircularProgressIndicator()),
          );
          
          await OfficeFileOpener.openAnyFile(
            url: url,
            context: context,
            token: token,
            fileName: fileName, // ✅ تمرير اسم الملف الأصلي
            closeLoadingDialog: true, // ✅ إغلاق Loading Dialog تلقائياً
            onProgress: (received, total) {
              // ✅ يمكن إضافة Progress indicator هنا لاحقاً
              if (total > 0) {
                final percent = (received / total * 100).toStringAsFixed(0);
                print("📥 Downloading: $percent% ($received / $total bytes)");
              }
            },
          );
          
          // ✅ لا حاجة لإغلاق Loading Dialog يدوياً - يتم إغلاقه تلقائياً في OfficeFileOpener
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).fileNotAvailableError(response.statusCode)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorLoadingFile(e.toString())),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff28336f),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'بحث ذكي في الملفات...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: Colors.white),
                    tooltip: 'مسح البحث',
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _isSearching = false;
                        _searchResults = [];
                        _searchQuery = null;
                      });
                    },
                  ),
                ),
                autofocus: true,
              )
            : Text(widget.folderName, style: TextStyle(color: Colors.white)),
        backgroundColor: widget.folderColor ?? const Color(0xff28336f),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          // ✅ زر البحث
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: _isSearching ? 'إغلاق البحث' : 'بحث ذكي',
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _isSearching = false;
                  _searchResults = [];
                  _searchQuery = null;
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          // ✅ زر معلومات المجلد
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showFolderInfo(context),
            tooltip: S.of(context).folderInfo,
          ),
          // ✅ زر مشاركة
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _showShareDialog(context),
            tooltip: 'مشاركة المجلد',
          ),
          ViewToggleButtons(
            isGridView: isGridView,
            onViewChanged: (isGrid) {
              setState(() {
                isGridView = isGrid;
              });
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Consumer<FolderController>(
        builder: (context, folderController, child) {
          // ✅ إذا كان البحث نشطاً، عرض نتائج البحث
          if (_isSearching) {
            if (_isSearchLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'جاري البحث...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              );
            }

            if (_searchResults.isEmpty && _searchQuery != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'لا توجد نتائج للبحث: "$_searchQuery"',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'جرب البحث بكلمات مختلفة',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            if (_searchResults.isNotEmpty) {
              // ✅ عرض نتائج البحث
              return _buildSearchResults();
            }
          }

          if (isLoading && contents.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (contents.isEmpty && !isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'المجلد فارغ',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // ✅ فصل المجلدات عن الملفات
          final folders = contents
              .where((item) => item['type'] == 'folder')
              .toList();
          final files = contents
              .where((item) => item['type'] == 'file')
              .toList();

          print(
            '📊 Display stats - Folders: ${folders.length}, Files: ${files.length}',
          );

          // ✅ دمج المجلدات والملفات في قائمة واحدة - المجلدات أولاً
          final allItems = <Map<String, dynamic>>[];

          // ✅ إضافة المجلدات أولاً
          for (var item in folders) {
            final name = item['name'] as String? ?? 'بدون اسم';
            final size = item['size'] as int? ?? 0;

            allItems.add({
              'title': name,
              'name': name,
              'fileCount': item['filesCount'] ?? 0,
              'size': _formatBytes(size),
              'icon': Icons.folder,
              'color': widget.folderColor ?? const Color(0xff28336f),
              'type': 'folder',
              'folderId': item['_id'],
              'itemData': item,
              'originalData': item,
            });
          }

          // ✅ إضافة الملفات بعد المجلدات
          for (var f in files) {
            final fileName = f['name']?.toString() ?? 'ملف بدون اسم';
            final filePath = f['path']?.toString() ?? '';

            // ✅ بناء URL حتى لو كان path فارغاً
            String fileUrl = '';
            if (filePath.isNotEmpty) {
              fileUrl = getFileUrl(filePath);
            }

            allItems.add({
              'title': fileName,
              'name': fileName,
              'url': fileUrl,
              'type': _getFileType(fileName),
              'size': _formatBytes(f['size'] ?? 0),
              'createdAt': f['createdAt'],
              'path': filePath,
              'originalData': f,
              'originalName': fileName,
              'icon': _getFileIcon(fileName),
              'fileColor': _getFileColor(fileName),
            });
          }

          print(
            '✅ Total items: ${allItems.length} (${folders.length} folders + ${files.length} files)',
          );

          return Column(
            children: [
              // ✅ عرض جميع العناصر في GridView موحد
              Expanded(
                child: isGridView
                    ? _buildUnifiedGridView(allItems, folders.length)
                    : _buildUnifiedListView(allItems, folders.length),
              ),

              // ✅ زر تحميل المزيد
              if (hasMore && !isLoading)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () => _loadFolderContents(loadMore: true),
                    child: Text(S.of(context).loadMore),
                  ),
                ),

              if (isLoading && contents.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          );
        },
      ),
    );
  }

  // ✅ بناء عرض نتائج البحث
  Widget _buildSearchResults() {
    // ✅ تحويل نتائج البحث إلى نفس format المستخدم في العرض العادي
    final allItems = <Map<String, dynamic>>[];

    for (var file in _searchResults) {
      final fileName = file['name']?.toString() ?? 'ملف بدون اسم';
      final filePath = file['path']?.toString() ?? '';
      final fileId = file['_id']?.toString() ?? '';
      final fileSize = file['size'] ?? 0;
      final fileType =
          file['type']?.toString() ?? file['category']?.toString() ?? '';
      final relevanceScore = file['relevanceScore'] ?? 0.0;
      final searchType = file['searchType'] ?? 'text';

      // ✅ بناء URL الملف - استخدام endpoint download إذا لم يكن path موجوداً
      String fileUrl = '';
      if (filePath.isNotEmpty) {
        fileUrl = getFileUrl(filePath);
      } else if (fileId.isNotEmpty) {
        // ✅ إذا لم يكن path موجوداً، استخدم endpoint download
        fileUrl =
            "${ApiConfig.baseUrl.replaceAll('/api/v1', '')}${ApiEndpoints.downloadFile(fileId)}";
      }

      // ✅ إعداد originalData بشكل كامل لفتح الملف
      final originalData = {
        '_id': fileId,
        'name': fileName,
        'path': filePath,
        'size': fileSize,
        'type': file['type'] ?? fileType, // mimeType
        'category': file['category'] ?? fileType,
        'createdAt': file['createdAt'],
        'updatedAt': file['updatedAt'],
        'description': file['description'],
        'tags': file['tags'] ?? [],
        'summary': file['summary'],
        'isStarred': file['isStarred'] ?? false,
        'parentFolderId': file['parentFolderId'],
        ...file, // ✅ إضافة جميع البيانات الأخرى
      };

      allItems.add({
        'title': fileName,
        'name': fileName,
        'url': fileUrl,
        'type': _getFileType(fileName), // نوع العرض (image, video, pdf, etc.)
        'size': _formatBytes(fileSize),
        'createdAt': file['createdAt'],
        'path': filePath,
        'originalData': originalData, // ✅ بيانات كاملة لفتح الملف
        'originalName': fileName,
        'icon': _getFileIcon(fileName),
        'fileColor': _getFileColor(fileName),
        'relevanceScore': relevanceScore,
        'searchType': searchType,
        'summary': file['summary'],
        'description': file['description'],
        '_id': fileId, // ✅ إضافة _id مباشرة للاستخدام السريع
      });
    }

    // ✅ ترتيب النتائج حسب relevanceScore
    allItems.sort((a, b) {
      final aScore = a['relevanceScore'] ?? 0.0;
      final bScore = b['relevanceScore'] ?? 0.0;
      return bScore.compareTo(aScore);
    });

    return Column(
      children: [
        // ✅ معلومات البحث
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.black.withOpacity(0.2),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تم العثور على ${allItems.length} نتيجة للبحث: "$_searchQuery"',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        // ✅ عرض النتائج
        Expanded(
          child: allItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد نتائج',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : isGridView
              ? _buildUnifiedGridView(allItems, 0)
              : _buildUnifiedListView(allItems, 0),
        ),
      ],
    );
  }

  // ✅ تنسيق حجم الملف
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

    if (i >= sizes.length) {
      i = sizes.length - 1;
    }

    return '${size.toStringAsFixed(1)} ${sizes[i]}';
  }

  // ✅ الحصول على نوع الملف
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

  // ✅ الحصول على أيقونة الملف حسب الامتداد
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
        return Icons.insert_drive_file;
    }
  }

  // ✅ الحصول على لون الملف حسب الامتداد
  Color _getFileColor(String fileName) {
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
        return Colors.green;
      case 'pdf':
        return Colors.red.shade700;
      case 'doc':
      case 'docx':
        return Colors.brown;
      case 'zip':
      case 'rar':
      case '7z':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // ✅ عرض معلومات المجلد
  Future<void> _showFolderInfo(BuildContext context) async {
    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );
    final token = await StorageService.getToken();

    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).mustLoginFirst)));
      return;
    }

    // ✅ جلب تفاصيل المجلد
    final folderDetails = await folderController.getFolderDetails(
      folderId: widget.folderId,
    );

    if (folderDetails == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل جلب معلومات المجلد')));
      return;
    }

    final folder = folderDetails['folder'] as Map<String, dynamic>?;
    if (folder == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ✅ Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.folderColor ?? const Color(0xff28336f),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder, color: Colors.white, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      folder['name'] ?? widget.folderName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ✅ Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem('folder', '📁', S.of(context).type, S.of(context).folder),
                    _buildDetailItem(
                      'size',
                      '💾',
                      S.of(context).size,
                      _formatBytes(folder['size'] ?? 0),
                    ),
                    _buildDetailItem(
                      'files',
                      '📄',
                      S.of(context).filesCount,
                      '${folder['filesCount'] ?? 0}',
                    ),
                    _buildDetailItem(
                      'subfolders',
                      '📂',
                      S.of(context).subfoldersCount,
                      '${folder['subfoldersCount'] ?? 0}',
                    ),
                    _buildDetailItem(
                      'time',
                      '🕐',
                      S.of(context).creationDate,
                      _formatDate(folder['createdAt']),
                    ),
                    _buildDetailItem(
                      'edit',
                      '✏️',
                      S.of(context).lastModified,
                      _formatDate(folder['updatedAt']),
                    ),
                    _buildDetailItem(
                      'description',
                      '📝',
                      S.of(context).description,
                      folder['description']?.isNotEmpty == true
                          ? folder['description']
                          : "—",
                    ),
                    _buildDetailItem(
                      'tags',
                      '🏷️',
                      S.of(context).tags,
                      (folder['tags'] as List?)?.join(', ') ?? "—",
                    ),

                    // ✅ Shared With Section
                    if (folder['sharedWith'] != null &&
                        (folder['sharedWith'] as List).isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          _buildDetailItem(
                            'share',
                            '👥',
                            'تمت المشاركة مع',
                            (folder['sharedWith'] as List)
                                    .map<String>(
                                      (u) =>
                                          u['user']?['email']?.toString() ??
                                          u['email']?.toString() ??
                                          '',
                                    )
                                    .where((email) => email.isNotEmpty)
                                    .join(', ') ??
                                "—",
                          ),
                        ],
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

  Widget _buildDetailItem(
    String type,
    String emoji,
    String label,
    String value,
  ) {
    Color getIconColor() {
      switch (type) {
        case 'folder':
          return Color(0xFF10B981);
        case 'size':
          return Color(0xFFF59E0B);
        case 'files':
          return Color(0xFF3B82F6);
        case 'subfolders':
          return Color(0xFF8B5CF6);
        case 'time':
          return Color(0xFFEF4444);
        case 'edit':
          return Color(0xFF8B5CF6);
        case 'description':
          return Color(0xFF4F6BED);
        case 'tags':
          return Color(0xFFEC4899);
        case 'share':
          return Color(0xFF06B6D4);
        default:
          return Color(0xFF6B7280);
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: getIconColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(emoji, style: TextStyle(fontSize: 20)),
          ),
          SizedBox(width: 16),
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
                    fontSize: 16,
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
    if (date == null) return "—";
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "—";
    }
  }

  // ✅ عرض dialog المشاركة
  void _showShareDialog(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShareFolderWithRoomPage(
          folderId: widget.folderId,
          folderName: widget.folderName,
        ),
      ),
    );

    // ✅ إعادة تحميل محتويات المجلد بعد المشاركة
    if (result == true) {
      _loadFolderContents();
    }
  }

  // ✅ بناء GridView موحد للمجلدات والملفات
  Widget _buildUnifiedGridView(
    List<Map<String, dynamic>> items,
    int foldersCount,
  ) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75, // ✅ نفس الحجم للكاردات
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final isFolder = item['type'] == 'folder';

        return _buildUnifiedCard(item, isFolder, index < foldersCount);
      },
    );
  }

  // ✅ بناء ListView موحد للمجلدات والملفات
  Widget _buildUnifiedListView(
    List<Map<String, dynamic>> items,
    int foldersCount,
  ) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isFolder = item['type'] == 'folder';

        // ✅ في ListView، نستخدم نفس الكارد لكن بحجم مختلف
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          height: 200, // ✅ ارتفاع ثابت للكارد في ListView
          child: _buildUnifiedCard(item, isFolder, index < foldersCount),
        );
      },
    );
  }

  // ✅ بناء كارد موحد للمجلدات والملفات
  Widget _buildUnifiedCard(
    Map<String, dynamic> item,
    bool isFolder,
    bool isInFoldersSection,
  ) {
    final name =
        item['name'] as String? ?? item['title'] as String? ?? 'بدون اسم';
    final size = item['size'] as String? ?? '0 B';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // ✅ إعداد البيانات بشكل صحيح لـ _handleItemTap
          final itemForTap = <String, dynamic>{
            'type': isFolder ? 'folder' : 'file',
            '_id': isFolder
                ? (item['folderId'] as String? ??
                      item['itemData']?['_id'] as String?)
                : (item['originalData']?['_id'] as String? ??
                      item['_id'] as String?),
            'name': isFolder
                ? (item['name'] as String? ??
                      item['itemData']?['name'] as String?)
                : (item['name'] as String? ??
                      item['originalData']?['name'] as String?),
            if (!isFolder && item['originalData'] != null)
              ...Map<String, dynamic>.from(item['originalData'] as Map),
          };
          _handleItemTap(itemForTap);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ منطقة الصورة/الأيقونة
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    // ✅ خلفية الكارد
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isFolder
                            ? (widget.folderColor ?? const Color(0xff28336f))
                                  .withOpacity(0.1)
                            : (item['fileColor'] as Color? ?? Colors.grey)
                                  .withOpacity(0.1),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: isFolder
                          ? Center(
                              child: Icon(
                                Icons.folder,
                                size: 64,
                                color:
                                    widget.folderColor ??
                                    const Color(0xff28336f),
                              ),
                            )
                          : item['url'] != null &&
                                (item['url'] as String).isNotEmpty &&
                                _isImageFile(item['name']?.toString() ?? '')
                          ? FutureBuilder<Map<String, String>>(
                              future: _getImageUrlWithToken(item),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                final urlData = snapshot.data;
                                if (urlData == null ||
                                    urlData['url'] == null ||
                                    urlData['url']!.isEmpty) {
                                  return Center(
                                    child: Icon(
                                      item['icon'] as IconData? ??
                                          Icons.insert_drive_file,
                                      size: 64,
                                      color:
                                          item['fileColor'] as Color? ??
                                          Colors.grey,
                                    ),
                                  );
                                }

                                final imageUrl = urlData['url']!;
                                final token = urlData['token'] ?? '';

                                return ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    headers: token.isNotEmpty
                                        ? {'Authorization': 'Bearer $token'}
                                        : null,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          item['icon'] as IconData? ??
                                              Icons.insert_drive_file,
                                          size: 64,
                                          color:
                                              item['fileColor'] as Color? ??
                                              Colors.grey,
                                        ),
                                      );
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Icon(
                                item['icon'] as IconData? ??
                                    Icons.insert_drive_file,
                                size: 64,
                                color:
                                    item['fileColor'] as Color? ?? Colors.grey,
                              ),
                            ),
                    ),

                    // ✅ زر 3 نقاط
                    Positioned(
                      top: 8,
                      right: 8,
                      child: isFolder
                          ? PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.grey[700],
                                size: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                              itemBuilder: (context) {
                                // ✅ استخدام نفس القائمة للمجلدات من دون أب
                                final folderData = item['itemData'] ?? item;
                                final folderId =
                                    item['folderId'] as String? ??
                                    folderData['_id'] as String?;
                                final folderController =
                                    Provider.of<FolderController>(
                                      context,
                                      listen: false,
                                    );

                                // ✅ التحقق من حالة isStarred
                                var isStarred =
                                    folderData['isStarred'] ?? false;
                                if (folderId != null) {
                                  final starredFolder = folderController
                                      .starredFolders
                                      .firstWhere(
                                        (f) => f['_id'] == folderId,
                                        orElse: () => {},
                                      );
                                  if (starredFolder.isNotEmpty) {
                                    isStarred =
                                        starredFolder['isStarred'] ?? true;
                                  }
                                }

                                return _buildFolderMenuItemsForPopup(
                                  item,
                                  isStarred,
                                );
                              },
                              onSelected: (value) {
                                _handleFolderMenuActionFromPopup(
                                  context,
                                  value,
                                  item,
                                );
                              },
                            )
                          : PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.grey[700],
                                size: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                              itemBuilder: (context) {
                                // ✅ استخدام نفس القائمة من FilesGridView1
                                final originalData =
                                    item['originalData'] ?? item;
                                final fileId = originalData['_id']?.toString();
                                final isStarred =
                                    originalData['isStarred'] ?? false;
                                return _buildNormalFileMenuItemsForPopup(
                                  item,
                                  isStarred,
                                );
                              },
                              onSelected: (value) {
                                _handleFileMenuActionFromPopup(
                                  context,
                                  value,
                                  item,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              // ✅ معلومات الكارد
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ اسم الملف/المجلد
                      Flexible(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      SizedBox(height: 4),

                      // ✅ الحجم/عدد الملفات
                      Row(
                        children: [
                          Icon(
                            isFolder ? Icons.folder : Icons.insert_drive_file,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              isFolder ? '${item['fileCount'] ?? 0} ملف' : size,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ عرض قائمة المجلدات من الأسفل
  void _showFolderContextMenu(
    BuildContext context,
    Map<String, dynamic> folder,
  ) {
    // ✅ حفظ context الأصلي قبل فتح الـ modal
    final scaffoldContext = context;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(modalContext).size.height * 0.7,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Handle bar
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ✅ قائمة خيارات المجلدات - قابلة للتمرير
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMenuItem(
                        modalContext,
                        icon: Icons.open_in_new_rounded,
                        title: S.of(context).open,
                        iconColor: Colors.blue,
                        onTap: () {
                          Navigator.pop(modalContext);
                          if (scaffoldContext.mounted) {
                            _handleItemTap(folder);
                          }
                        },
                      ),

                      _buildMenuItem(
                        modalContext,
                        icon: Icons.info_outline_rounded,
                        title: S.of(context).viewInfo,
                        iconColor: Colors.teal,
                        onTap: () {
                          Navigator.pop(modalContext);
                          if (scaffoldContext.mounted) {
                            _showFolderInfoFromItem(scaffoldContext, folder);
                          }
                        },
                      ),

                      _buildMenuItem(
                        modalContext,
                        icon: Icons.edit_rounded,
                        title: S.of(context).edit,
                        iconColor: Colors.orange,
                        onTap: () {
                          Navigator.pop(modalContext);
                          if (scaffoldContext.mounted) {
                            _showRenameDialogFromItem(scaffoldContext, folder);
                          }
                        },
                      ),

                      _buildMenuItem(
                        modalContext,
                        icon: Icons.share_rounded,
                        title: S.of(context).share,
                        iconColor: Colors.green,
                        onTap: () {
                          Navigator.pop(modalContext);
                          if (scaffoldContext.mounted) {
                            _showShareDialogFromItem(scaffoldContext, folder);
                          }
                        },
                      ),

                      _buildMenuItem(
                        modalContext,
                        icon: Icons.drive_file_move_rounded,
                        title: S.of(context).move,
                        iconColor: Colors.purple,
                        onTap: () {
                          Navigator.pop(modalContext);
                          if (scaffoldContext.mounted) {
                            _showMoveFolderDialogFromItem(
                              scaffoldContext,
                              folder,
                            );
                          }
                        },
                      ),

                      _buildMenuItem(
                        modalContext,
                        icon: _getFolderStarIcon(folder),
                        title: _getFolderStarText(folder),
                        iconColor: Colors.amber[700],
                        onTap: () {
                          Navigator.pop(modalContext);
                          if (scaffoldContext.mounted) {
                            _toggleFolderFavorite(scaffoldContext, folder);
                          }
                        },
                      ),

                      Divider(height: 1),

                      _buildMenuItem(
                        modalContext,
                        icon: Icons.delete_outline_rounded,
                        title: S.of(context).delete,
                        iconColor: Colors.red,
                        textColor: Colors.red,
                        onTap: () {
                          Navigator.pop(modalContext);
                          if (scaffoldContext.mounted) {
                            _showDeleteDialogFromItem(scaffoldContext, folder);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ بناء قائمة المجلدات للـ PopupMenuButton - نفس FilesListView
  List<PopupMenuEntry<String>> _buildFolderMenuItemsForPopup(
    Map<String, dynamic> folder,
    bool isStarred,
  ) {
    return [
      PopupMenuItem<String>(
        value: 'open',
        child: Row(
          children: [
            Icon(Icons.open_in_new_rounded, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text(S.of(context).open),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'info',
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.teal, size: 20),
            SizedBox(width: 8),
            Text(S.of(context).viewInfo),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'rename',
        child: Row(
          children: [
            Icon(Icons.edit_rounded, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Text(S.of(context).edit),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'share',
        child: Row(
          children: [
            Icon(Icons.share_rounded, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text(S.of(context).share),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'move',
        child: Row(
          children: [
            Icon(Icons.drive_file_move_rounded, color: Colors.purple, size: 20),
            SizedBox(width: 8),
            Text(S.of(context).move),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'favorite',
        child: Row(
          children: [
            Icon(
              isStarred ? Icons.star_rounded : Icons.star_border_rounded,
              color: Colors.amber[700],
              size: 20,
            ),
            SizedBox(width: 8),
            Text(isStarred ? S.of(context).removeFromFavorites : S.of(context).addToFavorites),
          ],
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text(S.of(context).delete, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    ];
  }

  // ✅ معالجة إجراءات قائمة المجلدات - نفس FilesListView
  void _handleFolderMenuActionFromPopup(
    BuildContext context,
    String action,
    Map<String, dynamic> folder,
  ) {
    switch (action) {
      case 'open':
        // ✅ إعداد البيانات بشكل صحيح لـ _handleItemTap
        final folderData = folder['itemData'] ?? folder;
        final folderId =
            folder['folderId'] as String? ?? folderData['_id'] as String?;
        final folderName =
            folder['name'] as String? ?? folderData['name'] as String?;

        if (folderId != null) {
          final itemForTap = {
            'type': 'folder',
            '_id': folderId,
            'name': folderName ?? S.of(context).folder,
          };
          _handleItemTap(itemForTap);
        }
        break;
      case 'info':
        _showFolderInfoFromItem(context, folder);
        break;
      case 'rename':
        _showRenameDialogFromItem(context, folder);
        break;
      case 'share':
        _showShareDialogFromItem(context, folder);
        break;
      case 'move':
        _showMoveFolderDialogFromItem(context, folder);
        break;
      case 'favorite':
        _toggleFolderFavorite(context, folder);
        break;
      case 'delete':
        _showDeleteDialogFromItem(context, folder);
        break;
    }
  }

  // ✅ عرض قائمة الملفات من الأسفل - نفس القائمة من FilesGridView1
  void _showFileContextMenu(BuildContext context, Map<String, dynamic> file) {
    // ✅ حفظ context الأصلي قبل فتح الـ modal
    final scaffoldContext = context;

    // ✅ الحصول على حالة النجمة - نفس FilesGridView1
    final originalData = file['originalData'] ?? file;
    final fileId = originalData['_id']?.toString();
    final isStarred = fileId != null
        ? (originalData['isStarred'] ?? false)
        : false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(modalContext).size.height * 0.7,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Handle bar
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ✅ قائمة خيارات الملفات - نفس FilesGridView1
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMenuItem(
                        modalContext,
                        icon: Icons.open_in_new_rounded,
                        title: S.of(context).open,
                        iconColor: Colors.blue,
                        onTap: () {
                          Navigator.pop(modalContext);
                          if (scaffoldContext.mounted) {
                            final originalData = file['originalData'] ?? file;
                            _handleFileTap(originalData, scaffoldContext);
                          }
                        },
                      ),

                      _buildMenuItem(
                        modalContext,
                        icon: Icons.info_outline_rounded,
                        title: S.of(context).viewInfo,
                        iconColor: Colors.teal,
                        onTap: () {
                          Navigator.pop(modalContext);
                          if (scaffoldContext.mounted) {
                            Navigator.push(
                              scaffoldContext,
                              MaterialPageRoute(
                                builder: (_) => FileDetailsPage(
                                  fileId: originalData['_id'] ?? file['_id'],
                                ),
                              ),
                            );
                          }
                        },
                      ),

                      _buildMenuItem(
                        modalContext,
                        icon: Icons.edit_rounded,
                        title: S.of(context).edit,
                        iconColor: Colors.orange,
                        onTap: () {
                          Navigator.pop(modalContext);
                          if (scaffoldContext.mounted) {
                            FileActionsService.editFile(scaffoldContext, file);
                            _loadFolderContents();
                          }
                        },
                      ),

                      _buildMenuItem(
                        modalContext,
                        icon: Icons.share_rounded,
                        title: S.of(context).share,
                        iconColor: Colors.green,
                        onTap: () {
                          Navigator.pop(modalContext);
                          if (scaffoldContext.mounted) {
                            FileActionsService.shareFile(scaffoldContext, file);
                          }
                        },
                      ),

                      _buildMenuItem(
                        modalContext,
                        icon: Icons.drive_file_move_rounded,
                        title: S.of(context).move,
                        iconColor: Colors.purple,
                        onTap: () {
                          Navigator.pop(modalContext);
                          if (scaffoldContext.mounted) {
                            _showMoveFileDialogFromItem(scaffoldContext, file);
                          }
                        },
                      ),

                      _buildMenuItem(
                        modalContext,
                        icon: isStarred
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        title: isStarred
                            ? 'إزالة من المفضلة'
                            : 'إضافة إلى المفضلة',
                        iconColor: Colors.amber[700],
                        onTap: () {
                          Navigator.pop(modalContext);
                          if (scaffoldContext.mounted) {
                            final fileController = Provider.of<FileController>(
                              scaffoldContext,
                              listen: false,
                            );
                            FileActionsService.toggleStar(
                              scaffoldContext,
                              fileController,
                              file,
                              onToggle: () {
                                _loadFolderContents();
                              },
                            );
                          }
                        },
                      ),

                      Divider(height: 1),

                      _buildMenuItem(
                        modalContext,
                        icon: Icons.delete_outline_rounded,
                        title: S.of(context).delete,
                        iconColor: Colors.red,
                        textColor: Colors.red,
                        onTap: () {
                          Navigator.pop(modalContext);
                          if (scaffoldContext.mounted) {
                            final fileController = Provider.of<FileController>(
                              scaffoldContext,
                              listen: false,
                            );
                            FileActionsService.deleteFile(
                              scaffoldContext,
                              fileController,
                              file,
                            );
                            _loadFolderContents();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ بناء عنصر القائمة - نفس التصميم المستخدم في FolderFileCard
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
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

  // ✅ بناء قائمة الملفات للـ PopupMenuButton - مطابقة للصورة
  List<PopupMenuEntry<String>> _buildNormalFileMenuItemsForPopup(
    Map<String, dynamic> file,
    bool isStarred,
  ) {
    return [
      // ✅ 1. Open
      PopupMenuItem<String>(
        value: 'open',
        child: Row(
          children: [
            Icon(Icons.open_in_new_rounded, color: Colors.blue, size: 20),
            SizedBox(width: 12),
            Text('Open', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      // ✅ 2. View Info
      PopupMenuItem<String>(
        value: 'info',
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.teal, size: 20),
            SizedBox(width: 12),
            Text('View Info', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      // ✅ 3. Download (تحميل)
      PopupMenuItem<String>(
        value: 'download',
        child: Row(
          children: [
            Icon(Icons.download_rounded, color: Colors.blue, size: 20),
            SizedBox(width: 12),
            Text(S.of(context).download, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      // ✅ 4. Edit
      PopupMenuItem<String>(
        value: 'edit',
        child: Row(
          children: [
            Icon(Icons.edit_rounded, color: Colors.orange, size: 20),
            SizedBox(width: 12),
            Text(S.of(context).edit, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      // ✅ 5. Share
      PopupMenuItem<String>(
        value: 'share',
        child: Row(
          children: [
            Icon(Icons.share_rounded, color: Colors.green, size: 20),
            SizedBox(width: 12),
            Text(S.of(context).share, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      // ✅ 6. Move
      PopupMenuItem<String>(
        value: 'move',
        child: Row(
          children: [
            Icon(Icons.drive_file_move_rounded, color: Colors.purple, size: 20),
            SizedBox(width: 12),
            Text(S.of(context).move, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      // ✅ 7. Remove from Favorites / Add to Favorites
      PopupMenuItem<String>(
        value: 'favorite',
        child: Row(
          children: [
            Icon(
              isStarred ? Icons.star_rounded : Icons.star_border_rounded,
              color: Colors.amber[700],
              size: 20,
            ),
            SizedBox(width: 12),
            Text(
              isStarred ? 'Remove from Favorites' : 'Add to Favorites',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      // ✅ 8. Delete
      PopupMenuItem<String>(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
            SizedBox(width: 12),
            Text('Delete', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red)),
          ],
        ),
      ),
    ];
  }

  // ✅ معالجة إجراءات قائمة الملفات - نفس FilesGridView1
  void _handleFileMenuActionFromPopup(
    BuildContext context,
    String action,
    Map<String, dynamic> file,
  ) {
    final fileController = Provider.of<FileController>(context, listen: false);

    switch (action) {
      case 'open':
        final originalData = file['originalData'] ?? file;
        _handleFileTap(originalData, context);
        break;
      case 'info':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FileDetailsPage(
              fileId: file['originalData']?['_id'] ?? file['_id'],
            ),
          ),
        );
        break;
      case 'download':
        // ✅ تحميل الملف
        FileActionsService.downloadFile(context, file);
        break;
      case 'edit':
        FileActionsService.editFile(context, file);
        _loadFolderContents();
        break;
      case 'share':
        FileActionsService.shareFile(context, file);
        break;
      case 'move':
        _showMoveFileDialogFromItem(context, file);
        break;
      case 'favorite':
        FileActionsService.toggleStar(
          context,
          fileController,
          file,
          onToggle: () {
            _loadFolderContents();
          },
        );
        break;
      case 'delete':
        FileActionsService.deleteFile(context, fileController, file);
        _loadFolderContents();
        break;
    }
  }

  // ✅ دوال مساعدة للعمليات
  void _showFolderInfoFromItem(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    final folderId =
        folder['folderId'] as String? ?? folder['itemData']?['_id'] as String?;

    if (folderId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ: معرف المجلد غير موجود')));
      return;
    }

    // ✅ جلب تفاصيل المجلد من الباك إند
    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );
    final folderDetails = await folderController.getFolderDetails(
      folderId: folderId,
    );

    if (folderDetails == null || folderDetails['folder'] == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل جلب معلومات المجلد')));
      }
      return;
    }

    final folderData = folderDetails['folder'] as Map<String, dynamic>;

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ✅ Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.folderColor ?? const Color(0xff28336f),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      folderData['name'] ?? 'مجلد',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ✅ Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem('folder', '📁', S.of(context).type, S.of(context).folder),
                    _buildDetailItem(
                      'size',
                      '💾',
                      S.of(context).size,
                      _formatBytes(folderData['size'] ?? 0),
                    ),
                    _buildDetailItem(
                      'files',
                      '📄',
                      S.of(context).filesCount,
                      '${folderData['filesCount'] ?? 0}',
                    ),
                    _buildDetailItem(
                      'subfolders',
                      '📂',
                      S.of(context).subfoldersCount,
                      '${folderData['subfoldersCount'] ?? 0}',
                    ),
                    _buildDetailItem(
                      'time',
                      '🕐',
                      S.of(context).creationDate,
                      _formatDate(folderData['createdAt']),
                    ),
                    _buildDetailItem(
                      'edit',
                      '✏️',
                      S.of(context).lastModified,
                      _formatDate(folderData['updatedAt']),
                    ),
                    _buildDetailItem(
                      'description',
                      '📝',
                      S.of(context).description,
                      folderData['description']?.isNotEmpty == true
                          ? folderData['description']
                          : "—",
                    ),
                    _buildDetailItem(
                      'tags',
                      '🏷️',
                      S.of(context).tags,
                      (folderData['tags'] as List?)?.join(', ') ?? "—",
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

  void _showRenameDialogFromItem(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    final folderData = {
      'title': folder['name'] as String? ?? 'مجلد',
      'folderId':
          folder['folderId'] as String? ??
          folder['itemData']?['_id'] as String?,
      'folderData': folder['itemData'] ?? folder,
    };

    await showRenameDialogHelper(context, folderData, () {
      // ✅ إعادة تحميل محتويات المجلد بعد التحديث
      _loadFolderContents();
    });
  }

  void _showShareDialogFromItem(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    final folderData = {
      'title': folder['name'] as String? ?? 'مجلد',
      'folderId':
          folder['folderId'] as String? ??
          folder['itemData']?['_id'] as String?,
    };

    await showShareDialogHelper(context, folderData);
  }

  void _showMoveFolderDialogFromItem(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    // ✅ حفظ context الأصلي قبل فتح الـ modal
    final scaffoldContext = context;

    final folderData = folder['itemData'] ?? folder;
    final folderId =
        folder['folderId'] as String? ?? folderData['_id'] as String?;
    final folderName =
        folder['name'] as String? ?? folderData['name'] as String? ?? S.of(context).folder;
    final currentParentId = folderData['parentId']?.toString();

    if (folderId == null) {
      if (scaffoldContext.mounted) {
        ScaffoldMessenger.of(
          scaffoldContext,
        ).showSnackBar(SnackBar(content: Text('خطأ: معرف المجلد غير موجود')));
      }
      return;
    }

    if (!scaffoldContext.mounted) return;

    showModalBottomSheet(
      context: scaffoldContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _FolderNavigationDialog(
        title: 'نقل المجلد: $folderName',
        excludeFolderId: folderId,
        excludeParentId: currentParentId,
        onSelect: (targetFolderId) async {
          Navigator.pop(modalContext);
          if (scaffoldContext.mounted) {
            await _moveFolder(
              scaffoldContext,
              folderId,
              targetFolderId,
              folderName,
            );
          }
        },
      ),
    );

    // ✅ إعادة تحميل محتويات المجلد بعد النقل - إعادة تعيين الصفحة
    // ✅ ملاحظة: _moveFolder يستدعي _loadFolderContents داخلياً، لكن نضيفه هنا أيضاً للتأكد
  }

  void _showDeleteDialogFromItem(
    BuildContext context,
    Map<String, dynamic> folder,
  ) {
    final folderData = {
      'title': folder['name'] as String? ?? 'مجلد',
      'folderId':
          folder['folderId'] as String? ??
          folder['itemData']?['_id'] as String?,
      'folderData': folder['itemData'] ?? folder,
    };

    showDeleteDialogHelper(context, folderData, () {
      // ✅ إعادة تحميل محتويات المجلد بعد الحذف
      _loadFolderContents();
    });
  }

  void _showFileInfoFromItem(BuildContext context, Map<String, dynamic> file) {
    // TODO: إضافة دالة معلومات الملف
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).featureUnderDevelopment)));
    }
  }

  void _showMoveFileDialogFromItem(
    BuildContext context,
    Map<String, dynamic> file,
  ) async {
    // ✅ حفظ context الأصلي قبل فتح الـ modal
    final scaffoldContext = context;

    final originalData = file['originalData'] ?? file;
    final fileId = originalData['_id']?.toString();
    final fileName =
        file['name'] as String? ?? originalData['name'] as String? ?? S.of(context).file;
    final currentParentId = originalData['parentFolderId']?.toString();

    if (fileId == null) {
      if (scaffoldContext.mounted) {
        ScaffoldMessenger.of(
          scaffoldContext,
        ).showSnackBar(SnackBar(content: Text('خطأ: معرف الملف غير موجود')));
      }
      return;
    }

    if (!scaffoldContext.mounted) return;

    showModalBottomSheet(
      context: scaffoldContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _FolderNavigationDialog(
        title: 'نقل الملف: $fileName',
        excludeFolderId:
            null, // ✅ الملف ليس مجلداً، لذا لا نحتاج لاستبعاد أي مجلد
        excludeParentId:
            currentParentId, // ✅ استبعاد المجلد الحالي فقط (لتجنب النقل لنفس المكان)
        onSelect: (targetFolderId) {
          Navigator.pop(modalContext);
          if (scaffoldContext.mounted) {
            _moveFile(scaffoldContext, fileId, targetFolderId, fileName);
          }
        },
      ),
    );
  }

  /// ✅ دالة لنقل الملف
  Future<void> _moveFile(
    BuildContext context,
    String fileId,
    String? targetFolderId,
    String fileName,
  ) async {
    final fileController = Provider.of<FileController>(context, listen: false);
    final token = await StorageService.getToken();

    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ: يجب تسجيل الدخول أولاً')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 16),
            Text(S.of(context).movingFile),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    final success = await fileController.moveFile(
      fileId: fileId,
      token: token,
      targetFolderId: targetFolderId,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم نقل الملف بنجاح'),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ إعادة تحميل محتويات المجلد بعد النقل - إعادة تعيين الصفحة
        // ✅ استخدام await لضمان اكتمال التحديث
        await _loadFolderContents(resetPage: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(fileController.errorMessage ?? '❌ فشل نقل الملف'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteFileDialogFromItem(
    BuildContext context,
    Map<String, dynamic> file,
  ) {
    final fileController = Provider.of<FileController>(context, listen: false);
    FileActionsService.deleteFile(context, fileController, file);

    // ✅ إعادة تحميل محتويات المجلد بعد الحذف
    _loadFolderContents();
  }

  // ✅ دوال مساعدة للميزات الجديدة

  // ✅ الحصول على أيقونة النجمة للمجلد
  IconData _getFolderStarIcon(Map<String, dynamic> folder) {
    final folderData = folder['itemData'] ?? folder;
    final isStarred = folderData['isStarred'] ?? false;
    return isStarred ? Icons.star_rounded : Icons.star_border_rounded;
  }

  // ✅ الحصول على نص النجمة للمجلد
  String _getFolderStarText(Map<String, dynamic> folder) {
    final folderData = folder['itemData'] ?? folder;
    final isStarred = folderData['isStarred'] ?? false;
    return isStarred ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة';
  }

  // ✅ تبديل حالة المفضلة للمجلد
  Future<void> _toggleFolderFavorite(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    final folderId =
        folder['folderId'] as String? ?? folder['itemData']?['_id'] as String?;
    if (folderId == null) return;

    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );

    // ✅ إظهار مؤشر التحميل
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
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
              Text(S.of(context).updating),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }

    // ✅ استدعاء API لإضافة/إزالة من المفضلة
    final result = await folderController.toggleStarFolder(folderId: folderId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (result['success'] == true) {
        final isStarred = result['isStarred'] as bool? ?? false;

        // ✅ تحديث البيانات المحلية
        final folderData = folder['itemData'] ?? folder;
        if (folderData is Map<String, dynamic>) {
          folderData['isStarred'] = isStarred;
        }
        folder['isStarred'] = isStarred;

        // ✅ إعادة تحميل محتويات المجلد
        _loadFolderContents();

        // ✅ إظهار رسالة النجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isStarred
                  ? '✅ تم إضافة المجلد إلى المفضلة'
                  : '✅ تم إزالة المجلد من المفضلة',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // ✅ إظهار رسالة الخطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              folderController.errorMessage ?? '❌ فشل تحديث حالة المفضلة',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // ✅ الحصول على أيقونة النجمة للملف
  IconData _getFileStarIcon(Map<String, dynamic> file) {
    final originalData = file['originalData'] ?? file;
    final isStarred = originalData['isStarred'] ?? false;
    return isStarred ? Icons.star_rounded : Icons.star_border_rounded;
  }

  // ✅ الحصول على نص النجمة للملف
  String _getFileStarText(Map<String, dynamic> file) {
    final originalData = file['originalData'] ?? file;
    final isStarred = originalData['isStarred'] ?? false;
    return isStarred ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة';
  }

  // ✅ تبديل حالة المفضلة للملف
  void _toggleFileFavorite(BuildContext context, Map<String, dynamic> file) {
    final fileController = Provider.of<FileController>(context, listen: false);
    FileActionsService.toggleStar(
      context,
      fileController,
      file,
      onToggle: () {
        // ✅ إعادة تحميل محتويات المجلد بعد التحديث
        _loadFolderContents();
      },
    );
  }

  // ✅ تعديل الملف
  void _editFileFromItem(BuildContext context, Map<String, dynamic> file) {
    FileActionsService.editFile(context, file);

    // ✅ إعادة تحميل محتويات المجلد بعد التعديل
    _loadFolderContents();
  }

  // ✅ مشاركة الملف
  void _shareFileFromItem(BuildContext context, Map<String, dynamic> file) {
    FileActionsService.shareFile(context, file);
  }

  // ✅ جلب جميع المجلدات بشكل متكرر (بما في ذلك المجلدات الفرعية)
  Future<List<Map<String, dynamic>>> _getAllFoldersRecursive(
    FolderController folderController,
    String? excludeFolderId,
    String? excludeParentId,
  ) async {
    final List<Map<String, dynamic>> allFolders = [];

    // ✅ جلب المجلدات من الجذر
    final rootResponse = await folderController.getAllFolders(
      page: 1,
      limit: 100,
    );
    if (rootResponse != null && rootResponse['folders'] != null) {
      final rootFolders = List<Map<String, dynamic>>.from(
        rootResponse['folders'] ?? [],
      );
      allFolders.addAll(rootFolders);

      // ✅ جلب المجلدات الفرعية لكل مجلد
      for (var folder in rootFolders) {
        final folderId = folder['_id']?.toString();
        if (folderId != null) {
          await _getSubfoldersRecursive(folderController, folderId, allFolders);
        }
      }
    }

    // ✅ تصفية المجلدات المستبعدة
    return allFolders.where((f) {
      final fId = f['_id']?.toString();
      return fId != excludeFolderId && fId != excludeParentId;
    }).toList();
  }

  // ✅ جلب المجلدات الفرعية بشكل متكرر
  Future<void> _getSubfoldersRecursive(
    FolderController folderController,
    String parentFolderId,
    List<Map<String, dynamic>> allFolders,
  ) async {
    try {
      final contentsResponse = await folderController.getFolderContents(
        folderId: parentFolderId,
        page: 1,
        limit: 100,
      );

      if (contentsResponse != null && contentsResponse['subfolders'] != null) {
        final subfolders = List<Map<String, dynamic>>.from(
          contentsResponse['subfolders'] ?? [],
        );
        allFolders.addAll(subfolders);

        // ✅ جلب المجلدات الفرعية لكل مجلد فرعي
        for (var subfolder in subfolders) {
          final subfolderId = subfolder['_id']?.toString();
          if (subfolderId != null) {
            await _getSubfoldersRecursive(
              folderController,
              subfolderId,
              allFolders,
            );
          }
        }
      }
    } catch (e) {
      print('Error getting subfolders for $parentFolderId: $e');
    }
  }

  // ✅ بناء هيكل شجري للمجلدات
  List<Map<String, dynamic>> _buildFolderTree(
    List<Map<String, dynamic>> allFolders,
    String? excludeFolderId,
    String? excludeParentId,
  ) {
    // ✅ تصفية المجلدات المستبعدة
    final availableFolders = allFolders.where((f) {
      final fId = f['_id']?.toString();
      return fId != excludeFolderId && fId != excludeParentId;
    }).toList();

    // ✅ بناء الهيكل الشجري
    final Map<String, List<Map<String, dynamic>>> childrenMap = {};
    final List<Map<String, dynamic>> rootFolders = [];

    // ✅ تجميع المجلدات حسب parentId
    for (var folder in availableFolders) {
      final parentId = folder['parentId']?.toString();
      if (parentId == null || parentId == 'null') {
        rootFolders.add(folder);
      } else {
        if (!childrenMap.containsKey(parentId)) {
          childrenMap[parentId] = [];
        }
        childrenMap[parentId]!.add(folder);
      }
    }

    // ✅ إضافة المجلدات الفرعية لكل مجلد
    void addChildren(Map<String, dynamic> folder) {
      final folderId = folder['_id']?.toString();
      if (folderId != null && childrenMap.containsKey(folderId)) {
        folder['children'] = childrenMap[folderId]!;
        for (var child in folder['children']) {
          addChildren(child);
        }
      }
    }

    // ✅ إضافة المجلدات الفرعية للمجلدات الجذرية
    for (var folder in rootFolders) {
      addChildren(folder);
    }

    return rootFolders;
  }

  // ✅ بناء عنصر شجري للمجلد (قابل للتوسيع)
  Widget _buildFolderTreeItem(
    BuildContext context,
    Map<String, dynamic> folder,
    int level,
    Function(String?) onSelect,
  ) {
    final folderId = folder['_id']?.toString();
    final folderName = folder['name'] ?? S.of(context).folderWithoutName;
    final children = folder['children'] as List<Map<String, dynamic>>? ?? [];
    final hasChildren = children.isNotEmpty;

    return ExpansionTile(
      tilePadding: EdgeInsets.only(left: 16.0 + (level * 24.0), right: 16.0),
      leading: Icon(
        hasChildren ? Icons.folder_rounded : Icons.folder_outlined,
        color: Colors.orange,
      ),
      title: Text(folderName),
      subtitle: Text('${folder['filesCount'] ?? 0} ملف'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ زر لاختيار المجلد نفسه
          IconButton(
            icon: Icon(Icons.check_circle_outline, color: Colors.green),
            onPressed: () => onSelect(folderId),
            tooltip: 'اختيار "$folderName"',
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
          if (hasChildren) ...[
            SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ],
      ),
      children: [
        // ✅ زر لاختيار المجلد نفسه (في حالة التوسيع)
        ListTile(
          contentPadding: EdgeInsets.only(
            left: 16.0 + ((level + 1) * 24.0),
            right: 16.0,
          ),
          leading: Icon(Icons.check_circle, color: Colors.green),
          title: Text('اختيار "$folderName"'),
          onTap: () => onSelect(folderId),
        ),
        // ✅ عرض المجلدات الفرعية
        if (hasChildren)
          ...children.map((child) {
            return _buildFolderTreeItem(context, child, level + 1, onSelect);
          }).toList(),
      ],
    );
  }

  // ✅ دالة لنقل المجلد
  Future<void> _moveFolder(
    BuildContext context,
    String folderId,
    String? targetFolderId,
    String folderName,
  ) async {
    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 16),
            Text(S.of(context).movingFolder),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    final success = await folderController.moveFolder(
      folderId: folderId,
      targetFolderId: targetFolderId,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم نقل المجلد بنجاح'),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ إعادة تحميل محتويات المجلد بعد النقل - إعادة تعيين الصفحة
        // ✅ استخدام await لضمان اكتمال التحديث
        await _loadFolderContents(resetPage: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(folderController.errorMessage ?? '❌ فشل نقل المجلد'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ✅ Widget للتنقل داخل المجلدات عند النقل
class _FolderNavigationDialog extends StatefulWidget {
  final String title;
  final String? excludeFolderId;
  final String? excludeParentId;
  final Function(String?) onSelect;

  const _FolderNavigationDialog({
    required this.title,
    this.excludeFolderId,
    this.excludeParentId,
    required this.onSelect,
  });

  @override
  State<_FolderNavigationDialog> createState() =>
      _FolderNavigationDialogState();
}

class _FolderNavigationDialogState extends State<_FolderNavigationDialog> {
  List<Map<String, dynamic>> _currentFolders = [];
  List<Map<String, String?>> _breadcrumb = []; // [{id: null, name: 'الجذر'}]
  bool _isLoading = false;
  String? _currentFolderId;

  @override
  void initState() {
    super.initState();
    _breadcrumb.add({'id': null, 'name': 'الجذر'});
    _loadRootFolders();
  }

  // ✅ جلب المجلدات الجذرية
  Future<void> _loadRootFolders() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _currentFolderId = null;
    });

    try {
      final folderController = Provider.of<FolderController>(
        context,
        listen: false,
      );
      final response = await folderController.getAllFolders(
        page: 1,
        limit: 100,
      );

      if (!mounted) return;

      if (response != null && response['folders'] != null) {
        final folders = List<Map<String, dynamic>>.from(
          response['folders'] ?? [],
        );

        // ✅ تصفية المجلدات المستبعدة
        final filteredFolders = folders.where((f) {
          final fId = f['_id']?.toString();
          return fId != widget.excludeFolderId && fId != widget.excludeParentId;
        }).toList();

        if (mounted) {
          setState(() {
            _currentFolders = filteredFolders;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _currentFolders = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading root folders: $e');
      if (mounted) {
        setState(() {
          _currentFolders = [];
          _isLoading = false;
        });
      }
    }
  }

  // ✅ جلب المجلدات الفرعية لمجلد معين
  Future<void> _loadSubfolders(String folderId, String folderName) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _currentFolderId = folderId;
    });

    // ✅ إضافة المجلد إلى breadcrumb
    if (mounted) {
      setState(() {
        _breadcrumb.add({'id': folderId, 'name': folderName});
      });
    }

    try {
      final folderController = Provider.of<FolderController>(
        context,
        listen: false,
      );

      // ✅ جلب جميع المجلدات الفرعية بدون pagination (limit كبير)
      final response = await folderController.getFolderContents(
        folderId: folderId,
        page: 1,
        limit: 1000, // ✅ limit كبير لضمان جلب جميع المجلدات
      );

      if (!mounted) return;

      print('📁 Response for folder $folderId: ${response?.keys}');
      print('📁 Full response: $response');

      // ✅ محاولة جلب المجلدات الفرعية من response
      List<Map<String, dynamic>> subfolders = [];

      if (response != null) {
        // ✅ محاولة من subfolders مباشرة (الأولوية) - هذا يحتوي على جميع المجلدات الفرعية
        if (response['subfolders'] != null) {
          subfolders = List<Map<String, dynamic>>.from(
            response['subfolders'] ?? [],
          );
          print(
            '📁 Found ${subfolders.length} subfolders from subfolders field',
          );
        }
        // ✅ إذا لم تكن موجودة، جرب من contents (لكن هذا قد يكون محدود بـ pagination)
        if (subfolders.isEmpty && response['contents'] != null) {
          final contents = List<Map<String, dynamic>>.from(
            response['contents'] ?? [],
          );
          subfolders = contents
              .where((item) => item['type'] == 'folder')
              .toList();
          print('📁 Found ${subfolders.length} subfolders from contents field');
        }

        // ✅ إذا لم نجد أي مجلدات، جرب من folders مباشرة (fallback)
        if (subfolders.isEmpty && response['folders'] != null) {
          subfolders = List<Map<String, dynamic>>.from(
            response['folders'] ?? [],
          );
          print(
            '📁 Found ${subfolders.length} subfolders from folders field (fallback)',
          );
        }
      }

      print(
        '📁 Total found: ${subfolders.length} subfolders for folder $folderId ($folderName)',
      );

      // ✅ تصفية المجلدات المستبعدة
      final filteredFolders = subfolders.where((f) {
        final fId = f['_id']?.toString();
        return fId != widget.excludeFolderId && fId != widget.excludeParentId;
      }).toList();

      if (mounted) {
        setState(() {
          _currentFolders = filteredFolders;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading subfolders: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      if (mounted) {
        setState(() {
          _currentFolders = [];
          _isLoading = false;
        });
      }

      // ✅ إظهار رسالة خطأ للمستخدم
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorFetchingSubfolders(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ العودة إلى مجلد سابق
  void _navigateToFolder(String? folderId) {
    if (!mounted) return;

    if (folderId == null) {
      // ✅ العودة للجذر
      if (mounted) {
        setState(() {
          _breadcrumb = [
            {'id': null, 'name': 'الجذر'},
          ];
        });
      }
      _loadRootFolders();
    } else {
      // ✅ العودة لمجلد معين
      final index = _breadcrumb.indexWhere((b) => b['id'] == folderId);
      if (index >= 0) {
        if (mounted) {
          setState(() {
            _breadcrumb = _breadcrumb.sublist(0, index + 1);
          });
        }

        final folderName = _breadcrumb.last['name'] ?? S.of(context).folder;
        _loadSubfolders(folderId, folderName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ✅ Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.drive_file_move_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // ✅ Breadcrumb
          if (_breadcrumb.length > 1)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _breadcrumb.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final isLast = index == _breadcrumb.length - 1;

                          return GestureDetector(
                            onTap: isLast
                                ? null
                                : () => _navigateToFolder(item['id']),
                            child: Row(
                              children: [
                                if (index > 0) ...[
                                  Icon(
                                    Icons.chevron_left,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 4),
                                ],
                                Text(
                                  item['name'] ?? 'الجذر',
                                  style: TextStyle(
                                    color: isLast ? Colors.purple : Colors.blue,
                                    fontWeight: isLast
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    decoration: isLast
                                        ? null
                                        : TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ✅ Content
          Expanded(
            child: Column(
              children: [
                // ✅ خيار "اختيار الجذر" (إذا كنا في الجذر)
                if (_currentFolderId == null)
                  ListTile(
                    leading: Icon(Icons.home_rounded, color: Colors.blue),
                    title: Text(S.of(context).moveToRoot),
                    subtitle: Text(S.of(context).moveFolderToRoot),
                    onTap: () => widget.onSelect(null),
                  ),
                // ✅ خيار "اختيار المجلد الحالي" (إذا كنا داخل مجلد)
                if (_currentFolderId != null)
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text(
                      S.of(context).selectFolder(_breadcrumb.last['name'] ?? S.of(context).folder),
                    ),
                    subtitle: Text(S.of(context).moveToThisFolder),
                    onTap: () => widget.onSelect(_currentFolderId),
                  ),
                // ✅ Divider بين الخيارات وقائمة المجلدات
                Divider(),

                // ✅ قائمة المجلدات
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _currentFolders.isEmpty
                      ? Center(
                          child: Text(
                            _currentFolderId == null
                                ? 'لا توجد مجلدات متاحة'
                                : 'لا توجد مجلدات فرعية',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _currentFolders.length,
                          itemBuilder: (context, index) {
                            final folder = _currentFolders[index];
                            final folderId = folder['_id']?.toString();
                            final folderName =
                                folder['name'] ?? S.of(context).folderWithoutName;

                            return InkWell(
                              onTap: () {
                                // ✅ فتح المجلد لعرض المجلدات الفرعية
                                if (folderId != null) {
                                  print(
                                    '📂 Opening folder: $folderId ($folderName)',
                                  );
                                  _loadSubfolders(folderId, folderName);
                                } else {
                                  print(
                                    '⚠️ Folder ID is null for folder: $folderName',
                                  );
                                }
                              },
                              child: ListTile(
                                leading: Icon(
                                  Icons.folder_rounded,
                                  color: Colors.orange,
                                ),
                                title: Text(folderName),
                                subtitle: Text(
                                  '${folder['filesCount'] ?? 0} ملف',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // ✅ زر اختيار المجلد (checkmark)
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          // ✅ اختيار المجلد مباشرة
                                          widget.onSelect(folderId);
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          child: Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.green,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    // ✅ أيقونة chevron للإشارة إلى إمكانية فتح المجلد
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
