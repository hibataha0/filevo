import 'package:filevo/views/folders/CategoryFiles.dart';
import 'package:filevo/views/folders/folder_contents_page.dart';
import 'package:flutter/material.dart';
import 'package:filevo/components/FilesGridView.dart';
import 'package:filevo/components/FilesListView.dart';
import 'package:filevo/components/ViewToggleButtons.dart';
import 'package:filevo/responsive.dart';
import 'package:filevo/views/folders/components/filter_section.dart';
import 'package:filevo/views/folders/components/tab_bar.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:filevo/views/folders/create_share_page.dart';
import 'package:filevo/views/folders/room_details_page.dart';
import 'package:filevo/views/folders/pending_invitations_page.dart';
import 'package:filevo/services/storage_service.dart';

class FoldersPage extends StatefulWidget {
  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  bool _showFilterOptions = false;
  String _selectedTimeFilter = 'All';
  bool isFilesGridView = true;
  List<String> _selectedTypes = [];
  bool isFoldersGridView = true;
  bool isFoldersListView = true;

  // نقل قائمة المجلدات لتكون جزء من الـ State
  List<Map<String, dynamic>> folders = [];
  List<Map<String, dynamic>> sharedFolders = []; // ✅ المجلدات المشتركة معي
  bool _isLoadingFolders = false;
  bool _isLoadingSharedFolders = false;
  Map<String, Map<String, dynamic>> _previousCategoriesStats = {}; // ✅ لتتبع تغييرات إحصائيات التصنيفات

