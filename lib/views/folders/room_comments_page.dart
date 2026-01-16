import 'package:flutter/material.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filevo/config/api_config.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/utils/room_permissions.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:filevo/constants/app_colors.dart';

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
  String _selectedTargetType = 'room'; // ✅ افتراضي: تعليقات عامة على الروم
  String _selectedTargetId =
      ''; // ✅ إذا كان فارغاً، يعني تعليقات عامة على الروم
  Map<String, dynamic>? roomData; // ✅ بيانات الغرفة للتحقق من الصلاحيات
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    // ✅ إذا كان targetType و targetId محددين (مثل ملف)، استخدمهم
    if (widget.targetType != null && widget.targetId != null) {
      _selectedTargetType = widget.targetType!;
      _selectedTargetId = widget.targetId!;
    } else {
      // ✅ إذا لم يكن محدداً، يعني تعليقات عامة على الروم
      _selectedTargetType = 'room';
      _selectedTargetId =
          widget.roomId; // ✅ استخدام roomId كـ targetId للتعليقات العامة
    }
    // ✅ تأجيل تحميل البيانات حتى بعد اكتمال البناء الأولي
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoomData();
      _loadComments();
    });
  }

  // ✅ جلب بيانات الغرفة للتحقق من الصلاحيات
  Future<void> _loadRoomData() async {
    if (!mounted) return;

    final roomController = Provider.of<RoomController>(context, listen: false);
    final response = await roomController.getRoomById(widget.roomId);

    if (mounted) {
      setState(() {
        roomData = response?['room'];
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    if (!mounted) return;

    if (_selectedTargetType != 'room' &&
        _selectedTargetId.isEmpty &&
        widget.targetId == null) {
      setState(() {
        comments = [];
        isLoading = false;
      });
      return;
    }

    setState(() => isLoading = true);

    final roomController = Provider.of<RoomController>(context, listen: false);
    final targetIdForApi = _selectedTargetType == 'room'
        ? null
        : (_selectedTargetId.isNotEmpty ? _selectedTargetId : widget.targetId);

    final result = await roomController.listComments(
      roomId: widget.roomId,
      targetType: _selectedTargetType,
      targetId: targetIdForApi,
    );

    if (mounted) {
      // ✅ Debug: طباعة بيانات التعليقات للتحقق من وجود profileImg
      if (result.isNotEmpty) {
        print('📝 [RoomCommentsPage] Comments loaded: ${result.length}');
        print(
          '📝 [RoomCommentsPage] First comment user keys: ${result[0]['user']?.keys.toList()}',
        );
        print(
          '📝 [RoomCommentsPage] First comment user profileImg: ${result[0]['user']?['profileImg']}',
        );
      }
      setState(() {
        comments = result;
        isLoading = false;
      });
    }
  }

  Future<void> _addComment() async {
    // ✅ التحقق من الصلاحيات
    if (roomData == null) {
      await _loadRoomData();
    }

    if (roomData != null) {
      final canAdd = await RoomPermissions.canAddComments(roomData!);
      if (!canAdd) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).noPermissionAddComment),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).pleaseEnterComment),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedTargetType != 'room' &&
        _selectedTargetId.isEmpty &&
        widget.targetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).pleaseSelectFileOrFolder),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final roomController = Provider.of<RoomController>(context, listen: false);
    final targetIdForApi = _selectedTargetType == 'room'
        ? null
        : (_selectedTargetId.isNotEmpty ? _selectedTargetId : widget.targetId);

    final result = await roomController.addComment(
      roomId: widget.roomId,
      targetType: _selectedTargetType,
      targetId: targetIdForApi,
      content: _commentController.text.trim(),
    );

    if (mounted) {
      if (result != null) {
        _commentController.clear();
        _loadComments();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).addCommentSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              roomController.errorMessage ?? S.of(context).addCommentFailure,
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).deleteComment),
        content: Text(S.of(context).confirmDeleteComment),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              S.of(context).delete,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final roomController = Provider.of<RoomController>(
        context,
        listen: false,
      );
      final success = await roomController.deleteComment(
        roomId: widget.roomId,
        commentId: commentId,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).deleteCommentSuccess),
              backgroundColor: AppColors.success,
            ),
          );
          _loadComments();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                roomController.errorMessage ??
                    S.of(context).deleteCommentFailure,
              ),
              backgroundColor: AppColors.error,
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
        title: Text(S.of(context).comments),
        backgroundColor: AppColors.getAppBar(
          Theme.of(context).brightness == Brightness.dark,
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.refresh),
        //     onPressed: () {
        //       setState(() => isLoading = true);
        //       _loadComments();
        //     },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          // ✅ Target Selection (فقط إذا لم يكن محدداً وكانت تعليقات على ملف/مجلد)
          if (widget.targetId == null && _selectedTargetType != 'room')
            Container(
              padding: EdgeInsets.all(16),
              color: AppColors.getBackground(
                Theme.of(context).brightness == Brightness.dark,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).selectFileOrFolder,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedTargetType,
                          decoration: InputDecoration(
                            labelText: S.of(context).type,
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'file',
                              child: Text(S.of(context).file),
                            ),
                            DropdownMenuItem(
                              value: 'folder',
                              child: Text(S.of(context).folder),
                            ),
                            DropdownMenuItem(
                              value: 'room',
                              child: Text(S.of(context).room),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedTargetType = value!;
                              if (value == 'room') {
                                _selectedTargetId = widget.roomId;
                              } else {
                                _selectedTargetId = '';
                              }
                              comments = [];
                              _loadComments();
                            });
                          },
                        ),
                      ),
                      if (_selectedTargetType != 'room') ...[
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: S.of(context).fileOrFolderId,
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
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
                          color: AppColors.getPrimary(
                            Theme.of(context).brightness == Brightness.dark,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

          // Comments List
          Expanded(
            child: isLoading
                ? _buildShimmerLoading()
                : (_selectedTargetId.isEmpty &&
                      widget.targetId == null &&
                      _selectedTargetType != 'room')
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 64,
                          color: AppColors.getTextSecondary(
                            Theme.of(context).brightness == Brightness.dark,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          S.of(context).pleaseSelectFileOrFolder,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.getTextSecondary(
                            Theme.of(context).brightness == Brightness.dark,
                          ),
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
                        Icon(
                          Icons.comment_outlined,
                          size: 64,
                          color: AppColors.getTextSecondary(
                            Theme.of(context).brightness == Brightness.dark,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          S.of(context).noCommentsYet,
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.getTextSecondary(
                            Theme.of(context).brightness == Brightness.dark,
                          ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          S.of(context).beTheFirstToComment,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.getTextSecondary(
                            Theme.of(context).brightness == Brightness.dark,
                          ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SmartRefresher(
                    controller: _refreshController,
                    onRefresh: () async {
                      await _loadComments();
                      _refreshController.refreshCompleted();
                    },
                    header: const WaterDropHeader(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        return _buildCommentCard(comments[index]);
                      },
                    ),
                  ),
          ),

          // ✅ Add Comment Section - متاح دائماً للتعليقات العامة أو عند تحديد ملف/مجلد
          // ✅ لكن فقط للذين لديهم صلاحية إضافة تعليقات
          if (_selectedTargetType == 'room' ||
              _selectedTargetId.isNotEmpty ||
              widget.targetId != null)
            FutureBuilder<bool>(
              future: roomData != null
                  ? RoomPermissions.canAddComments(roomData!)
                  : Future.value(false),
              builder: (context, snapshot) {
                final canAdd = snapshot.data ?? false;
                if (!canAdd) return SizedBox.shrink();

                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.getCardColor(
                      Theme.of(context).brightness == Brightness.dark,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.getShadow(
                          Theme.of(context).brightness == Brightness.dark,
                        ),
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
                              hintText: S.of(context).writeComment,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
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
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      Icons.send, 
                                      color: AppColors.getPrimary(
                                        Theme.of(context).brightness == Brightness.dark,
                                      ),
                                    ),
                              onPressed: roomController.isLoading
                                  ? null
                                  : _addComment,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(Map<String, dynamic> comment) {
    // ✅ التأكد من أن user هو Map
    Map<String, dynamic> user;
    if (comment['user'] is Map<String, dynamic>) {
      user = comment['user'] as Map<String, dynamic>;
    } else {
      user = {};
    }

    final content = comment['content'] ?? '';
    final createdAt = comment['createdAt'];

    // ✅ Debug: طباعة بيانات المستخدم
    print('👤 [RoomCommentsPage] Comment user keys: ${user.keys.toList()}');
    print(
      '👤 [RoomCommentsPage] Comment user profileImg: ${user['profileImg']}',
    );

    // ✅ استخراج commentUserId للتحقق من الصلاحيات
    String? commentUserId = user['_id']?.toString() ?? user['id']?.toString();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: AppColors.getCardColor(isDarkMode),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // ✅ عرض صورة البروفايل إذا كانت موجودة
                _buildUserAvatar(user),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] ??
                            user['email'] ??
                            S.of(context).unknownUser,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextPrimary(isDarkMode),
                        ),
                      ),
                      Text(
                        _formatDate(createdAt, context),
                        style: TextStyle(
                          fontSize: 12, 
                          color: AppColors.getTextSecondary(isDarkMode),
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder<bool>(
                  future: roomData != null && commentUserId != null
                      ? RoomPermissions.canDeleteComment(
                          roomData!,
                          commentUserId,
                        )
                      : Future.value(false),
                  builder: (context, snapshot) {
                    final canDelete = snapshot.data ?? false;
                    if (!canDelete) return SizedBox.shrink();

                    return IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: AppColors.error,
                      ),
                      onPressed: () => _deleteComment(comment['_id']),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              content, 
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextPrimary(isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date, BuildContext context) {
    if (date == null) return '—';
    try {
      final dateTime = date is String
          ? DateTime.parse(date).toLocal()
          : (date as DateTime).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      final s = S.of(context);

      // إذا مر أكثر من 7 أيام، نعرض التاريخ الكامل
      if (difference.inDays > 7) {
        return DateFormat(
          s.fullDateFormat,
          Localizations.localeOf(context).languageCode,
        ).format(dateTime);
      }
      // إذا مر من يوم إلى 7 أيام
      else if (difference.inDays > 0) {
        return s.daysAgo(difference.inDays);
      }
      // إذا مر أقل من يوم (ساعات)
      else if (difference.inHours > 0) {
        return s.hoursAgo(difference.inHours);
      }
      // إذا مر أقل من ساعة (دقائق)
      else if (difference.inMinutes > 0) {
        return s.minutesAgo(difference.inMinutes);
      }
      // أقل من دقيقة
      else {
        return s.now;
      }
    } catch (e) {
      return '—';
    }
  }

  // ✅ بناء URL كامل للصورة من اسم الملف (للـ backward compatibility)
  String? _buildProfileImageUrl(String? profileImg) {
    if (profileImg == null ||
        profileImg.toString().isEmpty ||
        profileImg.toString() == 'null') {
      return null;
    }

    final profileImgStr = profileImg.toString();

    // ✅ إذا كان URL كامل، استخدمه مباشرة
    if (profileImgStr.startsWith('http://') ||
        profileImgStr.startsWith('https://')) {
      return profileImgStr;
    }

    // ✅ بناء URL من base URL + path
    String cleanPath = profileImgStr
        .replaceAll(r'\', '/')
        .replaceAll('//', '/');
    while (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    // ✅ إزالة /api/v1 من base URL للحصول على base فقط
    final base = ApiConfig.baseUrl.replaceAll('/api/v1', '');
    final baseClean = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;

    // ✅ بناء URL كامل (الـ backend يخدم الملفات من uploads/)
    final imageUrl = '$baseClean/uploads/$cleanPath';
    print('🖼️ [RoomCommentsPage] Building profile image URL:');
    print('  - Original: $profileImgStr');
    print('  - Clean path: $cleanPath');
    print('  - Final URL: $imageUrl');

    return imageUrl;
  }

  // ✅ بناء widget صورة البروفايل
  Widget _buildUserAvatar(Map<String, dynamic> user) {
    // ✅ قراءة profileImgUrl أولاً (من الباك إند الجديد)
    // ✅ إذا لم يكن موجوداً، استخدم profileImg وابني URL (للـ backward compatibility)
    final profileImgUrl = user['profileImgUrl'];
    final profileImg = user['profileImg'];
    final name = user['name'] ?? user['email'] ?? 'م';
    final firstLetter = name.isNotEmpty
        ? name.substring(0, 1).toUpperCase()
        : 'م';

    // ✅ Debug: طباعة البيانات للتحقق
    print('🖼️ [RoomCommentsPage] User data: ${user.keys.toList()}');
    print('🖼️ [RoomCommentsPage] profileImgUrl: $profileImgUrl');
    print('🖼️ [RoomCommentsPage] profileImg: $profileImg');
    print('🖼️ [RoomCommentsPage] name: $name');

    // ✅ استخدام profileImgUrl إذا كان موجوداً، وإلا بناء URL من profileImg
    final imageUrl =
        profileImgUrl?.toString() ??
        _buildProfileImageUrl(profileImg?.toString());

    if (imageUrl != null && imageUrl.isNotEmpty) {
      print('🖼️ [RoomCommentsPage] Loading profile image from: $imageUrl');

      return CircleAvatar(
        radius: 20,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            width: 40,
            height: 40,
            placeholder: (context, url) => CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.getPrimary(
                Theme.of(context).brightness == Brightness.dark,
              ).withOpacity(0.1),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (context, url, error) {
              print(
                '❌ [RoomCommentsPage] Failed to load profile image: $error',
              );
              return CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.getPrimary(
                Theme.of(context).brightness == Brightness.dark,
              ).withOpacity(0.1),
                child: Text(
                  firstLetter,
                  style: TextStyle(
                    color: AppColors.getPrimary(
                      Theme.of(context).brightness == Brightness.dark,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      print('🖼️ [RoomCommentsPage] No profile image, using default avatar');
      return CircleAvatar(
        radius: 20,
              backgroundColor: AppColors.getPrimary(
                Theme.of(context).brightness == Brightness.dark,
              ).withOpacity(0.1),
        child: Text(
          firstLetter,
          style: TextStyle(
            color: Color(0xff28336f),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  // ✅ بناء shimmer loading لصفحة تعليقات الروم
  Widget _buildShimmerLoading() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: List.generate(
        6,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: AppColors.getShimmerBase(
              Theme.of(context).brightness == Brightness.dark,
            ),
            highlightColor: AppColors.getShimmerHighlight(
              Theme.of(context).brightness == Brightness.dark,
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              width: 80,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: 200,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
