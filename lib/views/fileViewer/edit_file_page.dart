import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart'; // ✅ لـ imageCache
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/config/api_config.dart';
import 'package:filevo/services/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:filevo/views/fileViewer/textViewer.dart';
import 'package:filevo/views/fileViewer/image_editor_page.dart';
import 'package:filevo/views/fileViewer/video_editor_page.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
// Temporarily disabled - package is discontinued
// import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter_min/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart' as audioplayers;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image_picker/image_picker.dart';

/// صفحة تعديل الملفات الشاملة
/// تدعم تعديل metadata ومحتوى الملف حسب نوعه
class EditFilePage extends StatefulWidget {
  final Map<String, dynamic> file;

  const EditFilePage({super.key, required this.file});

  @override
  State<EditFilePage> createState() => _EditFilePageState();
}

class _EditFilePageState extends State<EditFilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  bool _isLoading = false;
  File? _editedFile; // الملف المعدل
  String? _fileExtension;
  String? _fileType; // image, video, audio, pdf, text, other

  @override
  void initState() {
    super.initState();
    _initializeFile();
  }

  void _initializeFile() {
    final originalData = widget.file['originalData'] ?? widget.file;
    final fileName = originalData['name'] ?? '';

    // استخراج الامتداد
    if (fileName.contains('.')) {
      _fileExtension = fileName
          .substring(fileName.lastIndexOf('.') + 1)
          .toLowerCase();
      _nameController.text = fileName.substring(0, fileName.lastIndexOf('.'));
    } else {
      _nameController.text = fileName;
    }

    _descriptionController.text = originalData['description'] ?? '';
    _tagsController.text = (originalData['tags'] as List?)?.join(', ') ?? '';

    // تحديد نوع الملف
    _fileType = _getFileType(_fileExtension, originalData['contentType'] ?? '');

    // ✅ Debug: طباعة معلومات الملف
    print('📹 [EditFilePage] File type: $_fileType');
    print('📹 [EditFilePage] Extension: $_fileExtension');
    print('📹 [EditFilePage] Category: ${originalData['category']}');
    print('📹 [EditFilePage] ContentType: ${originalData['contentType']}');
  }

  String _getFileType(String? extension, String contentType) {
    final originalData = widget.file['originalData'] ?? widget.file;
    final category = (originalData['category'] ?? '').toString().toLowerCase();

    // ✅ التحقق من category أولاً
    if (category == 'videos' || category == 'video') {
      return 'video';
    } else if (category == 'images' || category == 'image') {
      return 'image';
    } else if (category == 'audio' || category == 'audios') {
      return 'audio';
    } else if (category == 'documents' &&
        (extension == 'pdf' || contentType.contains('pdf'))) {
      return 'pdf';
    }

    // ✅ إذا لم يكن category محدداً، نستخدم extension و contentType
    if (extension == null) return 'other';

    final imageExts = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    final videoExts = ['mp4', 'mov', 'mkv', 'avi', 'wmv', 'webm', 'flv', '3gp'];
    final audioExts = ['mp3', 'wav', 'aac', 'ogg', 'm4a', 'wma', 'flac'];

    if (imageExts.contains(extension) || contentType.startsWith('image/')) {
      return 'image';
    } else if (videoExts.contains(extension) ||
        contentType.startsWith('video/')) {
      return 'video';
    } else if (audioExts.contains(extension) ||
        contentType.startsWith('audio/')) {
      return 'audio';
    } else if (extension == 'pdf' || contentType.contains('pdf')) {
      return 'pdf';
    } else if (extension == 'txt' || contentType.startsWith('text/')) {
      return 'text';
    }
    return 'other';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).editFile),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ معلومات الملف الأساسية
            _buildMetadataSection(),
            const SizedBox(height: 24),

            // ✅ خيارات تعديل المحتوى حسب نوع الملف
            if (_fileType == 'image')
              _buildImageEditSection()
            else if (_fileType == 'video')
              _buildVideoEditSection()
            else if (_fileType == 'audio')
              _buildAudioEditSection()
            else if (_fileType == 'pdf')
              _buildPdfEditSection()
            else if (_fileType == 'text')
              _buildTextEditSection(),
            // else
            //   _buildUnsupportedSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).fileInfoTitle, // "معلومات الملف"
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: S.of(context).fileNameLabel, // "اسم الملف"
                suffixText: _fileExtension != null ? '.$_fileExtension' : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: S.of(context).descriptionLabel, // "الوصف"
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: S
                    .of(context)
                    .tagsLabel, // "الوسوم (افصل بينها بفاصلة)"
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageEditSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).editImage,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: Text(S.of(context).openImageEditor),
              onPressed: _editImage,
            ),
            if (_editedFile != null) ...[
              const SizedBox(height: 16),
              Text(
                '✅ ${S.of(context).imageEdited}',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // ✅ معاينة الصورة المعدلة
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _editedFile!,
                    key: ValueKey(_editedFile!.path), // ✅ إجبار إعادة التحميل
                    fit: BoxFit.cover,
                    cacheWidth: null, // ✅ تعطيل cache
                    cacheHeight: null,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.refresh),
                label: Text(S.of(context).reloadOriginalImage),
                onPressed: () {
                  setState(() {
                    _editedFile = null;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoEditSection() {
    // تم إزالة جميع خيارات تعديل الفيديو
    return const SizedBox.shrink();
  }

  Widget _buildAudioEditSection() {
    // تم إزالة جميع خيارات تعديل الصوت
    return const SizedBox.shrink();
  }

  Widget _buildPdfEditSection() {
    // تم إزالة جميع خيارات تعديل PDF
    return const SizedBox.shrink();
  }

  Widget _buildTextEditSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).editText,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit_note),
              label: Text(S.of(context).openTextEditor),
              onPressed: _editText,
            ),
            if (_editedFile != null) ...[
              const SizedBox(height: 12),
              Text('✅ ${S.of(context).textEdited}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUnsupportedSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).editContentTitle, // "تعديل المحتوى"
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              S
                  .of(context)
                  .editContentDescription, // "تعديل محتوى هذا النوع من الملفات غير مدعوم حالياً.\nيمكنك تعديل الاسم والوصف والوسوم فقط."
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ تعديل الصورة
  Future<void> _editImage() async {
    try {
      final originalData = widget.file['originalData'] ?? widget.file;
      final fileId = originalData['_id'] ?? originalData['id'];

      if (fileId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).fileIdNotAvailable)),
        );
        return;
      }

      // تحميل الصورة
      final token = await StorageService.getToken();
      if (token == null) return;

      final url = "${ApiConfig.baseUrl}${ApiEndpoints.viewFile(fileId)}";
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).failedToLoadImage)),
        );
        return;
      }

      // حفظ الصورة مؤقتاً
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/temp_image_$timestamp.jpg');

      // ✅ التأكد من كتابة الملف بشكل صحيح
      await tempFile.writeAsBytes(response.bodyBytes);

      // ✅ التحقق من وجود الملف قبل استخدامه
      if (!await tempFile.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).failedToSaveTempImage)),
        );
        return;
      }

      // ✅ التحقق من حجم الملف
      final fileSize = await tempFile.length();
      if (fileSize == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).loadedImageIsEmpty)),
        );
        return;
      }

      // ✅ فتح محرر الصور
      final editedImageFile = await Navigator.push<File?>(
        context,
        MaterialPageRoute(
          builder: (context) => ImageEditorPage(imageFile: tempFile),
        ),
      );

      if (editedImageFile != null) {
        try {
          // ✅ التحقق من وجود الملف وحجمه
          if (await editedImageFile.exists()) {
            final fileSize = await editedImageFile.length();
            if (fileSize > 0) {
              // ✅ التأكد من تحديث الواجهة
              if (mounted) {
                setState(() {
                  _editedFile = editedImageFile;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).imageEditedSuccessfully),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).editedImageIsEmpty),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context).failedToSaveEditedImage),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        } catch (e) {
          print('❌ Error checking edited image file: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(S.of(context).errorVerifyingImage(e.toString())),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).error(e.toString()))),
      );
    }
  }

  // ✅ قص الفيديو
  Future<void> _trimVideo() async {
    try {
      print('📹 [EditFilePage] Starting video trim...');

      final originalData = widget.file['originalData'] ?? widget.file;
      final fileId = originalData['_id'] ?? originalData['id'];

      print('📹 [EditFilePage] File ID: $fileId');

      if (fileId == null) {
        print('❌ [EditFilePage] File ID is null');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).fileIdNotAvailable)),
        );
        return;
      }

      // تحميل الفيديو
      final token = await StorageService.getToken();
      if (token == null) {
        print('❌ [EditFilePage] Token is null');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(S.of(context).mustLoginFirst)));
        return;
      }

      final url = "${ApiConfig.baseUrl}${ApiEndpoints.viewFile(fileId)}";
      print('📹 [EditFilePage] Downloading video from: $url');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).loadingVideo),
          duration: Duration(seconds: 2),
        ),
      );

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📹 [EditFilePage] Response status: ${response.statusCode}');
      print(
        '📹 [EditFilePage] Response size: ${response.bodyBytes.length} bytes',
      );

      if (response.statusCode != 200) {
        print(
          '❌ [EditFilePage] Failed to download video: ${response.statusCode}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).failedToLoadVideo(response.statusCode)),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // حفظ الفيديو مؤقتاً
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = originalData['name'] ?? 'video.mp4';
      final fileExtension = fileName.contains('.')
          ? fileName.substring(fileName.lastIndexOf('.'))
          : '.mp4';
      final tempFile = File(
        '${tempDir.path}/temp_video_$timestamp$fileExtension',
      );

      print('📹 [EditFilePage] Saving video to: ${tempFile.path}');

      // ✅ التأكد من كتابة الملف بشكل صحيح
      await tempFile.writeAsBytes(response.bodyBytes);

      // ✅ التحقق من وجود الملف قبل استخدامه
      if (!await tempFile.exists()) {
        print('❌ [EditFilePage] Temp file does not exist');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).failedToSaveTempVideo)),
        );
        return;
      }

      // ✅ التحقق من حجم الملف
      final fileSize = await tempFile.length();
      print('📹 [EditFilePage] Temp file size: $fileSize bytes');

      if (fileSize == 0) {
        print('❌ [EditFilePage] Temp file is empty');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).loadedVideoIsEmpty)),
        );
        return;
      }

      print('📹 [EditFilePage] Opening video editor...');

      // ✅ فتح محرر الفيديو
      final editedVideoFile = await Navigator.push<File?>(
        context,
        MaterialPageRoute(
          builder: (context) => VideoEditorPage(videoFile: tempFile),
        ),
      );

      if (editedVideoFile != null) {
        try {
          // ✅ التحقق من وجود الملف وحجمه
          if (await editedVideoFile.exists()) {
            final fileSize = await editedVideoFile.length();
            if (fileSize > 0) {
              print(
                '✅ [EditFilePage] Video edited successfully, size: $fileSize bytes',
              );
              // ✅ التأكد من تحديث الواجهة
              if (mounted) {
                setState(() {
                  _editedFile = editedVideoFile;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).videoEditedSuccessfully),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } else {
              print('⚠️ [EditFilePage] Edited video file is empty');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).editedVideoIsEmpty),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
          } else {
            print('⚠️ [EditFilePage] Edited file does not exist');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context).failedToSaveEditedVideo),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        } catch (e) {
          print('❌ [EditFilePage] Error checking edited video file: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(S.of(context).errorVerifyingVideo(e.toString())),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        print('ℹ️ [EditFilePage] User cancelled video editing');
      }
    } catch (e, stackTrace) {
      print('❌ [EditFilePage] Error trimming video: $e');
      print('❌ [EditFilePage] Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).errorOccurred(e.toString())),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // ✅ استخراج صورة من الفيديو
  Future<void> _extractFrameFromVideo() async {
    try {
      print('🖼️ [EditFilePage] Starting frame extraction...');

      final originalData = widget.file['originalData'] ?? widget.file;
      final fileId = originalData['_id'] ?? originalData['id'];

      if (fileId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).fileIdNotAvailable)),
        );
        return;
      }

      // عرض dialog لاختيار الوقت
      final timeSeconds = await showDialog<int>(
        context: context,
        builder: (context) => _FrameExtractionDialog(),
      );

      if (timeSeconds == null) return;

      final token = await StorageService.getToken();
      if (token == null) return;

      final url = "${ApiConfig.baseUrl}${ApiEndpoints.viewFile(fileId)}";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).extractingImage),
          duration: Duration(seconds: 2),
        ),
      );

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).failedToLoadVideo(response.statusCode)),
          ),
        );
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempVideoFile = File(
        '${tempDir.path}/temp_video_extract_$timestamp.mp4',
      );
      await tempVideoFile.writeAsBytes(response.bodyBytes);

      // ✅ استخراج الصورة باستخدام video_thumbnail
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: tempVideoFile.path,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.PNG,
        timeMs: timeSeconds * 1000,
        quality: 100,
      );

      if (thumbnailPath != null) {
        final imageFile = File(thumbnailPath);
        if (await imageFile.exists()) {
          // ✅ عرض الصورة المستخرجة
          final saveOption = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(S.of(context).imageExtracted),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.file(imageFile, height: 200),
                  const SizedBox(height: 16),
                  Text(S.of(context).saveThisImage),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'cancel'),
                  child: Text(S.of(context).cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, 'save'),
                  child: Text(S.of(context).save),
                ),
              ],
            ),
          );

          if (saveOption == 'save') {
            // ✅ حفظ الصورة كملف معدل
            setState(() {
              _editedFile = imageFile;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(S.of(context).imageExtractedSuccessfully),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).failedToExtractImage)),
        );
      }

      // ✅ حذف الملف المؤقت
      if (await tempVideoFile.exists()) {
        await tempVideoFile.delete();
      }
    } catch (e) {
      print('❌ [EditFilePage] Error extracting frame: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).error(e.toString()))),
      );
    }
  }

  // ✅ دمج مقاطع فيديو (معطل مؤقتاً بسبب مشاكل في ffmpeg_kit_flutter)
  Future<void> _mergeVideos() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'ميزة دمج الفيديوهات معطلة مؤقتاً بسبب مشاكل في التبعيات',
        ),
        backgroundColor: Colors.orange,
      ),
    );
    return;
    /* تم تعطيل الكود مؤقتاً
    try {
      print('🔀 [EditFilePage] Starting video merge...');
      
      final originalData = widget.file['originalData'] ?? widget.file;
      final fileId = originalData['_id'] ?? originalData['id'];
      
      if (fileId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('معرف الملف غير متوفر')),
        );
        return;
      }

      // ✅ اختيار ملفات فيديو إضافية للدمج
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return; // المستخدم ألغى العملية
      }

      final token = await StorageService.getToken();
      if (token == null) return;

      // ✅ تحميل الفيديو الأساسي
      final url = "${ApiConfig.baseUrl}${ApiEndpoints.viewFile(fileId)}";
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).failedToLoadVideo(response.statusCode))),
        );
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // ✅ حفظ الفيديو الأساسي
      final mainVideoFile = File('${tempDir.path}/main_video_$timestamp.mp4');
      await mainVideoFile.writeAsBytes(response.bodyBytes);

      // ✅ حفظ الفيديوهات الإضافية
      final List<File> videoFiles = [mainVideoFile];
      for (var file in result.files) {
        if (file.path != null) {
          videoFiles.add(File(file.path!));
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(S.of(context).mergingVideos),
          duration: Duration(seconds: 3),
        ),
      );

      // ✅ دمج الفيديوهات باستخدام ffmpeg
      final outputFile = File('${tempDir.path}/merged_video_$timestamp.mp4');
      final success = await _mergeVideoFiles(videoFiles, outputFile);

      if (success && await outputFile.exists()) {
        setState(() {
          _editedFile = outputFile;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(S.of(context).videoMergedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(S.of(context).failedToMergeVideos),
            backgroundColor: Colors.red,
          ),
        );
      }

      // ✅ تنظيف الملفات المؤقتة
      if (await mainVideoFile.exists()) {
        await mainVideoFile.delete();
      }
    } catch (e) {
      print('❌ [EditFilePage] Error merging videos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: ${e.toString()}')),
      );
    }
    */
  }

  // ✅ دمج ملفات فيديو باستخدام ffmpeg (معطل مؤقتاً)
  // تم حذف الدالة مؤقتاً بسبب مشاكل في ffmpeg_kit_flutter

  // ✅ قص الصوت
  // ✅ قص الصوت
  Future<void> _trimAudio() async {
    try {
      print('🎵 [EditFilePage] Starting audio trim...');

      final originalData = widget.file['originalData'] ?? widget.file;
      final fileId = originalData['_id'] ?? originalData['id'];

      if (fileId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).fileIdNotAvailable)),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final token = await StorageService.getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(S.of(context).mustLoginFirst)));
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final url = "${ApiConfig.baseUrl}${ApiEndpoints.viewFile(fileId)}";
      print('🎵 [EditFilePage] Downloading audio from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        print(
          '❌ [EditFilePage] Failed to download audio: ${response.statusCode}',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context).failedToLoadAudio(response.statusCode),
              ),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = originalData['name'] ?? 'audio.mp3';
      final fileExtension = fileName.contains('.')
          ? fileName.substring(fileName.lastIndexOf('.'))
          : '.mp3';
      final tempFile = File(
        '${tempDir.path}/temp_audio_$timestamp$fileExtension',
      );

      print('🎵 [EditFilePage] Saving audio to: ${tempFile.path}');
      await tempFile.writeAsBytes(response.bodyBytes);

      if (!await tempFile.exists()) {
        print('❌ [EditFilePage] Temp file does not exist');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).failedToSaveTempAudio)),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final fileSize = await tempFile.length();
      print('🎵 [EditFilePage] Temp file size: $fileSize bytes');

      if (fileSize == 0) {
        print('❌ [EditFilePage] Temp file is empty');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).loadedAudioIsEmpty)),
          );
        }
        setState(() {
          _isLoading = false;
        });
        await tempFile.delete();
        return;
      }

      // ✅ فتح واجهة اختيار start/end time
      final result = await showDialog<Map<String, Duration>>(
        context: context,
        builder: (context) => _AudioTrimDialog(audioFile: tempFile),
      );

      if (result == null) {
        print('ℹ️ [EditFilePage] Audio trim cancelled by user.');
        await tempFile.delete();
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final startTime = result['start']!;
      final endTime = result['end']!;

      if (startTime >= endTime) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).startTimeMustBeBeforeEndTime)),
          );
        }
        await tempFile.delete();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print(
        '🎵 [EditFilePage] Trimming audio from ${startTime.inSeconds}s to ${endTime.inSeconds}s...',
      );

      // ✅ قص الصوت باستخدام FFmpeg
      // Temporarily disabled - FFmpeg Kit package is discontinued
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⚠️ هذه الميزة معطلة مؤقتاً - حزمة FFmpeg Kit غير متاحة',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    } catch (e, stackTrace) {
      print('❌ [EditFilePage] Error trimming audio: $e');
      print('❌ [EditFilePage] Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorOccurred(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ✅ تعديل مستوى الصوت
  Future<void> _adjustAudioVolume() async {
    File? tempFile;
    try {
      print('🔊 [EditFilePage] Starting audio volume adjustment...');

      final originalData = widget.file['originalData'] ?? widget.file;
      final fileId = originalData['_id'] ?? originalData['id'];

      if (fileId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).fileIdNotAvailable)),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final token = await StorageService.getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(S.of(context).mustLoginFirst)));
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final url = "${ApiConfig.baseUrl}${ApiEndpoints.viewFile(fileId)}";
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context).failedToLoadAudio(response.statusCode),
              ),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = originalData['name'] ?? 'audio.mp3';
      final fileExtension = fileName.contains('.')
          ? fileName.substring(fileName.lastIndexOf('.'))
          : '.mp3';

      tempFile = File(
        '${tempDir.path}/temp_audio_vol_$timestamp$fileExtension',
      );
      await tempFile.writeAsBytes(response.bodyBytes);

      if (!await tempFile.exists() || await tempFile.length() == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).failedToLoadAudioFile)),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // ✅ فتح واجهة اختيار مستوى الصوت
      final volumeMultiplier = await showDialog<double>(
        context: context,
        builder: (context) => _AudioVolumeDialog(),
      );

      if (volumeMultiplier == null) {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('🔊 [EditFilePage] Adjusting volume by ${volumeMultiplier}x...');

      // ✅ تعديل مستوى الصوت باستخدام FFmpeg
      final outputFile = File(
        '${tempDir.path}/adjusted_audio_$timestamp$fileExtension',
      );
      // volume filter: 1.0 = 100%, 2.0 = 200%, 0.5 = 50%
      final command =
          '-i "${tempFile.path}" -af "volume=${volumeMultiplier}" "${outputFile.path}"';

      print('🔊 [FFmpeg] Command: $command');

      // Temporarily disabled - FFmpeg Kit package is discontinued
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⚠️ هذه الميزة معطلة مؤقتاً - حزمة FFmpeg Kit غير متاحة',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    } catch (e, stackTrace) {
      print('❌ [EditFilePage] Error adjusting audio volume: $e');
      print('❌ [EditFilePage] Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorOccurred(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (tempFile != null && await tempFile.exists()) {
        await tempFile.delete();
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ✅ دمج مقاطع صوتية
  Future<void> _mergeAudios() async {
    try {
      print('🔀 [EditFilePage] Starting audio merge...');

      final originalData = widget.file['originalData'] ?? widget.file;
      final fileId = originalData['_id'] ?? originalData['id'];

      if (fileId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).fileIdNotAvailable)),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final token = await StorageService.getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(S.of(context).mustLoginFirst)));
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final url = "${ApiConfig.baseUrl}${ApiEndpoints.viewFile(fileId)}";
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context).failedToLoadAudio(response.statusCode),
              ),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = originalData['name'] ?? 'audio.mp3';
      final fileExtension = fileName.contains('.')
          ? fileName.substring(fileName.lastIndexOf('.'))
          : '.mp3';
      final mainAudioFile = File(
        '${tempDir.path}/main_audio_$timestamp$fileExtension',
      );

      await mainAudioFile.writeAsBytes(response.bodyBytes);

      if (!await mainAudioFile.exists() || await mainAudioFile.length() == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).failedToLoadBaseAudio)),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // ✅ اختيار ملفات صوتية إضافية
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        await mainAudioFile.delete();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final List<File> audioFiles = [mainAudioFile];
      for (var file in result.files) {
        if (file.path != null) {
          final pickedFile = File(file.path!);
          if (await pickedFile.exists()) {
            audioFiles.add(pickedFile);
          }
        }
      }

      if (audioFiles.length < 2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).mustSelectAtLeastTwoAudioFiles),
            ),
          );
        }
        await mainAudioFile.delete();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).mergingAudioFiles),
            duration: Duration(seconds: 3),
          ),
        );
      }

      // ✅ دمج الملفات الصوتية باستخدام FFmpeg
      final outputFile = File(
        '${tempDir.path}/merged_audio_$timestamp$fileExtension',
      );
      File? listFile;

      try {
        // إنشاء ملف قائمة
        listFile = File('${tempDir.path}/audio_list_$timestamp.txt');
        final buffer = StringBuffer();
        for (final file in audioFiles) {
          buffer.writeln("file '${file.path.replaceAll("'", "'\\''")}'");
        }
        await listFile.writeAsString(buffer.toString());

        final command =
            '-f concat -safe 0 -i "${listFile.path}" -acodec copy "${outputFile.path}"';

        print('🔀 [FFmpeg] Command: $command');

        // Temporarily disabled - FFmpeg Kit package is discontinued
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '⚠️ هذه الميزة معطلة مؤقتاً - حزمة FFmpeg Kit غير متاحة',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      } finally {
        if (listFile != null && await listFile.exists()) {
          await listFile.delete();
        }
        await mainAudioFile.delete();
      }
    } catch (e, stackTrace) {
      print('❌ [EditFilePage] Error merging audios: $e');
      print('❌ [EditFilePage] Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorOccurred(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ✅ تحويل صيغة الصوت (MP3 → WAV)
  Future<void> _convertAudioFormat() async {
    File? tempFile;
    try {
      print('🔄 [EditFilePage] Starting audio format conversion...');

      final originalData = widget.file['originalData'] ?? widget.file;
      final fileId = originalData['_id'] ?? originalData['id'];

      if (fileId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).fileIdNotAvailable)),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final token = await StorageService.getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(S.of(context).mustLoginFirst)));
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final url = "${ApiConfig.baseUrl}${ApiEndpoints.viewFile(fileId)}";
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context).failedToLoadAudio(response.statusCode),
              ),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = originalData['name'] ?? 'audio.mp3';
      final fileExtension = fileName.contains('.')
          ? fileName.substring(fileName.lastIndexOf('.'))
          : '.mp3';
      tempFile = File(
        '${tempDir.path}/temp_audio_conv_$timestamp$fileExtension',
      );

      await tempFile.writeAsBytes(response.bodyBytes);

      if (!await tempFile.exists() || await tempFile.length() == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).failedToLoadAudioFile)),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // ✅ اختيار صيغة الإخراج
      final outputFormat = await showDialog<String>(
        context: context,
        builder: (context) =>
            _AudioFormatDialog(currentExtension: fileExtension),
      );

      if (outputFormat == null) {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('🔄 [EditFilePage] Converting audio to $outputFormat...');

      // ✅ تحويل الصيغة باستخدام FFmpeg
      final outputFile = File(
        '${tempDir.path}/converted_audio_$timestamp$outputFormat',
      );

      String command;
      if (outputFormat == '.wav') {
        command =
            '-i "${tempFile.path}" -acodec pcm_s16le "${outputFile.path}"';
      } else if (outputFormat == '.mp3') {
        command =
            '-i "${tempFile.path}" -acodec libmp3lame "${outputFile.path}"';
      } else {
        command = '-i "${tempFile.path}" "${outputFile.path}"';
      }

      print('🔄 [FFmpeg] Command: $command');

      // Temporarily disabled - FFmpeg Kit package is discontinued
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⚠️ هذه الميزة معطلة مؤقتاً - حزمة FFmpeg Kit غير متاحة',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    } catch (e, stackTrace) {
      print('❌ [EditFilePage] Error converting audio format: $e');
      print('❌ [EditFilePage] Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorOccurred(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (tempFile != null && await tempFile.exists()) {
        await tempFile.delete();
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ✅ استخراج النص من PDF
  Future<void> _extractTextFromPdf() async {
    try {
      print('📄 [EditFilePage] Starting PDF text extraction...');

      final originalData = widget.file['originalData'] ?? widget.file;
      final fileId = originalData['_id'] ?? originalData['id'];

      if (fileId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).fileIdNotAvailable)),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final token = await StorageService.getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(S.of(context).mustLoginFirst)));
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final url = "${ApiConfig.baseUrl}${ApiEndpoints.viewFile(fileId)}";
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).pdfLoadFailed(response.statusCode)),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/temp_pdf_$timestamp.pdf');

      await tempFile.writeAsBytes(response.bodyBytes);

      if (!await tempFile.exists() || await tempFile.length() == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).failedToLoadPdf)),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('📄 [EditFilePage] Extracting text from PDF...');

      // ✅ ملاحظة: استخراج النص من PDF يتطلب مكتبة متخصصة مثل pdf_text
      // ✅ حالياً سنعرض رسالة للمستخدم
      await tempFile.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⚠️ استخراج النص من PDF يتطلب مكتبة إضافية. الميزة قيد التطوير.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ [EditFilePage] Error extracting text from PDF: $e');
      print('❌ [EditFilePage] Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorOccurred(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ✅ إضافة نص (annotation) فوق PDF
  Future<void> _addTextAnnotation() async {
    try {
      print('📝 [EditFilePage] Starting PDF text annotation...');

      final originalData = widget.file['originalData'] ?? widget.file;
      final fileId = originalData['_id'] ?? originalData['id'];

      if (fileId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).fileIdNotAvailable)),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final token = await StorageService.getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(S.of(context).mustLoginFirst)));
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final url = "${ApiConfig.baseUrl}${ApiEndpoints.viewFile(fileId)}";
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).pdfLoadFailed(response.statusCode)),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/temp_pdf_annot_$timestamp.pdf');

      await tempFile.writeAsBytes(response.bodyBytes);

      if (!await tempFile.exists() || await tempFile.length() == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).failedToLoadPdf)),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // ✅ فتح واجهة إدخال النص
      final annotationData = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => _PdfAnnotationDialog(),
      );

      if (annotationData == null) {
        await tempFile.delete();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('📝 [EditFilePage] Adding text annotation to PDF...');

      // ✅ إنشاء PDF جديد مع annotation
      final newPdf = pw.Document();

      // ✅ إضافة صفحة جديدة مع النص
      newPdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // الصفحة الأصلية كصورة (محدود - يحتاج تحويل PDF إلى صور)
                pw.Center(
                  child: pw.Text(
                    'PDF مع تعليق توضيحي',
                    style: pw.TextStyle(fontSize: 16),
                  ),
                ),
                // النص المضاف
                pw.Positioned(
                  left: (annotationData['x'] as double? ?? 50),
                  top: (annotationData['y'] as double? ?? 50),
                  child: pw.Text(
                    annotationData['text'] as String? ?? '',
                    style: pw.TextStyle(
                      fontSize: annotationData['fontSize'] as double? ?? 12,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // ✅ حفظ PDF الجديد
      final outputFile = File('${tempDir.path}/annotated_pdf_$timestamp.pdf');
      await outputFile.writeAsBytes(await newPdf.save());

      await tempFile.delete();

      if (await outputFile.exists()) {
        print('✅ [EditFilePage] PDF annotated successfully');
        if (mounted) {
          setState(() {
            _editedFile = outputFile;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).textAddedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ [EditFilePage] Error adding text annotation: $e');
      print('❌ [EditFilePage] Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorOccurred(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ✅ إضافة صورة (annotation) فوق PDF
  Future<void> _addImageAnnotation() async {
    try {
      print('🖼️ [EditFilePage] Starting PDF image annotation...');

      final originalData = widget.file['originalData'] ?? widget.file;
      final fileId = originalData['_id'] ?? originalData['id'];

      if (fileId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).fileIdNotAvailable)),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final token = await StorageService.getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(S.of(context).mustLoginFirst)));
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final url = "${ApiConfig.baseUrl}${ApiEndpoints.viewFile(fileId)}";
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).pdfLoadFailed(response.statusCode)),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/temp_pdf_img_$timestamp.pdf');

      await tempFile.writeAsBytes(response.bodyBytes);

      if (!await tempFile.exists() || await tempFile.length() == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).failedToLoadPdf)),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // ✅ اختيار صورة
      final imagePicker = ImagePicker();
      final pickedImage = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedImage == null) {
        await tempFile.delete();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // ✅ فتح واجهة تحديد موضع الصورة
      final positionData = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => _PdfImagePositionDialog(),
      );

      if (positionData == null) {
        await tempFile.delete();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('🖼️ [EditFilePage] Adding image annotation to PDF...');

      // ✅ إنشاء PDF جديد مع الصورة
      final imageBytes = await File(pickedImage.path).readAsBytes();
      final newPdf = pw.Document();

      // ✅ إضافة صفحة جديدة مع الصورة
      newPdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // الصفحة الأصلية (محدود - يحتاج تحويل PDF إلى صور)
                pw.Center(
                  child: pw.Text(
                    'PDF مع صورة',
                    style: pw.TextStyle(fontSize: 16),
                  ),
                ),
                // الصورة المضافة
                pw.Positioned(
                  left: (positionData['x'] as double? ?? 50),
                  top: (positionData['y'] as double? ?? 50),
                  child: pw.Image(
                    pw.MemoryImage(imageBytes),
                    width: (positionData['width'] as double? ?? 100),
                    height: (positionData['height'] as double? ?? 100),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // ✅ حفظ PDF الجديد
      final outputFile = File(
        '${tempDir.path}/image_annotated_pdf_$timestamp.pdf',
      );
      await outputFile.writeAsBytes(await newPdf.save());

      await tempFile.delete();

      if (await outputFile.exists()) {
        print('✅ [EditFilePage] PDF image annotation added successfully');
        if (mounted) {
          setState(() {
            _editedFile = outputFile;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).imageAddedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ [EditFilePage] Error adding image annotation: $e');
      print('❌ [EditFilePage] Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorOccurred(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ✅ Highlight النص في PDF
  Future<void> _highlightText() async {
    try {
      print('🖍️ [EditFilePage] Starting PDF text highlighting...');

      final originalData = widget.file['originalData'] ?? widget.file;
      final fileId = originalData['_id'] ?? originalData['id'];

      if (fileId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).fileIdNotAvailable)),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final token = await StorageService.getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(S.of(context).mustLoginFirst)));
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final url = "${ApiConfig.baseUrl}${ApiEndpoints.viewFile(fileId)}";
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).pdfLoadFailed(response.statusCode)),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File(
        '${tempDir.path}/temp_pdf_highlight_$timestamp.pdf',
      );

      await tempFile.writeAsBytes(response.bodyBytes);

      if (!await tempFile.exists() || await tempFile.length() == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).failedToLoadPdf)),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // ✅ فتح واجهة تحديد منطقة highlight
      final highlightData = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => _PdfHighlightDialog(),
      );

      if (highlightData == null) {
        await tempFile.delete();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('🖍️ [EditFilePage] Adding highlight to PDF...');

      // ✅ إنشاء PDF جديد مع highlight
      final newPdf = pw.Document();

      // ✅ إضافة صفحة جديدة مع highlight
      newPdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // الصفحة الأصلية (محدود - يحتاج تحويل PDF إلى صور)
                pw.Center(
                  child: pw.Text(
                    'PDF مع highlight',
                    style: pw.TextStyle(fontSize: 16),
                  ),
                ),
                // Highlight
                pw.Positioned(
                  left: (highlightData['x'] as double? ?? 50),
                  top: (highlightData['y'] as double? ?? 50),
                  child: pw.Container(
                    width: (highlightData['width'] as double? ?? 100),
                    height: (highlightData['height'] as double? ?? 20),
                    decoration: pw.BoxDecoration(color: PdfColors.yellow),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // ✅ حفظ PDF الجديد
      final outputFile = File('${tempDir.path}/highlighted_pdf_$timestamp.pdf');
      await outputFile.writeAsBytes(await newPdf.save());

      await tempFile.delete();

      if (await outputFile.exists()) {
        print('✅ [EditFilePage] PDF highlighted successfully');
        if (mounted) {
          setState(() {
            _editedFile = outputFile;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).textHighlightedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ [EditFilePage] Error highlighting PDF: $e');
      print('❌ [EditFilePage] Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorOccurred(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ✅ تعديل النص
  Future<void> _editText() async {
    try {
      final originalData = widget.file['originalData'] ?? widget.file;
      final fileId = originalData['_id'] ?? originalData['id'];

      if (fileId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).fileIdNotAvailable)),
        );
        return;
      }

      // تحميل الملف النصي
      final token = await StorageService.getToken();
      if (token == null) return;

      final url = "${ApiConfig.baseUrl}${ApiEndpoints.viewFile(fileId)}";
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(S.of(context).failedToLoadFile)));
        return;
      }

      // حفظ الملف مؤقتاً
      final tempDir = await getTemporaryDirectory();
      final fileName = originalData['name'] ?? 'file.txt';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(response.bodyBytes);

      // ✅ فتح محرر النص - مثل الصور، نستقبل الملف المعدل عند الحفظ
      final editedTextFile = await Navigator.push<File?>(
        context,
        MaterialPageRoute(
          builder: (context) => TextViewerPage(
            filePath: tempFile.path,
            fileName: fileName,
            fileId: null, // ✅ لا نرفع مباشرة، نعيد الملف إلى EditFilePage
            fileUrl: null,
          ),
        ),
      );

      // ✅ إذا تم حفظ الملف المعدل، احفظه في _editedFile مثل الصور
      if (editedTextFile != null && await editedTextFile.exists()) {
        final fileSize = await editedTextFile.length();
        if (fileSize > 0) {
          setState(() {
            _editedFile = editedTextFile;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).textEditedSuccessfully),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).error(e.toString()))),
      );
    }
  }

  // ✅ عرض خيارات الحفظ للصورة المعدلة
  Future<String?> _showSaveOptionDialog() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).saveOptions),
          content: Text(S.of(context).saveOptionsDescription),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(S.of(context).cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('new'),
              child: Text(S.of(context).saveNewCopy),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop('replace'),
              child: Text(S.of(context).replaceOldVersion),
            ),
          ],
        );
      },
    );
  }

  // ✅ حفظ التغييرات
  Future<void> _saveChanges() async {
    if (_isLoading) return;

    final token = await StorageService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).mustLoginFirst)));
      return;
    }

    final originalData = widget.file['originalData'] ?? widget.file;
    final fileId = originalData['_id'] ?? originalData['id'];

    if (fileId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).fileIdNotAvailable)));
      return;
    }

    // ✅ إذا كان هناك ملف معدل، عرض خيارات الحفظ
    if (_editedFile != null) {
      // ✅ التحقق من وجود الملف قبل استخدامه
      try {
        if (!await _editedFile!.exists()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).editedFileNotFound),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _editedFile = null;
          });
          return;
        }
      } catch (e) {
        print('❌ Error checking edited file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorAccessingEditedFile(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _editedFile = null;
        });
        return;
      }
      final saveOption = await _showSaveOptionDialog();

      if (saveOption == null) {
        // المستخدم ألغى العملية
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final fileController = Provider.of<FileController>(
          context,
          listen: false,
        );

        if (saveOption == 'replace') {
          // ✅ التحقق من نوع الملف
          final category =
              originalData['category']?.toString().toLowerCase() ?? '';
          final fileType = originalData['type']?.toString().toLowerCase() ?? '';
          final isImage =
              category == 'images' ||
              fileType.startsWith('image/') ||
              _fileType == 'image';

          // ✅ التحقق من أن الملف مشترك (isShared أو sharedWith) أو في غرفة (roomId)
          final isShared =
              originalData['isShared'] == true ||
              (originalData['sharedWith'] != null &&
                  (originalData['sharedWith'] as List).isNotEmpty);
          final hasRoomId =
              widget.file['roomId'] != null || originalData['roomId'] != null;

          // ✅ استخدام updateFileContent للصور (الباك إند يجعل replaceMode افتراضياً true للصور)
          // ✅ أو للملفات المشتركة أو في غرفة
          if (isImage || isShared || hasRoomId) {
            print(
              '📝 [EditFilePage] File is image/shared/in room, using updateFileContent',
            );
            print('   - isImage: $isImage');
            print('   - isShared: $isShared');
            print('   - hasRoomId: $hasRoomId');
            final updateSuccess = await fileController.updateFileContent(
              fileId: fileId,
              file: _editedFile!,
              token: token,
              replaceMode:
                  true, // ✅ استبدال تلقائي (الباك إند يجعلها افتراضية للصور)
            );

            if (updateSuccess) {
              print('✅ [EditFilePage] File content updated successfully');

              // ✅ مسح cache الصور في Flutter بعد التحديث الناجح
              // ✅ هذا يضمن أن الصور المحدثة يتم إعادة تحميلها
              // ✅ استخدام PaintingBinding.instance.imageCache بدلاً من imageCache مباشرة
              PaintingBinding.instance.imageCache.clear();
              PaintingBinding.instance.imageCache.clearLiveImages();
              print('✅ [EditFilePage] Image cache cleared');

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context).fileUpdatedSuccessfully),
                  backgroundColor: Colors.green,
                ),
              );
              // ✅ إرجاع true لإعلام الصفحة الأم أن التحديث تم بنجاح
              Navigator.pop(context, true);
              return;
            } else {
              print(
                '❌ [EditFilePage] Failed to update file content: ${fileController.errorMessage}',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    fileController.errorMessage ??
                        S.of(context).updateFileError,
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            // ✅ للملفات غير المشتركة وغير الصور: استخدام الطريقة القديمة (رفع ملف جديد وحذف القديم)
            print(
              '📝 [EditFilePage] File is not image/shared, using upload + delete',
            );
            // أولاً: رفع الملف الجديد
            final uploadSuccess = await fileController.uploadSingleFile(
              file: _editedFile!,
              token: token,
              parentFolderId: originalData['parentFolderId'],
            );

            if (uploadSuccess) {
              // ثانياً: حذف الملف القديم
              final deleteSuccess = await fileController.deleteFile(
                fileId: fileId,
                token: token,
              );

              if (deleteSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).fileReplacedSuccessfully),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context, true);
                return;
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ' ${S.of(context).fileUploadedButDeleteFailed} ${fileController.errorMessage ?? S.of(context).unknownError}',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    fileController.errorMessage ??
                        S.of(context).fileUpdateFailed,
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else if (saveOption == 'new') {
          // ✅ حفظ نسخة جديدة
          final uploadSuccess = await fileController.uploadSingleFile(
            file: _editedFile!,
            token: token,
            parentFolderId: originalData['parentFolderId'],
          );

          if (uploadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(S.of(context).newCopySavedSuccessfully),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
            return;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  fileController.errorMessage ??
                      S.of(context).saveNewVersionFailed,
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorOccurred(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    // ✅ إذا لم يكن هناك ملف معدل، تحديث metadata فقط
    setState(() {
      _isLoading = true;
    });

    try {
      final fileController = Provider.of<FileController>(
        context,
        listen: false,
      );

      // ✅ تحديث metadata فقط
      final tags = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final success = await fileController.updateFile(
        fileId: fileId,
        token: token,
        name:
            _nameController.text.trim() +
            (_fileExtension != null ? '.$_fileExtension' : ''),
        description: _descriptionController.text.trim(),
        tags: tags,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).changesSavedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              fileController.errorMessage ?? S.of(context).saveChangesFailed,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).errorOccurred(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

/// Dialog لاختيار الوقت لاستخراج الصورة من الفيديو
class _FrameExtractionDialog extends StatefulWidget {
  @override
  State<_FrameExtractionDialog> createState() => _FrameExtractionDialogState();
}

class _FrameExtractionDialogState extends State<_FrameExtractionDialog> {
  int _selectedSeconds = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).chooseTimeToExtractImage),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(S.of(context).chooseTimeInSeconds),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (_selectedSeconds > 0) {
                    setState(() {
                      _selectedSeconds--;
                    });
                  }
                },
              ),
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_selectedSeconds ${S.of(context).second}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _selectedSeconds++;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: _selectedSeconds.toDouble(),
            min: 0,
            max: 300, // 5 دقائق كحد أقصى
            divisions: 60,
            label: '$_selectedSeconds ${S.of(context).second}',
            onChanged: (value) {
              setState(() {
                _selectedSeconds = value.toInt();
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedSeconds),
          child: Text(S.of(context).extract),
        ),
      ],
    );
  }
}

