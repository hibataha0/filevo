# ⚡ إصلاح سريع لخطأ 500 في `/api/v1/files/storage`

## ❌ المشكلة

```
GET /api/v1/files/storage 500 86.184 ms - 1631
```

## ✅ الحل السريع (3 خطوات)

### الخطوة 1: إضافة الكود في Controller

افتح ملف `controllers/fileController.js` في الباك إند وانسخ محتوى ملف **`backend_file_controller_getStorageInfo.js`** إلى نهاية الملف.

### الخطوة 2: إضافة Route

افتح ملف `routes/fileRoutes.js` (أو الملف الذي يحتوي على routes الملفات) وأضف في **بداية الملف** (قبل أي routes ديناميكية):

```javascript
// ✅ يجب أن يكون هذا route قبل route /:id الديناميكي
router.get('/storage', protect, fileController.getStorageInfo);
```

**⚠️ مهم:** يجب أن يكون route `/storage` **قبل** route `/files/:id` أو أي route ديناميكي آخر.

### الخطوة 3: التحقق من Models

تأكد من أن:
- ✅ `User` model يحتوي على `storageLimit` و `storageUsed`
- ✅ `File` model يحتوي على `userId`, `size`, و `isDeleted`

## ✅ التحقق من العمل

بعد التعديلات، أعد تشغيل الباك إند وجرب:

```bash
GET http://localhost:3000/api/v1/files/storage
Authorization: Bearer <your_token>
```

يجب أن تحصل على:
```json
{
  "success": true,
  "message": "Storage information retrieved successfully",
  "storage": {
    "limit": 10737418240,
    "limitFormatted": "10.00 GB",
    "used": 0,
    "usedFormatted": "0 Bytes",
    "available": 10737418240,
    "availableFormatted": "10.00 GB",
    "percentage": 0,
    "isFull": false,
    "canUpload": true
  }
}
```

## 🔍 إذا استمرت المشكلة

1. **تحقق من console logs** في الباك إند لمعرفة الخطأ الدقيق
2. **تحقق من أن middleware `protect`** يعمل بشكل صحيح
3. **تحقق من أن User و File models** موجودة وصحيحة
4. **راجع ملف `BACKEND_FIX_STORAGE_ENDPOINT_500.md`** للحل المفصل


