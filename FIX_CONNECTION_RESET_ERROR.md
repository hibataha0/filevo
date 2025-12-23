# 🔧 إصلاح خطأ "Connection reset by peer" عند تحديث محتوى الملف

## المشكلة
عند محاولة تحديث محتوى ملف نصي، يحدث خطأ:
```
ClientException: Connection reset by peer
```

## الأسباب المحتملة

### 1. **Timeout في السيرفر**
السيرفر يغلق الاتصال قبل اكتمال الرفع.

### 2. **حجم الملف كبير**
الملف كبير جداً والسيرفر لا يدعم الملفات الكبيرة.

### 3. **مشكلة في Multer Config**
إعدادات multer لا تدعم PUT requests أو حجم الملف.

### 4. **مشكلة في Route Handler**
الـ route handler لا يتعامل مع PUT requests بشكل صحيح.

## الحلول في الباك إند

### الحل 1: زيادة Timeout في Express

في ملف `server.js` أو `app.js`:

```javascript
// ✅ زيادة timeout للـ requests
app.timeout = 300000; // 5 دقائق

// ✅ أو في middleware
app.use((req, res, next) => {
  req.setTimeout(300000); // 5 دقائق
  res.setTimeout(300000);
  next();
});
```

### الحل 2: تحديث Multer Config

في ملف `config/multerConfig.js`:

```javascript
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, uploadDir);
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
    }
});

// ✅ زيادة حد حجم الملف إلى 100MB
const limits = {
    fileSize: 100 * 1024 * 1024, // 100MB
    fieldSize: 10 * 1024 * 1024, // 10MB
    files: 1, // ملف واحد فقط
    fields: 10,
    headerPairs: 2000
};

const upload = multer({
    storage: storage,
    limits: limits,
    fileFilter: function (req, file, cb) {
        cb(null, true);
    }
});

// ✅ Middleware لرفع ملف واحد
const uploadSingle = upload.single('file');

module.exports = { uploadSingle };
```

### الحل 3: تحديث Route Handler

في ملف `routes/fileRoutes.js`:

```javascript
const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const fileController = require('../controllers/fileController');
const { uploadSingle } = require('../config/multerConfig');

// ✅ Route لتحديث محتوى الملف مع timeout
router.put('/files/:id/content', protect, (req, res, next) => {
  // ✅ تعيين timeout طويل (5 دقائق)
  req.setTimeout(300000);
  res.setTimeout(300000);
  
  // ✅ استخدام uploadSingle middleware
  uploadSingle(req, res, (err) => {
    if (err) {
      console.error('Multer error:', err);
      return res.status(400).json({
        success: false,
        message: 'Error uploading file',
        error: err.message
      });
    }
    // ✅ استدعاء controller
    fileController.updateFileContent(req, res, next);
  });
});
```

### الحل 4: تحديث Controller

في ملف `controllers/fileController.js`:

```javascript
exports.updateFileContent = asyncHandler(async (req, res) => {
  const fileId = req.params.id;
  const userId = req.user._id;

  console.log("📝 Updating file content:", fileId, "for user:", userId);

  // ✅ التحقق من وجود الملف
  const file = await File.findOne({ _id: fileId, userId: userId });
  
  if (!file) {
    return res.status(404).json({
      success: false,
      message: "File not found",
    });
  }

  // ✅ التحقق من وجود ملف جديد في الطلب
  if (!req.file) {
    return res.status(400).json({
      success: false,
      message: "No file uploaded",
    });
  }

  const oldFilePath = file.path;
  const newFilePath = req.file.path;
  const newFileSize = req.file.size;
  const newFileName = req.file.originalname || file.name;

  console.log("📄 Old file path:", oldFilePath);
  console.log("📄 New file path:", newFilePath);
  console.log("📄 New file size:", newFileSize, "bytes");

  try {
    // ✅ حذف الملف القديم
    if (oldFilePath && fs.existsSync(oldFilePath)) {
      try {
        fs.unlinkSync(oldFilePath);
        console.log("✅ Deleted old file:", oldFilePath);
      } catch (deleteError) {
        console.warn("⚠️ Could not delete old file:", deleteError.message);
      }
    }

    // ✅ تحديث معلومات الملف
    file.path = newFilePath;
    file.size = newFileSize;
    file.name = newFileName;
    file.updatedAt = new Date();
    
    await file.save();

    console.log("✅ File content updated successfully:", fileId);

    res.status(200).json({
      success: true,
      message: "File content updated successfully",
      file: file,
    });
  } catch (error) {
    // ✅ تنظيف الملف الجديد في حالة الخطأ
    if (newFilePath && fs.existsSync(newFilePath)) {
      try {
        fs.unlinkSync(newFilePath);
      } catch (cleanupError) {
        console.error("❌ Error cleaning up new file:", cleanupError);
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
```

## التحقق من الحل

1. **تحقق من Timeout:**
   - تأكد من أن timeout في Express أكبر من الوقت المطلوب للرفع
   - للملفات الكبيرة (>10MB)، استخدم timeout 5 دقائق على الأقل

2. **تحقق من Multer:**
   - تأكد من أن `fileSize` limit كبير بما يكفي
   - تأكد من أن middleware يعمل بشكل صحيح

3. **تحقق من Route:**
   - تأكد من أن route يقع قبل route `/:id` العام
   - تأكد من أن middleware `protect` يعمل

4. **تحقق من Network:**
   - تأكد من أن الاتصال مستقر
   - جرب مع ملف صغير أولاً للتأكد من أن المشكلة ليست في الاتصال

## ملاحظات

- ✅ تم إضافة timeout في Flutter (5 دقائق)
- ✅ تم إضافة معالجة أفضل للأخطاء
- ✅ تم إضافة fallback (رفع ملف جديد) في حالة فشل PUT
- ⚠️ يجب تحديث الباك إند لدعم timeout أطول
- ⚠️ يجب التأكد من أن multer config يدعم الملفات الكبيرة






