import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/room_controller.dart';

class RoomCommentsPage extends StatefulWidget {
  final String roomId;
  final String? targetType; // 'file' or 'folder'
  final String? targetId;

  const RoomCommentsPage({
    super.key,
    required this.roomId,
    this.targetType,
    this.targetId,
  });

  @override
  State<RoomCommentsPage> createState() => _RoomCommentsPageState();
}

class _RoomCommentsPageState extends State<RoomCommentsPage> {
  List<Map<String, dynamic>> comments = [];
  bool isLoading = true;
  final TextEditingController _commentController = TextEditingController();
  String _selectedTargetType = 'file';
  String _selectedTargetId = '';

  @override
  void initState() {
    super.initState();
    if (widget.targetType != null && widget.targetId != null) {
      _selectedTargetType = widget.targetType!;
      _selectedTargetId = widget.targetId!;
      // ✅ تأجيل تحميل البيانات حتى بعد اكتمال البناء الأولي
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadComments();
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    if (_selectedTargetId.isEmpty) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      return;
    }

    if (!mounted) return;

    final roomController = Provider.of<RoomController>(context, listen: false);
    final result = await roomController.listComments(
      roomId: widget.roomId,
      targetType: _selectedTargetType,
      targetId: _selectedTargetId,
    );

    if (mounted) {
      setState(() {
        comments = result;
        isLoading = false;
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty || _selectedTargetId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال تعليق واختيار ملف/مجلد'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final roomController = Provider.of<RoomController>(context, listen: false);
    final result = await roomController.addComment(
      roomId: widget.roomId,
      targetType: _selectedTargetType,
      targetId: _selectedTargetId,
      content: _commentController.text.trim(),
    );

    if (mounted) {
      if (result != null) {
        _commentController.clear();
        _loadComments();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم إضافة التعليق بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(roomController.errorMessage ?? '❌ فشل إضافة التعليق'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف التعليق'),
        content: Text('هل أنت متأكد من حذف هذا التعليق؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final roomController = Provider.of<RoomController>(context, listen: false);
      final success = await roomController.deleteComment(
        roomId: widget.roomId,
        commentId: commentId,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تم حذف التعليق بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          _loadComments();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(roomController.errorMessage ?? '❌ فشل حذف التعليق'),
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
        title: Text('التعليقات'),
        backgroundColor: Color(0xff28336f),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              _loadComments();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Target Selection (if not provided)
          if (widget.targetId == null)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اختر ملف أو مجلد',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedTargetType,
                          decoration: InputDecoration(
                            labelText: 'النوع',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: [
                            DropdownMenuItem(value: 'file', child: Text('ملف')),
                            DropdownMenuItem(value: 'folder', child: Text('مجلد')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedTargetType = value!;
                              _selectedTargetId = '';
                              comments = [];
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'معرف الملف/المجلد',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onChanged: (value) {
                            setState(() => _selectedTargetId = value);
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: _loadComments,
                        color: Color(0xff28336f),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Comments List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : _selectedTargetId.isEmpty && widget.targetId == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.comment_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'اختر ملف أو مجلد لعرض التعليقات',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : comments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.comment_outlined, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'لا توجد تعليقات',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'كن أول من يعلق',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadComments,
                            child: ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                return _buildCommentCard(comments[index]);
                              },
                            ),
                          ),
          ),

          // Add Comment Section
          if (_selectedTargetId.isNotEmpty || widget.targetId != null)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'اكتب تعليقاً...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        maxLines: null,
                      ),
                    ),
                    SizedBox(width: 8),
                    Consumer<RoomController>(
                      builder: (context, roomController, child) {
                        return IconButton(
                          icon: roomController.isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(Icons.send, color: Color(0xff28336f)),
                          onPressed: roomController.isLoading ? null : _addComment,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(Map<String, dynamic> comment) {
    final user = comment['user'] ?? {};
    final content = comment['content'] ?? '';
    final createdAt = comment['createdAt'];

    // TODO: Check if current user can delete (owner or comment author)
    final canDelete = true; // Replace with actual check

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                        user['name'] ?? user['email'] ?? 'مستخدم',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (canDelete)
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    onPressed: () => _deleteComment(comment['_id']),
                  ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '—';
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return 'منذ ${difference.inDays} يوم';
      } else if (difference.inHours > 0) {
        return 'منذ ${difference.inHours} ساعة';
      } else if (difference.inMinutes > 0) {
        return 'منذ ${difference.inMinutes} دقيقة';
      } else {
        return 'الآن';
      }
    } catch (e) {
      return '—';
    }
  }
}

