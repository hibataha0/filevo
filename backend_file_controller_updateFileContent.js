// ✅ Update file content (replace old file with new file)
// @desc    Update file content (replace old file with new file)
// @route   PUT /api/files/:id/content
// @access  Private
// @note    يجب إضافة هذا الكود إلى ملف fileController.js في الباك إند

const asyncHandler = require('express-async-handler');
const File = require('../models/fileModel');
const fs = require('fs');
const path = require('path');

// ✅ استيراد الدوال المساعدة (تأكد من المسارات الصحيحة)
// إذا كانت هذه الدوال موجودة في ملفات أخرى، استوردها:
// const { getCategoryByExtension } = require('../utils/fileUtils');
// const { logActivity } = require('./activityLogService');
// const { processFile } = require('../services/fileProcessingService');

// ✅ Helper function لتحديد category بناءً على extension و mimeType
// إذا لم تكن موجودة، يمكنك إضافتها هنا أو استيرادها
function getCategoryByExtension(fileName, mimeType) {
  const ext = path.extname(fileName).toLowerCase();
  
  // Images
  if (['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg'].includes(ext) ||
      (mimeType && mimeType.startsWith('image/'))) {
    return 'Images';
  }
  
  // Videos
  if (['.mp4', '.avi', '.mov', '.wmv', '.flv', '.mkv', '.webm'].includes(ext) ||
      (mimeType && mimeType.startsWith('video/'))) {
    return 'Videos';
  }
  
  // Audio
  if (['.mp3', '.wav', '.aac', '.ogg', '.flac', '.m4a'].includes(ext) ||
      (mimeType && mimeType.startsWith('audio/'))) {
    return 'Audio';
  }
  
  // Documents
  if (['.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.txt', '.md', '.rtf'].includes(ext) ||
      (mimeType && (mimeType.startsWith('application/pdf') || mimeType.startsWith('application/msword') || mimeType.startsWith('text/')))) {
    return 'Documents';
  }
  
  // Archives
  if (['.zip', '.rar', '.7z', '.tar', '.gz'].includes(ext) ||
      (mimeType && mimeType.includes('zip'))) {
    return 'Archives';
  }
  
  return 'Other';
}

// ✅ Helper function لتحديث حجم المجلد
// إذا كانت موجودة في ملف آخر، استوردها
async function updateFolderSize(folderId) {
  try {
    const Folder = require('../models/folderModel');
    const files = await File.find({ parentFolderId: folderId, isDeleted: false });
    let totalSize = files.reduce((sum, file) => sum + (file.size || 0), 0);
    
    const subfolders = await Folder.find({ parentId: folderId, isDeleted: false });
    for (const subfolder of subfolders) {
      const subfolderSize = await calculateFolderSizeRecursive(subfolder._id);
      totalSize += subfolderSize;
    }
    
    await Folder.findByIdAndUpdate(folderId, { size: totalSize });
  } catch (error) {
    console.error('Error updating folder size:', error);
  }
}

// ✅ Helper function لحساب حجم المجلد بشكل recursive
async function calculateFolderSizeRecursive(folderId) {
  try {
    const Folder = require('../models/folderModel');
    const files = await File.find({ parentFolderId: folderId, isDeleted: false });
    let totalSize = files.reduce((sum, file) => sum + (file.size || 0), 0);
    
    const subfolders = await Folder.find({ parentId: folderId, isDeleted: false });
    for (const subfolder of subfolders) {
      const subfolderSize = await calculateFolderSizeRecursive(subfolder._id);
      totalSize += subfolderSize;
    }
    
    return totalSize;
  } catch (error) {
    console.error('Error calculating folder size:', error);
    return 0;
  }
}

// ✅ Helper function لتسجيل النشاط (إذا كانت موجودة، استوردها)
async function logActivity(userId, action, type, itemId, itemName, metadata = {}, context = {}) {
  try {
    // إذا كان لديك ActivityLog model، استخدمه هنا
    // const ActivityLog = require('../models/activityLogModel');
    // await ActivityLog.create({ userId, action, type, itemId, itemName, metadata, ...context });
    console.log(`📝 Activity: ${action} - ${type} - ${itemName} by user ${userId}`);
  } catch (error) {
    console.error('Error logging activity:', error);
  }
}