/// Dialog لاختيار وقت البداية والنهاية لقص الصوت
class _AudioTrimDialog extends StatefulWidget {
  final File audioFile;

  const _AudioTrimDialog({required this.audioFile});

  @override
  State<_AudioTrimDialog> createState() => _AudioTrimDialogState();
}

class _AudioTrimDialogState extends State<_AudioTrimDialog> {
  Duration _startTime = Duration.zero;
  Duration _endTime = Duration.zero;
  Duration _audioDuration = Duration.zero;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAudioDuration();
  }

  Future<void> _loadAudioDuration() async {
    try {
      // استخدام audioplayers للحصول على مدة الملف
      final player = audioplayers.AudioPlayer();
      await player.setSource(
        audioplayers.DeviceFileSource(widget.audioFile.path),
      );
      final duration = await player.getDuration();
      await player.dispose();

      if (duration != null && mounted) {
        setState(() {
          _audioDuration = duration;
          _endTime = duration;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading audio duration: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).trimAudio),
      content: _isLoading
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    S
                        .of(context)
                        .totalDuration(_formatDuration(_audioDuration)),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'وقت البداية:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _startTime.inSeconds.toDouble(),
                    min: 0,
                    max: _endTime.inSeconds.toDouble(),
                    divisions: _audioDuration.inSeconds > 0
                        ? _audioDuration.inSeconds
                        : 1,
                    label: _formatDuration(_startTime),
                    onChanged: (value) {
                      setState(() {
                        _startTime = Duration(seconds: value.toInt());
                      });
                    },
                  ),
                  Text(_formatDuration(_startTime)),
                  const SizedBox(height: 24),
                  const Text(
                    'وقت النهاية:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _endTime.inSeconds.toDouble(),
                    min: _startTime.inSeconds.toDouble(),
                    max: _audioDuration.inSeconds.toDouble(),
                    divisions: _audioDuration.inSeconds > 0
                        ? _audioDuration.inSeconds
                        : 1,
                    label: _formatDuration(_endTime),
                    onChanged: (value) {
                      setState(() {
                        _endTime = Duration(seconds: value.toInt());
                      });
                    },
                  ),
                  Text(_formatDuration(_endTime)),
                  const SizedBox(height: 16),
                  Text(
                    'المدة المقطوعة: ${_formatDuration(_endTime - _startTime)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () => Navigator.pop(context, {
                  'start': _startTime,
                  'end': _endTime,
                }),
          child: Text(S.of(context).trim),
        ),
      ],
    );
  }
}

