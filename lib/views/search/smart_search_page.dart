import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/ai_search_controller.dart';
import 'package:filevo/constants/app_colors.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:filevo/responsive.dart';

class SmartSearchPage extends StatefulWidget {
  const SmartSearchPage({super.key});

  @override
  State<SmartSearchPage> createState() => _SmartSearchPageState();
}

class _SmartSearchPageState extends State<SmartSearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _selectedScope = 'all';

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
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('أدخل نص البحث'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final searchController = Provider.of<AiSearchController>(context, listen: false);
    final success = await searchController.search(
      query: _searchController.text.trim(),
      scope: _selectedScope,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(searchController.errorMessage ?? 'فشل البحث'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('البحث الذكي'),
        backgroundColor: isDarkMode ? AppColors.darkAppBar : AppColors.lightAppBar,
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
                                  Provider.of<AiSearchController>(context, listen: false)
                                    .clearResults();
                                  setState(() {});
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
              Builder(
                builder: (context) {
                  final controller = Provider.of<AiSearchController>(context, listen: true);
                  return TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                        text: 'الكل (${controller.totalResults})',
                        icon: Icon(Icons.grid_view),
                      ),
                      Tab(
                        text: 'ملفات (${controller.filesCount})',
                        icon: Icon(Icons.insert_drive_file),
                      ),
                      Tab(
                        text: 'رومات (${controller.roomsCount})',
                        icon: Icon(Icons.meeting_room),
                      ),
                      Tab(
                        text: 'مجلدات (${controller.foldersCount})',
                        icon: Icon(Icons.folder),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Consumer<AiSearchController>(
        builder: (context, searchController, child) {
          if (searchController.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (searchController.searchResults == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ابحث في ملفاتك، روماتك، ومجلداتك',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'مثال: "صور من الأسبوع الماضي"',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          if (searchController.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    searchController.errorMessage!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAllResults(searchController),
              _buildFilesResults(searchController.files),
              _buildRoomsResults(searchController.rooms),
              _buildFoldersResults(searchController.folders),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScopeChip(String value, String label, IconData icon) {
    final isSelected = _selectedScope == value;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          SizedBox(width: 4),
          Text(label),
        ],
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
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
      ),
    );
  }

  Widget _buildAllResults(AiSearchController controller) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        if (controller.filesCount > 0) ...[
          _buildSectionHeader('الملفات', controller.filesCount, Icons.insert_drive_file),
          SizedBox(height: 8),
          ...controller.files.take(5).map((file) => _buildFileItem(file)),
          if (controller.filesCount > 5)
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: Text('عرض كل الملفات (${controller.filesCount})'),
            ),
          SizedBox(height: 16),
        ],
        if (controller.roomsCount > 0) ...[
          _buildSectionHeader('الرومات', controller.roomsCount, Icons.meeting_room),
          SizedBox(height: 8),
          ...controller.rooms.take(5).map((room) => _buildRoomItem(room)),
          if (controller.roomsCount > 5)
            TextButton(
              onPressed: () => _tabController.animateTo(2),
              child: Text('عرض كل الرومات (${controller.roomsCount})'),
            ),
          SizedBox(height: 16),
        ],
        if (controller.foldersCount > 0) ...[
          _buildSectionHeader('المجلدات', controller.foldersCount, Icons.folder),
          SizedBox(height: 8),
          ...controller.folders.take(5).map((folder) => _buildFolderItem(folder)),
          if (controller.foldersCount > 5)
            TextButton(
              onPressed: () => _tabController.animateTo(3),
              child: Text('عرض كل المجلدات (${controller.foldersCount})'),
            ),
          SizedBox(height: 16),
        ],
        if (controller.commentsCount > 0) ...[
          _buildSectionHeader('التعليقات', controller.commentsCount, Icons.comment),
          SizedBox(height: 8),
          ...controller.comments.take(5).map((comment) => _buildCommentItem(comment)),
        ],
      ],
    );
  }

  Widget _buildFilesResults(List<Map<String, dynamic>> files) {
    if (files.isEmpty) {
      return Center(
        child: Text('لا توجد ملفات'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: files.length,
      itemBuilder: (context, index) => _buildFileItem(files[index]),
    );
  }

  Widget _buildRoomsResults(List<Map<String, dynamic>> rooms) {
    if (rooms.isEmpty) {
      return Center(
        child: Text('لا توجد رومات'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: rooms.length,
      itemBuilder: (context, index) => _buildRoomItem(rooms[index]),
    );
  }

  Widget _buildFoldersResults(List<Map<String, dynamic>> folders) {
    if (folders.isEmpty) {
      return Center(
        child: Text('لا توجد مجلدات'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: folders.length,
      itemBuilder: (context, index) => _buildFolderItem(folders[index]),
    );
  }

  Widget _buildSectionHeader(String title, int count, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent),
        SizedBox(width: 8),
        Text(
          '$title ($count)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFileItem(Map<String, dynamic> file) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      color: isDarkMode ? AppColors.darkCardBackground : Colors.white,
      child: ListTile(
        leading: Icon(Icons.insert_drive_file, color: AppColors.accent),
        title: Text(file['name'] ?? 'ملف غير معروف'),
        subtitle: Text(
          '${file['category'] ?? 'غير محدد'} • ${_formatSize(file['size'])}',
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to file details
        },
      ),
    );
  }

  Widget _buildRoomItem(Map<String, dynamic> room) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      color: isDarkMode ? AppColors.darkCardBackground : Colors.white,
      child: ListTile(
        leading: Icon(Icons.meeting_room, color: AppColors.accent),
        title: Text(room['name'] ?? 'روم غير معروف'),
        subtitle: Text(room['description'] ?? ''),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to room details
        },
      ),
    );
  }

  Widget _buildFolderItem(Map<String, dynamic> folder) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      color: isDarkMode ? AppColors.darkCardBackground : Colors.white,
      child: ListTile(
        leading: Icon(Icons.folder, color: AppColors.accent),
        title: Text(folder['name'] ?? 'مجلد غير معروف'),
        subtitle: Text('${_formatSize(folder['size'])}'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to folder details
        },
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      color: isDarkMode ? AppColors.darkCardBackground : Colors.white,
      child: ListTile(
        leading: Icon(Icons.comment, color: AppColors.accent),
        title: Text(comment['content'] ?? ''),
        subtitle: Text(
          '${comment['user']?['name'] ?? 'مستخدم'} • ${comment['room']?['name'] ?? ''}',
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to comment context
        },
      ),
    );
  }

  String _formatSize(dynamic size) {
    if (size == null) return '—';
    try {
      final bytes = size is int ? size : int.tryParse(size.toString()) ?? 0;
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
      return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    } catch (e) {
      return '—';
    }
  }
}

