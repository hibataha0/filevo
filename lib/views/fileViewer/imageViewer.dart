import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filevo/views/folders/room_comments_page.dart';

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
    // ✅ هذه الدالة تُستدعى فقط عندما يكون roomId متوفراً (بسبب الشرط في actions)
    if (widget.fileId == null || widget.roomId == null) {
      return;
    }

    // ✅ فتح صفحة التعليقات مباشرة للملفات المشتركة في الغرف
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
          // ✅ زر التعليقات (يظهر فقط للملفات المشتركة في الغرف - أي عندما يكون roomId متوفراً)
          if (widget.fileId != null && widget.roomId != null)
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