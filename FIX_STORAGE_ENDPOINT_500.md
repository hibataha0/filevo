# 🔧 إصلاح خطأ 500 في `/api/v1/files/storage`

## ❌ المشكلة

الباك إند يرجع **500 (Internal Server Error)** عند محاولة جلب معلومات المساحة:
```
GET /api/v1/files/storage 500
```

**خطأ شائع:**
```
Cast to ObjectId failed for value "storage" (type string) at path "_id" for model "File"
```

## ⚠️ **سبب شائع جداً: ترتيب Routes خاطئ!**

إذا كنت ترى خطأ `Cast to ObjectId failed for value "storage"`، هذا يعني أن route `/storage` يتم تفسيره كـ `/:id` حيث `:id` = "storage".

**الحل:** راجع ملف `FIX_STORAGE_ROUTE_CONFLICT.md` لإصلاح ترتيب الـ routes.

## ✅ الحل

### الخطوة 1: إضافة `getStorageInfo` إلى `fileController.js`

افتح ملف `controllers/fileController.js` في الباك إند وأضف الكود التالي:

```javascript
const asyncHandler = require('express-async-handler');
const File = require('../models/fileModel');
const User = require('../models/userModel');
const mongoose = require('mongoose');

// ✅ دالة مساعدة لحساب المساحة المستخدمة للمستخدم
async function calculateUserStorageUsed(userId) {
  try {
    // ✅ تحويل userId إلى ObjectId إذا كان string
    const userIdObject = mongoose.Types.ObjectId.isValid(userId) 
      ? new mongoose.Types.ObjectId(userId) 
      : userId;

    const result = await File.aggregate([
      {
        $match: {
          userId: userIdObject,
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
    return totalSize || 0;
  } catch (error) {
    console.error('❌ Error calculating user storage used:', error);
    console.error('❌ Error stack:', error.stack);
    return 0;
  }
}

// @desc    Get user storage information
// @route   GET /api/v1/files/storage
// @access  Private
exports.getStorageInfo = asyncHandler(async (req, res) => {
  try {
    // ✅ التحقق من وجود المستخدم
    if (!req.user || !req.user._id) {
      return res.status(401).json({ 
        success: false,
        message: 'Unauthorized. Please login first.' 
      });
    }

    const userId = req.user._id;

    // ✅ جلب بيانات المستخدم
    const user = await User.findById(userId).select('storageLimit storageUsed');
    if (!user) {
      return res.status(404).json({ 
        success: false,
        message: 'User not found' 
      });
    }

    // ✅ حساب المساحة المستخدمة الفعلية من الملفات
    const actualStorageUsed = await calculateUserStorageUsed(userId);

    // ✅ تحديث المساحة المستخدمة إذا كان هناك فرق (أكثر من 1KB)
    if (Math.abs(actualStorageUsed - (user.storageUsed || 0)) > 1024) {
      await User.findByIdAndUpdate(userId, { 
        storageUsed: actualStorageUsed 
      });
      user.storageUsed = actualStorageUsed;
    }

    // ✅ حساب المساحة المتاحة والنسبة المئوية
    const storageLimit = user.storageLimit || (10 * 1024 * 1024 * 1024); // Default 10 GB
    const storageUsed = user.storageUsed || 0;
    const storageAvailable = storageLimit - storageUsed;
    const storagePercentage = storageLimit > 0 
      ? (storageUsed / storageLimit) * 100 
      : 0;

    // ✅ دالة لتنسيق البايت
    const formatBytes = (bytes) => {
      if (!bytes || bytes === 0 || isNaN(bytes)) return '0 Bytes';
      const k = 1024;
      const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
      const i = Math.floor(Math.log(bytes) / Math.log(k));
      return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    };

    // ✅ إرجاع النتيجة
    res.status(200).json({
      success: true,
      message: 'Storage information retrieved successfully',
      data: {
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
    console.error('❌ Error stack:', error.stack);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: process.env.NODE_ENV === 'development' 
        ? error.message 
        : 'Failed to retrieve storage information',
    });
  }
});

// ✅ Export الدالة المساعدة أيضاً
exports.calculateUserStorageUsed = calculateUserStorageUsed;
```

