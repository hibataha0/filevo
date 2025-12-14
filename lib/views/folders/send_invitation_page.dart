import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/generated/l10n.dart';

class SendInvitationPage extends StatefulWidget {
  final String roomId;

  const SendInvitationPage({super.key, required this.roomId});

  @override
  State<SendInvitationPage> createState() => _SendInvitationPageState();
}

class _SendInvitationPageState extends State<SendInvitationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedRole = 'viewer';
  bool _canShare = false;

  @override
  void initState() {
    super.initState();
    // ✅ مسح رسالة الخطأ عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomController = Provider.of<RoomController>(
        context,
        listen: false,
      );
      roomController.setError(null);
    });
  }

  @override
  void dispose() {
    // ✅ مسح رسالة الخطأ عند الخروج من الصفحة
    try {
      final roomController = Provider.of<RoomController>(
        context,
        listen: false,
      );
      roomController.setError(null);
    } catch (e) {
      // ✅ إذا لم يكن context متاحاً، لا مشكلة
    }
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendInvitation() async {
    if (_formKey.currentState!.validate()) {
      final roomController = Provider.of<RoomController>(
        context,
        listen: false,
      );

      // ✅ مسح رسالة الخطأ السابقة قبل إرسال دعوة جديدة
      roomController.setError(null);

      final result = await roomController.sendInvitation(
        roomId: widget.roomId,
        email: _emailController.text.trim(),
        role: _selectedRole,
        canShare: _canShare,
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
        }
        // ✅ رسالة الخطأ ستظهر تلقائياً في Consumer widget
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).sendInvitation),
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
                      'أدخل البريد الإلكتروني لإرسال الدعوة',
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

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني *',
                  hintText: 'أدخل البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  // ✅ مسح رسالة الخطأ عند بدء الكتابة
                  final roomController = Provider.of<RoomController>(
                    context,
                    listen: false,
                  );
                  if (roomController.errorMessage != null) {
                    roomController.setError(null);
                  }
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال البريد الإلكتروني';
                  }
                  // ✅ التحقق من صحة البريد الإلكتروني
                  final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'يرجى إدخال بريد إلكتروني صحيح';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Role
              Text(
                'الدور',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                      title: Text(S.of(context).viewOnly),
                      subtitle: Text(S.of(context).viewOnlyDescription),
                      value: 'viewer',
                      groupValue: _selectedRole,
                      onChanged: (value) =>
                          setState(() => _selectedRole = value!),
                    ),
                    Divider(height: 1),
                    RadioListTile<String>(
                      title: Text(S.of(context).editor),
                      subtitle: Text(S.of(context).editorDescription),
                      value: 'editor',
                      groupValue: _selectedRole,
                      onChanged: (value) =>
                          setState(() => _selectedRole = value!),
                    ),
                    Divider(height: 1),
                    RadioListTile<String>(
                      title: Text(S.of(context).commenter),
                      subtitle: Text(S.of(context).commenterDescription),
                      value: 'commenter',
                      groupValue: _selectedRole,
                      onChanged: (value) =>
                          setState(() => _selectedRole = value!),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Can Share Checkbox
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _canShare,
                      onChanged: (value) =>
                          setState(() => _canShare = value ?? false),
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
                    onPressed: roomController.isLoading
                        ? null
                        : _sendInvitation,
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
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
