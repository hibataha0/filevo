import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:filevo/views/profile/favorites_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/services/storage_service.dart';

class FavoritesSection extends StatefulWidget {
  const FavoritesSection({Key? key}) : super(key: key);

  @override
  State<FavoritesSection> createState() => _FavoritesSectionState();
}

class _FavoritesSectionState extends State<FavoritesSection> {
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFiles();
  }

  Future<void> _loadTokenAndFiles() async {
    _token = await StorageService.getToken();
    if (_token != null && mounted) {
      final controller = Provider.of<FileController>(context, listen: false);
      await controller.getStarredFiles(token: _token!, limit: 6);
    }
  }

  // تحديد نوع الملف
  Map<String, dynamic> _getFileInfo(Map<String, dynamic> file) {
    final fileName = (file['name'] ?? '').toString().toLowerCase();
    final fileSize = file['size']?.toString() ?? '0';

    IconData icon;
    Color color;

    if (fileName.endsWith('.pdf')) {
      icon = Icons.picture_as_pdf_rounded;
      color = Colors.red;
    } else if (_isImage(fileName)) {
      icon = Icons.image_rounded;
      color = Colors.green;
    } else if (_isVideo(fileName)) {
      icon = Icons.videocam_rounded;
      color = Colors.blue;
    } else if (_isAudio(fileName)) {
      icon = Icons.audiotrack_rounded;
      color = Colors.purple;
    } else if (_isWord(fileName)) {
      icon = Icons.description_rounded;
      color = Colors.blue.shade700;
    } else if (_isExcel(fileName)) {
      icon = Icons.table_chart_rounded;
      color = Colors.green.shade700;
    } else if (_isPowerPoint(fileName)) {
      icon = Icons.slideshow_rounded;
      color = Colors.orange;
    } else {
      icon = Icons.insert_drive_file_rounded;
      color = Colors.grey;
    }

    String displayName = file['name'] ?? 'ملف بدون اسم';
    if (displayName.length > 15) {
      displayName = '${displayName.substring(0, 12)}...';
    }

    return {
      'icon': icon,
      'color': color,
      'displayName': displayName,
      'fileName': file['name'],
      'fileSize': fileSize,
      'fileUrl': file['path'] ?? file['url'],
    };
  }

  bool _isImage(String name) =>
      name.endsWith('.jpg') || name.endsWith('.jpeg') || name.endsWith('.png') || name.endsWith('.gif');

  bool _isVideo(String name) =>
      name.endsWith('.mp4') || name.endsWith('.mov') || name.endsWith('.avi') || name.endsWith('.mkv');

  bool _isAudio(String name) =>
      name.endsWith('.mp3') || name.endsWith('.wav') || name.endsWith('.aac');

  bool _isWord(String name) =>
      name.endsWith('.doc') || name.endsWith('.docx');

  bool _isExcel(String name) =>
      name.endsWith('.xls') || name.endsWith('.xlsx');

  bool _isPowerPoint(String name) =>
      name.endsWith('.ppt') || name.endsWith('.pptx');

  // الانتقال لصفحة المفضلة
  void _navigateToAllFavorites(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => FavoritesPage()));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FileController>(context);
    final starred = controller.starredFiles ?? [];

    return Container(
      margin: const EdgeInsets.only(top: 25, bottom: 15),
      child: Column(
        children: [
          _buildHeader(starred),
          const SizedBox(height: 15),
          _buildContent(controller, starred),
        ],
      ),
    );
  }

  Widget _buildHeader(List starred) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "الملفات المفضلة",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff28336f),
            ),
          ),

          if (starred.isNotEmpty)
            GestureDetector(
              onTap: () => _navigateToAllFavorites(context),
              child: const Text(
                "عرض الكل",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff28336f),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(FileController controller, List starred) {
    if (controller.isLoading && starred.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(
            color: const Color(0xff28336f),
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (starred.isEmpty) {
      return Container(
        height: 120,
        decoration: _emptyBox(),
        child: _emptyContent(),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          const SizedBox(width: 8),
          ...starred.take(6).map((file) {
            final fileInfo = _getFileInfo(file);
            return _buildFavoriteItem(fileInfo, file);
          }),
          if (starred.length > 6) _buildViewAllCard(context),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  BoxDecoration _emptyBox() {
    return BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[200]!),
    );
  }

  Widget _emptyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border_rounded, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'لا توجد ملفات مفضلة',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // عنصر مفضلة فردي
  Widget _buildFavoriteItem(Map<String, dynamic> info, Map<String, dynamic> file) {
    return GestureDetector(
      onTap: () => _showFileOptions(info, file),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: _itemBox(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Icon(info['icon'], size: 32, color: info['color']),
                const Positioned(
                  top: -2,
                  right: -2,
                  child: Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              info['displayName'],
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.2),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _itemBox() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
      ],
    );
  }

  // بطاقة "عرض الكل"
  Widget _buildViewAllCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToAllFavorites(context),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xff28336f),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.arrow_forward_rounded, size: 32, color: Colors.white),
            SizedBox(height: 8),
            Text(
              'عرض\nالكل',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // خيارات الملف
  void _showFileOptions(info, file) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(info['icon'], color: info['color']),
                title: Text(info['fileName']),
                subtitle: Text(_formatFileSize(info['fileSize'])),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.open_in_new_rounded, color: Colors.blue),
                title: const Text('فتح الملف'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded, color: Colors.teal),
                title: const Text('عرض التفاصيل'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.star_rounded, color: Colors.amber),
                title: const Text('إزالة من المفضلة'),
                onTap: () {
                  Navigator.pop(context);
                  _removeFromFavorites(file);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _removeFromFavorites(file) async {
    final fileId = file['_id'];
    if (fileId == null || _token == null) return;

    final controller = Provider.of<FileController>(context, listen: false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
            ),
            SizedBox(width: 12),
            Text('جاري إزالة من المفضلة...'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );

    final result = await controller.toggleStar(fileId: fileId, token: _token!);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (result['success'] == true) {
      final isStarred = result['isStarred'] as bool? ?? false;
      // ✅ لا حاجة لإعادة تحميل القائمة - التحديث يحدث تلقائياً في toggleStar
      _showSnack(
        isStarred
          ? '✅ تم إضافة الملف إلى المفضلة'
          : '✅ تم إزالة الملف من المفضلة',
        Colors.green,
      );
    } else {
      _showSnack(
        result['message'] ?? 'فشل في تحديث حالة المفضلة',
        Colors.red,
      );
    }
  }

  void _showSnack(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatFileSize(String size) {
    final bytes = int.tryParse(size) ?? 0;
    if (bytes < 1024) return '$bytes بايت';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} ك.ب';
    return '${(bytes / 1048576).toStringAsFixed(1)} م.ب';
  }
}
