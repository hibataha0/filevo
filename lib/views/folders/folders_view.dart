import 'package:filevo/views/folders/CategoryFiles.dart';
import 'package:filevo/views/folders/folder_contents_page.dart';
import 'package:flutter/material.dart';
import 'package:filevo/components/FilesGridView.dart';
import 'package:filevo/components/FilesListView.dart';
import 'package:filevo/components/ViewToggleButtons.dart';
import 'package:filevo/responsive.dart';
import 'package:filevo/views/folders/components/filter_section.dart';
import 'package:filevo/views/folders/components/search_results_widget.dart';
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
import 'package:filevo/config/api_config.dart';
import 'package:filevo/views/fileViewer/VideoViewer.dart';
import 'package:filevo/views/fileViewer/audioPlayer.dart';
import 'package:filevo/views/fileViewer/imageViewer.dart';
import 'package:filevo/views/fileViewer/office_file_opener.dart';
import 'package:filevo/views/fileViewer/pdfViewer.dart';
import 'package:filevo/views/fileViewer/textViewer.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FoldersPage extends StatefulWidget {
  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage>
    with SingleTickerProviderStateMixin {
  static const List<String> _externalFileExtensions = [
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'zip',
    'rar',
    '7z',
    'apk',
    'exe',
    'psd',
    'ai',
    'sketch',
  ];

  final TextEditingController _searchController = TextEditingController();
  bool _showFilterOptions = false;
  String _selectedTimeFilter = 'All';
  String? _selectedCategory;
  String? _selectedDateRange;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  bool isFilesGridView = true;
  List<String> _selectedTypes = [];

  // ✅ تغيير نظام العرض - استخدام TabController بدلاً من _viewMode
  TabController? _tabController;
  int _currentTabIndex = 0; // 0: الكل، 1: الغرف

  List<Map<String, dynamic>> folders = [];
  List<Map<String, dynamic>> sharedFolders = [];
  bool _isLoadingFolders = false;
  bool _isLoadingSharedFolders = false;
  Map<String, Map<String, dynamic>> _previousCategoriesStats = {};

  List<Map<String, dynamic>> _filteredFolders = [];
  List<Map<String, dynamic>> _filteredSharedFolders = [];

  final FileSearchService _fileSearchService = FileSearchService();
  bool _isSearchLoadingFiles = false;
  List<Map<String, dynamic>> _searchFilesResults = [];
  Timer? _searchDebounceTimer;
  http.Client? _searchHttpClient;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _searchText = '';

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();

    // ✅ تهيئة TabController
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(() {
      if (_tabController!.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController!.index;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategoriesAndFolders();
      final roomController = Provider.of<RoomController>(
        context,
        listen: false,
      );
      roomController.getRooms();
      _loadSharedFolders();
    });

    _searchController.addListener(_onSearchChanged);
    _initializeSpeech();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      _searchDebounceTimer?.cancel();
      _searchHttpClient?.close();
      _searchHttpClient = null;

      setState(() {
        _filteredFolders = folders;
        _filteredSharedFolders = sharedFolders;
        _searchFilesResults = [];
        _isSearchLoadingFiles = false;
      });
      return;
    }

    final queryLower = query.toLowerCase();

    final filteredFoldersList = folders.where((folder) {
      final name = (folder['title'] ?? folder['name'] ?? '')
          .toString()
          .toLowerCase();
      return name.contains(queryLower);
    }).toList();

    final filteredSharedFoldersList = sharedFolders.where((folder) {
      final name = (folder['name'] ?? '').toString().toLowerCase();
      return name.contains(queryLower);
    }).toList();

    if (mounted) {
      setState(() {
        _filteredFolders = filteredFoldersList;
        _filteredSharedFolders = filteredSharedFoldersList;
      });
    }

    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(Duration(milliseconds: 500), () {
      if (_searchController.text.trim() == query && query.isNotEmpty) {
        _performFileSearch(query);
      }
    });
  }

  Future<void> _performFileSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchFilesResults = [];
        _isSearchLoadingFiles = false;
      });
      return;
    }

    _searchHttpClient?.close();
    _searchHttpClient = http.Client();

    setState(() {
      _isSearchLoadingFiles = true;
    });

    try {
      String? categoryForBackend;
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        final categoryMap = {
          'صور': 'Images',
          'فيديوهات': 'Videos',
          'صوتيات': 'Audio',
          'مستندات': 'Documents',
          'مضغوط': 'Compressed',
          'تطبيقات': 'Applications',
          'رمز/كود': 'Code',
          'أخرى': 'Others',
        };
        categoryForBackend =
            categoryMap[_selectedCategory] ?? _selectedCategory;
      }

      String? dateRangeForBackend;
      if (_selectedDateRange != null &&
          _selectedDateRange != 'All' &&
          _selectedDateRange!.isNotEmpty) {
        final dateRangeMap = {
          'أمس': 'yesterday',
          'آخر 7 أيام': 'last7days',
          'آخر 30 يوم': 'last30days',
          'آخر سنة': 'lastyear',
          'مخصص': 'custom',
        };
        dateRangeForBackend =
            dateRangeMap[_selectedDateRange] ?? _selectedDateRange;
      }

      final result = await _fileSearchService.smartSearch(
        query: query,
        limit: 50,
        category: categoryForBackend,
        dateRange: dateRangeForBackend,
        startDate: _customStartDate,
        endDate: _customEndDate,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final results = List<Map<String, dynamic>>.from(
          result['results'] ?? [],
        );
        final processedResults = results.map<Map<String, dynamic>>((r) {
          final file = Map<String, dynamic>.from(r['item'] ?? r);
          file['type'] = 'file';
          file['searchType'] = r['searchType'] ?? 'text';
          file['relevanceScore'] = r['relevanceScore'] ?? 0.0;
          if (file['_id'] == null && file['id'] != null) {
            file['_id'] = file['id'];
          }
          return file;
        }).toList();

        if (!mounted) return;

        setState(() {
          _searchFilesResults = processedResults;
          _isSearchLoadingFiles = false;
        });
      } else {
        setState(() {
          _searchFilesResults = [];
          _isSearchLoadingFiles = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchFilesResults = [];
          _isSearchLoadingFiles = false;
        });
      }
    }
  }

  Future<void> _loadCategoriesAndFolders() async {
    if (!mounted) return;

    setState(() {
      _isLoadingFolders = true;
    });

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

    try {
      final fileController = Provider.of<FileController>(
        context,
        listen: false,
      );
      final token = await StorageService.getToken();

      if (token != null) {
        await fileController.getRootCategoriesStats(token: token);
      }
    } catch (e) {
      print('⚠️ Error loading root categories stats: $e');
    }

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
          dynamic sizeValue = folderData['size'];
          dynamic filesCountValue = folderData['filesCount'];

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

          return {
            "title": folderData['name'] ?? 'بدون اسم',
            "fileCount": filesCount,
            "size": _formatBytes(size),
            "icon": Icons.folder,
            "color": Color(0xff28336f),
            "type": "folder",
            "folderId": folderData['_id'],
            "folderData": folderData,
          };
        }).toList();
      }

      if (!mounted) return;

      final fileController = Provider.of<FileController>(
        context,
        listen: false,
      );
      final categoriesStats = fileController.categoriesStats;

      if (_previousCategoriesStats.isEmpty) {
        _previousCategoriesStats = Map<String, Map<String, dynamic>>.from(
          categoriesStats,
        );
      }

      final updatedCategories = categoriesBase.map((category) {
        final categoryName = (category['category']?.toString() ?? '')
            .toLowerCase();
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
          folders = [...updatedCategories, ...userFolders];
          _filteredFolders = folders;
          _isLoadingFolders = false;
        });
      }
    } catch (e) {
      print('❌ Error loading folders: $e');

      if (!mounted) return;

      final fileController = Provider.of<FileController>(
        context,
        listen: false,
      );
      final categoriesStats = fileController.categoriesStats;

      final updatedCategories = categoriesBase.map((category) {
        final categoryName = (category['category']?.toString() ?? '')
            .toLowerCase();
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
          _filteredFolders = folders;
          _isLoadingFolders = false;
        });
      }
    }
  }

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
            "color": Colors.orange,
            "type": "folder",
            "folderId": folderData['_id'],
            "folderData": folderData,
            "owner": ownerName,
            "myPermission": folderData['myPermission'] ?? 'view',
          };
        }).toList();
      }

      if (!mounted) return;

      if (mounted) {
        setState(() {
          sharedFolders = sharedFoldersList;
          _filteredSharedFolders = sharedFolders;
          _isLoadingSharedFolders = false;
        });
      }
    } catch (e) {
      print('❌ Error loading shared folders: $e');

      if (!mounted) return;

      if (mounted) {
        setState(() {
          sharedFolders = [];
          _filteredSharedFolders = [];
          _isLoadingSharedFolders = false;
        });
      }
    }
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

    if (i >= sizes.length) {
      i = sizes.length - 1;
    }

    return '${size.toStringAsFixed(1)} ${sizes[i]}';
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchDebounceTimer?.cancel();
    _searchHttpClient?.close();
    _searchController.dispose();
    _speech.stop();
    _refreshController.dispose();
    super.dispose();
  }

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

  Future<void> _startListening() async {
    PermissionStatus status = await Permission.microphone.status;

    if (status.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('إذن الميكروفون مطلوب'),
            content: const Text(
              'يجب السماح بالوصول إلى الميكروفون للبحث بالصوت.\n\nافتح إعدادات التطبيق وسمح بالوصول إلى الميكروفون.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('فتح الإعدادات'),
              ),
            ],
          ),
        );
      }
      return;
    }

    if (!status.isGranted) {
      status = await Permission.microphone.request();
      await Future.delayed(const Duration(milliseconds: 100));
      status = await Permission.microphone.status;

      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم رفض الإذن. يجب السماح بالوصول إلى الميكروفون للبحث بالصوت.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    }

    final finalStatus = await Permission.microphone.status;
    if (!finalStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب السماح بالوصول إلى الميكروفون للبحث بالصوت.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    bool available = await _speech.initialize();
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خدمة التعرف على الصوت غير متاحة'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    _speech.listen(
      localeId: "ar",
      onResult: (result) {
        if (mounted) {
          setState(() {
            _searchText = result.recognizedWords;
            if (_searchText.isNotEmpty) {
              _searchController.text = _searchText;
            }
          });

          if (result.finalResult && _searchText.isNotEmpty) {
            print('✅ النص المعرّف: $_searchText');
            _stopListening();
          }
        }
      },
    );

    setState(() {
      _isListening = true;
      _searchText = '';
    });
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  Widget? _buildSuffixIcons() {
    final hasText = _searchController.text.isNotEmpty;

    if (hasText && !_isListening) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.mic_none, color: Colors.grey[500], size: 20),
            onPressed: _startListening,
            tooltip: 'البحث بالصوت',
            padding: EdgeInsets.all(8),
            constraints: BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          IconButton(
            icon: Icon(Icons.clear, color: Colors.grey[500], size: 20),
            onPressed: () {
              setState(() {
                _searchController.clear();
              });
            },
            padding: EdgeInsets.all(8),
            constraints: BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      );
    }

    if (_isListening) {
      return IconButton(
        icon: Icon(Icons.mic, color: Colors.red, size: 20),
        onPressed: _stopListening,
        tooltip: 'إيقاف التسجيل',
        padding: EdgeInsets.all(8),
        constraints: BoxConstraints(minWidth: 40, minHeight: 40),
      );
    }

    return IconButton(
      icon: Icon(Icons.mic_none, color: Colors.grey[500], size: 20),
      onPressed: _startListening,
      tooltip: 'البحث بالصوت',
      padding: EdgeInsets.all(8),
      constraints: BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF1E1E1E)
          : const Color(0xff28336f),
      body: Column(
        children: [
          // ✅ شريط العلوي مع البحث والأزرار
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xff28336f),
            ),
            child: Column(
              children: [
                // شريط البحث والأزرار
                Row(
                  children: [
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
                            suffixIcon: _buildSuffixIcons(),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
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
                    SizedBox(width: 12),
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
                              builder: (context) =>
                                  ChangeNotifierProvider.value(
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
                  ],
                ),

                // خيارات الفلتر
                if (_showFilterOptions)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: FilterSection(
                      selectedTypes: _selectedTypes,
                      selectedTimeFilter: _selectedTimeFilter,
                      selectedCategory: _selectedCategory,
                      selectedDateRange: _selectedDateRange,
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
                      onCategoryChanged: (newCategory) {
                        setState(() {
                          _selectedCategory = newCategory;
                        });
                        if (_searchController.text.trim().isNotEmpty) {
                          _performFileSearch(_searchController.text.trim());
                        }
                      },
                      onDateRangeChanged: (newDateRange) {
                        setState(() {
                          _selectedDateRange = newDateRange;
                          if (newDateRange == null) {
                            _customStartDate = null;
                            _customEndDate = null;
                          }
                        });
                        if (_searchController.text.trim().isNotEmpty) {
                          _performFileSearch(_searchController.text.trim());
                        }
                      },
                      onStartDateChanged: (newStartDate) {
                        setState(() {
                          _customStartDate = newStartDate;
                        });
                        if (_searchController.text.trim().isNotEmpty) {
                          _performFileSearch(_searchController.text.trim());
                        }
                      },
                      onEndDateChanged: (newEndDate) {
                        setState(() {
                          _customEndDate = newEndDate;
                        });
                        if (_searchController.text.trim().isNotEmpty) {
                          _performFileSearch(_searchController.text.trim());
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),

          // ✅ TabBar الجديد - تصميم محسّن
          if (_tabController != null)
            Container(
              color: isDarkMode
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xff28336f),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController!,
                  indicator: BoxDecoration(
                    color: Color(0xFF00BFA5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder, size: 18),
                          SizedBox(width: 6),
                          Text('الكل'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.meeting_room, size: 18),
                          SizedBox(width: 6),
                          Text('غرف'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(height: 12),

          // ✅ المحتوى الرئيسي مع TabBarView
          Expanded(
            child: SmartRefresher(
              controller: _refreshController,
              onRefresh: () async {
                await _loadCategoriesAndFolders();
                await _loadSharedFolders();
                final roomController = Provider.of<RoomController>(
                  context,
                  listen: false,
                );
                await roomController.getRooms();
                _refreshController.refreshCompleted();
              },
              header: const WaterDropHeader(),
              child: _tabController == null
                  ? Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController!,
                      children: [
                        // Tab 1: الكل (المجلدات والتصنيفات)
                        _buildAllTab(),

                        // Tab 2: المجلدات المشتركة
                        //  _buildSharedFoldersTab(),

                        // Tab 3: الغرف
                        _buildRoomsTab(),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Tab الكل
  Widget _buildAllTab() {
    final hasSearchQuery = _searchController.text.trim().isNotEmpty;

    if (hasSearchQuery) {
      return _buildSearchResults();
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9E9E9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).allItems,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff28336f),
                  ),
                ),
                Row(
                  children: [
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

            // المحتوى
            Expanded(
              child: _isLoadingFolders
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildFoldersView(_filteredFolders),
                          SizedBox(height: 100), // ✅ مسافة فاضية في النهاية
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Tab الغرف
  Widget _buildRoomsTab() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9E9E9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الغرف',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff28336f),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: Color(0xff28336f),
                      ),
                      tooltip: 'إنشاء غرفة مشاركة',
                      onPressed: () => _showCreateRoomPage(),
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

            Expanded(
              child: Consumer<RoomController>(
                builder: (context, roomController, child) {
                  if (roomController.isLoading &&
                      roomController.rooms.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (roomController.errorMessage != null &&
                      roomController.rooms.isEmpty) {
                    return Center(
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
                    );
                  }

                  if (roomController.rooms.isEmpty) {
                    return Center(
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
                    );
                  }

                  final roomItems = roomController.rooms.map((room) {
                    final membersCount = room['members']?.length ?? 0;
                    int filesCount = 0;
                    int foldersCount = 0;

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

                    if (filesCount == 0 && room['files'] is List) {
                      filesCount = (room['files'] as List).length;
                    }

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

                    if (foldersCount == 0 && room['folders'] is List) {
                      foldersCount = (room['folders'] as List).length;
                    }

                    final totalItems = filesCount + foldersCount;

                    return {
                      "title": room['name'] ?? 'بدون اسم',
                      "fileCount": totalItems,
                      "filesCount": filesCount,
                      "foldersCount": foldersCount,
                      "size": _formatMemberCount(membersCount),
                      "icon": Icons.meeting_room,
                      "color": Color(0xff28336f),
                      "description": room['description'] ?? '',
                      "type": "room",
                      "room": room,
                    };
                  }).toList();

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildRoomsView(roomItems, roomController),
                        SizedBox(height: 100), // ✅ مسافة فاضية في النهاية
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ بناء عرض المجلدات
  Widget _buildFoldersView(List<Map<String, dynamic>> items) {
    if (isFilesGridView) {
      return Consumer<FileController>(
        builder: (context, fileController, child) {
          final categoriesStats = fileController.categoriesStats;

          final updatedCategories = items
              .where((item) => item['type'] == 'category')
              .map((category) {
                final categoryName = (category['category']?.toString() ?? '')
                    .toLowerCase();
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

          final updatedFolders = [
            ...updatedCategories,
            ...items.where((item) => item['type'] != 'category').toList(),
          ];

          return FilesGridView(
            items: updatedFolders,
            showFileCount: true,
            onFileRemoved: () => _loadCategoriesAndFolders(),
            onItemTap: (item) => _handleFolderTap(item),
          );
        },
      );
    } else {
      return Consumer<FileController>(
        builder: (context, fileController, child) {
          final categoriesStats = fileController.categoriesStats;

          final updatedCategories = items
              .where((item) => item['type'] == 'category')
              .map((category) {
                final categoryName = (category['category']?.toString() ?? '')
                    .toLowerCase();
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

          final updatedFolders = [
            ...updatedCategories,
            ...items.where((item) => item['type'] != 'category').toList(),
          ];

          return FilesListView(
            items: updatedFolders,
            itemMargin: EdgeInsets.only(bottom: 10),
            showMoreOptions: true,
            onFileRemoved: () => _loadCategoriesAndFolders(),
            onItemTap: (item) => _handleFolderTap(item),
          );
        },
      );
    }
  }

  // ✅ بناء عرض المجلدات المشتركة
  Widget _buildSharedFoldersView(List<Map<String, dynamic>> items) {
    if (isFilesGridView) {
      return FilesGridView(
        items: items,
        showFileCount: true,
        onFileRemoved: () {
          _loadSharedFolders();
          _loadCategoriesAndFolders();
        },
        onItemTap: (item) => _handleFolderTap(item),
      );
    } else {
      return FilesListView(
        items: items,
        itemMargin: EdgeInsets.only(bottom: 10),
        showMoreOptions: true,
        onItemTap: (item) => _handleFolderTap(item),
      );
    }
  }

  // ✅ بناء عرض الغرف
  Widget _buildRoomsView(
    List<Map<String, dynamic>> roomItems,
    RoomController roomController,
  ) {
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
                builder: (context) => ChangeNotifierProvider.value(
                  value: roomController,
                  child: RoomDetailsPage(roomId: room['_id']),
                ),
              ),
            );
          }
        },
        onRoomDetailsTap: (item) {
          final room = item['room'] as Map<String, dynamic>?;
          if (room != null && room['_id'] != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider.value(
                  value: roomController,
                  child: RoomDetailsPage(roomId: room['_id']),
                ),
              ),
            );
          }
        },
        onRoomEditTap: (item) async {
          final room = item['room'] as Map<String, dynamic>?;
          if (room != null && room['_id'] != null) {
            final canEdit = await RoomPermissions.canEditRoom(room);
            if (canEdit) {
              _showEditRoomDialog(context, roomController, room);
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
                builder: (context) => ChangeNotifierProvider.value(
                  value: roomController,
                  child: RoomDetailsPage(roomId: room['_id']),
                ),
              ),
            );
          }
        },
        onRoomDetailsTap: (item) {
          final room = item['room'] as Map<String, dynamic>?;
          if (room != null && room['_id'] != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider.value(
                  value: roomController,
                  child: RoomDetailsPage(roomId: room['_id']),
                ),
              ),
            );
          }
        },
        onRoomEditTap: (item) async {
          final room = item['room'] as Map<String, dynamic>?;
          if (room != null && room['_id'] != null) {
            final canEdit = await RoomPermissions.canEditRoom(room);
            if (canEdit) {
              _showEditRoomDialog(context, roomController, room);
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
  }

  // باقي الدوال المساعدة (بدون تغيير)
  Widget _buildSearchResults() {
    return SearchResultsWidget(
      filteredFolders: _filteredFolders,
      searchFilesResults: _searchFilesResults,
      isSearchLoadingFiles: _isSearchLoadingFiles,
      isFilesGridView: isFilesGridView,
      onViewChanged: (isGrid) {
        setState(() {
          isFilesGridView = isGrid;
        });
      },
      onFolderTap: _handleFolderTap,
      onFileTap: _handleFileTap,
      onFileRemoved: () {
        final query = _searchController.text.trim();
        if (query.isNotEmpty) {
          _performFileSearch(query);
        }
      },
      getFileUrlForSearch: _getFileUrlForSearch,
      getFileTypeForSearch: _getFileTypeForSearch,
      formatBytesForSearch: _formatBytesForSearch,
    );
  }

  String _getFileTypeForSearch(String fileName) {
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

  String _formatBytesForSearch(int bytes) {
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

  Map<String, dynamic> _extractFileData(Map<String, dynamic> file) {
    final originalData = file['originalData'] ?? file;
    final filePath = file['path'] as String?;
    final fileId =
        file['_id']?.toString() ??
        file['id']?.toString() ??
        originalData['_id']?.toString() ??
        originalData['id']?.toString();
    final originalName = file['originalName'] ?? file['name'] ?? 'ملف بدون اسم';

    return {
      'originalData': originalData,
      'filePath': filePath,
      'fileId': fileId,
      'originalName': originalName,
    };
  }

  Map<String, dynamic>? _buildFileUrl({
    required String? filePath,
    required String? fileId,
    required String originalName,
  }) {
    if ((filePath == null || filePath.isEmpty) &&
        (fileId != null && fileId.isNotEmpty)) {
      final extension = originalName.toLowerCase().contains('.')
          ? originalName.toLowerCase().substring(
              originalName.toLowerCase().lastIndexOf('.') + 1,
            )
          : '';

      final isExternalFile = _externalFileExtensions.contains(
        extension.toLowerCase(),
      );

      if (isExternalFile) {
        final baseUrl = ApiConfig.baseUrl.replaceAll('/api/v1', '');
        final downloadPath = ApiEndpoints.downloadFile(fileId);
        return {'url': "$baseUrl$downloadPath", 'useDownloadEndpoint': true};
      } else {
        final baseUrl = ApiConfig.baseUrl;
        final viewPath = ApiEndpoints.viewFile(fileId);
        return {'url': "$baseUrl$viewPath", 'useDownloadEndpoint': false};
      }
    } else if (filePath != null && filePath.isNotEmpty) {
      return {
        'url': _getFileUrlForSearch(filePath),
        'useDownloadEndpoint': false,
      };
    }
    return null;
  }

  Future<void> _handleFileTap(Map<String, dynamic> file) async {
    final fileData = _extractFileData(file);
    final originalData = fileData['originalData'] as Map<String, dynamic>;
    final filePath = fileData['filePath'] as String?;
    final fileId = fileData['fileId'] as String?;
    final originalName = fileData['originalName'] as String;
    final fileNameLower = originalName.toLowerCase();

    final urlData = _buildFileUrl(
      filePath: filePath,
      fileId: fileId,
      originalName: originalName,
    );

    if (urlData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('رابط الملف غير متوفر - لا يوجد path أو _id'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final url = urlData['url'] as String;
    final useDownloadEndpoint = urlData['useDownloadEndpoint'] as bool;

    if (!_isValidUrlForSearch(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('رابط غير صالح'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final extension = fileNameLower.contains('.')
        ? fileNameLower.substring(fileNameLower.lastIndexOf('.') + 1)
        : '';
    final shouldShowLoading = !_externalFileExtensions.contains(
      extension.toLowerCase(),
    );

    if (shouldShowLoading) {
      _showLoadingDialog(context);
    }

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        if (mounted && shouldShowLoading) {
          Navigator.pop(context);
        }
        if (mounted) {
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
      if (mounted && shouldShowLoading) {
        Navigator.pop(context);
      }

      if (response.statusCode == 200 || response.statusCode == 206) {
        await _openFileByType(
          url: url,
          fileId: fileId,
          originalName: originalName,
          originalData: originalData,
          filePath: filePath,
          fileNameLower: fileNameLower,
          response: response,
          useDownloadEndpoint: useDownloadEndpoint,
          token: token,
        );
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

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
  }

  bool _isValidUrlForSearch(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  String? _getFileExtension({
    required Map<String, dynamic> originalData,
    required String fileNameLower,
    required String? filePath,
    required String contentType,
  }) {
    final origName = originalData['name']?.toString();
    if (origName != null && origName.contains('.')) {
      return origName.substring(origName.lastIndexOf('.') + 1).toLowerCase();
    }
    final contentTypeFromData =
        originalData['contentType']?.toString() ??
        originalData['mimeType']?.toString();
    if (contentTypeFromData != null) {
      if (contentTypeFromData.contains('image')) {
        if (contentTypeFromData.contains('jpeg')) return 'jpg';
        if (contentTypeFromData.contains('png')) return 'png';
        if (contentTypeFromData.contains('gif')) return 'gif';
        if (contentTypeFromData.contains('webp')) return 'webp';
      }
      if (contentTypeFromData.contains('video')) {
        if (contentTypeFromData.contains('mp4')) return 'mp4';
        if (contentTypeFromData.contains('quicktime')) return 'mov';
      }
      if (contentTypeFromData.contains('audio')) {
        if (contentTypeFromData.contains('mpeg')) return 'mp3';
        if (contentTypeFromData.contains('wav')) return 'wav';
      }
      if (contentTypeFromData.contains('pdf')) return 'pdf';
    }
    if (fileNameLower.contains('.')) {
      return fileNameLower.substring(fileNameLower.lastIndexOf('.') + 1);
    }
    if (filePath != null && filePath.contains('.')) {
      return filePath.substring(filePath.lastIndexOf('.') + 1).toLowerCase();
    }
    return null;
  }

  bool _isImageFile(String? extension, String contentType) {
    if (extension != null) {
      return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
    }
    return contentType.startsWith('image/');
  }

  bool _isVideoFile(String? extension, String contentType) {
    if (extension != null) {
      return [
        'mp4',
        'mov',
        'mkv',
        'avi',
        'wmv',
        'webm',
        'm4v',
        '3gp',
        'flv',
      ].contains(extension);
    }
    return contentType.startsWith('video/');
  }

  bool _isAudioFile(String? extension, String contentType) {
    if (extension != null) {
      return [
        'mp3',
        'wav',
        'aac',
        'ogg',
        'm4a',
        'wma',
        'flac',
      ].contains(extension);
    }
    return contentType.startsWith('audio/');
  }

  Future<void> _openFileByType({
    required String url,
    required String? fileId,
    required String originalName,
    required Map<String, dynamic> originalData,
    required String? filePath,
    required String fileNameLower,
    required http.Response response,
    required bool useDownloadEndpoint,
    required String? token,
  }) async {
    final bytes = response.bodyBytes;
    final isPdf = _isValidPdfForSearch(bytes);
    final contentType = response.headers['content-type']?.toLowerCase() ?? '';
    final extension = _getFileExtension(
      originalData: originalData,
      fileNameLower: fileNameLower,
      filePath: filePath,
      contentType: contentType,
    );

    if ((extension == 'pdf' || fileNameLower.endsWith('.pdf')) && isPdf) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewerPage(pdfUrl: url, fileName: originalName),
        ),
      );
      return;
    }

    if (_isVideoFile(extension, contentType)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VideoViewer(url: url)),
      );
      return;
    }

    if (_isImageFile(extension, contentType)) {
      final fileIdForImage = originalData['_id']?.toString();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ImageViewer(imageUrl: url, fileId: fileIdForImage ?? ''),
        ),
      );
      return;
    }

    if (TextViewerPage.isTextFile(originalName) ||
        contentType.startsWith('text/')) {
      _showLoadingDialog(context);
      try {
        final fullResponse = await http.get(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (mounted) Navigator.pop(context);
        if (fullResponse.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$originalName');
          await tempFile.writeAsBytes(fullResponse.bodyBytes);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TextViewerPage(
                filePath: tempFile.path,
                fileName: originalName,
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
      return;
    }

    if (_isAudioFile(extension, contentType)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AudioPlayerPage(audioUrl: url, fileName: originalName),
        ),
      );
      return;
    }

    String finalUrl = url;
    if (!useDownloadEndpoint && fileId != null && fileId.isNotEmpty) {
      final baseUrl = ApiConfig.baseUrl.replaceAll('/api/v1', '');
      final downloadPath = ApiEndpoints.downloadFile(fileId);
      finalUrl = "$baseUrl$downloadPath";
    }

    _showLoadingDialog(context);

    await OfficeFileOpener.openAnyFile(
      url: finalUrl,
      context: context,
      token: token,
      fileName: originalName,
      closeLoadingDialog: true,
      onProgress: (received, total) {
        if (total > 0) {
          final percent = (received / total * 100).toStringAsFixed(0);
          print("📥 Downloading: $percent% ($received / $total bytes)");
        }
      },
    );
  }

  bool _isValidPdfForSearch(List<int> bytes) {
    try {
      if (bytes.length < 4) return false;
      final signature = String.fromCharCodes(bytes.sublist(0, 4));
      return signature == '%PDF';
    } catch (e) {
      return false;
    }
  }

  String _getFileUrlForSearch(String path) {
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

  void _handleFolderTap(Map<String, dynamic> folder) {
    final type = folder['type'] as String?;
    if (type == 'category') {
      final categoryTitle = folder['title']?.toString() ?? '';
      final categoryColor = folder['color'] is Color
          ? folder['color'] as Color
          : Colors.blue;
      final categoryIcon = folder['icon'] is IconData
          ? folder['icon'] as IconData
          : Icons.folder;

      if (categoryTitle.isNotEmpty) {
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
    } else if (type == 'folder') {
      final folderId =
          folder['folderId']?.toString() ?? folder['_id']?.toString();
      if (folderId != null && folderId.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider.value(
              value: Provider.of<FolderController>(context, listen: false),
              child: FolderContentsPage(
                folderId: folderId,
                folderName:
                    folder['title']?.toString() ??
                    folder['name']?.toString() ??
                    'مجلد',
                folderColor: folder['color'] is Color
                    ? folder['color'] as Color?
                    : null,
              ),
            ),
          ),
        );
      }
    }
  }

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
        Navigator.pop(context);

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
