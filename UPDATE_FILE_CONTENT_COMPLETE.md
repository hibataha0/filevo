# 📝 تحديث محتوى الملف - دليل شامل

## ✅ نظرة عامة

تم تحديث دالة `updateFileContent` لدعم وضعين لتحديث محتوى الملف:
1. **وضع الاستبدال (Replace Mode)**: استبدال الملف القديم بنفس الاسم والمسار
2. **وضع النسخة الجديدة (New Version Mode)**: إنشاء ملف جديد مع تحديث الاسم والمسار

## 🔧 الميزات

### 1. استبدال تلقائي للملفات النصية
- الملفات النصية (`.txt`, `.md`, `.json`, `.xml`, `.csv` وغيرها) يتم استبدالها تلقائياً
- لا حاجة لإرسال `replaceMode` للملفات النصية
- الحفاظ على نفس الاسم والمسار

### 2. خيار للملفات الأخرى
- يمكن إرسال `replaceMode` في body للملفات غير النصية
- `replaceMode = true`: استبدال الملف القديم بنفس الاسم والمسار
- `replaceMode = false` أو غير موجود: إنشاء نسخة جديدة مع اسم ومسار جديد

### 3. تحديث تلقائي للـ Category
- يتم تحديث `category` بناءً على نوع الملف الجديد
- استخدام `getCategoryByExtension` لتحديد التصنيف الصحيح

### 4. إعادة معالجة الملف
- إعادة تعيين حالة المعالجة (`isProcessed = false`)
- معالجة الملف في الخلفية (استخراج نص، توليد embedding، تلخيص)

### 5. تحديث حجم المجلد
- تحديث تلقائي لحجم المجلد إذا كان الملف داخل مجلد

### 6. تسجيل النشاط
- تسجيل تفاصيل التحديث في سجل النشاطات

## 📋 API Usage

### 1. ملف نصي (استبدال تلقائي):

```http
PUT /api/files/:id/content
Content-Type: multipart/form-data
Authorization: Bearer <token>

file: <new_file.txt>
```

**النتيجة:**
- يتم استبدال الملف القديم بنفس الاسم والمسار
- لا حاجة لإرسال `replaceMode`

### 2. ملف آخر (استبدال):

```http
PUT /api/files/:id/content
Content-Type: multipart/form-data
Authorization: Bearer <token>

file: <new_file.jpg>
replaceMode: true
```

**النتيجة:**
- يتم استبدال الملف القديم بنفس الاسم والمسار
- الحفاظ على نفس الاسم في قاعدة البيانات

### 3. ملف آخر (نسخة جديدة):

```http
PUT /api/files/:id/content
Content-Type: multipart/form-data
Authorization: Bearer <token>

file: <new_file.jpg>
replaceMode: false
```

**النتيجة:**
- يتم حذف الملف القديم
- الملف الجديد يبقى في مكانه الجديد
- تحديث الاسم والمسار في قاعدة البيانات

## 🔌 Integration

### الخطوة 1: إضافة Route

في ملف `routes/fileRoutes.js` أو `routes/fileRoutes.js`:

```javascript
const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const fileController = require('../controllers/fileController');
const { uploadSingle } = require('../config/multerConfig');

// ✅ Route لتحديث محتوى الملف (يجب وضعه قبل route /files/:id العام)
router.put('/files/:id/content', protect, uploadSingle, fileController.updateFileContent);

module.exports = router;
```

**ملاحظة مهمة:** يجب أن يكون هذا route قبل أي route ديناميكي آخر مثل:
- `router.get('/files/:id', ...)`
- `router.delete('/files/:id', ...)`

### الخطوة 2: إضافة الكود إلى Controller

انسخ دالة `updateFileContent` من `backend_file_controller_updateFileContent.js` إلى ملف `fileController.js` في الباك إند.

### الخطوة 3: استيراد الدوال المساعدة

إذا كانت الدوال المساعدة موجودة في ملفات أخرى، استوردها:

```javascript
// في أعلى ملف fileController.js
const { getCategoryByExtension } = require('../utils/fileUtils');
const { logActivity } = require('./activityLogService');
const { processFile } = require('../services/fileProcessingService');
```

إذا لم تكن موجودة، الكود يحتوي على نسخ بسيطة منها يمكن استخدامها.

## ⚠️ ملاحظات مهمة

### 1. الدوال المساعدة
الكود يحتوي على نسخ بسيطة من الدوال المساعدة:
- `getCategoryByExtension`: تحديد التصنيف بناءً على extension و mimeType
- `updateFolderSize`: تحديث حجم المجلد
- `calculateFolderSizeRecursive`: حساب حجم المجلد بشكل recursive
- `logActivity`: تسجيل النشاط
- `processFile`: معالجة الملف في الخلفية

**إذا كانت هذه الدوال موجودة في ملفات أخرى، استوردها بدلاً من استخدام النسخ البسيطة.**

### 2. معالجة الأخطاء
- في حالة الخطأ، يتم حذف الملف الجديد تلقائياً
- في وضع replace، يتم حذف الملف المنسوخ أيضاً في حالة الخطأ

### 3. الأمان
- التحقق من أن المستخدم يملك الملف قبل التحديث
- التحقق من وجود ملف في الطلب
- معالجة آمنة للأخطاء

## 📊 Response Format

### نجاح (200):
```json
{
  "success": true,
  "message": "تم استبدال الملف بنجاح (نفس الاسم والمسار)" | "تم تحديث الملف بنجاح (نسخة جديدة)",
  "file": {
    "_id": "...",
    "name": "...",
    "path": "...",
    "size": 12345,
    "type": "...",
    "category": "...",
    ...
  },
  "replaceMode": true | false
}
```

### خطأ (404):
```json
{
  "success": false,
  "message": "File not found"
}
```

### خطأ (400):
```json
{
  "success": false,
  "message": "No file uploaded"
}
```

### خطأ (500):
```json
{
  "success": false,
  "message": "Error updating file content",
  "error": "Error message details"
}
```

## ✅ الفوائد

1. **مرونة**: دعم وضعين مختلفين لتحديث الملف
2. **سهولة الاستخدام**: استبدال تلقائي للملفات النصية
3. **الأمان**: معالجة آمنة للأخطاء وتنظيف الملفات المؤقتة
4. **التكامل**: تحديث تلقائي لحجم المجلد وتسجيل النشاط
5. **المعالجة**: إعادة معالجة الملف تلقائياً بعد التحديث

## 🔄 التحديثات المستقبلية

- إضافة دعم للـ versioning (الاحتفاظ بنسخ قديمة)
- إضافة دعم للـ rollback (التراجع عن التحديث)
- إضافة دعم للـ diff (مقارنة الملفات)









