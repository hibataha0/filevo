import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// صفحة محرر الصور الاحترافية باستخدام pro_image_editor
class ImageEditorPage extends StatefulWidget {
  final File imageFile;

  const ImageEditorPage({super.key, required this.imageFile});

  @override
  State<ImageEditorPage> createState() => _ImageEditorPageState();
}

class _ImageEditorPageState extends State<ImageEditorPage> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  /// تحميل الصورة في الذاكرة لتجنب مشاكل الملفات المؤقتة
  Future<void> _loadImage() async {
    try {
      // ✅ التحقق من وجود الملف
      if (!await widget.imageFile.exists()) {
        setState(() {
          _errorMessage = 'الملف غير موجود';
          _isLoading = false;
        });
        return;
      }

      // ✅ قراءة الملف في الذاكرة
      final bytes = await widget.imageFile.readAsBytes();

      if (bytes.isEmpty) {
        setState(() {
          _errorMessage = 'الملف فارغ';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _imageBytes = bytes;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading image: $e');
      setState(() {
        _errorMessage = 'فشل تحميل الصورة: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('تحميل الصورة')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _imageBytes == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'فشل تحميل الصورة',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ استخدام ProImageEditor.memory بدلاً من file لتجنب مشاكل الملفات المؤقتة
    return ProImageEditor.memory(
      _imageBytes!,
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (imageBytes) async {
          // ✅ حفظ الصورة المعدلة
          if (imageBytes.isNotEmpty) {
            final editedFile = await _saveEditedImage(imageBytes);
            if (mounted && editedFile != null) {
              Navigator.pop(context, editedFile);
            }
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  /// حفظ الصورة المعدلة
  Future<File?> _saveEditedImage(Uint8List imageBytes) async {
    try {
      if (imageBytes.isEmpty) {
        print('❌ Image bytes are empty');
        return null;
      }

      final tempDir = await getTemporaryDirectory();

      // ✅ التأكد من وجود المجلد المؤقت
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final editedFile = File('${tempDir.path}/edited_$timestamp.jpg');

      // ✅ كتابة الملف
      await editedFile.writeAsBytes(imageBytes);

      // ✅ التحقق من وجود الملف وحجمه
      if (await editedFile.exists()) {
        final fileSize = await editedFile.length();
        if (fileSize > 0) {
          print(
            '✅ Image saved successfully: ${editedFile.path}, size: $fileSize bytes',
          );
          return editedFile;
        } else {
          print('❌ Saved file is empty');
          // ✅ حذف الملف الفارغ
          try {
            await editedFile.delete();
          } catch (_) {}
          return null;
        }
      } else {
        print('❌ File was not created');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ Error saving edited image: $e');
      print('❌ Stack trace: $stackTrace');
      return null;
    }
  }
}
