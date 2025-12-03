# 🔧 إصلاح دالة getFilesByCategory في Backend

## المشكلة
عند نقل ملف من الجذر إلى مجلد، الملف لا يزال يظهر في التصنيفات (categories) التي لا تحتوي على مجلد أب.

## الحل

افتح ملف `fileController.js` في Backend (على الأرجح في `E:\Projects Flutter\Filevo_Backend\controllers\fileController.js`)

ابحث عن دالة `getFilesByCategory` واستبدلها بالكود التالي:

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
    // هذا يضمن عرض فقط الملفات بدون مجلد أب
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

## التغيير الرئيسي

**قبل:**
```javascript
const query = { category, userId, isDeleted: false };
if (parentFolderId) {
  query.parentFolderId = parentFolderId;
}
// ❌ المشكلة: عندما يكون parentFolderId هو null، لا يتم إضافته
```

**بعد:**
```javascript
const query = { category, userId, isDeleted: false };
if (parentFolderId && parentFolderId !== 'null' && parentFolderId !== '') {
  query.parentFolderId = parentFolderId;
} else {
  query.parentFolderId = null; // ✅ إضافة null صراحة
}
```

## إصلاح إضافي: getCategoriesStats

إذا كنت تريد أن تحسب `getCategoriesStats` فقط الملفات بدون مجلد أب، أضف `parentFolderId: null` في الـ aggregation:

```javascript
const aggregationResult = await File.aggregate([
    {
        $match: {
            userId: userIdObjectId,
            isDeleted: false,
            parentFolderId: null // ✅ إضافة هذا السطر
        }
    },
    // ... باقي الكود
]);
```

## الخطوات

1. افتح `E:\Projects Flutter\Filevo_Backend\controllers\fileController.js`
2. ابحث عن `exports.getFilesByCategory`
3. استبدلها بالكود أعلاه
4. أعد تشغيل Backend
5. اختبر نقل ملف من الجذر إلى مجلد




