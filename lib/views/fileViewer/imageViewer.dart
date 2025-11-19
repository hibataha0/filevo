import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filevo/views/folders/room_comments_page.dart';
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/room_controller.dart';

class ImageViewer extends StatefulWidget {
  final String imageUrl;
  final String? roomId; // معرف الغرفة للتعليقات
  final String? fileId; // معرف الملف للتعليقات

  const ImageViewer({
    Key? key,
    required this.imageUrl,
    this.roomId,
    this.fileId,
  }) : super(key: key);

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late PhotoViewController _photoViewController;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _photoViewController = PhotoViewController();
    _checkImageUrl();
  }

  void _checkImageUrl() {
    print('Image URL: ${widget.imageUrl}');
    
    if (!widget.imageUrl.startsWith('http')) {
      setState(() {
        _hasError = true;
        _errorMessage = 'رابط الصورة غير صالح';
      });
    }
  }

  void _retryLoading() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });
  }

  Future<void> _openComments(BuildContext context) async {
    if (widget.fileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('معرف الملف غير متوفر'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // إذا كان roomId متوفراً، افتح صفحة التعليقات مباشرة
    if (widget.roomId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoomCommentsPage(
            roomId: widget.roomId!,
            targetType: 'file',
            targetId: widget.fileId!,
          ),
        ),
      );
      return;
    }

    // إذا لم يكن roomId متوفراً، اجلب الغرف واختر الغرفة أولاً
    final roomController = Provider.of<RoomController>(context, listen: false);
    final success = await roomController.getRooms();
    
    if (!success || roomController.rooms.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('لا توجد غرف متاحة. قم بإنشاء غرفة أولاً.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    // عرض dialog لاختيار الغرفة
    final selectedRoom = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اختر الغرفة'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: roomController.rooms.length,
            itemBuilder: (context, index) {
              final room = roomController.rooms[index];
              return ListTile(
                leading: Icon(Icons.meeting_room, color: Color(0xff28336f)),
                title: Text(room['name'] ?? 'بدون اسم'),
                subtitle: room['description'] != null 
                    ? Text(room['description'], maxLines: 1, overflow: TextOverflow.ellipsis)
                    : null,
                onTap: () => Navigator.pop(context, room),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
        ],
      ),
    );

    if (selectedRoom != null && mounted) {
      final roomId = selectedRoom['_id']?.toString();
      if (roomId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomCommentsPage(
              roomId: roomId,
              targetType: 'file',
              targetId: widget.fileId!,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('عرض الصورة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // زر التعليقات (يظهر دائماً إذا كان fileId متوفراً)
          if (widget.fileId != null)
            IconButton(
              icon: const Icon(Icons.comment, color: Colors.white),
              onPressed: () => _openComments(context),
              tooltip: 'التعليقات',
            ),
          if (_hasError)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _retryLoading,
            ),
        ],
      ),
      body: _hasError
          ? _buildErrorWidget()
          : _buildPhotoView(),
    );
  }

  Widget _buildPhotoView() {
    return Center(
      child: PhotoView(
        // ✅ استخدام CachedNetworkImage للعرض المباشر مع cache قوي
        imageProvider: CachedNetworkImageProvider(
          widget.imageUrl,
          maxWidth: null, // عرض الصورة بالحجم الكامل للتفاصيل
          maxHeight: null,
          // ✅ إعدادات cache قوية لمنع إعادة التحميل
          cacheKey: widget.imageUrl, // ✅ مفتاح cache فريد
        ),
        controller: _photoViewController,
        loadingBuilder: (context, progress) {
          return Center(
            child: Container(
              width: 60,
              height: 60,
              child: Stack(
                children: [
                  Center(
                    child: CircularProgressIndicator(
                      value: progress == null
                          ? null
                          : progress.cumulativeBytesLoaded /
                              (progress.expectedTotalBytes ?? 1),
                      color: Colors.white,
                    ),
                  ),
                  if (progress != null && progress.expectedTotalBytes != null)
                    Center(
                      child: Text(
                        '${(progress.cumulativeBytesLoaded / (1024 * 1024)).toStringAsFixed(1)}MB',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('PhotoView Error: $error');
          print('Stack Trace: $stackTrace');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = 'فشل في تحميل الصورة: $error';
              });
            }
          });
          return _buildErrorWidget();
        },
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _hasError ? _errorMessage : 'فشل في تحميل الصورة',
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'الرابط: ${widget.imageUrl}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _retryLoading,
                  child: const Text('إعادة المحاولة'),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('عودة', style: TextStyle(color: Colors.white54)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _photoViewController.dispose();
    super.dispose();
  }
}