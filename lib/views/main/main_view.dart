import 'dart:io';
import 'dart:async'; // ✅ للـ TimeoutException
import 'package:file_picker/file_picker.dart';
import 'package:filevo/components/NavigationBar .dart';
import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filevo/views/folders/folders_view.dart';
import 'package:filevo/views/home/home_view.dart';
import 'package:filevo/views/profile/profile_view.dart';
import 'package:filevo/views/settings/settings_view.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selected = 0;
  String? _token;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadToken();
    _pages = [
      HomeView(),
      FoldersPage(),
      ProfilePage(),
      SettingsPage(),
    ];
  }

  Future<void> _loadToken() async {
    final token = await StorageService.getToken();
    setState(() {
      _token = token;
    });
    print('🔑 Token: ${_token != null ? "موجود ✅" : "مش موجود ❌"}');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // ✅ رفع مجلد - اختيار اسم المجلد أولاً ثم اختيار الملفات
  Future<void> _uploadFolderAndroid() async {
    if (_token == null) {
      _showSnackBar('⚠️ سجل دخول أولاً', isError: true);
      return;
    }

    try {
      // ✅ 1. طلب اسم المجلد أولاً
      final folderNameController = TextEditingController();
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('إنشاء مجلد جديد'),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(
              hintText: 'أدخل اسم المجلد',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.folder),
            ),
            autofocus: true,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                if (folderNameController.text.trim().isNotEmpty) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('التالي'),
            ),
          ],
        ),
      );

      // ✅ قراءة النص من الـ controller قبل أي dispose
      final folderName = shouldProceed == true 
          ? folderNameController.text.trim() 
          : '';
      
      // ✅ انتظار قليل للتأكد من إغلاق الـ dialog تماماً
      await Future.delayed(const Duration(milliseconds: 100));
      
      // ✅ الآن يمكن dispose بأمان
      folderNameController.dispose();
      
      if (shouldProceed != true || folderName.isEmpty) {
        if (shouldProceed == true && folderName.isEmpty) {
          _showSnackBar('⚠️ يجب إدخال اسم المجلد', isError: true);
        }
        return;
      }

      // ✅ 2. طلب الصلاحيات (لـ Android 10 وأقل)
      if (await _requestStoragePermissions()) {
        print('✅ Storage permissions granted');
      }

      // ✅ 3. فتح file picker لاختيار ملفات متعددة
      _showSnackBar('📁 اختر الملفات التي تريد إضافتها للمجلد...');
      
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result == null || result.files.isEmpty) {
        print('❌ User cancelled file selection');
        return;
      }

      print('✅ Selected ${result.files.length} files');

      // ✅ 4. قراءة الملفات وتحويلها إلى bytes
      _showSnackBar('📁 جاري قراءة الملفات...');

      List<Map<String, dynamic>> filesData = [];
      List<String> relativePaths = [];

      for (var platformFile in result.files) {
        try {
          List<int> bytes;
          String fileName = platformFile.name;
          
          if (platformFile.path != null) {
            final file = File(platformFile.path!);
            if (await file.exists()) {
              bytes = await file.readAsBytes();
              print('✅ Read file: $fileName (${bytes.length} bytes)');
            } else {
              print('⚠️ File does not exist: ${platformFile.path}');
              continue;
            }
          } else if (platformFile.bytes != null) {
            // ✅ إذا كان الملف في الذاكرة (مثل اختيار من Google Drive)
            bytes = platformFile.bytes!;
            print('✅ Read file from memory: $fileName (${bytes.length} bytes)');
          } else {
            print('⚠️ No file data available for: $fileName');
            continue;
          }
          
          filesData.add({
            'bytes': bytes,
            'fileName': fileName,
          });
          
          // ✅ استخدام اسم الملف كـ relative path
          relativePaths.add(fileName);
        } catch (e) {
          print('❌ Error reading file ${platformFile.name}: $e');
        }
      }

      if (filesData.isEmpty) {
        _showSnackBar('❌ لا يمكن قراءة الملفات المختارة', isError: true);
        return;
      }

      print('✅ Successfully collected ${filesData.length} files');

      // ✅ 5. رفع المجلد مع الملفات
      final folderController = Provider.of<FolderController>(context, listen: false);
      _showSnackBar('📁 جاري رفع المجلد "$folderName" (${filesData.length} ملف)...');

      print('🔄 MainView: Calling uploadFolder...');
      print('   Folder name: $folderName');
      print('   Files count: ${filesData.length}');
      print('   Relative paths count: ${relativePaths.length}');

      final response = await folderController.uploadFolder(
        folderName: folderName,
        filesData: filesData,
        relativePaths: relativePaths,
      );

      print('📥 MainView: Server response received');
      print('📥 Response is null: ${response == null}');
      print('📥 Response: $response');
      print('📥 Controller error message: ${folderController.errorMessage}');

      if (response != null && response['folder'] != null) {
        print('✅ MainView: Upload successful!');
        _showSnackBar('✅ تم رفع المجلد "$folderName" بنجاح! (${filesData.length} ملف)');
      } else {
        print('❌ MainView: Upload failed or response is null');
        final errorMsg = response?['message'] ?? 
                         response?['error'] ?? 
                         folderController.errorMessage ?? 
                         "فشل رفع المجلد";
        print('❌ Error message: $errorMsg');
        _showSnackBar('❌ $errorMsg', isError: true);
      }

    } catch (e) {
      print('❌ Error in _uploadFolderAndroid: $e');
      _showSnackBar('❌ خطأ في رفع المجلد: ${e.toString()}', isError: true);
    }
  }

