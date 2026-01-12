# 🔧 إعداد Endpoint للمساحة التخزينية

## ❌ المشكلة الحالية

الـ endpoint `/api/v1/files/storage` يعطي خطأ 500. هذا يعني أن الـ endpoint غير موجود أو به مشكلة.

## ✅ الحل: إضافة الـ Endpoint في الباك إند

### الخطوة 1: إضافة الدالة في Controller

انسخ محتوى ملف `backend_file_controller_getStorageInfo.js` إلى ملف `fileController.js` في الباك إند.

أو أضف هذا الكود مباشرة إلى ملف `controllers/fileController.js`:

```javascript
const asyncHandler = require('express-async-handler');
const File = require('../models/fileModel');
const User = require('../models/userModel');

// ✅ دالة مساعدة لحساب المساحة المستخدمة للمستخدم
async function calculateUserStorageUsed(userId) {
  try {
    const result = await File.aggregate([
      {
        $match: {
          userId: userId,
          isDeleted: false, // ✅ فقط الملفات غير المحذوفة
        },
      },
      {
        $group: {
          _id: null,
          totalSize: { $sum: '$size' },
        },
      },
    ]);

    const totalSize = result.length > 0 ? result[0].totalSize : 0;
    return totalSize;
  } catch (error) {
    console.error('❌ Error calculating user storage used:', error);
    return 0;
  }
}

// @desc    Get user storage information
// @route   GET /api/v1/files/storage
// @access  Private
exports.getStorageInfo = asyncHandler(async (req, res) => {
  try {
    const userId = req.user._id;

    // ✅ جلب بيانات المستخدم
    const user = await User.findById(userId).select('storageLimit storageUsed');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // ✅ حساب المساحة المستخدمة الفعلية من الملفات
    const actualStorageUsed = await calculateUserStorageUsed(userId);

    // ✅ تحديث المساحة المستخدمة إذا كان هناك فرق (أكثر من 1KB)
    if (Math.abs(actualStorageUsed - (user.storageUsed || 0)) > 1024) {
      await User.findByIdAndUpdate(userId, { storageUsed: actualStorageUsed });
      user.storageUsed = actualStorageUsed;
    }

    // ✅ حساب المساحة المتاحة والنسبة المئوية
    const storageLimit = user.storageLimit || 10 * 1024 * 1024 * 1024; // Default 10 GB
    const storageUsed = user.storageUsed || 0;
    const storageAvailable = storageLimit - storageUsed;
    const storagePercentage = (storageUsed / storageLimit) * 100;

    // ✅ دالة لتنسيق البايت
    const formatBytes = (bytes) => {
      if (bytes === 0) return '0 Bytes';
      if (!bytes || isNaN(bytes)) return '0 Bytes';
      const k = 1024;
      const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
      const i = Math.floor(Math.log(bytes) / Math.log(k));
      return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    };

    // ✅ إرجاع النتيجة
    res.status(200).json({
      message: 'Storage information retrieved successfully',
      storage: {
        limit: storageLimit,
        limitFormatted: formatBytes(storageLimit),
        used: storageUsed,
        usedFormatted: formatBytes(storageUsed),
        available: storageAvailable,
        availableFormatted: formatBytes(storageAvailable),
        percentage: parseFloat(storagePercentage.toFixed(2)),
        isFull: storageAvailable <= 0,
        canUpload: storageAvailable > 0,
      },
    });
  } catch (error) {
    console.error('❌ Error in getStorageInfo:', error);
    res.status(500).json({
      message: 'Internal server error',
      error: error.message || 'Failed to retrieve storage information',
    });
  }
});
```

### الخطوة 2: إضافة Route

في ملف `routes/fileRoutes.js` (أو أي ملف routes للـ files):

```javascript
const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const fileController = require('../controllers/fileController');

// ✅ يجب أن يكون هذا route قبل route /files/:id الديناميكي
router.get('/files/storage', protect, fileController.getStorageInfo);

// ... باقي الـ routes

module.exports = router;
```

**⚠️ مهم جداً:** يجب أن يكون route `/files/storage` قبل أي route ديناميكي مثل `/files/:id` لتجنب التعارض.

### الخطوة 3: التحقق من User Model

تأكد من أن `User` model يحتوي على الحقول التالية:

```javascript
const userSchema = new mongoose.Schema({
  // ... الحقول الأخرى
  storageLimit: {
    type: Number,
    default: 10 * 1024 * 1024 * 1024, // 10 GB بالبايت
  },
  storageUsed: {
    type: Number,
    default: 0, // المساحة المستخدمة بالبايت
  },
});
```

### الخطوة 4: التحقق من File Model

تأكد من أن `File` model يحتوي على الحقول التالية:

```javascript
const fileSchema = new mongoose.Schema({
  // ... الحقول الأخرى
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  size: {
    type: Number,
    default: 0,
  },
  isDeleted: {
    type: Boolean,
    default: false,
  },
});
```

## 🔍 حل المشاكل الشائعة

### 1. خطأ 404 Not Found
- تأكد من إضافة route بشكل صحيح
- تأكد من أن route يقع قبل أي routes ديناميكية

### 2. خطأ 500 Internal Server Error
- تحقق من console logs في الباك إند لمعرفة الخطأ الدقيق
- تأكد من وجود جميع الـ imports المطلوبة
- تأكد من أن `User` و `File` models موجودة وصحيحة

### 3. خطأ "User not found"
- تأكد من أن middleware `protect` يعمل بشكل صحيح
- تأكد من أن `req.user._id` موجود وصحيح

## ✅ التحقق من العمل

بعد إضافة الكود، جرب الطلب التالي:

```bash
GET /api/v1/files/storage
Authorization: Bearer <your_token>
```

يجب أن تحصل على استجابة مثل:

```json
{
  "message": "Storage information retrieved successfully",
  "storage": {
    "limit": 10737418240,
    "limitFormatted": "10.00 GB",
    "used": 5242880,
    "usedFormatted": "5.00 MB",
    "available": 10732175360,
    "availableFormatted": "10.00 GB",
    "percentage": 0.05,
    "isFull": false,
    "canUpload": true
  }
}
```


