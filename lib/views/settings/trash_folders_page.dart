import 'package:filevo/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/controllers/profile/profile_controller.dart';

class TrashFoldersPage extends StatefulWidget {
  const TrashFoldersPage({super.key});

  @override
  State<TrashFoldersPage> createState() => _TrashFoldersPageState();
}

class _TrashFoldersPageState extends State<TrashFoldersPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    // عند فتح الصفحة — تحميل المجلدات المحذوفة
    Future.microtask(() {
      _loadTrashFolders(loadMore: false);
    });

    // سكرول لانهائي
    _scrollController.addListener(() {
      final controller = Provider.of<FolderController>(context, listen: false);

      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          controller.pagination["hasNext"] == true) {
        _loadTrashFolders(loadMore: true);
      }
    });
  }

  Future<void> _loadTrashFolders({bool loadMore = false}) async {
    if (loadMore) {
      setState(() {
        _isLoadingMore = true;
      });
    }

    final controller = Provider.of<FolderController>(context, listen: false);
    await controller.getTrashFolders(
      page: loadMore ? (controller.pagination["currentPage"] ?? 1) + 1 : 1,
      loadMore: loadMore,
    );

    if (loadMore) {
      setState(() {
        _isLoadingMore = false;
      });
    }

    if (controller.errorMessage != null && mounted && !loadMore) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ ${controller.errorMessage}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _restoreFolder(Map<String, dynamic> folder) async {
    final controller = Provider.of<FolderController>(context, listen: false);
    final profileController = Provider.of<ProfileController>(context, listen: false);
    final s = S.of(context); // ✅ مرجع الترجمة

    final result = await controller.restoreFolder(folderId: folder["_id"]);

    if (mounted) {
      if (result['success'] == true) {
        // ✅ تحديث معلومات المساحة بعد الاستعادة (سيتم التحديث تلقائياً من FolderController)
        profileController.getStorageInfo(forceRefresh: true);
        
        // ✅ بناء رسالة النجاح مع عدد الملفات المسترجعة
        final filesRestored = result['filesRestored'] as int? ?? 0;
        String successMessage = s.folderRestoredSuccess;
        
        if (filesRestored > 0) {
          successMessage += '\nتم استعادة $filesRestored ملف مع المجلد.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: filesRestored > 0 
              ? Duration(seconds: 4) 
              : Duration(seconds: 3),
          ),
        );
        _loadTrashFolders(loadMore: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 
              controller.errorMessage ?? 
              s.folderRestoredError
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _permanentDeleteFolder(Map<String, dynamic> folder) async {
    final controller = Provider.of<FolderController>(context, listen: false);
    final profileController = Provider.of<ProfileController>(context, listen: false);
    final s = S.of(context); // ✅ مرجع الترجمة

    final result = await controller.deleteFolderPermanent(
      folderId: folder["_id"],
    );

    if (mounted) {
      if (result['success'] == true) {
        // ✅ تحديث معلومات المساحة بعد الحذف النهائي
        profileController.getStorageInfo(forceRefresh: true);
        
        // ✅ بناء رسالة النجاح مع معلومات الـ Rooms إذا كانت موجودة
        String successMessage = s.folderPermanentDeleteSuccess;
        final warning = result['warning'];
        final roomsRemovedFrom = result['roomsRemovedFrom'] as List? ?? [];
        
        if (warning != null && warning.toString().isNotEmpty) {
          successMessage += '\n\n$warning';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: roomsRemovedFrom.isNotEmpty 
              ? Duration(seconds: 5) 
              : Duration(seconds: 3),
          ),
        );
        _loadTrashFolders(loadMore: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 
              controller.errorMessage ?? 
              s.folderPermanentDeleteError,
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showFolderActions(BuildContext context, Map<String, dynamic> folder) {
    final s = S.of(context); // ✅ مرجع الترجمة

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.green),
              title: Text(s.restoreFolder), // ✅ نص مترجم
              onTap: () {
                Navigator.pop(context);
                _restoreFolder(folder);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: Text(s.permanentDelete), // ✅ نص مترجم
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(folder);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> folder) {
    final s = S.of(context); // ✅ مرجع الترجمة

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.confirmFolderDeleteTitle), // ✅ عنوان مترجم
        content: Text(
          // ✅ نص مترجم مع تمرير اسم المجلد
          s.confirmFolderDeleteMessage(folder["name"] ?? ""),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel), // ✅ نص مترجم
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _permanentDeleteFolder(folder);
            },
            child: Text(
              s.permanentDelete, // ✅ نص مترجم
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString == '-') return '-';
    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context); // ✅ مرجع الترجمة

    return Consumer<FolderController>(
      builder: (context, folderController, child) {
        final folders = folderController.trashFolders;
        final isLoading = folderController.isLoading;
        final hasFolders = folders.isNotEmpty;

        return Scaffold(
          backgroundColor: const Color(0xff28336f),
          appBar: AppBar(
            backgroundColor: const Color(0xff28336f),
            title: Text(
              s.deletedFoldersTitle, // ✅ نص مترجم
              style: const TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              children: [
                // إحصائيات المهملات
                if (hasFolders)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.folder_delete,
                          s.foldersCount, // ✅ "المجلدات" مترجم
                          "${folders.length}",
                          Colors.orange,
                        ),
                        _buildStatItem(
                          Icons.schedule,
                          s.autoDeleteNoticeFolders, // ✅ نص مترجم
                          "",
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),

                // قائمة المجلدات
                Expanded(
                  child: isLoading && folders.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : !hasFolders
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.folder_delete_outlined,
                                size: 80,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                s.noDeletedFolders, // ✅ "لا يوجد مجلدات" مترجم
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(10),
                          child: GridView.builder(
                            controller: _scrollController,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.85,
                                ),
                            itemCount:
                                folders.length + (_isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == folders.length && _isLoadingMore) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final folder = folders[index];
                              return _buildTrashFolderCard(
                                context,
                                folder,
                                () => _showFolderActions(context, folder),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        if (value.isNotEmpty)
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// كرت واحد لمجلد محذوف
  Widget _buildTrashFolderCard(
    BuildContext context,
    Map<String, dynamic> folder,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // أيقونة المجلد
            Center(
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.folder, size: 30, color: Colors.orange),
              ),
            ),

            const SizedBox(height: 10),

            // اسم المجلد
            Text(
              folder["name"] ?? S.of(context).unnamedFolder,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            // تاريخ الحذف
            Text(
              // ✅ استخدام المتغير المترجم وتمرير التاريخ إليه
              S
                  .of(context)
                  .deletedAta(
                    _formatDate(folder['deletedAt']?.toString() ?? '-'),
                  ),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),

            const Spacer(),

            // أزرار الإجراءات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.restore, color: Colors.green),
                  onPressed: () => _restoreFolder(folder),
                  tooltip: S.of(context).restoreFolder,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(folder),
                  tooltip: S.of(context).permanentDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
