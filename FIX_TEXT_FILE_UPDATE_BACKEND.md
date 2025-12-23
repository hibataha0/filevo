# 🔧 إصلاح مشكلة حفظ ملفات النص المعدلة في الباك إند

## المشكلة
عند تعديل ملف نصي وحفظه، لا يتم رفعه على السيرفر بنجاح.

## الحل المطلوب في الباك إند

### الطريقة 1: إضافة Route لتحديث محتوى الملف (PUT)

يجب إضافة route جديد في ملف routes الخاص بالملفات يدعم تحديث محتوى الملف:

#### في ملف `routes/fileRoutes.js` (أو الملف المناسب):

```javascript
const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const fileController = require('../controllers/fileController');
const { uploadSingle } = require('../config/multerConfig'); // أو مسار multer config

// ✅ إضافة Route لتحديث محتوى الملف
router.put('/files/:id', protect, uploadSingle, fileController.updateFileContent);
```

### الطريقة 2: إضافة دالة في Controller

#### في ملف `controllers/fileController.js`:

```javascript
const asyncHandler = require('express-async-handler');
const File = require('../models/fileModel');
const fs = require('fs');
const path = require('path');

// ✅ تحديث محتوى الملف (استبدال الملف القديم بملف جديد)
// @desc    Update file content (replace old file with new file)
// @route   PUT /api/v1/files/:id
// @access  Private
exports.updateFileContent = asyncHandler(async (req, res) => {
  const fileId = req.params.id;
  const userId = req.user._id;

  // ✅ التحقق من وجود الملف
  const file = await File.findOne({ _id: fileId, userId: userId });
  
  if (!file) {
    return res.status(404).json({ message: 'File not found' });
  }

  // ✅ التحقق من وجود ملف جديد في الطلب
  if (!req.file) {
    return res.status(400).json({ message: 'No file uploaded' });
  }

  const oldFilePath = file.path;
  const newFilePath = req.file.path;
  const newFileSize = req.file.size;

  try {
    // ✅ حذف الملف القديم من النظام
    if (oldFilePath && fs.existsSync(oldFilePath)) {
      fs.unlinkSync(oldFilePath);
      console.log('✅ Deleted old file:', oldFilePath);
    }

    // ✅ تحديث معلومات الملف في قاعدة البيانات
    file.path = newFilePath;
    file.size = newFileSize;
    file.originalName = req.file.originalname || file.originalName;
    file.updatedAt = new Date();
    
    await file.save();

    console.log('✅ File content updated successfully:', fileId);

    res.status(200).json({
      success: true,
      message: 'File content updated successfully',
      file: file
    });
  } catch (error) {
    // ✅ في حالة الخطأ، حذف الملف الجديد إذا تم رفعه
    if (fs.existsSync(newFilePath)) {
      fs.unlinkSync(newFilePath);
    }
    
    console.error('❌ Error updating file content:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating file content',
      error: error.message
    });
  }
});
```

### الطريقة البديلة: استخدام الطريقة الحالية (رفع جديد + حذف قديم)

إذا كنت تريد استخدام الطريقة الحالية (رفع ملف جديد ثم حذف القديم)، تأكد من:

1. **أن route `/files/upload-single` موجود ويعمل:**
```javascript
router.post('/files/upload-single', protect, uploadSingle, fileController.uploadSingleFile);
```

2. **أن route DELETE `/files/:id` موجود ويعمل:**
```javascript
router.delete('/files/:id', protect, fileController.deleteFile);
```

3. **أن دالة `uploadSingleFile` في Controller تدعم `parentFolderId`:**
```javascript
exports.uploadSingleFile = asyncHandler(async (req, res) => {
  const userId = req.user._id;
  const parentFolderId = req.body.parentFolderId || null;
  const fileName = req.body.name || req.file.originalname;
  
  // ... باقي الكود
});
```

## ملاحظات مهمة:

1. **تأكد من استيراد `multer` بشكل صحيح:**
```javascript
const { uploadSingle } = require('../config/multerConfig');
// أو
const multer = require('multer');
const uploadSingle = multer({ ... }).single('file');
```

2. **تأكد من أن middleware `protect` موجود ويعمل**

3. **تأكد من أن route يقع قبل أي routes ديناميكية أخرى**

4. **للطريقة 1 (PUT):** تأكد من أن الـ route يقع قبل route `/files/:id` العام إذا كان موجوداً

## الاختبار:

بعد إضافة الكود، اختبر:

1. تعديل ملف نصي من التطبيق
2. حفظ التغييرات
3. التحقق من أن الملف تم تحديثه على السيرفر
4. التحقق من أن الملف القديم تم حذفه (للطريقة 1)

## في حالة وجود مشاكل:

- تأكد من أن `req.file` موجود في Controller
- تأكد من أن `req.user._id` موجود (middleware protect يعمل)
- راجع console logs في الباك إند للتحقق من الأخطاء
- تأكد من أن مسار الملفات (`path`) صحيح في قاعدة البيانات






