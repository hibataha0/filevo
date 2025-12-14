import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:filevo/services/file_service.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/services/api_endpoints.dart';
import 'package:filevo/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:filevo/generated/l10n.dart';

class TextViewerPage extends StatefulWidget {
  final String filePath; // مسار الملف المحلي
  final String fileName;
  final String? fileId; // ✅ معرف الملف على السيرفر (لرفع التحديثات)
  final String? fileUrl; // ✅ رابط الملف الأصلي (لرفع التحديثات)

  const TextViewerPage({
    Key? key,
    required this.filePath,
    required this.fileName,
    this.fileId,
    this.fileUrl,
  }) : super(key: key);

  @override
  State<TextViewerPage> createState() => _TextViewerPageState();

  // قائمة بجميع الامتدادات النصية المدعومة
  static final List<String> supportedTextExtensions = [
    'txt',
    'json',
    'xml',
    'csv',
    'html',
    'htm',
    'css',
    'js',
    'dart',
    'py',
    'java',
    'cpp',
    'c',
    'h',
    'php',
    'rb',
    'go',
    'rs',
    'swift',
    'kt',
    'md',
    'yaml',
    'yml',
    'ini',
    'cfg',
    'conf',
    'log',
    'sql',
    'sh',
    'bash',
    'bat',
    'ps1',
    'env',
    'gitignore',
    'dockerfile',
    'xml',
    'svg',
    'rtf',
    'tex',
    'bib',
    'ics',
    'vcf',
  ];

  // التحقق إذا كان الملف نصي مدعوم
  static bool isTextFile(String fileName) {
    final extension = _getFileExtension(fileName);
    return supportedTextExtensions.contains(extension.toLowerCase());
  }

  // الحصول على امتداد الملف
  static String _getFileExtension(String fileName) {
    try {
      final dotIndex = fileName.lastIndexOf('.');
      if (dotIndex != -1 && dotIndex < fileName.length - 1) {
        return fileName.substring(dotIndex + 1).toLowerCase();
      }
    } catch (e) {
      print('خطأ في تحليل امتداد الملف: $e');
    }
    return '';
  }

  // الحصول على أيقونة الملف حسب النوع
  static IconData getFileIcon(String fileName) {
    final extension = _getFileExtension(fileName);

    switch (extension) {
      case 'json':
        return Icons.code;
      case 'xml':
      case 'html':
      case 'htm':
        return Icons.web;
      case 'css':
        return Icons.style;
      case 'js':
      case 'dart':
      case 'py':
      case 'java':
      case 'cpp':
      case 'c':
      case 'php':
      case 'rb':
      case 'go':
      case 'rs':
      case 'swift':
      case 'kt':
        return Icons.developer_mode;
      case 'md':
        return Icons.description;
      case 'yaml':
      case 'yml':
      case 'ini':
      case 'cfg':
      case 'conf':
        return Icons.settings;
      case 'log':
        return Icons.list_alt;
      case 'sql':
        return Icons.storage;
      case 'sh':
      case 'bash':
      case 'bat':
      case 'ps1':
        return Icons.terminal;
      case 'env':
        return Icons.settings_applications;
      case 'gitignore':
        return Icons.code;
      case 'dockerfile':
        return Icons.apps;
      case 'svg':
        return Icons.photo;
      case 'rtf':
        return Icons.text_format;
      case 'tex':
        return Icons.functions;
      case 'bib':
        return Icons.library_books;
      case 'ics':
        return Icons.calendar_today;
      case 'vcf':
        return Icons.contact_phone;
      default:
        return Icons.text_fields;
    }
  }

