// import 'dart:io';
// import 'package:saf/saf.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as path;
// import 'package:flutter/services.dart';

// class SAF {
//   static const MethodChannel _channel = MethodChannel('com.example.filevo/saf');
  
//   /// فتح Folder Picker والحصول على الصلاحيات
//   static Future<String?> openFolderPicker() async {
//   try {
//     print("📁 Opening SAF folder picker...");

//     // ----- 1) المجلدات قبل اختيار المستخدم -----
//     List<String>? before = await Saf.getPersistedPermissionDirectories();
//     before ??= [];
//     print("ℹ️ Persisted BEFORE: $before");

//     // ----- 2) فتح picker (ما برجع path، بس بضيف إذن جديد إذا المستخدم اختر مجلد) -----
//     bool? granted = await Saf.getDynamicDirectoryPermission();
//     print("ℹ️ Permission result: $granted");

//     if (granted != true) {
//       print("❌ User cancelled or permission denied.");
//       return null;
//     }

//     // ----- 3) المجلدات بعد اختيار المستخدم -----
//     List<String>? after = await Saf.getPersistedPermissionDirectories();
//     after ??= [];
//     print("ℹ️ Persisted AFTER:  $after");

//     // ----- 4) مقارنة قبل/بعد لاكتشاف المجلد الجديد -----
//     List<String> newDirs =
//         after.where((folder) => !(before?.contains(folder) ?? false)).toList();

//     if (newDirs.isNotEmpty) {
//       print("✅ NEW folder detected: ${newDirs.first}");
//       return newDirs.first;
//     }

//     // ----- 5) لو ما ظهر مجلد جديد → معناها Android ما حدث القائمة -----
//     // نستخدم آخر مجلد لأنه آخر إذن فعليّ
//     if (after.isNotEmpty) {
//       print("⚠️ No new folder detected, using last: ${after.last}");
//       return after.last;
//     }

//     print("❌ No directories found at all");
//     return null;
//   } catch (e) {
//     print("❌ Error in openFolderPicker: $e");
//     return null;
//   }
// }

//   /// قراءة جميع الملفات من المجلد
//   /// ترجع: (List<FileData>, List<String> relativePaths, int count)
//   /// حيث FileData يحتوي على bytes واسم الملف
//   static Future<(List<FileData>, List<String>, int)> loadFiles(String folderPath) async {
//     try {
//       print("📁 Loading files from SAF $folderPath");
      
//       // ✅ استخدام package saf للحصول على الملفات
//       List<String>? filePaths = await Saf.getFilesPathFor(
//         folderPath,
//         fileType: "any", // جميع أنواع الملفات
//       );
//       print("ℹ️ Found ${filePaths?.length ?? 0} files in folder");
      
//       if (filePaths == null || filePaths.isEmpty) {
//         print("⚠️ No files found in folder");
//         return (<FileData>[], <String>[], 0);
//       }
      
//       print("📄 Found ${filePaths.length} files, reading content...");
      
//       // ✅ استخدام Saf instance لقراءة الملفات
//       final saf = Saf(folderPath);
//       bool? hasPermission = await saf.getDirectoryPermission(isDynamic: false);
      
//       print("ℹ️ Has permission: $hasPermission");
      
//       // ✅ محاولة cache و sync الملفات
//       List<String>? cachedPaths;
      
//       if (hasPermission == true) {
//         try {
//           // ✅ محاولة cache الملفات
//           // cache() قد ترجع List<String>? أو bool? حسب implementation
//           var cacheResult = await saf.cache();
//           print("ℹ️ Cache result type: ${cacheResult.runtimeType}");
//           print("ℹ️ Cache result: $cacheResult");
          
//           // ✅ التحقق من نوع النتيجة
//           if (cacheResult is List) {
//             // إذا كانت النتيجة List مباشرة، استخدمها كـ cached paths
//             cachedPaths = (cacheResult as List).cast<String>();
//             print("✅ Cache returned paths directly, count: ${cachedPaths.length}");
//           } else if (cacheResult == true) {
//             // إذا كانت bool? و true، احصل على المسارات المكشوفة
//             print("✅ Cache operation succeeded (bool)");
            
//             // ✅ محاولة sync الملفات (اختياري لكن قد يساعد)
//             try {
//               var syncResult = await saf.sync();
//               print("ℹ️ Sync result: $syncResult");
//             } catch (e) {
//               print("⚠️ Sync failed (not critical): $e");
//             }
            
