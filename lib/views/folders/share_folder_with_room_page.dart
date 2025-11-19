import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/room_controller.dart';

class ShareFolderWithRoomPage extends StatefulWidget {
  final String folderId;
  final String folderName;

  const ShareFolderWithRoomPage({
    super.key,
    required this.folderId,
    required this.folderName,
  });

  @override
  State<ShareFolderWithRoomPage> createState() => _ShareFolderWithRoomPageState();
}

class _ShareFolderWithRoomPageState extends State<ShareFolderWithRoomPage> {
  List<Map<String, dynamic>> rooms = [];
  bool isLoading = true;
  String? selectedRoomId;

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
    final success = await roomController.getRooms();

    if (mounted) {
      setState(() {
        rooms = roomController.rooms;
        isLoading = false;
      });
    }
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
            content: Text('✅ تم مشاركة المجلد مع الغرفة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(roomController.errorMessage ?? '❌ فشل مشاركة المجلد'),
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
        title: Text('مشاركة المجلد مع غرفة'),
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
                            Icon(Icons.meeting_room_outlined,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'لا توجد غرف متاحة',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'قم بإنشاء غرفة أولاً للمشاركة',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadRooms,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            final room = rooms[index];
                            final isSelected = selectedRoomId == room['_id'];
                            final membersCount =
                                (room['members'] as List?)?.length ?? 0;
                            final foldersCount =
                                (room['folders'] as List?)?.length ?? 0;

                            // Check if folder is already shared with this room
                            final isAlreadyShared = (room['folders'] as List?)
                                    ?.any((f) {
                                      final folderIdRef = f['folderId'];
                                      if (folderIdRef == null) return false;
                                      
                                      // إذا كان folderId هو String مباشرة
                                      if (folderIdRef is String) {
                                        return folderIdRef == widget.folderId;
                                      }
                                      
                                      // إذا كان folderId هو Map/Object
                                      if (folderIdRef is Map<String, dynamic>) {
                                        final folderId = folderIdRef['_id']?.toString();
                                        return folderId == widget.folderId ||
                                            folderIdRef['_id'] == widget.folderId;
                                      }
                                      
                                      // إذا كان folderId هو ObjectId أو أي نوع آخر
                                      return folderIdRef.toString() == widget.folderId;
                                    }) ??
                                false;

                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              elevation: isSelected ? 4 : 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isSelected
                                      ? Color(0xff28336f)
                                      : Colors.transparent,
                                  width: isSelected ? 2 : 0,
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedRoomId = room['_id'];
                                  });
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Color(0xff28336f)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                                  room['name'] ?? 'بدون اسم',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (room['description'] !=
                                                        null &&
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(Icons.check_circle,
                                                color: Color(0xff28336f)),
                                          if (isAlreadyShared)
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'مشترك',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.green.shade700,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Row(
                                        children: [
                                          _buildStatChip(
                                            Icons.people,
                                            '$membersCount',
                                            'أعضاء',
                                          ),
                                          SizedBox(width: 12),
                                          _buildStatChip(
                                            Icons.folder,
                                            '$foldersCount',
                                            'مجلدات',
                                          ),
                                        ],
                                      ),
                                      if (isSelected && !isAlreadyShared) ...[
                                        SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: Consumer<RoomController>(
                                            builder: (context, roomController,
                                                child) {
                                              return ElevatedButton.icon(
                                                onPressed:
                                                    roomController.isLoading
                                                        ? null
                                                        : () =>
                                                            _shareFolderWithRoom(
                                                                room['_id']),
                                                icon: roomController.isLoading
                                                    ? SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors.white),
                                                        ),
                                                      )
                                                    : Icon(Icons.share),
                                                label: Text('مشاركة مع هذه الغرفة'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Color(0xff28336f),
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 12),
                                                ),
                                              );
                                            },
                                          ),
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
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