  // الحصول على لون الأيقونة حسب النوع
  static Color getFileColor(String fileName) {
    final extension = _getFileExtension(fileName);

    switch (extension) {
      case 'json':
        return Colors.orange;
      case 'xml':
        return Colors.green;
      case 'html':
      case 'htm':
        return Colors.blue;
      case 'css':
        return Colors.pink;
      case 'js':
        return Colors.yellow[700]!;
      case 'dart':
        return Colors.blue;
      case 'py':
        return Colors.blue[800]!;
      case 'java':
        return Colors.red;
      case 'cpp':
      case 'c':
        return Colors.blue[900]!;
      case 'php':
        return Colors.purple;
      case 'md':
        return Colors.grey;
      case 'sql':
        return Colors.orange[800]!;
      case 'sh':
      case 'bash':
        return Colors.green[800]!;
      default:
        return Colors.grey;
    }
  }
}

class _TextViewerPageState extends State<TextViewerPage> {
  final TextEditingController _textController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = true;
  bool _hasChanges = false;
  String _originalContent = '';
  bool _fileWasUpdated = false; // ✅ تتبع ما إذا تم تحديث الملف بنجاح

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// ✅ إعادة تحميل الملف من السيرفر بعد التحديث
  Future<void> _reloadFileFromServer(String token) async {
    if (widget.fileId == null) return;

    try {
      print('🔄 إعادة تحميل الملف من السيرفر...');
      final url =
          "${ApiConfig.baseUrl}${ApiEndpoints.viewFile(widget.fileId!)}";
      final response = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // ✅ حفظ الملف المحدث محلياً
        final file = File(widget.filePath);
        await file.writeAsBytes(response.bodyBytes);

        // ✅ إعادة تحميل المحتوى
        final content = await file.readAsString();
        final extension = _getFileExtension(widget.fileName);
        final formattedContent = _formatContent(content, extension);

        if (mounted) {
          setState(() {
            _originalContent = formattedContent;
            _textController.text = formattedContent;
          });
        }

        print('✅ تم إعادة تحميل الملف من السيرفر بنجاح');
      } else {
        print('⚠️ Failed to reload file from server: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error reloading file from server: $e');
      // لا نرمي الخطأ - الملف محفوظ محلياً
    }
  }

