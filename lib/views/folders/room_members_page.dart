import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filevo/config/api_config.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/utils/room_permissions.dart';
import 'package:filevo/generated/l10n.dart';

class RoomMembersPage extends StatefulWidget {
  final String roomId;

  const RoomMembersPage({super.key, required this.roomId});

  @override
  State<RoomMembersPage> createState() => _RoomMembersPageState();
}

class _RoomMembersPageState extends State<RoomMembersPage> {
  Map<String, dynamic>? roomData;
  bool isLoading = true;
  bool _hasChanges = false; // ✅ تتبع إذا كان هناك تغييرات

  @override
  void initState() {
    super.initState();
    // ✅ تأجيل تحميل البيانات حتى بعد اكتمال البناء الأولي
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoomData();
    });
  }

  Future<void> _loadRoomData() async {
    if (!mounted) return;

    final roomController = Provider.of<RoomController>(context, listen: false);
    final response = await roomController.getRoomById(widget.roomId);

    if (mounted) {
      // ✅ Debug: طباعة بيانات الأعضاء للتحقق من وجود profileImg
      if (response?['room'] != null) {
        final members = response!['room']['members'] as List? ?? [];
        if (members.isNotEmpty) {
          print('👥 [RoomMembersPage] Members loaded: ${members.length}');
          print('👥 [RoomMembersPage] First member user keys: ${members[0]['user']?.keys.toList()}');
          print('👥 [RoomMembersPage] First member user profileImg: ${members[0]['user']?['profileImg']}');
        }
      }
      setState(() {
        roomData = response?['room'];
        isLoading = false;
      });
    }
  }

  Future<void> _updateMemberRole(
    String memberId,
    String role, {
    bool? canShare,
  }) async {
    final roomController = Provider.of<RoomController>(context, listen: false);

    final success = await roomController.updateMemberRole(
      roomId: widget.roomId,
      memberId: memberId,
      role: role,
      canShare: canShare,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم تحديث الدور بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        _loadRoomData();
        _hasChanges = true; // ✅ تم تسجيل تغيير
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(roomController.errorMessage ?? '❌ فشل تحديث الدور'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeMember(String memberId, String memberName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).removeMember),
        content: Text(S.of(context).confirmRemoveMember(memberName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.of(context).remove, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final roomController = Provider.of<RoomController>(
        context,
        listen: false,
      );
      final success = await roomController.removeMember(
        roomId: widget.roomId,
        memberId: memberId,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تم إزالة العضو بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          // ✅ تحديث بيانات الصفحة الحالية أولاً
          await _loadRoomData();
          _hasChanges = true; // ✅ تم تسجيل تغيير
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(roomController.errorMessage ?? '❌ فشل إزالة العضو'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showMemberOptions(Map<String, dynamic> member) async {
    if (roomData == null) return;

    // ✅ التأكد من أن user هو Map
    Map<String, dynamic> user;
    if (member['user'] is Map<String, dynamic>) {
      user = member['user'] as Map<String, dynamic>;
    } else {
      user = {};
    }
    
    final memberId = member['_id']?.toString() ?? '';
    final currentRole = member['role'] ?? 'viewer';
    final currentCanShare = member['canShare'] ?? false;
    final isOwner = currentRole == 'owner';
    
    // ✅ Debug: طباعة بيانات المستخدم
    print('👤 [RoomMembersPage] Member options user keys: ${user.keys.toList()}');
    print('👤 [RoomMembersPage] Member options user profileImg: ${user['profileImg']}');

    // ✅ التحقق من الصلاحيات
    final canUpdateRoles = await RoomPermissions.canUpdateMemberRoles(
      roomData!,
    );
    final canRemoveMembers = await RoomPermissions.canRemoveMembers(roomData!);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildMemberAvatar(user, currentRole),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] ?? user['email'] ?? '—',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currentRole,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            if (!isOwner) ...[
              // ✅ تحديث الدور - owner فقط
              if (canUpdateRoles) ...[
                Text(
                  'تحديث الدور',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildRoleChip('viewer', currentRole, () {
                      _updateMemberRole(memberId, 'viewer');
                      Navigator.pop(context);
                    }),
                    _buildRoleChip('editor', currentRole, () {
                      _updateMemberRole(memberId, 'editor');
                      Navigator.pop(context);
                    }),
                    _buildRoleChip('commenter', currentRole, () {
                      _updateMemberRole(memberId, 'commenter');
                      Navigator.pop(context);
                    }),
                  ],
                ),
                SizedBox(height: 24),
                Divider(),
                SizedBox(height: 12),
                // ✅ تحديث صلاحية المشاركة
                Text(
                  'صلاحيات المشاركة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: currentCanShare,
                        onChanged: (value) {
                          _updateMemberRole(
                            memberId,
                            currentRole,
                            canShare: value ?? false,
                          );
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'السماح بالمشاركة',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'يمكن للمستخدم مشاركة ملفات ومجلدات في هذه الغرفة',
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
                ),
                SizedBox(height: 24),
                Divider(),
                SizedBox(height: 12),
              ],
              // ✅ إزالة من الغرفة - owner فقط
              if (canRemoveMembers)
                ListTile(
                  leading: Icon(Icons.person_remove, color: Colors.red),
                  title: Text(
                    'إزالة من الغرفة',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeMember(
                      memberId,
                      user['name'] ?? user['email'] ?? 'العضو',
                    );
                  },
                ),
            ] else
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'لا يمكن تعديل دور المالك',
                        style: TextStyle(color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(String role, String current, VoidCallback onTap) {
    final isSelected = role == current;
    return FilterChip(
      label: Text(role),
      selected: isSelected,
      onSelected: (selected) => onTap(),
      selectedColor: _getRoleColor(role).withOpacity(0.2),
      checkmarkColor: _getRoleColor(role),
      labelStyle: TextStyle(
        color: isSelected ? _getRoleColor(role) : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).roomMembers),
        backgroundColor: Color(0xff28336f),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // ✅ إرجاع true إذا كان هناك تغييرات
            Navigator.of(context).pop(_hasChanges);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              _loadRoomData();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : roomData == null
          ? Center(child: Text(S.of(context).failedToLoadRoomData))
          : RefreshIndicator(
              onRefresh: _loadRoomData,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: (roomData!['members'] as List?)?.length ?? 0,
                itemBuilder: (context, index) {
                  final member = roomData!['members'][index];
                  return _buildMemberCard(member);
                },
              ),
            ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    // ✅ التأكد من أن user هو Map
    Map<String, dynamic> user;
    if (member['user'] is Map<String, dynamic>) {
      user = member['user'] as Map<String, dynamic>;
    } else {
      user = {};
    }
    
    final role = member['role'] ?? 'viewer';
    final isOwner = role == 'owner';
    
    // ✅ Debug: طباعة بيانات المستخدم
    print('👤 [RoomMembersPage] Member user keys: ${user.keys.toList()}');
    print('👤 [RoomMembersPage] Member user profileImg: ${user['profileImg']}');

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: _buildMemberAvatar(user, role),
        title: Text(
          user['name'] ?? user['email'] ?? '—',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getRoleColor(role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                role,
                style: TextStyle(
                  fontSize: 10,
                  color: _getRoleColor(role),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: !isOwner
            ? IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: () => _showMemberOptions(member),
              )
            : null,
        onTap: !isOwner ? () => _showMemberOptions(member) : null,
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
      case 'commenter':
        return Color(0xFF8B5CF6);
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
      case 'commenter':
        return Icons.comment;
      default:
        return Icons.person;
    }
  }

  // ✅ بناء URL كامل للصورة من اسم الملف (للـ backward compatibility)
  String? _buildProfileImageUrl(String? profileImg) {
    if (profileImg == null || profileImg.toString().isEmpty || profileImg.toString() == 'null') {
      return null;
    }

    final profileImgStr = profileImg.toString();

    // ✅ إذا كان URL كامل، استخدمه مباشرة
    if (profileImgStr.startsWith('http://') || profileImgStr.startsWith('https://')) {
      return profileImgStr;
    }

    // ✅ بناء URL من base URL + path
    String cleanPath = profileImgStr.replaceAll(r'\', '/').replaceAll('//', '/');
    while (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    // ✅ إزالة /api/v1 من base URL للحصول على base فقط
    final base = ApiConfig.baseUrl.replaceAll('/api/v1', '');
    final baseClean = base.endsWith('/') ? base.substring(0, base.length - 1) : base;

    // ✅ بناء URL كامل (الـ backend يخدم الملفات من uploads/)
    final imageUrl = '$baseClean/uploads/$cleanPath';
    print('🖼️ [RoomMembersPage] Building profile image URL:');
    print('  - Original: $profileImgStr');
    print('  - Clean path: $cleanPath');
    print('  - Final URL: $imageUrl');

    return imageUrl;
  }

  // ✅ بناء widget صورة البروفايل للعضو
  Widget _buildMemberAvatar(Map<String, dynamic> user, String role) {
    // ✅ قراءة profileImgUrl أولاً (من الباك إند الجديد)
    // ✅ إذا لم يكن موجوداً، استخدم profileImg وابني URL (للـ backward compatibility)
    final profileImgUrl = user['profileImgUrl'];
    final profileImg = user['profileImg'];
    final name = user['name'] ?? user['email'] ?? 'م';
    final firstLetter = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'م';

    // ✅ Debug: طباعة البيانات للتحقق
    print('🖼️ [RoomMembersPage] User data: ${user.keys.toList()}');
    print('🖼️ [RoomMembersPage] profileImgUrl: $profileImgUrl');
    print('🖼️ [RoomMembersPage] profileImg: $profileImg');
    print('🖼️ [RoomMembersPage] name: $name');

    // ✅ استخدام profileImgUrl إذا كان موجوداً، وإلا بناء URL من profileImg
    final imageUrl = profileImgUrl?.toString() ?? _buildProfileImageUrl(profileImg?.toString());

    if (imageUrl != null && imageUrl.isNotEmpty) {
      print('🖼️ [RoomMembersPage] Loading profile image from: $imageUrl');
      
      return CircleAvatar(
        radius: 24,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            width: 48,
            height: 48,
            placeholder: (context, url) => CircleAvatar(
              radius: 24,
              backgroundColor: _getRoleColor(role).withOpacity(0.2),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (context, url, error) {
              print('❌ [RoomMembersPage] Failed to load profile image: $error');
              return CircleAvatar(
                radius: 24,
                backgroundColor: _getRoleColor(role).withOpacity(0.2),
                child: Text(
                  firstLetter,
                  style: TextStyle(
                    color: _getRoleColor(role),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      print('🖼️ [RoomMembersPage] No profile image, using default avatar');
      return CircleAvatar(
        radius: 24,
        backgroundColor: _getRoleColor(role).withOpacity(0.2),
        child: Text(
          firstLetter,
          style: TextStyle(
            color: _getRoleColor(role),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      );
    }
  }
}
