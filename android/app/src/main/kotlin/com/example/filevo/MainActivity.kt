package com.example.filevo

import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.content.ContentValues
import androidx.annotation.NonNull
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.InputStream
import java.io.FileInputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.filevo/saf"
    private val FILE_CHOOSER_CHANNEL = "file_chooser_channel"
    private val DOWNLOAD_CHANNEL = "com.example.filevo/download"
    private var pendingFolderPickerResult: MethodChannel.Result? = null
    private val FOLDER_PICKER_REQUEST_CODE = 1001

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // ✅ MethodChannel لفتح الملفات مع اختيار التطبيق
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FILE_CHOOSER_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "openWithChooser") {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        openFileWithChooser(path)
                        result.success(null)
                    } else {
                        result.error("NO_PATH", "File path is null", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
        
        // ✅ MethodChannel لإضافة الملف إلى MediaStore (للظهور في التحميلات)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DOWNLOAD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "addToDownloads" -> {
                        val filePath = call.argument<String>("filePath")
                        val fileName = call.argument<String>("fileName")
                        if (filePath != null && fileName != null) {
                            val success = addFileToDownloads(filePath, fileName)
                            result.success(success)
                        } else {
                            result.error("INVALID_ARGUMENT", "filePath or fileName is null", null)
                        }
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openFolderPicker" -> {
                    openFolderPicker(result)
                }
                "clearPersistedPermissions" -> {
                    clearPersistedPermissions(result)
                }
                "readFilesFromSAF" -> {
                    val folderPath = call.argument<String>("folderPath")
                    if (folderPath != null) {
                        readFilesFromSAF(folderPath, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "folderPath is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun clearPersistedPermissions(result: MethodChannel.Result) {
        try {
            android.util.Log.d("SAF", "clearPersistedPermissions called")
            val contentResolver = applicationContext.contentResolver
            val persistedUriPermissions = contentResolver.persistedUriPermissions
            
            android.util.Log.d("SAF", "Found ${persistedUriPermissions.size} persisted permissions")
            
            for (uriPermission in persistedUriPermissions) {
                try {
                    contentResolver.releasePersistableUriPermission(
                        uriPermission.uri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                    )
                    android.util.Log.d("SAF", "Released permission for: ${uriPermission.uri}")
                } catch (e: Exception) {
                    android.util.Log.e("SAF", "Error releasing permission: ${e.message}", e)
                }
            }
            
            android.util.Log.d("SAF", "✅ Cleared all persisted permissions")
            result.success(true)
        } catch (e: Exception) {
            android.util.Log.e("SAF", "Error clearing persisted permissions: ${e.message}", e)
            result.error("CLEAR_ERROR", "Error clearing permissions: ${e.message}", null)
        }
    }

    private fun openFolderPicker(result: MethodChannel.Result) {
        try {
            android.util.Log.d("SAF", "openFolderPicker called")
            pendingFolderPickerResult = result
            val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
            android.util.Log.d("SAF", "Starting activity for result with request code: $FOLDER_PICKER_REQUEST_CODE")
            startActivityForResult(intent, FOLDER_PICKER_REQUEST_CODE)
            android.util.Log.d("SAF", "Activity started successfully")
        } catch (e: Exception) {
            android.util.Log.e("SAF", "Error opening folder picker: ${e.message}", e)
            result.error("PICKER_ERROR", "Error opening folder picker: ${e.message}", null)
            pendingFolderPickerResult = null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        android.util.Log.d("SAF", "onActivityResult called: requestCode=$requestCode, resultCode=$resultCode")
        
        if (requestCode == FOLDER_PICKER_REQUEST_CODE) {
            android.util.Log.d("SAF", "Processing folder picker result")
            val result = pendingFolderPickerResult
            pendingFolderPickerResult = null
            
            if (result == null) {
                android.util.Log.e("SAF", "pendingFolderPickerResult is null!")
                return
            }
            
            if (resultCode == RESULT_OK && data != null) {
                android.util.Log.d("SAF", "Result OK, data is not null")
                val treeUri: Uri? = data.data
                if (treeUri != null) {
                    // ✅ الحصول على URI المختار
                    val uriString = treeUri.toString()
                    android.util.Log.d("SAF", "Selected folder URI: $uriString")
                    
                    // ✅ حفظ الصلاحية بشكل دائم
                    val contentResolver = applicationContext.contentResolver
                    val takeFlags: Int = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                                       Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                    try {
                        contentResolver.takePersistableUriPermission(treeUri, takeFlags)
                        android.util.Log.d("SAF", "Persistable URI permission taken successfully")
                    } catch (e: SecurityException) {
                        android.util.Log.e("SAF", "Failed to take persistable URI permission: ${e.message}")
                    }
                    
                    // ✅ استخراج المسار من URI
                    val documentId = DocumentsContract.getTreeDocumentId(treeUri)
                    android.util.Log.d("SAF", "Document ID: $documentId")
                    val path = documentId.replace("primary:", "").replace("%2F", "/")
                    
                    android.util.Log.d("SAF", "Selected folder path: $path")
                    result.success(path)
                } else {
                    android.util.Log.e("SAF", "Tree URI is null")
                    result.error("NO_URI", "No URI returned from folder picker", null)
                }
            } else {
                android.util.Log.d("SAF", "User cancelled folder picker or result not OK. resultCode=$resultCode")
                result.success(null)
            }
        } else {
            android.util.Log.d("SAF", "Request code doesn't match: $requestCode != $FOLDER_PICKER_REQUEST_CODE")
        }
    }

    private fun readFilesFromSAF(folderPath: String, result: MethodChannel.Result) {
        try {
            android.util.Log.d("SAF", "readFilesFromSAF called with folderPath: $folderPath")
            
            // ✅ استخدام package saf للحصول على URI
            val uri = getSAFUriFromPath(folderPath)
            if (uri == null) {
                android.util.Log.e("SAF", "Failed to get SAF URI from path: $folderPath")
                result.error("INVALID_URI", "Could not convert path to SAF URI: $folderPath", null)
                return
            }

            android.util.Log.d("SAF", "Using SAF URI: $uri")
            
            val contentResolver: ContentResolver = applicationContext.contentResolver
            val treeDocumentId = DocumentsContract.getTreeDocumentId(uri)
            android.util.Log.d("SAF", "Tree document ID: $treeDocumentId")
            
            val files = mutableListOf<ByteArray>()
            val fileNames = mutableListOf<String>()
            val relativePaths = mutableListOf<String>()

            // ✅ قراءة الملفات بشكل متكرر من جميع المجلدات الفرعية
            android.util.Log.d("SAF", "🚀 Starting recursive directory reading from root...")
            readDirectoryRecursively(
                contentResolver = contentResolver,
                treeUri = uri,
                documentId = treeDocumentId,
                currentPath = "", // ✅ المسار الحالي (يبدأ من الجذر)
                files = files,
                fileNames = fileNames,
                relativePaths = relativePaths
            )

            android.util.Log.d("SAF", "✅ Total files read: ${files.size}")
            android.util.Log.d("SAF", "✅ File names: $fileNames")
            android.util.Log.d("SAF", "✅ Relative paths: $relativePaths")

            val resultMap = mapOf(
                "files" to files.map { it.toList() },
                "fileNames" to fileNames,
                "relativePaths" to relativePaths
            )

            result.success(resultMap)
        } catch (e: Exception) {
            android.util.Log.e("SAF", "Error in readFilesFromSAF: ${e.message}", e)
            result.error("READ_ERROR", "Error reading files from SAF: ${e.message}", null)
        }
    }

    // ✅ دالة متكررة لقراءة جميع الملفات من المجلدات الفرعية
    private fun readDirectoryRecursively(
        contentResolver: ContentResolver,
        treeUri: Uri,
        documentId: String,
        currentPath: String,
        files: MutableList<ByteArray>,
        fileNames: MutableList<String>,
        relativePaths: MutableList<String>
    ) {
        try {
            android.util.Log.d("SAF", "📂 Reading directory: path='$currentPath', documentId='$documentId'")
            
            val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, documentId)
            android.util.Log.d("SAF", "📂 Children URI: $childrenUri")

            val cursor = contentResolver.query(
                childrenUri,
                arrayOf(
                    DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                    DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                    DocumentsContract.Document.COLUMN_MIME_TYPE
                ),
                null,
                null,
                null
            )
            
            if (cursor == null) {
                android.util.Log.e("SAF", "❌ Cursor is null for directory: $currentPath")
                return
            }

            try {
                android.util.Log.d("SAF", "Cursor count in directory '$currentPath': ${cursor.count}")
                
                while (cursor.moveToNext()) {
                    val childDocumentId = cursor.getString(0)
                    val displayName = cursor.getString(1)
                    val mimeType = cursor.getString(2)

                    android.util.Log.d("SAF", "Found item in '$currentPath': name=$displayName, type=$mimeType, id=$childDocumentId")

                    // ✅ بناء المسار النسبي
                    val relativePath = if (currentPath.isEmpty()) {
                        displayName
                    } else {
                        "$currentPath/$displayName"
                    }

                    if (mimeType != null && mimeType.startsWith("vnd.android.document/directory")) {
                        // ✅ هذا مجلد فرعي، اقرأ محتوياته بشكل متكرر
                        android.util.Log.d("SAF", "Found subdirectory: $displayName, reading recursively from path: $relativePath")
                        readDirectoryRecursively(
                            contentResolver = contentResolver,
                            treeUri = treeUri,
                            documentId = childDocumentId,
                            currentPath = relativePath,
                            files = files,
                            fileNames = fileNames,
                            relativePaths = relativePaths
                        )
                        android.util.Log.d("SAF", "Finished reading subdirectory: $displayName")
                    } else {
                        // ✅ هذا ملف، اقرأه
                        val documentUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, childDocumentId)
                        android.util.Log.d("SAF", "Reading file: $relativePath (documentId: $childDocumentId)")
                        
                        try {
                            val inputStream: InputStream? = contentResolver.openInputStream(documentUri)
                            if (inputStream != null) {
                                inputStream.use { stream ->
                                    val bytes = stream.readBytes()
                                    files.add(bytes)
                                    fileNames.add(displayName)
                                    relativePaths.add(relativePath) // ✅ المسار النسبي الكامل
                                    android.util.Log.d("SAF", "✅ Successfully read file: $relativePath (${bytes.size} bytes)")
                                }
                            } else {
                                android.util.Log.e("SAF", "❌ InputStream is null for file: $relativePath")
                            }
                        } catch (e: Exception) {
                            android.util.Log.e("SAF", "❌ Error reading file $relativePath: ${e.message}", e)
                        }
                    }
                }
                
                android.util.Log.d("SAF", "Finished reading directory '$currentPath', total files so far: ${files.size}")
            } finally {
                cursor.close()
            }
        } catch (e: Exception) {
            android.util.Log.e("SAF", "Error reading directory $currentPath: ${e.message}", e)
        }
    }

    private fun getSAFUriFromPath(folderPath: String): Uri? {
        // ✅ تحويل folderPath إلى SAF URI
        // مثال: "Download/Dfdsfs" -> "content://com.android.externalstorage.documents/tree/primary%3ADownload%2FDfdsfs"
        try {
            // ✅ إذا كان folderPath يحتوي على "primary:" فهو URI كامل
            if (folderPath.startsWith("content://")) {
                return Uri.parse(folderPath)
            }
            
            // ✅ بناء SAF URI من folderPath
            // تحويل "Download/Dfdsfs" إلى "primary:Download/Dfdsfs" ثم encode
            val pathParts = folderPath.split("/")
            val encodedParts = pathParts.map { 
                java.net.URLEncoder.encode(it, "UTF-8").replace("+", "%20")
            }
            val encodedPath = encodedParts.joinToString("%2F")
            val uriString = "content://com.android.externalstorage.documents/tree/primary%3A$encodedPath"
            
            android.util.Log.d("SAF", "Built URI from path: $folderPath -> $uriString")
            return Uri.parse(uriString)
        } catch (e: Exception) {
            android.util.Log.e("SAF", "Error converting path to URI: ${e.message}", e)
            return null
        }
    }

    private fun openFileWithChooser(path: String) {
        val file = File(path)
        val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)
        val intent = Intent(Intent.ACTION_VIEW)
        intent.setDataAndType(uri, contentResolver.getType(uri))
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        startActivity(Intent.createChooser(intent, "Open with"))
    }
    
    // ✅ إضافة الملف إلى MediaStore للظهور في التحميلات
    private fun addFileToDownloads(filePath: String, fileName: String): Boolean {
        try {
            val file = File(filePath)
            if (!file.exists()) {
                android.util.Log.e("Download", "File does not exist: $filePath")
                return false
            }
            
            val contentResolver = applicationContext.contentResolver
            val contentValues = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                put(MediaStore.Downloads.RELATIVE_PATH, "Download/")
                put(MediaStore.Downloads.IS_PENDING, 1)
            }
            
            val uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
            } else {
                // ✅ Android 9 وأقل
                val downloadsDir = android.os.Environment.getExternalStoragePublicDirectory(
                    android.os.Environment.DIRECTORY_DOWNLOADS
                )
                val downloadFile = File(downloadsDir, fileName)
                file.copyTo(downloadFile, overwrite = true)
                
                // ✅ إعلام النظام بالملف الجديد
                val intent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
                intent.data = Uri.fromFile(downloadFile)
                applicationContext.sendBroadcast(intent)
                
                android.util.Log.d("Download", "File added to downloads (Android 9-): ${downloadFile.absolutePath}")
                return true
            }
            
            if (uri != null) {
                // ✅ نسخ الملف إلى MediaStore
                contentResolver.openOutputStream(uri)?.use { outputStream ->
                    FileInputStream(file).use { inputStream ->
                        inputStream.copyTo(outputStream)
                    }
                }
                
                // ✅ تحديث حالة الملف (إزالة IS_PENDING)
                contentValues.clear()
                contentValues.put(MediaStore.Downloads.IS_PENDING, 0)
                contentResolver.update(uri, contentValues, null, null)
                
                android.util.Log.d("Download", "File added to downloads (Android 10+): $uri")
                return true
            } else {
                android.util.Log.e("Download", "Failed to create URI in MediaStore")
                return false
            }
        } catch (e: Exception) {
            android.util.Log.e("Download", "Error adding file to downloads: ${e.message}", e)
            return false
        }
    }
}
