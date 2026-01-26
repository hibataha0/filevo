import 'package:filevo/responsive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/views/fileViewer/file_actions_service.dart';
import 'package:filevo/views/fileViewer/file_details_page.dart';
import 'package:filevo/views/folders/room_comments_page.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filevo/constants/app_colors.dart';
import 'package:filevo/dialogs/folder_protection_dialogs.dart';
import 'package:filevo/views/folders/share_folder_with_room_page.dart';
import 'package:filevo/views/fileViewer/folder_actions_service.dart';

class FilesListView extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final EdgeInsetsGeometry? itemMargin;
  final bool showMoreOptions;
  final void Function(Map<String, dynamic>)? onItemTap;
  final String? roomId;
  final void Function()? onFileRemoved;
  final void Function(Map<String, dynamic>)? onRoomDetailsTap;
  final void Function(Map<String, dynamic>)? onRoomEditTap;
  final VoidCallback? onFileUpdated; // ✅ callback عند تحديث ملف

  const FilesListView({
    Key? key,
    required this.items,
    this.itemMargin,
    this.showMoreOptions = true,
    this.onItemTap,
    this.roomId,
    this.onFileRemoved,
    this.onRoomDetailsTap,
    this.onRoomEditTap,
    this.onFileUpdated,
  }) : super(key: key);

  @override
  State<FilesListView> createState() => _FilesListViewState();
}

class _FilesListViewState extends State<FilesListView> {
  Map<String, dynamic>? _roomData;
  final Map<String, bool> _starStates = {};
  final Map<String, bool> _hoverStates = {};

  @override
  void initState() {
    super.initState();
    _initializeStarStates();
    if (widget.roomId != null) {
      _loadRoomData();
    }
  }

  void _loadRoomData() async {
    if (widget.roomId == null) return;
    final roomController = Provider.of<RoomController>(context, listen: false);
    final response = await roomController.getRoomById(widget.roomId!);
    if (mounted) {
      setState(() {
        _roomData = response?['room'];
      });
    }
  }