/// Dialog لاختيار مستوى الصوت
class _AudioVolumeDialog extends StatefulWidget {
  @override
  State<_AudioVolumeDialog> createState() => _AudioVolumeDialogState();
}

class _AudioVolumeDialogState extends State<_AudioVolumeDialog> {
  double _volumeMultiplier = 1.0; // 1.0 = 100%, 2.0 = 200%, 0.5 = 50%

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).adjustVolume),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${(_volumeMultiplier * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Slider(
            value: _volumeMultiplier,
            min: 0.0,
            max: 3.0,
            divisions: 60,
            label: '${(_volumeMultiplier * 100).toStringAsFixed(0)}%',
            onChanged: (value) {
              setState(() {
                _volumeMultiplier = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildVolumeButton('50%', 0.5),
              _buildVolumeButton('100%', 1.0),
              _buildVolumeButton('150%', 1.5),
              _buildVolumeButton('200%', 2.0),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _volumeMultiplier),
          child: Text(S.of(context).apply),
        ),
      ],
    );
  }

  Widget _buildVolumeButton(String label, double value) {
    return TextButton(
      onPressed: () {
        setState(() {
          _volumeMultiplier = value;
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: (_volumeMultiplier - value).abs() < 0.01
            ? Colors.blue.shade100
            : null,
      ),
      child: Text(label),
    );
  }
}

/// Dialog لاختيار صيغة الإخراج
class _AudioFormatDialog extends StatelessWidget {
  final String currentExtension;

  const _AudioFormatDialog({required this.currentExtension});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).convertFormat),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(S.of(context).chooseOutputFormat),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.audiotrack, color: Colors.blue),
            title: Text(S.of(context).wavFormat),
            subtitle: Text(S.of(context).wavDescription),
            onTap: () => Navigator.pop(context, '.wav'),
            selected: currentExtension.toLowerCase() == '.wav',
          ),
          ListTile(
            leading: const Icon(Icons.audiotrack, color: Colors.orange),
            title: Text(S.of(context).mp3Format),
            subtitle: Text(S.of(context).mp3Description),
            onTap: () => Navigator.pop(context, '.mp3'),
            selected: currentExtension.toLowerCase() == '.mp3',
          ),
          ListTile(
            leading: const Icon(Icons.audiotrack, color: Colors.green),
            title: Text(S.of(context).aacFormat),
            subtitle: Text(S.of(context).aacDescription),
            onTap: () => Navigator.pop(context, '.aac'),
            selected: currentExtension.toLowerCase() == '.aac',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel),
        ),
      ],
    );
  }
}