// ✅ Helper function لمعالجة الملف في الخلفية (إذا كانت موجودة، استوردها)
async function processFile(fileId) {
  try {
    // إذا كان لديك fileProcessingService، استخدمه هنا
    // const { processFile } = require('../services/fileProcessingService');
    // await processFile(fileId);
    console.log(`🔄 Processing file in background: ${fileId}`);
  } catch (error) {
    console.error('Error processing file:', error);
  }
}

exports.updateFileContent = asyncHandler(async (req, res) => {
  const fileId = req.params.id;
  const userId = req.user._id;

  console.log("📝 Updating file content:", fileId, "for user:", userId);

  // ✅ التحقق من وجود الملف
  const file = await File.findOne({ _id: fileId, userId: userId });

  if (!file) {
    console.log("❌ File not found:", fileId);
    return res.status(404).json({
      success: false,
      message: "File not found",
    });
  }

  // ✅ التحقق من وجود ملف جديد في الطلب
  if (!req.file) {
    console.log("❌ No file uploaded");
    return res.status(400).json({
      success: false,
      message: "No file uploaded",
    });
  }

  // ✅ تحديد وضع التحديث: replace (استبدال) أو new (نسخة جديدة)
  // للملفات المشتركة: دائماً replace (حتى للصور) حتى يظهر التحديث للمستخدمين المشاركين
  // للملفات الأخرى (بما في ذلك النصية): حسب replaceMode في body
  
  // ✅ إذا كان الملف مشاركاً، استخدم replace mode تلقائياً
  const isShared =
    file.isShared === true || (file.sharedWith && file.sharedWith.length > 0);

  const replaceMode =
    isShared
      ? true
      : req.body.replaceMode === "true" || req.body.replaceMode === true;

  const oldFilePath = file.path;
  const oldFileSize = file.size;
  const oldFileType = file.type;
  const oldCategory = file.category;
  const oldFileName = file.name;

  const newFilePath = req.file.path; // الملف الجديد الذي تم رفعه
  const newFileSize = req.file.size;
  const newFileType = req.file.mimetype;
  const newFileName = req.file.originalname || file.name;

  console.log("📄 Old file path:", oldFilePath);
  console.log("📄 New file path:", newFilePath);
  console.log("📄 Replace mode:", replaceMode);

  console.log("📄 Is shared:", isShared);

  try {
    let finalFilePath = newFilePath;
    let finalFileName = newFileName;

    if (replaceMode) {
      // ✅ وضع الاستبدال: حذف القديم ووضع الجديد بنفس الاسم والمسار
      console.log("🔄 Replace mode: Keeping same name and path");

      // ✅ حذف الملف القديم
      if (oldFilePath && fs.existsSync(oldFilePath)) {
        try {
          fs.unlinkSync(oldFilePath);
          console.log("✅ Deleted old file:", oldFilePath);
        } catch (deleteError) {
          console.warn("⚠️ Could not delete old file:", deleteError.message);
        }
      }

      // ✅ نسخ الملف الجديد إلى مكان الملف القديم بنفس الاسم
      const finalPath = oldFilePath; // استخدام نفس مسار الملف القديم
      const finalDir = path.dirname(finalPath);

      // ✅ التأكد من وجود المجلد
      if (!fs.existsSync(finalDir)) {
        fs.mkdirSync(finalDir, { recursive: true });
      }

      // ✅ نسخ الملف الجديد إلى المكان القديم
      // استخدام readFileSync/writeFileSync للتأكد من التوافق
      const fileContent = fs.readFileSync(newFilePath);
      fs.writeFileSync(finalPath, fileContent);

      // ✅ حذف الملف المؤقت الجديد
      if (fs.existsSync(newFilePath) && newFilePath !== finalPath) {
        try {
          fs.unlinkSync(newFilePath);
          console.log("✅ Deleted temporary new file:", newFilePath);
        } catch (err) {
          console.warn("⚠️ Could not delete temporary file:", err.message);
        }
      }

      finalFilePath = finalPath;
      // ✅ إذا كان الملف مشتركاً، قم بتحديث الاسم إلى الاسم الجديد لضمان ظهور التغييرات للجميع
      // إذا لم يكن مشتركاً، حافظ على الاسم القديم (السلوك الافتراضي للاستبدال)
      finalFileName = isShared ? newFileName : oldFileName;

    } else {
      // ✅ وضع النسخة الجديدة: حذف القديم فقط، الملف الجديد يبقى في مكانه الجديد
      console.log("📝 New version mode: Creating new file");

      // ✅ حذف الملف القديم
      if (oldFilePath && fs.existsSync(oldFilePath)) {
        try {
          fs.unlinkSync(oldFilePath);
          console.log("✅ Deleted old file:", oldFilePath);
        } catch (deleteError) {
          console.warn("⚠️ Could not delete old file:", deleteError.message);
        }
      }

      // ✅ الملف الجديد يبقى في مكانه الجديد (newFilePath)
      finalFilePath = newFilePath;
      finalFileName = newFileName;
    }

    // ✅ تحديد category جديد بناءً على نوع الملف الجديد
    const newCategory = getCategoryByExtension(finalFileName, newFileType);

    // ✅ تحديث معلومات الملف في قاعدة البيانات
    file.path = finalFilePath;
    file.size = newFileSize;
    file.type = newFileType;
    file.category = newCategory;
    file.name = finalFileName; // ✅ اسم الملف (قد يكون القديم أو الجديد حسب replaceMode)
    file.updatedAt = new Date();

    // ✅ إعادة تعيين حالة المعالجة لأن الملف تغير
    file.isProcessed = false;
    file.processedAt = null;
    file.extractedText = null;
    file.embedding = null;
    file.summary = null;

    // ✅ حفظ التغييرات
    await file.save();

    // ✅ تحديث حجم المجلد إذا كان الملف داخل مجلد
    if (file.parentFolderId) {
      await updateFolderSize(file.parentFolderId);
    }

    // ✅ معالجة الملف الجديد في الخلفية (استخراج نص، توليد embedding، تلخيص)
    processFile(file._id)
      .then(() => {
        console.log(
          `✅ Background processing completed for updated file: ${file.name}`
        );
      })
      .catch((err) => {
        console.error(
          `❌ Background processing error for updated file ${file.name} (${file._id}):`,
          err.message
        );
        console.error("Full error:", err);
      });

    // ✅ تسجيل النشاط
    await logActivity(
      userId,
      "file_content_updated",
      "file",
      file._id,
      file.name,
      {
        oldSize: oldFileSize,
        newSize: newFileSize,
        oldType: oldFileType,
        newType: newFileType,
        oldCategory: oldCategory,
        newCategory: newCategory,
      },
      {
        ipAddress: req.ip,
        userAgent: req.get("User-Agent"),
      }
    );

    console.log("✅ File content updated successfully:", fileId);
    res.status(200).json({
      success: true,
      message: replaceMode
        ? "تم استبدال الملف بنجاح (نفس الاسم والمسار)"
        : "تم تحديث الملف بنجاح (نسخة جديدة)",
      file: file,
      replaceMode: replaceMode,
    });
  } catch (error) {
    // ✅ في حالة الخطأ، حذف الملف الجديد إذا تم رفعه
    if (newFilePath && fs.existsSync(newFilePath)) {
      try {
        fs.unlinkSync(newFilePath);
        console.log("🧹 Cleaned up new file due to error");
      } catch (cleanupError) {
        console.error("❌ Error cleaning up new file:", cleanupError);
      }
    }

    // ✅ إذا كان في وضع replace وحاولنا نسخ الملف، حذف الملف المنسوخ أيضاً
    if (replaceMode && oldFilePath && fs.existsSync(oldFilePath)) {
      try {
        // التحقق من أن هذا ليس نفس الملف القديم الأصلي
        const stats = fs.statSync(oldFilePath);
        if (stats.mtimeMs > Date.now() - 5000) {
          // تم إنشاؤه/تعديله في آخر 5 ثواني
          fs.unlinkSync(oldFilePath);
          console.log("🧹 Cleaned up replaced file due to error");
        }
      } catch (cleanupError) {
        console.error("❌ Error cleaning up replaced file:", cleanupError);
      }
    }

    console.error("❌ Error updating file content:", error);
    res.status(500).json({
      success: false,
      message: "Error updating file content",
      error: error.message,
    });
  }
});

// ✅ Export helper functions إذا كانت مطلوبة في أماكن أخرى
module.exports = {
  updateFileContent: exports.updateFileContent,
  getCategoryByExtension,
  updateFolderSize,
  calculateFolderSizeRecursive,
};