  @override
  void didUpdateWidget(FilesListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _initializeStarStates();
    }
  }

  void _initializeStarStates() {
    _starStates.clear();
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Color(0xFF1E1E1E) : Color(0xFFF8F9FA);
    final cardColor = isDark ? Color(0xFF2D2D2D) : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListView.separated(
        itemCount: widget.items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return _buildListItem(context, item, cardColor);
        },
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    Map<String, dynamic> item,
    Color cardColor,
  ) {
    final type = item['type'] as String?;
    final iconSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 22.0,
      tablet: 24.0,
      desktop: 26.0,
    );

    final itemId = item['originalData']?['_id']?.toString() ?? item['title'];
    final isHovered = _hoverStates[itemId] ?? false;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoverStates[itemId] = true),
      onExit: (_) => setState(() => _hoverStates[itemId] = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0, isHovered ? -2 : 0, 0),
        child: Card(
          elevation: isHovered ? 8 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isHovered
                  ? _getTypeColor(type).withOpacity(0.3)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          color: cardColor,
          shadowColor: Colors.black.withOpacity(0.1),
          child: InkWell(
            onTap: () => _handleItemTap(item),
            borderRadius: BorderRadius.circular(20),
            splashColor: _getTypeColor(type).withOpacity(0.1),
            highlightColor: _getTypeColor(type).withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Leading Icon/Thumbnail with animated background
                  _buildLeadingWidget(item, iconSize, type, isHovered),
                  const SizedBox(width: 16),

                  // Main Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title with animated color
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveValue(
                              context,
                              mobile: 16.0,
                              tablet: 17.0,
                              desktop: 18.0,
                            ),
                            fontWeight: FontWeight.w700,
                            color: isHovered
                                ? _getTypeColor(type)
                                : Theme.of(context).colorScheme.onSurface,
                            height: 1.3,
                          ),
                          child: Text(
                            item['title'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subtitle with icon
                        _buildSubtitle(context, item),
                      ],
                    ),
                  ),

                  // Trailing: Actions or Arrow
                  const SizedBox(width: 12),
                  if (widget.showMoreOptions)
                    _buildMenuButton(context, item)
                  else
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isHovered
                            ? _getTypeColor(type).withOpacity(0.1)
                            : Theme.of(context).colorScheme.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: ResponsiveUtils.getResponsiveValue(
                          context,
                          mobile: 14.0,
                          tablet: 16.0,
                          desktop: 18.0,
                        ),
                        color: isHovered
                            ? _getTypeColor(type)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildLeadingWidget(
    Map<String, dynamic> item,
    double iconSize,
    String? type,
    bool isHovered,
  ) {
    final url = item['url'] as String?;
    final thumbnailUrl = item['thumbnailUrl'] as String?;

    // For images and videos with thumbnails
    if ((type == 'image' || type == 'video') &&
        (thumbnailUrl != null || url != null)) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getTypeColor(type).withOpacity(0.8),
              _getTypeColor(type).withOpacity(0.4),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: _getTypeColor(type).withOpacity(0.3),
              blurRadius: isHovered ? 12 : 8,
              offset: Offset(0, isHovered ? 4 : 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              // Thumbnail
              if (thumbnailUrl != null || url != null)
                _buildNetworkImage(thumbnailUrl ?? url!, type, iconSize),

              // Play icon for videos
              if (type == 'video')
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // For other file types
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isHovered
              ? [
                  _getTypeColor(type).withOpacity(0.9),
                  _getTypeColor(type).withOpacity(0.6),
                ]
              : [
                  _getTypeColor(type).withOpacity(0.7),
                  _getTypeColor(type).withOpacity(0.4),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: _getTypeColor(type).withOpacity(0.2),
            blurRadius: isHovered ? 12 : 8,
            offset: Offset(0, isHovered ? 4 : 2),
          ),
        ],
      ),
      child: _buildFileTypeIcon(type, iconSize, false),
    );
  }

  /// ✅ بناء صورة من الشبكة مع headers للـ Authorization
  Widget _buildNetworkImage(String imageUrl, String? type, double iconSize) {
    // ✅ التحقق من أن الصورة تحتاج إلى token
    final needsToken =
        imageUrl.contains('/api/') ||
        imageUrl.contains('/download/') ||
        imageUrl.contains('/view');

    return FutureBuilder<Map<String, String>?>(
      future: needsToken ? _getImageHeaders() : Future.value(null),
      builder: (context, snapshot) {
        return CachedNetworkImage(
          imageUrl: imageUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          httpHeaders: snapshot.data,
          memCacheWidth: 200,
          memCacheHeight: 200,
          placeholder: (context, url) => Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_getTypeColor(type)),
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            return _buildFileTypeIcon(type, iconSize, true);
          },
        );
      },
    );
  }

  /// ✅ الحصول على headers للصور التي تحتاج token
  Future<Map<String, String>?> _getImageHeaders() async {
    try {
      final token = await StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        return {'Authorization': 'Bearer $token'};
      }
    } catch (e) {
      print('❌ Error getting token for image headers: $e');
    }
    return null;
  }

  Widget _buildFileTypeIcon(String? type, double iconSize, bool isThumbnail) {
    IconData icon;
    Color iconColor = Colors.white;

    switch (type) {
      case 'image':
        icon = Icons.image_rounded;
        break;
      case 'video':
        icon = Icons.videocam_rounded;
        break;
      case 'audio':
        icon = Icons.music_note_rounded;
        break;
      case 'pdf':
        icon = Icons.picture_as_pdf_rounded;
        break;
      case 'zip':
      case 'rar':
      case 'archive':
        icon = Icons.folder_zip_rounded;
        break;
      case 'doc':
      case 'docx':
        icon = Icons.description_rounded;
        break;
      case 'xls':
      case 'xlsx':
        icon = Icons.table_chart_rounded;
        break;
      case 'ppt':
      case 'pptx':
        icon = Icons.slideshow_rounded;
        break;
      case 'txt':
        icon = Icons.text_snippet_rounded;
        break;
      case 'room':
        icon = Icons.meeting_room_rounded;
        break;
      case 'folder':
        icon = Icons.folder_rounded;
        break;
      case 'category':
        icon = Icons.category_rounded;
        break;
      default:
        icon = Icons.insert_drive_file_rounded;
    }

    return Center(
      child: Icon(
        icon,
        color: iconColor,
        size: isThumbnail ? 24 : iconSize + 8,
      ),
    );
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'room':
        return Color(0xFF6366F1); // Indigo
      case 'folder':
        return Color(0xFFF59E0B); // Amber
      case 'category':
        return Color(0xFF8B5CF6); // Violet
      case 'image':
        return Color(0xFF10B981); // Emerald
      case 'video':
        return Color(0xFFEF4444); // Red
      case 'pdf':
        return Color(0xFFDC2626); // Red 600
      case 'audio':
        return Color(0xFF8B5CF6); // Violet
      case 'doc':
      case 'docx':
        return Color(0xFF3B82F6); // Blue
      case 'xls':
      case 'xlsx':
        return Color(0xFF10B981); // Emerald
      case 'ppt':
      case 'pptx':
        return Color(0xFFF97316); // Orange
      default:
        return Color(0xFF6B7280); // Gray
    }
  }

  Widget _buildSubtitle(BuildContext context, Map<String, dynamic> item) {
    final type = item['type'] as String?;
    final size = item['size'] as String? ?? '';
    final fileCount = item['fileCount'] as int? ?? 0;

    final subtitleStyle = TextStyle(
      fontSize: ResponsiveUtils.getResponsiveValue(
        context,
        mobile: 13.0,
        tablet: 14.0,
        desktop: 15.0,
      ),
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return Row(
      children: [
        Icon(
          _getSubtitleIcon(type),
          size: 14,
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            type == 'room' || type == 'folder'
                ? '${_getCountText(context, fileCount)} • $size'
                : size,
            style: subtitleStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  IconData _getSubtitleIcon(String? type) {
    switch (type) {
      case 'room':
      case 'folder':
        return Icons.folder_open_rounded;
      case 'image':
        return Icons.photo_size_select_actual_rounded;
      case 'video':
        return Icons.video_library_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'audio':
        return Icons.audiotrack_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  String _getCountText(BuildContext context, int count) {
    if (count == 0) {
      return S.of(context).noItems;
    } else if (count == 1) {
      return S.of(context).oneItem;
    } else {
      return '$count ${S.of(context).item}';
    }
  }

  Widget _buildMenuButton(BuildContext context, Map<String, dynamic> item) {
    final type = item['type'] as String?;
    final itemId = item['originalData']?['_id']?.toString() ?? item['title'];
    final isHovered = _hoverStates[itemId] ?? false;

    if (type != 'room' && type != 'category' && type != 'folder') {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isHovered
              ? _getTypeColor(type).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            color: isHovered
                ? _getTypeColor(type)
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          itemBuilder: (context) {
            return widget.roomId != null
                ? _buildSharedFileMenuItems(context, item)
                : _buildNormalFileMenuItems(context, item);
          },
          onSelected: (value) {
            if (widget.roomId != null) {
              _handleSharedFileMenuAction(context, value, item);
            } else {
              _handleNormalFileMenuAction(context, value, item);
            }
          },
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isHovered
            ? _getTypeColor(type).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          Icons.more_vert_rounded,
          color: isHovered
              ? _getTypeColor(type)
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onPressed: () {
          if (type == 'room') {
            _showRoomMenu(context, item);
          } else if (type == 'category') {
            _showCategoryMenu(context, item);
          } else if (type == 'folder') {
            _showFolderMenu(context, item);
          }
        },
      ),
    );
  }

  bool _getStarState(Map<String, dynamic> item) {
    final originalData = item['originalData'] ?? item['itemData'];
    if (originalData is Map<String, dynamic>) {
      final itemId = originalData['_id']?.toString();
      if (itemId != null) {
        return _starStates[itemId] ?? originalData['isStarred'] ?? false;
      }
    }
    return false;
  }

  void _handleItemTap(Map<String, dynamic> item) {
    final type = item['type'] as String?;

    if (type == 'room' || type == 'folder' || type == 'category') {
      if (widget.onItemTap != null) {
        widget.onItemTap!(item);
      }
    } else {
      final originalData = item['originalData'] ?? item['itemData'];
      final fileData = {
        'name': item['title'] ?? item['name'] ?? originalData?['name'],
        'url': item['url'] ?? '',
        'type': item['type'] ?? 'file',
        'path': item['path'] ?? originalData?['path'],
        'originalData': originalData ?? {},
      };
      FileActionsService.openFile(fileData, widget.onItemTap);
    }
  }
  // ==================== FILE MENU ITEMS ====================

  List<PopupMenuEntry<String>> _buildSharedFileMenuItems(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final originalData = item['originalData'] ?? item['itemData'] ?? {};
    final fileId = originalData['_id']?.toString();
    final isStarred = fileId != null
        ? (_starStates[fileId] ?? originalData['isStarred'] ?? false)
        : (originalData['isStarred'] ?? false);

    return [
      PopupMenuItem<String>(
        value: 'open',
        child: Row(
          children: [
            const Icon(Icons.open_in_new_rounded, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(S.of(context).open),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'info',
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Colors.teal,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(S.of(context).viewDetails),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'download',
        child: Row(
          children: [
            const Icon(Icons.download_rounded, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(S.of(context).download),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'comments',
        child: Row(
          children: [
            const Icon(
              Icons.comment_rounded,
              color: Color(0xFFF59E0B),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(S.of(context).comments),
          ],
        ),
      ),
      const PopupMenuDivider(),
      // PopupMenuItem<String>(
      //   value: 'favorite',
      //   child: Row(
      //     children: [
      //       Icon(
      //         isStarred ? Icons.star_rounded : Icons.star_border_rounded,
      //         color: Colors.amber[700],
      //         size: 20,
      //       ),
      //       const SizedBox(width: 8),
      //       Text(
      //         isStarred
      //             ? S.of(context).removeFromFavorites
      //             : S.of(context).addToFavorites,
      //       ),
      //     ],
      //   ),
      // ),
      PopupMenuItem<String>(
        value: 'save',
        child: Row(
          children: [
            const Icon(Icons.save_rounded, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(S.of(context).saveToMyAccount),
          ],
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'remove_from_room',
        child: Row(
          children: [
            const Icon(Icons.link_off_rounded, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Text(
              S.of(context).removeFromRoom,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    ];
  }

  List<PopupMenuEntry<String>> _buildNormalFileMenuItems(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final originalData = item['originalData'] ?? item['itemData'] ?? {};
    final fileId = originalData['_id']?.toString();
    final isStarred = fileId != null
        ? (_starStates[fileId] ?? originalData['isStarred'] ?? false)
        : (originalData['isStarred'] ?? false);

    return [
      PopupMenuItem<String>(
        value: 'open',
        child: Row(
          children: [
            const Icon(Icons.open_in_new_rounded, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(S.of(context).open),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'info',
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Colors.teal,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(S.of(context).viewInfo),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'download',
        child: Row(
          children: [
            const Icon(Icons.download_rounded, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(S.of(context).download),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'edit',
        child: Row(
          children: [
            const Icon(Icons.edit_rounded, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Text(S.of(context).edit),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'share',
        child: Row(
          children: [
            const Icon(Icons.share_rounded, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(S.of(context).share),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'move',
        child: Row(
          children: [
            const Icon(
              Icons.drive_file_move_rounded,
              color: Colors.purple,
              size: 20,
            ),
            const SizedBox(width: 8),
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
            const SizedBox(width: 8),
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
            const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              S.of(context).delete,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    ];
  }

  // ==================== MENU ACTION HANDLERS ====================

  void _handleSharedFileMenuAction(
    BuildContext context,
    String action,
    Map<String, dynamic> item,
  ) async {
    final originalData = item['originalData'] ?? item['itemData'] ?? {};
    final fileId = originalData['_id']?.toString();
    final fileData = {
      'name': item['title'] ?? item['name'],
      'url': item['url'] ?? '',
      'type': item['type'] ?? 'file',
      'originalData': originalData,
    };

    switch (action) {
      case 'open':
        FileActionsService.openFile(fileData, widget.onItemTap);
        break;

      case 'info':
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
        if (widget.roomId != null && fileId != null) {
          final roomController = Provider.of<RoomController>(
            context,
            listen: false,
          );
          final fileName = fileData['name'] ?? originalData['name'];
          FileActionsService.downloadRoomFile(
            context,
            roomController,
            widget.roomId!,
            fileId,
            fileName,
          );
        }
        break;

      case 'comments':
        if (widget.roomId != null && fileId != null) {
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
        break;

      case 'favorite':
        final fileController = Provider.of<FileController>(
          context,
          listen: false,
        );
        await FileActionsService.toggleStar(
          context,
          fileController,
          fileData,
          onToggle: () => _updateStarState(fileData),
        );
        break;

      case 'save':
        await _saveFileFromRoom(context, item);
        break;

      case 'remove_from_room':
        await _removeFileFromRoom(context, item);
        break;
    }
  }

  void _handleNormalFileMenuAction(
    BuildContext context,
    String action,
    Map<String, dynamic> item,
  ) {
    final originalData = item['originalData'] ?? item['itemData'] ?? {};
    final fileData = {
      'name': item['title'] ?? item['name'] ?? originalData['name'],
      'url': item['url'] ?? '',
      'type': item['type'] ?? 'file',
      'path': item['path'] ?? originalData['path'],
      'originalData': originalData,
    };

    switch (action) {
      case 'open':
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
        FileActionsService.downloadFile(context, fileData);
        break;

      case 'edit':
        FileActionsService.editFile(context, fileData)
            .then((updated) {
              // ✅ إذا تم تحديث الملف، استدعي callback لإعادة تحميل البيانات
              print('🔄 [FilesListView] Edit file result: $updated');
              print(
                '🔄 [FilesListView] onFileRemoved is null: ${widget.onFileRemoved == null}',
              );
              if (updated == true) {
                // ✅ استدعاء onFileUpdated إذا كان موجوداً
                if (widget.onFileUpdated != null) {
                  widget.onFileUpdated!();
                } else if (widget.onFileRemoved != null) {
                  // ✅ fallback to onFileRemoved if onFileUpdated is not provided
                  widget.onFileRemoved!();
                }
              } else {
                print('❌ [FilesListView] File not updated, skipping refresh');
              }
            })
            .catchError((error) {
              print('❌ [FilesListView] Error in editFile: $error');
            });
        break;

      case 'share':
        FileActionsService.shareFile(context, fileData);
        break;

      case 'move':
        _showMoveFileDialog(context, item);
        break;

      case 'favorite':
        final fileController = Provider.of<FileController>(
          context,
          listen: false,
        );
        FileActionsService.toggleStar(
          context,
          fileController,
          fileData,
          onToggle: () => _updateStarState(fileData),
        );
        break;

      case 'delete':
        final fileController = Provider.of<FileController>(
          context,
          listen: false,
        );
        FileActionsService.deleteFile(
          context,
          fileController,
          fileData,
          onLocalUpdate: () {
            // ✅ استدعاء onFileRemoved إذا كان موجوداً لإعادة تحميل الصفحة
            if (widget.onFileRemoved != null) {
              widget.onFileRemoved!();
            }
          },
        );
        break;
    }
  }

  // ==================== ROOM, CATEGORY, FOLDER MENUS ====================

  void _showRoomMenu(BuildContext context, Map<String, dynamic> room) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBottomSheetHeader(
                context,
                room['title'] as String? ?? S.of(context).room,
              ),
              if (widget.onItemTap != null)
                _buildBottomSheetItem(
                  context,
                  icon: Icons.open_in_new,
                  title: S.of(context).open,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onItemTap!(room);
                  },
                ),
              if (widget.onRoomDetailsTap != null)
                _buildBottomSheetItem(
                  context,
                  icon: Icons.info_outline,
                  title: S.of(context).viewInfo,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onRoomDetailsTap!(room);
                  },
                ),
              if (widget.onRoomEditTap != null)
                _buildBottomSheetItem(
                  context,
                  icon: Icons.edit,
                  title: S.of(context).edit,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onRoomEditTap!(room);
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryMenu(BuildContext context, Map<String, dynamic> category) {
    final parentContext = context; // ✅ حفظ الـ context الأصلي
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBottomSheetHeader(
                context,
                category['title'] as String? ?? S.of(context).category,
              ),
              if (widget.onItemTap != null)
                _buildBottomSheetItem(
                  context,
                  icon: Icons.open_in_new,
                  title: S.of(context).open,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onItemTap!(category);
                  },
                ),
              _buildBottomSheetItem(
                context,
                icon: Icons.info_outline,
                title: S.of(context).viewDetails,
                onTap: () {
                  Navigator.pop(context);
                  _showCategoryDetails(parentContext, category);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showSharedFolderMenu(
    BuildContext context,
    Map<String, dynamic> folder,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final folderId =
        (folder['folderId'] ?? folder['_id'] ?? folder['originalData']?['_id'])
            .toString();
    final folderName =
        folder['title'] ??
        folder['name'] ??
        folder['originalData']?['name'] ??
        S.of(context).folder;

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
            color: AppColors.getCardColor(isDarkMode),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.darkSurface : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // فتح المجلد
                      _buildBottomSheetItem(
                        context,
                        icon: Icons.open_in_new,
                        title: S.of(context).open,
                        onTap: () {
                          Navigator.pop(context);
                          _handleItemTap(folder);
                        },
                      ),

                      // عرض التفاصيل
                      _buildBottomSheetItem(
                        context,
                        icon: Icons.info_outline,
                        title: S.of(context).viewDetails,
                        onTap: () async {
                          Navigator.pop(context);
                          _showFolderInfo(context, folder);
                        },
                      ),

                       // تحميل المجلد (كـ ZIP)
                       _buildBottomSheetItem(
                         context,
                         icon: Icons.download_rounded,
                         title: S.of(context).download,
                         onTap: () {
                           Navigator.pop(context);
                           // ✅ دائماً استخدم التحميل العادي للمجلدات حتى لو كنا في روم
                           // لضمان عمل التحميل بشكل صحيح للمجلدات التي قد لا يدعمها endpoint الرومات
                           FolderActionsService.downloadFolder(context, folder);
                         },
                       ),

                      // التعليقات
                      _buildBottomSheetItem(
                        context,
                        icon: Icons.comment_outlined,
                        title: S.of(context).comments,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoomCommentsPage(
                                roomId: widget.roomId!,
                                targetType: 'folder',
                                targetId: folderId,
                              ),
                            ),
                          );
                        },
                      ),



                      const Divider(height: 1),

                      // حفظ إلى حسابي
                      _buildBottomSheetItem(
                        context,
                        icon: Icons.save_alt,
                        title: S.of(context).saveToMyAccount,
                        iconColor: Colors.green,
                        onTap: () {
                          Navigator.pop(context);
                          _showSaveFolderDialog(folderId, folderName);
                        },
                      ),

                      // إزالة من الغرفة
                      _buildBottomSheetItem(
                        context,
                        icon: Icons.link_off,
                        title: S.of(context).removeFromRoom,
                        iconColor: Colors.red,
                        textColor: Colors.red,
                        onTap: () {
                          Navigator.pop(context);
                          _showRemoveFolderFromRoomDialog(folderId, folderName);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showRemoveFolderFromRoomDialog(String folderId, String folderName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).removeFromRoom),
        content: Text(
          S.of(context).confirmRemoveFolderFromRoomWithName(folderName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final roomController = Provider.of<RoomController>(
                context,
                listen: false,
              );

              // ✅ تحديد إذا كان المجلد مشير بشكل مباشر للغرفة أو هو مجلد فرعي داخل مجلد مشترك
              bool isDirectlyShared = false;
              if (_roomData != null && _roomData!['folders'] != null) {
                final roomFolders = _roomData!['folders'] as List;
                isDirectlyShared = roomFolders.any((f) {
                  final fId = f['folderId'] is Map
                      ? f['folderId']['_id']
                      : f['folderId'];
                  return fId.toString() == folderId.toString();
                });
              }

              final success = isDirectlyShared
                  ? await roomController.unshareFolderFromRoom(
                      roomId: widget.roomId!,
                      folderId: folderId,
                    )
                  : await roomController.excludeFolderFromRoom(
                      roomId: widget.roomId!,
                      folderId: folderId,
                    );

              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(S.of(context).removeFolderFromRoomSuccess),
                      backgroundColor: Colors.green,
                    ),
                  );
                  if (widget.onFileRemoved != null) {
                    widget.onFileRemoved!();
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        roomController.errorMessage ??
                            S.of(context).failedToRemoveFolderFromRoom,
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              S.of(context).remove,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSaveFolderDialog(String folderId, String folderName) async {
    final roomController = Provider.of<RoomController>(context, listen: false);
    final success = await roomController.saveFolderFromRoom(
      roomId: widget.roomId!,
      folderId: folderId,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).changesSavedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              roomController.errorMessage ?? S.of(context).saveFolderFailure,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFolderMenu(BuildContext context, Map<String, dynamic> folder) {
    if (widget.roomId != null) {
      _showSharedFolderMenu(context, folder);
      return;
    }
    final parentContext = context; // ✅ حفظ الـ context الأصلي
    // ✅ الحصول على حالة المفضلة الحالية
    final folderId =
        folder['folderId'] as String? ??
        folder['_id'] as String? ??
        folder['folderData']?['_id'] as String? ??
        folder['originalData']?['_id'] as String?;
    final folderData =
        folder['folderData'] as Map<String, dynamic>? ??
        folder['originalData'] as Map<String, dynamic>? ??
        folder;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // ✅ الحصول على حالة المفضلة الحالية من _starStates
            final currentIsStarred = folderId != null
                ? (_starStates[folderId] ?? folderData['isStarred'] ?? false)
                : (folderData['isStarred'] ?? false);

            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildBottomSheetHeader(
                      context,
                      folder['title'] as String? ?? S.of(context).folder,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.onItemTap != null)
                              _buildBottomSheetItem(
                                context,
                                icon: Icons.open_in_new,
                                title: S.of(context).open,
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onItemTap!(folder);
                                },
                              ),
                            _buildBottomSheetItem(
                              context,
                              icon: Icons.info_outline,
                              title: S.of(context).viewInfo,
                              onTap: () {
                                Navigator.pop(context);
                                _showFolderInfo(parentContext, folder);
                              },
                            ),
                            _buildBottomSheetItem(
                              context,
                              icon: Icons.edit,
                              title: S.of(context).edit,
                              onTap: () {
                                Navigator.pop(context);
                                _showRenameDialog(parentContext, folder);
                              },
                            ),
                            if (widget.roomId == null)
                              _buildBottomSheetItem(
                                context,
                                icon: Icons.download_rounded,
                                title: S.of(context).download,
                                onTap: () {
                                  Navigator.pop(context);
                                  _downloadFolder(parentContext, folder);
                                },
                              ),
                            if (widget.roomId == null)
                              _buildBottomSheetItem(
                                context,
                                icon: Icons.share,
                                title: S.of(context).share,
                                onTap: () {
                                  Navigator.pop(context);
                                  _showShareDialog(parentContext, folder);
                                },
                              ),
                            if (widget.roomId == null)
                              _buildBottomSheetItem(
                                context,
                                icon: Icons.drive_file_move_rounded,
                                title: S.of(context).move,
                                iconColor: Colors.purple,
                                onTap: () {
                                  Navigator.pop(context);
                                  _showMoveFolderDialog(parentContext, folder);
                                },
                              ),
                            _buildBottomSheetItem(
                              context,
                              icon: currentIsStarred
                                  ? Icons.star_rounded
                                  : Icons.star_border,
                              title: currentIsStarred
                                  ? S.of(context).removeFromFavorites
                                  : S.of(context).addToFavorites,
                              iconColor: Colors.amber[700],
                              onTap: () {
                                Navigator.pop(context);
                                // ✅ استدعاء _toggleFavorite - سيتم تحديث الحالة تلقائياً
                                _toggleFavorite(parentContext, folder);
                              },
                            ),
                            if (widget.roomId == null)
                              _buildBottomSheetItem(
                                context,
                                icon: Icons.lock_outline,
                                title: S.of(context).lockFolder,
                                iconColor: Colors.orange,
                                onTap: () {
                                  Navigator.pop(context);
                                  _showProtectFolderDialog(parentContext, folder);
                                },
                              ),
                            const Divider(height: 1),
                            _buildBottomSheetItem(
                              context,
                              icon: Icons.delete,
                              title: S.of(context).delete,
                              textColor: Colors.red,
                              iconColor: Colors.red,
                              onTap: () {
                                Navigator.pop(context);
                                _showDeleteDialog(parentContext, folder);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==================== BOTTOM SHEET COMPONENTS ====================

  Widget _buildBottomSheetHeader(BuildContext context, String title) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColors.getTextPrimary(isDarkMode),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBottomSheetItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.getTextSecondary(isDarkMode),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppColors.getTextPrimary(isDarkMode),
        ),
      ),
      onTap: onTap,
    );
  }

  // ==================== HELPER METHODS ====================

  void _updateStarState(Map<String, dynamic> fileData) {
    final fileId = fileData['originalData']?['_id']?.toString();
    if (fileId != null && mounted) {
      setState(() {
        _starStates[fileId] = fileData['originalData']['isStarred'] ?? false;
      });
    }
  }

  Future<void> _saveFileFromRoom(
    BuildContext context,
    Map<String, dynamic> item,
  ) async {
    if (widget.roomId == null) return;

    final originalData = item['originalData'] ?? item['itemData'] ?? {};
    final fileId = originalData['_id']?.toString();

    if (fileId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${S.of(context).fileIdNotFound}'),
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
      final success = await roomController.saveFileFromRoom(
        roomId: widget.roomId!,
        fileId: fileId,
        parentFolderId: null,
      );

      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${S.of(context).fileSavedToAccount}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              roomController.errorMessage ?? S.of(context).failedToSaveFile,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${S.of(context).error} ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeFileFromRoom(
    BuildContext context,
    Map<String, dynamic> item,
  ) async {
    if (widget.roomId == null) return;

    final originalData = item['originalData'] ?? item['itemData'] ?? {};
    final fileId = originalData['_id']?.toString();

    if (fileId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${S.of(context).fileIdNotFound}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).removeFileFromRoom),
        content: Text(
          S
              .of(context)
              .removeFileFromRoomConfirm(item['title'] ?? S.of(context).file),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              S.of(context).remove,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      final roomController = Provider.of<RoomController>(
        context,
        listen: false,
      );

      // ✅ تحديد إذا كان الملف مشير بشكل مباشر للغرفة أو هو ملف داخل مجلد مشترك
      bool isDirectlyShared = false;
      if (_roomData != null && _roomData!['files'] != null) {
        final roomFiles = _roomData!['files'] as List;
        isDirectlyShared = roomFiles.any((f) {
          final fId = f['fileId'] is Map ? f['fileId']['_id'] : f['fileId'];
          return fId.toString() == fileId.toString();
        });
      }

      final success = isDirectlyShared
          ? await roomController.unshareFileFromRoom(
              roomId: widget.roomId!,
              fileId: fileId,
            )
          : await roomController.excludeFileFromRoom(
              roomId: widget.roomId!,
              fileId: fileId,
            );

      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isDirectlyShared
                ? '✅ ${S.of(context).fileRemovedFromRoom}'
                : '✅ ${S.of(context).fileRemovedFromRoomView}'),
            backgroundColor: Colors.green,
          ),
        );
        if (widget.onFileRemoved != null) {
          widget.onFileRemoved!();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              roomController.errorMessage ?? S.of(context).failedToRemoveFile,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${S.of(context).error} ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ==================== FOLDER SPECIFIC METHODS ====================

  void _showFolderInfo(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // ✅ التحقق من كلمة السر إذا كان المجلد محمياً
    final hasAccess = await _verifyProtectedFolderAccess(context, folder);
    if (!hasAccess) {
      return; // ✅ إيقاف العملية إذا لم يتم التحقق
    }

    // ✅ الحصول على folderId من جميع الأماكن المحتملة
    final folderId =
        folder['folderId'] as String? ??
        folder['_id'] as String? ??
        folder['folderData']?['_id'] as String? ??
        folder['originalData']?['_id'] as String?;

    final folderName =
        folder['title'] as String? ??
        folder['name'] as String? ??
        folder['folderData']?['name'] as String? ??
        folder['originalData']?['name'] as String? ??
        S.of(context).folder;

    final folderColor =
        folder['color'] as Color? ?? AppColors.getPrimary(isDarkMode);

    if (folderId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(S.of(context).folderIdNotFound)));
      }
      return;
    }

    // ✅ جلب تفاصيل المجلد من الباك إند
    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );

    Map<String, dynamic>? folderDetails;
    if (widget.roomId != null && widget.roomId!.isNotEmpty) {
      try {
        folderDetails = await folderController.getSharedFolderDetailsInRoom(
          folderId: folderId,
        );
      } catch (e) {
        // ✅ إذا فشل، حاول جلب تفاصيل المجلد العادية
        folderDetails = await folderController.getFolderDetails(
          folderId: folderId,
        );
      }
    } else {
      folderDetails = await folderController.getFolderDetails(
        folderId: folderId,
      );
    }

    if (folderDetails == null || folderDetails['folder'] == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).failedToFetchFolderInfo)),
        );
      }
      return;
    }

    final folderData = folderDetails['folder'] as Map<String, dynamic>;
    
    // ✅ استخدام totalItems (مجموع المجلدات والملفات المباشرة)
    // كبديل إذا كان filesCount المرجع من الباك إند هو 0
    final int displayCount = folderData['totalItems'] ?? folderData['filesCount'] ?? 0;

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: AppColors.getCardColor(isDarkMode),
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
                    _buildDetailItem(
                      context,
                      'folder',
                      '📁',
                      S.of(context).type,
                      S.of(context).folder,
                    ),
                    _buildDetailItem(
                      context,
                      'size',
                      '💾',
                      S.of(context).size,
                      _formatBytes(folderData['size'] ?? 0),
                    ),
                    _buildDetailItem(
                      context,
                      'files',
                      '📄',
                      S.of(context).filesCount,
                      '$displayCount',
                    ),
                    _buildDetailItem(
                      context,
                      'subfolders',
                      '📂',
                      S.of(context).subfoldersCount,
                      '${folderData['subfoldersCount'] ?? 0}',
                    ),
                    _buildDetailItem(
                      context,
                      'time',
                      '🕐',
                      S.of(context).createdAt,
                      _formatDate(folderData['createdAt']),
                    ),
                    _buildDetailItem(
                      context,
                      'edit',
                      '✏️',
                      S.of(context).detailUpdatedAt,
                      _formatDate(folderData['updatedAt']),
                    ),
                    _buildDetailItem(
                      context,
                      'description',
                      '📝',
                      S.of(context).description,
                      folderData['description']?.isNotEmpty == true
                          ? folderData['description']
                          : "—",
                    ),
                    _buildDetailItem(
                      context,
                      'tags',
                      '🏷️',
                      S.of(context).tags,
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
                            context,
                            'share',
                            '👥',
                            S.of(context).sharedWith,
                            (folderData['sharedWith'] as List)
                                .map<String>(
                                  (u) =>
                                      u['user']?['email']?.toString() ??
                                      u['email']?.toString() ??
                                      '',
                                )
                                .where((email) => email.isNotEmpty)
                                .join(', '),
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

  String _formatBytes(int bytes) {
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

  String _formatDate(dynamic date) {
    if (date == null) return "—";
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "—";
    }
  }

  Widget _buildDetailItem(
    BuildContext context,
    String type,
    String emoji,
    String label,
    String value,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color getIconColor() {
      switch (type) {
        case 'folder':
          return Color(0xFF10B981);
        case 'size':
          return Color(0xFFF59E0B);
        case 'files':
          return Color(0xFF3B82F6);
        case 'subfolders':
          return Color(0xFF8B5CF6);
        case 'time':
          return Color(0xFFEF4444);
        case 'edit':
          return Color(0xFF8B5CF6);
        case 'description':
          return Color(0xFF4F6BED);
        case 'tags':
          return Color(0xFFEC4899);
        case 'share':
          return Color(0xFF06B6D4);
        default:
          return Color(0xFF6B7280);
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.darkSurface : Colors.grey[200]!,
        ),
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
                    color: AppColors.getTextSecondary(isDarkMode),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.getTextPrimary(isDarkMode),
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

  void _showRenameDialog(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    if (!context.mounted) return;
    // ✅ التحقق من كلمة السر إذا كان المجلد محمياً
    final hasAccess = await _verifyProtectedFolderAccess(context, folder);
    if (!hasAccess) {
      return; // ✅ إيقاف العملية إذا لم يتم التحقق
    }

    // ✅ الحصول على folderId من جميع الأماكن المحتملة (للمجلدات الفرعية)
    final folderId =
        folder['folderId'] as String? ??
        folder['_id'] as String? ??
        folder['folderData']?['_id'] as String? ??
        folder['originalData']?['_id'] as String?;

    final folderName =
        folder['title'] as String? ??
        folder['name'] as String? ??
        folder['folderData']?['name'] as String? ??
        folder['originalData']?['name'] as String? ??
        S.of(context).folder;

    final folderData =
        folder['folderData'] as Map<String, dynamic>? ??
        folder['originalData'] as Map<String, dynamic>? ??
        folder;

    final nameController = TextEditingController(text: folderName);
    final descriptionController = TextEditingController(
      text: (folderData['description'] as String?) ?? '',
    );
    final tagsController = TextEditingController(
      text: ((folderData['tags'] as List?)?.join(', ')) ?? '',
    );

    final scaffoldContext = context; // ✅ حفظ context الأصلي

    if (folderId == null) {
      if (scaffoldContext.mounted) {
        ScaffoldMessenger.of(
          scaffoldContext,
        ).showSnackBar(SnackBar(content: Text(S.of(context).folderIdNotFound)));
      }
      return;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).editFolder),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: S.of(context).folderName,
                  hintText: S.of(context).folderNameHint,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.folder),
                ),
                autofocus: true,
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: S.of(context).description,
                  hintText: S.of(context).descriptionHint,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextField(
                controller: tagsController,
                decoration: InputDecoration(
                  labelText: S.of(context).tags,
                  hintText: S.of(context).tagsHint,
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
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(S.of(context).enterFolderName)),
                );
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
                folderId,
                newName,
                description.isEmpty ? null : description,
                tags.isEmpty ? null : tags,
              );
            },
            child: Text(S.of(context).save),
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
            content: Text(S.of(scaffoldContext).folderUpdateSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        // ✅ إعادة تحميل البيانات
        if (widget.onFileRemoved != null) {
          widget.onFileRemoved!();
        }
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text(
              folderController.errorMessage ??
                  S.of(scaffoldContext).folderUpdateFailed,
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showShareDialog(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    if (!context.mounted) return;
    final folderId =
        folder['folderId'] as String? ??
        folder['_id'] as String? ??
        folder['folderData']?['_id'] as String? ??
        folder['originalData']?['_id'] as String?;

    final folderName =
        folder['title'] as String? ??
        folder['name'] as String? ??
        folder['folderData']?['name'] as String? ??
        folder['originalData']?['name'] as String? ??
        S.of(context).folder;

    if (folderId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).folderIdNotFound)));
      return;
    }

    // ✅ تم السماح بمشاركة المجلدات المحمية في الرومات (يتم طلب كلمة السر عند فتحها)
    if (!context.mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ShareFolderWithRoomPage(folderId: folderId, folderName: folderName),
      ),
    );

    // ✅ إعادة تحميل البيانات بعد المشاركة (إذا لزم الأمر)
    if (result == true && widget.onFileRemoved != null) {
      widget.onFileRemoved!();
    }
  }

  void _showMoveFolderDialog(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    if (!context.mounted) return;
    // ✅ التحقق من كلمة السر إذا كان المجلد محمياً
    final hasAccess = await _verifyProtectedFolderAccess(context, folder);
    if (!hasAccess) {
      return; // ✅ إيقاف العملية إذا لم يتم التحقق
    }

    // ✅ حفظ context الأصلي قبل فتح الـ modal
    final scaffoldContext = context;

    // ✅ الحصول على folderId من جميع الأماكن المحتملة (للمجلدات الفرعية)
    final folderId =
        folder['folderId'] as String? ??
        folder['_id'] as String? ??
        folder['folderData']?['_id'] as String? ??
        folder['originalData']?['_id'] as String?;

    final folderName =
        folder['title'] as String? ??
        folder['name'] as String? ??
        folder['folderData']?['name'] as String? ??
        folder['originalData']?['name'] as String? ??
        S.of(context).folder;

    final folderData =
        folder['folderData'] as Map<String, dynamic>? ??
        folder['originalData'] as Map<String, dynamic>? ??
        folder;

    final currentParentId = folderData['parentId']?.toString();
    if (folderId == null) {
      if (scaffoldContext.mounted) {
        ScaffoldMessenger.of(
          scaffoldContext,
        ).showSnackBar(SnackBar(content: Text(S.of(context).folderIdNotFound)));
      }
      return;
    }

    if (!scaffoldContext.mounted) return;

    showModalBottomSheet(
      context: scaffoldContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _FolderNavigationDialog(
        title: '${S.of(context).moveFolder} : $folderName',
        excludeFolderId: folderId,
        excludeParentId: currentParentId,
        onSelect: (targetFolderId) async {
          Navigator.pop(modalContext);
          if (scaffoldContext.mounted) {
            await _moveFolder(
              scaffoldContext,
              folderId,
              targetFolderId,
              folderName,
            );
          }
        },
      ),
    );
  }

  /// ✅ دالة لنقل المجلد
  Future<void> _moveFolder(
    BuildContext scaffoldContext,
    String folderId,
    String? targetFolderId,
    String folderName,
  ) async {
    final folderController = Provider.of<FolderController>(
      scaffoldContext,
      listen: false,
    );

    if (!scaffoldContext.mounted) return;

    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 16),
            Text(S.of(scaffoldContext).movingFolder),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    // ✅ نقل المجلد
    final success = await folderController.moveFolder(
      folderId: folderId,
      targetFolderId: targetFolderId,
    );

    if (scaffoldContext.mounted) {
      ScaffoldMessenger.of(scaffoldContext).hideCurrentSnackBar();

      if (success) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text(S.of(scaffoldContext).folderMoveSuccess),
            backgroundColor: AppColors.success,
          ),
        );

        // ✅ إعادة تحميل البيانات - استخدام callback إذا كان موجوداً
        if (widget.onFileRemoved != null) {
          widget.onFileRemoved!();
        }
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text(
              folderController.errorMessage ??
                  S.of(scaffoldContext).folderMoveFailed,
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _toggleFavorite(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    if (!context.mounted) return;
    // ✅ الحصول على folderId من جميع الأماكن المحتملة (للمجلدات الفرعية)
    final folderId =
        folder['folderId'] as String? ??
        folder['_id'] as String? ??
        folder['folderData']?['_id'] as String? ??
        folder['originalData']?['_id'] as String?;

    if (folderId == null) return;

    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );

    // ✅ حفظ الحالة الحالية قبل التبديل (للتأكد من التحديث الصحيح)
    final folderData = folder['folderData'] as Map<String, dynamic>?;

    // ✅ إظهار مؤشر التحميل
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
            Text(S.of(context).updating),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // ✅ استدعاء API لإضافة/إزالة من المفضلة
    final result = await folderController.toggleStarFolder(folderId: folderId);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (result['success'] == true) {
      // ✅ قراءة القيمة المحدثة من originalData مباشرة
      final updatedIsStarred = result['isStarred'] as bool? ?? false;
      final updatedFolder = result['folder'] as Map<String, dynamic>?;

      // ✅ تحديث بيانات المجلد المحلية فوراً لتغيير لون النجمة
      if (folderData != null) {
        folderData['isStarred'] = updatedIsStarred;
        if (updatedFolder != null) {
          // ✅ تحديث جميع البيانات من الـ response
          folderData.addAll(updatedFolder);
        }
      }

      // ✅ تحديث folder أيضاً مباشرة
      if (updatedFolder != null) {
        folder['folderData'] = updatedFolder;
        folder['isStarred'] = updatedIsStarred;

        // ✅ تحديث itemData أيضاً إذا كان موجوداً
        final itemData = folder['itemData'] as Map<String, dynamic>?;
        if (itemData != null) {
          final itemFolderData =
              itemData['folderData'] as Map<String, dynamic>?;
          if (itemFolderData != null) {
            itemFolderData['isStarred'] = updatedIsStarred;
          }
        }
      } else {
        folder['isStarred'] = updatedIsStarred;

        // ✅ تحديث itemData أيضاً إذا كان موجوداً
        final itemData = folder['itemData'] as Map<String, dynamic>?;
        if (itemData != null) {
          final itemFolderData =
              itemData['folderData'] as Map<String, dynamic>?;
          if (itemFolderData != null) {
            itemFolderData['isStarred'] = updatedIsStarred;
          }
        }
      }

      // ✅ تحديث _starStates مباشرة لتحديث الواجهة
      if (folderId != null && mounted) {
        setState(() {
          _starStates[folderId] = updatedIsStarred;

          // ✅ تحديث البيانات في widget.items أيضاً لضمان استمرار التحديث
          for (var item in widget.items) {
            final itemFolderId =
                item['folderId'] as String? ??
                item['_id'] as String? ??
                item['folderData']?['_id'] as String? ??
                item['originalData']?['_id'] as String?;
            if (itemFolderId == folderId) {
              item['isStarred'] = updatedIsStarred;
              if (item['folderData'] != null) {
                item['folderData']['isStarred'] = updatedIsStarred;
              }
              if (item['originalData'] != null) {
                item['originalData']['isStarred'] = updatedIsStarred;
              }
              break;
            }
          }
        });
      }

      // ✅ إظهار رسالة النجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedIsStarred
                ? S.of(context).folderAddedToFavorite
                : S.of(context).folderRemovedFromFavorite,
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );

      // ✅ لا نستدعي onFileRemoved هنا - التحديث يحدث تلقائياً في البيانات المحلية
      // ✅ مثل Grid، لا نحتاج لإعادة تحميل الصفحة
    } else {
      // ✅ إظهار رسالة الخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            folderController.errorMessage ?? S.of(context).favoriteUpdateFaile,
          ),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    if (!context.mounted) return;
    // ✅ التحقق من كلمة السر إذا كان المجلد محمياً
    final hasAccess = await _verifyProtectedFolderAccess(context, folder);
    if (!hasAccess) {
      return; // ✅ إيقاف العملية إذا لم يتم التحقق
    }

    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );
    final folderData = folder['folderData'] ?? folder['originalData'] ?? folder;

    FolderActionsService.deleteFolder(
      context,
      folderController,
      {
        'name': folder['title'] ?? folderData['name'],
        '_id': folder['folderId'] ?? folder['_id'] ?? folderData['_id'],
        'folderData': folderData,
      },
      onLocalUpdate: () {
        // ✅ تحديث القائمة بعد الحذف
        if (widget.onFileRemoved != null) {
          widget.onFileRemoved!();
        }
      },
    );
  }

  void _showMoveFileDialog(BuildContext context, Map<String, dynamic> file) async {
    if (!context.mounted) return;
    
    // ✅ حفظ context الأصلي قبل فتح الـ modal
    final scaffoldContext = context;

    final originalData = file['originalData'] ?? file;
    final fileId = originalData['_id']?.toString();
    final fileName =
        file['name'] as String? ??
        originalData['name'] as String? ??
        S.of(context).file;
    final currentParentId = originalData['parentFolderId']?.toString();

    if (fileId == null) {
      if (scaffoldContext.mounted) {
        ScaffoldMessenger.of(
          scaffoldContext,
        ).showSnackBar(SnackBar(content: Text(S.of(context).fileIdNotFound)));
      }
      return;
    }

    if (!scaffoldContext.mounted) return;

    showModalBottomSheet(
      context: scaffoldContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _FolderNavigationDialog(
        title: S.of(context).moveFileTitle(fileName),

        excludeFolderId:
            null, // ✅ الملف ليس مجلداً، لذا لا نحتاج لاستبعاد أي مجلد
        excludeParentId:
            currentParentId, // ✅ استبعاد المجلد الحالي فقط (لتجنب النقل لنفس المكان)
        onSelect: (targetFolderId) {
          Navigator.pop(modalContext);
          if (scaffoldContext.mounted) {
            _moveFile(scaffoldContext, fileId, targetFolderId, fileName);
          }
        },
      ),
    );
  }

  /// ✅ دالة لنقل الملف
  Future<void> _moveFile(
    BuildContext context, // ✅ نمرر context لأننا في دالة منفصلة
    String fileId,
    String? targetFolderId,
    String fileName,
  ) async {
    if (!mounted) return;

    final fileController = Provider.of<FileController>(context, listen: false);
    final token = await StorageService.getToken();

    if (token == null || !mounted) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(S.of(context).mustLoginFirst)));
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 16),
            Text(S.of(context).movingFile),
          ],
        ),
        // duration: Duration(seconds: 30),
      ),
    );

    final success = await fileController.moveFile(
      fileId: fileId,
      token: token,
      targetFolderId: targetFolderId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${S.of(context).fileMovedSuccessfully}'),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ إعادة تحميل البيانات إذا كان هناك callback
        if (widget.onFileRemoved != null) {
          widget.onFileRemoved!();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              fileController.errorMessage ??
                  '❌ ${S.of(context).failedToMoveFile}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showCategoryDetails(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    if (!context.mounted) return;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final categoryTitle =
        category['title'] as String? ?? S.of(context).category;
    final fileCount = category['fileCount'] as int? ?? 0;
    final size = category['size'] as String? ?? '0';
    final color =
        category['color'] as Color? ?? AppColors.getPrimary(isDarkMode);
    final icon = category['icon'] as IconData? ?? Icons.folder;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: AppColors.getCardColor(isDarkMode),
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
                    _buildDetailItem(
                      context,
                      'folder',
                      '📁',
                      S.of(context).type,
                      S.of(context).category,
                    ),
                    _buildDetailItem(
                      context,
                      'files',
                      '📄',
                      S.of(context).filesCount,
                      '$fileCount',
                    ),
                    _buildDetailItem(
                      context,
                      'size',
                      '💾',
                      S.of(context).totalSize,
                      size,
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

  // ✅ التحقق من الوصول لمجلد محمي قبل تنفيذ أي عملية
  Future<bool> _verifyProtectedFolderAccess(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    // ✅ البحث عن isProtected في جميع الأماكن المحتملة (للمجلدات الفرعية أيضاً)
    Map<String, dynamic>? folderData;
    bool isProtected = false;
    String protectionType = 'none';

    // ✅ محاولة 1: folder['folderData']
    folderData = folder['folderData'] as Map<String, dynamic>?;
    if (folderData != null) {
      isProtected = folderData['isProtected'] == true;
      protectionType = folderData['protectionType']?.toString() ?? 'none';
    }

    // ✅ محاولة 2: folder['originalData'] (للمجلدات الفرعية)
    if (!isProtected && folder['originalData'] != null) {
      final originalData = folder['originalData'] as Map<String, dynamic>?;
      if (originalData != null) {
        isProtected = originalData['isProtected'] == true;
        protectionType = originalData['protectionType']?.toString() ?? 'none';
        if (isProtected) {
          folderData = originalData;
        }
      }
    }

    // ✅ محاولة 3: folder مباشرة
    if (!isProtected) {
      isProtected = folder['isProtected'] == true;
      protectionType = folder['protectionType']?.toString() ?? 'none';
      if (isProtected) {
        folderData = folder;
      }
    }

    // ✅ محاولة 4: folder['itemData']?['folderData'] (للمجلدات في القوائم)
    if (!isProtected && folder['itemData'] != null) {
      final itemData = folder['itemData'] as Map<String, dynamic>?;
      if (itemData != null) {
        final itemFolderData = itemData['folderData'] as Map<String, dynamic>?;
        if (itemFolderData != null) {
          isProtected = itemFolderData['isProtected'] == true;
          protectionType =
              itemFolderData['protectionType']?.toString() ?? 'none';
          if (isProtected) {
            folderData = itemFolderData;
          }
        }
      }
    }

    // ✅ إذا لم يكن المجلد محمياً، لا حاجة للتحقق
    if (!isProtected || protectionType == 'none') {
      return true;
    }

    // ✅ الحصول على folderId و folderName من جميع الأماكن المحتملة
    final folderId =
        folder['folderId'] as String? ??
        folderData?['_id'] as String? ??
        folder['_id'] as String? ??
        folder['originalData']?['_id'] as String?;

    final folderName =
        folder['title'] as String? ??
        folderData?['name'] as String? ??
        folder['name'] as String? ??
        folder['originalData']?['name'] as String? ??
        S.of(context).folder;

    if (folderId == null) {
      return false;
    }

    // ✅ طلب كلمة السر
    final result = await showVerifyFolderAccessDialog(
      context,
      folderId,
      folderName,
      protectionType,
    );

    // ✅ إرجاع true إذا تم التحقق بنجاح
    return result['success'] == true;
  }

  /// ✅ تحميل مجلد عادي كـ ZIP
  Future<void> _downloadFolder(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    if (!context.mounted) return;

    // ✅ التحقق من كلمة السر إذا كان المجلد محمياً
    final hasAccess = await _verifyProtectedFolderAccess(context, folder);
    if (!hasAccess) {
      return; // ✅ إيقاف العملية إذا لم يتم التحقق
    }

    // ✅ الحصول على folderId من جميع الأماكن المحتملة
    final folderId =
        folder['folderId'] as String? ??
        folder['_id'] as String? ??
        folder['folderData']?['_id'] as String? ??
        folder['originalData']?['_id'] as String?;

    final folderName =
        folder['title'] as String? ??
        folder['name'] as String? ??
        folder['folderData']?['name'] as String? ??
        folder['originalData']?['name'] as String? ??
        S.of(context).folder;

    if (folderId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(S.of(context).folderIdNotFound)));
      }
      return;
    }

    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );

    FolderActionsService.downloadFolder(
      context,
      folder,
    );
  }

  /// 🔒 عرض dialog لقفل/إلغاء قفل المجلد
  Future<void> _showProtectFolderDialog(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    if (!context.mounted) return;

    // ✅ التحقق من كلمة السر إذا كان المجلد محمياً
    final hasAccess = await _verifyProtectedFolderAccess(context, folder);
    if (!hasAccess) {
      return; // ✅ إيقاف العملية إذا لم يتم التحقق
    }

    final scaffoldContext = context;

    final folderData =
        folder['folderData'] as Map<String, dynamic>? ??
        folder['originalData'] as Map<String, dynamic>? ??
        folder;
    final folderId =
        folder['folderId'] as String? ??
        folder['_id'] as String? ??
        folderData['_id'] as String?;
    final folderName =
        folder['title'] as String? ??
        folder['name'] as String? ??
        folderData['name'] as String? ??
        S.of(context).folder;

    if (folderId == null) {
      if (scaffoldContext.mounted) {
        ScaffoldMessenger.of(
          scaffoldContext,
        ).showSnackBar(SnackBar(content: Text(S.of(context).folderIdNotFound)));
      }
      return;
    }

    // ✅ جلب معلومات الحماية الحالية من السيرفر
    final folderController = Provider.of<FolderController>(
      scaffoldContext,
      listen: false,
    );

    bool isCurrentlyProtected = false;
    String currentProtectionType = 'none';

    // ✅ التحقق من البيانات المحلية أولاً
    isCurrentlyProtected = folderData['isProtected'] == true;
    currentProtectionType = folderData['protectionType']?.toString() ?? 'none';

    // ✅ محاولة جلب أحدث البيانات من السيرفر
    try {
      final folderDetails = await folderController.getFolderDetails(
        folderId: folderId,
      );

      if (folderDetails != null && folderDetails['folder'] != null) {
        final serverFolderData =
            folderDetails['folder'] as Map<String, dynamic>;
        final serverIsProtected = serverFolderData['isProtected'] == true;
        final serverProtectionType =
            serverFolderData['protectionType']?.toString() ?? 'none';

        // ✅ استخدام بيانات السيرفر إذا كانت متوفرة
        if (serverIsProtected || serverProtectionType != 'none') {
          isCurrentlyProtected = serverIsProtected;
          currentProtectionType = serverProtectionType;
        }
      }
    } catch (e) {
      print('⚠️ [FilesListView] Error fetching folder details: $e');
    }

    // ✅ فتح dialog الحماية
    await showSetFolderProtectionDialog(
      scaffoldContext,
      folderId,
      folderName,
      isCurrentlyProtected,
      currentProtectionType,
      widget.onFileRemoved,
    );
  }
}

// ✅ Widget للتنقل داخل المجلدات عند النقل
class _FolderNavigationDialog extends StatefulWidget {
  final String title;
  final String? excludeFolderId;
  final String? excludeParentId;
  final Function(String?) onSelect;

  const _FolderNavigationDialog({
    required this.title,
    this.excludeFolderId,
    this.excludeParentId,
    required this.onSelect,
  });

  @override
  State<_FolderNavigationDialog> createState() =>
      _FolderNavigationDialogState();
}

class _FolderNavigationDialogState extends State<_FolderNavigationDialog> {
  List<Map<String, dynamic>> _currentFolders = [];
  List<Map<String, String?>> _breadcrumb = []; // [{id: null, name: 'الجذر'}]
  bool _isLoading = false;
  String? _currentFolderId;
  bool _initializedBreadcrumb = false;

  @override
  void initState() {
    super.initState();
    // ✅ تأخير تحميل المجلدات حتى يكون الـ context جاهزاً
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadRootFolders();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ هنا مسموح نستخدم S.of(context) لأنه بعد initState وتم تهيئة Localizations
    if (!_initializedBreadcrumb) {
      _breadcrumb.add({'id': null, 'name': S.of(context).root});
      _initializedBreadcrumb = true;
    }
  }

  // ✅ جلب المجلدات الجذرية
  Future<void> _loadRootFolders() async {
    setState(() {
      _isLoading = true;
      _currentFolderId = null;
    });

    try {
      final folderController = Provider.of<FolderController>(
        context,
        listen: false,
      );
      final response = await folderController.getAllFolders(
        page: 1,
        limit: 100,
      );

      if (response != null && response['folders'] != null) {
        final folders = List<Map<String, dynamic>>.from(
          response['folders'] ?? [],
        );

        // ✅ تصفية المجلدات المستبعدة
        final filteredFolders = folders.where((f) {
          final fId = f['_id']?.toString();
          return fId != widget.excludeFolderId && fId != widget.excludeParentId;
        }).toList();

        setState(() {
          _currentFolders = filteredFolders;
          _isLoading = false;
        });
      } else {
        setState(() {
          _currentFolders = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading root folders: $e');
      setState(() {
        _currentFolders = [];
        _isLoading = false;
      });
    }
  }

  // ✅ جلب المجلدات الفرعية لمجلد معين
  Future<void> _loadSubfolders(String folderId, String folderName) async {
    setState(() {
      _isLoading = true;
      _currentFolderId = folderId;
    });

    // ✅ إضافة المجلد إلى breadcrumb
    setState(() {
      _breadcrumb.add({'id': folderId, 'name': folderName});
    });

    try {
      final folderController = Provider.of<FolderController>(
        context,
        listen: false,
      );

      // ✅ جلب جميع المجلدات الفرعية (limit كبير لضمان جلب جميع المجلدات)
      final response = await folderController.getFolderContents(
        folderId: folderId,
        page: 1,
        limit: 1000, // ✅ limit كبير لضمان جلب جميع المجلدات الفرعية
      );

      print('📁 Response for folder $folderId: ${response?.keys}');
      print('📁 Full response: $response');

      // ✅ محاولة جلب المجلدات الفرعية من response
      List<Map<String, dynamic>> subfolders = [];

      if (response != null) {
        // ✅ محاولة من subfolders مباشرة (الأولوية) - هذا يحتوي على جميع المجلدات الفرعية
        if (response['subfolders'] != null) {
          subfolders = List<Map<String, dynamic>>.from(
            response['subfolders'] ?? [],
          );
          print(
            '📁 Found ${subfolders.length} subfolders from subfolders field',
          );
        }
        // ✅ إذا لم تكن موجودة، جرب من contents (لكن هذا قد يكون محدود بـ pagination)
        if (subfolders.isEmpty && response['contents'] != null) {
          final contents = List<Map<String, dynamic>>.from(
            response['contents'] ?? [],
          );
          subfolders = contents
              .where((item) => item['type'] == 'folder')
              .toList();
          print('📁 Found ${subfolders.length} subfolders from contents field');
        }

        // ✅ إذا لم نجد أي مجلدات، جرب من folders مباشرة (fallback)
        if (subfolders.isEmpty && response['folders'] != null) {
          subfolders = List<Map<String, dynamic>>.from(
            response['folders'] ?? [],
          );
          print(
            '📁 Found ${subfolders.length} subfolders from folders field (fallback)',
          );
        }
      }

      print(
        '📁 Total found: ${subfolders.length} subfolders for folder $folderId ($folderName)',
      );

      // ✅ تصفية المجلدات المستبعدة
      final filteredFolders = subfolders.where((f) {
        final fId = f['_id']?.toString();
        return fId != widget.excludeFolderId && fId != widget.excludeParentId;
      }).toList();

      setState(() {
        _currentFolders = filteredFolders;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading subfolders: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      setState(() {
        _currentFolders = [];
        _isLoading = false;
      });

      // ✅ إظهار رسالة خطأ للمستخدم
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).subfoldersFetchError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ✅ العودة إلى مجلد سابق
  void _navigateToFolder(String? folderId) {
    if (folderId == null) {
      // ✅ العودة للجذر
      setState(() {
        _breadcrumb = [
          {'id': null, 'name': S.of(context).root},
        ];
      });
      _loadRootFolders();
    } else {
      // ✅ العودة لمجلد معين
      final index = _breadcrumb.indexWhere((b) => b['id'] == folderId);
      if (index >= 0) {
        setState(() {
          _breadcrumb = _breadcrumb.sublist(0, index + 1);
        });

        final folderName = _breadcrumb.last['name'] ?? S.of(context).folder;
        _loadSubfolders(folderId, folderName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final s = S.of(context);
    final folderName = _breadcrumb.last['name'] ?? s.folder;
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.getCardColor(isDarkMode),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ✅ Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.getPrimary(isDarkMode),
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
                    widget.title,
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

          // ✅ Breadcrumb
          if (_breadcrumb.length > 1)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDarkMode ? AppColors.darkSurface : Colors.grey[100],
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _breadcrumb.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final isLast = index == _breadcrumb.length - 1;

                          return GestureDetector(
                            onTap: isLast
                                ? null
                                : () => _navigateToFolder(item['id']),
                            child: Row(
                              children: [
                                if (index > 0) ...[
                                  Icon(
                                    Icons.chevron_left,
                                    size: 16,
                                    color: AppColors.getTextSecondary(
                                      isDarkMode,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                ],
                                Text(
                                  item['name'] ?? S.of(context).root,
                                  style: TextStyle(
                                    color: isLast
                                        ? AppColors.getPrimary(isDarkMode)
                                        : AppColors.getPrimary(
                                            isDarkMode,
                                          ).withOpacity(0.8),
                                    fontWeight: isLast
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    decoration: isLast
                                        ? null
                                        : TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ✅ Content
          Expanded(
            child: Column(
              children: [
                // ✅ خيار "اختيار الجذر" (إذا كنا في الجذر)
                if (_currentFolderId == null)
                  ListTile(
                    tileColor: AppColors.getCardColor(isDarkMode),
                    leading: Icon(
                      Icons.home_rounded,
                      color: AppColors.getPrimary(isDarkMode),
                    ),
                    title: Text(
                      S.of(context).moveToRoot,
                      style: TextStyle(
                        color: AppColors.getTextPrimary(isDarkMode),
                      ),
                    ),
                    subtitle: Text(
                      S.of(context).moveFolderToRoot,
                      style: TextStyle(
                        color: AppColors.getTextSecondary(isDarkMode),
                      ),
                    ),
                    onTap: () => widget.onSelect(null),
                  ),
                // ✅ خيار "اختيار المجلد الحالي" (إذا كنا داخل مجلد)
                if (_currentFolderId != null)
                  ListTile(
                    tileColor: AppColors.getCardColor(isDarkMode),
                    leading: Icon(Icons.check_circle, color: AppColors.success),
                    title: Text(
                      s.selectFolderNamed(folderName),
                      style: TextStyle(
                        color: AppColors.getTextPrimary(isDarkMode),
                      ),
                    ),
                    subtitle: Text(
                      S.of(context).moveToThisFolder,
                      style: TextStyle(
                        color: AppColors.getTextSecondary(isDarkMode),
                      ),
                    ),
                    onTap: () => widget.onSelect(_currentFolderId),
                  ),
                // ✅ Divider بين الخيارات وقائمة المجلدات
                Divider(
                  color: isDarkMode ? AppColors.darkSurface : Colors.grey[300],
                ),

                // ✅ قائمة المجلدات
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.getPrimary(
                                Theme.of(context).brightness == Brightness.dark,
                              ),
                            ),
                          ),
                        )
                      : _currentFolders.isEmpty
                      ? Center(
                          child: Text(
                            _currentFolderId == null
                                ? S.of(context).noFoldersAvailable
                                : S.of(context).noSubfoldersAvailable,
                            style: TextStyle(
                              color: AppColors.getTextSecondary(isDarkMode),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _currentFolders.length,
                          itemBuilder: (context, index) {
                            final folder = _currentFolders[index];
                            final folderId = folder['_id']?.toString();
                            final folderName =
                                folder['name'] ?? S.of(context).unnamedFolder;

                            return InkWell(
                              onTap: () {
                                // ✅ فتح المجلد لعرض المجلدات الفرعية
                                if (folderId != null) {
                                  print(
                                    '📂 Opening folder: $folderId ($folderName)',
                                  );
                                  _loadSubfolders(folderId, folderName);
                                } else {
                                  print(
                                    '⚠️ Folder ID is null for folder: $folderName',
                                  );
                                }
                              },
                              child: Container(
                                color: AppColors.getCardColor(isDarkMode),
                                child: ListTile(
                                  tileColor: AppColors.getCardColor(isDarkMode),
                                  leading: Icon(
                                    Icons.folder_rounded,
                                    color: AppColors.warning,
                                  ),
                                  title: Text(
                                    folderName,
                                    style: TextStyle(
                                      color: AppColors.getTextPrimary(
                                        isDarkMode,
                                      ),
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${folder['filesCount'] ?? 0} ${S.of(context).file}',
                                    style: TextStyle(
                                      color: AppColors.getTextSecondary(
                                        isDarkMode,
                                      ),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // ✅ زر اختيار المجلد (checkmark)
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            // ✅ اختيار المجلد مباشرة
                                            widget.onSelect(folderId);
                                          },
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            child: Icon(
                                              Icons.check_circle_outline,
                                              color: AppColors.success,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      // ✅ أيقونة chevron للإشارة إلى إمكانية فتح المجلد
                                      Icon(
                                        Icons.chevron_right,
                                        color: AppColors.getTextSecondary(
                                          isDarkMode,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
