# 🔧 إصلاح خطأ 500 في endpoint `/api/v1/files/storage`

## ❌ المشكلة الحالية

```
GET /api/v1/files/storage 500 86.184 ms - 1631
GET /api/v1/users/getMe 500 163.660 ms - 351
```

الـ endpoint `/api/v1/files/storage` يعطي خطأ 500 (Internal Server Error). هذا يعني أن:
- الـ endpoint غير موجود في الباك إند، أو
- هناك خطأ في تنفيذ الـ endpoint (خطأ في الكود، models غير موجودة، إلخ)

## ✅ الحل: إضافة الـ Endpoint في الباك إند

### الخطوة 1: إضافة الدالة في Controller

**افتح ملف `controllers/fileController.js` في الباك إند** وأضف هذا الكود في نهاية الملف:

```javascript
const asyncHandler = require('express-async-handler');
const mongoose = require('mongoose');
const File = require('../models/fileModel');
const User = require('../models/userModel');

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
        message: 'Unauthorized. Please login first.' 
      });
    }

    const userId = req.user._id;

    // ✅ جلب بيانات المستخدم
    const user = await User.findById(userId).select('storageLimit storageUsed');
    if (!user) {
      return res.status(404).json({ 
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

// ✅ Export الدالة المساعدة أيضاً (في حالة الحاجة إليها في ملفات أخرى)
exports.calculateUserStorageUsed = calculateUserStorageUsed;
```

### الخطوة 2: إضافة Route

**افتح ملف `routes/fileRoutes.js`** (أو أي ملف routes للـ files) وأضف هذا الـ route:

```javascript
const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const fileController = require('../controllers/fileController');

// ✅ يجب أن يكون هذا route قبل route /files/:id الديناميكي
// ✅ هذا مهم جداً لتجنب التعارض!
router.get('/storage', protect, fileController.getStorageInfo);

// ... باقي الـ routes مثل:
// router.get('/:id', protect, fileController.getFileDetails);
// router.get('/:id/download', protect, fileController.downloadFile);

module.exports = router;
```

**⚠️ مهم جداً:** يجب أن يكون route `/storage` **قبل** أي route ديناميكي مثل `/files/:id` أو `/files/:id/download` لتجنب التعارض.

### الخطوة 3: التحقق من User Model

تأكد من أن `models/userModel.js` يحتوي على الحقول التالية:

```javascript
const userSchema = new mongoose.Schema({
  // ... الحقول الأخرى
  name: {
    type: String,
    trim: true,
    required: [true, "Name is required"],
  },
  email: {
    type: String,
    required: [true, "Email is required"],
    unique: true,
    lowercase: true,
  },
  password: {
    type: String,
    required: [true, "Password is required"],
    minlength: [6, "Too short password"],
  },
  // ✅ إضافة حقول المساحة التخزينية
  storageLimit: {
    type: Number,
    default: 10 * 1024 * 1024 * 1024, // 10 GB بالبايت (10 * 1024^3)
  },
  storageUsed: {
    type: Number,
    default: 0, // المساحة المستخدمة بالبايت
  },
  // ... باقي الحقول
}, { timestamps: true });
```

### الخطوة 4: التحقق من File Model

تأكد من أن `models/fileModel.js` يحتوي على الحقول التالية:

```javascript
const fileSchema = new mongoose.Schema({
  // ... الحقول الأخرى
  name: {
    type: String,
    required: true,
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  size: {
    type: Number,
    default: 0,
    required: true,
  },
  isDeleted: {
    type: Boolean,
    default: false,
  },
  // ... باقي الحقول
}, { timestamps: true });
```

### الخطوة 5: التحقق من Route الرئيسي

تأكد من أن ملف `routes/index.js` (أو `app.js` أو `server.js`) يحتوي على:

```javascript
const fileRoutes = require('./routes/fileRoutes');

// ✅ استخدام الـ routes
app.use('/api/v1', fileRoutes);
// أو
app.use('/api/v1/files', fileRoutes);
```

**⚠️ ملاحظة:** حسب طريقة تنظيم الـ routes في مشروعك:
- إذا كان route path في `fileRoutes.js` يبدأ بـ `/files/storage`، فاستخدم: `app.use('/api/v1', fileRoutes);`
- إذا كان route path في `fileRoutes.js` يبدأ بـ `/storage`، فاستخدم: `app.use('/api/v1/files', fileRoutes);`

## 🔍 حل المشاكل الشائعة

### 1. خطأ 500 Internal Server Error

**الأسباب المحتملة:**
- ✅ Model غير موجود أو غير مستورد بشكل صحيح
- ✅ خطأ في الـ aggregate query
- ✅ خطأ في تحويل userId إلى ObjectId
- ✅ خطأ في الـ middleware `protect`

**الحل:**
1. تحقق من console logs في الباك إند لمعرفة الخطأ الدقيق
2. تأكد من وجود جميع الـ imports المطلوبة
3. تأكد من أن `User` و `File` models موجودة وصحيحة
4. تأكد من أن middleware `protect` يعمل بشكل صحيح

### 2. خطأ 404 Not Found

**الأسباب المحتملة:**
- ✅ Route غير موجود أو في مكان خاطئ
- ✅ Route يقع بعد route ديناميكي

**الحل:**
- تأكد من إضافة route بشكل صحيح
- تأكد من أن route يقع **قبل** أي routes ديناميكية

### 3. خطأ 401 Unauthorized

**الأسباب المحتملة:**
- ✅ middleware `protect` يفشل
- ✅ Token غير صحيح أو منتهي الصلاحية

**الحل:**
- تحقق من أن middleware `protect` يعمل بشكل صحيح
- تحقق من أن Token صحيح وليس منتهي الصلاحية

### 4. خطأ "User not found"

**الأسباب المحتملة:**
- ✅ `req.user._id` غير موجود
- ✅ المستخدم غير موجود في قاعدة البيانات

**الحل:**
- تحقق من أن middleware `protect` يعمل بشكل صحيح
- تحقق من أن `req.user._id` موجود وصحيح

## ✅ التحقق من العمل

بعد إضافة الكود، جرب الطلب التالي:

```bash
GET http://localhost:3000/api/v1/files/storage
Authorization: Bearer <your_token>
Content-Type: application/json
```

يجب أن تحصل على استجابة مثل:

```json
{
  "success": true,
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

## 📝 ملاحظات إضافية

1. **تأكد من تحديث قاعدة البيانات:** إذا كان لديك مستخدمين موجودين بالفعل، تأكد من أنهم لديهم قيم افتراضية لـ `storageLimit` و `storageUsed`:
   ```javascript
   // في MongoDB shell أو أي أداة أخرى
   db.users.updateMany(
     { storageLimit: { $exists: false } },
     { $set: { storageLimit: 10737418240, storageUsed: 0 } }
   );
   ```

2. **اختبار الـ endpoint:** استخدم Postman أو curl لاختبار الـ endpoint:
   ```bash
   curl -X GET http://localhost:3000/api/v1/files/storage \
     -H "Authorization: Bearer YOUR_TOKEN_HERE" \
     -H "Content-Type: application/json"
   ```

3. **مراقبة الأخطاء:** راقب console logs في الباك إند لمعرفة أي أخطاء محتملة.