/// Dialog لإدخال بيانات annotation للنص
class _PdfAnnotationDialog extends StatefulWidget {
  @override
  State<_PdfAnnotationDialog> createState() => _PdfAnnotationDialogState();
}

class _PdfAnnotationDialogState extends State<_PdfAnnotationDialog> {
  final TextEditingController _textController = TextEditingController();
  double _x = 50;
  double _y = 50;
  double _fontSize = 12;
  int _page = 0;
  String _color = '#000000';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).addTextAnnotation),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'النص',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(S.of(context).positionX(_x.toStringAsFixed(0))),
            Slider(
              value: _x,
              min: 0,
              max: 200,
              onChanged: (value) => setState(() => _x = value),
            ),
            Text(S.of(context).positionY(_y.toStringAsFixed(0))),
            Slider(
              value: _y,
              min: 0,
              max: 200,
              onChanged: (value) => setState(() => _y = value),
            ),
            Text(S.of(context).fontSize(_fontSize.toStringAsFixed(0))),
            Slider(
              value: _fontSize,
              min: 8,
              max: 48,
              onChanged: (value) => setState(() => _fontSize = value),
            ),
            Text(S.of(context).page(_page.toString())),
            Slider(
              value: _page.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (value) => setState(() => _page = value.toInt()),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'text': _textController.text,
            'x': _x,
            'y': _y,
            'fontSize': _fontSize,
            'page': _page,
            'color': _color,
          }),
          child: Text(S.of(context).add),
        ),
      ],
    );
  }
}