//             // ✅ الحصول على المسارات المكشوفة بعد cache
//             try {
//               cachedPaths = await saf.getCachedFilesPath();
//               print("✅ Got cached paths, count: ${cachedPaths?.length ?? 0}");
//             } catch (e) {
//               print("⚠️ Failed to get cached paths: $e");
//             }
//           } else {
//             print("⚠️ Cache operation returned false or null");
//             print("⚠️ Cache may have failed");
//           }
          
//           if (cachedPaths != null && cachedPaths.isNotEmpty) {
//             print("📂 All cached paths:");
//             for (int i = 0; i < cachedPaths.length; i++) {
//               print("   ${i + 1}. ${cachedPaths[i]}");
//             }
//           } else {
//             print("⚠️ No cached paths available after cache operation");
//           }
//         } catch (e) {
//           print("⚠️ Cache operation threw exception: $e");
//         }
//       } else {
//         print("⚠️ No permission granted, cannot cache files");
//       }
      
//       // ✅ محاولة استخدام native code لقراءة الملفات من SAF URI مباشرة
//       // نحتاج للحصول على SAF URI الفعلي من persisted permissions
//       try {
//         print("🔄 Attempting to read files using native code...");
        
//         // ✅ الحصول على SAF URI من persisted permissions
//         List<String>? persistedDirs = await Saf.getPersistedPermissionDirectories();
//         String? safUri;
        
//         if (persistedDirs != null && persistedDirs.isNotEmpty) {
//           // ✅ استخدام آخر مجلد مصرح به (يجب أن يكون نفس folderPath)
//           String lastDir = persistedDirs.last;
//           if (lastDir == folderPath || lastDir.contains(folderPath.split('/').last)) {
//             // ✅ نحتاج لبناء SAF URI من folderPath
//             // لكن package saf لا يعطينا URI مباشرة، لذا سنستخدم folderPath
//             safUri = folderPath;
//           }
//         }
        
//         if (safUri == null) {
//           safUri = folderPath;
//         }
        
//         print("🔄 Calling native code with folderPath: $safUri");
//         final result = await _channel.invokeMethod<Map>('readFilesFromSAF', {
//           'folderPath': safUri,
//         });
        
//         if (result != null && result['files'] != null) {
//           List<dynamic> fileBytesList = result['files'];
//           List<String> fileNames = List<String>.from(result['fileNames'] ?? []);
//           List<String> relativePathsFromNative = List<String>.from(result['relativePaths'] ?? []);
          
//           print("✅ Native code returned ${fileBytesList.length} files");
//           print("✅ Native code returned ${fileNames.length} file names");
//           print("✅ Native code returned ${relativePathsFromNative.length} relative paths");
          
//           final fileDataList = <FileData>[];
//           for (int i = 0; i < fileBytesList.length; i++) {
//             List<int> bytes = List<int>.from(fileBytesList[i]);
//             String fileName = i < fileNames.length ? fileNames[i] : 'file_$i';
            
//             fileDataList.add(FileData(
//               bytes: bytes,
//               fileName: fileName,
//               originalPath: i < filePaths.length ? filePaths[i] : fileName,
//             ));
//             print("✅ Read file from native: $fileName (${bytes.length} bytes)");
//           }
          
//           // ✅ حساب المسارات النسبية بشكل صحيح
//           // يجب أن تطابق عدد الملفات بالضبط
//           String normalizedFolderPath = folderPath.replaceAll(RegExp(r'[/\\]+$'), '');
//           final relativePathsList = <String>[];
          
//           for (int i = 0; i < fileDataList.length; i++) {
//             String relativePath;
            
//             // ✅ إذا كان native code أعطى relativePath صحيح، استخدمه
//             if (i < relativePathsFromNative.length && relativePathsFromNative[i].isNotEmpty) {
//               relativePath = relativePathsFromNative[i];
//             } else if (i < filePaths.length) {
//               // ✅ احسب relativePath من filePath
//               String filePath = filePaths[i];
//               String normalizedPath = filePath.replaceAll(RegExp(r'[/\\]+'), '/');
              
//               if (normalizedPath.startsWith(normalizedFolderPath)) {
//                 relativePath = normalizedPath.substring(normalizedFolderPath.length);
//                 if (relativePath.startsWith('/')) {
//                   relativePath = relativePath.substring(1);
//                 }
//                 if (relativePath.isEmpty) {
//                   relativePath = filePath.split('/').last;
//                 }
//               } else {
//                 relativePath = filePath.split('/').last;
//               }
//             } else {
//               // ✅ Fallback: استخدم اسم الملف
//               relativePath = fileDataList[i].fileName;
//             }
            
