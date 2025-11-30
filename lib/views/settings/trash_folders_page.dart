import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';

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
    
    final success = await controller.restoreFolder(
      folderId: folder["_id"],
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ تم استعادة المجلد بنجاح"),
          backgroundColor: Colors.green,
        ),
      );
      // تحديث القائمة
      _loadTrashFolders(loadMore: false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? "❌ فشل استعادة المجلد"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _permanentDeleteFolder(Map<String, dynamic> folder) async {
    final controller = Provider.of<FolderController>(context, listen: false);
    
    final success = await controller.deleteFolderPermanent(
      folderId: folder["_id"],
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ تم الحذف النهائي للمجلد بنجاح"),
          backgroundColor: Colors.red,
        ),
      );
      // تحديث القائمة
      _loadTrashFolders(loadMore: false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? "❌ فشل الحذف النهائي للمجلد"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFolderActions(BuildContext context, Map<String, dynamic> folder) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.green),
              title: const Text("استعادة المجلد"),
              onTap: () {
                Navigator.pop(context);
                _restoreFolder(folder);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("حذف نهائي"),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف النهائي"),
        content: Text("هل أنت متأكد من الحذف النهائي للمجلد '${folder["name"]}'؟ لا يمكن التراجع عن هذا الإجراء. سيتم حذف جميع الملفات والمجلدات الفرعية نهائياً."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _permanentDeleteFolder(folder);
            },
            child: const Text("حذف نهائي", style: TextStyle(color: Colors.red)),
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
    return Consumer<FolderController>(
      builder: (context, folderController, child) {
        final folders = folderController.trashFolders;
        final isLoading = folderController.isLoading;
        final hasFolders = folders.isNotEmpty;

        return Scaffold(
          backgroundColor: const Color(0xff28336f),
          appBar: AppBar(
            backgroundColor: const Color(0xff28336f),
            title: const Text(
              "المجلدات المحذوفة",
              style: TextStyle(color: Colors.white),
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
                          "المجلدات",
                          "${folders.length}",
                          Colors.orange,
                        ),
                        _buildStatItem(
                          Icons.schedule,
                          "سيتم حذفها تلقائياً بعد 30 يوم",
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
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.folder_delete_outlined, size: 80, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    "لا يوجد مجلدات محذوفة",
                                    style: TextStyle(fontSize: 18, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: GridView.builder(
                                      controller: _scrollController,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                        childAspectRatio: 0.85,
                                      ),
                                      itemCount: folders.length + (_isLoadingMore ? 1 : 0),
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
                                ],
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

  Widget _buildStatItem(IconData icon, String title, String value, Color color) {
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
            )
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
              folder["name"] ?? "مجلد بدون اسم",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            // تاريخ الحذف
            Text(
              "تم الحذف: ${_formatDate(folder['deletedAt']?.toString())}",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),

            const Spacer(),

            // أزرار الإجراءات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.restore, color: Colors.green),
                  onPressed: () => _restoreFolder(folder),
                  tooltip: "استعادة",
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(folder),
                  tooltip: "حذف نهائي",
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

