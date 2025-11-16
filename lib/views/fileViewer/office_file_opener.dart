import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class OfficeFileOpener {
  // قائمة بجميع أنواع الملفات التي تفتح بالتطبيقات الخارجية
  static final List<String> allFileExtensions = [
    // مستندات وأوفيس
    'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'rtf', 
    'odt', 'ods', 'odp', 'csv',
    
    // ملفات مضغوطة
    'zip', 'rar', '7z', 'tar', 'gz', 'bz2', 'xz', 'iso', 'dmg',
    
    // تطبيقات
    'exe', 'apk', 'msi', 'dmg', 'deb', 'rpm', 'pkg', 'appimage', 
    
    // كتب إلكترونية
    'epub', 'mobi',
    
    // صور
    'ico', 'svg',
    
    // فيديوهات
    'webm', 'm4v', '3gp', 'flv',
    
    // صوتيات
    'm4a', 'wma', 'mid', 'midi', 'flac',
    
    // ملفات برمجة وإعدادات
    'js', 'ts', 'jsx', 'html', 'htm', 'css', 'scss', 'sass', 'less',
    'java', 'py', 'cpp', 'c', 'h', 'cs', 'php', 'rb', 'go', 'rs',
    'swift', 'kt', 'dart', 'json', 'xml', 'yaml', 'yml', 'ini', 
    'cfg', 'conf', 'env', 'gitignore', 'dockerfile', 'tex', 'bib',
    'ics', 'vcf', 'log', 'sql', 'sh', 'bash', 'ps1', 'bat', 'md', 'lock'
  ];

  // التحقق إذا كان الملف يمكن فتحه بالتطبيقات الخارجية
  static bool isOpenableFile(String fileName) {
    final extension = _getFileExtension(fileName);
    return allFileExtensions.contains(extension.toLowerCase());
  }

  // الحصول على امتداد الملف
  static String _getFileExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final fileName = pathSegments.last;
        final dotIndex = fileName.lastIndexOf('.');
        if (dotIndex != -1 && dotIndex < fileName.length - 1) {
          return fileName.substring(dotIndex + 1);
        }
      }
    } catch (e) {
      print('خطأ في تحليل امتداد الملف: $e');
    }
    return '';
  }

  // الحصول على اسم الملف من الرابط
  static String getFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return pathSegments.last;
      }
    } catch (e) {
      print('خطأ في استخراج اسم الملف: $e');
    }
    return 'file${_getFileExtension(url).isNotEmpty ? '.${_getFileExtension(url)}' : ''}';
  }

  // فتح أي ملف بالتطبيقات الخارجية (الطريقة الرئيسية)
  static Future<void> openAnyFile({
    required String url,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      // عرض مؤشر تحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // تحميل الملف
      final file = await _downloadFile(url, fileName);

      // إغلاق مؤشر التحميل
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (file != null) {
        // عرض خيارات فتح الملف
        await _showFileOpenDialog(context, file.path, fileName, url);
      } else {
        _showErrorDialog(context, 'فشل تحميل الملف');
      }
    } catch (e) {
      // إغلاق مؤشر التحميل في حالة الخطأ
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _showErrorDialog(context, 'حدث خطأ: $e');
    }
  }

  // عرض خيارات فتح الملف (واجهة موحدة لجميع الملفات)
  static Future<void> _showFileOpenDialog(BuildContext context, String filePath, String fileName, String url) async {
    final extension = _getFileExtension(filePath).toLowerCase();
    
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // رأس البطاقة
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getFileColorByExtension(extension).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getFileIconByExtension(extension),
                    color: _getFileColorByExtension(extension),
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getFileTypeDescription(extension),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'اختر التطبيق لفتح الملف',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // خيارات الفتح
            _buildFileOpenOptions(context, filePath, fileName, url, extension),
            
            // زر الإلغاء
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('إلغاء'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء خيارات فتح الملف (الدالة المصححة)
  static Widget _buildFileOpenOptions(BuildContext context, String filePath, String fileName, String url, String extension) {
    final List<Map<String, dynamic>> options = [
      {
        'title': 'فتح بالتطبيق الافتراضي',
        'subtitle': 'سيتم فتح الملف بالتطبيق المحدد في النظام',
        'icon': Icons.open_in_new,
        'color': Colors.blue,
        'onTap': () async {
          Navigator.pop(context);
          await _openFileWithDefault(filePath);
        },
      },
      {
        'title': 'فتح في المتصفح',
        'subtitle': 'فتح الرابط مباشرة في المتصفح',
        'icon': Icons.public,
        'color': Colors.green,
        'onTap': () async {
          Navigator.pop(context);
          await _openInBrowser(url, context);
        },
      },
      {
        'title': 'تنزيل الملف',
        'subtitle': 'حفظ الملف على الجهاز',
        'icon': Icons.download,
        'color': Colors.orange,
        'onTap': () async {
          Navigator.pop(context);
          await _downloadAndSaveFile(filePath, fileName, context);
        },
      },
    ];

    // إضافة خيارات خاصة حسب نوع الملف
    if (_isCompressedFile(extension)) {
      options.add({
        'title': 'استخراج الملف',
        'subtitle': 'فتح الملف ببرنامج الضغط',
        'icon': Icons.folder_open,
        'color': Colors.purple,
        'onTap': () async {
          Navigator.pop(context);
          await _openWithCompressionApp(filePath, context);
        },
      });
    }

    if (_isAppFile(extension)) {
      options.add({
        'title': 'تثبيت التطبيق',
        'subtitle': 'فتح بمدير التطبيقات',
        'icon': Icons.android,
        'color': Colors.red,
        'onTap': () async {
          Navigator.pop(context);
          await _openWithAppManager(filePath, context);
        },
      });
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        return ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: option['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(option['icon'], color: option['color']),
          ),
          title: Text(
            option['title'],
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
          subtitle: Text(
            option['subtitle'],
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          onTap: option['onTap'],
        );
      },
    );
  }

  // التحقق إذا كان ملف مضغوط
  static bool _isCompressedFile(String extension) {
    return ['zip', 'rar', '7z', 'tar', 'gz', 'bz2', 'xz', 'iso', 'dmg']
        .contains(extension);
  }

  // التحقق إذا كان ملف تطبيق
  static bool _isAppFile(String extension) {
    return ['exe', 'apk', 'msi', 'dmg', 'deb', 'rpm', 'pkg', 'appimage']
        .contains(extension);
  }

  // فتح ببرنامج الضغط
  static Future<void> _openWithCompressionApp(String filePath, BuildContext context) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        _showErrorDialog(context, 'تعذر فتح الملف ببرنامج الضغط');
      }
    } catch (e) {
      _showErrorDialog(context, 'حدث خطأ: $e');
    }
  }

  // فتح بمدير التطبيقات
  static Future<void> _openWithAppManager(String filePath, BuildContext context) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        _showErrorDialog(context, 'تعذر فتح الملف بمدير التطبيقات');
      }
    } catch (e) {
      _showErrorDialog(context, 'حدث خطأ: $e');
    }
  }

  // تنزيل وحفظ الملف
  static Future<void> _downloadAndSaveFile(String filePath, String fileName, BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.download_done, color: Colors.white),
              const SizedBox(width: 8),
              Text('تم تحميل الملف: $fileName'),
            ],
          ),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'فتح',
            textColor: Colors.white,
            onPressed: () => _openFileWithDefault(filePath),
          ),
        ),
      );
    } catch (e) {
      _showErrorDialog(context, 'حدث خطأ أثناء حفظ الملف: $e');
    }
  }

  // فتح في المتصفح
  static Future<void> _openInBrowser(String url, BuildContext context) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showErrorDialog(context, 'تعذر فتح الرابط في المتصفح');
      }
    } catch (e) {
      _showErrorDialog(context, 'حدث خطأ: $e');
    }
  }

  // فتح الملف بالتطبيق الافتراضي
  static Future<void> _openFileWithDefault(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      
      if (result.type != ResultType.done) {
        print('خطأ في فتح الملف: ${result.message}');
      }
    } catch (e) {
      print('خطأ في فتح الملف: $e');
    }
  }

  // الحصول على أيقونة الملف حسب النوع
  static IconData _getFileIconByExtension(String extension) {
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
      case 'odt':
      case 'rtf':
        return Icons.article;
      case 'xls':
      case 'xlsx':
      case 'ods':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
      case 'odp':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_fields;
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
      case 'bz2':
      case 'xz':
      case 'iso':
      case 'dmg':
        return Icons.archive;
      case 'exe':
      case 'apk':
      case 'msi':
      case 'deb':
      case 'rpm':
      case 'pkg':
      case 'appimage':
        return Icons.apps;
      case 'epub':
      case 'mobi':
        return Icons.menu_book;
      case 'js':
      case 'ts':
      case 'jsx':
      case 'html':
      case 'htm':
      case 'css':
      case 'java':
      case 'py':
      case 'cpp':
      case 'c':
      case 'php':
      case 'rb':
      case 'go':
      case 'rs':
      case 'swift':
      case 'kt':
      case 'dart':
        return Icons.code;
      case 'json':
      case 'xml':
      case 'yaml':
      case 'yml':
        return Icons.data_object;
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'ogg':
      case 'm4a':
      case 'wma':
      case 'mid':
      case 'midi':
      case 'flac':
        return Icons.audio_file;
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
      case 'webm':
      case 'm4v':
      case '3gp':
      case 'flv':
        return Icons.video_file;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'bmp':
      case 'ico':
      case 'svg':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  // الحصول على لون الأيقونة حسب النوع
  static Color _getFileColorByExtension(String extension) {
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
      case 'bz2':
      case 'xz':
      case 'iso':
      case 'dmg':
        return Colors.orange;
      case 'exe':
      case 'apk':
      case 'msi':
      case 'deb':
      case 'rpm':
      case 'pkg':
      case 'appimage':
        return Colors.purple;
      case 'epub':
      case 'mobi':
        return Colors.brown;
      case 'js':
      case 'ts':
      case 'jsx':
      case 'html':
      case 'css':
      case 'java':
      case 'py':
      case 'cpp':
      case 'c':
      case 'php':
        return Colors.yellow[700]!;
      case 'json':
      case 'xml':
        return Colors.orange;
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'ogg':
        return Colors.pink;
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
        return Colors.purple;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // وصف نوع الملف
  static String _getFileTypeDescription(String extension) {
    switch (extension) {
      case 'pdf':
        return 'ملف PDF';
      case 'doc':
      case 'docx':
        return 'مستند Word';
      case 'xls':
      case 'xlsx':
        return 'جدول Excel';
      case 'ppt':
      case 'pptx':
        return 'عرض تقديمي';
      case 'txt':
        return 'ملف نصي';
      case 'rtf':
        return 'مستند نصي منسق';
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
      case 'bz2':
      case 'xz':
        return 'ملف مضغوط';
      case 'iso':
      case 'dmg':
        return 'صورة قرص';
      case 'exe':
        return 'تطبيق Windows';
      case 'apk':
        return 'تطبيق Android';
      case 'msi':
        return 'برنامج تثبيت Windows';
      case 'deb':
        return 'حزمة Debian';
      case 'rpm':
        return 'حزمة Red Hat';
      case 'pkg':
        return 'حزمة macOS';
      case 'appimage':
        return 'تطبيق Linux';
      case 'epub':
        return 'كتاب إلكتروني';
      case 'mobi':
        return 'كتاب Kindle';
      case 'js':
      case 'ts':
      case 'jsx':
        return 'ملف JavaScript';
      case 'html':
      case 'htm':
        return 'صفحة ويب';
      case 'css':
        return 'ملف تنسيق';
      case 'java':
        return 'ملف Java';
      case 'py':
        return 'ملف Python';
      case 'json':
        return 'ملف بيانات';
      case 'xml':
        return 'ملف XML';
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'ogg':
        return 'ملف صوتي';
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
        return 'ملف فيديو';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'صورة';
      default:
        return 'ملف $extension';
    }
  }

  // تحميل الملف وحفظه مؤقتاً
  static Future<File?> _downloadFile(String url, String fileName) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$fileName');
        
        await file.writeAsBytes(bytes);
        return file;
      } else {
        throw Exception('فشل التحميل: ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ في تحميل الملف: $e');
      return null;
    }
  }

  // عرض رسالة خطأ
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}