// ✅ دالة لطلب صلاحيات التخزين
Future<bool> _requestStoragePermissions() async {
  if (Platform.isAndroid) {
    // ✅ للـ Android 13+ (API 33+)
    if (await Permission.photos.isGranted || 
        await Permission.videos.isGranted || 
        await Permission.audio.isGranted) {
          print('✅ Media permissions already granted');
      return true;
    }

    // ✅ للـ Android 11-12 (API 30-32) - SAF يغطيها
    // ✅ للـ Android 10 وأقل (API 29-)
    if (await Permission.storage.isGranted) {
      print('✅ Storage permission already granted');
      return true;
    }

    // ✅ طلب الصلاحية
    final status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    }

    // ✅ إذا تم الرفض، حاول فتح الإعدادات
    if (status.isPermanentlyDenied) {
      _showSnackBar('⚠️ يرجى منح صلاحية التخزين من الإعدادات', isError: true);
      await openAppSettings();
      return false;
    }
  }
  return false;
}

// ✅ دالة محسنة لقراءة محتويات المجلد مع دعم SAF الكامل
Future<(List<File>, List<String>, int)> _readFolderContentsWithSAF(String directoryPath) async {
  final List<File> files = [];
  final List<String> relativePaths = [];
  int fileCount = 0;

  print('🔍 Attempting to read folder: $directoryPath');

  try {
    // ✅ استخدام variable محلي للتعديل
    String effectivePath = directoryPath;
    Directory directory = Directory(effectivePath);
    
    // ✅ التحقق من وجود المجلد
    if (!await directory.exists()) {
      print('❌ Directory does not exist: $effectivePath');
      throw Exception('المجلد غير موجود: $effectivePath');
    }

    // ✅ للـ Android 11+: محاولة استخدام listSync أولاً (قد يعمل مع SAF في بعض الحالات)
    bool isAndroid11Plus = Platform.isAndroid && effectivePath.startsWith('/storage/emulated/0/');
    
    if (isAndroid11Plus) {
      print('📱 Android 11+ detected - Trying listSync first...');
      
      // ✅ محاولة listSync أولاً على Android 11+ (قد يعمل مع SAF)
      try {
        final entities = directory.listSync(recursive: true);
        print('🔄 Found ${entities.length} entities using listSync');
        
        for (var entity in entities) {
          if (entity is File) {
            try {
              final file = File(entity.path);
              
              if (!file.existsSync()) {
                continue;
              }

              try {
                final stat = file.statSync();
                
                // ✅ محاولة فتح الملف للتأكد من إمكانية القراءة
                final randomAccessFile = await file.open();
                await randomAccessFile.close();
                
                files.add(file);
                final relativePath = p.relative(entity.path, from: effectivePath);
                relativePaths.add(relativePath);
                fileCount++;
                
                print('✅ Added (listSync): ${p.basename(entity.path)} (${stat.size} bytes)');
              } catch (e) {
                print('⚠️ Cannot open file (listSync): ${entity.path} - $e');
                // ✅ محاولة إضافته رغم ذلك
                try {
                  files.add(file);
                  final relativePath = p.relative(entity.path, from: effectivePath);
                  relativePaths.add(relativePath);
                  fileCount++;
                } catch (e2) {
                  print('❌ Failed to add file: ${entity.path}');
                }
              }
            } catch (e) {
              print('⚠️ Error processing file (listSync): ${entity.path} - $e');
              continue;
            }
          }
        }
        
        if (fileCount > 0) {
          print('✅ Successfully read $fileCount files using listSync on Android 11+');
          return (files, relativePaths, fileCount);
        }
      } catch (e) {
        print('⚠️ listSync failed on Android 11+: $e - Trying async method...');
      }
    }

    // ✅ محاولة قراءة الملفات بطريقة عادية (لـ Android 10 وأقل أو مجلدات متاحة)
    try {
      await for (FileSystemEntity entity in directory.list(recursive: true)) {
        if (entity is File) {
          try {
            final file = File(entity.path);
            
            if (!await file.exists()) {
              continue;
            }

            // ✅ محاولة فتح الملف للتأكد من إمكانية القراءة
            try {
              final stat = await file.stat();
              
              // ✅ محاولة فتح الملف للقراءة
              final testRead = file.openRead();
              await testRead.first.timeout(
                const Duration(seconds: 1),
              );
              
              files.add(file);
              final relativePath = p.relative(entity.path, from: effectivePath);
              relativePaths.add(relativePath);
              fileCount++;
              
              print('✅ Added: ${p.basename(entity.path)} (${stat.size} bytes)');
            } catch (e) {
              print('⚠️ Cannot read file: ${entity.path} - $e');
              // ✅ محاولة إضافة الملف رغم ذلك (قد يعمل لاحقاً)
              try {
                files.add(file);
                final relativePath = p.relative(entity.path, from: effectivePath);
                relativePaths.add(relativePath);
                fileCount++;
                print('⚠️ Added without verification: ${p.basename(entity.path)}');
              } catch (e2) {
                print('❌ Failed to add file: ${entity.path}');
              }
            }
          } catch (e) {
            print('⚠️ Error processing file: ${entity.path} - $e');
            continue;
          }
        }
      }
      
      // ✅ إذا نجحت، رجع النتيجة
      if (fileCount > 0) {
        print('✅ Successfully read $fileCount files using async method');
        return (files, relativePaths, fileCount);
      }
    } catch (e) {
      print('⚠️ directory.list() failed: $e');
      
      // ✅ طريقة بديلة: استخدام listSync (fallback)
      if (!isAndroid11Plus) {
        try {
          final entities = directory.listSync(recursive: true);
          print('🔄 Found ${entities.length} entities using listSync (fallback)');
          
          for (var entity in entities) {
            if (entity is File) {
              try {
                final file = File(entity.path);
                
                if (!file.existsSync()) {
                  continue;
                }

                try {
                  final stat = file.statSync();
                  
                  // ✅ محاولة فتح الملف
                  final randomAccessFile = await file.open();
                  await randomAccessFile.close();
                  
                  files.add(file);
                  final relativePath = p.relative(entity.path, from: effectivePath);
                  relativePaths.add(relativePath);
                  fileCount++;
                  
                  print('✅ Added (sync fallback): ${p.basename(entity.path)} (${stat.size} bytes)');
                } catch (e) {
                  print('⚠️ Cannot open file (sync fallback): ${entity.path} - $e');
                  // ✅ محاولة إضافته رغم ذلك
                  try {
                    files.add(file);
                    final relativePath = p.relative(entity.path, from: effectivePath);
                    relativePaths.add(relativePath);
                    fileCount++;
                  } catch (e2) {
                    print('❌ Failed to add file: ${entity.path}');
                  }
                }
              } catch (e) {
                print('⚠️ Error processing file (sync fallback): ${entity.path} - $e');
                continue;
              }
            }
          }
          
          if (fileCount > 0) {
            print('✅ Successfully read $fileCount files using listSync (fallback)');
            return (files, relativePaths, fileCount);
          }
        } catch (e2) {
          print('❌ listSync fallback also failed: $e2');
        }
      }
    }

    // ✅ إذا فشلت كل المحاولات
    if (fileCount == 0) {
      throw Exception(
        'لا يمكن قراءة ملفات المجلد.\n'
        'المسار: $effectivePath\n\n'
        '⚠️ هذه مشكلة شائعة على Android 11+ بسبب Scoped Storage\n\n'
        'الحلول المقترحة:\n'
        '1. اذهب إلى إعدادات الجهاز > التطبيقات > filevo > الأذونات\n'
        '2. منح صلاحية "إدارة جميع الملفات" (MANAGE_EXTERNAL_STORAGE)\n'
        '3. اختر مجلد من قسم "Downloads" أو "Documents" بدلاً من مجلدات أخرى\n'
        '4. جرب مجلد من مجلد التطبيق الخاص بك أو مجلدات متاحة أخرى'
      );
    }

  } catch (e) {
    print('❌ Error reading folder contents: $e');
    rethrow;
  }

  return (files, relativePaths, fileCount);
}

