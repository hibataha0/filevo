import 'package:flutter/material.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:filevo/constants/app_colors.dart';
import 'package:filevo/components/search_results_widget.dart';
import 'package:filevo/services/file_search_service.dart';
import 'package:filevo/config/api_config.dart';
import 'package:filevo/services/api_endpoints.dart';
import 'package:filevo/views/fileViewer/VideoViewer.dart';
import 'package:filevo/views/fileViewer/audioPlayer.dart';
import 'package:filevo/views/fileViewer/imageViewer.dart';
import 'package:filevo/views/fileViewer/office_file_opener.dart';
import 'package:filevo/views/fileViewer/pdfViewer.dart';
import 'package:filevo/views/fileViewer/textViewer.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SmartSearchPage extends StatefulWidget {
  const SmartSearchPage({super.key});

  @override
  State<SmartSearchPage> createState() => _SmartSearchPageState();
}

class _SmartSearchPageState extends State<SmartSearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _selectedScope = 'all';

  // ✅ استخدام البحث الجديد
  final FileSearchService _fileSearchService = FileSearchService();
  bool _isSearching = false;
  bool _isSearchLoading = false;
  List<Map<String, dynamic>> _searchResults = [];
  String? _searchQuery;
  bool _isGridView = true; // ✅ toggle للتبديل بين Grid و List

  // ✅ ميزة البحث بالصوت (Speech to Text)
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _searchText = ''; // النص المعرّف من الصوت

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeSpeech();
  }

  /// تهيئة خدمة تحويل الصوت إلى نص
  Future<void> _initializeSpeech() async {
    try {
      await _speech.initialize(
        onStatus: (status) {
          if (mounted) {
            setState(() {
              _isListening = status == 'listening';
            });
          }
        },
        onError: (error) {
          if (mounted) {
            print('❌ خطأ في التعرف على الصوت: ${error.errorMsg}');
            setState(() {
              _isListening = false;
            });
          }
        },
      );
    } catch (e) {
      print('❌ خطأ في تهيئة خدمة الصوت: $e');
    }
  }

  /// بدء الاستماع للصوت
  Future<void> _startListening() async {
    // ✅ التحقق من حالة الإذن أولاً
    PermissionStatus status = await Permission.microphone.status;
    
    // ✅ إذا كان الإذن مرفوض بشكل دائم، نفتح الإعدادات
    if (status.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(S.of(context).microphonePermissionRequired),
            content: const Text(
              'يجب السماح بالوصول إلى الميكروفون للبحث بالصوت.\n\n'
              'افتح إعدادات التطبيق وسمح بالوصول إلى الميكروفون.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings(); // ✅ فتح إعدادات التطبيق
                },
                child: Text(S.of(context).openSettings),
              ),
            ],
          ),
        );
      }
      return;
    }
    
    // ✅ إذا لم يكن الإذن ممنوحاً، نطلب الإذن مباشرة
    if (!status.isGranted) {
      // ✅ طلب إذن الميكروفون - سيظهر نافذة النظام تلقائياً
      status = await Permission.microphone.request();
      
      // ✅ إعادة التحقق من حالة الإذن بعد الطلب
      // ✅ ننتظر قليلاً للتأكد من تحديث الحالة
      await Future.delayed(const Duration(milliseconds: 100));
      status = await Permission.microphone.status;
      
      // ✅ إذا رفض المستخدم الإذن
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).permissionDenied),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    }
    
    // ✅ التأكد مرة أخرى من أن الإذن ممنوح قبل المتابعة
    final finalStatus = await Permission.microphone.status;
    if (!finalStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).mustAllowMicrophoneAccess),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // ✅ التحقق من توفر الخدمة
    bool available = await _speech.initialize();
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).speechRecognitionNotAvailable),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // ✅ بدء الاستماع
    _speech.listen(
      localeId: "ar", // ✅ اللغة العربية
      onResult: (result) {
        if (mounted) {
          setState(() {
            _searchText = result.recognizedWords;
            // ✅ تحديث حقل البحث مباشرة
            if (_searchText.isNotEmpty) {
              _searchController.text = _searchText;
            }
          });

          // ✅ إذا انتهى التعرف (final result)، نبحث تلقائياً
          if (result.finalResult && _searchText.isNotEmpty) {
            print('✅ النص المعرّف: $_searchText');
            _stopListening();
            // ✅ البحث تلقائياً بعد التعرف على الصوت
            _performSearch();
          }
        }
      },
    );

    setState(() {
      _isListening = true;
      _searchText = '';
    });
  }

  /// إيقاف الاستماع للصوت
  Future<void> _stopListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    print('🔍 [SmartSearch] ===== SEARCH STARTED =====');
    print('🔍 [SmartSearch] Query: $query');

    if (query.isEmpty) {
      print('🔍 [SmartSearch] ERROR: Empty query');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).enterSearchText),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _isSearchLoading = true;
      _searchQuery = query;
    });

    try {
      print('🔍 [SmartSearch] Calling FileSearchService.smartSearch...');
      // ✅ استخدام البحث الجديد
      final result = await _fileSearchService.smartSearch(
        query: query,
        limit: 50,
      );

      print('🔍 [SmartSearch] Search result received');
      print('🔍 [SmartSearch] Result success: ${result['success']}');
      print('🔍 [SmartSearch] Result keys: ${result.keys.toList()}');

      if (!mounted) return;

      if (result['success'] == true) {
        final results = List<Map<String, dynamic>>.from(
          result['results'] ?? [],
        );

        print('🔍 [SmartSearch] Results count: ${results.length}');
        if (results.isNotEmpty) {
          print(
            '🔍 [SmartSearch] First result keys: ${results[0].keys.toList()}',
          );
          print('🔍 [SmartSearch] First result: ${results[0]}');
        }

        setState(() {
          _searchResults = results.map<Map<String, dynamic>>((r) {
            // ✅ البيانات تأتي مباشرة بدون wrapper 'item'
            // الباك إند يرسل: { _id, name, path, category, ... }
            final file = Map<String, dynamic>.from(r);

            // ✅ التأكد من وجود _id و name
            if (file['_id'] == null && file['id'] != null) {
              file['_id'] = file['id'];
            }

            print('🔍 [SmartSearch] Processed file: ${file['name']}');
            print('🔍 [SmartSearch]   - _id: ${file['_id']}');
            print('🔍 [SmartSearch]   - path: ${file['path']}');
            print('🔍 [SmartSearch]   - keys: ${file.keys.toList()}');

            return file;
          }).toList();
          _isSearchLoading = false;
        });

        print(
          '🔍 [SmartSearch] Total results processed: ${_searchResults.length}',
        );

        print('🔍 [SmartSearch] Processed ${_searchResults.length} files');
        if (_searchResults.isNotEmpty) {
          print(
            '🔍 [SmartSearch] First processed file keys: ${_searchResults[0].keys.toList()}',
          );
          print(
            '🔍 [SmartSearch] First processed file _id: ${_searchResults[0]['_id']}',
          );
          print(
            '🔍 [SmartSearch] First processed file path: ${_searchResults[0]['path']}',
          );
        }
      } else {
        setState(() {
          _searchResults = [];
          _isSearchLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'فشل البحث'),
              backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).smartSearch),
        backgroundColor: isDarkMode
            ? AppColors.darkAppBar
            : AppColors.lightAppBar,
        actions: [],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(160),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: _isListening
                              ? 'جاري الاستماع...'
                              : 'ابحث... (مثال: صور من الأسبوع الماضي)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: isDarkMode
                              ? AppColors.darkCardBackground
                              : Colors.white,
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: _buildSuffixIcons(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                        onSubmitted: (_) => _performSearch(),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: _performSearch,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
              // Scope selector
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 8.0,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildScopeChip('all', 'الكل', Icons.search),
                      SizedBox(width: 8),
                      _buildScopeChip('my-files', 'ملفاتي', Icons.folder),
                      SizedBox(width: 8),
                      _buildScopeChip('shared', 'مشتركة', Icons.share),
                      SizedBox(width: 8),
                      _buildScopeChip('rooms', 'الرومات', Icons.meeting_room),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isSearching || (_searchResults.isNotEmpty && _searchQuery != null)
          ? _buildSearchResults()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'ابحث في ملفاتك',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'مثال: "ملفات المشروع"',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
    );
  }

  /// بناء أيقونات suffix (الميكروفون ومسح النص)
  Widget? _buildSuffixIcons() {
    final hasText = _searchController.text.isNotEmpty;
    
    // ✅ إذا كان هناك نص وليس في حالة استماع، نعرض كلا الأيقونتين
    if (hasText && !_isListening) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ زر الميكروفون
          IconButton(
            icon: Icon(Icons.mic_none),
            onPressed: _startListening,
            tooltip: 'البحث بالصوت',
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
          // ✅ زر مسح النص
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _isSearching = false;
                _searchResults = [];
                _searchQuery = null;
              });
            },
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      );
    }
    
    // ✅ إذا كان في حالة استماع، نعرض فقط أيقونة الميكروفون الحمراء
    if (_isListening) {
      return IconButton(
        icon: Icon(Icons.mic, color: Colors.red),
        onPressed: _stopListening,
        tooltip: 'إيقاف التسجيل',
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(),
      );
    }
    
    // ✅ إذا لم يكن هناك نص، نعرض فقط أيقونة الميكروفون
    return IconButton(
      icon: Icon(Icons.mic_none),
      onPressed: _startListening,
      tooltip: 'البحث بالصوت',
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
    );
  }

  Widget _buildScopeChip(String value, String label, IconData icon) {
    final isSelected = _selectedScope == value;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), SizedBox(width: 4), Text(label)],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedScope = value;
        });
      },
      backgroundColor: isDarkMode
          ? AppColors.darkCardBackground
          : Colors.grey[200],
      selectedColor: AppColors.accent,
      labelStyle: TextStyle(color: isSelected ? Colors.white : null),
    );
  }

  // ✅ بناء عرض نتائج البحث باستخدام SearchResultsWidget المشترك
  Widget _buildSearchResults() {
    return SearchResultsWidget(
      results: _searchResults,
      searchQuery: _searchQuery,
      isLoading: _isSearchLoading,
      isGridView: _isGridView,
      onViewToggle: (isGrid) {
        setState(() {
          _isGridView = isGrid;
        });
      },
      onFileTap: (file) {
        _handleFileTap(file, context);
      },
    );
  }

  // ✅ فتح الملف من نتائج البحث
  Future<void> _handleFileTap(
    Map<String, dynamic> file,
    BuildContext context,
  ) async {
    print('═══════════════════════════════════════════════════════');
    print('🔍 [SmartSearch] ===== START OPENING FILE =====');
    print('🔍 [SmartSearch] File name: ${file['name']}');
    print('🔍 [SmartSearch] File data keys: ${file.keys.toList()}');
    print('🔍 [SmartSearch] Full file data: $file');
    print('🔍 [SmartSearch] Full file data (JSON): ${file.toString()}');
    print('───────────────────────────────────────────────────────');

    // ✅ استخراج path و _id مباشرة من البيانات
    String? filePath = file['path'] as String?;
    String? fileId = file['_id']?.toString() ?? file['id']?.toString();

    print('🔍 [SmartSearch] Step 1: Extract path and _id');
    print('🔍 [SmartSearch]   - filePath (raw): ${file['path']}');
    print('🔍 [SmartSearch]   - filePath (after cast): $filePath');
    print(
      '🔍 [SmartSearch]   - filePath isEmpty: ${filePath?.isEmpty ?? true}',
    );
    print('🔍 [SmartSearch]   - file _id (raw): ${file['_id']}');
    print('🔍 [SmartSearch]   - file id (raw): ${file['id']}');
    print('🔍 [SmartSearch]   - fileId (final): $fileId');
    print('🔍 [SmartSearch]   - fileId isEmpty: ${fileId?.isEmpty ?? true}');
    print('───────────────────────────────────────────────────────');

    // ✅ إذا لم يكن path موجوداً، استخدم endpoint download
    String url;
    String urlSource = '';

    if ((filePath == null || filePath.isEmpty) &&
        (fileId != null && fileId.isNotEmpty)) {
      // ✅ استخدام endpoint download
      urlSource = 'download_endpoint';
      final baseUrl = ApiConfig.baseUrl.replaceAll('/api/v1', '');
      final downloadPath = ApiEndpoints.downloadFile(fileId);
      url = "$baseUrl$downloadPath";

      print('🔍 [SmartSearch] Step 2: Build URL');
      print('🔍 [SmartSearch]   - Source: $urlSource');
      print('🔍 [SmartSearch]   - Base URL: $baseUrl');
      print('🔍 [SmartSearch]   - Download path: $downloadPath');
      print('🔍 [SmartSearch]   - Final URL: $url');
    } else if (filePath != null && filePath.isNotEmpty) {
      urlSource = 'file_path';
      url = _getFileUrlFromPath(filePath);

      print('🔍 [SmartSearch] Step 2: Build URL');
      print('🔍 [SmartSearch]   - Source: $urlSource');
      print('🔍 [SmartSearch]   - File path: $filePath');
      print('🔍 [SmartSearch]   - Final URL: $url');
    } else {
      print('🔍 [SmartSearch] Step 2: ERROR - No path or _id');
      print(
        '🔍 [SmartSearch]   - filePath is null/empty: ${filePath == null || filePath.isEmpty}',
      );
      print(
        '🔍 [SmartSearch]   - fileId is null/empty: ${fileId == null || fileId.isEmpty}',
      );
      print('═══════════════════════════════════════════════════════');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).fileLinkNotAvailableNoPath),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print('───────────────────────────────────────────────────────');
    print('🔍 [SmartSearch] Step 3: Validate URL');
    final isValidUrl = _isValidUrl(url);
    print('🔍 [SmartSearch]   - URL is valid: $isValidUrl');
    print('🔍 [SmartSearch]   - URL: $url');
    print('───────────────────────────────────────────────────────');

    if (!isValidUrl) {
      print('🔍 [SmartSearch] ERROR: Invalid URL');
      print('═══════════════════════════════════════════════════════');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).invalidUrl),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final fileName = file['name']?.toString() ?? 'ملف بدون اسم';
    final name = fileName.toLowerCase();

    print('🔍 [SmartSearch] Step 4: Get file info');
    print('🔍 [SmartSearch]   - File name: $fileName');
    print('🔍 [SmartSearch]   - File name (lowercase): $name');
    print('───────────────────────────────────────────────────────');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      // ✅ الحصول على token
      print('🔍 [SmartSearch] Step 5: Get token');
      final token = await StorageService.getToken();
      if (token == null) {
        print('🔍 [SmartSearch] ERROR: Token is null');
        print('═══════════════════════════════════════════════════════');
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).mustLoginFirst),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      print('🔍 [SmartSearch]   - Token exists: ${token.isNotEmpty}');
      print('🔍 [SmartSearch]   - Token length: ${token.length}');
      print('───────────────────────────────────────────────────────');

      // ✅ التحقق من أن الملف موجود
      print('🔍 [SmartSearch] Step 6: Request file');
      print('🔍 [SmartSearch]   - Request URL: $url');
      print(
        '🔍 [SmartSearch]   - Request headers: Authorization: Bearer ${token.substring(0, 20)}...',
      );

      final client = http.Client();
      final response = await client.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Range': 'bytes=0-511'},
      );

      print('🔍 [SmartSearch] Step 7: Response received');
      print('🔍 [SmartSearch]   - Status code: ${response.statusCode}');
      print('🔍 [SmartSearch]   - Response headers: ${response.headers}');
      print(
        '🔍 [SmartSearch]   - Content length: ${response.bodyBytes.length}',
      );
      print('───────────────────────────────────────────────────────');

      if (!mounted) {
        print('🔍 [SmartSearch] ERROR: Widget not mounted');
        print('═══════════════════════════════════════════════════════');
        return;
      }
      Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 206) {
        print('🔍 [SmartSearch] Step 8: File request successful');
        final bytes = response.bodyBytes;
        final isPdf = _isValidPdf(bytes);
        final contentType =
            response.headers['content-type']?.toLowerCase() ?? '';

        print('🔍 [SmartSearch]   - Bytes received: ${bytes.length}');
        print('🔍 [SmartSearch]   - Is PDF: $isPdf');
        print('🔍 [SmartSearch]   - Content type: $contentType');
        print('───────────────────────────────────────────────────────');

        // ✅ التحقق من نوع الملف
        bool isImageFile() {
          return name.endsWith('.jpg') ||
              name.endsWith('.jpeg') ||
              name.endsWith('.png') ||
              name.endsWith('.gif') ||
              name.endsWith('.bmp') ||
              name.endsWith('.webp') ||
              contentType.startsWith('image/');
        }

        bool isVideoFile() {
          return name.endsWith('.mp4') ||
              name.endsWith('.mov') ||
              name.endsWith('.mkv') ||
              name.endsWith('.avi') ||
              name.endsWith('.wmv') ||
              contentType.startsWith('video/');
        }

        bool isAudioFile() {
          return name.endsWith('.mp3') ||
              name.endsWith('.wav') ||
              name.endsWith('.m4a') ||
              name.endsWith('.aac') ||
              contentType.startsWith('audio/');
        }

        // ✅ فتح الملف حسب نوعه
        print('🔍 [SmartSearch] Step 9: Determine file type and open');
        if (name.endsWith('.pdf') && isPdf) {
          print('🔍 [SmartSearch]   - Opening as PDF');
          print('🔍 [SmartSearch]   - PDF URL: $url');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PdfViewerPage(pdfUrl: url, fileName: fileName),
            ),
          );
        } else if (isVideoFile()) {
          print('🔍 [SmartSearch]   - Opening as Video');
          print('🔍 [SmartSearch]   - Video URL: $url');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VideoViewer(url: url)),
          );
        } else if (isImageFile()) {
          print('🔍 [SmartSearch]   - Opening as Image');
          print('🔍 [SmartSearch]   - Image URL: $url');
          print('🔍 [SmartSearch]   - File ID: $fileId');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageViewer(imageUrl: url, fileId: fileId ?? ''),
            ),
          );
        } else if (TextViewerPage.isTextFile(fileName) ||
            contentType.startsWith('text/')) {
          print('🔍 [SmartSearch]   - Opening as Text file');
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(child: CircularProgressIndicator()),
          );
          try {
            print('🔍 [SmartSearch]   - Downloading full text file...');
            final fullResponse = await http.get(
              Uri.parse(url),
              headers: {'Authorization': 'Bearer $token'},
            );
            print(
              '🔍 [SmartSearch]   - Full response status: ${fullResponse.statusCode}',
            );
            if (!mounted) return;
            Navigator.pop(context);
            if (fullResponse.statusCode == 200) {
              final tempDir = await getTemporaryDirectory();
              final tempFile = File('${tempDir.path}/$fileName');
              await tempFile.writeAsBytes(fullResponse.bodyBytes);
              print(
                '🔍 [SmartSearch]   - Text file saved to: ${tempFile.path}',
              );
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
            print('🔍 [SmartSearch] ERROR in text file download: $e');
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context).errorLoadingTextFile(e.toString())),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else if (isAudioFile()) {
          print('🔍 [SmartSearch]   - Opening as Audio');
          print('🔍 [SmartSearch]   - Audio URL: $url');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AudioPlayerPage(audioUrl: url, fileName: fileName),
            ),
          );
        } else {
          // ✅ باقي الملفات (Office، مضغوطة، تطبيقات، وغيرها)
          print('🔍 [SmartSearch]   - Opening with OfficeFileOpener');
          print('🔍 [SmartSearch]   - File URL: $url');
          await OfficeFileOpener.openAnyFile(
            url: url,
            context: context,
            token: token,
          );
        }
        print('═══════════════════════════════════════════════════════');
        print('🔍 [SmartSearch] ===== FILE OPENED SUCCESSFULLY =====');
        print('═══════════════════════════════════════════════════════');
      } else {
        print('🔍 [SmartSearch] ERROR: File request failed');
        print('🔍 [SmartSearch]   - Status code: ${response.statusCode}');
        print('🔍 [SmartSearch]   - Response body: ${response.body}');
        print('═══════════════════════════════════════════════════════');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).fileNotAvailableError(response.statusCode)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('🔍 [SmartSearch] ERROR: Exception occurred');
      print('🔍 [SmartSearch]   - Error: $e');
      print('🔍 [SmartSearch]   - Stack trace: $stackTrace');
      print('═══════════════════════════════════════════════════════');
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

  // ✅ بناء URL الملف من path
  String _getFileUrlFromPath(String path) {
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
}
