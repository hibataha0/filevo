import 'package:filevo/responsive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/views/fileViewer/file_actions_service.dart';
import 'package:filevo/views/fileViewer/file_details_page.dart';
import 'package:filevo/views/folders/room_comments_page.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/views/fileViewer/folder_actions_service.dart';
import 'package:filevo/views/folders/share_folder_with_room_page.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/generated/l10n.dart';

class FilesListView extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final EdgeInsetsGeometry? itemMargin;
  final bool showMoreOptions;
  final void Function(Map<String, dynamic>)? onItemTap;
  final String? roomId; // ✅ معرف الغرفة (لتمييز الملفات المشتركة)
  final void Function()?
  onFileRemoved; // ✅ callback لإعادة تحميل البيانات بعد إزالة ملف
  final void Function(Map<String, dynamic>)?
  onRoomDetailsTap; // ✅ callback لعرض تفاصيل الغرفة
  final void Function(Map<String, dynamic>)?
  onRoomEditTap; // ✅ callback لتعديل الغرفة

  const FilesListView({
    Key? key,
    required this.items,
    this.itemMargin,
    this.showMoreOptions = true,
    this.onItemTap,
    this.roomId,
    this.onFileRemoved,
    this.onRoomDetailsTap, // ✅ Initialize new callback
    this.onRoomEditTap, // ✅ Initialize new callback
  }) : super(key: key);

  @override
  State<FilesListView> createState() => _FilesListViewState();
}

class _FilesListViewState extends State<FilesListView> {
  // ✅ إضافة: Map لتتبع حالة النجمة لكل ملف (مثل FilesGrid)
  final Map<String, bool> _starStates = {};

  @override
  void initState() {
    super.initState();
    _initializeStarStates();
  }

  @override
  void didUpdateWidget(FilesListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ تحديث الحالات عند تغيير القائمة
    if (oldWidget.items != widget.items) {
      _initializeStarStates();
    }
  }

  // ✅ إضافة: تهيئة حالات النجمة من البيانات (مثل FilesGrid)
  void _initializeStarStates() {
    for (var file in widget.items) {
      final originalData = file['originalData'] ?? file['itemData'];
      if (originalData is Map<String, dynamic>) {
        final fileId = originalData['_id']?.toString();
        if (fileId != null) {
          _starStates[fileId] = originalData['isStarred'] ?? false;
        }
      }
    }
  }