/// Dialog لتحديد موضع الصورة
class _PdfImagePositionDialog extends StatefulWidget {
  @override
  State<_PdfImagePositionDialog> createState() =>
      _PdfImagePositionDialogState();
}

class _PdfImagePositionDialogState extends State<_PdfImagePositionDialog> {
  double _x = 50;
  double _y = 50;
  double _width = 100;
  double _height = 100;
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).selectImagePosition),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.of(context).positionX(_x.toStringAsFixed(0))),
            Slider(
              value: _x,
              min: 0,
              max: 200,
              onChanged: (value) => setState(() => _x = value),
            ),
            Text(S.of(context).positionY(_y.toStringAsFixed(0))),
            Slider(
              value: _y,
              min: 0,
              max: 200,
              onChanged: (value) => setState(() => _y = value),
            ),
            Text('العرض: ${_width.toStringAsFixed(0)}'),
            Slider(
              value: _width,
              min: 20,
              max: 200,
              onChanged: (value) => setState(() => _width = value),
            ),
            Text('الارتفاع: ${_height.toStringAsFixed(0)}'),
            Slider(
              value: _height,
              min: 20,
              max: 200,
              onChanged: (value) => setState(() => _height = value),
            ),
            Text(S.of(context).page(_page.toString())),
            Slider(
              value: _page.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (value) => setState(() => _page = value.toInt()),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'x': _x,
            'y': _y,
            'width': _width,
            'height': _height,
            'page': _page,
          }),
          child: Text(S.of(context).add),
        ),
      ],
    );
  }
}

