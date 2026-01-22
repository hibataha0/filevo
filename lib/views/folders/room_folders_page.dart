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
import 'package:shimmer/shimmer.dart';
import 'package:filevo/dialogs/folder_protection_dialogs.dart';
import 'package:filevo/services/socket_service.dart';
import 'package:filevo/constants/app_colors.dart';

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
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoomData();
      _setupSocketListeners();
    });
  }

  /// ✅ إعداد مستمعي socket.io
  void _setupSocketListeners() {
    // ✅ الاتصال بـ socket.io
    _socketService.connect().then((_) {
      // ✅ الانضمام إلى الروم
      _socketService.joinRoom(widget.roomId);

      // ✅ الاستماع لحدث new_folder
      _socketService.onNewFolder((data) {
        if (!mounted) return;

        final folder = data['folder'] as Map<String, dynamic>?;
        final roomId = data['roomId'] as String?;
        final sharedBy = data['sharedBy'] as String?;

        // ✅ التحقق من أن المجلد يخص هذا الروم
        if (roomId != widget.roomId || folder == null) {
          return;
        }

        print('📂 [RoomFoldersPage] New folder received via socket: ${folder['name']}');

        // ✅ إضافة المجلد إلى القائمة
        if (mounted && roomData != null) {
          setState(() {
            final folders = roomData!['folders'] as List? ?? [];
            // ✅ التحقق من أن المجلد غير موجود بالفعل
            final folderId = folder['_id']?.toString();
            final exists = folders.any((f) {
              final fId = f['folderId'] is Map
                  ? f['folderId']['_id']?.toString()
                  : f['folderId']?.toString();
              return fId == folderId;
            });

            if (!exists) {
              folders.add({
                'folderId': folder,
                'sharedBy': sharedBy,
                'sharedAt': DateTime.now().toIso8601String(),
              });
              roomData!['folders'] = folders;
            }
          });

          // ✅ تحديث تفاصيل المجلد
          _loadFoldersDetails();

          // ✅ عرض إشعار
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📂 ${S.of(context).newFolderShared(folder['name'] ?? S.of(context).folder)}'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
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

        // ✅ محاولة جلب تفاصيل المجلد المشترك في الروم أولاً (لأننا في صفحة الروم)
        // ✅ هذا يتطابق مع منطق _showFolderInfo الذي يعمل بشكل صحيح
        Map<String, dynamic>? details;
        try {
          details = await folderController.getSharedFolderDetailsInRoom(
            folderId: folderId,
          );
        } catch (e) {
          // ✅ إذا فشل، حاول جلب تفاصيل المجلد العادية كبديل
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
          final isProtected = folderInfo['isProtected'] ?? false;
          final protectionType = folderInfo['protectionType']?.toString() ?? 'none';

          // ✅ تحديث الـ cache مع معلومات الحماية
          if (mounted) {
            print('📥 [RoomFoldersPage] Data Loaded for $folderId: filesCount=$filesCount, size=$size');
            setState(() {
              _folderDetailsCache[folderId] = {
                'filesCount': filesCount ?? 0,
                'size': size ?? 0,
                'isProtected': isProtected,
                'protectionType': protectionType,
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
    // ✅ مغادرة الروم وإزالة المستمعين
    _socketService.leaveRoom(widget.roomId);
    _socketService.removeAllListeners();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).roomFolders,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 18.0,
              tablet: 20.0,
              desktop: 22.0,
            ),
          ),
        ),
        backgroundColor: AppColors.getAppBar(
          Theme.of(context).brightness == Brightness.dark,
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.refresh),
        //     iconSize: ResponsiveUtils.getResponsiveValue(
        //       context,
        //       mobile: 24.0,
        //       tablet: 26.0,
        //       desktop: 28.0,
        //     ),
        //     onPressed: () {
        //       setState(() {
        //         isLoading = true;
        //         _folderDetailsCache.clear(); // ✅ مسح الـ cache عند التحديث
        //       });
        //       _loadRoomData();
        //     },
        //   ),
        // ],
      ),
      body: isLoading
          ? _buildShimmerLoading()
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
              color: AppColors.getTextSecondary(
                Theme.of(context).brightness == Brightness.dark,
              ),
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
              S.of(context).noSharedFolders,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 18.0,
                  tablet: 20.0,
                  desktop: 22.0,
                ),
                color: AppColors.getTextSecondary(
                  Theme.of(context).brightness == Brightness.dark,
                ),
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
              S.of(context).shareFoldersWithRoom,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 14.0,
                  tablet: 16.0,
                  desktop: 18.0,
                ),
                color: AppColors.getTextSecondary(
                  Theme.of(context).brightness == Brightness.dark,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ✅ تحويل المجلدات إلى format مناسب لـ FilesGridView
    // ✅ نعرض جميع المجلدات بما فيها المحمية (يتم طلب كلمة السر عند فتحها)
    final displayFolders = folders.map((folder) {
      final folderIdRef = folder['folderId'];
      final folderData = folderIdRef is Map<String, dynamic>
          ? folderIdRef
          : <String, dynamic>{};
      final folderName =
          folderData['name']?.toString() ?? S.of(context).unknownFolder;
      final folderId =
          folderData['_id']?.toString() ??
          (folderIdRef is String ? folderIdRef : folderIdRef?.toString());

      print('🔍 [RoomFoldersPage] Build List - FolderId: $folderId');
      
      // ✅ استخدام تفاصيل المجلد من الـ cache إذا كانت موجودة
      final cachedDetails = _folderDetailsCache[folderId];
      if (cachedDetails != null) {
          print('   ✅ Cache HIT: $cachedDetails');
      } else {
          print('   ❌ Cache MISS');
          print('   📄 Raw FolderData filesCount: ${folderData['filesCount']}');
      }

      dynamic rawFilesCount = cachedDetails?['filesCount'] ?? folderData['filesCount'] ?? folderData['fileCount'];
      int filesCount = 0;
      if (rawFilesCount != null) {
        if (rawFilesCount is int) filesCount = rawFilesCount;
        else if (rawFilesCount is String) filesCount = int.tryParse(rawFilesCount) ?? 0;
        else if (rawFilesCount is num) filesCount = rawFilesCount.toInt();
      }
      print('   🔢 Final filesCount: $filesCount');

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
        onItemTap: (item) async {
          final itemData = item['itemData'] as Map<String, dynamic>?;
          if (itemData == null) return;

          final folderId = itemData['folderId'] as String?;
          final folderName = itemData['folderName'] as String?;

          if (folderId == null || folderId.isEmpty || folderName == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context).folderIdNotAvailable)),
            );
            return;
          }

          // ✅ دائماً التحقق من معلومات الحماية قبل الفتح (مثل المجلدات العادية)
          print('🔐 [RoomFoldersPage] onItemTap - Checking folder protection...');
          print('   - folderId: $folderId');
          print('   - folderName: $folderName');
          
          bool isProtected = false;
          String protectionType = 'none';
          
          // ✅ دائماً التحقق من معلومات الحماية من الباك إند للتأكد
          // ✅ لأن البيانات المحلية قد تكون غير دقيقة (خاصة من getSharedFolderDetailsInRoom)
          // ✅ لأن getSharedFolderDetailsInRoom قد يعيد معلومات غير صحيحة
          try {
            final folderController = Provider.of<FolderController>(
              context,
              listen: false,
            );
            
            // ✅ محاولة جلب تفاصيل المجلد العادية أولاً (أكثر دقة)
            // ✅ getFolderDetails يعيد معلومات الحماية الصحيحة دائماً
            try {
              print('🔐 [RoomFoldersPage] Getting folder details from backend for protection check...');
              final folderDetails = await folderController.getFolderDetails(
                folderId: folderId,
              );
              
              if (folderDetails != null && folderDetails['folder'] != null) {
                final folderInfo = folderDetails['folder'] as Map<String, dynamic>;
                final backendIsProtected = folderInfo['isProtected'] == true;
                final backendProtectionType = folderInfo['protectionType']?.toString() ?? 'none';
                
                // ✅ استخدام معلومات الحماية من getFolderDetails (الأكثر دقة)
                isProtected = backendIsProtected;
                protectionType = backendProtectionType;
                
                // ✅ تحديث الـ cache مع معلومات الحماية الصحيحة
                if (mounted) {
                  setState(() {
                    _folderDetailsCache[folderId] = {
                      ...(_folderDetailsCache[folderId] ?? {}),
                      'isProtected': isProtected,
                      'protectionType': protectionType,
                    };
                  });
                }
                
                print('🔐 [RoomFoldersPage] Protection from getFolderDetails (accurate):');
                print('   - isProtected: $isProtected');
                print('   - protectionType: $protectionType');
              }
            } catch (e2) {
              print('⚠️ [RoomFoldersPage] Error in getFolderDetails: $e2');
              // ✅ إذا كان هناك خطأ 403، المجلد محمي بالتأكيد
              final errorString = e2.toString().toLowerCase();
              if (errorString.contains('403') || 
                  errorString.contains('protected') || 
                  errorString.contains('verify access')) {
                isProtected = true;
                protectionType = 'password';
                print('🔐 [RoomFoldersPage] Detected 403 - folder is protected');
              } else {
                // ✅ إذا فشل getFolderDetails، حاول getSharedFolderDetailsInRoom كبديل
                try {
                  print('🔐 [RoomFoldersPage] Trying getSharedFolderDetailsInRoom as fallback...');
                  final folderDetails = await folderController.getSharedFolderDetailsInRoom(
                    folderId: folderId,
                  );
                  
                  if (folderDetails != null && folderDetails['folder'] != null) {
                    final folderInfo = folderDetails['folder'] as Map<String, dynamic>;
                    isProtected = folderInfo['isProtected'] == true;
                    protectionType = folderInfo['protectionType']?.toString() ?? 'none';
                    
                    // ✅ تحديث الـ cache
                    if (mounted) {
                      setState(() {
                        _folderDetailsCache[folderId] = {
                          ...(_folderDetailsCache[folderId] ?? {}),
                          'isProtected': isProtected,
                          'protectionType': protectionType,
                        };
                      });
                    }
                    
                    print('🔐 [RoomFoldersPage] Protection from getSharedFolderDetailsInRoom (fallback):');
                    print('   - isProtected: $isProtected');
                    print('   - protectionType: $protectionType');
                  }
                } catch (e) {
                  print('⚠️ [RoomFoldersPage] Error in getSharedFolderDetailsInRoom: $e');
                }
              }
            }
          } catch (e) {
            print('⚠️ [RoomFoldersPage] General error in protection check: $e');
          }

          print('🔐 [RoomFoldersPage] Final check result:');
          print('   - isProtected: $isProtected');
          print('   - protectionType: $protectionType');

          // ✅ إذا كان المجلد محمي، نطلب كلمة السر أولاً (مثل المجلدات العادية)
          if (isProtected && protectionType != 'none') {
            print('🔐 [RoomFoldersPage] Folder is protected - requesting password...');
            final result = await showVerifyFolderAccessDialog(
              context,
              folderId,
              folderName,
              protectionType,
            );

            // ✅ إذا لم يتم التحقق بنجاح، نوقف العملية
            if (result['success'] != true) {
              print('❌ [RoomFoldersPage] Password verification failed');
              return;
            }
            print('✅ [RoomFoldersPage] Password verified - opening folder');
          } else {
            print('✅ [RoomFoldersPage] Folder is not protected - opening directly');
          }

          // ✅ بعد التحقق (إذا كان محمياً) أو مباشرة (إذا لم يكن محمياً)، نفتح المجلد
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider.value(
                  value: Provider.of<FolderController>(context, listen: false),
                  child: FolderContentsPage(
                    folderId: folderId,
                    folderName: folderName,
                    folderColor: Color(0xFF8B5CF6),
                    roomId: widget.roomId, // ✅ تمرير roomId للمجلدات المشتركة
                  ),
                ),
              ),
            );
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
            final folderName =
                itemData['folderName'] as String? ?? S.of(context).folder;

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
                      content: Text(S.of(context).removeFolderPermissionError),
                      backgroundColor: AppColors.error,
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
                          S.of(context).removeFolderPermissionError,
                        ),
                        backgroundColor: AppColors.error,
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
          // ✅ دائماً استخدم التحميل العادي للمجلدات حتى لو كنا في روم
          // لضمان عمل التحميل بشكل صحيح للمجلدات التي قد لا يدعمها endpoint الرومات
          FolderActionsService.downloadFolder(context, item);
        },
        onSaveFolderFromRoomTap: (item) async {
          // ✅ حفظ المجلد من الغرفة إلى حسابي
          final itemData = item['itemData'] as Map<String, dynamic>?;
          if (itemData != null) {
            final folderId = itemData['folderId'] as String?;
            final folderName =
                itemData['folderName'] as String? ?? S.of(context).folder;

            if (folderId != null && folderId.isNotEmpty) {
              _saveFolderFromRoom(folderId, folderName);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).folderIdNotAvailable)),
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
            content: Text(S.of(context).removeFolderPermissionError),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).removeFolderFromRoom),
        content: Text(
          S.of(context).confirmRemoveFolderFromRoomWithName(folderName),
        ),
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
            child: Text(
              S.of(context).remove,
              style: TextStyle(color: AppColors.error),
            ),
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
        final s = S.of(context); // مرجع الترجمة
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                s.saveFolderSuccess(folderName),
              ), // ✅ تمرير اسم المجلد للترجمة
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                roomController.errorMessage ??
                    s.saveFolderFailure, // ✅ رسالة الفشل المترجمة
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorPrefix(e.toString())),
            backgroundColor: AppColors.error,
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
                      S.of(context).selectDestinationFolder,
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
                  S.of(context).willBeSavedInRoot,
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
              content: Text(S.of(context).removeFolderFromRoomSuccess),
              backgroundColor: AppColors.success,
            ),
          );
          // ✅ إعادة تحميل بيانات الغرفة بعد إزالة المجلد
          _loadRoomData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                roomController.errorMessage ??
                    S.of(context).removeFolderFromRoomFailure,
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorPrefix(e.toString())),
            backgroundColor: AppColors.error,
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
        return sharedBy['name'] ??
            sharedBy['email'] ??
            S.of(context).unknownUser;
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
                  return user['name'] ??
                      user['email'] ??
                      S.of(context).unknownUser;
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
        return userId['name'] ?? userId['email'] ?? S.of(context).unknownUser;
      }
    }

    // ✅ 3. من owner في itemData (fallback)
    if (itemData['owner'] != null) {
      final owner = itemData['owner'];
      if (owner is Map<String, dynamic>) {
        return owner['name'] ?? owner['email'] ?? S.of(context).unknownUser;
      }
    }

    return null;
  }

  // ✅ بناء shimmer loading لصفحة مجلدات الروم
  Widget _buildShimmerLoading() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: List.generate(
        6,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
      baseColor: AppColors.getShimmerBase(
        Theme.of(context).brightness == Brightness.dark,
      ),
      highlightColor: AppColors.getShimmerHighlight(
        Theme.of(context).brightness == Brightness.dark,
      ),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
