# 🔧 إصلاح دالة getFilesByCategory - عرض فقط الملفات بدون مجلد أب

## المشكلة
عند نقل ملف من الجذر إلى مجلد، الملف لا يزال يظهر في التصنيفات (categories) التي لا تحتوي على مجلد أب.

## السبب
دالة `getFilesByCategory` لا تضيف `parentFolderId: null` إلى الـ query عندما نريد الملفات من الجذر فقط.

## الحل

### الخطوة 1: افتح ملف fileController.js
افتح ملف `fileController.js` في مجلد `controllers` في Backend.

### الخطوة 2: ابحث عن دالة `getFilesByCategory`
ابحث عن دالة `exports.getFilesByCategory` في الملف.

### الخطوة 3: استبدل الكود

استبدل دالة `getFilesByCategory` بالكود التالي:

```javascript
// @desc    Get files by category (for logged-in user only)
// @route   GET /api/files/category/:category
// @access  Private
exports.getFilesByCategory = asyncHandler(async (req, res) => {
  const { category } = req.params; // File category from URL
  const userId = req.user._id;
  const parentFolderId = req.query.parentFolderId || null;

  // ✅ Build query - إصلاح: إضافة parentFolderId: null عند طلب الملفات من الجذر
  const query = { 
    category, 
    userId, 
    isDeleted: false 
  };
  
  // ✅ إصلاح: إضافة parentFolderId إلى الـ query دائماً
  // إذا كان parentFolderId موجوداً، استخدمه
  // إذا كان null أو undefined، استخدم null (الجذر فقط)
  if (parentFolderId && parentFolderId !== 'null' && parentFolderId !== '') {
    query.parentFolderId = parentFolderId;
  } else {
    // ✅ عند طلب الملفات من الجذر، يجب إضافة parentFolderId: null
    query.parentFolderId = null;
  }

  // جلب الملفات الخاصة بالمستخدم في نفس الفئة
  const files = await File.find(query);

  if (!files || files.length === 0) {
    return res.status(201).json({
      message: `No files found for user in category: ${category}`,
      files: []
    });
  }

  res.status(200).json({
    message: `Files in category: ${category}`,
    count: files.length,
    files,
  });
});
```

## التغييرات الرئيسية

### قبل (الكود القديم):
```javascript
const query = { category, userId, isDeleted: false };
if (parentFolderId) {
  query.parentFolderId = parentFolderId;
}
// ❌ المشكلة: عندما يكون parentFolderId هو null، لا يتم إضافته إلى الـ query
// لذلك قد تعرض الملفات من جميع المجلدات
```

### بعد (الكود الجديد):
```javascript
const query = { category, userId, isDeleted: false };
if (parentFolderId && parentFolderId !== 'null' && parentFolderId !== '') {
  query.parentFolderId = parentFolderId;
} else {
  // ✅ عند طلب الملفات من الجذر، يجب إضافة parentFolderId: null
  query.parentFolderId = null;
}
```

## إصلاح إضافي: تحديث getCategoriesStats

إذا كنت تريد أن تحسب `getCategoriesStats` فقط الملفات بدون مجلد أب (من الجذر)، استبدل الدالة بالكود التالي:

```javascript
// ✅ Get categories statistics (count and size for each category)
// @desc    Get categories statistics - يحسب حجم جميع الملفات وعددهم بناءً على التصنيف
// @route   GET /api/files/categories/stats
// @access  Private
exports.getCategoriesStats = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    const mongoose = require('mongoose');
    
    // ✅ قائمة التصنيفات (حسب الموديل - بأحرف كبيرة)
    const categories = ['Images', 'Videos', 'Audio', 'Documents', 'Compressed', 'Applications', 'Code', 'Others'];
    
    // ✅ استخدام MongoDB Aggregation Pipeline لحساب جميع الإحصائيات في query واحد (أكثر كفاءة)
    // ✅ إصلاح: حساب فقط الملفات بدون مجلد أب (parentFolderId: null)
    const userIdObjectId = mongoose.Types.ObjectId.isValid(userId) ? new mongoose.Types.ObjectId(userId) : userId;
    
    // ✅ Aggregation واحد لحساب جميع التصنيفات - فقط الملفات من الجذر
    const aggregationResult = await File.aggregate([
        {
            $match: {
                userId: userIdObjectId,
                isDeleted: false,
                parentFolderId: null // ✅ فقط الملفات بدون مجلد أب
            }
        },
        {
            $group: {
                _id: '$category',
                filesCount: { $sum: 1 },
                totalSize: { $sum: '$size' }
            }
        }
    ]);
    
    // ✅ تحويل النتيجة إلى Map لتسهيل البحث
    const statsMap = new Map();
    aggregationResult.forEach(item => {
        statsMap.set(item._id, {
            filesCount: Number(item.filesCount) || 0,
            totalSize: Number(item.totalSize) || 0
        });
    });
    
    // ✅ إنشاء الإحصائيات لجميع التصنيفات (حتى التي لا تحتوي على ملفات)
    const stats = categories.map(category => {
        const stat = statsMap.get(category);
        return {
            category: category,
            filesCount: stat ? stat.filesCount : 0,
            totalSize: stat ? stat.totalSize : 0
        };
    });
    
    // ✅ حساب الإجمالي العام
    const totalStats = stats.reduce((acc, stat) => {
        acc.totalFiles += stat.filesCount;
        acc.totalSize += stat.totalSize;
        return acc;
    }, { totalFiles: 0, totalSize: 0 });
    
    // ✅ تنسيق الحجم بشكل مقروء
    const formatBytes = (bytes) => {
        if (bytes === 0) return '0 Bytes';
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    };
    
    res.status(200).json({
        message: "Categories statistics retrieved successfully",
        categories: stats.map(stat => ({
            ...stat,
            totalSizeFormatted: formatBytes(stat.totalSize)
        })),
        totals: {
            totalFiles: totalStats.totalFiles,
            totalSize: totalStats.totalSize,
            totalSizeFormatted: formatBytes(totalStats.totalSize)
        }
    });
});
```

## ملاحظات

- ✅ `getFilesByCategory` الآن تعرض فقط الملفات من الجذر عندما يكون `parentFolderId` هو `null`
- ✅ `getCategoriesStats` الآن تحسب فقط الملفات من الجذر (بدون مجلد أب)
- ✅ الملفات التي تم نقلها إلى مجلد لن تظهر في التصنيفات بعد الآن

## التحقق من الإصلاح

بعد تطبيق الإصلاح:

1. أعد تشغيل Backend
2. انقل ملف من الجذر إلى مجلد
3. تحقق من أن الملف لم يعد يظهر في التصنيفات
4. تحقق من أن إحصائيات التصنيفات لا تشمل الملفات المنقولة

