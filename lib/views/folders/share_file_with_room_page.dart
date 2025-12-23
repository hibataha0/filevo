import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/constants/app_colors.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:filevo/utils/file_type_utils.dart';

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
  late bool canOneTimeShare; // ✅ هل يمكن مشاركة الملف لمرة واحدة

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    // ✅ التحقق من أن الملف يمكن مشاركته لمرة واحدة
    // ✅ الملفات التي تفتح داخل التطبيق (PDF, الصور, الفيديو, الصوت, النصوص) يمكن مشاركتها لمرة واحدة
    // ❌ الملفات التي تفتح خارج التطبيق (Office, ZIP, etc.) لا يمكن مشاركتها لمرة واحدة

    // ✅ استخراج اسم الملف مع الامتداد
    final fileName = widget.fileName.trim();
    final opensInside = FileTypeUtils.opensInsideApp(fileName);
    canOneTimeShare = FileTypeUtils.canBeOneTimeShared(fileName);

    print(
      '🔍 [ShareFileWithRoomPage] ==========================================',
    );
    print('🔍 [ShareFileWithRoomPage] fileName: $fileName');
    print('🔍 [ShareFileWithRoomPage] opensInsideApp: $opensInside');
    print('🔍 [ShareFileWithRoomPage] canBeOneTimeShared: $canOneTimeShare');
    print(
      '🔍 [ShareFileWithRoomPage] ==========================================',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRooms();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    if (!mounted) return;

    final roomController = Provider.of<RoomController>(context, listen: false);
    await roomController.getRooms();

    if (mounted) {
      final roomsList = roomController.rooms;

      // ✅ تحميل تفاصيل كل روم بشكل متوازي للحصول على الملفات المشتركة
      final roomsWithDetails = await Future.wait(
        roomsList.map((room) async {
          try {
            final roomId = room['_id']?.toString();
            if (roomId != null) {
              // ✅ تحميل تفاصيل الروم للحصول على الملفات
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

  Future<void> _shareFileWithRoom(String roomId) async {
    if (!mounted) return;

    // ✅ إظهار loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final roomController = Provider.of<RoomController>(
        context,
        listen: false,
      );
      final success = await roomController.shareFileWithRoom(
        roomId: roomId,
        fileId: widget.fileId,
        isOneTime: isOneTimeShare,
        expiresInHours: isOneTimeShare ? (expiresInHours ?? 24) : null,
      );

      if (!mounted) return;

      // ✅ إغلاق loading indicator
      Navigator.of(context).pop();

      print(
        'ShareFileWithRoomPage: shareFileWithRoom response success: $success (one-time: $isOneTimeShare)',
      );

      if (success) {
        // ✅ التحقق من رسالة الخطأ لمعرفة إذا كان الملف مشارك بالفعل
        final errorMessage = roomController.errorMessage ?? '';
        final isAlreadyShared =
            errorMessage.toLowerCase().contains('already shared') ||
            errorMessage.toLowerCase().contains('مشارك بالفعل');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAlreadyShared
                  ? 'ℹ️ الملف مشارك بالفعل مع هذه الغرفة'
                  : isOneTimeShare
                  ? '✅ تم مشاركة الملف مع الغرفة (لمرة واحدة) بنجاح'
                  : '✅ تم مشاركة الملف مع الغرفة بنجاح',
            ),
            backgroundColor: isAlreadyShared ? Colors.blue : Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // ✅ تحديث قائمة الغرف لتحديث عدد الملفات
        await roomController.getRooms();

        Navigator.pop(context, true);
      } else {
        final errorMessage =
            roomController.errorMessage ?? '❌ فشل مشاركة الملف';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // ✅ إغلاق loading indicator في حالة الخطأ
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
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
                        final filesCount =
                            (room['files'] as List?)?.length ?? 0;
                        final isAlreadyShared = _checkIfFileIsShared(
                          room,
                          widget.fileId,
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
                                  ? AppColors.lightAppBar
                                  : isAlreadyShared
                                  ? Colors.green.shade300
                                  : Colors.transparent,
                              width: isSelected ? 2 : (isAlreadyShared ? 1 : 0),
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
                                          color: AppColors.lightAppBar,
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
                                  // ✅ إظهار معلومات إضافية إذا كان الملف مشارك
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
                                              'هذا الملف مشارك بالفعل مع هذه الغرفة',
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
                                  // ✅ إظهار خيارات المشاركة إذا كان الملف غير مشارك
                                  if (isSelected && !isAlreadyShared) ...[
                                    SizedBox(height: 12),
                                    // ✅ خيار المشاركة لمرة واحدة
                                    // ✅ فقط الملفات التي تفتح داخل التطبيق (الصور، الفيديو، الصوت، PDF، النصوص) يمكن مشاركتها لمرة واحدة
                                    // ❌ الملفات التي تفتح خارج التطبيق (Office, ZIP, etc.) لا يمكن مشاركتها لمرة واحدة
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
                                                    S
                                                        .of(context)
                                                        .expiresInHours(
                                                          '${expiresInHours ?? 24}',
                                                        ),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  )
                                                : !canOneTimeShare
                                                ? Text(
                                                    '⚠️ الملفات التي تفتح خارج التطبيق (Office, ZIP, etc.) لا يمكن مشاركتها لمرة واحدة',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.orange[700],
                                                    ),
                                                  )
                                                : null,
                                            value: isOneTimeShare,
                                            enabled:
                                                canOneTimeShare, // ✅ تعطيل الخيار للملفات التي تفتح خارج التطبيق
                                            onChanged: canOneTimeShare
                                                ? (value) {
                                                    setState(() {
                                                      isOneTimeShare =
                                                          value ?? false;
                                                      if (isOneTimeShare &&
                                                          expiresInHours ==
                                                              null) {
                                                        expiresInHours = 24;
                                                      }
                                                    });
                                                    if (value == true) {
                                                      _showOneTimeShareDialog();
                                                    }
                                                  }
                                                : null, // ✅ منع التغيير للملفات التي تفتح خارج التطبيق
                                            contentPadding: EdgeInsets.zero,
                                            controlAffinity:
                                                ListTileControlAffinity.leading,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: Consumer<RoomController>(
                                        builder: (context, roomController, child) {
                                          return ElevatedButton.icon(
                                            onPressed: roomController.isLoading
                                                ? null
                                                : () => _shareFileWithRoom(
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
                                              isOneTimeShare
                                                  ? S.of(context).oneTimeShare
                                                  : S.of(context).share,
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

  /// ✅ التحقق من أن الملف مشارك مع الغرفة
  bool _checkIfFileIsShared(Map<String, dynamic> room, String fileId) {
    print('🔍 [checkIfFileIsShared] Checking fileId: $fileId');
    print('🔍 [checkIfFileIsShared] Room: ${room['name']}');

    final files = room['files'] as List?;
    print('🔍 [checkIfFileIsShared] Files count: ${files?.length ?? 0}');

    if (files == null || files.isEmpty) {
      print('❌ [checkIfFileIsShared] No files in room');
      return false;
    }

    // ✅ طباعة جميع الملفات للتحقق
    for (int i = 0; i < files.length; i++) {
      final f = files[i];
      print('📄 [checkIfFileIsShared] File $i: $f');
    }

    final isShared = files.any((f) {
      if (f == null) {
        return false;
      }

      final fileIdRef = f['fileId'];
      if (fileIdRef == null) {
        return false;
      }

      String? actualFileId;

      // ✅ إذا كان fileId هو String مباشرة
      if (fileIdRef is String) {
        actualFileId = fileIdRef;
      }
      // ✅ إذا كان fileId هو Map/Object
      else if (fileIdRef is Map<String, dynamic>) {
        // ✅ محاولة قراءة _id بطرق مختلفة
        actualFileId =
            fileIdRef['_id']?.toString() ?? fileIdRef['id']?.toString();

        // ✅ إذا كان _id نفسه Map (nested)
        if (actualFileId == null && fileIdRef['_id'] is Map) {
          final nestedId = fileIdRef['_id'] as Map;
          actualFileId =
              nestedId['_id']?.toString() ?? nestedId['id']?.toString();
        }
      }
      // ✅ إذا كان fileId هو ObjectId أو أي نوع آخر
      else {
        actualFileId = fileIdRef.toString();
      }

      if (actualFileId == null) {
        return false;
      }

      final matches = actualFileId == fileId;
      if (matches) {
        print('✅ [checkIfFileIsShared] Found match: $actualFileId == $fileId');
      }
      return matches;
    });

    print('${isShared ? "✅" : "❌"} [checkIfFileIsShared] Result: $isShared');
    return isShared;
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
}
