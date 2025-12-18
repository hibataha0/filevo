# 📝 تحديث محتوى الملف - تحديثات الفرونت إند والباك إند

## ✅ ملخص التحديثات

تم تحديث الكود في الفرونت إند والباك إند لدعم تحديث محتوى الملف بشكل محسّن.

---

## 🔧 تحديثات الباك إند

### 1. Route محدث (`backend_file_routes_updateFileContent.js`)

```javascript
// ✅ Route محدث
router.put('/files/:id/content', protect, uploadSingle, fileController.updateFileContent);
```

**التغيير:**
- تم تغيير Route من `/files/:id` إلى `/files/:id/content` لتجنب التعارض مع routes أخرى

### 2. Controller محدث (`backend_file_controller_updateFileContent.js`)

**الميزات:**
- ✅ دعم وضعين: Replace Mode و New Version Mode
- ✅ استبدال تلقائي للملفات النصية
- ✅ تحديث تلقائي للـ category
- ✅ إعادة معالجة الملف في الخلفية
- ✅ تحديث حجم المجلد
- ✅ تسجيل النشاط

**الملفات النصية:**
- يتم استبدالها تلقائياً بنفس الاسم والمسار
- لا حاجة لإرسال `replaceMode`

**الملفات الأخرى:**
- يمكن إرسال `replaceMode` في body:
  - `replaceMode = true`: استبدال بنفس الاسم والمسار
  - `replaceMode = false`: نسخة جديدة مع اسم ومسار جديد

---

## 🎨 تحديثات الفرونت إند

### 1. دالة جديدة في FileService (`lib/services/file_service.dart`)

تم إضافة دالة `updateFileContent`:

```dart
Future<Map<String, dynamic>> updateFileContent({
  required String fileId,
  required File file,
  required String token,
  bool? replaceMode,
}) async
```

**الميزات:**
- ✅ استخدام multipart/form-data
- ✅ دعم replaceMode (اختياري)
- ✅ معالجة أخطاء محسّنة
- ✅ timeout طويل للملفات الكبيرة (5 دقائق)
- ✅ logging مفصل

### 2. تحديث TextViewerPage (`lib/views/fileViewer/textViewer.dart`)

**التغييرات:**
- ✅ استخدام `FileService.updateFileContent` بدلاً من الكود المباشر
- ✅ تبسيط الكود وتحسينه
- ✅ معالجة أخطاء أفضل
- ✅ تحديث تلقائي لبيانات الملف بعد التحديث

---

## 📋 API Usage

### 1. ملف نصي (استبدال تلقائي):

```http
PUT /api/files/:id/content
Content-Type: multipart/form-data
Authorization: Bearer <token>

file: <new_file.txt>
```

**النتيجة:**
- يتم استبدال الملف القديم بنفس الاسم والمسار تلقائياً
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

---

## 🔌 Integration Steps

### الخطوة 1: تحديث Route في الباك إند

في ملف `routes/fileRoutes.js`:

```javascript
const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const fileController = require('../controllers/fileController');
const { uploadSingle } = require('../config/multerConfig');

// ✅ Route محدث
router.put('/files/:id/content', protect, uploadSingle, fileController.updateFileContent);

module.exports = router;
```

**ملاحظة مهمة:** يجب أن يكون هذا route قبل أي route ديناميكي آخر مثل:
- `router.get('/files/:id', ...)`
- `router.delete('/files/:id', ...)`

### الخطوة 2: إضافة Controller في الباك إند

انسخ دالة `updateFileContent` من `backend_file_controller_updateFileContent.js` إلى ملف `fileController.js` في الباك إند.

### الخطوة 3: تحديث الفرونت إند

الكود محدث بالفعل في:
- ✅ `lib/services/file_service.dart` - دالة `updateFileContent` جديدة
- ✅ `lib/views/fileViewer/textViewer.dart` - استخدام الدالة الجديدة
- ✅ `lib/services/api_endpoints.dart` - endpoint موجود

---

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

---

## ✅ الفوائد

1. **تنظيم الكود**: فصل منطق تحديث الملف في دالة منفصلة
2. **إعادة الاستخدام**: يمكن استخدام `FileService.updateFileContent` في أي مكان
3. **سهولة الصيانة**: جميع التحديثات في مكان واحد
4. **معالجة أخطاء أفضل**: معالجة شاملة للأخطاء
5. **Logging مفصل**: تسجيل مفصل لجميع العمليات

---

## 🔄 التحديثات المستقبلية

- إضافة دعم للـ versioning (الاحتفاظ بنسخ قديمة)
- إضافة دعم للـ rollback (التراجع عن التحديث)
- إضافة progress indicator أثناء التحديث
- إضافة دعم للـ diff (مقارنة الملفات)

---

## 📝 ملاحظات

1. **الملفات النصية**: يتم استبدالها تلقائياً بنفس الاسم والمسار
2. **الملفات الأخرى**: يمكن اختيار وضع الاستبدال أو النسخة الجديدة
3. **الأمان**: التحقق من أن المستخدم يملك الملف قبل التحديث
4. **الأداء**: معالجة في الخلفية للملفات الكبيرة





