import 'package:flutter/material.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/views/folders/folder_contents_page.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/responsive.dart';
import 'package:filevo/components/FilesGridView.dart';
import 'package:filevo/views/folders/room_comments_page.dart';
import 'package:filevo/utils/room_permissions.dart';
import 'package:filevo/views/fileViewer/folder_actions_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RoomFoldersPage extends StatefulWidget {
  final String roomId;

  const RoomFoldersPage({super.key, required this.roomId});

  @override
  State<RoomFoldersPage> createState() => _RoomFoldersPageState();
}

class _RoomFoldersPageState extends State<RoomFoldersPage> {
  Map<String, dynamic>? roomData;
  bool isLoading = true;
  Map<String, Map<String, dynamic>> _folderDetailsCache =
      {}; // ✅ Cache لتفاصيل المجلدات
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoomData();
    });
  }

  Future<void> _loadRoomData() async {
    if (!mounted) return;

    final roomController = Provider.of<RoomController>(context, listen: false);
    final response = await roomController.getRoomById(widget.roomId);

    if (mounted) {
      setState(() {
        roomData = response?['room'];
        isLoading = false;
      });

      // ✅ مسح الـ cache القديم
      _folderDetailsCache.clear();
      // ✅ جلب تفاصيل المجلدات بشكل async لتحديث filesCount و size
      _loadFoldersDetails();
    }
  }

  // ✅ جلب تفاصيل جميع المجلدات لتحديث filesCount و size
  Future<void> _loadFoldersDetails() async {
    if (!mounted || roomData == null) return;

    final folders = roomData!['folders'] as List? ?? [];
    if (folders.isEmpty) return;

    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );

    // ✅ جلب تفاصيل كل مجلد بشكل parallel
    final futures = folders.map((folder) async {
      try {
        final folderIdRef = folder['folderId'];
        final folderId = folderIdRef is Map<String, dynamic>
            ? folderIdRef['_id']?.toString()
            : (folderIdRef is String ? folderIdRef : folderIdRef?.toString());

        if (folderId == null || folderId.isEmpty) return;

        // ✅ محاولة جلب تفاصيل المجلد المشترك في الروم أولاً
        Map<String, dynamic>? details;
        try {
          details = await folderController.getSharedFolderDetailsInRoom(
            folderId: folderId,
          );
        } catch (e) {
          // ✅ إذا فشل، حاول جلب تفاصيل المجلد العادية
          try {
            details = await folderController.getFolderDetails(
              folderId: folderId,
            );
          } catch (e2) {
            print('⚠️ Error loading folder details for $folderId: $e2');
            return;
          }
        }

        if (details != null && details['folder'] != null && mounted) {
          final folderInfo = details['folder'] as Map<String, dynamic>;
          final filesCount = folderInfo['filesCount'];
          final size = folderInfo['size'];

          // ✅ تحديث الـ cache فقط إذا كانت القيم موجودة
          // ✅ حتى لو كان filesCount = 0، نحدث القيمة
          if (mounted) {
            setState(() {
              _folderDetailsCache[folderId] = {
                'filesCount': filesCount ?? 0,
                'size': size ?? 0,
              };
            });
          }
        }
      } catch (e) {
        print('⚠️ Error loading folder details: $e');
      }
    }).toList();

    await Future.wait(futures);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'المجلدات المشتركة',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 18.0,
              tablet: 20.0,
              desktop: 22.0,
            ),
          ),
        ),
        backgroundColor: Color(0xff28336f),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            iconSize: ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 24.0,
              tablet: 26.0,
              desktop: 28.0,
            ),
            onPressed: () {
              setState(() {
                isLoading = true;
                _folderDetailsCache.clear(); // ✅ مسح الـ cache عند التحديث
              });
              _loadRoomData();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : roomData == null
              ? Center(child: Text(S.of(context).failedToLoadRoomData))
              : SmartRefresher(
                  controller: _refreshController,
                  onRefresh: () async {
                    await _loadRoomData();
                    _refreshController.refreshCompleted();
                  },
                  header: const WaterDropHeader(),
                  child: _buildFoldersList(),
                ),
    );
  }

  Widget _buildFoldersList() {
    final folders = roomData!['folders'] as List? ?? [];

    if (folders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 64.0,
                tablet: 80.0,
                desktop: 96.0,
              ),
              color: Colors.grey,
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 16.0,
                tablet: 20.0,
                desktop: 24.0,
              ),
            ),
            Text(
              'لا توجد مجلدات مشتركة',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 18.0,
                  tablet: 20.0,
                  desktop: 22.0,
                ),
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 8.0,
                tablet: 12.0,
                desktop: 16.0,
              ),
            ),
            Text(
              'قم بمشاركة مجلدات مع هذه الغرفة',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 14.0,
                  tablet: 16.0,
                  desktop: 18.0,
                ),
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // ✅ تحويل المجلدات إلى format مناسب لـ FilesGridView
    final displayFolders = folders.map((folder) {
      final folderIdRef = folder['folderId'];
      final folderData = folderIdRef is Map<String, dynamic>
          ? folderIdRef
          : <String, dynamic>{};
      final folderName = folderData['name']?.toString() ?? 'مجلد غير معروف';
      final folderId =
          folderData['_id']?.toString() ??
          (folderIdRef is String ? folderIdRef : folderIdRef?.toString());

      // ✅ استخدام تفاصيل المجلد من الـ cache إذا كانت موجودة
      final cachedDetails = _folderDetailsCache[folderId];
      final filesCount =
          cachedDetails?['filesCount'] ?? folderData['filesCount'] ?? 0;
      final size = cachedDetails?['size'] ?? folderData['size'] ?? 0;

      final createdAt = folderData['createdAt'];
      final updatedAt = folderData['updatedAt'];
      final sharedAt = folder['sharedAt'];

      // ✅ استخراج معلومات من شارك المجلد من room data
      final sharedBy = _getSharedByInfo(folder, folderData);

      // ✅ دمج بيانات المجلد مع التفاصيل المحدثة
      final updatedFolderData = {
        ...folderData,
        if (cachedDetails != null) ...cachedDetails,
      };

      return {
        'title': folderName,
        'fileCount': filesCount,
        'size': _formatSize(size),
        'icon': Icons.folder,
        'color': Color(0xFF8B5CF6),
        'type': 'folder',
        'folderId': folderId,
        'folderData': updatedFolderData,
        'sharedBy': sharedBy,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'sharedAt': sharedAt,
        'itemData': {
          'folderId': folderId,
          'folderName': folderName,
          'folderData': updatedFolderData,
        },
      };
    }).toList();

    final padding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );

    return Padding(
      padding: EdgeInsets.all(padding),
      child: FilesGridView(
        items: displayFolders,
        showFileCount: true,
        roomId: widget.roomId, // ✅ تمرير roomId لتمييز المجلدات المشتركة
        onItemTap: (item) {
          final itemData = item['itemData'] as Map<String, dynamic>?;
          if (itemData != null) {
            final folderId = itemData['folderId'] as String?;
            final folderName = itemData['folderName'] as String?;

            if (folderId != null && folderId.isNotEmpty && folderName != null) {
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
                      folderName: folderName,
                      folderColor: Color(0xFF8B5CF6),
                    ),
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).folderIdNotAvailable)),
              );
            }
          }
        },
        onFolderCommentTap: (item) {
          // ✅ فتح صفحة التعليقات على المجلد
          final itemData = item['itemData'] as Map<String, dynamic>?;
          if (itemData != null) {
            final folderId = itemData['folderId'] as String?;

            if (folderId != null && folderId.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider.value(
                    value: Provider.of<RoomController>(context, listen: false),
                    child: RoomCommentsPage(
                      roomId: widget.roomId,
                      targetType: 'folder',
                      targetId: folderId,
                    ),
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).folderIdNotAvailable)),
              );
            }
          }
        },
        onRemoveFolderFromRoomTap: (item) async {
          // ✅ إزالة المجلد من الغرفة
          final itemData = item['itemData'] as Map<String, dynamic>?;
          if (itemData != null) {
            final folderId = itemData['folderId'] as String?;
            final folderName = itemData['folderName'] as String? ?? 'المجلد';

            if (folderId != null && folderId.isNotEmpty) {
              // ✅ التحقق من الصلاحيات قبل عرض dialog
              if (roomData != null) {
                final canRemove = await RoomPermissions.canRemoveFiles(
                  roomData!,
                );
                if (canRemove) {
                  _showRemoveFolderFromRoomDialog(folderId, folderName);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '❌ فقط مالك الغرفة أو الأعضاء برتبة محرر يمكنهم إزالة المجلدات',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                // ✅ إذا لم تكن بيانات الغرفة محملة، حاول تحميلها أولاً
                await _loadRoomData();
                if (roomData != null) {
                  final canRemove = await RoomPermissions.canRemoveFiles(
                    roomData!,
                  );
                  if (canRemove) {
                    _showRemoveFolderFromRoomDialog(folderId, folderName);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '❌ فقط مالك الغرفة أو الأعضاء برتبة محرر يمكنهم إزالة المجلدات',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).folderIdNotAvailable)),
              );
            }
          }
        },
        onDownloadFolderFromRoomTap: (item) async {
          // ✅ تحميل المجلد من الغرفة
          final itemData = item['itemData'] as Map<String, dynamic>?;
          if (itemData != null) {
            final folderId = itemData['folderId'] as String?;
            final folderName = itemData['folderName'] as String? ?? 'المجلد';

            if (folderId != null && folderId.isNotEmpty) {
              final roomController = Provider.of<RoomController>(
                context,
                listen: false,
              );
              FolderActionsService.downloadRoomFolder(
                context,
                roomController,
                widget.roomId,
                folderId,
                folderName,
              );
            }
          }
        },
      ),
    );
  }

  String _formatSize(dynamic size) {
    if (size == null) return '—';
    try {
      final bytes = size is int
          ? size
          : (size is num ? size.toInt() : int.tryParse(size.toString()) ?? 0);
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      if (bytes < 1073741824)
        return '${(bytes / 1048576).toStringAsFixed(1)} MB';
      return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    } catch (e) {
      return '—';
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '—';
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return '—';
    }
  }

  /// ✅ عرض dialog لتأكيد إزالة المجلد من الغرفة
  Future<void> _showRemoveFolderFromRoomDialog(
    String folderId,
    String folderName,
  ) async {
    // ✅ التحقق من الصلاحيات قبل عرض dialog
    if (roomData == null) {
      await _loadRoomData();
    }

    if (roomData != null) {
      final canRemove = await RoomPermissions.canRemoveFiles(roomData!);
      if (!canRemove) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ فقط مالك الغرفة أو الأعضاء برتبة محرر يمكنهم إزالة المجلدات',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).removeFolderFromRoom),
        content: Text(S.of(context).confirmRemoveFolderFromRoomWithName(folderName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _removeFolderFromRoom(folderId);
            },
            child: Text(S.of(context).remove, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// ✅ حفظ المجلد من الغرفة إلى حساب المستخدم
  Future<void> _saveFolderFromRoom(String folderId, String folderName) async {
    // ✅ عرض dialog لاختيار المجلد (اختياري)
    final targetFolderId = await _showSaveFolderDialog();

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(width: 16),
                Text(S.of(context).savingFolder),
              ],
            ),
            duration: Duration(seconds: 60),
          ),
        );
      }

      final roomController = Provider.of<RoomController>(
        context,
        listen: false,
      );
      final success = await roomController.saveFolderFromRoom(
        roomId: widget.roomId,
        folderId: folderId,
        parentFolderId: targetFolderId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تم حفظ المجلد "$folderName" في حسابك بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(roomController.errorMessage ?? '❌ فشل حفظ المجلد'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
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

  /// ✅ عرض dialog لاختيار المجلد لحفظ المجلد
  Future<String?> _showSaveFolderDialog() async {
    // ✅ استخدام _FolderNavigationDialog من FilesGridView
    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.save, color: Colors.white, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'اختر مجلد لحفظ المجلد',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(modalContext, null),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'سيتم حفظ المجلد في الجذر',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(modalContext, null);
                },
                child: Text(S.of(context).saveToRoot),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ إزالة المجلد من الغرفة
  Future<void> _removeFolderFromRoom(String folderId) async {
    try {
      final roomController = Provider.of<RoomController>(
        context,
        listen: false,
      );
      final success = await roomController.unshareFolderFromRoom(
        roomId: widget.roomId,
        folderId: folderId,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تم إزالة المجلد من الغرفة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          // ✅ إعادة تحميل بيانات الغرفة بعد إزالة المجلد
          _loadRoomData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                roomController.errorMessage ?? '❌ فشل إزالة المجلد من الغرفة',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ استخراج معلومات من شارك المجلد من room data
  String? _getSharedByInfo(
    Map<String, dynamic> sharedItem,
    Map<String, dynamic> itemData,
  ) {
    // ✅ 1. من sharedItem مباشرة (من room data - sharedBy)
    if (sharedItem['sharedBy'] != null) {
      final sharedBy = sharedItem['sharedBy'];
      if (sharedBy is Map<String, dynamic>) {
        return sharedBy['name'] ?? sharedBy['email'] ?? 'مستخدم';
      }
      if (sharedBy is String) {
        // ✅ إذا كان sharedBy هو ID، ابحث في room members
        if (roomData != null && roomData!['members'] != null) {
          final members = roomData!['members'] as List?;
          if (members != null) {
            for (final member in members) {
              final userId = member['user'];
              final userIdStr = userId is Map
                  ? userId['_id']?.toString()
                  : userId?.toString();
              if (userIdStr == sharedBy) {
                final user = userId is Map ? userId : member['user'];
                if (user is Map<String, dynamic>) {
                  return user['name'] ?? user['email'] ?? 'مستخدم';
                }
              }
            }
          }
        }
        return null;
      }
    }

    // ✅ 2. من userId في itemData (fallback)
    if (itemData['userId'] != null) {
      final userId = itemData['userId'];
      if (userId is Map<String, dynamic>) {
        return userId['name'] ?? userId['email'] ?? 'مستخدم';
      }
    }

    // ✅ 3. من owner في itemData (fallback)
    if (itemData['owner'] != null) {
      final owner = itemData['owner'];
      if (owner is Map<String, dynamic>) {
        return owner['name'] ?? owner['email'] ?? 'مستخدم';
      }
    }

    return null;
  }
}
