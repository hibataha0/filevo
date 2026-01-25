import 'dart:io';
import 'dart:typed_data';
import 'package:filevo/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filevo/views/folders/room_comments_page.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/services/screen_protection_service.dart'; // ✅ إضافة missing import
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ImageViewer extends StatefulWidget {
  final String imageUrl;
  final String? roomId; // معرف الغرفة للتعليقات
  final String? fileId; // معرف الملف للتعليقات
  final bool isOneTimeShare; // ✅ إضافة missing field

  const ImageViewer({
    Key? key,
    required this.imageUrl,
    this.roomId,
    this.fileId,
    this.isOneTimeShare = false, // ✅ للملفات المشتركة لمرة واحدة
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
    // ✅ تفعيل الحماية من السكرين شوت والريكورد للملفات المشتركة لمرة واحدة
    if (widget.isOneTimeShare) {
      ScreenProtectionService.enableProtection();
    }
    _photoViewController = PhotoViewController();
    _checkImageUrl();
    _loadImageWithToken();
  }

  @override
  void dispose() {
    // ✅ إلغاء تفعيل الحماية عند إغلاق المشاهد
    if (widget.isOneTimeShare) {
      ScreenProtectionService.disableProtection();
    }
    _photoViewController.dispose();
    super.dispose();
  }

  Future<void> _loadImageWithToken() async {
    // ✅ إذا كان URL يحتاج token، حمله محلياً
    if (widget.imageUrl.startsWith('http') &&
        widget.imageUrl.contains('/api/v1/')) {
      if (!mounted) return;
      setState(() {
        _isLoadingLocal = true;
      });

      try {
        final token = await StorageService.getToken();
        if (token == null) {
          if (!mounted) return;
          setState(() {
            _hasError = true;
            _errorMessage = S.of(context).mustLogin;
            _isLoadingLocal = false;
          });
          return;
        }

        // ✅ إضافة cache-busting للصور دائماً (ليس فقط للغرف)
        // ✅ استخدام timestamp حالي لضمان تحميل الصورة المحدثة
        String imageUrl = widget.imageUrl;
        // ✅ إزالة أي timestamp موجود مسبقاً
        final urlWithoutParams = imageUrl.split('?').first;
        // ✅ إضافة timestamp جديد دائماً لضمان cache busting
        imageUrl =
            '$urlWithoutParams?v=${DateTime.now().millisecondsSinceEpoch}';

        print('🖼️ [ImageViewer] Loading image with cache busting: $imageUrl');

        final response = await http.get(
          Uri.parse(imageUrl),
          headers: {
            'Authorization': 'Bearer $token',
            // ✅ إضافة headers لمنع الـ cache دائماً
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
            'Expires': '0',
          },
        );

        if (!mounted) return;

        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          // ✅ استخدام fileId أو timestamp في اسم الملف المؤقت لضمان عدم استخدام cache قديم
          final fileId = widget.fileId ?? 'image';
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = widget.imageUrl.split('/').last.split('?').first;
          final tempFile = File(
            '${tempDir.path}/${fileId}_${timestamp}_$fileName',
          );

          // ✅ حذف الملف القديم إذا كان موجوداً
          try {
            final oldFiles = tempDir
                .listSync()
                .where(
                  (f) =>
                      f.path.contains('${fileId}_') &&
                      f.path.endsWith('_$fileName'),
                )
                .toList();
            for (var oldFile in oldFiles) {
              if (oldFile is File) {
                await oldFile.delete();
              }
            }
          } catch (e) {
            print('⚠️ [ImageViewer] Could not delete old temp files: $e');
          }

          await tempFile.writeAsBytes(response.bodyBytes);

          if (!mounted) return;
          setState(() {
            _localImagePath = tempFile.path;
            _isLoadingLocal = false;
          });
          print('✅ [ImageViewer] Image loaded and saved to: ${tempFile.path}');
        } else {
          if (!mounted) return;
          setState(() {
            _hasError = true;
            _errorMessage =
                '${S.of(context).failedToLoadImage} (${response.statusCode})';
            _isLoadingLocal = false;
          });
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _hasError = true;
          _errorMessage = '${S.of(context).errorLoadingImage}: ${e.toString()}';
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
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = S.of(context).invalidImageUrl;
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
            _errorMessage = S.of(context).fileNotFoundd(filePath);
          });
        }
      });
    }
  }

  void _retryLoading() {
    if (!mounted) return;
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _localImagePath = null; // ✅ مسح الملف المحلي القديم
    });
    // ✅ مسح cache الصور قبل إعادة التحميل
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
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
        title: Text(S.of(context).viewImage),
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
              tooltip: S.of(context).comments,
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
        // ✅ إنشاء صورة placeholder شفافة (1x1 pixel) بدلاً من AssetImage
        final placeholderBytes = Uint8List.fromList([
          0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
          0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
          0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1 dimensions
          0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89,
          0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, // IDAT chunk
          0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01,
          0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45,
          0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82, // IEND chunk
        ]);
        imageProvider = MemoryImage(placeholderBytes);
      } else {
        // ✅ استخدام CachedNetworkImage للـ URLs العامة
        // ✅ إضافة cache busting للـ URL
        String imageUrl = widget.imageUrl;
        if (!imageUrl.contains('?')) {
          // ✅ إضافة timestamp للـ cache busting إذا لم يكن موجوداً
          imageUrl = '$imageUrl?v=${DateTime.now().millisecondsSinceEpoch}';
        }
        imageProvider = CachedNetworkImageProvider(
          imageUrl,
          maxWidth: null,
          maxHeight: null,
          cacheKey: imageUrl, // ✅ استخدام URL الكامل مع timestamp كـ cacheKey
        );
      }
    }

    // ✅ استخدام ValueKey مع URL لضمان إعادة بناء الـ widget عند تغيير الصورة
    final imageKey = ValueKey(widget.imageUrl);

    return Center(
      child: PhotoView(
        key: imageKey, // ✅ إضافة key لضمان إعادة بناء الـ widget عند تغيير URL
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
                _errorMessage = '${S.of(context).failedToLoadImage}: $error';
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
              _hasError ? _errorMessage : S.of(context).failedToLoadImage,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${S.of(context).urlLabel} ${widget.imageUrl}',
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
                  child: Text(S.of(context).retry),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    S.of(context).back,
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
}
