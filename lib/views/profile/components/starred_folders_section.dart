import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/views/folders/starred_folders_page.dart';
import 'package:filevo/views/folders/folder_contents_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:shimmer/shimmer.dart';

class StarredFoldersSection extends StatefulWidget {
  const StarredFoldersSection({Key? key}) : super(key: key);

  @override
  State<StarredFoldersSection> createState() => _StarredFoldersSectionState();
}

class _StarredFoldersSectionState extends State<StarredFoldersSection> {
  @override
  void initState() {
    super.initState();
    _loadStarredFolders();
  }

  Future<void> _loadStarredFolders() async {
    if (mounted) {
      final controller = Provider.of<FolderController>(context, listen: false);
      await controller.getStarredFolders(limit: 6);
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes بايت';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} ك.ب';
    return '${(bytes / 1048576).toStringAsFixed(1)} م.ب';
  }

  // الانتقال لصفحة المجلدات المفضلة
  void _navigateToAllStarredFolders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StarredFoldersPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FolderController>(context);
    final starred = controller.starredFolders;

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
            "المجلدات المفضلة",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff28336f),
            ),
          ),
          if (starred.isNotEmpty)
            GestureDetector(
              onTap: () => _navigateToAllStarredFolders(context),
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

  Widget _buildContent(FolderController controller, List starred) {
    if (controller.isLoading && starred.isEmpty) {
      return _buildShimmerLoading();
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
          ...starred.take(6).map((folder) => _buildFavoriteItem(folder)),
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
            'لا توجد مجلدات مفضلة',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  // عنصر مفضلة فردي
  Widget _buildFavoriteItem(Map<String, dynamic> folder) {
    final name = folder['name'] as String? ?? 'بدون اسم';
    final fileCount = folder['filesCount'] ?? 0;
    final size = folder['size'] as int? ?? 0;
    final folderId = folder['_id'] as String?;

    String displayName = name;
    if (displayName.length > 15) {
      displayName = '${displayName.substring(0, 12)}...';
    }

    return GestureDetector(
      onTap: () {
        if (folderId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                value: Provider.of<FolderController>(context, listen: false),
                child: FolderContentsPage(
                  folderId: folderId,
                  folderName: name,
                  folderColor: const Color(0xff28336f),
                ),
              ),
            ),
          );
        }
      },
      onLongPress: () => _showFolderOptions(folder),
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
                Icon(
                  Icons.folder_rounded,
                  size: 32,
                  color: const Color(0xff28336f),
                ),
                const Positioned(
                  top: -2,
                  right: -2,
                  child: Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '$fileCount ملف',
              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
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
      onTap: () => _navigateToAllStarredFolders(context),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xff28336f),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
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

  // خيارات المجلد
  void _showFolderOptions(Map<String, dynamic> folder) {
    final name = folder['name'] as String? ?? 'بدون اسم';
    final fileCount = folder['filesCount'] ?? 0;
    final size = folder['size'] as int? ?? 0;

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
                leading: Icon(
                  Icons.folder_rounded,
                  color: const Color(0xff28336f),
                ),
                title: Text(name),
                subtitle: Text('$fileCount ملف • ${_formatBytes(size)}'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.open_in_new_rounded,
                  color: Colors.blue,
                ),
                title: Text(S.of(context).openFolder),
                onTap: () {
                  Navigator.pop(context);
                  final folderId = folder['_id'] as String?;
                  if (folderId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider.value(
                          value: Provider.of<FolderController>(
                            context,
                            listen: false,
                          ),
                          child: FolderContentsPage(
                            folderId: folderId,
                            folderName: name,
                            folderColor: const Color(0xff28336f),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.teal,
                ),
                title: Text(S.of(context).viewDetails),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.star_rounded, color: Colors.amber),
                title: Text(S.of(context).removeFromFavorites),
                onTap: () {
                  Navigator.pop(context);
                  _removeFromFavorites(folder);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _removeFromFavorites(Map<String, dynamic> folder) async {
    final folderId = folder['_id'];
    if (folderId == null) return;

    final controller = Provider.of<FolderController>(context, listen: false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(S.of(context).removingFromFavorites),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );

    final result = await controller.toggleStarFolder(folderId: folderId);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (result['success'] == true) {
      await controller.getStarredFolders(limit: 6);
      _showSnack('تمت الإزالة من المفضلة', Colors.green);
    } else {
      _showSnack(
        controller.errorMessage ?? 'فشل في الإزالة من المفضلة',
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

  // ✅ بناء shimmer loading لقسم المجلدات المفضلة
  Widget _buildShimmerLoading() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: List.generate(
          6,
          (index) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ Icon shimmer
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ✅ Text shimmer
                  Container(
                    width: double.infinity,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 60,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
