import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/views/folders/starred_folders_page.dart';
import 'package:filevo/views/folders/folder_contents_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:shimmer/shimmer.dart';
import 'package:filevo/constants/app_colors.dart';

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
    if (bytes < 1024) return '$bytes ${S.of(context).unitBytes}';
    if (bytes < 1048576)
      return '${(bytes / 1024).toStringAsFixed(1)} ${S.of(context).unitKB}';
    return '${(bytes / 1048576).toStringAsFixed(1)} ${S.of(context).unitMB}';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            S.of(context).starredFolders,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getPrimary(isDarkMode),
            ),
          ),
          if (starred.isNotEmpty)
            GestureDetector(
              onTap: () => _navigateToAllStarredFolders(context),
              child: Text(
                S.of(context).viewAll,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getPrimary(isDarkMode),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDarkMode ? AppColors.darkSurface : Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDarkMode 
            ? AppColors.darkSurface 
            : Colors.grey[200]!,
      ),
    );
  }

  Widget _emptyContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border_rounded,
            size: 40,
            color: AppColors.getTextSecondary(isDarkMode),
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).noFavoriteFolders,
            style: TextStyle(
              color: AppColors.getTextSecondary(isDarkMode),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // عنصر مفضلة فردي
  Widget _buildFavoriteItem(Map<String, dynamic> folder) {
    final name = folder['name'] as String? ?? S.of(context).unnamedfile;
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
                  color: AppColors.getPrimary(
                    Theme.of(context).brightness == Brightness.dark,
                  ),
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
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.2,
                color: AppColors.getTextPrimary(
                  Theme.of(context).brightness == Brightness.dark,
                ),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '$fileCount ${S.of(context).files}',
              style: TextStyle(
                fontSize: 9,
                color: AppColors.getTextSecondary(
                  Theme.of(context).brightness == Brightness.dark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _itemBox() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: AppColors.getCardColor(isDarkMode),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.getShadow(isDarkMode),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  // بطاقة "عرض الكل"
  Widget _buildViewAllCard(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _navigateToAllStarredFolders(context),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.getPrimary(isDarkMode),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadow(isDarkMode),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_forward_rounded, size: 32, color: Colors.white),
            SizedBox(height: 8),
            Text(
              S.of(context).viewAll,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final name = folder['name'] as String? ?? S.of(context).unnamedFolder;
    final fileCount = folder['filesCount'] ?? 0;
    final size = folder['size'] as int? ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.getCardColor(isDarkMode),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.folder_rounded,
                    color: AppColors.getPrimary(isDarkMode),
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      color: AppColors.getTextPrimary(isDarkMode),
                    ),
                  ),
                  subtitle: Text(
                    '$fileCount ${S.of(context).files} • ${_formatBytes(size)}',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(isDarkMode),
                    ),
                  ),
                ),
                Divider(
                  color: isDarkMode 
                      ? AppColors.darkSurface 
                      : Colors.grey[300],
                ),
                ListTile(
                  leading: Icon(
                    Icons.open_in_new_rounded,
                    color: AppColors.getPrimary(isDarkMode),
                  ),
                  title: Text(
                    S.of(context).openFolder,
                    style: TextStyle(
                      color: AppColors.getTextPrimary(isDarkMode),
                    ),
                  ),
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
                              folderColor: AppColors.getPrimary(isDarkMode),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.getTextSecondary(isDarkMode),
                  ),
                  title: Text(
                    S.of(context).viewDetails,
                    style: TextStyle(
                      color: AppColors.getTextPrimary(isDarkMode),
                    ),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.star_rounded, color: Colors.amber),
                  title: Text(
                    S.of(context).removeFromFavorites,
                    style: TextStyle(
                      color: AppColors.getTextPrimary(isDarkMode),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeFromFavorites(folder);
                  },
                ),
              ],
            ),
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
        backgroundColor: AppColors.getPrimary(
          Theme.of(context).brightness == Brightness.dark,
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    final result = await controller.toggleStarFolder(folderId: folderId);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (result['success'] == true) {
      await controller.getStarredFolders(limit: 6);
      _showSnack(
        S.of(context).removedFromFavorites, // ✅ نص مترجم
        AppColors.success,
      );
    } else {
      _showSnack(
        controller.errorMessage ??
            S.of(context).failedToRemoveFromFavorites, // ✅ نص مترجم
        AppColors.error,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: List.generate(
          6,
          (index) => Shimmer.fromColors(
            baseColor: AppColors.getShimmerBase(isDarkMode),
            highlightColor: AppColors.getShimmerHighlight(isDarkMode),
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.getCardColor(isDarkMode),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getShadow(isDarkMode),
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
                      color: AppColors.getShimmerBase(isDarkMode),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ✅ Text shimmer
                  Container(
                    width: double.infinity,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.getShimmerBase(isDarkMode),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 60,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.getShimmerBase(isDarkMode),
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
