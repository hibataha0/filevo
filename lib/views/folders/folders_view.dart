import 'package:filevo/views/folders/CategoryFiles.dart';
import 'package:filevo/views/folders/folder_contents_page.dart';
import 'package:flutter/material.dart';
import 'package:filevo/components/FilesGridView.dart';
import 'package:filevo/components/FilesListView.dart';
import 'package:filevo/components/ViewToggleButtons.dart';
import 'package:filevo/responsive.dart';
import 'package:filevo/views/folders/components/filter_section.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:filevo/views/folders/create_share_page.dart';
import 'package:filevo/views/folders/room_details_page.dart';
import 'package:filevo/utils/room_permissions.dart';
import 'package:filevo/views/folders/pending_invitations_page.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/services/file_search_service.dart';
import 'package:filevo/services/api_endpoints.dart';
import 'package:filevo/views/fileViewer/VideoViewer.dart';
import 'package:filevo/views/fileViewer/audioPlayer.dart';
import 'package:filevo/views/fileViewer/imageViewer.dart';
import 'package:filevo/views/fileViewer/office_file_opener.dart';
import 'package:filevo/views/fileViewer/pdfViewer.dart';
import 'package:filevo/views/fileViewer/textViewer.dart';
import 'package:filevo/config/api_config.dart';
import 'package:filevo/constants/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FoldersPage extends StatefulWidget {
  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilterOptions = false;
  String _selectedTimeFilter = 'All';
  bool isFilesGridView = true;
  List<String> _selectedTypes = [];
  bool isFoldersGridView = true;
  bool isFoldersListView = true;
  String _viewMode = 'all'; // 'all' or 'shared'

  // نقل قائمة المجلدات لتكون جزء من الـ State
  List<Map<String, dynamic>> folders = [];
  List<Map<String, dynamic>> sharedFolders = []; // ✅ المجلدات المشتركة معي
  bool _isLoadingFolders = false;
  bool _isLoadingSharedFolders = false;
  Map<String, Map<String, dynamic>> _previousCategoriesStats =
      {}; // ✅ لتتبع تغييرات إحصائيات التصنيفات

  // ✅ البحث المحلي
  List<Map<String, dynamic>> _filteredFolders = [];
  List<Map<String, dynamic>> _filteredSharedFolders = [];

  // ✅ البحث الذكي للملفات
  final FileSearchService _searchService = FileSearchService();
  bool _isSearching = false;
  bool _isSearchLoading = false;
  List<Map<String, dynamic>> _searchResults = [];
  String? _searchQuery;
  bool _isSearchGridView =
      true; // ✅ toggle للتبديل بين Grid و List في نتائج البحث

  @override
  void initState() {
    super.initState();

    // ✅ تحميل التصنيفات والمجلدات بعد اكتمال البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategoriesAndFolders();
    });

    // ✅ تحميل الغرف عند بدء الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomController = Provider.of<RoomController>(
        context,
        listen: false,
      );
      roomController.getRooms();
    });

    // ✅ تحميل المجلدات المشتركة عند بدء الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSharedFolders();
    });

    // ✅ إضافة listener للبحث الذكي
    _searchController.addListener(_onSearchChanged);
  }

  // ✅ معالجة تغيير نص البحث (ذكي للملفات)
  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
        _searchQuery = null;
        _filteredFolders = folders;
        _filteredSharedFolders = sharedFolders;
      });
    } else {
      // ✅ البحث الذكي بعد تأخير قصير (debounce)
      Future.delayed(Duration(milliseconds: 500), () {
        if (_searchController.text.trim() == query && query.isNotEmpty) {
          _performSmartSearch(query);
        }
      });
    }
  }

  // ✅ تنفيذ البحث الذكي للملفات
  Future<void> _performSmartSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
        _searchQuery = null;
        _filteredFolders = folders;
        _filteredSharedFolders = sharedFolders;
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

        setState(() {
          _searchResults = results.map<Map<String, dynamic>>((r) {
            // ✅ البيانات تأتي مباشرة بدون wrapper 'item'
            final file = Map<String, dynamic>.from(r);

            // ✅ التأكد من وجود _id و name
            if (file['_id'] == null && file['id'] != null) {
              file['_id'] = file['id'];
            }

            return file;
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
            content: Text('خطأ في البحث: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ تحميل التصنيفات والمجلدات من الباك
  Future<void> _loadCategoriesAndFolders() async {
    if (!mounted) return;

    setState(() {
      _isLoadingFolders = true;
    });

    // ✅ التصنيفات (categories) - قاعدة البيانات
    final categoriesBase = [
      {
        "category": "images",
        "title": S.current.images,
        "fileCount": 0,
        "size": "0 B",
        "icon": Icons.image,
        "color": Colors.blue,
        "type": "category",
        "folderData": {"type": "category"},
      },
      {
        "category": "videos",
        "title": S.current.videos,
        "fileCount": 0,
        "size": "0 B",
        "icon": Icons.videocam,
        "color": Colors.red,
        "type": "category",
        "folderData": {"type": "category"},
      },
      {
        "category": "audio",
        "title": S.current.audio,
        "fileCount": 0,
        "size": "0 B",
        "icon": Icons.audiotrack,
        "color": Colors.green,
        "type": "category",
        "folderData": {"type": "category"},
      },
      {
        "category": "compressed",
        "title": S.current.compressed,
        "fileCount": 0,
        "size": "0 B",
        "icon": Icons.folder_zip,
        "color": Colors.orange,
        "type": "category",
        "folderData": {"type": "category"},
      },
      {
        "category": "applications",
        "title": S.current.applications,
        "fileCount": 0,
        "size": "0 B",
        "icon": Icons.apps,
        "color": Colors.purple,
        "type": "category",
        "folderData": {"type": "category"},
      },
      {
        "category": "documents",
        "title": S.current.documents,
        "fileCount": 0,
        "size": "0 B",
        "icon": Icons.description,
        "color": Colors.brown,
        "type": "category",
        "folderData": {"type": "category"},
      },
      {
        "category": "code",
        "title": S.current.code,
        "fileCount": 0,
        "size": "0 B",
        "icon": Icons.code,
        "color": Colors.teal,
        "type": "category",
        "folderData": {"type": "category"},
      },
      {
        "category": "other",
        "title": S.current.other,
        "fileCount": 0,
        "size": "0 B",
        "icon": Icons.more_horiz,
        "color": Colors.grey,
        "type": "category",
        "folderData": {"type": "category"},
      },
    ];

    // ✅ جلب إحصائيات التصنيفات من الباك (الجذر فقط)
    // ✅ الآن يتم حفظ القيم في Controller مباشرة
    try {
      final fileController = Provider.of<FileController>(
        context,
        listen: false,
      );
      final token = await StorageService.getToken();

      if (token != null) {
        // ✅ جلب الإحصائيات للجذر فقط - سيتم حفظها في Controller تلقائياً
        await fileController.getRootCategoriesStats(token: token);
      }
    } catch (e) {
      // ✅ في حالة الخطأ، نستخدم القيم الافتراضية (0) بهدوء
      print('⚠️ Error loading root categories stats: $e');
    }

    // ✅ جلب المجلدات من الباك
    try {
      final folderController = Provider.of<FolderController>(
        context,
        listen: false,
      );
      final result = await folderController.getAllFolders(page: 1, limit: 100);

      List<Map<String, dynamic>> userFolders = [];

      if (result != null && result['folders'] != null) {
        final foldersList = result['folders'] as List;
        userFolders = foldersList.map((folder) {
          final folderData = folder as Map<String, dynamic>;

          // ✅ التحويل الصحيح للحجم وعدد الملفات
          dynamic sizeValue = folderData['size'];
          dynamic filesCountValue = folderData['filesCount'];

          // ✅ تحويل إلى int إذا كان String أو num
          int size = 0;
          int filesCount = 0;

          if (sizeValue != null) {
            if (sizeValue is int) {
              size = sizeValue;
            } else if (sizeValue is num) {
              size = sizeValue.toInt();
            } else if (sizeValue is String) {
              size = int.tryParse(sizeValue) ?? 0;
            }
          }

          if (filesCountValue != null) {
            if (filesCountValue is int) {
              filesCount = filesCountValue;
            } else if (filesCountValue is num) {
              filesCount = filesCountValue.toInt();
            } else if (filesCountValue is String) {
              filesCount = int.tryParse(filesCountValue) ?? 0;
            }
          }

          // ✅ Log للتحقق من القيم
          print(
            '📁 Folder: ${folderData['name']} - Size: $size bytes, Files: $filesCount',
          );
          print('   Raw size: $sizeValue, Raw filesCount: $filesCountValue');

          return {
            "title": folderData['name'] ?? 'بدون اسم',
            "fileCount": filesCount,
            "size": _formatBytes(size),
            "icon": Icons.folder,
            "color": Color(0xff28336f), // ✅ لون مختلف للمجلدات
            "type": "folder", // ✅ للتمييز
            "folderId": folderData['_id'], // ✅ ID المجلد
            "folderData": folderData, // ✅ بيانات المجلد الكاملة
          };
        }).toList();
      }

      if (!mounted) return;

      // ✅ الحصول على إحصائيات التصنيفات من Controller
      final fileController = Provider.of<FileController>(
        context,
        listen: false,
      );
      final categoriesStats = fileController.categoriesStats;

      // ✅ تحديث _previousCategoriesStats عند التحميل الأول
      if (_previousCategoriesStats.isEmpty) {
        _previousCategoriesStats = Map<String, Map<String, dynamic>>.from(
          categoriesStats,
        );
      }

      // ✅ تحديث التصنيفات بالقيم من Controller
      final updatedCategories = categoriesBase.map((category) {
        final categoryName = (category['category'] as String).toLowerCase();
        final stats = categoriesStats[categoryName];

        if (stats != null) {
          return {
            ...category,
            'fileCount': stats['filesCount'] ?? 0,
            'size': _formatBytes(stats['totalSize'] ?? 0),
          };
        }
        return category; // ✅ القيم الافتراضية (0)
      }).toList();

      // ✅ دمج التصنيفات المحدثة والمجلدات
      if (mounted) {
        setState(() {
          folders = [...updatedCategories, ...userFolders];
          _filteredFolders = folders; // ✅ تهيئة القائمة المفلترة
          _isLoadingFolders = false;
        });
      }
    } catch (e) {
      print('❌ Error loading folders: $e');

      if (!mounted) return;

      // ✅ في حالة الخطأ، نعرض التصنيفات فقط (مع القيم من Controller إن وجدت)
      final fileController = Provider.of<FileController>(
        context,
        listen: false,
      );
      final categoriesStats = fileController.categoriesStats;

      final updatedCategories = categoriesBase.map((category) {
        final categoryName = (category['category'] as String).toLowerCase();
        final stats = categoriesStats[categoryName];

        if (stats != null) {
          return {
            ...category,
            'fileCount': stats['filesCount'] ?? 0,
            'size': _formatBytes(stats['totalSize'] ?? 0),
          };
        }
        return category;
      }).toList();

      if (mounted) {
        setState(() {
          folders = updatedCategories;
          _filteredFolders = folders; // ✅ تهيئة القائمة المفلترة
          _isLoadingFolders = false;
        });
      }
    }
  }

  // ✅ تحميل المجلدات المشتركة معي
  Future<void> _loadSharedFolders() async {
    if (!mounted) return;

    setState(() {
      _isLoadingSharedFolders = true;
    });

    try {
      final folderController = Provider.of<FolderController>(
        context,
        listen: false,
      );
      final result = await folderController.getFoldersSharedWithMe(
        page: 1,
        limit: 100,
      );

      if (!mounted) return;

      List<Map<String, dynamic>> sharedFoldersList = [];

      if (result != null && result['folders'] != null) {
        final foldersList = result['folders'] as List;
        sharedFoldersList = foldersList.map((folder) {
          final folderData = folder as Map<String, dynamic>;
          final size = folderData['size'] ?? 0;
          final filesCount = folderData['filesCount'] ?? 0;
          final owner = folderData['userId'] as Map<String, dynamic>?;
          final ownerName = owner?['name'] ?? owner?['email'] ?? 'مستخدم';

          return {
            "title": folderData['name'] ?? 'بدون اسم',
            "fileCount": filesCount,
            "size": _formatBytes(size),
            "icon": Icons.folder_shared,
            "color": Colors.orange, // ✅ لون مختلف للمجلدات المشتركة
            "type": "folder", // ✅ للتمييز
            "folderId": folderData['_id'], // ✅ ID المجلد
            "folderData": folderData, // ✅ بيانات المجلد الكاملة
            "owner": ownerName, // ✅ اسم المالك
            "myPermission": folderData['myPermission'] ?? 'view', // ✅ صلاحياتي
          };
        }).toList();
      }

      if (!mounted) return;

      if (mounted) {
        setState(() {
          sharedFolders = sharedFoldersList;
          _filteredSharedFolders = sharedFolders; // ✅ تهيئة القائمة المفلترة
          _isLoadingSharedFolders = false;
        });
      }
    } catch (e) {
      print('❌ Error loading shared folders: $e');

      if (!mounted) return;

      if (mounted) {
        setState(() {
          sharedFolders = [];
          _filteredSharedFolders = []; // ✅ تهيئة القائمة المفلترة
          _isLoadingSharedFolders = false;
        });
      }
    }
  }

  // ✅ بناء عرض نتائج البحث الذكي (باستخدام نفس الكاردات من smart_search_page.dart)
  Widget _buildSmartSearchResults() {
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
                  'تم العثور على ${_searchResults.length} نتيجة للبحث الذكي: "$_searchQuery"',
                  style: TextStyle(color: AppColors.accent, fontSize: 14),
                ),
              ),
              IconButton(
                icon: Icon(_isSearchGridView ? Icons.list : Icons.grid_view),
                onPressed: () {
                  setState(() {
                    _isSearchGridView = !_isSearchGridView;
                  });
                },
                tooltip: _isSearchGridView ? 'عرض كقائمة' : 'عرض كشبكة',
              ),
            ],
          ),
        ),
        // ✅ عرض النتائج بكارد مخصص للبحث
        Expanded(
          child: _isSearchGridView
              ? _buildSearchResultsGrid()
              : _buildSearchResultsList(),
        ),
      ],
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
    final fileType = _getFileTypeForSearch(fileName);
    final fileSize = _formatSizeForSearch(file['size']);
    final createdAt = file['createdAt'];
    final isStarred = file['isStarred'] ?? false;

    // ✅ بناء URL
    String fileUrl;
    if (filePath.isNotEmpty) {
      fileUrl = _getFileUrlForSearch(filePath);
    } else if (fileId != null && fileId.isNotEmpty) {
      final baseUrl = ApiConfig.baseUrl.replaceAll('/api/v1', '');
      final downloadPath = ApiEndpoints.downloadFile(fileId);
      fileUrl = "$baseUrl$downloadPath";
    } else {
      fileUrl = '';
    }

    return GestureDetector(
      onTap: () {
        _handleSearchFileTap(file);
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
            ? _buildListCardForSearch(
                fileName,
                fileType,
                fileUrl,
                fileSize,
                createdAt,
                isStarred,
                file,
              )
            : _buildGridCardForSearch(
                fileName,
                fileType,
                fileUrl,
                fileSize,
                createdAt,
                isStarred,
                file,
              ),
      ),
    );
  }

  // ✅ بناء كارد Grid
  Widget _buildGridCardForSearch(
    String fileName,
    String fileType,
    String fileUrl,
    String fileSize,
    dynamic createdAt,
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
                child: _buildFilePreviewForSearch(fileType, fileUrl, fileName),
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
                      _formatDateForSearch(createdAt),
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
  Widget _buildListCardForSearch(
    String fileName,
    String fileType,
    String fileUrl,
    String fileSize,
    dynamic createdAt,
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
            child: _buildFilePreviewForSearch(fileType, fileUrl, fileName),
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
                    _formatDateForSearch(createdAt),
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
  Widget _buildFilePreviewForSearch(
    String fileType,
    String fileUrl,
    String fileName,
  ) {
    switch (fileType.toLowerCase()) {
      case 'image':
        if (fileUrl.isNotEmpty) {
          // ✅ إضافة token للصور إذا كانت من API
          final needsToken = fileUrl.contains('/api/');
          return FutureBuilder<Map<String, String>?>(
            future: needsToken
                ? _getImageHeadersForSearch()
                : Future.value(null),
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
        return _buildFileIconForSearch(Icons.image, Colors.blue);
      case 'pdf':
        return _buildFileIconForSearch(Icons.picture_as_pdf, Colors.red);
      case 'video':
        return _buildFileIconForSearch(Icons.video_library, Colors.purple);
      case 'audio':
        return _buildFileIconForSearch(Icons.audiotrack, Colors.orange);
      default:
        return _buildFileIconForSearch(Icons.insert_drive_file, Colors.grey);
    }
  }

  // ✅ بناء أيقونة الملف
  Widget _buildFileIconForSearch(IconData icon, Color color) {
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
  String _getFileTypeForSearch(String fileName) {
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

  String _formatSizeForSearch(dynamic size) {
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
  Future<Map<String, String>?> _getImageHeadersForSearch() async {
    final token = await StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      return {'Authorization': 'Bearer $token'};
    }
    return null;
  }

  // ✅ تنسيق التاريخ
  String _formatDateForSearch(dynamic date) {
    if (date == null) return '—';
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return '—';
    }
  }

  // ✅ بناء URL الملف
  String _getFileUrlForSearch(String path) {
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

  // ✅ فتح الملف من نتائج البحث الذكي (نفس الكود من smart_search_page.dart)
  Future<void> _handleSearchFileTap(Map<String, dynamic> file) async {
    print('═══════════════════════════════════════════════════════');
    print('🔍 [FoldersSearch] ===== START OPENING FILE =====');
    print('🔍 [FoldersSearch] File name: ${file['name']}');
    print('🔍 [FoldersSearch] File data keys: ${file.keys.toList()}');
    print('🔍 [FoldersSearch] Full file data: $file');
    print('───────────────────────────────────────────────────────');

    // ✅ استخراج path و _id مباشرة من البيانات
    String? filePath = file['path'] as String?;
    String? fileId = file['_id']?.toString() ?? file['id']?.toString();

    print('🔍 [FoldersSearch] Step 1: Extract path and _id');
    print('🔍 [FoldersSearch]   - filePath (raw): ${file['path']}');
    print('🔍 [FoldersSearch]   - filePath (after cast): $filePath');
    print(
      '🔍 [FoldersSearch]   - filePath isEmpty: ${filePath?.isEmpty ?? true}',
    );
    print('🔍 [FoldersSearch]   - file _id (raw): ${file['_id']}');
    print('🔍 [FoldersSearch]   - file id (raw): ${file['id']}');
    print('🔍 [FoldersSearch]   - fileId (final): $fileId');
    print('🔍 [FoldersSearch]   - fileId isEmpty: ${fileId?.isEmpty ?? true}');
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

      print('🔍 [FoldersSearch] Step 2: Build URL');
      print('🔍 [FoldersSearch]   - Source: $urlSource');
      print('🔍 [FoldersSearch]   - Base URL: $baseUrl');
      print('🔍 [FoldersSearch]   - Download path: $downloadPath');
      print('🔍 [FoldersSearch]   - Final URL: $url');
    } else if (filePath != null && filePath.isNotEmpty) {
      urlSource = 'file_path';
      url = _getFileUrlForSearch(filePath);

      print('🔍 [FoldersSearch] Step 2: Build URL');
      print('🔍 [FoldersSearch]   - Source: $urlSource');
      print('🔍 [FoldersSearch]   - File path: $filePath');
      print('🔍 [FoldersSearch]   - Final URL: $url');
    } else {
      print('🔍 [FoldersSearch] Step 2: ERROR - No path or _id');
      print(
        '🔍 [FoldersSearch]   - filePath is null/empty: ${filePath == null || filePath.isEmpty}',
      );
      print(
        '🔍 [FoldersSearch]   - fileId is null/empty: ${fileId == null || fileId.isEmpty}',
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
    print('🔍 [FoldersSearch] Step 3: Validate URL');

    // ✅ التحقق من صحة URL
    bool isValidUrlForSearch(String url) {
      try {
        final uri = Uri.parse(url);
        return uri.isAbsolute &&
            (uri.scheme == 'http' || uri.scheme == 'https') &&
            uri.host.isNotEmpty;
      } catch (e) {
        return false;
      }
    }

    final isValidUrl = isValidUrlForSearch(url);
    print('🔍 [FoldersSearch]   - URL is valid: $isValidUrl');
    print('🔍 [FoldersSearch]   - URL: $url');
    print('───────────────────────────────────────────────────────');

    if (!isValidUrl) {
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

    // ✅ عرض loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
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

      final client = http.Client();
      final response = await client.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Range': 'bytes=0-511'},
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 206) {
        final bytes = response.bodyBytes;
        final isPdf = _isValidPdfForSearch(bytes);
        final contentType =
            response.headers['content-type']?.toLowerCase() ?? '';

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
        if (name.endsWith('.pdf') && isPdf) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PdfViewerPage(pdfUrl: url, fileName: fileName),
            ),
          );
        } else if (isVideoFile()) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VideoViewer(url: url)),
          );
        } else if (isImageFile()) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageViewer(imageUrl: url, fileId: fileId ?? ''),
            ),
          );
        } else if (TextViewerPage.isTextFile(fileName) ||
            contentType.startsWith('text/')) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(child: CircularProgressIndicator()),
          );
          try {
            final fullResponse = await http.get(
              Uri.parse(url),
              headers: {'Authorization': 'Bearer $token'},
            );
            if (!mounted) return;
            Navigator.pop(context);
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AudioPlayerPage(audioUrl: url, fileName: fileName),
            ),
          );
        } else {
          await OfficeFileOpener.openAnyFile(
            url: url,
            context: context,
            token: token,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('الملف غير متاح (خطأ ${response.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
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

  // ✅ التحقق من صحة PDF
  bool _isValidPdfForSearch(List<int> bytes) {
    try {
      if (bytes.length < 4) return false;
      final signature = String.fromCharCodes(bytes.sublist(0, 4));
      return signature == '%PDF';
    } catch (e) {
      return false;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes == 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];

    // ✅ حساب الفهرس بشكل صحيح
    int i = 0;
    double size = bytes.toDouble();

    while (size >= k && i < sizes.length - 1) {
      size /= k;
      i++;
    }

    // ✅ التأكد من أن الفهرس ضمن النطاق
    if (i >= sizes.length) {
      i = sizes.length - 1;
    }

    return '${size.toStringAsFixed(1)} ${sizes[i]}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF1E1E1E)
          : const Color(0xff28336f),
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          children: [
            // شريط البحث والفلتر
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 16.0,
                  tablet: 24.0,
                  desktop: 32.0,
                ),
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  // حقل البحث
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F5F5).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: S.of(context).searchHint,
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[500],
                            size: 22,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey[500],
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        onChanged: (value) {
                          setState(() {
                            // ✅ البحث يتم تلقائياً عبر listener
                          });
                        },
                        onSubmitted: (value) {
                          // ✅ البحث يتم تلقائياً عبر listener
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // زر الدعوات المعلقة
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.mail_outline, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider.value(
                              value: Provider.of<RoomController>(
                                context,
                                listen: false,
                              ),
                              child: PendingInvitationsPage(),
                            ),
                          ),
                        );
                      },
                      tooltip: 'الدعوات المعلقة',
                    ),
                  ),
                  SizedBox(width: 12),
                  // زر الفلتر
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF00BFA5),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.filter_list, color: Colors.white),
                      tooltip: 'الفلتر',
                      onPressed: () {
                        setState(() {
                          _showFilterOptions = !_showFilterOptions;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // خيارات الفلتر (تظهر/تختفي)
            if (_showFilterOptions)
              FilterSection(
                selectedTypes: _selectedTypes,
                selectedTimeFilter: _selectedTimeFilter,
                onTypesChanged: (newTypes) {
                  setState(() {
                    _selectedTypes = newTypes;
                  });
                },
                onTimeFilterChanged: (newTimeFilter) {
                  setState(() {
                    _selectedTimeFilter = newTimeFilter;
                  });
                },
              ),
            SizedBox(height: 10),

            // View Mode Selector
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment<String>(
                    value: 'all',
                    label: Text(S.of(context).all),
                    icon: Icon(Icons.folder, size: 18),
                  ),
                  ButtonSegment<String>(
                    value: 'shared',
                    label: Text(S.of(context).shared),
                    icon: Icon(Icons.share, size: 18),
                  ),
                ],
                selected: {_viewMode},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _viewMode = newSelection.first;
                  });
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: Color(0xFF00BFA5),
                  selectedForegroundColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white70,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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

            Expanded(
              child: _viewMode == 'all'
                  ? _buildContent(_filteredFolders, true, true)
                  : _buildContent(_filteredFolders, false, true),
            ),
          ],
        ),
      ),
    );
  }

  // دالة لبناء المحتوى
  Widget _buildContent(
    List<Map<String, dynamic>> folders,
    bool showFolders,
    bool showFiles,
  ) {
    // ✅ إذا كان البحث الذكي نشطاً، عرض نتائج البحث
    if (_isSearching && showFiles) {
      if (_isSearchLoading) {
        return Card(
          elevation: 4,
          margin: EdgeInsets.zero,
          color: const Color(0xFFE9E9E9),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'جاري البحث الذكي...',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      }

      if (_searchResults.isEmpty && _searchQuery != null) {
        return Card(
          elevation: 4,
          margin: EdgeInsets.zero,
          color: const Color(0xFFE9E9E9),
          child: Center(
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
          ),
        );
      }

      if (_searchResults.isNotEmpty) {
        return _buildSmartSearchResults();
      }
    }

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 25.0,
              tablet: 30.0,
              desktop: 35.0,
            ),
          ),
        ),
      ),
      color: const Color(0xFFE9E9E9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),

              // العنوان وأزرار العرض + زر إنشاء مجلد جديد أو غرفة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    showFolders && showFiles
                        ? S.of(context).allItems
                        : showFolders
                        ? S.of(context).myFolders
                        : S.of(context).sharedFiles,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveValue(
                        context,
                        mobile: 24.0,
                        tablet: 28.0,
                        desktop: 32.0,
                      ),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff28336f),
                    ),
                  ),
                  Row(
                    children: [
                      // ✅ زر إنشاء غرفة في tab المشتركة، أو زر إنشاء مجلد في باقي التابز
                      if (!showFolders && showFiles)
                        IconButton(
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Color(0xff28336f),
                          ),
                          tooltip: 'إنشاء غرفة مشاركة',
                          onPressed: () => _showCreateRoomPage(),
                        )
                      else
                        IconButton(
                          icon: Icon(
                            Icons.create_new_folder,
                            color: Color(0xff28336f),
                          ),
                          tooltip: S.of(context).createFolder,
                          onPressed: () => _showCreateFolderDialog(),
                        ),
                      ViewToggleButtons(
                        isGridView: isFilesGridView,
                        onViewChanged: (isGrid) {
                          setState(() {
                            isFilesGridView = isGrid;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 20),

              // عرض المجلدات فقط
              if (showFolders) ...[
                if (_isLoadingFolders)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (isFilesGridView)
                  Consumer<FileController>(
                    builder: (context, fileController, child) {
                      // ✅ استخدام Consumer للاستماع لتغييرات categoriesStats
                      final categoriesStats = fileController.categoriesStats;

                      // ✅ تحديث التصنيفات بالقيم من Controller (من القائمة المفلترة)
                      final updatedCategories = _filteredFolders
                          .where((item) => item['type'] == 'category')
                          .map((category) {
                            final categoryName =
                                (category['category'] as String).toLowerCase();
                            final stats = categoriesStats[categoryName];

                            if (stats != null) {
                              return {
                                ...category,
                                'fileCount': stats['filesCount'] ?? 0,
                                'size': _formatBytes(stats['totalSize'] ?? 0),
                              };
                            }
                            return category;
                          })
                          .toList();

                      // ✅ دمج التصنيفات المحدثة مع المجلدات (من القائمة المفلترة)
                      final updatedFolders = [
                        ...updatedCategories,
                        ..._filteredFolders
                            .where((item) => item['type'] != 'category')
                            .toList(),
                      ];

                      // ✅ تحديث folders في الـ state عند تغيير categoriesStats
                      if (_previousCategoriesStats.toString() !=
                          categoriesStats.toString()) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              folders = updatedFolders;
                              // ✅ تحديث القائمة المفلترة أيضاً
                              final query = _searchController.text
                                  .trim()
                                  .toLowerCase();
                              if (query.isEmpty) {
                                _filteredFolders = folders;
                              } else {
                                _filteredFolders = folders.where((item) {
                                  final title = (item['title'] as String? ?? '')
                                      .toLowerCase();
                                  return title.contains(query);
                                }).toList();
                              }
                            });
                          }
                        });
                        _previousCategoriesStats =
                            Map<String, Map<String, dynamic>>.from(
                              categoriesStats,
                            );
                      }

                      return FilesGridView(
                        items: updatedFolders,
                        showFileCount: true,
                        onFileRemoved: () {
                          // ✅ إعادة تحميل التصنيفات والمجلدات بعد نقل ملف أو مجلد
                          _loadCategoriesAndFolders();
                        },
                        onItemTap: (item) {
                          final type = item['type'] as String?;

                          // ✅ إذا كان category، افتح صفحة التصنيف
                          if (type == 'category') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryPage(
                                  category: item['title'] as String,
                                  color: item['color'] as Color,
                                  icon: item['icon'] as IconData,
                                ),
                              ),
                            );
                          }
                          // ✅ إذا كان folder، افتح محتويات المجلد
                          else if (type == 'folder') {
                            final folderId = item['folderId'] as String?;
                            final folderName = item['title'] as String?;
                            final folderColor = item['color'] as Color?;

                            if (folderId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChangeNotifierProvider.value(
                                        value: Provider.of<FolderController>(
                                          context,
                                          listen: false,
                                        ),
                                        child: FolderContentsPage(
                                          folderId: folderId,
                                          folderName: folderName ?? 'مجلد',
                                          folderColor: folderColor,
                                        ),
                                      ),
                                ),
                              ).then((_) {
                                // ✅ إعادة تحميل المجلدات عند العودة من صفحة المحتويات
                                if (mounted) {
                                  _loadCategoriesAndFolders();
                                }
                              });
                            }
                          }
                        },
                      );
                    },
                  ),
                if (!isFilesGridView)
                  Consumer<FileController>(
                    builder: (context, fileController, child) {
                      // ✅ استخدام Consumer للاستماع لتغييرات categoriesStats
                      final categoriesStats = fileController.categoriesStats;

                      // ✅ تحديث التصنيفات بالقيم من Controller (من القائمة المفلترة)
                      final updatedCategories = _filteredFolders
                          .where((item) => item['type'] == 'category')
                          .map((category) {
                            final categoryName =
                                (category['category'] as String).toLowerCase();
                            final stats = categoriesStats[categoryName];

                            if (stats != null) {
                              return {
                                ...category,
                                'fileCount': stats['filesCount'] ?? 0,
                                'size': _formatBytes(stats['totalSize'] ?? 0),
                              };
                            }
                            return category;
                          })
                          .toList();

                      // ✅ دمج التصنيفات المحدثة مع المجلدات (من القائمة المفلترة)
                      final updatedFolders = [
                        ...updatedCategories,
                        ..._filteredFolders
                            .where((item) => item['type'] != 'category')
                            .toList(),
                      ];

                      // ✅ تحديث folders في الـ state عند تغيير categoriesStats
                      if (_previousCategoriesStats.toString() !=
                          categoriesStats.toString()) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              folders = updatedFolders;
                              // ✅ تحديث القائمة المفلترة أيضاً
                              final query = _searchController.text
                                  .trim()
                                  .toLowerCase();
                              if (query.isEmpty) {
                                _filteredFolders = folders;
                              } else {
                                _filteredFolders = folders.where((item) {
                                  final title = (item['title'] as String? ?? '')
                                      .toLowerCase();
                                  return title.contains(query);
                                }).toList();
                              }
                            });
                          }
                        });
                        _previousCategoriesStats =
                            Map<String, Map<String, dynamic>>.from(
                              categoriesStats,
                            );
                      }

                      return FilesListView(
                        items: updatedFolders,
                        itemMargin: EdgeInsets.only(bottom: 10),
                        showMoreOptions: true,
                        onFileRemoved: () {
                          // ✅ إعادة تحميل التصنيفات والمجلدات بعد نقل ملف
                          _loadCategoriesAndFolders();
                        },
                        onItemTap: (item) {
                          final type = item['type'] as String?;

                          // ✅ إذا كان category، افتح صفحة التصنيف
                          if (type == 'category') {
                            final categoryTitle =
                                item['title'] as String? ?? '';
                            final categoryColor =
                                item['color'] as Color? ?? Colors.blue;
                            final categoryIcon =
                                item['icon'] as IconData? ?? Icons.folder;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryPage(
                                  category: categoryTitle,
                                  color: categoryColor,
                                  icon: categoryIcon,
                                ),
                              ),
                            );
                          }
                          // ✅ إذا كان folder، افتح محتويات المجلد
                          else if (type == 'folder') {
                            final folderId = item['folderId'] as String?;
                            final folderName = item['title'] as String?;
                            final folderColor = item['color'] as Color?;

                            if (folderId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChangeNotifierProvider.value(
                                        value: Provider.of<FolderController>(
                                          context,
                                          listen: false,
                                        ),
                                        child: FolderContentsPage(
                                          folderId: folderId,
                                          folderName: folderName ?? 'مجلد',
                                          folderColor: folderColor,
                                        ),
                                      ),
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
              ],

              // ✅ عرض المجلدات المشتركة والغرف في tab المشتركة
              if (showFiles && !showFolders) ...[
                // ✅ عرض المجلدات المشتركة
                if (_isLoadingSharedFolders)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_filteredSharedFolders.isNotEmpty) ...[
                  Text(
                    'المجلدات المشتركة معي',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveValue(
                        context,
                        mobile: 18.0,
                        tablet: 20.0,
                        desktop: 22.0,
                      ),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff28336f),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (isFilesGridView)
                    FilesGridView(
                      items: _filteredSharedFolders,
                      showFileCount: true,
                      onFileRemoved: () {
                        // ✅ إعادة تحميل المجلدات المشتركة بعد نقل ملف أو مجلد
                        _loadSharedFolders();
                        _loadCategoriesAndFolders();
                      },
                      onItemTap: (item) {
                        final type = item['type'] as String?;

                        // ✅ إذا كان folder، افتح محتويات المجلد
                        if (type == 'folder') {
                          final folderId = item['folderId'] as String?;
                          final folderName = item['title'] as String?;
                          final folderColor = item['color'] as Color?;

                          if (folderId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChangeNotifierProvider.value(
                                      value: Provider.of<FolderController>(
                                        context,
                                        listen: false,
                                      ),
                                      child: FolderContentsPage(
                                        folderId: folderId,
                                        folderName: folderName ?? 'مجلد',
                                        folderColor: folderColor,
                                      ),
                                    ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  if (!isFilesGridView)
                    FilesListView(
                      items: _filteredSharedFolders,
                      itemMargin: EdgeInsets.only(bottom: 10),
                      showMoreOptions: true,
                      onItemTap: (item) {
                        final type = item['type'] as String?;

                        // ✅ إذا كان folder، افتح محتويات المجلد
                        if (type == 'folder') {
                          final folderId = item['folderId'] as String?;
                          final folderName = item['title'] as String?;
                          final folderColor = item['color'] as Color?;

                          if (folderId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChangeNotifierProvider.value(
                                      value: Provider.of<FolderController>(
                                        context,
                                        listen: false,
                                      ),
                                      child: FolderContentsPage(
                                        folderId: folderId,
                                        folderName: folderName ?? 'مجلد',
                                        folderColor: folderColor,
                                      ),
                                    ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  SizedBox(height: 32),
                ],

                // ✅ عرض الغرف
                Text(
                  'الغرف',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveValue(
                      context,
                      mobile: 18.0,
                      tablet: 20.0,
                      desktop: 22.0,
                    ),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff28336f),
                  ),
                ),
                SizedBox(height: 16),
                Consumer<RoomController>(
                  builder: (context, roomController, child) {
                    if (roomController.isLoading &&
                        roomController.rooms.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (roomController.errorMessage != null &&
                        roomController.rooms.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              SizedBox(height: 16),
                              Text(
                                roomController.errorMessage!,
                                style: TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => roomController.getRooms(),
                                child: Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (roomController.rooms.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.meeting_room_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'لا توجد غرف مشاركة',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'اضغط على + لإنشاء غرفة مشاركة جديدة',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // ✅ تحويل الغرف إلى format مناسب للعرض
                    final roomItems = roomController.rooms.map((room) {
                      final membersCount = room['members']?.length ?? 0;

                      // ✅ استخدام filesCount و foldersCount من الباك إند مباشرة
                      // ✅ إذا لم تكن موجودة، احسبها من arrays
                      int filesCount = 0;
                      int foldersCount = 0;

                      // ✅ محاولة جلب filesCount من الباك إند
                      final filesCountValue = room['filesCount'];
                      if (filesCountValue != null) {
                        if (filesCountValue is int) {
                          filesCount = filesCountValue;
                        } else if (filesCountValue is num) {
                          filesCount = filesCountValue.toInt();
                        } else if (filesCountValue is String) {
                          filesCount = int.tryParse(filesCountValue) ?? 0;
                        }
                      }

                      // ✅ إذا لم يكن filesCount موجوداً، احسبه من array
                      if (filesCount == 0 && room['files'] is List) {
                        filesCount = (room['files'] as List).length;
                      }

                      // ✅ محاولة جلب foldersCount من الباك إند
                      final foldersCountValue = room['foldersCount'];
                      if (foldersCountValue != null) {
                        if (foldersCountValue is int) {
                          foldersCount = foldersCountValue;
                        } else if (foldersCountValue is num) {
                          foldersCount = foldersCountValue.toInt();
                        } else if (foldersCountValue is String) {
                          foldersCount = int.tryParse(foldersCountValue) ?? 0;
                        }
                      }

                      // ✅ إذا لم يكن foldersCount موجوداً، احسبه من array
                      if (foldersCount == 0 && room['folders'] is List) {
                        foldersCount = (room['folders'] as List).length;
                      }

                      final totalItems =
                          filesCount + foldersCount; // ✅ إجمالي العناصر

                      return {
                        "title": room['name'] ?? 'بدون اسم',
                        "fileCount":
                            totalItems, // ✅ إجمالي العناصر (ملفات + مجلدات)
                        "filesCount": filesCount, // ✅ عدد الملفات فقط
                        "foldersCount": foldersCount, // ✅ عدد المجلدات فقط
                        "size": _formatMemberCount(membersCount),
                        "icon": Icons.meeting_room,
                        "color": Color(0xff28336f),
                        "description": room['description'] ?? '',
                        "type": "room", // ✅ تمييز الغرف
                        "room": room, // ✅ إضافة بيانات الغرفة الكاملة
                      };
                    }).toList();

                    if (isFilesGridView) {
                      return FilesGridView(
                        items: roomItems,
                        showFileCount: true,
                        onItemTap: (item) {
                          final room = item['room'] as Map<String, dynamic>?;
                          if (room != null && room['_id'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChangeNotifierProvider.value(
                                      value: roomController,
                                      child: RoomDetailsPage(
                                        roomId: room['_id'],
                                      ),
                                    ),
                              ),
                            );
                          }
                        },
                        onRoomDetailsTap: (item) {
                          // ✅ عرض تفاصيل الغرفة عند الضغط على خيار "عرض التفاصيل" في القائمة
                          final room = item['room'] as Map<String, dynamic>?;
                          if (room != null && room['_id'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChangeNotifierProvider.value(
                                      value: roomController,
                                      child: RoomDetailsPage(
                                        roomId: room['_id'],
                                      ),
                                    ),
                              ),
                            );
                          }
                        },
                        onRoomEditTap: (item) async {
                          // ✅ تعديل الغرفة عند الضغط على خيار "تعديل" في القائمة
                          final room = item['room'] as Map<String, dynamic>?;
                          if (room != null && room['_id'] != null) {
                            // ✅ التحقق من الصلاحيات قبل فتح نافذة التعديل
                            final canEdit = await RoomPermissions.canEditRoom(
                              room,
                            );
                            if (canEdit) {
                              _showEditRoomDialog(
                                context,
                                roomController,
                                room,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '❌ فقط مالك الغرفة أو الأعضاء برتبة محرر يمكنهم تعديل الغرفة',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      );
                    } else {
                      return FilesListView(
                        items: roomItems,
                        itemMargin: EdgeInsets.only(bottom: 10),
                        showMoreOptions: true,
                        onItemTap: (item) {
                          final room = item['room'] as Map<String, dynamic>?;
                          if (room != null && room['_id'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChangeNotifierProvider.value(
                                      value: roomController,
                                      child: RoomDetailsPage(
                                        roomId: room['_id'],
                                      ),
                                    ),
                              ),
                            );
                          }
                        },
                        onRoomDetailsTap: (item) {
                          // ✅ عرض تفاصيل الغرفة عند الضغط على خيار "عرض المعلومات" في القائمة
                          final room = item['room'] as Map<String, dynamic>?;
                          if (room != null && room['_id'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChangeNotifierProvider.value(
                                      value: roomController,
                                      child: RoomDetailsPage(
                                        roomId: room['_id'],
                                      ),
                                    ),
                              ),
                            );
                          }
                        },
                        onRoomEditTap: (item) async {
                          // ✅ تعديل الغرفة عند الضغط على خيار "تعديل" في القائمة
                          final room = item['room'] as Map<String, dynamic>?;
                          if (room != null && room['_id'] != null) {
                            // ✅ التحقق من الصلاحيات قبل فتح نافذة التعديل
                            final canEdit = await RoomPermissions.canEditRoom(
                              room,
                            );
                            if (canEdit) {
                              _showEditRoomDialog(
                                context,
                                roomController,
                                room,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '❌ فقط مالك الغرفة أو الأعضاء برتبة محرر يمكنهم تعديل الغرفة',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      );
                    }
                  },
                ),
              ],

              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // Dialog لإنشاء مجلد جديد
  void _showCreateFolderDialog() async {
    final folderNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).createFolder),
        content: TextField(
          controller: folderNameController,
          decoration: InputDecoration(
            hintText: S.of(context).folderNameHint,
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
                    content: Text('⚠️ الرجاء إدخال اسم المجلد'),
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
                          ? '📁 تم إنشاء المجلد "$folderName" بنجاح'
                          : '❌ ${folderController.errorMessage ?? "فشل إنشاء المجلد"}',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                // ✅ إعادة تحميل المجلدات بعد إنشاء مجلد جديد
                if (success) {
                  _loadCategoriesAndFolders();
                }
              }
            },
            child: Text(S.of(context).create),
          ),
        ],
      ),
    );
  }

  // ✅ فتح صفحة إنشاء غرفة مشاركة جديدة
  Future<void> _showCreateRoomPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: Provider.of<RoomController>(context, listen: false),
          child: CreateSharePage(),
        ),
      ),
    );

    // ✅ إذا تم إنشاء غرفة بنجاح، تحديث القائمة
    if (result != null && mounted) {
      final roomController = Provider.of<RoomController>(
        context,
        listen: false,
      );
      await roomController.getRooms();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم إنشاء الغرفة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ✅ عرض نافذة تعديل الغرفة
  Future<void> _showEditRoomDialog(
    BuildContext context,
    RoomController roomController,
    Map<String, dynamic> room,
  ) async {
    final roomId = room['_id']?.toString();
    if (roomId == null) return;

    final nameController = TextEditingController(text: room['name'] ?? '');
    final descriptionController = TextEditingController(
      text: room['description'] ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('تعديل الغرفة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'اسم الغرفة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                autofocus: true,
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'الوصف (اختياري)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text('⚠️ الرجاء إدخال اسم الغرفة'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext, true);
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final newName = nameController.text.trim();
      final newDescription = descriptionController.text.trim();

      // ✅ التحقق من أن الاسم غير فارغ (يتم التحقق في الباك إند أيضاً)
      if (newName.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ اسم الغرفة لا يمكن أن يكون فارغاً'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // ✅ إظهار loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      final success = await roomController.updateRoom(
        roomId: roomId,
        name: newName,
        description: newDescription.isEmpty ? null : newDescription,
      );

      if (mounted) {
        Navigator.pop(context); // إغلاق loading indicator

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تم تحديث الغرفة بنجاح'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                roomController.errorMessage ?? '❌ فشل تحديث الغرفة',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  // ✅ تنسيق عدد الأعضاء
  String _formatMemberCount(int count) {
    if (count == 0) {
      return 'لا يوجد أعضاء';
    } else if (count == 1) {
      return 'عضو واحد';
    } else {
      return '$count أعضاء';
    }
  }
}
