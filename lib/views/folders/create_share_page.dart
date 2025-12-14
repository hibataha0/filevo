// ملف: lib/views/folders/create_share_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/generated/l10n.dart';

class CreateSharePage extends StatefulWidget {
  @override
  _CreateSharePageState createState() => _CreateSharePageState();
}

class _CreateSharePageState extends State<CreateSharePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).createNewShareRoom),
        backgroundColor: Color(0xff28336f),
        actions: [
          Consumer<RoomController>(
            builder: (context, roomController, child) {
              return IconButton(
                icon: roomController.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.check),
                onPressed: roomController.isLoading ? null : _createRoom,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'اسم الغرفة *',
                  border: OutlineInputBorder(),
                  hintText: 'أدخل اسم للغرفة',
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'وصف الغرفة (اختياري)',
                  border: OutlineInputBorder(),
                  hintText: 'أدخل وصفاً للغرفة',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              Consumer<RoomController>(
                builder: (context, roomController, child) {
                  if (roomController.errorMessage != null) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        padding: EdgeInsets.all(12),
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
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createRoom() async {
    if (_formKey.currentState!.validate()) {
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).pleaseEnterRoomName),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final roomController = Provider.of<RoomController>(context, listen: false);

      final response = await roomController.createRoom(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (response != null && response['room'] != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تم إنشاء الغرفة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, response['room']);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  roomController.errorMessage ?? '❌ فشل إنشاء الغرفة'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}