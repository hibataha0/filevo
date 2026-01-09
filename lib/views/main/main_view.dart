import 'dart:io';
import 'dart:async'; // ✅ للـ TimeoutException
import 'package:file_picker/file_picker.dart';
import 'package:filevo/components/NavigationBar .dart';
import 'package:filevo/components/folder_selection_dialog.dart';
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
import 'package:path_provider/path_provider.dart';
import 'package:filevo/utils/file_security.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selected = 0;
  String? _token;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadToken();
    _pages = [
      HomeView(
        onNavigateToFolders: () {
          setState(() {
            selected = 1; // ✅ تغيير إلى صفحة الفولدرات
          });
        },
      ),
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

  // ✅ رفع مجلد - اختيار اسم المجلد و الملفات أولاً ثم اختيار المجلد الهدف
  Future<void> _uploadFolderAndroid() async {
    if (_token == null) {
      _showSnackBar(S.of(context).loginFirst, isError: true);
      return;
    }

    try {
      // ✅ 1. طلب اسم المجلد أولاً
      final folderNameController = TextEditingController();
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(S.of(context).CreateFolder),
          content: TextField(
            controller: folderNameController,
            decoration: InputDecoration(
              hintText: S.of(context).folderNameHint,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.folder),
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
              child: Text(S.of(context).cancel),
            ),
            TextButton(
              onPressed: () {
                if (folderNameController.text.trim().isNotEmpty) {
                  Navigator.pop(context, true);
                }
              },
              child: Text(S.of(context).next),
            ),
          ],
        ),
      );

      final folderName = shouldProceed == true
          ? folderNameController.text.trim()
          : '';
      await Future.delayed(const Duration(milliseconds: 100));
      folderNameController.dispose();

      if (shouldProceed != true || folderName.isEmpty) {
        if (shouldProceed == true && folderName.isEmpty) {
          _showSnackBar(S.of(context).folderNameRequired, isError: true);
        }
        return;
      }

      if (await _requestStoragePermissions()) {
        print('✅ Storage permissions granted');
      }

      // ✅ 3. اختيار ملفات متعددة
      _showSnackBar(S.of(context).folderUploadStart);

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result == null || result.files.isEmpty) return;

      // 🔐 Security: التحقق من الملفات الخطيرة
      final fileNames = result.files.map((f) => f.name).toList();
      final dangerousFiles = getDangerousFiles(fileNames);

      if (dangerousFiles.isNotEmpty) {
        final proceedSecurity = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(S.of(context).securityWarning),
            content: Text(
              S.of(context).dangerousFilesDetected(dangerousFiles.join('\n')),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(S.of(context).cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(S.of(context).next),
              ),
            ],
          ),
        );
        if (proceedSecurity != true) return;
      }

      _showSnackBar(S.of(context).readingFiles);

      List<Map<String, dynamic>> filesData = [];
      List<String> relativePaths = [];

      for (var platformFile in result.files) {
        try {
          List<int> bytes;
          String fileName = platformFile.name;
          String safeFileName = fileName;

          if (platformFile.path != null) {
            final file = File(platformFile.path!);
            if (await file.exists()) {
              if (isDangerousExtension(fileName)) {
                _showSnackBar(S.of(context).convertingDangerousFile(fileName));
                final convertedFile = await convertDangerousFileToText(
                  originalFile: file,
                  originalFileName: fileName,
                );
                bytes = await convertedFile.readAsBytes();
                safeFileName = convertToSafeTextFile(fileName);
              } else {
                bytes = await file.readAsBytes();
              }
            } else {
              continue;
            }
          } else if (platformFile.bytes != null) {
            bytes = platformFile.bytes!;
            if (isDangerousExtension(fileName)) {
              _showSnackBar(S.of(context).convertingDangerousFile(fileName));
              final tempDir = await getTemporaryDirectory();
              final tempFile = File('${tempDir.path}/temp_$fileName');
              await tempFile.writeAsBytes(bytes);
              final convertedFile = await convertDangerousFileToText(
                originalFile: tempFile,
                originalFileName: fileName,
              );
              bytes = await convertedFile.readAsBytes();
              safeFileName = convertToSafeTextFile(fileName);
              await tempFile.delete();
            }
          } else {
            continue;
          }

          filesData.add({'bytes': bytes, 'fileName': safeFileName});
          relativePaths.add(safeFileName);
        } catch (e) {
          print('❌ Error reading file: $e');
        }
      }

      if (filesData.isEmpty) {
        _showSnackBar(S.of(context).cannotReadFiles, isError: true);
        return;
      }

      // ✅ 4. اختيار المجلد الهدف
      final selectedFolderId = await showModalBottomSheet<String?>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (modalContext) => FolderSelectionDialog(
          title: S.of(context).selectTargetFolder,
          onSelect: (folderId) {},
        ),
      ).then((value) => value ?? 'CANCELLED');

      if (selectedFolderId == 'CANCELLED') return;

      final folderController = Provider.of<FolderController>(
        context,
        listen: false,
      );
      _showSnackBar(
        S.of(context).uploadingFolder(folderName, filesData.length),
      );

      final parentFolderId = selectedFolderId == 'ROOT'
          ? null
          : selectedFolderId;

      final response = await folderController.uploadFolder(
        folderName: folderName,
        filesData: filesData,
        relativePaths: relativePaths,
        parentFolderId: parentFolderId,
      );

      if (response != null && response['folder'] != null) {
        _showSnackBar(
          S.of(context).uploadFolderSuccess(folderName, filesData.length),
        );
      } else {
        final errorMsg =
            response?['message'] ??
            response?['error'] ??
            folderController.errorMessage ??
            S.of(context).uploadFolderFailed;
        _showSnackBar('❌ $errorMsg', isError: true);
      }
    } catch (e) {
      _showSnackBar(
        S.of(context).errorUploadingFolder(e.toString()),
        isError: true,
      );
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
        _showSnackBar(S.of(context).storagePermissionRequired, isError: true);
        await openAppSettings();
        return false;
      }
    }
    return false;
  }

  // ✅ دالة محسنة لقراءة محتويات المجلد مع دعم SAF الكامل
  Future<(List<File>, List<String>, int)> _readFolderContentsWithSAF(
    String directoryPath,
  ) async {
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
      bool isAndroid11Plus =
          Platform.isAndroid &&
          effectivePath.startsWith('/storage/emulated/0/');

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
                  final relativePath = p.relative(
                    entity.path,
                    from: effectivePath,
                  );
                  relativePaths.add(relativePath);
                  fileCount++;

                  print(
                    '✅ Added (listSync): ${p.basename(entity.path)} (${stat.size} bytes)',
                  );
                } catch (e) {
                  print('⚠️ Cannot open file (listSync): ${entity.path} - $e');
                  // ✅ محاولة إضافته رغم ذلك
                  try {
                    files.add(file);
                    final relativePath = p.relative(
                      entity.path,
                      from: effectivePath,
                    );
                    relativePaths.add(relativePath);
                    fileCount++;
                  } catch (e2) {
                    print('❌ Failed to add file: ${entity.path}');
                  }
                }
              } catch (e) {
                print(
                  '⚠️ Error processing file (listSync): ${entity.path} - $e',
                );
                continue;
              }
            }
          }

          if (fileCount > 0) {
            print(
              '✅ Successfully read $fileCount files using listSync on Android 11+',
            );
            return (files, relativePaths, fileCount);
          }
        } catch (e) {
          print(
            '⚠️ listSync failed on Android 11+: $e - Trying async method...',
          );
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
                await testRead.first.timeout(const Duration(seconds: 1));

                files.add(file);
                final relativePath = p.relative(
                  entity.path,
                  from: effectivePath,
                );
                relativePaths.add(relativePath);
                fileCount++;

                print(
                  '✅ Added: ${p.basename(entity.path)} (${stat.size} bytes)',
                );
              } catch (e) {
                print('⚠️ Cannot read file: ${entity.path} - $e');
                // ✅ محاولة إضافة الملف رغم ذلك (قد يعمل لاحقاً)
                try {
                  files.add(file);
                  final relativePath = p.relative(
                    entity.path,
                    from: effectivePath,
                  );
                  relativePaths.add(relativePath);
                  fileCount++;
                  print(
                    '⚠️ Added without verification: ${p.basename(entity.path)}',
                  );
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
            print(
              '🔄 Found ${entities.length} entities using listSync (fallback)',
            );

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
                    final relativePath = p.relative(
                      entity.path,
                      from: effectivePath,
                    );
                    relativePaths.add(relativePath);
                    fileCount++;

                    print(
                      '✅ Added (sync fallback): ${p.basename(entity.path)} (${stat.size} bytes)',
                    );
                  } catch (e) {
                    print(
                      '⚠️ Cannot open file (sync fallback): ${entity.path} - $e',
                    );
                    // ✅ محاولة إضافته رغم ذلك
                    try {
                      files.add(file);
                      final relativePath = p.relative(
                        entity.path,
                        from: effectivePath,
                      );
                      relativePaths.add(relativePath);
                      fileCount++;
                    } catch (e2) {
                      print('❌ Failed to add file: ${entity.path}');
                    }
                  }
                } catch (e) {
                  print(
                    '⚠️ Error processing file (sync fallback): ${entity.path} - $e',
                  );
                  continue;
                }
              }
            }

            if (fileCount > 0) {
              print(
                '✅ Successfully read $fileCount files using listSync (fallback)',
              );
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
          '4. جرب مجلد من مجلد التطبيق الخاص بك أو مجلدات متاحة أخرى',
        );
      }
    } catch (e) {
      print('❌ Error reading folder contents: $e');
      rethrow;
    }

    return (files, relativePaths, fileCount);
  }

  // 🔥 دالة لعرض تأكيد رفع المجلد
  Future<bool> _showFolderConfirmationDialog(
    String directoryPath,
    String folderName,
  ) async {
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
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
        ) ??
        false;
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
      _showSnackBar(S.of(context).loginFirst, isError: true);
      return;
    }

    try {
      // ✅ 1. اختيار الملفات أولاً
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result == null || result.files.isEmpty) return;

      // 🔐 Security: Check for dangerous files
      final selectedFileNames = result.files.map((f) => f.name).toList();
      final dangerousFiles = getDangerousFiles(selectedFileNames);

      if (dangerousFiles.isNotEmpty) {
        // Show warning dialog
        final shouldProceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(S.of(context).securityWarning),
            content: Text(
              S.of(context).dangerousFilesDetected(dangerousFiles.join('\n')),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(S.of(context).cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(S.of(context).continuee),
              ),
            ],
          ),
        );

        if (shouldProceed != true) {
          return;
        }
      }

      // ✅ 2. قراءة الملفات فوراً وتحويلها إلى bytes (قبل اختيار المجلد)
      // ✅ هذا مهم لأن الملفات المؤقتة من FilePicker قد تُحذف أثناء اختيار المجلد
      _showSnackBar(S.of(context).readingFiles);

      List<File> tempFiles = [];
      List<String> fileNames = [];

      final tempDir = await getTemporaryDirectory();

      for (var platformFile in result.files) {
        try {
          List<int> bytes;
          String fileName = platformFile.name;
          String safeFileName = fileName;

          // ✅ محاولة قراءة من path أولاً
          if (platformFile.path != null) {
            final file = File(platformFile.path!);
            if (await file.exists()) {
              // 🔐 Security: Convert dangerous files to text
              if (isDangerousExtension(fileName)) {
                _showSnackBar(S.of(context).convertingDangerousFile(fileName));
                final convertedFile = await convertDangerousFileToText(
                  originalFile: file,
                  originalFileName: fileName,
                );
                bytes = await convertedFile.readAsBytes();
                safeFileName = convertToSafeTextFile(fileName);
                print(
                  '🔐 Converted dangerous file: $fileName -> $safeFileName',
                );
              } else {
                bytes = await file.readAsBytes();
              }
              print(
                '✅ Read file from path: $safeFileName (${bytes.length} bytes)',
              );
            } else {
              // ✅ إذا لم يكن الملف موجوداً، حاول من bytes
              if (platformFile.bytes != null) {
                bytes = platformFile.bytes!;

                // 🔐 Security: Convert dangerous files to text
                if (isDangerousExtension(fileName)) {
                  _showSnackBar(
                    S.of(context).convertingDangerousFile(fileName),
                  );
                  final tempFileForConversion = File(
                    '${tempDir.path}/temp_conv_$fileName',
                  );
                  await tempFileForConversion.writeAsBytes(bytes);
                  final convertedFile = await convertDangerousFileToText(
                    originalFile: tempFileForConversion,
                    originalFileName: fileName,
                  );
                  bytes = await convertedFile.readAsBytes();
                  safeFileName = convertToSafeTextFile(fileName);
                  await tempFileForConversion.delete(); // Clean up
                  print(
                    '🔐 Converted dangerous file: $fileName -> $safeFileName',
                  );
                }

                print(
                  '✅ Read file from bytes: $safeFileName (${bytes.length} bytes)',
                );
              } else {
                print('⚠️ No file data available for: $fileName');
                continue;
              }
            }
          } else if (platformFile.bytes != null) {
            // ✅ إذا كان الملف في الذاكرة (مثل اختيار من Google Drive)
            bytes = platformFile.bytes!;

            // 🔐 Security: Convert dangerous files to text
            if (isDangerousExtension(fileName)) {
              _showSnackBar(S.of(context).convertingDangerousFile(fileName));
              final tempFileForConversion = File(
                '${tempDir.path}/temp_conv_$fileName',
              );
              await tempFileForConversion.writeAsBytes(bytes);
              final convertedFile = await convertDangerousFileToText(
                originalFile: tempFileForConversion,
                originalFileName: fileName,
              );
              bytes = await convertedFile.readAsBytes();
              safeFileName = convertToSafeTextFile(fileName);
              await tempFileForConversion.delete(); // Clean up
              print('🔐 Converted dangerous file: $fileName -> $safeFileName');
            }

            print(
              '✅ Read file from memory: $safeFileName (${bytes.length} bytes)',
            );
          } else {
            print('⚠️ No file data available for: $fileName');
            continue;
          }

          // ✅ حفظ الملف في مجلد مؤقت آمن (باستخدام الاسم الآمن)
          final tempFile = File(
            '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_$safeFileName',
          );
          await tempFile.writeAsBytes(bytes);
          tempFiles.add(tempFile);
          fileNames.add(safeFileName);
        } catch (e) {
          print('❌ Error reading file ${platformFile.name}: $e');
        }
      }

      if (tempFiles.isEmpty) {
        _showSnackBar(S.of(context).cannotReadFiles, isError: true);
        return;
      }

      print('✅ Successfully saved ${tempFiles.length} files to temp directory');

      // ✅ 3. اختيار المجلد الهدف
      final selectedFolderId =
          await showModalBottomSheet<String?>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (modalContext) => FolderSelectionDialog(
              title: S.of(context).selectTargetFolder,
              onSelect: (folderId) {
                // ✅ لا نحتاج لإغلاق الـ dialog هنا - FolderSelectionDialog يقوم بذلك
                // ✅ هذا callback يمكن استخدامه لأغراض أخرى إذا لزم الأمر
              },
            ),
          ).then((value) {
            // ✅ إذا ألغى المستخدم (null)، نعيد 'CANCELLED'
            if (value == null) return 'CANCELLED';
            return value;
          });

      // ✅ إذا ألغى المستخدم، حذف الملفات المؤقتة
      if (selectedFolderId == 'CANCELLED') {
        for (var tempFile in tempFiles) {
          try {
            if (await tempFile.exists()) {
              await tempFile.delete();
            }
          } catch (e) {
            print('⚠️ Error deleting temp file: $e');
          }
        }
        return;
      }

      final fileController = Provider.of<FileController>(
        context,
        listen: false,
      );

      Future<T?> _showProgressDialog<T>({
        required String title,
        required Future<T> Function(void Function(int, int) onProgress) action,
      }) {
        return showDialog<T>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            double progressValue = 0;
            bool started = false;

            return StatefulBuilder(
              builder: (ctx, setState) {
                if (!started) {
                  started = true;
                  Future(() async {
                    try {
                      final result = await action((sent, total) {
                        if (total > 0) {
                          setState(() {
                            progressValue = sent / total;
                          });
                        }
                      });
                      if (Navigator.of(dialogContext).canPop()) {
                        Navigator.of(dialogContext).pop(result);
                      }
                    } catch (e) {
                      if (Navigator.of(dialogContext).canPop()) {
                        Navigator.of(dialogContext).pop(null);
                      }
                      rethrow;
                    }
                  });
                }

                final percent = (progressValue * 100)
                    .clamp(0, 100)
                    .toStringAsFixed(0);

                return AlertDialog(
                  title: Text(title),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LinearProgressIndicator(
                        value: progressValue > 0 ? progressValue : null,
                      ),
                      const SizedBox(height: 12),
                      Text('$percent%'),
                    ],
                  ),
                );
              },
            );
          },
        );
      }

      // ✅ استخدام selectedFolderId ('ROOT' = الجذر = null)
      print('📁 MainView: Selected folder ID: $selectedFolderId');
      final parentFolderId = selectedFolderId == 'ROOT'
          ? null
          : selectedFolderId;
      print('📁 MainView: Parent folder ID for upload: $parentFolderId');

      // ✅ 4. رفع الملفات من الملفات المؤقتة
      try {
        if (tempFiles.length == 1) {
          bool success =
              await _showProgressDialog<bool>(
                title: S.of(context).uploadingMultipleFiles,
                action: (onProgress) => fileController.uploadSingleFile(
                  file: tempFiles[0],
                  token: _token!,
                  parentFolderId: parentFolderId,
                  onSendProgress: onProgress,
                ),
              ) ??
              false;
          // ✅ التحقق من خطأ المساحة التخزينية
          if (!success && fileController.errorMessage != null) {
            final errorMsg = fileController.errorMessage!;
            if (errorMsg.toLowerCase().contains('storage') || 
                errorMsg.toLowerCase().contains('مساحة')) {
              _showSnackBar(errorMsg, isError: true);
            } else {
              _showSnackBar(
                success
                    ? S.of(context).upload_success
                    : fileController.errorMessage ?? S.of(context).uploadFailed,
                isError: !success,
              );
            }
          } else {
            _showSnackBar(
              success
                  ? S.of(context).upload_success
                  : fileController.errorMessage ?? S.of(context).uploadFailed,
              isError: !success,
            );
          }
        } else {
          final response =
              await _showProgressDialog<Map<String, dynamic>>(
                title: S.of(context).uploadingMultipleFiles,
                action: (onProgress) => fileController.uploadMultipleFiles(
                  files: tempFiles,
                  token: _token!,
                  parentFolderId: parentFolderId,
                  onSendProgress: onProgress,
                ),
              ) ??
              {};
          if (response['files'] != null &&
              (response['files'] as List).isNotEmpty) {
            final uploadedCount = (response['files'] as List).length;
            final errors = (response['errors'] as List?) ?? [];
            final errorsCount = errors.length;

            _showSnackBar(
              errorsCount > 0
                  ? S
                        .of(context)
                        .uploadSuccessWithErrors(uploadedCount, errorsCount)
                  : S.of(context).uploadSuccessCount(uploadedCount),
            );

            if (errorsCount > 0) {
              final errorNames = errors
                  .map((e) {
                    if (e is Map && e['filename'] != null) {
                      return e['filename'].toString();
                    }
                    return e is Map && e['error'] != null
                        ? e['error'].toString()
                        : e.toString();
                  })
                  .where((name) => name.isNotEmpty)
                  .take(3)
                  .join(', ');

              final errorMessage = errorNames.isNotEmpty
                  ? S
                        .of(context)
                        .allFilesRejectedVirus(
                          errorNames,
                        ) // تمرير أسماء الملفات كمتغير
                  : S.of(context).someFilesRejectedVirus;

              _showSnackBar(errorMessage, isError: true);
            }
          } else {
            final errors = (response['errors'] as List?) ?? [];
            if (errors.isNotEmpty) {
              final errorNames = errors
                  .map((e) {
                    if (e is Map && e['filename'] != null) {
                      return e['filename'].toString();
                    }
                    return e is Map && e['error'] != null
                        ? e['error'].toString()
                        : e.toString();
                  })
                  .where((name) => name.isNotEmpty)
                  .take(3)
                  .join(', ');

              final errorMessage = errorNames.isNotEmpty
                  ? S
                        .of(context)
                        .allFilesRejectedVirus(
                          errorNames,
                        ) // تمرير أسماء الملفات كمتغير
                  : S.of(context).someFilesRejectedVirus;

              _showSnackBar(errorMessage, isError: true);
            } else {
              // ✅ التحقق من خطأ المساحة التخزينية
              if (response['storageLimitExceeded'] == true) {
                final storageMsg = response['message'] ?? 
                    'تم الوصول للحد الأقصى من المساحة التخزينية (10 GB). يرجى حذف بعض الملفات أو شراء مساحة إضافية';
                _showSnackBar(storageMsg, isError: true);
              } else {
                _showSnackBar(
                  fileController.errorMessage ??
                      response['message'] ??
                      S.of(context).uploadFailed,
                  isError: true,
                );
              }
            }
          }
        }
      } finally {
        // ✅ حذف الملفات المؤقتة بعد الرفع
        for (var tempFile in tempFiles) {
          try {
            if (await tempFile.exists()) {
              await tempFile.delete();
            }
          } catch (e) {
            print('⚠️ Error deleting temp file: $e');
          }
        }
      }
    } catch (e) {
      _showSnackBar(S.of(context).uploadFailed, isError: true);
    }
  }

  // إنشاء مجلد جديد - لجميع المنصات مع دعم الترجمة
  Future<void> _createNewFolder() async {
    if (_token == null) return;

    final folderNameController = TextEditingController();

    // ✅ 1. إدخال اسم المجلد أولاً
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).createNewFolder),
        content: TextField(
          controller: folderNameController,
          decoration: InputDecoration(
            hintText: S.of(context).folderNameHint,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.create_new_folder),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (folderNameController.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: Text(S.of(context).next),
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
        _showSnackBar(S.of(context).folderNameRequired, isError: true);
      }
      return;
    }

    // ✅ 2. اختيار المجلد الهدف
    final selectedFolderId =
        await showModalBottomSheet<String?>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (modalContext) => FolderSelectionDialog(
            title: S.of(context).selectTargetFolder,
            onSelect: (folderId) {
              // FolderSelectionDialog يقوم بالإغلاق تلقائياً
            },
          ),
        ).then((value) {
          if (value == null) return 'CANCELLED';
          return value;
        });

    // ✅ إذا ألغى المستخدم، لا نفعل شيئاً
    if (selectedFolderId == 'CANCELLED') {
      return;
    }

    final folderController = Provider.of<FolderController>(
      context,
      listen: false,
    );

    // ✅ استخدام selectedFolderId ('ROOT' = الجذر = null)
    final parentId = selectedFolderId == 'ROOT' ? null : selectedFolderId;

    final success = await folderController.createFolder(
      name: folderName,
      parentId: parentId,
    );

    if (success) {
      _showSnackBar(S.of(context).folderCreatedSuccess(folderName));
    } else {
      final errorMsg = folderController.errorMessage ?? "";
      _showSnackBar(S.of(context).folderCreateFailed(errorMsg), isError: true);
    }
  }

  // 🔥 خيارات الرفع - مفصولة حسب النظام
  Future<void> _showUploadOptions() async {
    if (_token == null) {
      _showSnackBar(S.of(context).mustLoginFirst, isError: true);
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
                S.of(context).uploadOptions,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  // 🔥 خيارات Android المترجمة
  Widget _buildAndroidOptions() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.folder, color: Colors.blue),
          title: Text(S.of(context).uploadFolder),
          subtitle: Text(S.of(context).uploadFolderSubtitle),
          onTap: () {
            Navigator.pop(context);
            _uploadFolderAndroid();
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.file_copy, color: Colors.green),
          title: Text(S.of(context).uploadMultipleFiles),
          subtitle: Text(S.of(context).uploadMultipleFilesSubtitle),
          onTap: () {
            Navigator.pop(context);
            _uploadFilesOrSingle();
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.create_new_folder, color: Colors.orange),
          title: Text(S.of(context).createNewFolder),
          subtitle: Text(S.of(context).createEmptyFolderSubtitle),
          onTap: () {
            Navigator.pop(context);
            _createNewFolder();
          },
        ),
      ],
    );
  }

  /// 🔥 خيارات iOS المترجمة
  Widget _buildIOSOptions() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.file_copy, color: Colors.green),
          title: Text(S.of(context).uploadFiles),
          subtitle: Text(S.of(context).uploadFilesSubtitle),
          onTap: () {
            Navigator.pop(context);
            _uploadFilesOrSingle();
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.create_new_folder, color: Colors.orange),
          title: Text(S.of(context).createNewFolder),
          subtitle: Text(S.of(context).createEmptyFolderSubtitle),
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
      child: Builder(
        builder: (builderContext) {
          // ✅ التحقق من وجود route مفتوح (صفحة مفتوحة فوق MainPage)
          // ✅ استخدام Navigator.canPop للتحقق من وجود route مفتوح
          final canPop = Navigator.of(
            builderContext,
            rootNavigator: false,
          ).canPop();
          // ✅ إخفاء FloatingActionButton إذا كان هناك route مفتوح
          final shouldShowFAB = !canPop;

          return Scaffold(
            extendBody: true,
            body: _pages[selected],
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: shouldShowFAB
                ? Consumer<FileController>(
                    builder: (context, fileController, child) => Container(
                      margin: EdgeInsets.only(bottom: 10),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF4D62D5), Color(0xFF28336F)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: fileController.isLoading
                              ? null
                              : _showUploadOptions,
                          borderRadius: BorderRadius.circular(30),
                          child: fileController.isLoading
                              ? Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(Icons.add, color: Colors.white, size: 30),
                        ),
                      ),
                    ),
                  )
                : null, // ✅ إخفاء FloatingActionButton عند وجود route مفتوح
            bottomNavigationBar: SizedBox(
              height: 80,
              child: MyBottomBar(
                selectedIndex: selected,
                onTap: (index) => setState(() => selected = index),
              ),
            ),
          );
        },
      ),
    );
  }
}
