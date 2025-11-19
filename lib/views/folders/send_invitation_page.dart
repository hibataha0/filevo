import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/room_controller.dart';

class SendInvitationPage extends StatefulWidget {
  final String roomId;

  const SendInvitationPage({super.key, required this.roomId});

  @override
  State<SendInvitationPage> createState() => _SendInvitationPageState();
}

class _SendInvitationPageState extends State<SendInvitationPage> {
  final _formKey = GlobalKey<FormState>();
  final _receiverIdController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedPermission = 'view';
  String? _selectedRole;

  @override
  void dispose() {
    _receiverIdController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendInvitation() async {
    if (_formKey.currentState!.validate()) {
      final roomController = Provider.of<RoomController>(context, listen: false);

      final result = await roomController.sendInvitation(
        roomId: widget.roomId,
        receiverId: _receiverIdController.text.trim(),
        permission: _selectedPermission,
        message: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
      );

      if (mounted) {
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تم إرسال الدعوة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(roomController.errorMessage ?? '❌ فشل إرسال الدعوة'),
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
        title: Text('إرسال دعوة'),
        backgroundColor: Color(0xff28336f),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff28336f), Color(0xFF4D62D5)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.person_add, color: Colors.white, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'دعوة مستخدم جديد',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'أدخل معرف المستخدم لإرسال الدعوة',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Receiver ID
              TextFormField(
                controller: _receiverIdController,
                decoration: InputDecoration(
                  labelText: 'معرف المستخدم *',
                  hintText: 'أدخل معرف المستخدم (User ID)',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال معرف المستخدم';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Permission
              Text(
                'الصلاحية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: Text('عرض فقط'),
                      subtitle: Text('يمكنه عرض الملفات فقط'),
                      value: 'view',
                      groupValue: _selectedPermission,
                      onChanged: (value) => setState(() => _selectedPermission = value!),
                    ),
                    Divider(height: 1),
                    RadioListTile<String>(
                      title: Text('تعديل'),
                      subtitle: Text('يمكنه تعديل الملفات'),
                      value: 'edit',
                      groupValue: _selectedPermission,
                      onChanged: (value) => setState(() => _selectedPermission = value!),
                    ),
                    Divider(height: 1),
                    RadioListTile<String>(
                      title: Text('حذف'),
                      subtitle: Text('يمكنه حذف الملفات'),
                      value: 'delete',
                      groupValue: _selectedPermission,
                      onChanged: (value) => setState(() => _selectedPermission = value!),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Role (optional)
              Text(
                'الدور (اختياري)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'اختر الدور',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: null, child: Text('بدون دور محدد')),
                  DropdownMenuItem(value: 'viewer', child: Text('عرض فقط')),
                  DropdownMenuItem(value: 'editor', child: Text('محرر')),
                  DropdownMenuItem(value: 'commenter', child: Text('معلق')),
                ],
                onChanged: (value) => setState(() => _selectedRole = value),
              ),
              SizedBox(height: 20),

              // Message
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'رسالة (اختياري)',
                  hintText: 'أضف رسالة ترحيبية...',
                  prefixIcon: Icon(Icons.message),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 32),

              // Error message
              Consumer<RoomController>(
                builder: (context, roomController, child) {
                  if (roomController.errorMessage != null) {
                    return Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              roomController.errorMessage!,
                              style: TextStyle(color: Colors.red.shade800),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),

              // Send button
              Consumer<RoomController>(
                builder: (context, roomController, child) {
                  return ElevatedButton(
                    onPressed: roomController.isLoading ? null : _sendInvitation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff28336f),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: roomController.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'إرسال الدعوة',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

