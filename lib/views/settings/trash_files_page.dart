import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/files_controller.dart';

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
    
    final success = await controller.restoreFiles(
      fileIds: [fileId],
      token: widget.token,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم استعادة الملف بنجاح"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _permanentDeleteFile(String fileId) async {
    final controller = Provider.of<FileController>(context, listen: false);
    
    final success = await controller.permanentDelete(
      fileIds: [fileId],
      token: widget.token,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم الحذف النهائي للملف بنجاح"),
          backgroundColor: Colors.red,
        ),
      );
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
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.green),
              title: const Text("استعادة الملف"),
              onTap: () {
                // Navigator.pop(context);
                // _restoreFile(file["_id"]);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("حذف نهائي"),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف النهائي"),
        content: Text("هل أنت متأكد من الحذف النهائي للملف '${file["name"]}'؟ لا يمكن التراجع عن هذا الإجراء."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _permanentDeleteFile(file["_id"]);
            },
            child: const Text("حذف نهائي", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEmptyTrashConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إفراغ سلة المحذوفات"),
        content: const Text("هل أنت متأكد من إفراغ سلة المحذوفات؟ سيتم حذف جميع الملفات نهائياً ولا يمكن استعادتها."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              // Navigator.pop(context);
              // _emptyTrash();
            },
            child: const Text("إفراغ", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
    return Consumer<FileController>(
      builder: (context, fileController, child) {
        final files = fileController.trashFiles;
        final isLoading = fileController.isLoading;
        final hasFiles = files.isNotEmpty;

        print('Building TrashFilesPage with ${files.length} files, isLoading: $isLoading');

        return Scaffold(
          backgroundColor: const Color(0xff28336f),
          appBar: AppBar(
            backgroundColor: const Color(0xff28336f),
            title: const Text(
              "سلة المحذوفات",
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            actions: [
              if (hasFiles)
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: _showEmptyTrashConfirmation,
                  tooltip: "إفراغ السلة",
                ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              children: [
                // إحصائيات المهملات
                if (hasFiles)
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
                          Icons.delete,
                          "الملفات",
                          "${files.length}",
                          Colors.red,
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

                // قائمة الملفات
                Expanded(
                  child: isLoading && files.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : !hasFiles
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete_outline, size: 80, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    "لا يوجد ملفات محذوفة",
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

  /// كرت واحد لملف محذوف
  Widget _buildTrashFileCard(
    BuildContext context,
    Map<String, dynamic> file,
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
            // أيقونة الملف حسب النوع
            Center(
              child: _buildFileIcon(file),
            ),

            const SizedBox(height: 10),

            // اسم الملف
            Text(
              file["name"] ?? "ملف بدون اسم",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            // حجم الملف
            if (file["size"] != null)
              Text(
                _formatFileSize(file["size"]),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),

            // تاريخ الحذف
            Text(
              "تم الحذف: ${_formatDate(file['deletedAt'] ?? '-')}",
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
                  onPressed: () => _restoreFile(file["_id"]),
                  tooltip: "استعادة",
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(file),
                  tooltip: "حذف نهائي",
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
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    } catch (e) {
      return '0 B';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}