import 'package:flutter/material.dart';
import 'package:filevo/responsive.dart';

class FolderFileCard extends StatelessWidget {
  final String title;
  final int fileCount;
  final String size;
  final Color color;
  final VoidCallback? onTap;
  final bool showFileCount;
  final VoidCallback? onInfoTap; // ✅ callback لمعلومات المجلد
  final VoidCallback? onRenameTap; // ✅ callback لإعادة تسمية
  final VoidCallback? onDeleteTap; // ✅ callback للحذف
  final VoidCallback? onShareTap; // ✅ callback للمشاركة
  final VoidCallback? onOpenTap; // ✅ callback لفتح المجلد
  final VoidCallback? onDetailsTap; // ✅ callback لعرض تفاصيل الغرفة
  final VoidCallback? onCommentTap; // ✅ callback للتعليق على المجلد/الملف
  final VoidCallback? onFavoriteTap; // ✅ callback لإضافة/إزالة من المفضلة
  final VoidCallback? onMoveTap; // ✅ callback لنقل المجلد
  final VoidCallback? onRemoveFromRoomTap; // ✅ callback لإزالة المجلد من الغرفة
  final bool isStarred; // ✅ حالة المفضلة
  final Map<String, dynamic>? folderData; // ✅ بيانات المجلد الكاملة
  final String? sharedBy; // ✅ معلومات من شارك المجلد/الملف
  final String? roomId; // ✅ معرف الغرفة (لتمييز المجلدات المشتركة)