  @override
  void initState() {
    super.initState();
    
    // ✅ تحميل التصنيفات والمجلدات بعد اكتمال البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategoriesAndFolders();
    });
    
    // ✅ تحميل الغرف عند بدء الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomController = Provider.of<RoomController>(context, listen: false);
      roomController.getRooms();
    });
    
    // ✅ تحميل المجلدات المشتركة عند بدء الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSharedFolders();
    });
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
      final fileController = Provider.of<FileController>(context, listen: false);
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
      final folderController = Provider.of<FolderController>(context, listen: false);
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
          print('📁 Folder: ${folderData['name']} - Size: $size bytes, Files: $filesCount');
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
      final fileController = Provider.of<FileController>(context, listen: false);
      final categoriesStats = fileController.categoriesStats;
      
      // ✅ تحديث _previousCategoriesStats عند التحميل الأول
      if (_previousCategoriesStats.isEmpty) {
        _previousCategoriesStats = Map<String, Map<String, dynamic>>.from(categoriesStats);
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
      setState(() {
        folders = [...updatedCategories, ...userFolders];
        _isLoadingFolders = false;
      });
    } catch (e) {
      print('❌ Error loading folders: $e');
      
      if (!mounted) return;
      
      // ✅ في حالة الخطأ، نعرض التصنيفات فقط (مع القيم من Controller إن وجدت)
      final fileController = Provider.of<FileController>(context, listen: false);
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
      
      setState(() {
        folders = updatedCategories;
        _isLoadingFolders = false;
      });
    }
  }

  // ✅ تحميل المجلدات المشتركة معي
  Future<void> _loadSharedFolders() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingSharedFolders = true;
    });

    try {
      final folderController = Provider.of<FolderController>(context, listen: false);
      final result = await folderController.getFoldersSharedWithMe(page: 1, limit: 100);
      
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
      
      setState(() {
        sharedFolders = sharedFoldersList;
        _isLoadingSharedFolders = false;
      });
    } catch (e) {
      print('❌ Error loading shared folders: $e');
      
      if (!mounted) return;
      
      setState(() {
        sharedFolders = [];
        _isLoadingSharedFolders = false;
      });
    }
  }

  // ✅ تنسيق حجم الملف
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
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xff28336f),
        body: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
          ),
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          onChanged: (value) {
                            setState(() {});
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
                        icon: Icon(
                          Icons.mail_outline,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangeNotifierProvider.value(
                                value: Provider.of<RoomController>(context, listen: false),
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
                        icon: Icon(
                          Icons.filter_list,
                          color: Colors.white,
                        ),
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

              // Custom Tab Bar
              CustomTabBar(
                tabs: [
                  S.of(context).all,
                  S.of(context).myFiles,
                  S.of(context).shared
                ],
                backgroundColor: Colors.white,
                indicatorColor: Color(0xFF00BFA5),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
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
                child: TabBarView(
                  children: [
                    _buildContent(folders, true, true),
                    _buildContent(folders, true, false),
                    _buildContent(folders, false, true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة لبناء المحتوى
  Widget _buildContent(
      List<Map<String, dynamic>> folders, bool showFolders, bool showFiles) {
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
                          icon: Icon(Icons.add_circle_outline,
                              color: Color(0xff28336f)),
                          tooltip: 'إنشاء غرفة مشاركة',
                          onPressed: () => _showCreateRoomPage(),
                        )
                      else
                        IconButton(
                          icon: Icon(Icons.create_new_folder,
                              color: Color(0xff28336f)),
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
                      
                      // ✅ تحديث التصنيفات بالقيم من Controller
                      final updatedCategories = folders.where((item) => item['type'] == 'category').map((category) {
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
                      
                      // ✅ دمج التصنيفات المحدثة مع المجلدات
                      final updatedFolders = [
                        ...updatedCategories,
                        ...folders.where((item) => item['type'] != 'category').toList(),
                      ];
                      
                      // ✅ تحديث folders في الـ state عند تغيير categoriesStats
                      if (_previousCategoriesStats.toString() != categoriesStats.toString()) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              folders = updatedFolders;
                            });
                          }
                        });
                        _previousCategoriesStats = Map<String, Map<String, dynamic>>.from(categoriesStats);
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
                                  builder: (context) => ChangeNotifierProvider.value(
                                    value: Provider.of<FolderController>(context, listen: false),
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
                      
                      // ✅ تحديث التصنيفات بالقيم من Controller
                      final updatedCategories = folders.where((item) => item['type'] == 'category').map((category) {
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
                      
                      // ✅ دمج التصنيفات المحدثة مع المجلدات
                      final updatedFolders = [
                        ...updatedCategories,
                        ...folders.where((item) => item['type'] != 'category').toList(),
                      ];
                      
                      // ✅ تحديث folders في الـ state عند تغيير categoriesStats
                      if (_previousCategoriesStats.toString() != categoriesStats.toString()) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              folders = updatedFolders;
                            });
                          }
                        });
                        _previousCategoriesStats = Map<String, Map<String, dynamic>>.from(categoriesStats);
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
                        final categoryTitle = item['title'] as String? ?? '';
                        final categoryColor = item['color'] as Color? ?? Colors.blue;
                        final categoryIcon = item['icon'] as IconData? ?? Icons.folder;
                        
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
                              builder: (context) => ChangeNotifierProvider.value(
                                value: Provider.of<FolderController>(context, listen: false),
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
                else if (sharedFolders.isNotEmpty) ...[
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
                      items: sharedFolders,
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
                                builder: (context) => ChangeNotifierProvider.value(
                                  value: Provider.of<FolderController>(context, listen: false),
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
                      items: sharedFolders,
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
                                builder: (context) => ChangeNotifierProvider.value(
                                  value: Provider.of<FolderController>(context, listen: false),
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
                    if (roomController.isLoading && roomController.rooms.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (roomController.errorMessage != null && roomController.rooms.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.red),
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
                              Icon(Icons.meeting_room_outlined,
                                  size: 64, color: Colors.grey),
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
                      final filesCount = (room['files'] as List?)?.length ?? 0;
                      return {
                        "title": room['name'] ?? 'بدون اسم',
                        "fileCount": filesCount, // ✅ عدد الملفات في الغرفة
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
                                builder: (context) => ChangeNotifierProvider.value(
                                  value: roomController,
                                  child: RoomDetailsPage(roomId: room['_id']),
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
                                builder: (context) => ChangeNotifierProvider.value(
                                  value: roomController,
                                  child: RoomDetailsPage(roomId: room['_id']),
                                ),
                              ),
                            );
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
  void _showCreateFolderDialog() {
    String newFolderName = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(S.of(context).createFolder),
          content: TextField(
            onChanged: (value) {
              newFolderName = value;
            },
            decoration: InputDecoration(
              hintText: S.of(context).folderNameHint,
            ),
          ),
          actions: [
            TextButton(
              child: Text(S.of(context).cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text(S.of(context).create),
              onPressed: () {
                if (newFolderName.isNotEmpty) {
                  setState(() {
                    folders.add({
                      "title": newFolderName,
                      "fileCount": 0,
                      "size": "0 GB",
                      "icon": Icons.folder,
                      "color": Colors.blueGrey,
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
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
      final roomController = Provider.of<RoomController>(context, listen: false);
      await roomController.getRooms();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم إنشاء الغرفة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
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
