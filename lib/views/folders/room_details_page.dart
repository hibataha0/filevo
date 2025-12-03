import 'dart:io';
import 'package:filevo/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/constants/app_colors.dart';
import 'package:filevo/views/folders/send_invitation_page.dart';
import 'package:filevo/views/folders/room_members_page.dart';
import 'package:filevo/views/folders/room_comments_page.dart';
import 'package:filevo/views/folders/share_file_with_room_page.dart';
import 'package:filevo/views/folders/share_folder_with_room_page.dart';
import 'package:filevo/views/folders/room_files_page.dart';
import 'package:filevo/views/folders/room_folders_page.dart';
import 'package:filevo/views/folders/folder_contents_page.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/views/fileViewer/pdfViewer.dart';
import 'package:filevo/views/fileViewer/VideoViewer.dart';
import 'package:filevo/views/fileViewer/audioPlayer.dart';
import 'package:filevo/views/fileViewer/imageViewer.dart';
import 'package:filevo/views/fileViewer/office_file_opener.dart';
import 'package:filevo/views/fileViewer/textViewer.dart';
import 'package:filevo/config/api_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:filevo/responsive.dart';
import 'package:filevo/services/storage_service.dart';

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
    
    try {
      final roomController = Provider.of<RoomController>(context, listen: false);
      final response = await roomController.getRoomById(widget.roomId);

      if (mounted) {
        setState(() {
          // ✅ التأكد من أن الاستجابة تحتوي على room
          if (response != null && response['room'] != null) {
            roomData = response['room'];
            isLoading = false;
          } else {
            roomData = null;
            isLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          roomData = null;
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${S.of(context).errorLoadingRoomDetails}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          S.of(context).roomDetails,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 18.0,
              tablet: 20.0,
              desktop: 22.0,
            ),
          ),
        ),
        backgroundColor: AppColors.lightAppBar,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white,
          size: ResponsiveUtils.getResponsiveValue(
            context,
            mobile: 24.0,
            tablet: 26.0,
            desktop: 28.0,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            iconSize: ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 24.0,
              tablet: 26.0,
              desktop: 28.0,
            ),
            onPressed: _refreshRoom,
          ),
          // ✅ قائمة خيارات الغرفة (حذف/مغادرة)
          if (roomData != null)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              iconSize: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 24.0,
                tablet: 26.0,
                desktop: 28.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) async {
                if (value == 'delete') {
                  // ✅ التحقق من أن المستخدم هو المالك قبل عرض dialog
                  final isOwner = await _checkIfCurrentUserIsOwner();
                  if (isOwner) {
                    _showDeleteRoomDialog();
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ ${S.of(context).onlyOwnerCanDelete}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } else if (value == 'leave') {
                  // ✅ التحقق من أن المستخدم ليس المالك قبل عرض dialog
                  final isOwner = await _checkIfCurrentUserIsOwner();
                  if (!isOwner) {
                    _showLeaveRoomDialog();
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ ${S.of(context).ownerCannotLeave}'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  }
                }
              },
              itemBuilder: (context) {
                // ✅ عرض كلا الخيارين، وسيتم التحقق في onSelected
                return [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 12),
                        Text(S.of(context).deleteRoom, style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'leave',
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app, color: Colors.orange),
                        SizedBox(width: 12),
                        Text(S.of(context).leaveRoom, style: TextStyle(color: Colors.orange)),
                      ],
                    ),
                  ),
                ];
              },
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
                      Text(S.of(context).failedToLoadRoomDetails),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshRoom,
                        child: Text(S.of(context).retry),
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
                        SizedBox(height: ResponsiveUtils.getResponsiveValue(
                          context,
                          mobile: 20.0,
                          tablet: 24.0,
                          desktop: 28.0,
                        )),
                        _buildQuickActions(),
                        SizedBox(height: ResponsiveUtils.getResponsiveValue(
                          context,
                          mobile: 20.0,
                          tablet: 24.0,
                          desktop: 28.0,
                        )),
                        _buildRoomInfo(),
                        SizedBox(height: ResponsiveUtils.getResponsiveValue(
                          context,
                          mobile: 20.0,
                          tablet: 24.0,
                          desktop: 28.0,
                        )),
                        _buildMembersSection(),
                        SizedBox(height: ResponsiveUtils.getResponsiveValue(
                          context,
                          mobile: 20.0,
                          tablet: 24.0,
                          desktop: 28.0,
                        )),
                        _buildSharedFilesSection(),
                        SizedBox(height: ResponsiveUtils.getResponsiveValue(
                          context,
                          mobile: 20.0,
                          tablet: 24.0,
                          desktop: 28.0,
                        )),
                        _buildSharedFoldersSection(),
                        SizedBox(height: ResponsiveUtils.getResponsiveValue(
                          context,
                          mobile: 100.0,
                          tablet: 120.0,
                          desktop: 140.0,
                        )),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildRoomHeader() {
    final owner = roomData!['owner'] ?? {};
    final membersCount = (roomData!['members'] as List?)?.length ?? 0;
    // ✅ ملاحظة: الـ backend يقوم بفلترة الملفات المشتركة لمرة واحدة تلقائياً
    final filesCount = (roomData!['files'] as List?)?.length ?? 0;
    final foldersCount = (roomData!['folders'] as List?)?.length ?? 0;

    final margin = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 32.0,
      desktop: 48.0,
    );
    final padding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );
    final borderRadius = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );
    final iconSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 60.0,
      tablet: 70.0,
      desktop: 80.0,
    );
    final iconInnerSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 30.0,
      tablet: 35.0,
      desktop: 40.0,
    );
    final titleFontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );
    final subtitleFontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 14.0,
      tablet: 16.0,
      desktop: 18.0,
    );
    final descriptionFontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 14.0,
      tablet: 16.0,
      desktop: 18.0,
    );
    final spacing = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );

    return Container(
      margin: EdgeInsets.all(margin),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.lightAppBar, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightAppBar.withOpacity(0.3),
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
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.meeting_room,
                  color: Colors.white,
                  size: iconInnerSize,
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roomData!['name'] ?? S.of(context).roomNamePlaceholder,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${S.of(context).owner}: ${owner['name'] ?? owner['email'] ?? '—'}',
                      style: TextStyle(
                        fontSize: subtitleFontSize,
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
            SizedBox(height: spacing),
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 12.0,
                tablet: 14.0,
                desktop: 16.0,
              )),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 12.0,
                  tablet: 14.0,
                  desktop: 16.0,
                )),
              ),
              child: Text(
                roomData!['description'],
                style: TextStyle(
                  fontSize: descriptionFontSize,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          SizedBox(height: spacing),
          Row(
            children: [
              _buildStatItem(Icons.people, '$membersCount', S.of(context).members),
              SizedBox(width: spacing),
              _buildStatItem(Icons.insert_drive_file, '$filesCount', S.of(context).files),
              SizedBox(width: spacing),
              _buildStatItem(Icons.folder, '$foldersCount', S.of(context).folders),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    final padding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 14.0,
      desktop: 16.0,
    );
    final horizontalPadding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 8.0,
      tablet: 10.0,
      desktop: 12.0,
    );
    final borderRadius = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 14.0,
      desktop: 16.0,
    );
    final iconSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );
    final valueFontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 18.0,
      tablet: 20.0,
      desktop: 22.0,
    );
    final labelFontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 14.0,
      desktop: 16.0,
    );

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: padding, horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: iconSize),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: valueFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: labelFontSize,
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

    final margin = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 32.0,
      desktop: 48.0,
    );
    final spacing = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: margin),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.person_add,
              label: S.of(context).sendInvitation,
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
          SizedBox(width: spacing),
          Expanded(
            child: _buildActionButton(
              icon: Icons.people,
              label: S.of(context).members,
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
          SizedBox(width: spacing),
          Expanded(
            child: _buildActionButton(
              icon: Icons.comment,
              label: S.of(context).comments,
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
    final borderRadius = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
    );
    final verticalPadding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
    );
    final iconSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 28.0,
      tablet: 32.0,
      desktop: 36.0,
    );
    final fontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 14.0,
      desktop: 16.0,
    );
    final spacing = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 8.0,
      tablet: 10.0,
      desktop: 12.0,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: iconSize),
            SizedBox(height: spacing),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
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
    final margin = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 32.0,
      desktop: 48.0,
    );
    final padding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );
    final borderRadius = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );
    final iconSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 40.0,
      tablet: 48.0,
      desktop: 56.0,
    );
    final iconInnerSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    final titleFontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 22.0,
      desktop: 24.0,
    );
    final spacing = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );
    final sectionSpacing = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: margin),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
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
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4F6BED), Color(0xFF6D8BFF)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.info_outline, color: Colors.white, size: iconInnerSize),
              ),
              SizedBox(width: spacing),
              Text(
                S.of(context).roomInfo,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: sectionSpacing),
          _buildInfoItem('🕒', S.of(context).createdAt, _formatDate(roomData!['createdAt'])),
          _buildInfoItem('✏️', S.of(context).lastModified, _formatDate(roomData!['updatedAt'])),
          _buildInfoItem('👤', S.of(context).owner, roomData!['owner']?['name'] ?? roomData!['owner']?['email'] ?? '—'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String emoji, String label, String value) {
    final emojiSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    final spacing = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );
    final labelFontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 14.0,
      desktop: 16.0,
    );
    final valueFontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
    );
    final bottomPadding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: emojiSize)),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: labelFontSize,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: valueFontSize,
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

    final margin = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 32.0,
      desktop: 48.0,
    );
    final padding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );
    final borderRadius = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );
    final iconSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 40.0,
      tablet: 48.0,
      desktop: 56.0,
    );
    final iconInnerSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    final titleFontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 22.0,
      desktop: 24.0,
    );
    final spacing = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );
    final sectionSpacing = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
    final emptyPadding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    final buttonIconSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
    );
    final buttonFontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 14.0,
      tablet: 16.0,
      desktop: 18.0,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: margin),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
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
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF34D399)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.people, color: Colors.white, size: iconInnerSize),
                  ),
                  SizedBox(width: spacing),
                  Text(
                    '${S.of(context).members} (${members.length})',
                    style: TextStyle(
                      fontSize: titleFontSize,
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
                  // ✅ تحديث البيانات تلقائياً عند الرجوع من صفحة الأعضاء
                  if (result == true || result == null) {
                    _refreshRoom();
                  }
                },
                icon: Icon(Icons.arrow_forward_ios, size: buttonIconSize),
                label: Text(
                  S.of(context).viewAll,
                  style: TextStyle(fontSize: buttonFontSize),
                ),
              ),
            ],
          ),
          SizedBox(height: sectionSpacing),
          if (members.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(emptyPadding),
                child: Text(
                  S.of(context).noMembers,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: ResponsiveUtils.getResponsiveValue(
                      context,
                      mobile: 14.0,
                      tablet: 16.0,
                      desktop: 18.0,
                    ),
                  ),
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

    final bottomPadding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 14.0,
      desktop: 16.0,
    );
    final avatarSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 40.0,
      tablet: 48.0,
      desktop: 56.0,
    );
    final iconSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    final spacing = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );
    final nameFontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
    );
    final roleFontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 14.0,
      desktop: 16.0,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        children: [
          CircleAvatar(
            radius: avatarSize / 2,
            backgroundColor: _getRoleColor(role).withOpacity(0.2),
            child: Icon(
              _getRoleIcon(role),
              color: _getRoleColor(role),
              size: iconSize,
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? user['email'] ?? '—',
                  style: TextStyle(
                    fontSize: nameFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: roleFontSize,
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

    final margin = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 32.0,
      desktop: 48.0,
    );
    final padding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );
    final borderRadius = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );
    final iconSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 40.0,
      tablet: 48.0,
      desktop: 56.0,
    );
    final iconInnerSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    final titleFontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 22.0,
      desktop: 24.0,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: margin),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
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
              Flexible(
                child: Row(
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.insert_drive_file,
                        color: Colors.white,
                        size: iconInnerSize,
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.getResponsiveValue(
                      context,
                      mobile: 12.0,
                      tablet: 16.0,
                      desktop: 20.0,
                    )),
                    Flexible(
                      child: Text(
                      S.of(context).sharedFilesCount('${files.length}'),

                     style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!ResponsiveUtils.isMobile(context))
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
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        size: ResponsiveUtils.getResponsiveValue(
                          context,
                          mobile: 16.0,
                          tablet: 18.0,
                          desktop: 20.0,
                        ),
                      ),
                      label: Text(
                        S.of(context).viewAll,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveValue(
                            context,
                            mobile: 14.0,
                            tablet: 16.0,
                            desktop: 18.0,
                          ),
                        ),
                      ),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        size: ResponsiveUtils.getResponsiveValue(
                          context,
                          mobile: 18.0,
                          tablet: 20.0,
                          desktop: 22.0,
                        ),
                      ),
                      tooltip: 'عرض الكل',
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
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFFF59E0B),
                      size: ResponsiveUtils.getResponsiveValue(
                        context,
                        mobile: 24.0,
                        tablet: 28.0,
                        desktop: 32.0,
                      ),
                    ),
                    tooltip: S.of(context).addFile,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(S.of(context).addFileToRoom),
                          content: Text(S.of(context).openFileDetailsToShare),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(S.of(context).ok),
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
          SizedBox(height: ResponsiveUtils.getResponsiveValue(
            context,
            mobile: 16.0,
            tablet: 20.0,
            desktop: 24.0,
          )),
          if (files.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 20.0,
                  tablet: 24.0,
                  desktop: 28.0,
                )),
                child: Text(
                  'لا توجد ملفات مشتركة',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: ResponsiveUtils.getResponsiveValue(
                      context,
                      mobile: 14.0,
                      tablet: 16.0,
                      desktop: 18.0,
                    ),
                  ),
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
    
    final iconSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    final fontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 14.0,
      tablet: 16.0,
      desktop: 18.0,
    );
    final padding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 8.0,
      tablet: 10.0,
      desktop: 12.0,
    );
    
    return InkWell(
      onTap: () => _openFile(fileData, fileId),
      borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(
        context,
        mobile: 8.0,
        tablet: 10.0,
        desktop: 12.0,
      )),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: padding,
          horizontal: ResponsiveUtils.getResponsiveValue(
            context,
            mobile: 4.0,
            tablet: 6.0,
            desktop: 8.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.description,
              color: Color(0xFFF59E0B),
              size: iconSize,
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 12.0,
              tablet: 16.0,
              desktop: 20.0,
            )),
            Expanded(
              child: Text(
                fileName,
                style: TextStyle(fontSize: fontSize),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 16.0,
                tablet: 18.0,
                desktop: 20.0,
              ),
              color: Colors.grey,
            ),
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
                      child: Text(S.of(context).cancel),
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
          final token = await StorageService.getToken();
          await OfficeFileOpener.openAnyFile(url: url, context: context, token: token);
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

    final margin = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 32.0,
      desktop: 48.0,
    );
    final padding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );
    final borderRadius = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );
    final iconSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 40.0,
      tablet: 48.0,
      desktop: 56.0,
    );
    final iconInnerSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    final titleFontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 22.0,
      desktop: 24.0,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: margin),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
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
              Flexible(
                child: Row(
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.folder,
                        color: Colors.white,
                        size: iconInnerSize,
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.getResponsiveValue(
                      context,
                      mobile: 12.0,
                      tablet: 16.0,
                      desktop: 20.0,
                    )),
                    Flexible(
                      child: Text(
                        'المجلدات المشتركة (${folders.length})',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!ResponsiveUtils.isMobile(context))
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider.value(
                              value: Provider.of<RoomController>(context, listen: false),
                              child: RoomFoldersPage(roomId: widget.roomId),
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        size: ResponsiveUtils.getResponsiveValue(
                          context,
                          mobile: 16.0,
                          tablet: 18.0,
                          desktop: 20.0,
                        ),
                      ),
                      label: Text(
                        S.of(context).viewAll,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveValue(
                            context,
                            mobile: 14.0,
                            tablet: 16.0,
                            desktop: 18.0,
                          ),
                        ),
                      ),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        size: ResponsiveUtils.getResponsiveValue(
                          context,
                          mobile: 18.0,
                          tablet: 20.0,
                          desktop: 22.0,
                        ),
                      ),
                      tooltip: 'عرض الكل',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider.value(
                              value: Provider.of<RoomController>(context, listen: false),
                              child: RoomFoldersPage(roomId: widget.roomId),
                            ),
                          ),
                        );
                      },
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF8B5CF6),
                      size: ResponsiveUtils.getResponsiveValue(
                        context,
                        mobile: 24.0,
                        tablet: 28.0,
                        desktop: 32.0,
                      ),
                      ),
                    tooltip: S.of(context).addFolder,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(S.of(context).addFolderToRoom),
                          content: Text(S.of(context).openFolderDetailsToShare),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(S.of(context).ok),
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
          SizedBox(height: ResponsiveUtils.getResponsiveValue(
            context,
            mobile: 16.0,
            tablet: 20.0,
            desktop: 24.0,
          )),
          if (folders.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 20.0,
                  tablet: 24.0,
                  desktop: 28.0,
                )),
                child: Text(
                  'لا توجد مجلدات مشتركة',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: ResponsiveUtils.getResponsiveValue(
                      context,
                      mobile: 14.0,
                      tablet: 16.0,
                      desktop: 18.0,
                    ),
                  ),
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
    // ✅ استخراج بيانات المجلد
    final folderIdRef = folder['folderId'];
    final folderData = folderIdRef is Map<String, dynamic> ? folderIdRef : <String, dynamic>{};
    final folderName = folderData['name']?.toString() ?? 'مجلد غير معروف';
    final folderId = folderData['_id']?.toString() ?? 
                     (folderIdRef is String ? folderIdRef : folderIdRef?.toString());
    
    final iconSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    final fontSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 14.0,
      tablet: 16.0,
      desktop: 18.0,
    );
    final padding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 8.0,
      tablet: 10.0,
      desktop: 12.0,
    );
    
    return InkWell(
      onTap: () {
        if (folderId != null && folderId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                value: Provider.of<FolderController>(context, listen: false),
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
      },
      borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(
        context,
        mobile: 8.0,
        tablet: 10.0,
        desktop: 12.0,
      )),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: padding,
          horizontal: ResponsiveUtils.getResponsiveValue(
            context,
            mobile: 4.0,
            tablet: 6.0,
            desktop: 8.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.folder,
              color: Color(0xFF8B5CF6),
              size: iconSize,
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 12.0,
              tablet: 16.0,
              desktop: 20.0,
            )),
            Expanded(
              child: Text(
                folderName,
                style: TextStyle(fontSize: fontSize),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 16.0,
                tablet: 18.0,
                desktop: 20.0,
              ),
              color: Colors.grey,
            ),
          ],
        ),
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

  /// ✅ التحقق من أن المستخدم الحالي هو مالك الغرفة (async)
  Future<bool> _checkIfCurrentUserIsOwner() async {
    if (roomData == null) return false;
    final owner = roomData!['owner'];
    if (owner == null) return false;
    
    // ✅ الحصول على معرف المالك
    final ownerId = owner is Map<String, dynamic> 
        ? (owner['_id']?.toString() ?? owner['id']?.toString())
        : owner.toString();
    
    if (ownerId == null || ownerId.isEmpty) return false;
    
    // ✅ الحصول على معرف المستخدم الحالي
    final roomController = Provider.of<RoomController>(context, listen: false);
    final currentUserId = await roomController.getCurrentUserId();
    
    if (currentUserId == null || currentUserId.isEmpty) return false;
    
    return currentUserId == ownerId;
  }

  /// ✅ عرض dialog لحذف الغرفة
  void _showDeleteRoomDialog() {
    if (roomData == null) return;
    final roomName = roomData!['name'] ?? 'الغرفة';
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).deleteRoom),
        content:Text(
  S.of(context).deleteRoomConfirm(roomName),
)
,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteRoom();
            },
            child: Text(S.of(context).deleteRoom, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// ✅ عرض dialog لمغادرة الغرفة
  void _showLeaveRoomDialog() {
    if (roomData == null) return;
    final roomName = roomData!['name'] ?? 'الغرفة';
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).leaveRoom),
        content: Text(S.of(context).leaveRoomConfirm(roomName))
,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _leaveRoom();
            },
            child: Text(S.of(context).leave, style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  /// ✅ حذف الغرفة
  Future<void> _deleteRoom() async {
    if (roomData == null) return;
    
    try {
      final roomController = Provider.of<RoomController>(context, listen: false);
      final success = await roomController.deleteRoom(widget.roomId);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تم حذف الغرفة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          // ✅ الرجوع إلى الصفحة السابقة
          Navigator.of(context).pop(true); // إرجاع true للإشارة إلى أنه تم حذف الغرفة
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(roomController.errorMessage ?? '❌ فشل حذف الغرفة'),
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

  /// ✅ مغادرة الغرفة
  Future<void> _leaveRoom() async {
    if (roomData == null) return;
    
    try {
      final roomController = Provider.of<RoomController>(context, listen: false);
      final success = await roomController.leaveRoom(widget.roomId);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تم مغادرة الغرفة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          // ✅ الرجوع إلى الصفحة السابقة
          Navigator.of(context).pop(true); // إرجاع true للإشارة إلى أنه تم مغادرة الغرفة
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(roomController.errorMessage ?? '❌ فشل مغادرة الغرفة'),
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
}