// 🔥 دالة لعرض تأكيد رفع المجلد
Future<bool> _showFolderConfirmationDialog(String directoryPath, String folderName) async {
  // حساب عدد الملفات التقريبي أولاً
  final estimatedCount = await _estimateFileCount(directoryPath);
  
  return await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text("رفع المجلد $folderName"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("هل تريد رفع هذا المجلد مع جميع محتوياته؟"),
          SizedBox(height: 10),
          Text(
            "سيتم رفع جميع الملفات داخل المجلد تلقائياً",
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          if (estimatedCount > 0) ...[
            SizedBox(height: 8),
            Text(
              "عدد الملفات التقريبي: $estimatedCount",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ]
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text("إلغاء"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text("نعم، رفع المجلد"),
        ),
      ],
    ),
  ) ?? false;
}

// 🔥 دالة لتقدير عدد الملفات
Future<int> _estimateFileCount(String directoryPath) async {
  int count = 0;
  try {
    final directory = Directory(directoryPath);
    await for (FileSystemEntity entity in directory.list(recursive: true)) {
      if (entity is File) count++;
    }
  } catch (e) {
    print('⚠️ Error estimating file count: $e');
  }
  return count;
}
 
 
  // رفع ملف واحد أو عدة ملفات - لجميع المنصات
  Future<void> _uploadFilesOrSingle() async {
    if (_token == null) {
      _showSnackBar('⚠️ سجل دخول أولاً', isError: true);
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result == null || result.files.isEmpty) return;

      final files = result.paths.map((path) => File(path!)).toList();
      final fileController = Provider.of<FileController>(context, listen: false);

      if (files.length == 1) {
        bool success = await fileController.uploadSingleFile(file: files[0], token: _token!);
        _showSnackBar(
          success ? S.of(context).upload_success : fileController.errorMessage ?? 'فشل رفع الملف', 
          isError: !success
        );
      } else {
        final response = await fileController.uploadMultipleFiles(files: files, token: _token!);
        if (response['files'] != null && (response['files'] as List).isNotEmpty) {
          _showSnackBar('✅ تم رفع ${files.length} ملف بنجاح');
        } else {
          _showSnackBar(
            fileController.errorMessage ?? response['message'] ?? 'فشل رفع الملفات', 
            isError: true
          );
        }
      }
    } catch (e) {
      _showSnackBar('❌ خطأ في رفع الملفات: ${e.toString()}', isError: true);
    }
  }

  // إنشاء مجلد جديد - لجميع المنصات
  Future<void> _createNewFolder() async {
    if (_token == null) return;
    
    final folderNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("إنشاء مجلد جديد"),
        content: TextField(
          controller: folderNameController,
          decoration: InputDecoration(
            hintText: "أدخل اسم المجلد", 
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.create_new_folder),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), 
            child: Text("إلغاء")
          ),
          ElevatedButton(
            onPressed: () async {
              final folderName = folderNameController.text.trim();
              if (folderName.isEmpty) {
                _showSnackBar('⚠️ الرجاء إدخال اسم المجلد', isError: true);
                return;
              }

              Navigator.pop(dialogContext);
              final folderController = Provider.of<FolderController>(context, listen: false);
              final success = await folderController.createFolder(name: folderName);

              _showSnackBar(
                success ? '📁 تم إنشاء المجلد "$folderName" بنجاح' : '❌ ${folderController.errorMessage ?? "فشل إنشاء المجلد"}',
                isError: !success,
              );
            },
            child: Text("إنشاء"),
          ),
        ],
      ),
    );
  }

  // 🔥 خيارات الرفع - مفصولة حسب النظام
  Future<void> _showUploadOptions() async {
    if (_token == null) {
      _showSnackBar('⚠️ سجل دخول أولاً', isError: true);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              Text(
                'اختر طريقة الرفع', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              SizedBox(height: 16),
              
              // 🔥 خيارات Android فقط
              if (Platform.isAndroid) _buildAndroidOptions(),
              
              // 🔥 خيارات iOS فقط
              if (Platform.isIOS) _buildIOSOptions(),
              
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 خيارات Android
  Widget _buildAndroidOptions() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.folder, color: Colors.blue),
          title: Text("رفع مجلد"),
          subtitle: Text("اختر اسم المجلد ثم اختر الملفات"),
          onTap: () {
            Navigator.pop(context);
            _uploadFolderAndroid();
          },
        ),
        Divider(height: 1),
        ListTile(
          leading: Icon(Icons.file_copy, color: Colors.green),
          title: Text("رفع ملفات متعددة"),
          subtitle: Text("اختر عدة ملفات منفردة"),
          onTap: () {
            Navigator.pop(context);
            _uploadFilesOrSingle();
          },
        ),
        Divider(height: 1),
        ListTile(
          leading: Icon(Icons.create_new_folder, color: Colors.orange),
          title: Text("إنشاء مجلد جديد"),
          subtitle: Text("إنشاء مجلد فارغ"),
          onTap: () {
            Navigator.pop(context);
            _createNewFolder();
          },
        ),
      ],
    );
  }

  // 🔥 خيارات iOS
  Widget _buildIOSOptions() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.file_copy, color: Colors.green),
          title: Text("رفع ملفات"),
          subtitle: Text("اختر ملف واحد أو عدة ملفات"),
          onTap: () {
            Navigator.pop(context);
            _uploadFilesOrSingle();
          },
        ),
        Divider(height: 1),
        ListTile(
          leading: Icon(Icons.create_new_folder, color: Colors.orange),
          title: Text("إنشاء مجلد جديد"),
          subtitle: Text("إنشاء مجلد فارغ"),
          onTap: () {
            Navigator.pop(context);
            _createNewFolder();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        extendBody: true,
        body: _pages[selected],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Consumer<FileController>(
          builder: (context, fileController, child) => Container(
            margin: EdgeInsets.only(bottom: 10),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFF4D62D5), Color(0xFF28336F)]),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3), 
                  blurRadius: 8, 
                  offset: Offset(0, 4)
                )
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: fileController.isLoading ? null : _showUploadOptions,
                borderRadius: BorderRadius.circular(30),
                child: fileController.isLoading
                    ? Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          color: Colors.white, 
                          strokeWidth: 2
                        ),
                      )
                    : Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),
          ),
        ),
        bottomNavigationBar: SizedBox(
          height: 80,
          child: MyBottomBar(
            selectedIndex: selected,
            onTap: (index) => setState(() => selected = index),
          ),
        ),
      ),
    );
  }
}