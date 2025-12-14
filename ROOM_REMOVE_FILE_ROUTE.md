# 🔧 إضافة Route لإزالة ملف من الروم

## ✅ المشكلة

عند محاولة إزالة ملف من الملفات المشتركة في الروم، يظهر الخطأ:

```
Can't find this route : /api/v1/rooms/:id/share-file/:fileId
```

## ✅ الحل

يجب إضافة الـ route التالي في ملف routes الرئيسي في الباك إند:

### الـ Route المطلوب:

```javascript
DELETE /api/v1/rooms/:id/share-file/:fileId
```

### الخطوات:

1. **افتح ملف routes الرئيسي** (مثل `routes/roomRoutes.js` أو `server.js` أو `app.js`)

2. **أضف الـ route التالي:**

```javascript
const { protect } = require("../middleware/authMiddleware");
const { removeFileFromRoom } = require("../backend_room_controller");

// ✅ إزالة ملف من الغرفة
router.delete("/rooms/:id/share-file/:fileId", protect, removeFileFromRoom);
```

### مثال كامل في ملف routes:

```javascript
const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/authMiddleware");
const {
  removeFileFromRoom,
  removeFolderFromRoom,
  // ... باقي الـ controllers
} = require("../backend_room_controller");

// ✅ إزالة ملف من الغرفة
router.delete("/rooms/:id/share-file/:fileId", protect, removeFileFromRoom);

// ✅ إزالة مجلد من الغرفة
router.delete(
  "/rooms/:id/share-folder/:folderId",
  protect,
  removeFolderFromRoom
);

module.exports = router;
```

### ⚠️ ملاحظات مهمة:

1. **ترتيب Routes:** تأكد من أن الـ route يأتي قبل أي routes ديناميكية أخرى
2. **Middleware:** الـ route محمي بـ `protect` middleware
3. **المسارات:** تأكد من أن المسارات النسبية صحيحة حسب بنية مشروعك

### ✅ بعد إضافة الـ route:

1. أعد تشغيل الباك إند
2. جرب إزالة ملف من الـ frontend
3. يجب أن يعمل الآن بدون أخطاء




