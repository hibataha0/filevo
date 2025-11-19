import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/views/folders/send_invitation_page.dart';
import 'package:filevo/views/folders/room_members_page.dart';
import 'package:filevo/views/folders/room_comments_page.dart';
import 'package:filevo/views/folders/share_file_with_room_page.dart';
import 'package:filevo/views/folders/share_folder_with_room_page.dart';
import 'package:filevo/views/folders/room_files_page.dart';
import 'package:filevo/views/fileViewer/pdfViewer.dart';
import 'package:filevo/views/fileViewer/VideoViewer.dart';
import 'package:filevo/views/fileViewer/audioPlayer.dart';
import 'package:filevo/views/fileViewer/imageViewer.dart';
import 'package:filevo/views/fileViewer/office_file_opener.dart';
import 'package:filevo/views/fileViewer/textViewer.dart';
import 'package:filevo/config/api_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class RoomDetailsPage extends StatefulWidget {
  final String roomId;

  const RoomDetailsPage({super.key, required this.roomId});

  @override
  State<RoomDetailsPage> createState() => _RoomDetailsPageState();
}

class _RoomDetailsPageState extends State<RoomDetailsPage> {
  Map<String, dynamic>? roomData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // ✅ تأجيل تحميل البيانات حتى بعد اكتمال البناء الأولي
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoomDetails();
    });
  }

  Future<void> _loadRoomDetails() async {
    if (!mounted) return;
    
    final roomController = Provider.of<RoomController>(context, listen: false);
    final response = await roomController.getRoomById(widget.roomId);

    if (mounted) {
      setState(() {
        roomData = response?['room'];
        isLoading = false;
      });
    }
  }

  Future<void> _refreshRoom() async {
    setState(() => isLoading = true);
    await _loadRoomDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFD),
      appBar: AppBar(
        title: Text(
          'تفاصيل الغرفة',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Color(0xff28336f),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshRoom,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : roomData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('فشل تحميل تفاصيل الغرفة'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshRoom,
                        child: Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshRoom,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildRoomHeader(),
                        SizedBox(height: 20),
                        _buildQuickActions(),
                        SizedBox(height: 20),
                        _buildRoomInfo(),
                        SizedBox(height: 20),
                        _buildMembersSection(),
                        SizedBox(height: 20),
                        _buildSharedFilesSection(),
                        SizedBox(height: 20),
                        _buildSharedFoldersSection(),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildRoomHeader() {
    final owner = roomData!['owner'] ?? {};
    final membersCount = (roomData!['members'] as List?)?.length ?? 0;
    final filesCount = (roomData!['files'] as List?)?.length ?? 0;
    final foldersCount = (roomData!['folders'] as List?)?.length ?? 0;

    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff28336f), Color(0xFF4D62D5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(0xff28336f).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.meeting_room,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roomData!['name'] ?? 'بدون اسم',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'المالك: ${owner['name'] ?? owner['email'] ?? '—'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (roomData!['description'] != null &&
              roomData!['description'].toString().isNotEmpty) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                roomData!['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          SizedBox(height: 20),
          Row(
            children: [
              _buildStatItem(Icons.people, '$membersCount', 'أعضاء'),
              SizedBox(width: 16),
              _buildStatItem(Icons.insert_drive_file, '$filesCount', 'ملفات'),
              SizedBox(width: 16),
              _buildStatItem(Icons.folder, '$foldersCount', 'مجلدات'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final userId = roomData!['owner']?['_id']?.toString() ?? '';
    // TODO: Get current user ID from AuthController
    final isOwner = true; // Replace with actual check

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.person_add,
              label: 'إرسال دعوة',
              color: Color(0xFF10B981),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider.value(
                      value: Provider.of<RoomController>(context, listen: false),
                      child: SendInvitationPage(roomId: widget.roomId),
                    ),
                  ),
                );
                if (result == true) {
                  _refreshRoom();
                }
              },
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              icon: Icons.people,
              label: 'الأعضاء',
              color: Color(0xFF4F6BED),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider.value(
                      value: Provider.of<RoomController>(context, listen: false),
                      child: RoomMembersPage(roomId: widget.roomId),
                    ),
                  ),
                );
                if (result == true) {
                  _refreshRoom();
                }
              },
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              icon: Icons.comment,
              label: 'التعليقات',
              color: Color(0xFFF59E0B),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomCommentsPage(roomId: widget.roomId),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4F6BED), Color(0xFF6D8BFF)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.info_outline, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'معلومات الغرفة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildInfoItem('🕒', 'أنشئت في', _formatDate(roomData!['createdAt'])),
          _buildInfoItem('✏️', 'آخر تعديل', _formatDate(roomData!['updatedAt'])),
          _buildInfoItem('👤', 'المالك', roomData!['owner']?['name'] ?? roomData!['owner']?['email'] ?? '—'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String emoji, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 20)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection() {
    final members = roomData!['members'] as List? ?? [];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF34D399)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.people, color: Colors.white, size: 20),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'الأعضاء (${members.length})',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider.value(
                        value: Provider.of<RoomController>(context, listen: false),
                        child: RoomMembersPage(roomId: widget.roomId),
                      ),
                    ),
                  );
                  if (result == true) _refreshRoom();
                },
                icon: Icon(Icons.arrow_forward_ios, size: 16),
                label: Text('عرض الكل'),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (members.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'لا يوجد أعضاء',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ...members.take(3).map((member) => _buildMemberItem(member)),
        ],
      ),
    );
  }

  Widget _buildMemberItem(Map<String, dynamic> member) {
    final user = member['user'] ?? {};
    final role = member['role'] ?? 'viewer';
    final permission = member['permission'] ?? 'view';

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getRoleColor(role).withOpacity(0.2),
            child: Icon(
              _getRoleIcon(role),
              color: _getRoleColor(role),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? user['email'] ?? '—',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$role • $permission',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharedFilesSection() {
    final files = roomData!['files'] as List? ?? [];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.insert_drive_file, color: Colors.white, size: 20),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'الملفات المشتركة (${files.length})',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (files.length > 3)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider.value(
                              value: Provider.of<RoomController>(context, listen: false),
                              child: RoomFilesPage(roomId: widget.roomId),
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.arrow_forward_ios, size: 16),
                      label: Text('عرض الكل'),
                    ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, color: Color(0xFFF59E0B)),
                    tooltip: 'إضافة ملف',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('إضافة ملف للغرفة'),
                          content: Text('يرجى فتح صفحة تفاصيل الملف ومشاركته مع الغرفة من هناك'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('موافق'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          if (files.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'لا توجد ملفات مشتركة',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ...files.take(3).map((file) => _buildFileItem(file)),
        ],
      ),
    );
  }

  Widget _buildFileItem(Map<String, dynamic> file) {
    final fileIdRef = file['fileId'];
    final fileData = fileIdRef is Map<String, dynamic> ? fileIdRef : <String, dynamic>{};
    final fileName = fileData['name']?.toString() ?? 'ملف غير معروف';
    final fileId = fileData['_id']?.toString() ?? 
                   (fileIdRef is String ? fileIdRef : fileIdRef?.toString());
    
    return InkWell(
      onTap: () => _openFile(fileData, fileId),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(Icons.description, color: Color(0xFFF59E0B)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                fileName,
                style: TextStyle(fontSize: 14),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  String _getFileUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    
    if (path.startsWith('http')) {
      return path;
    }

    String cleanPath = path.replaceAll(r'\', '/').replaceAll('//', '/');
    while (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    final base = ApiConfig.baseUrl.replaceAll('/api/v1', '');
    String baseClean = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    String finalUrl = '$baseClean/$cleanPath';

    return finalUrl;
  }

  Future<void> _openFile(Map<String, dynamic> fileData, String? fileId) async {
    if (fileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('معرف الملف غير متوفر'), backgroundColor: Colors.red),
      );
      return;
    }

    final filePath = fileData['path']?.toString();
    if (filePath == null || filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('رابط الملف غير متوفر'), backgroundColor: Colors.orange),
      );
      return;
    }

    final fileName = fileData['name']?.toString() ?? 'ملف';
    final name = fileName.toLowerCase();
    final url = _getFileUrl(filePath);

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('رابط غير صالح'), backgroundColor: Colors.red),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final client = http.Client();
      final response = await client.get(Uri.parse(url), headers: {'Range': 'bytes=0-511'});
      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 206) {
        final bytes = response.bodyBytes;
        final isPdf = _isValidPdf(bytes);

        if (name.endsWith('.pdf')) {
          if (!isPdf) {
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('ملف غير مدعوم'),
                  content: Text('هذا الملف ليس PDF صالح أو قد يكون تالفاً.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _openAsTextFile(url, fileName);
                      },
                      child: Text('فتح كنص'),
                    ),
                  ],
                ),
              );
            }
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PdfViewerPage(pdfUrl: url, fileName: fileName)),
          );
        }
        // فيديو
        else if (name.endsWith('.mp4') || name.endsWith('.mov') || name.endsWith('.mkv') ||
            name.endsWith('.avi') || name.endsWith('.wmv')) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => VideoViewer(url: url)));
        }
        // صورة
        else if (name.endsWith('.jpg') || name.endsWith('.jpeg') || name.endsWith('.png') ||
            name.endsWith('.gif') || name.endsWith('.bmp') || name.endsWith('.webp')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageViewer(
                imageUrl: url,
                roomId: widget.roomId,
                fileId: fileId,
              ),
            ),
          );
        }
        // نص
        else if (TextViewerPage.isTextFile(fileName)) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(child: CircularProgressIndicator()),
          );
          try {
            final fullResponse = await http.get(Uri.parse(url));
            if (mounted) Navigator.pop(context);
            if (fullResponse.statusCode == 200) {
              final tempDir = await getTemporaryDirectory();
              final tempFile = File('${tempDir.path}/$fileName');
              await tempFile.writeAsBytes(fullResponse.bodyBytes);
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => TextViewerPage(filePath: tempFile.path, fileName: fileName)),
                );
              }
            }
          } catch (e) {
            if (mounted) Navigator.pop(context);
          }
        }
        // صوت
        else if (name.endsWith('.mp3') ||
            name.endsWith('.wav') ||
            name.endsWith('.aac') ||
            name.endsWith('.ogg')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AudioPlayerPage(audioUrl: url, fileName: fileName)),
          );
        }
        // ملفات أخرى
        else {
          await OfficeFileOpener.openAnyFile(url: url, fileName: fileName, context: context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('الملف غير متاح (خطأ ${response.statusCode})'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الملف: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isValidPdf(List<int> bytes) {
    if (bytes.length < 4) return false;
    final pdfHeader = [0x25, 0x50, 0x44, 0x46]; // %PDF
    for (int i = 0; i < 4; i++) {
      if (bytes[i] != pdfHeader[i]) return false;
    }
    return true;
  }

  Future<void> _openAsTextFile(String url, String fileName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    try {
      final fullResponse = await http.get(Uri.parse(url));
      if (mounted) Navigator.pop(context);
      if (fullResponse.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(fullResponse.bodyBytes);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => TextViewerPage(filePath: tempFile.path, fileName: fileName)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في فتح الملف: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSharedFoldersSection() {
    final folders = roomData!['folders'] as List? ?? [];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.folder, color: Colors.white, size: 20),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'المجلدات المشتركة (${folders.length})',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: Color(0xFF8B5CF6)),
                tooltip: 'إضافة مجلد',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('إضافة مجلد للغرفة'),
                      content: Text('يرجى فتح صفحة تفاصيل المجلد ومشاركته مع الغرفة من هناك'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('موافق'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          if (folders.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'لا توجد مجلدات مشتركة',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ...folders.take(3).map((folder) => _buildFolderItem(folder)),
        ],
      ),
    );
  }

  Widget _buildFolderItem(Map<String, dynamic> folder) {
    final folderData = folder['folderId'] ?? {};
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.folder, color: Color(0xFF8B5CF6)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              folderData['name'] ?? 'مجلد غير معروف',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'owner':
        return Color(0xFFEF4444);
      case 'editor':
        return Color(0xFFF59E0B);
      case 'viewer':
        return Color(0xFF10B981);
      default:
        return Color(0xFF6B7280);
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'owner':
        return Icons.star;
      case 'editor':
        return Icons.edit;
      case 'viewer':
        return Icons.visibility;
      default:
        return Icons.person;
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
}

