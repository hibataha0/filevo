import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/room_controller.dart';

class PendingInvitationsPage extends StatefulWidget {
  @override
  State<PendingInvitationsPage> createState() => _PendingInvitationsPageState();
}

class _PendingInvitationsPageState extends State<PendingInvitationsPage> {
  List<Map<String, dynamic>> invitations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // ✅ تأجيل تحميل البيانات حتى بعد اكتمال البناء الأولي
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInvitations();
    });
  }

  Future<void> _loadInvitations() async {
    if (!mounted) return;
    
    final roomController = Provider.of<RoomController>(context, listen: false);
    final result = await roomController.getPendingInvitations();

    if (mounted) {
      setState(() {
        invitations = result;
        isLoading = false;
      });
    }
  }

  Future<void> _acceptInvitation(String invitationId) async {
    final roomController = Provider.of<RoomController>(context, listen: false);
    final result = await roomController.acceptInvitation(invitationId);

    if (mounted) {
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم قبول الدعوة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        _loadInvitations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(roomController.errorMessage ?? '❌ فشل قبول الدعوة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectInvitation(String invitationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('رفض الدعوة'),
        content: Text('هل أنت متأكد من رفض هذه الدعوة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('رفض', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final roomController = Provider.of<RoomController>(context, listen: false);
      final success = await roomController.rejectInvitation(invitationId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تم رفض الدعوة'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadInvitations();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(roomController.errorMessage ?? '❌ فشل رفض الدعوة'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الدعوات المعلقة'),
        backgroundColor: Color(0xff28336f),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              _loadInvitations();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : invitations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mail_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد دعوات معلقة',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'سيتم عرض الدعوات هنا عند استلامها',
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
                  onRefresh: _loadInvitations,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: invitations.length,
                    itemBuilder: (context, index) {
                      final invitation = invitations[index];
                      return _buildInvitationCard(invitation);
                    },
                  ),
                ),
    );
  }

  Widget _buildInvitationCard(Map<String, dynamic> invitation) {
    final sender = invitation['sender'] ?? {};
    final room = invitation['room'] ?? {};
    final permission = invitation['permission'] ?? 'view';
    final message = invitation['message'] ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xff28336f).withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: Color(0xff28336f),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sender['name'] ?? sender['email'] ?? 'مستخدم',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'دعاك للانضمام إلى غرفة',
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
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xff28336f).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.meeting_room, size: 20, color: Color(0xff28336f)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          room['name'] ?? 'غرفة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (room['description'] != null &&
                      room['description'].toString().isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      room['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (message.isNotEmpty) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.message, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPermissionColor(permission).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'الصلاحية: $permission',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getPermissionColor(permission),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  _formatDate(invitation['createdAt']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectInvitation(invitation['_id']),
                    icon: Icon(Icons.close, size: 18),
                    label: Text('رفض'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptInvitation(invitation['_id']),
                    icon: Icon(Icons.check, size: 18),
                    label: Text('قبول'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPermissionColor(String permission) {
    switch (permission) {
      case 'view':
        return Color(0xFF10B981);
      case 'edit':
        return Color(0xFFF59E0B);
      case 'delete':
        return Color(0xFFEF4444);
      default:
        return Colors.grey;
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

