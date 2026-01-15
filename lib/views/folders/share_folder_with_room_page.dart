import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:filevo/utils/room_permissions.dart';

class ShareFolderWithRoomPage extends StatefulWidget {
  final String folderId;
  final String folderName;

  const ShareFolderWithRoomPage({
    super.key,
    required this.folderId,
    required this.folderName,
  });

  @override
  State<ShareFolderWithRoomPage> createState() =>
      _ShareFolderWithRoomPageState();
}

class _ShareFolderWithRoomPageState extends State<ShareFolderWithRoomPage> {
  List<Map<String, dynamic>> rooms = [];
  bool isLoading = true;
  String? selectedRoomId;

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRooms();
    });
  }

  Future<void> _loadRooms() async {
    if (!mounted) return;

    final roomController = Provider.of<RoomController>(context, listen: false);
    await roomController.getRooms();

    if (mounted) {
      final roomsList = roomController.rooms;

      // ✅ تحميل تفاصيل كل روم بشكل متوازي للحصول على المجلدات المشتركة
      final roomsWithDetails = await Future.wait(
        roomsList.map((room) async {
          try {
            final roomId = room['_id']?.toString();
            if (roomId != null) {
              // ✅ تحميل تفاصيل الروم للحصول على المجلدات
              final roomDetails = await roomController.getRoomById(roomId);
              if (roomDetails != null && roomDetails['room'] != null) {
                return roomDetails['room'] as Map<String, dynamic>;
              }
            }
            // ✅ إذا فشل تحميل التفاصيل، استخدم البيانات الأساسية
            return room;
          } catch (e) {
            print('⚠️ Error loading room details for ${room['name']}: $e');
            // ✅ في حالة الخطأ، استخدم البيانات الأساسية
            return room;
          }
        }),
      );

      setState(() {
        rooms = roomsWithDetails;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _shareFolderWithRoom(String roomId) async {
    final roomController = Provider.of<RoomController>(context, listen: false);
    final success = await roomController.shareFolderWithRoom(
      roomId: roomId,
      folderId: widget.folderId,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).folderSharedSuccess),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ تحديث قائمة الغرف لتحديث عدد المجلدات
        await roomController.getRooms();

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              roomController.errorMessage ?? S.of(context).folderSharedFailed,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).shareFolderWithRoom),
        backgroundColor: Color(0xff28336f),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              _loadRooms();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Folder Info Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff28336f), Color(0xFF4D62D5)],
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.folder, color: Colors.white, size: 48),
                SizedBox(height: 12),
                Text(
                  widget.folderName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  'اختر غرفة لمشاركة هذا المجلد',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Rooms List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : rooms.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.meeting_room_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          S.of(context).noRoomsAvailable,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          S.of(context).createRoomFirstToShare,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : SmartRefresher(
                    controller: _refreshController,
                    onRefresh: () async {
                      await _loadRooms();
                      _refreshController.refreshCompleted();
                    },
                    header: const WaterDropHeader(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        final isSelected = selectedRoomId == room['_id'];
                        final membersCount =
                            (room['members'] as List?)?.length ?? 0;
                        final foldersCount =
                            (room['folders'] as List?)?.length ?? 0;

                        // ✅ التحقق من أن المجلد مشترك مع هذه الغرفة
                        final isAlreadyShared = _checkIfFolderIsShared(
                          room,
                          widget.folderId,
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: isSelected ? 4 : (isAlreadyShared ? 2 : 1),
                          color: isAlreadyShared
                              ? Colors.green.shade50.withOpacity(0.3)
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xff28336f)
                                  : isAlreadyShared
                                  ? Colors.green.shade300
                                  : Colors.transparent,
                              width: isSelected ? 2 : (isAlreadyShared ? 1 : 0),
                            ),
                          ),
                          child: InkWell(
                            onTap: isAlreadyShared
                                ? null // ✅ منع الضغط على الرومات المشتركة
                                : () async {
                                    // ✅ التحقق من صلاحية المشاركة قبل الاختيار
                                    final canShare = await RoomPermissions.canShareFiles(room);
                                    if (!canShare) {
                                      // ✅ عرض رسالة أنه لا يملك صلاحية
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(S.of(context).noPermissionToShareInRoom),
                                            backgroundColor: Colors.orange,
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                      return;
                                    }
                                    setState(() {
                                      selectedRoomId = room['_id'];
                                    });
                                  },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Color(
                                            0xff28336f,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          isAlreadyShared
                                              ? Icons.check_circle
                                              : Icons.meeting_room,
                                          color: isAlreadyShared
                                              ? Colors.green
                                              : Color(0xff28336f),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              room['name'] ??
                                                  S.of(context).unnamed,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (room['description'] != null &&
                                                room['description']
                                                    .toString()
                                                    .isNotEmpty) ...[
                                              SizedBox(height: 4),
                                              Text(
                                                room['description'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (isAlreadyShared)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.green.shade300,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                size: 14,
                                                color: Colors.green.shade700,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                S.of(context).shared,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.green.shade700,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          color: Color(0xff28336f),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _buildStatChip(
                                        Icons.people,
                                        '$membersCount',
                                        S.of(context).members,
                                      ),
                                      SizedBox(width: 12),
                                      _buildStatChip(
                                        Icons.folder,
                                        '$foldersCount',
                                        S.of(context).folders,
                                      ),
                                    ],
                                  ),
                                  // ✅ إظهار معلومات إضافية إذا كان المجلد مشارك
                                  if (isAlreadyShared) ...[
                                    SizedBox(height: 8),
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.green.shade200,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            size: 20,
                                            color: Colors.green.shade700,
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              S.of(context).folderAlreadyShared,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.green.shade800,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  // ✅ إظهار خيارات المشاركة إذا كان المجلد غير مشارك
                                  if (isSelected && !isAlreadyShared) ...[
                                    SizedBox(height: 12),
                                    FutureBuilder<bool>(
                                      future: RoomPermissions.canShareFiles(room),
                                      builder: (context, snapshot) {
                                        // ✅ لا نعرض أي شيء حتى يتم تحميل البيانات
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return SizedBox.shrink();
                                        }
                                        
                                        final canShare = snapshot.data ?? false;
                                        if (!canShare) {
                                          return Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.orange.shade200,
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.warning_amber_rounded,
                                                  size: 20,
                                                  color: Colors.orange.shade700,
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    S.of(context).noPermissionToShareInRoom,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.orange.shade800,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                        return SizedBox(
                                          width: double.infinity,
                                          child: Consumer<RoomController>(
                                            builder: (context, roomController, child) {
                                              return ElevatedButton.icon(
                                                onPressed: roomController.isLoading
                                                    ? null
                                                    : () => _shareFolderWithRoom(
                                                        room['_id'],
                                                      ),
                                                icon: roomController.isLoading
                                                    ? SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                Color
                                                              >(Colors.white),
                                                        ),
                                                      )
                                                    : Icon(Icons.share),
                                                label: Text(
                                                  S.of(context).shareWithThisRoom,
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color(
                                                    0xff28336f,
                                                  ),
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  // ✅ دالة للتحقق من أن المجلد مشترك مع الغرفة (مشابهة لـ _checkIfFileIsShared)
  bool _checkIfFolderIsShared(Map<String, dynamic> room, String folderId) {
    print('🔍 [checkIfFolderIsShared] Checking folderId: $folderId');
    print('🔍 [checkIfFolderIsShared] Room: ${room['name']}');

    final folders = room['folders'] as List?;
    print('🔍 [checkIfFolderIsShared] Folders count: ${folders?.length ?? 0}');

    if (folders == null || folders.isEmpty) {
      print('❌ [checkIfFolderIsShared] No folders in room');
      return false;
    }

    // ✅ طباعة جميع المجلدات للتحقق
    for (int i = 0; i < folders.length; i++) {
      final f = folders[i];
      print('📁 [checkIfFolderIsShared] Folder $i: $f');
    }

    final isShared = folders.any((f) {
      if (f == null) {
        return false;
      }

      final folderIdRef = f['folderId'];
      if (folderIdRef == null) {
        return false;
      }

      String? actualFolderId;

      // ✅ إذا كان folderId هو String مباشرة
      if (folderIdRef is String) {
        actualFolderId = folderIdRef;
      }
      // ✅ إذا كان folderId هو Map/Object
      else if (folderIdRef is Map<String, dynamic>) {
        // ✅ محاولة قراءة _id بطرق مختلفة
        actualFolderId =
            folderIdRef['_id']?.toString() ?? folderIdRef['id']?.toString();

        // ✅ إذا كان _id نفسه Map (nested)
        if (actualFolderId == null && folderIdRef['_id'] is Map) {
          final nestedId = folderIdRef['_id'] as Map;
          actualFolderId =
              nestedId['_id']?.toString() ?? nestedId['id']?.toString();
        }
      }
      // ✅ إذا كان folderId هو ObjectId أو أي نوع آخر
      else {
        actualFolderId = folderIdRef.toString();
      }

      if (actualFolderId == null) {
        return false;
      }

      final matches = actualFolderId == folderId;
      if (matches) {
        print('✅ [checkIfFolderIsShared] Found match: $actualFolderId == $folderId');
      }
      return matches;
    });

    print('${isShared ? "✅" : "❌"} [checkIfFolderIsShared] Result: $isShared');
    return isShared;
  }
}