/// Dialog لتحديد منطقة highlight
class _PdfHighlightDialog extends StatefulWidget {
  @override
  State<_PdfHighlightDialog> createState() => _PdfHighlightDialogState();
}

class _PdfHighlightDialogState extends State<_PdfHighlightDialog> {
  double _x = 50;
  double _y = 50;
  double _width = 100;
  double _height = 20;
  int _page = 0;
  String _color = '#FFFF00';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).highlightText),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.of(context).positionX(_x.toStringAsFixed(0))),
            Slider(
              value: _x,
              min: 0,
              max: 200,
              onChanged: (value) => setState(() => _x = value),
            ),
            Text(S.of(context).positionY(_y.toStringAsFixed(0))),
            Slider(
              value: _y,
              min: 0,
              max: 200,
              onChanged: (value) => setState(() => _y = value),
            ),
            Text('العرض: ${_width.toStringAsFixed(0)}'),
            Slider(
              value: _width,
              min: 20,
              max: 200,
              onChanged: (value) => setState(() => _width = value),
            ),
            Text('الارتفاع: ${_height.toStringAsFixed(0)}'),
            Slider(
              value: _height,
              min: 5,
              max: 50,
              onChanged: (value) => setState(() => _height = value),
            ),
            Text(S.of(context).page(_page.toString())),
            Slider(
              value: _page.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (value) => setState(() => _page = value.toInt()),
            ),
            const SizedBox(height: 16),
            Text(S.of(context).color),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildColorButton('أصفر', '#FFFF00'),
                _buildColorButton('أخضر', '#00FF00'),
                _buildColorButton('أزرق', '#00FFFF'),
                _buildColorButton('وردي', '#FF00FF'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'x': _x,
            'y': _y,
            'width': _width,
            'height': _height,
            'page': _page,
            'color': _color,
          }),
          child: Text(S.of(context).highlight),
        ),
      ],
    );
  }

  Widget _buildColorButton(String label, String color) {
    final isSelected = _color == color;
    return GestureDetector(
      onTap: () => setState(() => _color = color),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
