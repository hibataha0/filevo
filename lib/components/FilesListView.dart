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
import 'package:filevo/views/folders/starred_folders_page_helpers.dart';

class FilesListView extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final EdgeInsetsGeometry? itemMargin;
  final bool showMoreOptions;
  final void Function(Map<String, dynamic>)? onItemTap;
  final String? roomId;
  final void Function()? onFileRemoved;
  final void Function(Map<String, dynamic>)? onRoomDetailsTap;
  final void Function(Map<String, dynamic>)? onRoomEditTap;

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
  }) : super(key: key);

  @override
  State<FilesListView> createState() => _FilesListViewState();
}

class _FilesListViewState extends State<FilesListView> {
  final Map<String, bool> _starStates = {};
  final Map<String, bool> _hoverStates = {};

  @override
  void initState() {
    super.initState();
    _initializeStarStates();
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

    final starState = _getStarState(item);
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
                Image.network(
                  thumbnailUrl ?? url!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildFileTypeIcon(type, iconSize, true);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getTypeColor(type),
                          ),
                        ),
                      ),
                    );
                  },
                ),

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
                ? '$_getCountText(context, fileCount) • $size'
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
        FileActionsService.editFile(context, fileData);
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
        FileActionsService.deleteFile(context, fileController, fileData);
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
                  _showCategoryDetails(context, category);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showFolderMenu(BuildContext context, Map<String, dynamic> folder) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
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
                            _showFolderInfo(context, folder);
                          },
                        ),
                        _buildBottomSheetItem(
                          context,
                          icon: Icons.edit,
                          title: S.of(context).edit,
                          onTap: () {
                            Navigator.pop(context);
                            _showRenameDialog(context, folder);
                          },
                        ),
                        _buildBottomSheetItem(
                          context,
                          icon: Icons.share,
                          title: S.of(context).share,
                          onTap: () {
                            Navigator.pop(context);
                            _showShareDialog(context, folder);
                          },
                        ),
                        _buildBottomSheetItem(
                          context,
                          icon: Icons.download,
                          title: S.of(context).download,
                          iconColor: Colors.blue,
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: Implement folder download
                          },
                        ),
                        _buildBottomSheetItem(
                          context,
                          icon: Icons.drive_file_move_rounded,
                          title: S.of(context).move,
                          iconColor: Colors.purple,
                          onTap: () {
                            Navigator.pop(context);
                            _showMoveFolderDialog(context, folder);
                          },
                        ),
                        _buildBottomSheetItem(
                          context,
                          icon: Icons.star_border,
                          title: S.of(context).addToFavorites,
                          iconColor: Colors.amber[700],
                          onTap: () {
                            Navigator.pop(context);
                            _toggleFavorite(context, folder);
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
                            _showDeleteDialog(context, folder);
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
  }

  // ==================== BOTTOM SHEET COMPONENTS ====================

  Widget _buildBottomSheetHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey[700]),
      title: Text(title, style: TextStyle(color: textColor ?? Colors.black87)),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${S.of(context).fileIdNotFound}'),
          backgroundColor: Colors.red,
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${S.of(context).error} ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${S.of(context).fileIdNotFound}'),
          backgroundColor: Colors.red,
        ),
      );
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

    try {
      final roomController = Provider.of<RoomController>(
        context,
        listen: false,
      );
      final success = await roomController.unshareFileFromRoom(
        roomId: widget.roomId!,
        fileId: fileId,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${S.of(context).fileRemovedFromRoom}'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${S.of(context).error} ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==================== FOLDER SPECIFIC METHODS ====================

  void _showFolderInfo(BuildContext context, Map<String, dynamic> folder) {
    // TODO: Implement folder info dialog
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Folder Info: ${folder['title']}')));
  }

  void _showRenameDialog(BuildContext context, Map<String, dynamic> folder) async {
    final folderName =
        folder['title']?.toString() ??
        folder['name']?.toString() ??
        S.of(context).folder;
    final folderId = folder['folderId'] as String?;
    final folderData = folder['folderData'] as Map<String, dynamic>?;

    final nameController = TextEditingController(text: folderName);
    final descriptionController = TextEditingController(
      text: folderData?['description'] as String? ?? '',
    );
    final tagsController = TextEditingController(
      text: (folderData?['tags'] as List?)?.join(', ') ?? '',
    );

    final scaffoldContext = context;

    if (folderId == null) {
      ScaffoldMessenger.of(
        scaffoldContext,
      ).showSnackBar(SnackBar(content: Text(S.of(context).folderIdNotFound)));
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).editFileMetadata),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: S.of(context).folderName,
                  hintText: S.of(context).folderName,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.folder),
                ),
                autofocus: true,
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: S.of(context).folderDescription,
                  hintText: S.of(context).folderDescriptionHint,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextField(
                controller: tagsController,
                decoration: InputDecoration(
                  labelText: S.of(context).folderTags,
                  hintText: S.of(context).folderTagsHint,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(S.of(context).pleaseEnterFolderName)),
                );
                return;
              }
              Navigator.pop(dialogContext, true);
            },
            child: Text(S.of(context).save),
          ),
        ],
      ),
    );

    if (result == true) {
      final folderController = Provider.of<FolderController>(
        scaffoldContext,
        listen: false,
      );

      final newName = nameController.text.trim();
      final description = descriptionController.text.trim();
      final tagsString = tagsController.text.trim();
      final tags = tagsString.isNotEmpty
          ? tagsString
                .split(',')
                .map((t) => t.trim())
                .where((t) => t.isNotEmpty)
                .toList()
          : <String>[];

      final success = await folderController.updateFolder(
        folderId: folderId,
        name: newName,
        description: description.isEmpty ? null : description,
        tags: tags.isEmpty ? null : tags,
      );

      if (scaffoldContext.mounted) {
        if (success) {
          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
            SnackBar(
              content: Text(S.of(scaffoldContext).folderUpdatedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
          // ✅ استدعاء callback لإعادة تحميل البيانات بعد التحديث الناجح
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
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showShareDialog(BuildContext context, Map<String, dynamic> folder) {
    // TODO: Implement share dialog
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Share Folder: ${folder['title']}')));
  }

  void _showMoveFolderDialog(
    BuildContext context,
    Map<String, dynamic> folder,
  ) async {
    final folderData = folder['folderData'] as Map<String, dynamic>? ?? {};
    final folderId = folder['folderId'] as String? ?? folderData['_id'] as String?;
    final folderName = folder['title'] as String ?? folderData['name'] ?? 'مجلد';

    if (folderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: معرف المجلد غير موجود')),
      );
      return;
    }

    // ✅ استخدام الدالة المساعدة من starred_folders_page_helpers
    await showMoveFolderDialogHelper(
      context,
      folder,
      onUpdated: () {
        // ✅ استدعاء callback لإعادة تحميل البيانات بعد النقل الناجح
        if (widget.onFileRemoved != null) {
          widget.onFileRemoved!();
        }
      },
    );
  }

  void _toggleFavorite(BuildContext context, Map<String, dynamic> folder) async {
    final folderId = folder['folderId'] as String?;
    if (folderId == null) return;

    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );

    final result = await folderController.toggleStarFolder(folderId: folderId);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (result['success'] == true) {
      // ✅ قراءة القيمة المحدثة من originalData مباشرة
      final updatedIsStarred = result['isStarred'] as bool? ?? false;
      final updatedFolder = result['folder'] as Map<String, dynamic>?;

      // ✅ تحديث بيانات المجلد المحلية فوراً لتغيير لون النجمة
      final folderData = folder['folderData'] as Map<String, dynamic>?;
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
        // ✅ تحديث isStarred مباشرة في item أيضاً
        folder['isStarred'] = updatedIsStarred;
      } else {
        folder['isStarred'] = updatedIsStarred;
      }

      // ✅ تحديث حالة النجمة في _starStates
      setState(() {
        _starStates[folderId] = updatedIsStarred;
      });

      // ✅ إظهار رسالة النجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedIsStarred
                ? S.of(context).folderAddedToFavorites
                : S.of(context).folderRemovedFromFavorites,
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // ✅ لا نستدعي onFileRemoved هنا لأن البيانات تم تحديثها محلياً بالفعل
      // ✅ هذا يمنع عمل refresh غير ضروري عند toggle favorite
    } else {
      // ✅ إظهار رسالة الخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? S.of(context).folderUpdateFailed,
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> folder) {
    // TODO: Implement delete dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Delete Folder: ${folder['title']}')),
    );
  }

  void _showMoveFileDialog(BuildContext context, Map<String, dynamic> file) {
    // TODO: Implement move file dialog
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Move File: ${file['title']}')));
  }

  void _showCategoryDetails(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    // TODO: Implement category details dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Category Details: ${category['title']}')),
    );
  }
}
