# 🔧 إصلاح مشكلة عرض الملفات في التصنيفات بعد النقل

## المشكلة
عند نقل ملف من الجذر إلى مجلد، الملف لا يزال يظهر في التصنيفات (categories) التي لا تحتوي على مجلد أب.

## السبب
دالة `getFilesByCategory` لا تضيف `parentFolderId: null` إلى الـ query عندما نريد الملفات من الجذر فقط، لذلك قد تعرض الملفات من جميع المجلدات.

## الحل

### 1. إصلاح دالة `getFilesByCategory`

استبدل دالة `getFilesByCategory` في ملف `fileController.js`:

```javascript
// @desc    Get files by category (for logged-in user only)
// @route   GET /api/files/category/:category
// @access  Private
exports.getFilesByCategory = asyncHandler(async (req, res) => {
  const { category } = req.params;
  const userId = req.user._id;
  const parentFolderId = req.query.parentFolderId || null;

  // ✅ Build query
  const query = { 
    category, 
    userId, 
    isDeleted: false 
  };
  
  // ✅ إصلاح: إضافة parentFolderId إلى الـ query دائماً
  if (parentFolderId && parentFolderId !== 'null' && parentFolderId !== '') {
    query.parentFolderId = parentFolderId;
  } else {
    // ✅ عند طلب الملفات من الجذر، يجب إضافة parentFolderId: null
    query.parentFolderId = null;
  }

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

### 2. إصلاح دالة `getCategoriesStats` (اختياري)

إذا كنت تريد أن تحسب `getCategoriesStats` فقط الملفات بدون مجلد أب (من الجذر):

```javascript
// ✅ Get categories statistics
exports.getCategoriesStats = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    const mongoose = require('mongoose');
    
    const categories = ['Images', 'Videos', 'Audio', 'Documents', 'Compressed', 'Applications', 'Code', 'Others'];
    const userIdObjectId = mongoose.Types.ObjectId.isValid(userId) ? new mongoose.Types.ObjectId(userId) : userId;
    
    // ✅ إصلاح: إضافة parentFolderId: null لحساب فقط الملفات من الجذر
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
    
    // ... باقي الكود
});
```

## التغييرات الرئيسية

### قبل (المشكلة):
```javascript
const query = { category, userId, isDeleted: false };
if (parentFolderId) {
  query.parentFolderId = parentFolderId;
}
// ❌ عندما يكون parentFolderId هو null، لا يتم إضافته إلى الـ query
// لذلك قد تعرض الملفات من جميع المجلدات
```

### بعد (الحل):
```javascript
const query = { category, userId, isDeleted: false };
if (parentFolderId && parentFolderId !== 'null' && parentFolderId !== '') {
  query.parentFolderId = parentFolderId;
} else {
  query.parentFolderId = null; // ✅ إضافة null صراحة
}
```

## الخطوات

1. افتح ملف `fileController.js` في Backend
2. ابحث عن دالة `exports.getFilesByCategory`
3. استبدلها بالكود المحدث
4. (اختياري) حدث دالة `getCategoriesStats` أيضاً
5. أعد تشغيل Backend
6. اختبر نقل ملف من الجذر إلى مجلد وتحقق من أنه لم يعد يظهر في التصنيفات

## النتيجة

- ✅ الملفات المنقولة من الجذر إلى مجلد لن تظهر في التصنيفات
- ✅ التصنيفات تعرض فقط الملفات بدون مجلد أب
- ✅ إحصائيات التصنيفات تحسب فقط الملفات من الجذر




