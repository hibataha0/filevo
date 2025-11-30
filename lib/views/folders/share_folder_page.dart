import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';

class ShareFolderPage extends StatefulWidget {
  final String folderId;
  final String folderName;

  const ShareFolderPage({
    super.key,
    required this.folderId,
    required this.folderName,
  });

  @override
  State<ShareFolderPage> createState() => _ShareFolderPageState();
}

class _ShareFolderPageState extends State<ShareFolderPage> {
  final TextEditingController _userIdController = TextEditingController();
  final List<String> _selectedUserIds = [];
  String _selectedPermission = 'view';
  bool _isLoading = false;

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  void _addUserId() {
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال معرف المستخدم')),
      );
      return;
    }

    if (_selectedUserIds.contains(userId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('المستخدم موجود بالفعل في القائمة')),
      );
      return;
    }

    setState(() {
      _selectedUserIds.add(userId);
      _userIdController.clear();
    });
  }

  void _removeUserId(String userId) {
    setState(() {
      _selectedUserIds.remove(userId);
    });
  }

  Future<void> _shareFolder() async {
    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إضافة مستخدم واحد على الأقل')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final folderController = Provider.of<FolderController>(context, listen: false);
    final success = await folderController.shareFolder(
      folderId: widget.folderId,
      userIds: _selectedUserIds,
      permission: _selectedPermission,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم مشاركة المجلد بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(folderController.errorMessage ?? '❌ فشل مشاركة المجلد'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مشاركة المجلد'),
        actions: [
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _shareFolder,
              child: Text(
                'مشاركة',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ معلومات المجلد
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder, color: Colors.blue[700], size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المجلد',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.folderName,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue[900],
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // ✅ إضافة مستخدمين
            Text(
              'إضافة مستخدمين',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _userIdController,
                    decoration: InputDecoration(
                      hintText: 'أدخل معرف المستخدم',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    onSubmitted: (_) => _addUserId(),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: _addUserId,
                  icon: Icon(Icons.add_circle),
                  color: Colors.blue,
                  iconSize: 32,
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'أدخل معرف المستخدم (User ID) للمشاركة',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),

            // ✅ قائمة المستخدمين المختارين
            if (_selectedUserIds.isNotEmpty) ...[
              Text(
                'المستخدمون المختارون (${_selectedUserIds.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              ..._selectedUserIds.map((userId) => Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.blue[700]),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            userId,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeUserId(userId),
                          icon: Icon(Icons.close, color: Colors.red),
                          iconSize: 20,
                        ),
                      ],
                    ),
                  )),
              SizedBox(height: 24),
            ],

            // ✅ اختيار الصلاحيات
            Text(
              'الصلاحيات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            _buildPermissionOption('view', 'عرض فقط', Icons.visibility, Colors.blue),
            SizedBox(height: 8),
            _buildPermissionOption('edit', 'عرض وتعديل', Icons.edit, Colors.orange),
            SizedBox(height: 8),
            _buildPermissionOption('delete', 'عرض وتعديل وحذف', Icons.delete, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionOption(String permission, String label, IconData icon, Color color) {
    final isSelected = _selectedPermission == permission;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPermission = permission;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }
}