  /// ✅ تحميل محتوى الملف
  Future<void> _loadFile() async {
    try {
      final file = File(widget.filePath);
      if (!await file.exists()) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('الملف غير موجود: ${widget.fileName}'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          // ✅ محاولة إعادة تحميل الملف من السيرفر إذا كان fileId موجوداً
          if (widget.fileId != null && widget.fileId!.isNotEmpty) {
            try {
              final token = await StorageService.getToken();
              if (token != null) {
                await _reloadFileFromServer(token);
              }
            } catch (e) {
              print('⚠️ فشل إعادة تحميل الملف من السيرفر: $e');
            }
          }
        }
        return;
      }

      final content = await file.readAsString();
      final extension = _getFileExtension(widget.fileName);
      final formattedContent = _formatContent(content, extension);

      setState(() {
        _originalContent = formattedContent;
        _textController.text = formattedContent;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء قراءة الملف: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// ✅ حفظ التغييرات
  Future<void> _saveFile() async {
    try {
      // ✅ حفظ محلياً أولاً
      final file = File(widget.filePath);
      await file.writeAsString(_textController.text);

      setState(() {
        _originalContent = _textController.text;
        _hasChanges = false;
        _isEditing = false;
      });

      // ✅ إذا كان هناك fileId، ارفع الملف المحدث إلى السيرفر مباشرة
      if (widget.fileId != null && widget.fileId!.isNotEmpty) {
        final uploadSuccess = await _uploadUpdatedFile(file);
        if (mounted) {
          if (uploadSuccess) {
            // ✅ إعادة تحميل محتوى الملف من السيرفر بعد التحديث الناجح
            // ✅ لضمان أن البيانات محدثة عند فتح الملف مرة أخرى
            try {
              final reloadToken = await StorageService.getToken();
              if (reloadToken != null) {
                await _reloadFileFromServer(reloadToken);
              }
            } catch (e) {
              print('⚠️ Could not reload file from server: $e');
              // لا نوقف العملية - الملف محفوظ على السيرفر
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ${S.of(context).fileSavedAndUploaded}'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            // ✅ حفظ حالة أن الملف تم تحديثه بنجاح
            _fileWasUpdated = true;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('⚠️ ${S.of(context).fileSavedLocallyOnly}'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        // ✅ إذا لم يكن هناك fileId، ارجع الملف المعدل إلى EditFilePage (مثل الصور)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).fileSavedSuccessfully),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
          // ✅ إرجاع الملف المعدل إلى EditFilePage
          Navigator.pop(context, file);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${S.of(context).failedToSaveFile}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// ✅ رفع الملف المحدث إلى السيرفر باستخدام route الجديد
  /// ✅ ترجع true إذا نجح التحديث، false إذا فشل
  Future<bool> _uploadUpdatedFile(File file) async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception(S.of(context).accessTokenNotFound);
      }

      // ✅ التحقق من حجم الملف
      final fileSize = await file.length();
      print(
        '📤 File size: ${fileSize} bytes (${(fileSize / 1024).toStringAsFixed(2)} KB)',
      );

      if (fileSize == 0) {
        throw Exception(S.of(context).fileIsEmpty);
      }

      // ✅ استخدام FileService لتحديث محتوى الملف
      // ✅ للملفات النصية: replaceMode = true تلقائياً (يتم في الباك إند)
      // ✅ للملفات الأخرى: يمكن تحديد replaceMode يدوياً
      final fileService = FileService();
      final result = await fileService.updateFileContent(
        fileId: widget.fileId!,
        file: file,
        token: token,
        replaceMode: true, // ✅ للملفات النصية، دائماً true (استبدال بنفس الاسم)
      );

      if (result['success'] == true) {
        print('✅ تم تحديث محتوى الملف بنجاح');
        print('   - File name: ${result['file']?['name'] ?? 'N/A'}');
        print('   - Replace mode: ${result['replaceMode'] ?? 'N/A'}');

        // ✅ إعادة جلب بيانات الملف المحدثة من السيرفر لتحديث البيانات المحلية
        if (mounted && widget.fileId != null) {
          try {
            final fileController = Provider.of<FileController>(
              context,
              listen: false,
            );
            await fileController.getFileDetails(
              fileId: widget.fileId!,
              token: token,
            );
            print('✅ تم تحديث بيانات الملف في الـ controller');
          } catch (e) {
            print('⚠️ Could not refresh file details: $e');
            // لا نرمي الخطأ هنا - التحديث نجح على السيرفر
          }
        }

        return true; // ✅ نجح التحديث
      } else {
        print('❌ فشل تحديث محتوى الملف: ${result['message'] ?? 'Unknown error'}');
        
        // ✅ معالجة أنواع مختلفة من الأخطاء
        String errorMessage = result['message'] ?? 'فشل رفع الملف إلى السيرفر';

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حفظ الملف محلياً، لكن $errorMessage'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return false; // ✅ فشل التحديث
      }
    } catch (e) {
      print('❌ خطأ في رفع الملف المحدث: $e');
      print('❌ Error type: ${e.runtimeType}');

      // ✅ معالجة أنواع مختلفة من الأخطاء
      String errorMessage = 'فشل رفع الملف إلى السيرفر';

      if (e.toString().contains('Connection reset') ||
          e.toString().contains('Connection closed')) {
        errorMessage =
            'انقطع الاتصال بالسيرفر. يرجى التحقق من الاتصال والمحاولة مرة أخرى.';
      } else if (e.toString().contains('timeout') ||
          e.toString().contains('TimeoutException')) {
        errorMessage = 'انتهت مهلة الاتصال. الملف كبير جداً أو الاتصال بطيء.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage =
            'لا يمكن الاتصال بالسيرفر. يرجى التحقق من الاتصال بالإنترنت.';
      } else {
        errorMessage = 'خطأ في رفع الملف: ${e.toString()}';
      }

      // ✅ لا نرمي الخطأ هنا - الملف محفوظ محلياً على الأقل
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ الملف محلياً، لكن $errorMessage'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return false; // ✅ فشل التحديث
    }
  }

  /// ✅ إلغاء التعديلات
  void _cancelEditing() {
    setState(() {
      _textController.text = _originalContent;
      _hasChanges = false;
      _isEditing = false;
    });
  }

  /// ✅ تبديل وضع التحرير
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // ✅ إلغاء التعديلات عند الخروج من وضع التحرير
        _textController.text = _originalContent;
        _hasChanges = false;
      }
    });
  }

  // الحصول على امتداد الملف (instance method)
  String _getFileExtension(String fileName) {
    return TextViewerPage._getFileExtension(fileName);
  }

  // تنسيق المحتوى حسب نوع الملف
  String _formatContent(String content, String extension) {
    switch (extension) {
      case 'json':
        return _formatJson(content);
      case 'xml':
        return _formatXml(content);
      case 'csv':
        return _formatCsv(content);
      case 'html':
      case 'htm':
        return _formatHtml(content);
      default:
        return content;
    }
  }

  // تنسيق JSON
  String _formatJson(String content) {
    try {
      // محاولة تنسيق JSON إذا كان صالحاً
      final parsed = json.decode(content);
      return _formatJsonPretty(parsed);
    } catch (e) {
      return content; // إذا لم يكن JSON صالح، عرضه كما هو
    }
  }

  String _formatJsonPretty(dynamic jsonData, [int indent = 0]) {
    final spaces = '  ' * indent;
    if (jsonData is Map) {
      final entries = jsonData.entries.toList();
      if (entries.isEmpty) return '{}';

      final buffer = StringBuffer();
      buffer.writeln('{');
      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        buffer.write('$spaces  "${entry.key}": ');
        if (entry.value is Map || entry.value is List) {
          buffer.write(_formatJsonPretty(entry.value, indent + 1));
        } else {
          buffer.write(_valueToString(entry.value));
        }
        if (i < entries.length - 1) buffer.write(',');
        buffer.writeln();
      }
      buffer.write('$spaces}');
      return buffer.toString();
    } else if (jsonData is List) {
      if (jsonData.isEmpty) return '[]';

      final buffer = StringBuffer();
      buffer.writeln('[');
      for (int i = 0; i < jsonData.length; i++) {
        buffer.write('$spaces  ');
        if (jsonData[i] is Map || jsonData[i] is List) {
          buffer.write(_formatJsonPretty(jsonData[i], indent + 1));
        } else {
          buffer.write(_valueToString(jsonData[i]));
        }
        if (i < jsonData.length - 1) buffer.write(',');
        buffer.writeln();
      }
      buffer.write('$spaces]');
      return buffer.toString();
    } else {
      return _valueToString(jsonData);
    }
  }

  String _valueToString(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    return value.toString();
  }

  // تنسيق XML
  String _formatXml(String xml) {
    try {
      int indent = 0;
      final buffer = StringBuffer();
      final lines = xml.split('<');

      for (final line in lines) {
        if (line.isEmpty) continue;

        if (line.startsWith('/')) {
          indent--;
          buffer.write('${'  ' * indent}<$line\n');
        } else if (line.endsWith('/>')) {
          buffer.write('${'  ' * indent}<$line\n');
        } else if (!line.startsWith('?')) {
          buffer.write('${'  ' * indent}<$line\n');
          if (!line.endsWith('/>') && !line.contains('</')) {
            indent++;
          }
        } else {
          buffer.write('<$line\n');
        }
      }

      return buffer.toString();
    } catch (e) {
      return xml;
    }
  }

  // تنسيق CSV
  String _formatCsv(String csv) {
    try {
      final lines = csv.split('\n');
      final buffer = StringBuffer();

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        final cells = line.split(',');

        for (int j = 0; j < cells.length; j++) {
          buffer.write(cells[j].trim().padRight(20));
          if (j < cells.length - 1) buffer.write(' | ');
        }
        buffer.writeln();

        if (i == 0 && lines.length > 1) {
          buffer.write('-' * (line.length + (cells.length * 3)));
          buffer.writeln();
        }
      }

      return buffer.toString();
    } catch (e) {
      return csv;
    }
  }

  // تنسيق HTML
  String _formatHtml(String html) {
    try {
      return html
          .replaceAll('>', '>\n')
          .replaceAll('<', '\n<')
          .replaceAll('\n\n', '\n')
          .trim();
    } catch (e) {
      return html;
    }
  }

  // الحصول على نمط النص المناسب
  TextStyle _getTextStyle(String fileName) {
    final extension = _getFileExtension(fileName);

    switch (extension) {
      case 'json':
      case 'xml':
      case 'html':
      case 'css':
      case 'js':
      case 'dart':
      case 'py':
      case 'java':
      case 'cpp':
      case 'c':
      case 'php':
      case 'sql':
      case 'sh':
      case 'bash':
        return const TextStyle(
          fontFamily: 'Monospace',
          fontSize: 12,
          height: 1.4,
        );
      default:
        return const TextStyle(fontSize: 16, height: 1.6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges && _isEditing) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(S.of(context).unsavedChanges),
              content: Text(S.of(context).unsavedChangesMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(S.of(context).cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(S.of(context).exit),
                ),
              ],
            ),
          );
          if (shouldPop == true) {
            // ✅ استخدام Future.microtask لتأجيل استدعاء Navigator.pop
            // ✅ هذا يضمن أن الـ widget لا يزال mounted عند الاستدعاء
            Future.microtask(() {
              if (mounted) {
                Navigator.of(context, rootNavigator: false).pop(_fileWasUpdated);
              }
            });
            return false; // ✅ منع الإغلاق التلقائي لأننا سنغلق يدوياً
          }
          return false;
        }
        // ✅ استخدام Future.microtask لتأجيل استدعاء Navigator.pop
        // ✅ هذا يضمن أن الـ widget لا يزال mounted عند الاستدعاء
        Future.microtask(() {
          if (mounted) {
            Navigator.of(context, rootNavigator: false).pop(_fileWasUpdated);
          }
        });
        return false; // ✅ منع الإغلاق التلقائي لأننا سنغلق يدوياً
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(
                TextViewerPage.getFileIcon(widget.fileName),
                color: TextViewerPage.getFileColor(widget.fileName),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(widget.fileName, overflow: TextOverflow.ellipsis),
              ),
              if (_hasChanges && _isEditing)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.circle, size: 8, color: Colors.orange),
                ),
            ],
          ),
          actions: [
            // ✅ زر التحرير/الحفظ
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _hasChanges ? _saveFile : null,
                tooltip: S.of(context).save,
              )
            else
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _toggleEditMode,
                tooltip: S.of(context).edit,
              ),
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _cancelEditing,
                tooltip: S.of(context).cancel,
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'copy') {
                  // ✅ نسخ المحتوى
                  // يمكن إضافة Clipboard functionality لاحقاً
                } else if (value == 'share') {
                  // ✅ مشاركة الملف
                  // يمكن إضافة Share functionality لاحقاً
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'copy',
                  child: Row(
                    children: [
                      Icon(Icons.content_copy),
                      SizedBox(width: 8),
                      Text(S.of(context).copyContent),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text(S.of(context).share),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _isEditing
            ? _buildEditView()
            : _buildReadView(),
      ),
    );
  }

  /// ✅ بناء واجهة القراءة
  Widget _buildReadView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        _textController.text.isEmpty ? 'لا يوجد محتوى' : _textController.text,
        style: _getTextStyle(widget.fileName),
      ),
    );
  }

  /// ✅ بناء واجهة التحرير
  Widget _buildEditView() {
    return Column(
      children: [
        // ✅ شريط الأدوات
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: Theme.of(context).appBarTheme.backgroundColor,
          child: Row(
            children: [
              const Text(
                'وضع التحرير',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_hasChanges)
                const Text(
                  'تغييرات غير محفوظة',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
            ],
          ),
        ),
        // ✅ حقل التحرير
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              style: _getTextStyle(widget.fileName),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'ابدأ الكتابة...',
              ),
              onChanged: (value) {
                setState(() {
                  _hasChanges = value != _originalContent;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
