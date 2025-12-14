import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filevo/views/folders/room_comments_page.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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
  String? _localImagePath;
  bool _isLoadingLocal = false;

  @override
  void initState() {
    super.initState();
    _photoViewController = PhotoViewController();
    _checkImageUrl();
    _loadImageWithToken();
  }

  Future<void> _loadImageWithToken() async {
    // ✅ إذا كان URL يحتاج token، حمله محلياً
    if (widget.imageUrl.startsWith('http') &&
        widget.imageUrl.contains('/api/v1/')) {
      setState(() {
        _isLoadingLocal = true;
      });

      try {
        final token = await StorageService.getToken();
        if (token == null) {
          setState(() {
            _hasError = true;
            _errorMessage = 'يجب تسجيل الدخول أولاً';
            _isLoadingLocal = false;
          });
          return;
        }

        final response = await http.get(
          Uri.parse(widget.imageUrl),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final fileName = widget.imageUrl.split('/').last.split('?').first;
          final tempFile = File('${tempDir.path}/$fileName');
          await tempFile.writeAsBytes(response.bodyBytes);

          setState(() {
            _localImagePath = tempFile.path;
            _isLoadingLocal = false;
          });
        } else {
          setState(() {
            _hasError = true;
            _errorMessage = 'فشل تحميل الصورة (${response.statusCode})';
            _isLoadingLocal = false;
          });
        }
      } catch (e) {
        setState(() {
          _hasError = true;
          _errorMessage = 'خطأ في تحميل الصورة: ${e.toString()}';
          _isLoadingLocal = false;
        });
      }
    }
  }

  void _checkImageUrl() {
    print('Image URL: ${widget.imageUrl}');

    // ✅ التحقق من أن imageUrl هو URL أو مسار ملف محلي صالح
    final isLocalFile =
        widget.imageUrl.startsWith('/') ||
        widget.imageUrl.startsWith('file://');
    final isUrl = widget.imageUrl.startsWith('http');

    if (!isUrl && !isLocalFile) {
      setState(() {
        _hasError = true;
        _errorMessage = 'رابط الصورة غير صالح';
      });
    } else if (isLocalFile) {
      // ✅ التحقق من وجود الملف المحلي
      final filePath = widget.imageUrl.startsWith('file://')
          ? widget.imageUrl.replaceFirst('file://', '')
          : widget.imageUrl;
      final file = File(filePath);
      file.exists().then((exists) {
        if (!exists && mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'الملف غير موجود: $filePath';
          });
        }
      });
    }
  }

  void _retryLoading() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _localImagePath = null;
    });
    _loadImageWithToken();
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
      body: _isLoadingLocal
          ? Center(child: CircularProgressIndicator())
          : _hasError
          ? _buildErrorWidget()
          : _buildPhotoView(),
    );
  }

  Widget _buildPhotoView() {
    // ✅ التحقق من أن imageUrl هو URL أم مسار ملف محلي
    final isLocalFile =
        widget.imageUrl.startsWith('/') ||
        widget.imageUrl.startsWith('file://');

    ImageProvider imageProvider;

    if (isLocalFile) {
      // ✅ استخدام FileImage للملفات المحلية
      final filePath = widget.imageUrl.startsWith('file://')
          ? widget.imageUrl.replaceFirst('file://', '')
          : widget.imageUrl;
      imageProvider = FileImage(File(filePath));
    } else {
      // ✅ إذا كان لدينا ملف محلي (تم تحميله مع token)، استخدمه
      if (_localImagePath != null) {
        imageProvider = FileImage(File(_localImagePath!));
      } else if (widget.imageUrl.startsWith('http') &&
          widget.imageUrl.contains('/api/v1/')) {
        // ✅ إذا كان URL يحتاج token لكن لم يتم تحميله بعد، استخدم placeholder
        imageProvider = const AssetImage('assets/placeholder.png');
      } else {
        // ✅ استخدام CachedNetworkImage للـ URLs العامة
        imageProvider = CachedNetworkImageProvider(
          widget.imageUrl,
          maxWidth: null,
          maxHeight: null,
          cacheKey: widget.imageUrl,
        );
      }
    }

    return Center(
      child: PhotoView(
        imageProvider: imageProvider,
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
                  child: const Text(
                    'عودة',
                    style: TextStyle(color: Colors.white54),
                  ),
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
