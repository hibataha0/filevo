import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/constants/app_colors.dart';
import 'package:filevo/generated/l10n.dart';

class ShareFileWithRoomPage extends StatefulWidget {
  final String fileId;
  final String fileName;

  const ShareFileWithRoomPage({
    super.key,
    required this.fileId,
    required this.fileName,
  });

  @override
  State<ShareFileWithRoomPage> createState() => _ShareFileWithRoomPageState();
}

class _ShareFileWithRoomPageState extends State<ShareFileWithRoomPage> {
  List<Map<String, dynamic>> rooms = [];
  bool isLoading = true;
  String? selectedRoomId;
  bool isOneTimeShare = false; // ✅ خيار المشاركة لمرة واحدة
  int? expiresInHours; // ✅ عدد الساعات للانتهاء (افتراضي 24)

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

  Future<void> _shareFileWithRoom(String roomId) async {
    final roomController = Provider.of<RoomController>(context, listen: false);
    final success = await roomController.shareFileWithRoom(
      roomId: roomId,
      fileId: widget.fileId,
      isOneTime: isOneTimeShare,
      expiresInHours: isOneTimeShare ? (expiresInHours ?? 24) : null,
    );
 
    print('ShareFileWithRoomPage: shareFileWithRoom response success: $success (one-time: $isOneTimeShare)');
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isOneTimeShare 
                ? '✅ تم مشاركة الملف مع الغرفة (لمرة واحدة) بنجاح'
                : '✅ تم مشاركة الملف مع الغرفة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(roomController.errorMessage ?? '❌ فشل مشاركة الملف'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _showOneTimeShareDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).oneTimeShare),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.of(context).oneTimeShareDescription,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: S.of(context).enterHours,
                border: OutlineInputBorder(),
                hintText: '24',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  expiresInHours = int.tryParse(value);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isOneTimeShare = true;
                expiresInHours = expiresInHours ?? 24;
              });
              Navigator.pop(context);
            },
            child: Text(S.of(context).verify),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).shareFileWithRoom),
        backgroundColor: AppColors.lightAppBar,
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
          // File Info Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.lightAppBar, AppColors.accent],
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.insert_drive_file, color: Colors.white, size: 48),
                SizedBox(height: 12),
                Text(
                  widget.fileName,
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
                  S.of(context).chooseRoomToShare,
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
                              S.of(context).noRoomsAvailable,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              S.of(context).createRoomFirst,
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
                            // ✅ ملاحظة: الـ backend يقوم بفلترة الملفات المشتركة لمرة واحدة تلقائياً
                            final filesCount =
                                (room['files'] as List?)?.length ?? 0;

                            // Check if file is already shared with this room
                            final isAlreadyShared = (room['files'] as List?)
                                    ?.any((f) {
                                      final fileIdRef = f['fileId'];
                                      if (fileIdRef == null) return false;
                                      
                                      // إذا كان fileId هو String مباشرة
                                      if (fileIdRef is String) {
                                        return fileIdRef == widget.fileId;
                                      }
                                      
                                      // إذا كان fileId هو Map/Object
                                      if (fileIdRef is Map<String, dynamic>) {
                                        final fileId = fileIdRef['_id']?.toString();
                                        return fileId == widget.fileId ||
                                            fileIdRef['_id'] == widget.fileId;
                                      }
                                      
                                      // إذا كان fileId هو ObjectId أو أي نوع آخر
                                      return fileIdRef.toString() == widget.fileId;
                                    }) ??
                                false;

                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              elevation: isSelected ? 4 : 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.lightAppBar
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
                                                  : AppColors.lightAppBar,
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
                                                color: AppColors.lightAppBar),
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
                                                S.of(context).shared,
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
                                            Icons.insert_drive_file,
                                            '$filesCount',
                                            S.of(context).files,
                                          ),
                                        ],
                                      ),
                                      if (isSelected && !isAlreadyShared) ...[
                                        SizedBox(height: 12),
                                        // ✅ خيار المشاركة لمرة واحدة
                                        Row(
                                          children: [
                                            Expanded(
                                              child: CheckboxListTile(
                                                title: Text(
                                                  S.of(context).oneTimeShare,
                                                  style: TextStyle(fontSize: 14),
                                                ),
                                                subtitle: isOneTimeShare
                                                    ? Text(
                                                        S.of(context).expiresInHours('${expiresInHours ?? 24}')
,
                                                        style: TextStyle(fontSize: 12),
                                                      )
                                                    : null,
                                                value: isOneTimeShare,
                                                onChanged: (value) {
                                                  setState(() {
                                                    isOneTimeShare = value ?? false;
                                                    if (isOneTimeShare && expiresInHours == null) {
                                                      expiresInHours = 24;
                                                    }
                                                  });
                                                  if (value == true) {
                                                    _showOneTimeShareDialog();
                                                  }
                                                },
                                                contentPadding: EdgeInsets.zero,
                                                controlAffinity: ListTileControlAffinity.leading,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
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
                                                            _shareFileWithRoom(
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
                                                label: Text(isOneTimeShare 
                                                    ? S.of(context).oneTimeShare
                                                    : S.of(context).share),
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