//             relativePathsList.add(relativePath);
//             print("📂 Relative path for file ${i + 1}: $relativePath");
//           }
          
//           print("✅ Final relative paths count: ${relativePathsList.length}, files count: ${fileDataList.length}");
          
//           // ✅ التأكد من أن العددين متطابقان
//           if (relativePathsList.length != fileDataList.length) {
//             print("⚠️ WARNING: relativePaths count (${relativePathsList.length}) != files count (${fileDataList.length})");
//             // ✅ إصلاح: إضافة relativePaths ناقصة
//             while (relativePathsList.length < fileDataList.length) {
//               int index = relativePathsList.length;
//               relativePathsList.add(fileDataList[index].fileName);
//             }
//           }
          
//           return (fileDataList, relativePathsList, fileDataList.length);
//         }
//       } catch (e) {
//         print("⚠️ Native code method not available or failed: $e");
//         print("🔄 Falling back to package saf method...");
//       }
      
//       // ✅ Fallback: قراءة محتوى الملفات كـ bytes باستخدام package saf
//       final fileDataList = <FileData>[];
//       for (int i = 0; i < filePaths.length; i++) {
//         String filePath = filePaths[i];
//         String fileName = filePath.split('/').last;
        
//         print("📄 Attempting to read file ${i + 1}/${filePaths.length}: $fileName");
        
//         try {
//           // ✅ محاولة استخدام المسار المكشوف أولاً
//           String? pathToRead;
//           bool useCached = false;
          
//           if (cachedPaths != null && cachedPaths.isNotEmpty) {
//             // ✅ البحث عن الملف المكشوف الذي يطابق اسم الملف
//             try {
//               // ✅ البحث الدقيق أولاً
//               pathToRead = cachedPaths.firstWhere(
//                 (cachedPath) {
//                   String cachedFileName = cachedPath.split('/').last;
//                   return cachedFileName == fileName;
//                 },
//                 orElse: () => '',
//               );
              
//               if (pathToRead.isEmpty) {
//                 // ✅ إذا لم نجد تطابق دقيق، جرب البحث بجزء من الاسم
//                 pathToRead = cachedPaths.firstWhere(
//                   (cachedPath) {
//                     String cachedFileName = cachedPath.split('/').last;
//                     String fileNameWithoutExt = fileName.split('.').first;
//                     String cachedNameWithoutExt = cachedFileName.split('.').first;
//                     return cachedNameWithoutExt == fileNameWithoutExt || 
//                            cachedPath.contains(fileNameWithoutExt);
//                   },
//                   orElse: () => '',
//                 );
//               }
              
//               if (pathToRead.isEmpty && cachedPaths.length == filePaths.length) {
//                 // ✅ إذا كان عدد الملفات المكشوفة يطابق عدد الملفات الأصلية، استخدم الفهرس
//                 if (i < cachedPaths.length) {
//                   pathToRead = cachedPaths[i];
//                   print("📂 Using cached path by index for $fileName: $pathToRead");
//                 }
//               }
              
//               if (pathToRead.isNotEmpty) {
//                 useCached = true;
//                 print("📂 Found cached path for $fileName: $pathToRead");
//               } else {
//                 print("⚠️ Could not find cached path for $fileName, trying original path");
//                 pathToRead = filePath;
//               }
//             } catch (e) {
//               print("⚠️ Error finding cached path for $fileName: $e");
//               pathToRead = filePath;
//             }
//           } else {
//             print("⚠️ No cached paths available");
//             // ✅ محاولة استخدام getFilesPath من saf instance مباشرة
//             try {
//               List<String>? safPaths = await saf.getFilesPath(fileType: "any");
//               if (safPaths != null && safPaths.isNotEmpty && i < safPaths.length) {
//                 pathToRead = safPaths[i];
//                 useCached = true;
//                 print("📂 Using SAF path for $fileName: $pathToRead");
//               } else {
//                 pathToRead = filePath;
//               }
//             } catch (e) {
//               print("⚠️ Failed to get SAF paths: $e");
//               pathToRead = filePath;
//             }
//           }
          
//           // ✅ قراءة الملف من المسار
//           try {
//             final file = File(pathToRead);
//             if (await file.exists()) {
//               print("✅ File exists at: $pathToRead");
//               final bytes = await file.readAsBytes();
//               fileDataList.add(FileData(
//                 bytes: bytes,
//                 fileName: fileName,
//                 originalPath: filePath,
//               ));
//               print("✅ Read file: $fileName (${bytes.length} bytes) from ${useCached ? 'cached/SAF' : 'original'} path");
//             } else {
//               print("⚠️ File does not exist at: $pathToRead");
//               // ✅ إذا فشل كل شيء، جرب نسخ الملف إلى temp directory
//               if (!useCached) {
//                 try {
//                   print("🔄 Attempting to copy file to temp directory...");
//                   final tempDir = await getTemporaryDirectory();
//                   final tempFile = File(path.join(tempDir.path, fileName));
                  
