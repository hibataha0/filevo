import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/components/FolderFileCard.dart';
import 'package:filevo/components/FilesListView.dart';
import 'package:filevo/components/FilesGridView.dart';
import 'package:filevo/views/folders/folder_contents_page.dart';
import 'package:filevo/views/folders/share_folder_with_room_page.dart';
import 'package:filevo/views/fileViewer/folder_actions_service.dart';
import 'package:filevo/views/folders/starred_folders_page_helpers.dart';

class StarredFoldersPage extends StatefulWidget {
  const StarredFoldersPage({Key? key}) : super(key: key);

  @override
  State<StarredFoldersPage> createState() => _StarredFoldersPageState();
}

class _StarredFoldersPageState extends State<StarredFoldersPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = true;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _loadStarredFolders();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadStarredFolders() async {
    if (mounted) {
      final controller = Provider.of<FolderController>(context, listen: false);
      await controller.getStarredFolders();
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreFolders();
      }
    });
  }

  Future<void> _loadMoreFolders() async {
    if (mounted) {
      final controller = Provider.of<FolderController>(context, listen: false);
      if (!controller.isLoading) {
        await controller.getStarredFolders(loadMore: true);
      }
    }
  }

  Future<void> _refreshFolders() async {
    await _loadStarredFolders();
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes بايت';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} ك.ب';
    return '${(bytes / 1048576).toStringAsFixed(1)} م.ب';
  }

  void _handleFolderTap(Map<String, dynamic> folder) {
    final folderId = folder['folderId'] as String?;
    if (folderId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FolderContentsPage(
            folderId: folderId,
            folderName: folder['title'] as String? ?? 'مجلد',
            folderColor: folder['color'] as Color? ?? const Color(0xff28336f),
          ),
        ),
      );
    }
  }

  // ✅ Helper functions للتعامل مع إجراءات المجلد
  void _showFolderInfo(BuildContext context, Map<String, dynamic> folder) async {
    await showFolderInfoHelper(context, folder);
  }

  void _showRenameDialog(BuildContext context, Map<String, dynamic> folder) async {
    await showRenameDialogHelper(
      context, 
      folder, 
      () {
        // ✅ إعادة تحميل قائمة المفضلة بعد التحديث
        if (mounted) {
          final controller = Provider.of<FolderController>(context, listen: false);
          controller.getStarredFolders();
        }
      },
    );
  }

  void _showShareDialog(BuildContext context, Map<String, dynamic> folder) async {
    await showShareDialogHelper(context, folder);
  }

  void _showMoveFolderDialog(BuildContext context, Map<String, dynamic> folder) async {
    await showMoveFolderDialogHelper(context, folder);
  }

  void _toggleFavorite(BuildContext context, Map<String, dynamic> folder) async {
    final folderId = folder['folderId'] as String?;
    if (folderId == null) return;
    
    final folderController = Provider.of<FolderController>(context, listen: false);
    final result = await folderController.toggleStarFolder(folderId: folderId);
    
    if (result['success'] == true) {
      final isStarred = result['isStarred'] as bool? ?? false;
      
      // ✅ تحديث البيانات المحلية
      if (folder['folderData'] != null) {
        folder['folderData']['isStarred'] = isStarred;
      }
      
      // ✅ إعادة تحميل قائمة المفضلة
      await folderController.getStarredFolders();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isStarred 
              ? '✅ تم إضافة المجلد إلى المفضلة' 
              : '✅ تم إزالة المجلد من المفضلة',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> folder) {
    showDeleteDialogHelper(
      context, 
      folder, 
      () {
        // ✅ إعادة تحميل قائمة المفضلة بعد الحذف
        final controller = Provider.of<FolderController>(context, listen: false);
        controller.getStarredFolders();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FolderController>(
      builder: (context, folderController, child) {
        final starredFolders = folderController.starredFolders;

        // تحويل المجلدات إلى format مناسب للعرض
        final displayFolders = starredFolders.map((folder) {
          final name = folder['name'] as String? ?? 'بدون اسم';
          final size = folder['size'] as int? ?? 0;
          
          return {
            'title': name,
            'fileCount': folder['filesCount'] ?? 0,
            'size': _formatBytes(size),
            'icon': Icons.folder,
            'color': const Color(0xff28336f),
            'type': 'folder',
            'folderId': folder['_id'],
            'folderData': folder,
            'itemData': folder,
            'originalData': folder,
          };
        }).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'المجلدات المفضلة',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xff28336f),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(_isGridView ? Icons.list_rounded : Icons.grid_view_rounded),
                onPressed: () => setState(() => _isGridView = !_isGridView),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _refreshFolders,
              ),
            ],
          ),
          body: SmartRefresher(
            controller: _refreshController,
            onRefresh: () async {
              await _refreshFolders();
              _refreshController.refreshCompleted();
            },
            header: const WaterDropHeader(),
            child: folderController.isLoading && starredFolders.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xff28336f),
                    ),
                  )
                : starredFolders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star_border_rounded,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد مجلدات مفضلة',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'يمكنك إضافة المجلدات إلى المفضلة من خلال القائمة',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : _isGridView
                        ? GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: displayFolders.length,
                            itemBuilder: (context, index) {
                              final folder = displayFolders[index];
                              return GestureDetector(
                                onTap: () => _handleFolderTap(folder),
                                child: FolderFileCard(
                                  title: folder['title'] as String,
                                  fileCount: folder['fileCount'] as int,
                                  size: folder['size'] as String,
                                  showFileCount: true,
                                  color: folder['color'] as Color? ?? const Color(0xff28336f),
                                  folderData: folder['folderData'] as Map<String, dynamic>?,
                                  isStarred: folder['folderData']?['isStarred'] ?? true,
                                  onOpenTap: () => _handleFolderTap(folder),
                                  onInfoTap: () => _showFolderInfo(context, folder),
                                  onRenameTap: () => _showRenameDialog(context, folder),
                                  onShareTap: () => _showShareDialog(context, folder),
                                  onMoveTap: () => _showMoveFolderDialog(context, folder),
                                  onFavoriteTap: () => _toggleFavorite(context, folder),
                                  onDeleteTap: () => _showDeleteDialog(context, folder),
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: displayFolders.length,
                            itemBuilder: (context, index) {
                              final folder = displayFolders[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 12),
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.folder,
                                      color: folder['color'] as Color? ?? const Color(0xff28336f),
                                      size: 32,
                                    ),
                                    title: Text(
                                      folder['title'] as String,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${folder['fileCount']} ملف • ${folder['size']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      icon: Icon(Icons.more_vert),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 8,
                                      itemBuilder: (context) => [
                                        PopupMenuItem<String>(
                                          value: 'open',
                                          child: Row(
                                            children: [
                                              Icon(Icons.open_in_new, color: Colors.blue, size: 20),
                                              SizedBox(width: 8),
                                              Text('فتح'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'info',
                                          child: Row(
                                            children: [
                                              Icon(Icons.info_outline, color: Colors.teal, size: 20),
                                              SizedBox(width: 8),
                                              Text('عرض المعلومات'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'rename',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, color: Colors.orange, size: 20),
                                              SizedBox(width: 8),
                                              Text('تعديل'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'share',
                                          child: Row(
                                            children: [
                                              Icon(Icons.share, color: Colors.green, size: 20),
                                              SizedBox(width: 8),
                                              Text('مشاركة'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'move',
                                          child: Row(
                                            children: [
                                              Icon(Icons.drive_file_move_rounded, color: Colors.purple, size: 20),
                                              SizedBox(width: 8),
                                              Text('نقل'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'favorite',
                                          child: Row(
                                            children: [
                                              Icon(Icons.star, color: Colors.amber[700], size: 20),
                                              SizedBox(width: 8),
                                              Text('إزالة من المفضلة'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuDivider(),
                                        PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                              SizedBox(width: 8),
                                              Text('حذف', style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        switch (value) {
                                          case 'open':
                                            _handleFolderTap(folder);
                                            break;
                                          case 'info':
                                            _showFolderInfo(context, folder);
                                            break;
                                          case 'rename':
                                            _showRenameDialog(context, folder);
                                            break;
                                          case 'share':
                                            _showShareDialog(context, folder);
                                            break;
                                          case 'move':
                                            _showMoveFolderDialog(context, folder);
                                            break;
                                          case 'favorite':
                                            _toggleFavorite(context, folder);
                                            break;
                                          case 'delete':
                                            _showDeleteDialog(context, folder);
                                            break;
                                        }
                                      },
                                    ),
                                    onTap: () => _handleFolderTap(folder),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        );
      },
    );
  }
}

