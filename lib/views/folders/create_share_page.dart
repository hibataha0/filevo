// ملف: lib/views/folders/create_share_page.dart
import 'package:flutter/material.dart';

class CreateSharePage extends StatefulWidget {
  @override
  _CreateSharePageState createState() => _CreateSharePageState();
}

class _CreateSharePageState extends State<CreateSharePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إنشاء مشاركة جديدة'),
        backgroundColor: Color(0xff28336f),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _createShare,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'اسم المشاركة',
                border: OutlineInputBorder(),
                hintText: 'أدخل اسم للمشاركة',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'وصف المشاركة (اختياري)',
                border: OutlineInputBorder(),
                hintText: 'أدخل وصفاً للمشاركة',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            // هنا يمكنك إضافة خيارات أخرى مثل:
            // - اختيار الملفات
            // - إعدادات المشاركة
            // - الصلاحيات
          ],
        ),
      ),
    );
  }

  void _createShare() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال اسم للمشاركة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newShare = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'createdAt': DateTime.now(),
      'icon': Icons.share,
      'color': Colors.blue,
      'fileCount': 0,
      'size': '0 B',
    };

    Navigator.pop(context, newShare);
  }
}