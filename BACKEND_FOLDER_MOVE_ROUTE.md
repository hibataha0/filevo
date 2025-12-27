# 🔧 إضافة Route لنقل المجلدات في Backend

## المشكلة
الـ route `/api/v1/folders/:id/move` غير موجود في Backend، مما يسبب خطأ "Can't find this route".

## الحل

### الخطوة 1: إضافة Route في ملف Routes

افتح ملف routes الخاص بالـ folders في Backend (على الأرجح `routes/folderRoutes.js` أو `routes/folders.js`)

**أضف الـ route التالي:**

```javascript
const folderController = require('../controllers/folderController'); // أو مسار الملف الصحيح
const { protect } = require('../middleware/authMiddleware');

// ✅ إضافة Route لنقل المجلد
router.put('/folders/:id/move', protect, folderController.moveFolder);
```

**⚠️ مهم:** تأكد من أن هذا الـ route يقع **قبل** أي routes ديناميكية مثل `/folders/:id` (PUT أو DELETE).

**مثال على ترتيب Routes الصحيح:**

```javascript
// ✅ Routes محددة أولاً (قبل routes ديناميكية)
router.get('/folders', protect, folderController.getAllFolders);
router.post('/folders/create', protect, folderController.createFolder);
router.post('/folders/upload', protect, folderController.uploadFolder);

// ✅ Routes مع paths محددة
router.put('/folders/:id/move', protect, folderController.moveFolder); // ✅ أضف هذا
router.put('/folders/:id/star', protect, folderController.toggleStarFolder);
router.put('/folders/:id/restore', protect, folderController.restoreFolder);
router.get('/folders/:id/contents', protect, folderController.getFolderContents);
router.get('/folders/:id/size', protect, folderController.getFolderSize);

// ✅ Routes ديناميكية في النهاية
router.get('/folders/:id', protect, folderController.getFolderDetails);
router.put('/folders/:id', protect, folderController.updateFolder);
router.delete('/folders/:id', protect, folderController.deleteFolder);
```

### الخطوة 2: التأكد من وجود Controller Function

تأكد من أن دالة `moveFolder` موجودة في ملف controller (مثل `controllers/folderController.js`).

**الكود موجود في:** `moveFolder_FIXED_CODE.js` في مجلد Flutter

**انسخ الدالة `moveFolder` من `moveFolder_FIXED_CODE.js` إلى ملف controller في Backend.**

### الخطوة 3: التأكد من الـ Imports المطلوبة

في ملف controller، تأكد من وجود الـ imports التالية:

```javascript
const asyncHandler = require('express-async-handler');
const Folder = require('../models/folderModel');
const ApiError = require('../utils/apiError'); // أو مسار الملف الصحيح
const { calculateFolderSizeRecursive } = require('../services/folderService'); // أو مسار الملف الصحيح
const { logActivity } = require('../services/activityLogService'); // أو مسار الملف الصحيح
```

### الخطوة 4: اختبار الـ Route

بعد إضافة الـ route، اختبره:

1. أعد تشغيل الـ backend server
2. جرب نقل مجلد من الفرونت إند
3. يجب أن يعمل بدون خطأ

## ملاحظات

- ✅ الـ route يجب أن يكون `PUT /api/v1/folders/:id/move`
- ✅ يجب استخدام middleware `protect` للتحقق من authentication
- ✅ الـ route يجب أن يكون قبل routes ديناميكية مثل `/folders/:id`
- ✅ تأكد من أن `moveFolder` function موجودة في controller

## في حالة وجود مشاكل

1. تأكد من أن الـ route يقع قبل routes ديناميكية
2. تأكد من أن middleware `protect` موجود ويعمل
3. تأكد من أن controller function موجودة ومصدرة بشكل صحيح
4. تحقق من console الـ backend لأي أخطاء







