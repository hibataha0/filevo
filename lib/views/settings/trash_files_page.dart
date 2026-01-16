import 'package:filevo/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:filevo/controllers/profile/profile_controller.dart';
import 'package:filevo/constants/app_colors.dart';

class TrashFilesPage extends StatefulWidget {
  final String token;

  const TrashFilesPage({super.key, required this.token});

  @override
  State<TrashFilesPage> createState() => _TrashFilesPageState();
}

class _TrashFilesPageState extends State<TrashFilesPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    // عند فتح الصفحة — تحميل الملفات المحذوفة
    Future.microtask(() {
      _loadTrashFiles(loadMore: false);
    });

    // سكرول لانهائي
    _scrollController.addListener(() {
      final controller = Provider.of<FileController>(context, listen: false);

      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          controller.pagination["hasNext"] == true) {
        _loadTrashFiles(loadMore: true);
      }
    });
  }

  Future<void> _loadTrashFiles({bool loadMore = false}) async {
    if (loadMore) {
      setState(() {
        _isLoadingMore = true;
      });
    }

    final controller = Provider.of<FileController>(context, listen: false);
    await controller.getTrashFiles(
      token: widget.token,
      page: loadMore ? (controller.pagination["currentPage"] ?? 1) + 1 : 1,
      loadMore: loadMore,
    );

    if (loadMore) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _restoreFile(String fileId) async {
    final controller = Provider.of<FileController>(context, listen: false);
    final profileController = Provider.of<ProfileController>(context, listen: false);

    final success = await controller.restoreFiles(
      fileIds: [fileId],
      token: widget.token,
    );

    if (success && mounted) {
      // ✅ تحديث معلومات المساحة بعد الاستعادة (سيتم التحديث تلقائياً من FileController)
      profileController.getStorageInfo(forceRefresh: true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).fileRestoredSuccess),
          backgroundColor: AppColors.success,
        ),
      );
      
      // ✅ تحديث القائمة
      setState(() {});
    }
  }

  Future<void> _permanentDeleteFile(String fileId) async {
    final controller = Provider.of<FileController>(context, listen: false);

    final result = await controller.permanentDelete(
      fileIds: [fileId],
      token: widget.token,
    );

    if (result && mounted) {
      // ✅ تحديث معلومات المساحة بعد الحذف النهائي (سيتم التحديث تلقائياً من FileController)
      final profileController = Provider.of<ProfileController>(context, listen: false);
      profileController.getStorageInfo(forceRefresh: true);
      
      // ✅ ملاحظة: FileController.permanentDelete لا يزال يرجع bool
      // ✅ في المستقبل يمكن تحديثه لعرض warning و roomsRemovedFrom
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).fileDeletedPermanently),
          backgroundColor: AppColors.error,
        ),
      );
      
      // ✅ تحديث القائمة
      setState(() {});
    }
  }

  // Future<void> _emptyTrash() async {
  //   final controller = Provider.of<FileController>(context, listen: false);

  //   final success = await controller.emptyTrash(
  //     token: widget.token,
  //   );

  //   if (success && mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("تم إفراغ سلة المحذوفات بنجاح"),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   }
  // }

  void _showFileActions(BuildContext context, Map<String, dynamic> file) {
    final s = S.of(context);
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
              title: Text(s.restoreFile), // ✅ نص مترجم
              onTap: () {
                Navigator.pop(context);
                _restoreFile(file["_id"]);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: Text(s.permanentDelete), // ✅ نص مترجم
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> file) {
    final s = S.of(context);
    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: AppColors.getCardColor(isDarkMode),
          title: Text(
            s.confirmDeleteTitle,
            style: TextStyle(
              color: AppColors.getTextPrimary(isDarkMode),
            ),
          ),
          content: Text(
            // ✅ نص مترجم مع تمرير اسم الملف ديناميكياً
            s.confirmDeleteMessage(file["name"] ?? ""),
            style: TextStyle(
              color: AppColors.getTextPrimary(isDarkMode),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                s.cancel,
                style: TextStyle(
                  color: AppColors.getTextSecondary(isDarkMode),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _permanentDeleteFile(file["_id"]);
              },
              child: Text(
                s.permanentDelete,
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEmptyTrashConfirmation() {
    final s = S.of(context);

    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: AppColors.getCardColor(isDarkMode),
          title: Text(
            s.emptyTrashTitle,
            style: TextStyle(
              color: AppColors.getTextPrimary(isDarkMode),
            ),
          ),
          content: Text(
            s.emptyTrashMessage,
            style: TextStyle(
              color: AppColors.getTextPrimary(isDarkMode),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                s.cancel,
                style: TextStyle(
                  color: AppColors.getTextSecondary(isDarkMode),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigator.pop(context); // إغلاق الديالوج أولاً
                // _emptyTrash(); // استدعاء دالة الإفراغ
              },
              child: Text(
                s.empty,
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String dateString) {
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

    return Consumer<FileController>(
      builder: (context, fileController, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final files = fileController.trashFiles;
        final isLoading = fileController.isLoading;
        final hasFiles = files.isNotEmpty;

        return Scaffold(
          backgroundColor: AppColors.getAppBar(isDarkMode),
          appBar: AppBar(
            backgroundColor: AppColors.getAppBar(isDarkMode),
            title: Text(
              s.trashTitle, // ✅ نص مترجم
              style: const TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            actions: [
              if (hasFiles)
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: _showEmptyTrashConfirmation,
                  tooltip: s.emptyTrash, // ✅ تلميح مترجم
                ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              color: AppColors.getBackground(isDarkMode),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              children: [
                // إحصائيات المهملات
                if (hasFiles)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.getCardColor(isDarkMode),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.darkSurface,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.delete,
                          s.filesCount, // ✅ "الملفات" مترجم
                          "${files.length}",
                          Colors.red,
                        ),
                        _buildStatItem(
                          Icons.schedule,
                          s.autoDeleteNotice, // ✅ "حذف تلقائي" مترجم
                          "",
                          AppColors.warning,
                        ),
                      ],
                    ),
                  ),

                // قائمة الملفات
                Expanded(
                  child: isLoading && files.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : !hasFiles
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 80,
                                color: AppColors.getTextSecondary(isDarkMode),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                s.noDeletedFiles, // ✅ "لا يوجد ملفات" مترجم
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.getTextPrimary(isDarkMode),
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
                            itemCount: files.length + (_isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == files.length && _isLoadingMore) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final file = files[index];
                              return _buildTrashFileCard(
                                context,
                                file,
                                () => _showFileActions(context, file),
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

  Widget _buildTrashFileCard(
    BuildContext context,
    Map<String, dynamic> file,
    VoidCallback onTap,
  ) {
    final s = S.of(context); // ✅ مرجع الترجمة

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.getCardColor(
            Theme.of(context).brightness == Brightness.dark,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadow(
                Theme.of(context).brightness == Brightness.dark,
              ),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // أيقونة الملف حسب النوع
            Center(child: _buildFileIcon(file)),

            const SizedBox(height: 10),

            // اسم الملف
            Text(
              file["name"] ?? s.unnamedFile, // ✅ نص مترجم للملفات بدون اسم
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            // حجم الملف
            if (file["size"] != null)
              Text(
                _formatFileSize(file["size"]),
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),

            // تاريخ الحذف
            Text(
              // ✅ نص مترجم ديناميكي يعرض التاريخ
              s.deletedAt(_formatDate(file['deletedAt'] ?? '-')),
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),

            const Spacer(),

            // أزرار الإجراءات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.restore,
                    color: AppColors.success,
                    size: 20,
                  ),
                  onPressed: () => _restoreFile(file["_id"]),
                  tooltip: s.restore, // ✅ تلميح مترجم
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_forever,
                    color: AppColors.error,
                    size: 20,
                  ),
                  onPressed: () => _showDeleteConfirmation(file),
                  tooltip: s.permanentDelete, // ✅ تلميح مترجم
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileIcon(Map<String, dynamic> file) {
    final String? mimeType = file["mimeType"]?.toString().toLowerCase();
    final String? name = file["name"]?.toString().toLowerCase();

    IconData icon;
    Color color;

    if (mimeType?.startsWith('image/') == true ||
        name?.endsWith('.jpg') == true ||
        name?.endsWith('.png') == true ||
        name?.endsWith('.jpeg') == true) {
      icon = Icons.image;
      color = Colors.green;
    } else if (mimeType?.startsWith('video/') == true ||
        name?.endsWith('.mp4') == true ||
        name?.endsWith('.avi') == true) {
      icon = Icons.video_file;
      color = Colors.purple;
    } else if (mimeType?.startsWith('audio/') == true ||
        name?.endsWith('.mp3') == true) {
      icon = Icons.audio_file;
      color = Colors.blue;
    } else if (mimeType?.contains('pdf') == true ||
        name?.endsWith('.pdf') == true) {
      icon = Icons.picture_as_pdf;
      color = Colors.red;
    } else if (mimeType?.contains('word') == true ||
        name?.endsWith('.doc') == true ||
        name?.endsWith('.docx') == true) {
      icon = Icons.description;
      color = Colors.blue;
    } else {
      icon = Icons.insert_drive_file;
      color = Colors.grey;
    }

    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 30, color: color),
    );
  }

  String _formatFileSize(dynamic size) {
    try {
      final bytes = int.tryParse(size.toString()) ?? 0;
      if (bytes < 1024) return '$bytes ${S.of(context).bytes}';
      if (bytes < 1048576)
        return '${(bytes / 1024).toStringAsFixed(1)} ${S.of(context).kb}';
      return '${(bytes / 1048576).toStringAsFixed(1)} ${S.of(context).mb}';
    } catch (e) {
      return '0 ${S.of(context).bytes}';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
