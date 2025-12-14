import 'package:flutter/material.dart';
import 'package:filevo/constants/app_colors.dart';
import 'package:filevo/views/fileViewer/VideoViewer.dart';
import 'package:filevo/views/fileViewer/audioPlayer.dart';
import 'package:filevo/views/fileViewer/imageViewer.dart';
import 'package:filevo/views/fileViewer/office_file_opener.dart';
import 'package:filevo/views/fileViewer/pdfViewer.dart';
import 'package:filevo/views/fileViewer/textViewer.dart';
import 'package:filevo/config/api_config.dart';
import 'package:filevo/services/api_endpoints.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/services/file_search_service.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
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
          content: Text('أدخل نص البحث'),
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
            content: Text('خطأ في البحث: ${e.toString()}'),
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
        title: Text('البحث الذكي'),
        backgroundColor: isDarkMode
            ? AppColors.darkAppBar
            : AppColors.lightAppBar,
        actions: [],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'ابحث... (مثال: صور من الأسبوع الماضي)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: isDarkMode
                              ? AppColors.darkCardBackground
                              : Colors.white,
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _isSearching = false;
                                      _searchResults = [];
                                      _searchQuery = null;
                                    });
                                  },
                                )
                              : null,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
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
              // ✅ إخفاء TabBar لأننا نستخدم البحث الجديد الذي يعيد ملفات فقط
              SizedBox.shrink(),
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

  // ✅ بناء عرض نتائج البحث (بنفس طريقة عرض الملفات في التطبيق)
  Widget _buildSearchResults() {
    // ✅ إذا كان البحث قيد التحميل
    if (_isSearchLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري البحث...'),
          ],
        ),
      );
    }

    // ✅ إذا لم تكن هناك نتائج بعد البحث
    if (_searchResults.isEmpty && _searchQuery != null && !_isSearchLoading) {
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

    // ✅ إذا كانت هناك نتائج، اعرضها
    if (_searchResults.isNotEmpty && _searchQuery != null) {
      return Column(
        children: [
          // ✅ معلومات البحث
          Container(
            padding: EdgeInsets.all(16),
            color: AppColors.accent.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.search, color: AppColors.accent, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تم العثور على ${_searchResults.length} نتيجة للبحث: "$_searchQuery"',
                    style: TextStyle(color: AppColors.accent, fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                  onPressed: () {
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                  },
                  tooltip: _isGridView ? 'عرض كقائمة' : 'عرض كشبكة',
                ),
              ],
            ),
          ),
          // ✅ عرض النتائج بكارد مخصص للبحث
          Expanded(
            child: _isGridView
                ? _buildSearchResultsGrid()
                : _buildSearchResultsList(),
          ),
        ],
      );
    }

    // ✅ الحالة الافتراضية (لا يوجد بحث)
    return Center(
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
    );
  }

  // ✅ بناء Grid مخصص لنتائج البحث
  Widget _buildSearchResultsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final file = _searchResults[index];
        return _buildSearchResultCard(file);
      },
    );
  }

  // ✅ بناء List مخصص لنتائج البحث
  Widget _buildSearchResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final file = _searchResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSearchResultCard(file, isList: true),
        );
      },
    );
  }

  // ✅ بناء كارد مخصص لنتيجة البحث
  Widget _buildSearchResultCard(
    Map<String, dynamic> file, {
    bool isList = false,
  }) {
    final fileName = file['name']?.toString() ?? 'ملف بدون اسم';
    final filePath = file['path']?.toString() ?? '';
    final fileId = file['_id']?.toString() ?? file['id']?.toString();
    final fileType = _getFileType(fileName);
    final fileSize = _formatSize(file['size']);
    final createdAt = file['createdAt'];
    final category = file['category']?.toString();
    final isStarred = file['isStarred'] ?? false;

    // ✅ بناء URL
    String fileUrl;
    if (filePath.isNotEmpty) {
      fileUrl = _getFileUrl(filePath);
    } else if (fileId != null && fileId.isNotEmpty) {
      final baseUrl = ApiConfig.baseUrl.replaceAll('/api/v1', '');
      final downloadPath = ApiEndpoints.downloadFile(fileId);
      fileUrl = "$baseUrl$downloadPath";
    } else {
      fileUrl = '';
    }

    return GestureDetector(
      onTap: () {
        _handleFileTap(file, context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isList
            ? _buildListCard(
                fileName,
                fileType,
                fileUrl,
                fileSize,
                createdAt,
                category,
                isStarred,
                file,
              )
            : _buildGridCard(
                fileName,
                fileType,
                fileUrl,
                fileSize,
                createdAt,
                category,
                isStarred,
                file,
              ),
      ),
    );
  }

  // ✅ بناء كارد Grid
  Widget _buildGridCard(
    String fileName,
    String fileType,
    String fileUrl,
    String fileSize,
    dynamic createdAt,
    String? category,
    bool isStarred,
    Map<String, dynamic> file,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ منطقة المعاينة
        Expanded(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: _buildFilePreview(fileType, fileUrl, fileName),
              ),
              // ✅ زر المفضلة
              if (isStarred)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // ✅ معلومات الملف
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileName,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 11,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _formatDate(createdAt),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ بناء كارد List
  Widget _buildListCard(
    String fileName,
    String fileType,
    String fileUrl,
    String fileSize,
    dynamic createdAt,
    String? category,
    bool isStarred,
    Map<String, dynamic> file,
  ) {
    return Row(
      children: [
        // ✅ المعاينة
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildFilePreview(fileType, fileUrl, fileName),
          ),
        ),
        const SizedBox(width: 12),
        // ✅ المعلومات
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      fileName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  if (isStarred)
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.insert_drive_file,
                    size: 12,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    fileSize,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ بناء معاينة الملف
  Widget _buildFilePreview(String fileType, String fileUrl, String fileName) {
    switch (fileType.toLowerCase()) {
      case 'image':
        if (fileUrl.isNotEmpty) {
          // ✅ إضافة token للصور إذا كانت من API
          final needsToken = fileUrl.contains('/api/');
          return FutureBuilder<Map<String, String>?>(
            future: needsToken ? _getImageHeaders() : Future.value(null),
            builder: (context, snapshot) {
              return CachedNetworkImage(
                imageUrl: fileUrl,
                fit: BoxFit.cover,
                httpHeaders: snapshot.data,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[400],
                    size: 32,
                  ),
                ),
              );
            },
          );
        }
        return _buildFileIcon(Icons.image, Colors.blue);
      case 'pdf':
        return _buildFileIcon(Icons.picture_as_pdf, Colors.red);
      case 'video':
        return _buildFileIcon(Icons.video_library, Colors.purple);
      case 'audio':
        return _buildFileIcon(Icons.audiotrack, Colors.orange);
      default:
        return _buildFileIcon(Icons.insert_drive_file, Colors.grey);
    }
  }

  // ✅ بناء أيقونة الملف
  Widget _buildFileIcon(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 32, color: color),
        ),
      ),
    );
  }

  // ✅ الحصول على نوع الملف
  String _getFileType(String fileName) {
    final name = fileName.toLowerCase();
    if (name.endsWith('.pdf')) return 'pdf';
    if (name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.gif'))
      return 'image';
    if (name.endsWith('.mp4') || name.endsWith('.mov') || name.endsWith('.mkv'))
      return 'video';
    if (name.endsWith('.mp3') || name.endsWith('.wav') || name.endsWith('.m4a'))
      return 'audio';
    return 'file';
  }

  String _formatSize(dynamic size) {
    if (size == null) return '—';
    try {
      final bytes = size is int ? size : int.tryParse(size.toString()) ?? 0;
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      if (bytes < 1073741824)
        return '${(bytes / 1048576).toStringAsFixed(1)} MB';
      return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    } catch (e) {
      return '—';
    }
  }

  // ✅ جلب headers للصور (مع token)
  Future<Map<String, String>?> _getImageHeaders() async {
    final token = await StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      return {'Authorization': 'Bearer $token'};
    }
    return null;
  }

  // ✅ تنسيق التاريخ
  String _formatDate(dynamic date) {
    if (date == null) return '—';
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return '—';
    }
  }

  // ✅ بناء URL الملف
  String _getFileUrl(String path) {
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

  // ✅ عرض loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
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
      url = _getFileUrl(filePath);

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
          content: const Text('رابط الملف غير متوفر - لا يوجد path أو _id'),
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
          content: const Text('رابط غير صالح'),
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

    _showLoadingDialog(context);

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
              content: const Text('يجب تسجيل الدخول أولاً'),
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
          _showLoadingDialog(context);
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
                  content: Text('خطأ في تحميل الملف النصي: ${e.toString()}'),
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
            content: Text('الملف غير متاح (خطأ ${response.statusCode})'),
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
            content: Text('خطأ في تحميل الملف: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
