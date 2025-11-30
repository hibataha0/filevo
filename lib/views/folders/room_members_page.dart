import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/room_controller.dart';

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
      setState(() {
        roomData = response?['room'];
        isLoading = false;
      });
    }
  }

  Future<void> _updateMemberRole(String memberId, String role) async {
    final roomController = Provider.of<RoomController>(context, listen: false);

    final success = await roomController.updateMemberRole(
      roomId: widget.roomId,
      memberId: memberId,
      role: role,
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
        title: Text('إزالة عضو'),
        content: Text('هل أنت متأكد من إزالة $memberName من الغرفة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('إزالة', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final roomController = Provider.of<RoomController>(context, listen: false);
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

  void _showMemberOptions(Map<String, dynamic> member) {
    final user = member['user'] ?? {};
    final memberId = member['_id']?.toString() ?? '';
    final currentRole = member['role'] ?? 'viewer';
    final isOwner = currentRole == 'owner';

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getRoleColor(currentRole).withOpacity(0.2),
                  child: Icon(
                    _getRoleIcon(currentRole),
                    color: _getRoleColor(currentRole),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currentRole,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            if (!isOwner) ...[
              Text(
                'تحديث الدور',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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
              ListTile(
                leading: Icon(Icons.person_remove, color: Colors.red),
                title: Text(
                  'إزالة من الغرفة',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removeMember(memberId, user['name'] ?? user['email'] ?? 'العضو');
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
        title: Text('أعضاء الغرفة'),
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
              ? Center(child: Text('فشل تحميل بيانات الغرفة'))
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
    final user = member['user'] ?? {};
    final role = member['role'] ?? 'viewer';
    final isOwner = role == 'owner';

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(role).withOpacity(0.2),
          child: Icon(
            _getRoleIcon(role),
            color: _getRoleColor(role),
          ),
        ),
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

}