### الخطوة 2: إضافة Route في `routes/fileRoutes.js`

افتح ملف `routes/fileRoutes.js` (أو `routes/fileRoutes.js`) وأضف:

```javascript
const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const fileController = require('../controllers/fileController');

// ⚠️ مهم جداً: يجب أن يكون هذا route قبل route /:id الديناميكي
router.get('/storage', protect, fileController.getStorageInfo);

// ... باقي الـ routes مثل:
// router.get('/:id', protect, fileController.getFileDetails);
// router.get('/:id/download', protect, fileController.downloadFile);
// router.post('/upload', protect, upload.single('file'), fileController.uploadFile);
// router.delete('/:id', protect, fileController.deleteFile);

module.exports = router;
```

### الخطوة 3: التأكد من وجود `storageLimit` و `storageUsed` في User Model

افتح ملف `models/userModel.js` وتأكد من وجود الحقول التالية:

```javascript
const userSchema = new mongoose.Schema({
  // ... باقي الحقول ...
  
  storageLimit: {
    type: Number,
    default: 10 * 1024 * 1024 * 1024, // 10 GB بالبايت
  },
  storageUsed: {
    type: Number,
    default: 0,
  },
  
  // ... باقي الحقول ...
});
```

إذا لم تكن موجودة، أضفها:

```javascript
// في ملف models/userModel.js
userSchema.add({
  storageLimit: {
    type: Number,
    default: 10 * 1024 * 1024 * 1024, // 10 GB بالبايت
  },
  storageUsed: {
    type: Number,
    default: 0,
  },
});
```

### الخطوة 4: تحديث المستخدمين الموجودين (اختياري)

إذا كان لديك مستخدمين موجودين في قاعدة البيانات، يمكنك تشغيل هذا الكود مرة واحدة لتحديث `storageLimit`:

```javascript
// في ملف scripts/updateUsersStorage.js أو في console MongoDB
const mongoose = require('mongoose');
const User = require('../models/userModel');

async function updateUsersStorage() {
  try {
    await mongoose.connect('mongodb://localhost:27017/your_database'); // استبدل بالـ connection string الخاص بك
    
    const result = await User.updateMany(
      { storageLimit: { $exists: false } },
      { $set: { storageLimit: 10 * 1024 * 1024 * 1024, storageUsed: 0 } }
    );
    
    console.log(`✅ Updated ${result.modifiedCount} users`);
    await mongoose.disconnect();
  } catch (error) {
    console.error('❌ Error:', error);
  }
}

updateUsersStorage();
```

## 🔍 التحقق من الإصلاح

بعد إضافة الكود:

1. **أعد تشغيل الباك إند**
2. **جرب الـ endpoint:**
   ```bash
   GET /api/v1/files/storage
   Authorization: Bearer <your_token>
   ```

3. **يجب أن تحصل على استجابة:**
   ```json
   {
     "success": true,
     "message": "Storage information retrieved successfully",
     "data": {
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

## ⚠️ ملاحظات مهمة

1. **ترتيب الـ Routes مهم جداً:** يجب أن يكون `/storage` **قبل** `/files/:id` الديناميكي لتجنب التعارض.

2. **إذا استمر الخطأ 500:**
   - تحقق من logs الباك إند لمعرفة الخطأ الدقيق
   - تأكد من أن `File` model موجود ويعمل بشكل صحيح
   - تأكد من أن `User` model يحتوي على `storageLimit` و `storageUsed`

3. **إذا كان الـ response body مختلف:**
   - تأكد من أن الـ response يحتوي على `data` وليس `storage` (كما في الكود أعلاه)
   - أو عدّل الفرونت إند لاستخدام `data` بدلاً من `storage`

## 📝 ملاحظة على Response Format

إذا كان الباك إند يرجع `data` بدلاً من `storage` في الـ response:

في `lib/services/file_service.dart`، غيّر:
```dart
final storageData = data['storage'] ?? {};
```

إلى:
```dart
final storageData = data['data'] ?? data['storage'] ?? {};
```
