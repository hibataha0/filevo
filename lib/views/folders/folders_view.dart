import 'package:filevo/views/folders/CategoryFiles.dart';
import 'package:flutter/material.dart';
import 'package:filevo/components/FilesGridView.dart';
import 'package:filevo/components/FilesListView.dart';
import 'package:filevo/components/FolderFileCard.dart';
import 'package:filevo/components/ViewToggleButtons.dart';
import 'package:filevo/responsive.dart';
import 'package:filevo/views/folders/components/filter_section.dart';
import 'package:filevo/views/folders/components/tab_bar.dart';
import 'package:filevo/generated/l10n.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }//dispose controller to free resources

  @override
  Widget build(BuildContext context) {
    final folders = [
  {
    "title": S.of(context).images,
    "fileCount": 156,
    "size": "2.3 GB",
    "icon": Icons.image,
    "color": Colors.blue
  },
  {
    "title": S.of(context).videos,
    "fileCount": 89,
    "size": "15.7 GB",
    "icon": Icons.videocam,
    "color": Colors.red
  },
  {
    "title": S.of(context).audio,
    "fileCount": 234,
    "size": "3.1 GB",
    "icon": Icons.audiotrack,
    "color": Colors.green
  },
  {
    "title": S.of(context).compressed,
    "fileCount": 45,
    "size": "8.2 GB",
    "icon": Icons.folder_zip,
    "color": Colors.orange
  },
  {
    "title": S.of(context).applications,
    "fileCount": 23,
    "size": "12.5 GB",
    "icon": Icons.apps,
    "color": Colors.purple
  },
  {
    "title": S.of(context).documents,
    "fileCount": 312,
    "size": "1.8 GB",
    "icon": Icons.description,
    "color": Colors.brown
  },
  {
    "title": S.of(context).code,
    "fileCount": 67,
    "size": "856 MB",
    "icon": Icons.code,
    "color": Colors.teal
  },
  {
    "title": S.of(context).other,
    "fileCount": 78,
    "size": "4.3 GB",
    "icon": Icons.more_horiz,
    "color": Colors.grey
  },
];


    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xff28336f),
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

              // خيارات الفلتر (تظهر/تختفي) - فوق الـ Tab Bar
              if (_showFilterOptions) FilterSection(
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
              
              // استخدام الـ Custom Tab Bar من الملف المنفصل
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
                    // Tab 1: All
                    _buildContent(folders, true, true),
                    // Tab 2: My Files
                    _buildContent(folders, true, false),
                    // Tab 3: Shared
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
  Widget _buildContent(List<Map<String, Object>> folders, bool showFolders, bool showFiles) {
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

              // العنوان وأزرار العرض
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

              SizedBox(height: 20),

              // عرض المجلدات فقط
              if (showFolders) ...[
                if (isFilesGridView)
                  FilesGridView(
                    items: folders,
                    showFileCount: true,
                    onItemTap: (item) {
                      // هنا يمكنك إضافة ما يحدث عند النقر على مجلد
                      print('تم النقر على المجلد: ${item['title']}');
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
                      

                    },
                  ),
                if (!isFilesGridView)
                  FilesListView(
                    items: folders,
                    itemMargin: EdgeInsets.only(bottom: 10),
                    showMoreOptions: true,
                    onItemTap: (item) {
                      // هنا يمكنك إضافة ما يحدث عند النقر على مجلد
                      print('تم النقر على المجلد: ${item['title']}');
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
                      

                    },
                  ),
              ],

              // عرض الملفات فقط
              if (showFiles && !showFolders) ...[
                Center(
                  child: Text(
                    S.of(context).sharedFilesContent,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],

              // المسافة الفارغة 100 بكسل
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