  // ✅ الحصول على حالة النجمة للاستخدام في key
  bool _getStarState(Map<String, dynamic> file) {
    final originalData = file['originalData'] ?? file['itemData'];
    if (originalData is Map<String, dynamic>) {
      final fileId = originalData['_id']?.toString();
      if (fileId != null) {
        return _starStates[fileId] ?? originalData['isStarred'] ?? false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      itemBuilder: (context, index) {
        final file = widget.items[index];
        final icon = file['icon'] as IconData? ?? Icons.insert_drive_file;
        final color = file['color'] as Color? ?? Color(0xFF00BFA5);
        final iconSize = ResponsiveUtils.getResponsiveValue(
          context,
          mobile: 24.0,
          tablet: 28.0,
          desktop: 32.0,
        );

        // ✅ الحصول على حالة النجمة الحالية
        final originalData = file['originalData'] ?? file['itemData'];
        final fileId = originalData is Map<String, dynamic>
            ? originalData['_id']?.toString()
            : null;
        final starState = fileId != null
            ? (_starStates[fileId] ??
                  (originalData is Map<String, dynamic>
                      ? originalData['isStarred']
                      : false))
            : false;

        return Card(
          // ✅ إضافة key يعتمد على حالة النجمة لإعادة بناء الـ widget
          key: ValueKey('${file['title']}_$starState'),
          margin: widget.itemMargin ?? EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Container(
              width: iconSize + 8,
              height: iconSize + 8,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: iconSize),
            ),
            title: Text(
              file['title'] as String,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 14.0,
                  tablet: 15.0,
                  desktop: 16.0,
                ),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: _buildSubtitle(context, file),
            trailing: widget.showMoreOptions
                ? _buildMenuButton(context, file)
                : Icon(
                    Icons.arrow_forward_ios,
                    size: ResponsiveUtils.getResponsiveValue(
                      context,
                      mobile: 16.0,
                      tablet: 18.0,
                      desktop: 20.0,
                    ),
                    color: Colors.grey,
                  ),
            onTap: () {
              // ✅ التحقق من نوع الـ item
              final type = file['type'] as String?;

              // ✅ إذا كان room أو folder أو category، استخدم onItemTap مباشرة
              if (type == 'room' || type == 'folder' || type == 'category') {
                if (widget.onItemTap != null) {
                  widget.onItemTap!(file);
                }
              } else {
                // ✅ للملفات: استخدام FileActionsService.openFile
                final originalData =
                    file['originalData'] ??
                    file['itemData'] as Map<String, dynamic>?;
                final fileData = {
                  'name':
                      file['title'] ?? file['name'] ?? originalData?['name'],
                  'url': file['url'] ?? '',
                  'type': file['type'] ?? 'file',
                  'path': file['path'] ?? originalData?['path'],
                  'originalData': originalData ?? {},
                };
                FileActionsService.openFile(fileData, widget.onItemTap);
              }
            },
          ),
        );
      },
    );
  }

  /// ✅ بناء قائمة الملفات المشتركة في الغرف (نفس FilesGrid)
  List<PopupMenuEntry<String>> _buildSharedFileMenuItems(
    BuildContext context,
    Map<String, dynamic> file,
  ) {
    final originalData =
        file['originalData'] ?? file['itemData'] as Map<String, dynamic>? ?? {};
    final fileId = originalData['_id']?.toString();
    // ✅ استخدام _starStates لتتبع حالة النجمة (مثل FilesGrid)
    final isStarred = fileId != null
        ? (_starStates[fileId] ?? originalData['isStarred'] ?? false)
        : (originalData['isStarred'] ?? false);

    return [
      PopupMenuItem<String>(
        value: 'open',
        child: Row(
          children: [
            Icon(Icons.open_in_new_rounded, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text(S.of(context).open),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'info',
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.teal, size: 20),
            SizedBox(width: 8),
            Text(S.of(context).viewDetails),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'download',
        child: Row(
          children: [
            Icon(Icons.download_rounded, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text('تحميل'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'comments',
        child: Row(
          children: [
            Icon(Icons.comment_rounded, color: Color(0xFFF59E0B), size: 20),
            SizedBox(width: 8),
            Text(S.of(context).comments),
          ],
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'favorite',
        child: Row(
          children: [
            Icon(
              isStarred ? Icons.star_rounded : Icons.star_border_rounded,
              color: Colors.amber[700],
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              isStarred
                  ? S.of(context).removeFromFavorites
                  : S.of(context).addToFavorites,
            ),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'save',
        child: Row(
          children: [
            Icon(Icons.save_rounded, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text('حفظ في حسابي'),
          ],
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'remove_from_room',
        child: Row(
          children: [
            Icon(Icons.link_off_rounded, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text(
              S.of(context).removeFromRoom,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    ];
  }

  /// ✅ بناء زر القائمة (PopupMenuButton للملفات، IconButton للباقي)
  Widget _buildMenuButton(BuildContext context, Map<String, dynamic> file) {
    final type = file['type'] as String?;

    // ✅ للملفات: استخدام PopupMenuButton مثل Grid view
    if (type != 'room' && type != 'category' && type != 'folder') {
      return PopupMenuButton<String>(
        icon: Icon(Icons.more_vert),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        itemBuilder: (context) {
          // ✅ قائمة منفصلة للملفات المشتركة في الغرف
          if (widget.roomId != null) {
            return _buildSharedFileMenuItems(context, file);
          } else {
            // ✅ قائمة الملفات العادية
            return _buildNormalFileMenuItems(context, file);
          }
        },
        onSelected: (value) {
          if (widget.roomId != null) {
            _handleSharedFileMenuAction(context, value, file);
          } else {
            _handleNormalFileMenuAction(context, value, file);
          }
        },
      );
    }

    // ✅ للرومات والمجلدات والتصنيفات: استخدام IconButton مع bottom sheet
    return IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () {
        // ✅ قائمة خاصة للرومات
        if (type == 'room') {
          _showRoomMenu(context, file);
        }
        // ✅ قائمة خاصة للـ categories
        else if (type == 'category') {
          _showCategoryMenu(context, file);
        }
        // ✅ قائمة خاصة للمجلدات - استخدام bottom sheet مثل grid
        else if (type == 'folder') {
          _showFolderMenu(context, file);
        }
      },
    );
  }

  /// ✅ بناء subtitle للعناصر
  Widget _buildSubtitle(BuildContext context, Map<String, dynamic> file) {
    final type = file['type'] as String?;
    final size = file['size'] as String? ?? '';
    final fileCount = file['fileCount'] as int? ?? 0;

    // ✅ للرومات والمجلدات: عرض fileCount و size
    if (type == 'room' || type == 'folder') {
      String countText;
      if (fileCount == 0) {
        countText = 'لا توجد عناصر';
      } else if (fileCount == 1) {
        countText = 'عنصر واحد';
      } else {
        countText = '$fileCount عنصر';
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            countText,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 12.0,
                tablet: 13.0,
                desktop: 14.0,
              ),
              color: Colors.grey[600],
            ),
          ),
          if (size.isNotEmpty)
            Text(
              size,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 11.0,
                  tablet: 12.0,
                  desktop: 13.0,
                ),
                color: Colors.grey[500],
              ),
            ),
        ],
      );
    }

    // ✅ للتصنيفات والملفات: عرض size فقط
    return Text(
      size,
      style: TextStyle(
        fontSize: ResponsiveUtils.getResponsiveValue(
          context,
          mobile: 12.0,
          tablet: 13.0,
          desktop: 14.0,
        ),
        color: Colors.grey[600],
      ),
    );
  }

  /// ✅ عرض قائمة الـ categories (bottom sheet)
  void _showCategoryMenu(BuildContext context, Map<String, dynamic> category) {
    final scaffoldContext = context; // ✅ حفظ context الأصلي
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              ResponsiveUtils.getResponsiveValue(
                bottomSheetContext,
                mobile: 20.0,
                tablet: 24.0,
                desktop: 28.0,
              ),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Handle bar
            Container(
              margin: EdgeInsets.only(
                top: ResponsiveUtils.getResponsiveValue(
                  bottomSheetContext,
                  mobile: 12.0,
                  tablet: 14.0,
                  desktop: 16.0,
                ),
                bottom: ResponsiveUtils.getResponsiveValue(
                  bottomSheetContext,
                  mobile: 8.0,
                  tablet: 10.0,
                  desktop: 12.0,
                ),
              ),
              width: ResponsiveUtils.getResponsiveValue(
                bottomSheetContext,
                mobile: 40.0,
                tablet: 50.0,
                desktop: 60.0,
              ),
              height: ResponsiveUtils.getResponsiveValue(
                bottomSheetContext,
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
            if (widget.onItemTap != null)
              _buildMenuItem(
                bottomSheetContext,
                icon: Icons.open_in_new,
                title: 'فتح',
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (scaffoldContext.mounted) {
                      widget.onItemTap!(category);
                    }
                  });
                },
              ),
            _buildMenuItem(
              bottomSheetContext,
              icon: Icons.info_outline,
              title: 'عرض التفاصيل',
              onTap: () {
                Navigator.pop(bottomSheetContext);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scaffoldContext.mounted) {
                    _showCategoryDetails(scaffoldContext, category);
                  }
                });
              },
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveValue(
                bottomSheetContext,
                mobile: 8.0,
                tablet: 12.0,
                desktop: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ عرض قائمة الرومات (bottom sheet)
  void _showRoomMenu(BuildContext context, Map<String, dynamic> room) {
    final scaffoldContext = context; // ✅ حفظ context الأصلي
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              ResponsiveUtils.getResponsiveValue(
                bottomSheetContext,
                mobile: 20.0,
                tablet: 24.0,
                desktop: 28.0,
              ),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Handle bar
            Container(
              margin: EdgeInsets.only(
                top: ResponsiveUtils.getResponsiveValue(
                  bottomSheetContext,
                  mobile: 12.0,
                  tablet: 14.0,
                  desktop: 16.0,
                ),
                bottom: ResponsiveUtils.getResponsiveValue(
                  bottomSheetContext,
                  mobile: 8.0,
                  tablet: 10.0,
                  desktop: 12.0,
                ),
              ),
              width: ResponsiveUtils.getResponsiveValue(
                bottomSheetContext,
                mobile: 40.0,
                tablet: 50.0,
                desktop: 60.0,
              ),
              height: ResponsiveUtils.getResponsiveValue(
                bottomSheetContext,
                mobile: 4.0,
                tablet: 5.0,
                desktop: 6.0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // ✅ قائمة خيارات الرومات
            if (widget.onItemTap != null)
              _buildMenuItem(
                bottomSheetContext,
                icon: Icons.open_in_new,
                title: 'فتح',
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (scaffoldContext.mounted) {
                      widget.onItemTap!(room);
                    }
                  });
                },
              ),
            if (widget.onRoomDetailsTap != null)
              _buildMenuItem(
                bottomSheetContext,
                icon: Icons.info_outline,
                title: 'عرض المعلومات',
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (scaffoldContext.mounted) {
                      widget.onRoomDetailsTap!(room);
                    }
                  });
                },
              ),
            if (widget.onRoomEditTap != null)
              _buildMenuItem(
                bottomSheetContext,
                icon: Icons.edit,
                title: 'تعديل',
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (scaffoldContext.mounted) {
                      widget.onRoomEditTap!(room);
                    }
                  });
                },
              ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveValue(
                bottomSheetContext,
                mobile: 8.0,
                tablet: 12.0,
                desktop: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ بناء قائمة المجلدات
  List<PopupMenuEntry<String>> _buildFolderMenuItems(
    BuildContext context,
    Map<String, dynamic> folder,
  ) {
    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );
    final folderData = folder['folderData'] as Map<String, dynamic>? ?? {};
    final folderId =
        folder['folderId'] as String? ?? folderData['_id'] as String?;

    // ✅ التحقق من حالة isStarred
    var isStarred = folderData['isStarred'] ?? false;
    if (folderId != null) {
      final starredFolder = folderController.starredFolders.firstWhere(
        (f) => f['_id'] == folderId,
        orElse: () => {},
      );
      if (starredFolder.isNotEmpty) {
        isStarred = starredFolder['isStarred'] ?? true;
      }
    }

    return [
      PopupMenuItem<String>(
        value: 'open',
        child: Row(
          children: [
            Icon(Icons.open_in_new_rounded, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text('فتح'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'info',
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.teal, size: 20),
            SizedBox(width: 8),
            Text('عرض المعلومات'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'rename',
        child: Row(
          children: [
            Icon(Icons.edit_rounded, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Text('تعديل'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'share',
        child: Row(
          children: [
            Icon(Icons.share_rounded, color: Colors.green, size: 20),
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
            Icon(
              isStarred ? Icons.star_rounded : Icons.star_border_rounded,
              color: Colors.amber[700],
              size: 20,
            ),
            SizedBox(width: 8),
            Text(isStarred ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة'),
          ],
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text('حذف', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    ];
  }

  /// ✅ عرض قائمة المجلدات (bottom sheet) - مثل grid
  void _showFolderMenu(BuildContext context, Map<String, dynamic> folder) {
    final scaffoldContext = context; // ✅ حفظ context الأصلي
    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );
    final folderData = folder['folderData'] as Map<String, dynamic>? ?? {};
    final folderId =
        folder['folderId'] as String? ?? folderData['_id'] as String?;

    // ✅ التحقق من حالة isStarred
    var isStarred = folderData['isStarred'] ?? false;
    if (folderId != null) {
      final starredFolder = folderController.starredFolders.firstWhere(
        (f) => f['_id'] == folderId,
        orElse: () => {},
      );
      if (starredFolder.isNotEmpty) {
        isStarred = starredFolder['isStarred'] ?? true;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(bottomSheetContext).size.height * 0.7,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                ResponsiveUtils.getResponsiveValue(
                  bottomSheetContext,
                  mobile: 20.0,
                  tablet: 24.0,
                  desktop: 28.0,
                ),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Handle bar
              Container(
                margin: EdgeInsets.only(
                  top: ResponsiveUtils.getResponsiveValue(
                    bottomSheetContext,
                    mobile: 12.0,
                    tablet: 14.0,
                    desktop: 16.0,
                  ),
                  bottom: ResponsiveUtils.getResponsiveValue(
                    bottomSheetContext,
                    mobile: 8.0,
                    tablet: 10.0,
                    desktop: 12.0,
                  ),
                ),
                width: ResponsiveUtils.getResponsiveValue(
                  bottomSheetContext,
                  mobile: 40.0,
                  tablet: 50.0,
                  desktop: 60.0,
                ),
                height: ResponsiveUtils.getResponsiveValue(
                  bottomSheetContext,
                  mobile: 4.0,
                  tablet: 5.0,
                  desktop: 6.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // ✅ قائمة خيارات المجلدات - قابلة للتمرير
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.onItemTap != null)
                        _buildMenuItem(
                          bottomSheetContext,
                          icon: Icons.open_in_new,
                          title: 'فتح',
                          onTap: () {
                            Navigator.pop(bottomSheetContext);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (scaffoldContext.mounted) {
                                widget.onItemTap!(folder);
                              }
                            });
                          },
                        ),
                      _buildMenuItem(
                        bottomSheetContext,
                        icon: Icons.info_outline,
                        title: 'عرض المعلومات',
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (scaffoldContext.mounted) {
                              _showFolderInfo(scaffoldContext, folder);
                            }
                          });
                        },
                      ),
                      _buildMenuItem(
                        bottomSheetContext,
                        icon: Icons.edit,
                        title: 'تعديل',
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (scaffoldContext.mounted) {
                              _showRenameDialog(scaffoldContext, folder);
                            }
                          });
                        },
                      ),
                      _buildMenuItem(
                        bottomSheetContext,
                        icon: Icons.share,
                        title: 'مشاركة',
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (scaffoldContext.mounted) {
                              _showShareDialog(scaffoldContext, folder);
                            }
                          });
                        },
                      ),
                      _buildMenuItem(
                        bottomSheetContext,
                        icon: Icons.download,
                        title: 'تحميل',
                        iconColor: Colors.blue,
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (scaffoldContext.mounted) {
                              _handleFolderMenuAction(
                                scaffoldContext,
                                'download',
                                folder,
                              );
                            }
                          });
                        },
                      ),
                      _buildMenuItem(
                        bottomSheetContext,
                        icon: Icons.drive_file_move_rounded,
                        title: 'نقل',
                        iconColor: Colors.purple,
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (scaffoldContext.mounted) {
                              _showMoveFolderDialog(scaffoldContext, folder);
                            }
                          });
                        },
                      ),
                      _buildMenuItem(
                        bottomSheetContext,
                        icon: isStarred ? Icons.star : Icons.star_border,
                        title: isStarred
                            ? 'إزالة من المفضلة'
                            : 'إضافة إلى المفضلة',
                        iconColor: Colors.amber[700],
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (scaffoldContext.mounted) {
                              _toggleFavorite(scaffoldContext, folder);
                            }
                          });
                        },
                      ),
                      Divider(height: 1),
                      _buildMenuItem(
                        bottomSheetContext,
                        icon: Icons.delete,
                        title: 'حذف',
                        textColor: Colors.red,
                        iconColor: Colors.red,
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (scaffoldContext.mounted) {
                              _showDeleteDialog(scaffoldContext, folder);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveValue(
                  bottomSheetContext,
                  mobile: 8.0,
                  tablet: 12.0,
                  desktop: 16.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ بناء عنصر قائمة (menu item)
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
        child: Icon(icon, color: iconColor ?? Colors.grey[700], size: iconSize),
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

  /// ✅ معالجة إجراءات المجلدات (للاحتفاظ بالتوافق - لكن لن تُستخدم)
  void _handleFolderMenuAction(
    BuildContext context,
    String action,
    Map<String, dynamic> folder,
  ) {
    switch (action) {
      case 'open':
        // ✅ فتح المجلد
        if (widget.onItemTap != null) {
          widget.onItemTap!(folder);
        }
        break;
      case 'info':
        // ✅ عرض معلومات المجلد (استخدام الدوال المساعدة من FilesGridView)
        _showFolderInfo(context, folder);
        break;
      case 'rename':
        // ✅ تعديل المجلد (استخدام الدوال المساعدة من FilesGridView)
        _showRenameDialog(context, folder);
        break;
      case 'share':
        // ✅ مشاركة المجلد (استخدام الدوال المساعدة من FilesGridView)
        _showShareDialog(context, folder);
        break;
      case 'download':
        // ✅ تحميل المجلد
        FolderActionsService.downloadFolder(context, folder);
        break;
      case 'move':
        // ✅ نقل المجلد
        _showMoveFolderDialog(context, folder);
        break;
      case 'favorite':
        // ✅ إضافة/إزالة من المفضلة (استخدام الدوال المساعدة من FilesGridView)
        _toggleFavorite(context, folder);
        break;
      case 'delete':
        // ✅ حذف المجلد (استخدام الدوال المساعدة من FilesGridView)
        _showDeleteDialog(context, folder);
        break;
    }
  }

  // ✅ Helper functions للتعامل مع إجراءات المجلد
  void _showFolderInfo(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    final folderId = folder['folderId'] as String?;
    final folderName = folder['title'] as String;
    final folderColor = folder['color'] as Color? ?? Colors.blue;

    if (folderId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ: معرف المجلد غير موجود')));
      return;
    }

    // ✅ جلب تفاصيل المجلد من الباك إند
    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );
    final folderDetails = await folderController.getFolderDetails(
      folderId: folderId,
    );

    if (folderDetails == null || folderDetails['folder'] == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل جلب معلومات المجلد')));
      }
      return;
    }

    final folderData = folderDetails['folder'] as Map<String, dynamic>;

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ✅ Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: folderColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder, color: Colors.white, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      folderData['name'] ?? folderName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ✅ Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem('folder', '📁', 'النوع', 'مجلد'),
                    _buildDetailItem(
                      'size',
                      '💾',
                      'الحجم',
                      _formatBytesHelper(folderData['size'] ?? 0),
                    ),
                    _buildDetailItem(
                      'files',
                      '📄',
                      'عدد الملفات',
                      '${folderData['filesCount'] ?? 0}',
                    ),
                    _buildDetailItem(
                      'subfolders',
                      '📂',
                      'عدد المجلدات الفرعية',
                      '${folderData['subfoldersCount'] ?? 0}',
                    ),
                    _buildDetailItem(
                      'time',
                      '🕐',
                      'تاريخ الإنشاء',
                      _formatDateHelper(folderData['createdAt']),
                    ),
                    _buildDetailItem(
                      'edit',
                      '✏️',
                      'آخر تعديل',
                      _formatDateHelper(folderData['updatedAt']),
                    ),
                    _buildDetailItem(
                      'description',
                      '📝',
                      'الوصف',
                      folderData['description']?.isNotEmpty == true
                          ? folderData['description']
                          : "—",
                    ),
                    _buildDetailItem(
                      'tags',
                      '🏷️',
                      'الوسوم',
                      (folderData['tags'] as List?)?.join(', ') ?? "—",
                    ),

                    // ✅ Shared With Section
                    if (folderData['sharedWith'] != null &&
                        (folderData['sharedWith'] as List).isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          _buildDetailItem(
                            'share',
                            '👥',
                            'تمت المشاركة مع',
                            (folderData['sharedWith'] as List)
                                    .map<String>(
                                      (u) =>
                                          u['user']?['email']?.toString() ??
                                          u['email']?.toString() ??
                                          '',
                                    )
                                    .where((email) => email.isNotEmpty)
                                    .join(', ') ??
                                "—",
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytesHelper(int bytes) {
    if (bytes == 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];

    int i = 0;
    double size = bytes.toDouble();

    while (size >= k && i < sizes.length - 1) {
      size /= k;
      i++;
    }

    if (i >= sizes.length) {
      i = sizes.length - 1;
    }

    return '${size.toStringAsFixed(1)} ${sizes[i]}';
  }

  String _formatDateHelper(dynamic date) {
    if (date == null) return "—";
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "—";
    }
  }

  void _showRenameDialog(BuildContext context, Map<String, dynamic> folder) {
    final folderName = folder['title'] as String;
    final folderId = folder['folderId'] as String?;
    final folderData = folder['folderData'] as Map<String, dynamic>?;

    final nameController = TextEditingController(text: folderName);
    final descriptionController = TextEditingController(
      text: folderData?['description'] as String? ?? '',
    );
    final tagsController = TextEditingController(
      text: (folderData?['tags'] as List?)?.join(', ') ?? '',
    );

    final scaffoldContext = context; // ✅ حفظ context الأصلي

    if (folderId == null) {
      if (scaffoldContext.mounted) {
        ScaffoldMessenger.of(
          scaffoldContext,
        ).showSnackBar(SnackBar(content: Text('خطأ: معرف المجلد غير موجود')));
      }
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('تعديل المجلد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'اسم المجلد',
                  hintText: 'اسم المجلد',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.folder),
                ),
                autofocus: true,
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'الوصف',
                  hintText: 'وصف المجلد (اختياري)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextField(
                controller: tagsController,
                decoration: InputDecoration(
                  labelText: 'الوسوم',
                  hintText: 'وسوم مفصولة بفواصل (اختياري)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('يرجى إدخال اسم المجلد')),
                  );
                }
                return;
              }

              final description = descriptionController.text.trim();
              final tagsString = tagsController.text.trim();
              final tags = tagsString.isNotEmpty
                  ? tagsString
                        .split(',')
                        .map((t) => t.trim())
                        .where((t) => t.isNotEmpty)
                        .toList()
                  : <String>[];

              _performUpdate(
                dialogContext,
                scaffoldContext,
                folderId!,
                newName,
                description.isEmpty ? null : description,
                tags.isEmpty ? null : tags,
              );
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _performUpdate(
    BuildContext dialogContext,
    BuildContext scaffoldContext,
    String folderId,
    String newName,
    String? description,
    List<String>? tags,
  ) async {
    final folderController = Provider.of<FolderController>(
      scaffoldContext,
      listen: false,
    );

    Navigator.pop(dialogContext);

    final success = await folderController.updateFolder(
      folderId: folderId,
      name: newName,
      description: description,
      tags: tags,
    );

    if (scaffoldContext.mounted) {
      if (success) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('✅ تم تحديث المجلد بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        // ✅ إعادة بناء الـ widget بعد التحديث
        setState(() {});
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text(
              folderController.errorMessage ?? '❌ فشل تحديث المجلد',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showShareDialog(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    final folderId = folder['folderId'] as String?;
    final folderName = folder['title'] as String;

    if (folderId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ: معرف المجلد غير موجود')));
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ShareFolderWithRoomPage(folderId: folderId, folderName: folderName),
      ),
    );
  }

  void _toggleFavorite(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    final folderId = folder['folderId'] as String?;
    if (folderId == null) return;

    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );

    // ✅ إظهار مؤشر التحميل
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('جاري التحديث...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }

    // ✅ استدعاء API لإضافة/إزالة من المفضلة
    final result = await folderController.toggleStarFolder(folderId: folderId);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (result['success'] == true) {
      final isStarred = result['isStarred'] as bool? ?? false;

      // ✅ تحديث البيانات المحلية
      final folderData = folder['folderData'] as Map<String, dynamic>?;
      if (folderData != null) {
        folderData['isStarred'] = isStarred;
      }
      folder['isStarred'] = isStarred;

      // ✅ إعادة بناء الـ widget
      if (mounted) {
        setState(() {});
      }

      // ✅ إظهار رسالة النجاح
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isStarred
                  ? '✅ تم إضافة المجلد إلى المفضلة'
                  : '✅ تم إزالة المجلد من المفضلة',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // ✅ إظهار رسالة الخطأ
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              folderController.errorMessage ?? '❌ فشل تحديث حالة المفضلة',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> folder) {
    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );
    final folderData = folder['folderData'] ?? folder;

    FolderActionsService.deleteFolder(context, folderController, {
      'name': folder['title'] ?? folderData['name'],
      '_id': folder['folderId'] ?? folderData['_id'],
      'folderData': folderData,
    });
  }

  /// ✅ عرض تفاصيل التصنيف
  void _showCategoryDetails(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    final categoryTitle = category['title'] as String? ?? 'تصنيف';
    final fileCount = category['fileCount'] as int? ?? 0;
    final size = category['size'] as String? ?? '0';
    final color = category['color'] as Color? ?? Colors.blue;
    final icon = category['icon'] as IconData? ?? Icons.folder;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ✅ Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      categoryTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ✅ Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem('folder', '📁', 'النوع', 'تصنيف'),
                    _buildDetailItem(
                      'files',
                      '📄',
                      'عدد الملفات',
                      '$fileCount',
                    ),
                    _buildDetailItem('size', '💾', 'الحجم الإجمالي', size),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ بناء عنصر تفاصيل
  Widget _buildDetailItem(
    String type,
    String emoji,
    String label,
    String value,
  ) {
    Color getIconColor() {
      switch (type) {
        case 'folder':
          return Color(0xFF10B981);
        case 'size':
          return Color(0xFFF59E0B);
        case 'files':
          return Color(0xFF3B82F6);
        default:
          return Color(0xFF6B7280);
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: getIconColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(emoji, style: TextStyle(fontSize: 20)),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ بناء قائمة الملفات العادية
  /// ✅ بناء قائمة الملفات العادية (نفس FilesGrid)
  List<PopupMenuEntry<String>> _buildNormalFileMenuItems(
    BuildContext context,
    Map<String, dynamic> file,
  ) {
    final originalData =
        file['originalData'] ?? file['itemData'] as Map<String, dynamic>? ?? {};
    final fileId = originalData['_id']?.toString();
    // ✅ استخدام _starStates لتتبع حالة النجمة (مثل FilesGrid)
    final isStarred = fileId != null
        ? (_starStates[fileId] ?? originalData['isStarred'] ?? false)
        : (originalData['isStarred'] ?? false);

    return [
      PopupMenuItem<String>(
        value: 'open',
        child: Row(
          children: [
            Icon(Icons.open_in_new_rounded, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text(S.of(context).open),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'info',
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.teal, size: 20),
            SizedBox(width: 8),
            Text(S.of(context).viewInfo),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'download',
        child: Row(
          children: [
            Icon(Icons.download_rounded, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text('تحميل'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'edit',
        child: Row(
          children: [
            Icon(Icons.edit_rounded, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Text(S.of(context).edit),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'share',
        child: Row(
          children: [
            Icon(Icons.share_rounded, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text(S.of(context).share),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'move',
        child: Row(
          children: [
            Icon(Icons.drive_file_move_rounded, color: Colors.purple, size: 20),
            SizedBox(width: 8),
            Text(S.of(context).move),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'favorite',
        child: Row(
          children: [
            Icon(
              isStarred ? Icons.star_rounded : Icons.star_border_rounded,
              color: Colors.amber[700],
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              isStarred
                  ? S.of(context).removeFromFavorites
                  : S.of(context).addToFavorites,
            ),
          ],
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text(S.of(context).delete, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    ];
  }

  /// ✅ معالجة إجراءات الملفات المشتركة في الغرف
  void _handleSharedFileMenuAction(
    BuildContext context,
    String action,
    Map<String, dynamic> file,
  ) {
    final fileController = Provider.of<FileController>(context, listen: false);
    final originalData =
        file['originalData'] ?? file['itemData'] as Map<String, dynamic>? ?? {};
    // ✅ استخدام نفس format البيانات التي يستخدمها FilesGrid
    final fileData = {
      'name': file['title'] ?? file['name'],
      'url': file['url'] ?? '',
      'type': file['type'] ?? 'file',
      'originalData': originalData,
    };

    switch (action) {
      case 'open':
        // ✅ استخدام FileActionsService.openFile مثل FilesGrid
        FileActionsService.openFile(fileData, widget.onItemTap);
        break;
      case 'info':
        final fileId = originalData['_id']?.toString();
        if (fileId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  FileDetailsPage(fileId: fileId, roomId: widget.roomId),
            ),
          );
        }
        break;
      case 'download':
        // ✅ تحميل ملف مشترك في الروم
        if (widget.roomId != null) {
          final fileId = fileData['originalData']?['_id'] ?? fileData['fileId'];
          final fileName =
              fileData['name'] ?? fileData['originalData']?['name'];
          if (fileId != null) {
            final roomController = Provider.of<RoomController>(
              context,
              listen: false,
            );
            FileActionsService.downloadRoomFile(
              context,
              roomController,
              widget.roomId!,
              fileId,
              fileName,
            );
          }
        }
        break;
      case 'comments':
        if (widget.roomId != null) {
          final fileId = originalData['_id']?.toString();
          if (fileId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: Provider.of<RoomController>(context, listen: false),
                  child: RoomCommentsPage(
                    roomId: widget.roomId!,
                    targetType: 'file',
                    targetId: fileId,
                  ),
                ),
              ),
            );
          }
        }
        break;
      case 'favorite':
        FileActionsService.toggleStar(
          context,
          fileController,
          fileData,
          onToggle: () {
            // ✅ تحديث حالة النجمة في _starStates (مثل FilesGrid)
            final fileId = fileData['originalData']?['_id']?.toString();
            if (fileId != null && mounted) {
              setState(() {
                // ✅ نقرأ القيمة المحدثة من fileData مباشرة (مثل FilesGrid)
                _starStates[fileId] =
                    fileData['originalData']['isStarred'] ?? false;
                // ✅ تحديث البيانات في items أيضاً لتحديث القائمة
                final originalData = fileData['originalData'];
                if (originalData is Map<String, dynamic>) {
                  originalData['isStarred'] = _starStates[fileId];
                }
                // ✅ تحديث file في widget.items أيضاً (إذا كان reference)
                final fileIndex = widget.items.indexWhere((item) {
                  final itemData = item['originalData'] ?? item['itemData'];
                  return itemData is Map<String, dynamic> &&
                      itemData['_id']?.toString() == fileId;
                });
                if (fileIndex != -1) {
                  final itemOriginalData =
                      widget.items[fileIndex]['originalData'] ??
                      widget.items[fileIndex]['itemData'];
                  if (itemOriginalData is Map<String, dynamic>) {
                    itemOriginalData['isStarred'] = _starStates[fileId];
                  }
                }
                print('🎨 UI Updated - Star state: ${_starStates[fileId]}');
              });
            }
          },
        );
        break;
      case 'save':
        // ✅ حفظ الملف من الغرفة إلى حساب المستخدم
        _saveFileFromRoom(context, file);
        break;
      case 'remove_from_room':
        // ✅ إزالة الملف من الغرفة
        _showRemoveFileFromRoomDialog(context, file);
        break;
    }
  }

  /// ✅ حفظ الملف من الغرفة إلى حساب المستخدم
  Future<void> _saveFileFromRoom(
    BuildContext context,
    Map<String, dynamic> file,
  ) async {
    if (widget.roomId == null) return;

    final originalData =
        file['originalData'] ?? file['itemData'] as Map<String, dynamic>? ?? {};
    final fileId = originalData['_id']?.toString();
    if (fileId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ معرف الملف غير موجود'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // ✅ عرض dialog لاختيار المجلد (اختياري) - استخدام null للجذر
    String? targetFolderId = null;

    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(width: 16),
                Text('جاري حفظ الملف...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      final roomController = Provider.of<RoomController>(
        context,
        listen: false,
      );
      final success = await roomController.saveFileFromRoom(
        roomId: widget.roomId!,
        fileId: fileId,
        parentFolderId: targetFolderId,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تم حفظ الملف في حسابك بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(roomController.errorMessage ?? '❌ فشل حفظ الملف'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// ✅ عرض dialog لتأكيد إزالة الملف من الغرفة
  void _showRemoveFileFromRoomDialog(
    BuildContext context,
    Map<String, dynamic> file,
  ) {
    final fileName =
        file['title']?.toString() ??
        file['name']?.toString() ??
        file['originalName']?.toString() ??
        'الملف';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('إزالة الملف من الغرفة'),
        content: Text('هل أنت متأكد من إزالة "$fileName" من الغرفة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _removeFileFromRoom(context, file);
            },
            child: Text('إزالة', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// ✅ إزالة الملف من الغرفة
  Future<void> _removeFileFromRoom(
    BuildContext context,
    Map<String, dynamic> file,
  ) async {
    if (widget.roomId == null) return;

    final originalData =
        file['originalData'] ?? file['itemData'] as Map<String, dynamic>? ?? {};
    final fileId = originalData['_id']?.toString();
    if (fileId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ معرف الملف غير موجود'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final roomController = Provider.of<RoomController>(
        context,
        listen: false,
      );
      final success = await roomController.unshareFileFromRoom(
        roomId: widget.roomId!,
        fileId: fileId,
      );

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تم إزالة الملف من الغرفة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          // ✅ إعادة تحميل البيانات بعد إزالة الملف
          if (widget.onFileRemoved != null) {
            widget.onFileRemoved!();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                roomController.errorMessage ?? '❌ فشل إزالة الملف من الغرفة',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// ✅ معالجة إجراءات الملفات العادية
  void _handleNormalFileMenuAction(
    BuildContext context,
    String action,
    Map<String, dynamic> file,
  ) {
    final fileController = Provider.of<FileController>(context, listen: false);
    final originalData =
        file['originalData'] ?? file['itemData'] as Map<String, dynamic>? ?? {};
    // ✅ استخدام نفس format البيانات التي يستخدمها FilesGrid
    // ✅ الحصول على path من عدة مصادر
    final path =
        file['path'] ??
        (originalData is Map ? originalData['path'] : null) ??
        '';
    // ✅ الحصول على url من عدة مصادر (url موجود في البيانات من home_view)
    final url = file['url'] ?? '';

    final fileData = {
      'name':
          file['title'] ??
          file['name'] ??
          (originalData is Map ? originalData['name'] : null),
      'url': url,
      'type': file['type'] ?? 'file',
      'path': path,
      'originalData': originalData,
      'originalName':
          file['originalName'] ??
          (originalData is Map ? originalData['name'] : null),
    };

    switch (action) {
      case 'open':
        // ✅ استخدام FileActionsService.openFile مثل FilesGrid
        FileActionsService.openFile(fileData, widget.onItemTap);
        break;
      case 'info':
        final fileId = originalData['_id']?.toString();
        if (fileId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FileDetailsPage(fileId: fileId)),
          );
        }
        break;
      case 'download':
        // ✅ تحميل الملف
        FileActionsService.downloadFile(context, fileData);
        break;
      case 'edit':
        FileActionsService.editFile(context, fileData);
        break;
      case 'share':
        FileActionsService.shareFile(context, fileData);
        break;
      case 'move':
        // ✅ نقل الملف
        _showMoveFileDialog(context, file);
        break;
      case 'favorite':
        FileActionsService.toggleStar(
          context,
          fileController,
          fileData,
          onToggle: () {
            // ✅ تحديث حالة النجمة في _starStates (مثل FilesGrid)
            final fileId = fileData['originalData']?['_id']?.toString();
            if (fileId != null && mounted) {
              setState(() {
                // ✅ نقرأ القيمة المحدثة من fileData مباشرة (مثل FilesGrid)
                _starStates[fileId] =
                    fileData['originalData']['isStarred'] ?? false;
                // ✅ تحديث البيانات في items أيضاً لتحديث القائمة
                final originalData = fileData['originalData'];
                if (originalData is Map<String, dynamic>) {
                  originalData['isStarred'] = _starStates[fileId];
                }
                // ✅ تحديث file في widget.items أيضاً (إذا كان reference)
                final fileIndex = widget.items.indexWhere((item) {
                  final itemData = item['originalData'] ?? item['itemData'];
                  return itemData is Map<String, dynamic> &&
                      itemData['_id']?.toString() == fileId;
                });
                if (fileIndex != -1) {
                  final itemOriginalData =
                      widget.items[fileIndex]['originalData'] ??
                      widget.items[fileIndex]['itemData'];
                  if (itemOriginalData is Map<String, dynamic>) {
                    itemOriginalData['isStarred'] = _starStates[fileId];
                  }
                }
                print('🎨 UI Updated - Star state: ${_starStates[fileId]}');
              });
            }
          },
        );
        break;
      case 'delete':
        FileActionsService.deleteFile(context, fileController, fileData);
        break;
    }
  }

  /// ✅ دالة لعرض dialog لاختيار المجلد الهدف لنقل الملف
  void _showMoveFileDialog(
    BuildContext context,
    Map<String, dynamic> file,
  ) async {
    final originalData =
        file['originalData'] ?? file['itemData'] as Map<String, dynamic>? ?? {};
    final fileId = originalData['_id']?.toString();
    final fileName =
        file['title'] ?? file['name'] ?? originalData['name'] ?? 'ملف';
    final currentParentId = originalData['parentFolderId']?.toString();

    if (fileId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ: معرف الملف غير موجود')));
      }
      return;
    }

    // ✅ جلب قائمة المجلدات
    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );
    final foldersResponse = await folderController.getAllFolders(
      page: 1,
      limit: 100,
    );

    if (!context.mounted) return;

    if (foldersResponse == null || foldersResponse['folders'] == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل جلب قائمة المجلدات')));
      }
      return;
    }

    final folders = List<Map<String, dynamic>>.from(
      foldersResponse['folders'] ?? [],
    );

    // ✅ تصفية المجلد الحالي (إذا كان الملف في مجلد)
    final availableFolders = folders.where((folder) {
      final folderId = folder['_id']?.toString();
      return folderId != currentParentId;
    }).toList();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ✅ Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.drive_file_move_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'نقل الملف: $fileName',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ✅ Content
            Expanded(
              child: Column(
                children: [
                  // ✅ خيار "الجذر"
                  ListTile(
                    leading: Icon(Icons.home_rounded, color: Colors.blue),
                    title: Text('الجذر'),
                    subtitle: Text('نقل الملف للجذر (بدون مجلد)'),
                    onTap: () {
                      Navigator.pop(context);
                      _moveFile(context, fileId, null, fileName);
                    },
                  ),
                  Divider(),

                  // ✅ قائمة المجلدات
                  Expanded(
                    child: availableFolders.isEmpty
                        ? Center(
                            child: Text(
                              'لا توجد مجلدات متاحة',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: availableFolders.length,
                            itemBuilder: (context, index) {
                              final folder = availableFolders[index];
                              final folderId = folder['_id']?.toString();
                              final folderName =
                                  folder['name'] ?? 'مجلد بدون اسم';

                              return ListTile(
                                leading: Icon(
                                  Icons.folder_rounded,
                                  color: Colors.orange,
                                ),
                                title: Text(folderName),
                                subtitle: Text(
                                  '${folder['filesCount'] ?? 0} ملف',
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _moveFile(
                                    context,
                                    fileId,
                                    folderId,
                                    fileName,
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ دالة لنقل الملف
  Future<void> _moveFile(
    BuildContext context,
    String fileId,
    String? targetFolderId,
    String fileName,
  ) async {
    final fileController = Provider.of<FileController>(context, listen: false);
    final token = await StorageService.getToken();

    if (token == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ: يجب تسجيل الدخول أولاً')));
      }
      return;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 16),
            Text('جاري نقل الملف...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    final success = await fileController.moveFile(
      fileId: fileId,
      token: token,
      targetFolderId: targetFolderId,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم نقل الملف بنجاح'),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ إعادة تحميل البيانات - استخدام callback إذا كان موجوداً
        // هذا سيعيد تحميل الملفات في CategoryPage وإحصائيات التصنيفات في folders_view
        if (widget.onFileRemoved != null) {
          widget.onFileRemoved!();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(fileController.errorMessage ?? '❌ فشل نقل الملف'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// ✅ دالة لعرض dialog لاختيار المجلد الهدف لنقل المجلد
  void _showMoveFolderDialog(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    final folderData = folder['folderData'] as Map<String, dynamic>? ?? {};
    final folderId =
        folder['folderId'] as String? ?? folderData['_id'] as String?;
    final folderName =
        folder['title'] as String ?? folderData['name'] ?? 'مجلد';
    final currentParentId = folderData['parentId']?.toString();

    if (folderId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ: معرف المجلد غير موجود')));
      }
      return;
    }

    // ✅ جلب قائمة المجلدات
    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );
    final foldersResponse = await folderController.getAllFolders(
      page: 1,
      limit: 100,
    );

    if (!context.mounted) return;

    if (foldersResponse == null || foldersResponse['folders'] == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل جلب قائمة المجلدات')));
      }
      return;
    }

    final folders = List<Map<String, dynamic>>.from(
      foldersResponse['folders'] ?? [],
    );

    // ✅ تصفية المجلد الحالي والمجلدات الفرعية (لتجنب الحلقات)
    final availableFolders = folders.where((f) {
      final fId = f['_id']?.toString();
      return fId != folderId && fId != currentParentId;
    }).toList();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ✅ Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.drive_file_move_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'نقل المجلد: $folderName',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ✅ Content
            Expanded(
              child: Column(
                children: [
                  // ✅ خيار "الجذر"
                  ListTile(
                    leading: Icon(Icons.home_rounded, color: Colors.blue),
                    title: Text('الجذر'),
                    subtitle: Text('نقل المجلد للجذر (بدون مجلد أب)'),
                    onTap: () {
                      Navigator.pop(context);
                      _moveFolder(context, folderId, null, folderName);
                    },
                  ),
                  Divider(),

                  // ✅ قائمة المجلدات
                  Expanded(
                    child: availableFolders.isEmpty
                        ? Center(
                            child: Text(
                              'لا توجد مجلدات متاحة',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: availableFolders.length,
                            itemBuilder: (context, index) {
                              final f = availableFolders[index];
                              final fId = f['_id']?.toString();
                              final fName = f['name'] ?? 'مجلد بدون اسم';

                              return ListTile(
                                leading: Icon(
                                  Icons.folder_rounded,
                                  color: Colors.orange,
                                ),
                                title: Text(fName),
                                subtitle: Text('${f['filesCount'] ?? 0} ملف'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _moveFolder(
                                    context,
                                    folderId,
                                    fId,
                                    folderName,
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ عرض قائمة الملفات المشتركة في الغرف (bottom sheet)
  void _showSharedFileMenu(BuildContext context, Map<String, dynamic> file) {
    final scaffoldContext = context; // ✅ حفظ context الأصلي
    final originalData =
        file['originalData'] ?? file['itemData'] as Map<String, dynamic>? ?? {};
    final fileId = originalData['_id']?.toString();
    final isStarred = fileId != null
        ? (_starStates[fileId] ?? originalData['isStarred'] ?? false)
        : (originalData['isStarred'] ?? false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              ResponsiveUtils.getResponsiveValue(
                bottomSheetContext,
                mobile: 20.0,
                tablet: 24.0,
                desktop: 28.0,
              ),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Handle bar
            Container(
              margin: EdgeInsets.only(
                top: ResponsiveUtils.getResponsiveValue(
                  bottomSheetContext,
                  mobile: 12.0,
                  tablet: 14.0,
                  desktop: 16.0,
                ),
                bottom: ResponsiveUtils.getResponsiveValue(
                  bottomSheetContext,
                  mobile: 8.0,
                  tablet: 10.0,
                  desktop: 12.0,
                ),
              ),
              width: ResponsiveUtils.getResponsiveValue(
                bottomSheetContext,
                mobile: 40.0,
                tablet: 50.0,
                desktop: 60.0,
              ),
              height: ResponsiveUtils.getResponsiveValue(
                bottomSheetContext,
                mobile: 4.0,
                tablet: 5.0,
                desktop: 6.0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildMenuItem(
              bottomSheetContext,
              icon: Icons.open_in_new,
              title: 'فتح',
              onTap: () {
                Navigator.pop(bottomSheetContext);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scaffoldContext.mounted) {
                    _handleSharedFileMenuAction(scaffoldContext, 'open', file);
                  }
                });
              },
            ),
            _buildMenuItem(
              bottomSheetContext,
              icon: Icons.info_outline,
              title: 'عرض التفاصيل',
              onTap: () {
                Navigator.pop(bottomSheetContext);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scaffoldContext.mounted) {
                    _handleSharedFileMenuAction(scaffoldContext, 'info', file);
                  }
                });
              },
            ),
            _buildMenuItem(
              bottomSheetContext,
              icon: Icons.download,
              title: 'تحميل',
              iconColor: Colors.blue,
              onTap: () {
                Navigator.pop(bottomSheetContext);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scaffoldContext.mounted) {
                    _handleSharedFileMenuAction(
                      scaffoldContext,
                      'download',
                      file,
                    );
                  }
                });
              },
            ),
            _buildMenuItem(
              bottomSheetContext,
              icon: Icons.comment,
              title: 'تعليقات',
              iconColor: Color(0xFFF59E0B),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scaffoldContext.mounted) {
                    _handleSharedFileMenuAction(
                      scaffoldContext,
                      'comments',
                      file,
                    );
                  }
                });
              },
            ),
            Divider(height: 1),
            _buildMenuItem(
              bottomSheetContext,
              icon: isStarred ? Icons.star : Icons.star_border,
              title: isStarred ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
              iconColor: Colors.amber[700],
              onTap: () {
                Navigator.pop(bottomSheetContext);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scaffoldContext.mounted) {
                    _handleSharedFileMenuAction(
                      scaffoldContext,
                      'favorite',
                      file,
                    );
                  }
                });
              },
            ),
            _buildMenuItem(
              bottomSheetContext,
              icon: Icons.save,
              title: 'حفظ في حسابي',
              iconColor: Colors.green,
              onTap: () {
                Navigator.pop(bottomSheetContext);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scaffoldContext.mounted) {
                    _handleSharedFileMenuAction(scaffoldContext, 'save', file);
                  }
                });
              },
            ),
            Divider(height: 1),
            _buildMenuItem(
              bottomSheetContext,
              icon: Icons.link_off,
              title: 'إزالة من الغرفة',
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () {
                Navigator.pop(bottomSheetContext);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scaffoldContext.mounted) {
                    _handleSharedFileMenuAction(
                      scaffoldContext,
                      'remove_from_room',
                      file,
                    );
                  }
                });
              },
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveValue(
                bottomSheetContext,
                mobile: 8.0,
                tablet: 12.0,
                desktop: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ عرض قائمة الملفات العادية (bottom sheet)
  void _showNormalFileMenu(BuildContext context, Map<String, dynamic> file) {
    final scaffoldContext = context; // ✅ حفظ context الأصلي
    final originalData =
        file['originalData'] ?? file['itemData'] as Map<String, dynamic>? ?? {};
    final fileId = originalData['_id']?.toString();
    final isStarred = fileId != null
        ? (_starStates[fileId] ?? originalData['isStarred'] ?? false)
        : (originalData['isStarred'] ?? false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              ResponsiveUtils.getResponsiveValue(
                bottomSheetContext,
                mobile: 20.0,
                tablet: 24.0,
                desktop: 28.0,
              ),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Handle bar
            Container(
              margin: EdgeInsets.only(
                top: ResponsiveUtils.getResponsiveValue(
                  bottomSheetContext,
                  mobile: 12.0,
                  tablet: 14.0,
                  desktop: 16.0,
                ),
                bottom: ResponsiveUtils.getResponsiveValue(
                  bottomSheetContext,
                  mobile: 8.0,
                  tablet: 10.0,
                  desktop: 12.0,
                ),
              ),
              width: ResponsiveUtils.getResponsiveValue(
                bottomSheetContext,
                mobile: 40.0,
                tablet: 50.0,
                desktop: 60.0,
              ),
              height: ResponsiveUtils.getResponsiveValue(
                bottomSheetContext,
                mobile: 4.0,
                tablet: 5.0,
                desktop: 6.0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildMenuItem(
              bottomSheetContext,
              icon: Icons.open_in_new,
              title: 'فتح',
              onTap: () {
                Navigator.pop(bottomSheetContext);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scaffoldContext.mounted) {
                    _handleNormalFileMenuAction(scaffoldContext, 'open', file);
                  }
                });
              },
            ),
            _buildMenuItem(
              bottomSheetContext,
              icon: Icons.info_outline,
              title: 'عرض التفاصيل',
              onTap: () {
                Navigator.pop(bottomSheetContext);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scaffoldContext.mounted) {
                    _handleNormalFileMenuAction(scaffoldContext, 'info', file);
                  }
                });
              },
            ),
            _buildMenuItem(
              bottomSheetContext,
              icon: Icons.download,
              title: 'تحميل',
              iconColor: Colors.blue,
              onTap: () {
                Navigator.pop(bottomSheetContext);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scaffoldContext.mounted) {
                    _handleNormalFileMenuAction(
                      scaffoldContext,
                      'download',
                      file,
                    );
                  }
                });
              },
            ),
            Divider(height: 1),
            _buildMenuItem(
              bottomSheetContext,
              icon: isStarred ? Icons.star : Icons.star_border,
              title: isStarred ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
              iconColor: Colors.amber[700],
              onTap: () {
                Navigator.pop(bottomSheetContext);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scaffoldContext.mounted) {
                    _handleNormalFileMenuAction(
                      scaffoldContext,
                      'favorite',
                      file,
                    );
                  }
                });
              },
            ),
            _buildMenuItem(
              bottomSheetContext,
              icon: Icons.drive_file_move_rounded,
              title: 'نقل',
              iconColor: Colors.purple,
              onTap: () {
                Navigator.pop(bottomSheetContext);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scaffoldContext.mounted) {
                    _handleNormalFileMenuAction(scaffoldContext, 'move', file);
                  }
                });
              },
            ),
            Divider(height: 1),
            _buildMenuItem(
              bottomSheetContext,
              icon: Icons.delete,
              title: 'حذف',
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () {
                Navigator.pop(bottomSheetContext);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scaffoldContext.mounted) {
                    _handleNormalFileMenuAction(
                      scaffoldContext,
                      'delete',
                      file,
                    );
                  }
                });
              },
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveValue(
                bottomSheetContext,
                mobile: 8.0,
                tablet: 12.0,
                desktop: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ دالة لنقل المجلد
  Future<void> _moveFolder(
    BuildContext context,
    String folderId,
    String? targetFolderId,
    String folderName,
  ) async {
    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(width: 16),
              Text('جاري نقل المجلد...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );
    }

    // ✅ نقل المجلد
    final success = await folderController.moveFolder(
      folderId: folderId,
      targetFolderId: targetFolderId,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم نقل المجلد بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ فشل نقل المجلد - الميزة قيد التطوير'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
