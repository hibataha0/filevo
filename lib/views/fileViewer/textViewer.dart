import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';

class TextViewerPage extends StatelessWidget {
  final String filePath; // مسار الملف المحلي
  final String fileName;

  const TextViewerPage({Key? key, required this.filePath, required this.fileName}) : super(key: key);

  // قائمة بجميع الامتدادات النصية المدعومة
  static final List<String> supportedTextExtensions = [
    'txt', 'json', 'xml', 'csv', 'html', 'htm', 'css', 'js', 'dart',
    'py', 'java', 'cpp', 'c', 'h', 'php', 'rb', 'go', 'rs', 'swift',
    'kt', 'md', 'yaml', 'yml', 'ini', 'cfg', 'conf', 'log', 'sql',
    'sh', 'bash', 'bat', 'ps1', 'env', 'gitignore', 'dockerfile',
    'xml', 'svg', 'rtf', 'tex', 'bib', 'ics', 'vcf'
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
      return Icons.settings_applications; // بدل environment
    case 'gitignore':
      return Icons.code; // بدل git
    case 'dockerfile':
      return Icons.apps; // بدل docker
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

  Future<String> _readFile() async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return 'الملف غير موجود';
      
      final content = await file.readAsString();
      final extension = _getFileExtension(fileName);
      
      return _formatContent(content, extension);
    } catch (e) {
      return 'حدث خطأ أثناء قراءة الملف: $e';
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
        return const TextStyle(
          fontSize: 16,
          height: 1.6,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final extension = _getFileExtension(fileName);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(getFileIcon(fileName), color: getFileColor(fileName)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                fileName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // إضافة actions لاحقاً مثل النسخ، المشاركة، إلخ
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.content_copy),
                    SizedBox(width: 8),
                    Text('نسخ المحتوى'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('مشاركة'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _readFile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              snapshot.data ?? 'لا يوجد محتوى',
              style: _getTextStyle(fileName),
            ),
          );
        },
      ),
    );
  }
}