  const FolderFileCard({
    Key? key,
    required this.title,
    required this.fileCount,
    required this.size,
    this.color = const Color(0xFF00BFA5),
    this.onTap,
    this.showFileCount = true,
    this.onInfoTap,
    this.onRenameTap,
    this.onDeleteTap,
    this.onShareTap,
    this.onOpenTap,
    this.onDetailsTap,
    this.onCommentTap,
    this.onFavoriteTap,
    this.onMoveTap,
    this.onRemoveFromRoomTap,
    this.isStarred = false,
    this.folderData,
    this.sharedBy,
    this.roomId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(w * 0.08),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(w * 0.08),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.folder, color: color, size: w * 0.22),
                    // ✅ زر 3 نقاط - يفتح قائمة منبثقة من الأسفل
                    GestureDetector(
                      onTap: () {
                        if (onOpenTap != null || onInfoTap != null || onRenameTap != null || onShareTap != null || onMoveTap != null || onDeleteTap != null || onDetailsTap != null || onCommentTap != null || onRemoveFromRoomTap != null) {
                          _showContextMenu(context);
                        }
                      },
                      child: Icon(Icons.more_vert, color: Colors.grey, size: w * 0.12),
                    ),
                  ],
                ),

                Text(
                  title,
                  style: TextStyle(
                    fontSize: w * 0.12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (showFileCount)
                          Text(
                            "$fileCount Files",
                            style: TextStyle(
                              fontSize: w * 0.10,
                              color: Colors.grey[600],
                            ),
                          ),
                        if (!showFileCount)
                          SizedBox.shrink(),
                        Text(
                          size,
                          style: TextStyle(
                            fontSize: w * 0.10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ تنسيق التاريخ
  String _formatDate(dynamic date) {
    if (date == null) return '—';
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return '—';
    }
  }

  // ✅ عرض قائمة منبثقة من الأسفل
  void _showContextMenu(BuildContext context) {
    // ✅ تحديد إذا كان category (من folderData)
    final isCategory = folderData != null && folderData!['type'] == 'category';
    
    if (isCategory) {
      // ✅ قائمة خاصة للـ categories
      _showCategoryMenu(context);
    } else if (roomId != null) {
      // ✅ قائمة منفصلة للمجلدات المشتركة في الغرف
      _showSharedFolderMenu(context);
    } else {
      // ✅ قائمة المجلدات العادية
      _showNormalFolderMenu(context);
    }
  }

  // ✅ قائمة خاصة للـ categories
  void _showCategoryMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 20.0,
              tablet: 24.0,
              desktop: 28.0,
            )),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Handle bar
            Container(
              margin: EdgeInsets.only(
                top: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 12.0,
                  tablet: 14.0,
                  desktop: 16.0,
                ),
                bottom: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 8.0,
                  tablet: 10.0,
                  desktop: 12.0,
                ),
              ),
              width: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 40.0,
                tablet: 50.0,
                desktop: 60.0,
              ),
              height: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 4.0,
                tablet: 5.0,
                desktop: 6.0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // ✅ قائمة خيارات الـ categories
            if (onOpenTap != null)
              _buildMenuItem(
                context,
                icon: Icons.open_in_new,
                title: 'فتح',
                onTap: () {
                  Navigator.pop(context);
                  onOpenTap?.call();
                },
              ),
            
            if (onInfoTap != null)
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                title: 'عرض التفاصيل',
                onTap: () {
                  Navigator.pop(context);
                  onInfoTap?.call();
                },
              ),
            
            SizedBox(height: ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 8.0,
              tablet: 12.0,
              desktop: 16.0,
            )),
          ],
        ),
      ),
    );
  }

  // ✅ قائمة المجلدات المشتركة في الغرف
  void _showSharedFolderMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 20.0,
              tablet: 24.0,
              desktop: 28.0,
            )),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Handle bar
            Container(
              margin: EdgeInsets.only(
                top: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 12.0,
                  tablet: 14.0,
                  desktop: 16.0,
                ),
                bottom: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 8.0,
                  tablet: 10.0,
                  desktop: 12.0,
                ),
              ),
              width: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 40.0,
                tablet: 50.0,
                desktop: 60.0,
              ),
              height: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 4.0,
                tablet: 5.0,
                desktop: 6.0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // ✅ قائمة خيارات المجلدات المشتركة
            if (onOpenTap != null)
              _buildMenuItem(
                context,
                icon: Icons.open_in_new,
                title: 'فتح',
                onTap: () {
                  Navigator.pop(context);
                  onOpenTap?.call();
                },
              ),
            
            if (onInfoTap != null)
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                title: 'عرض التفاصيل',
                onTap: () {
                  Navigator.pop(context);
                  onInfoTap?.call();
                },
              ),
            
            if (onCommentTap != null)
              _buildMenuItem(
                context,
                icon: Icons.comment,
                title: 'التعليقات',
                iconColor: Color(0xFFF59E0B),
                onTap: () {
                  Navigator.pop(context);
                  onCommentTap?.call();
                },
              ),
            
            if (onFavoriteTap != null) ...[
              Divider(height: 1),
              _buildMenuItem(
                context,
                icon: isStarred ? Icons.star : Icons.star_border,
                title: isStarred ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
                iconColor: Colors.amber[700],
                onTap: () {
                  Navigator.pop(context);
                  onFavoriteTap?.call();
                },
              ),
            ],
            
            if (onRemoveFromRoomTap != null) ...[
              Divider(height: 1),
              _buildMenuItem(
                context,
                icon: Icons.link_off,
                title: 'إزالة من الغرفة',
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  onRemoveFromRoomTap?.call();
                },
              ),
            ],
            
            SizedBox(height: ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 8.0,
              tablet: 12.0,
              desktop: 16.0,
            )),
          ],
        ),
      ),
    );
  }

  // ✅ قائمة المجلدات العادية
  void _showNormalFolderMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 20.0,
                tablet: 24.0,
                desktop: 28.0,
              )),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // ✅ Handle bar
            Container(
              margin: EdgeInsets.only(
                top: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 12.0,
                  tablet: 14.0,
                  desktop: 16.0,
                ),
                bottom: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 8.0,
                  tablet: 10.0,
                  desktop: 12.0,
                ),
              ),
              width: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 40.0,
                tablet: 50.0,
                desktop: 60.0,
              ),
              height: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 4.0,
                tablet: 5.0,
                desktop: 6.0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // ✅ قائمة خيارات المجلدات العادية - قابلة للتمرير
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onOpenTap != null)
                      _buildMenuItem(
                        context,
                        icon: Icons.open_in_new,
                        title: 'فتح',
                        onTap: () {
                          Navigator.pop(context);
                          onOpenTap?.call();
                        },
                      ),
                    
                    if (onInfoTap != null)
                      _buildMenuItem(
                        context,
                        icon: Icons.info_outline,
                        title: 'عرض المعلومات',
                        onTap: () {
                          Navigator.pop(context);
                          onInfoTap?.call();
                        },
                      ),
                    
                    if (onRenameTap != null)
                      _buildMenuItem(
                        context,
                        icon: Icons.edit,
                        title: 'تعديل',
                        onTap: () {
                          Navigator.pop(context);
                          onRenameTap?.call();
                        },
                      ),
                    
                    if (onShareTap != null)
                      _buildMenuItem(
                        context,
                        icon: Icons.share,
                        title: 'مشاركة',
                        onTap: () {
                          Navigator.pop(context);
                          onShareTap?.call();
                        },
                      ),
                    
                    if (onMoveTap != null)
                      _buildMenuItem(
                        context,
                        icon: Icons.drive_file_move_rounded,
                        title: 'نقل',
                        iconColor: Colors.purple,
                        onTap: () {
                          Navigator.pop(context);
                          onMoveTap?.call();
                        },
                      ),
                    
                    if (onFavoriteTap != null)
                      _buildMenuItem(
                        context,
                        icon: isStarred ? Icons.star : Icons.star_border,
                        title: isStarred ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
                        iconColor: Colors.amber[700],
                        onTap: () {
                          Navigator.pop(context);
                          onFavoriteTap?.call();
                        },
                      ),
                    
                    if (onDeleteTap != null) ...[
                      Divider(height: 1),
                      _buildMenuItem(
                        context,
                        icon: Icons.delete,
                        title: 'حذف',
                        textColor: Colors.red,
                        iconColor: Colors.red,
                        onTap: () {
                          Navigator.pop(context);
                          onDeleteTap?.call();
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            SizedBox(height: ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 8.0,
              tablet: 12.0,
              desktop: 16.0,
            )),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    final iconSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    final containerSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 40.0,
      tablet: 48.0,
      desktop: 56.0,
    );
    final fontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
    );
    
    return ListTile(
      leading: Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.grey[700])!.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.grey[700],
          size: iconSize,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}