# 📋 إضافة `getCategoriesStats` إلى Backend

## المطلوب
إضافة دالة `getCategoriesStats` إلى ملف **File Controller** في Backend الخاص بك.

---

## 🔧 الخطوات

### 1. افتح ملف File Controller
الموقع المتوقع:
```
E:\Projects Flutter\Filevo_Backend\controllers\fileController.js
```
أو
```
E:\Projects Flutter\Filevo_Backend\controllers\filesController.js
```

### 2. تأكد من وجود الـ Imports التالية في أعلى الملف:
```javascript
const asyncHandler = require('express-async-handler');
const File = require('../models/fileModel');
const mongoose = require('mongoose');
```

### 3. أضف الدالة التالية في نهاية الملف (قبل `module.exports`):

```javascript
// ✅ Get categories statistics (count and size for each category)
// @desc    Get categories statistics - يحسب حجم جميع الملفات وعددهم بناءً على التصنيف
// @route   GET /api/files/categories/stats
// @access  Private
exports.getCategoriesStats = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    
    // ✅ قائمة التصنيفات (بأحرف صغيرة لتطابق Flutter)
    const categories = ['images', 'videos', 'audio', 'compressed', 'applications', 'documents', 'code', 'other'];
    
    // ✅ استخدام MongoDB Aggregation Pipeline لحساب جميع الإحصائيات في query واحد (أكثر كفاءة)
    // ✅ هذا يحسب جميع الملفات بغض النظر عن موقعها (في الجذر أو داخل مجلدات)
    const userIdObjectId = mongoose.Types.ObjectId.isValid(userId) ? new mongoose.Types.ObjectId(userId) : userId;
    
    // ✅ Aggregation واحد لحساب جميع التصنيفات
    const aggregationResult = await File.aggregate([
        {
            $match: {
                userId: userIdObjectId,
                isDeleted: false
            }
        },
        {
            $group: {
                _id: { 
                    $toLower: { $ifNull: ['$category', 'other'] }
                }, // ✅ تحويل إلى أحرف صغيرة للتطابق، مع معالجة null
                filesCount: { $sum: 1 },
                totalSize: { $sum: '$size' }
            }
        }
    ]);
    
    // ✅ تحويل النتيجة إلى Map لتسهيل البحث
    const statsMap = new Map();
    aggregationResult.forEach(item => {
        const categoryKey = (item._id || '').toLowerCase();
        statsMap.set(categoryKey, {
            filesCount: Number(item.filesCount) || 0,
            totalSize: Number(item.totalSize) || 0
        });
    });
    
    // ✅ إنشاء الإحصائيات لجميع التصنيفات (حتى التي لا تحتوي على ملفات)
    const stats = categories.map(category => {
        const stat = statsMap.get(category.toLowerCase());
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
    
    // ✅ Log للتحقق من الإحصائيات
    console.log(`📊 Categories stats calculated for user ${userId}:`);
    stats.forEach(stat => {
        if (stat.filesCount > 0) {
            console.log(`   ${stat.category}: ${stat.filesCount} files, ${formatBytes(stat.totalSize)}`);
        }
    });
    console.log(`   Total: ${totalStats.totalFiles} files, ${formatBytes(totalStats.totalSize)}`);
    
    res.status(200).json({
        message: "Categories statistics retrieved successfully",
        categories: stats.map(stat => ({
            category: stat.category,
            filesCount: stat.filesCount,
            totalSize: stat.totalSize
        })),
        totals: {
            totalFiles: totalStats.totalFiles,
            totalSize: totalStats.totalSize,
            totalSizeFormatted: formatBytes(totalStats.totalSize)
        }
    });
});
```

---

## 4. أضف Route في ملف Routes

افتح ملف routes (على الأرجح `routes/fileRoutes.js` أو في `server.js`):

```javascript
const fileController = require('../controllers/fileController'); // أو مسار الملف الصحيح

// ✅ إضافة Route جديد لإحصائيات التصنيفات
router.get('/files/categories/stats', protect, fileController.getCategoriesStats);
```

**⚠️ مهم:** تأكد من أن هذا Route يأتي **قبل** أي routes ديناميكية مثل `/files/:id`

---

## 5. التحقق

بعد إضافة الكود:
1. أعد تشغيل Backend
2. تحقق من Console - يجب أن ترى logs عند فتح صفحة المجلدات
3. افتح Flutter - يجب أن ترى عدد الملفات والحجم لكل تصنيف

---

## 📝 ملاحظات

- ✅ الدالة تحسب **جميع** الملفات بغض النظر عن موقعها (في الجذر أو داخل مجلدات)
- ✅ تستخدم **Aggregation Pipeline** (أكثر كفاءة من multiple queries)
- ✅ التصنيفات بأحرف صغيرة لتطابق Flutter
- ✅ تتعامل مع حالات `null` في التصنيفات

---

## 🔍 في حالة وجود مشاكل

إذا كانت التصنيفات في قاعدة البيانات بأحرف كبيرة (مثل `Images` بدلاً من `images`)، يمكن تعديل الكود ليتعامل مع كلا الحالتين.