//                   // ✅ محاولة نسخ الملف
//                   final sourceFile = File(filePath);
//                   if (await sourceFile.exists()) {
//                     await sourceFile.copy(tempFile.path);
//                     final bytes = await tempFile.readAsBytes();
//                     fileDataList.add(FileData(
//                       bytes: bytes,
//                       fileName: fileName,
//                       originalPath: filePath,
//                     ));
//                     print("✅ Copied and read file: $fileName (${bytes.length} bytes)");
//                     // ✅ حذف الملف المؤقت بعد القراءة
//                     await tempFile.delete();
//                   }
//                 } catch (copyError) {
//                   print("❌ Failed to copy file to temp: $copyError");
//                 }
//               }
//             }
//           } catch (readError) {
//             print("❌ Failed to read file from $pathToRead: $readError");
//             // ✅ محاولة أخيرة: نسخ إلى temp directory
//             if (pathToRead == filePath) {
//               try {
//                 print("🔄 Last attempt: copying to temp directory...");
//                 final tempDir = await getTemporaryDirectory();
//                 final tempFile = File(path.join(tempDir.path, fileName));
//                 final sourceFile = File(filePath);
//                 if (await sourceFile.exists()) {
//                   await sourceFile.copy(tempFile.path);
//                   final bytes = await tempFile.readAsBytes();
//                   fileDataList.add(FileData(
//                     bytes: bytes,
//                     fileName: fileName,
//                     originalPath: filePath,
//                   ));
//                   print("✅ Successfully copied and read: $fileName (${bytes.length} bytes)");
//                   await tempFile.delete();
//                 }
//               } catch (e) {
//                 print("❌ All attempts failed for $fileName: $e");
//               }
//             }
//           }
//         } catch (e) {
//           print("❌ Failed to read file $fileName: $e");
//           // نستمر مع الملفات الأخرى
//         }
//       }
      
//       // ✅ حساب المسارات النسبية بشكل صحيح
//       // تطبيع مسار المجلد الأساسي (إزالة trailing slash)
//       String normalizedFolderPath = folderPath.replaceAll(RegExp(r'[/\\]+$'), '');
      
//       final relativePaths = filePaths.map((path) {
//         // تطبيع مسار الملف
//         String normalizedPath = path.replaceAll(RegExp(r'[/\\]+'), '/');
        
//         if (normalizedPath.startsWith(normalizedFolderPath)) {
//           // إزالة مسار المجلد الأساسي
//           String relativePath = normalizedPath.substring(normalizedFolderPath.length);
          
//           // إزالة الـ slash الأول إن وجد
//           if (relativePath.startsWith('/')) {
//             relativePath = relativePath.substring(1);
//           }
          
//           // التأكد من أن المسار النسبي ليس فارغاً
//           if (relativePath.isEmpty) {
//             // إذا كان الملف في المجلد الجذر مباشرة
//             return path.split('/').last;
//           }
          
//           return relativePath;
//         }
        
//         // إذا لم يبدأ بمسار المجلد، نأخذ اسم الملف فقط
//         return path.split('/').last;
//       }).toList();
      
//       // ✅ طباعة بعض الأمثلة للمسارات النسبية (للـ debugging)
//       if (relativePaths.isNotEmpty) {
//         print('📂 Sample relative paths:');
//         for (int i = 0; i < (relativePaths.length > 3 ? 3 : relativePaths.length); i++) {
//           print('   ${i + 1}. ${relativePaths[i]}');
//         }
//         if (relativePaths.length > 3) {
//           print('   ... and ${relativePaths.length - 3} more');
//         }
//       }
      
//       final count = fileDataList.length;
//       print("✅ Loaded $count files from folder");
      
//       return (fileDataList, relativePaths, count);
//     } catch (e) {
//       print("❌ Error in loadFiles: $e");
//       return (<FileData>[], <String>[], 0);
//     }
//   }
// }

// /// Class لتخزين بيانات الملف (bytes + metadata)
// class FileData {
//   final List<int> bytes;
//   final String fileName;
//   final String originalPath;

//   FileData({
//     required this.bytes,
//     required this.fileName,
//     required this.originalPath,
//   });
// }
