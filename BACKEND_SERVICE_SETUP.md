# 📁 إعداد Service و Controller لحساب حجم المجلد وعدد الملفات

## ✅ الملفات المُنشأة

### 1. `backend_folder_calculation_service.js`
**Service** يحتوي على الدوال المساعدة لحساب حجم المجلد وعدد الملفات:

#### الدوال المتاحة:
- `calculateFolderSizeRecursive(folderId)` - حساب الحجم الكلي للمجلد (recursive)
- `calculateFolderFilesCountRecursive(folderId)` - حساب عدد الملفات الكلي (recursive)
- `calculateFolderStatsRecursive(folderId)` - حساب الحجم والعدد معاً (أكثر كفاءة)

#### مثال الاستخدام:
```javascript
const {
    calculateFolderSizeRecursive,
    calculateFolderFilesCountRecursive,
    calculateFolderStatsRecursive
} = require('./backend_folder_calculation_service');

// حساب الحجم فقط
const size = await calculateFolderSizeRecursive(folderId);

// حساب العدد فقط
const filesCount = await calculateFolderFilesCountRecursive(folderId);

// حساب كلاهما معاً (أكثر كفاءة)
const stats = await calculateFolderStatsRecursive(folderId);
// stats = { size: 1024000, filesCount: 50 }
```

---

### 2. `backend_folder_calculation_controller.js`
**Controller** يحتوي على endpoints للوصول للدوال:

#### Endpoints المتاحة:

1. **GET `/api/folders/:id/size`**
   - حساب حجم مجلد معين
   - Returns: `{ size, sizeFormatted }`

2. **GET `/api/folders/:id/files-count`**
   - حساب عدد الملفات في مجلد معين
   - Returns: `{ filesCount }`

3. **GET `/api/folders/:id/stats`** ⭐ (الأفضل)
   - حساب الحجم وعدد الملفات معاً
   - Returns: `{ stats: { size, sizeFormatted, filesCount } }`

---

## 🔧 التحديثات على الملفات الموجودة

### `backend_folder_controller_complete.js`
- ✅ تم إضافة `require` للـ service في البداية
- ✅ تم استبدال الدوال المحلية بالاستيراد من الـ service
- ✅ جميع endpoints الموجودة تستخدم الآن الدوال من الـ service

---

## 📝 كيفية إضافة Routes في Backend

في ملف routes الخاص بك (مثل `routes/folderRoutes.js`):

```javascript
const folderCalculationController = require('../controllers/folderCalculationController');
const { protect } = require('../middleware/authMiddleware'); // أو middleware الخاص بك

// ✅ إضافة routes للإحصائيات
router.get('/folders/:id/size', protect, folderCalculationController.getFolderSize);
router.get('/folders/:id/files-count', protect, folderCalculationController.getFolderFilesCount);
router.get('/folders/:id/stats', protect, folderCalculationController.getFolderStats);
```

**ملاحظة:** تأكد من أن هذه routes قبل أي routes ديناميكية مثل `/folders/:id`.

---

## ✅ الفوائد

1. **تنظيم الكود:** فصل الدوال المساعدة في service منفصل
2. **إعادة الاستخدام:** يمكن استخدام الدوال في أي مكان
3. **الكفاءة:** دالة `calculateFolderStatsRecursive` تحسب كل شيء في مرة واحدة
4. **سهولة الصيانة:** جميع الدوال المساعدة في مكان واحد
5. **Endpoints منفصلة:** يمكن الوصول للإحصائيات مباشرة عبر API

---

## 🔄 استخدام الدوال في الكود الموجود

جميع endpoints في `backend_folder_controller_complete.js` تستخدم الآن الدوال من الـ service:
- `getAllFolders`
- `getFolderDetails`
- `getFolderContents`
- `getFoldersSharedWithMe`
- `getSharedFolderDetailsInRoom`
- `getAllItems`
- `getRecentFolders`
- `getStarredFolders`
- `getTrashFolders`

كلها تستخدم الآن:
```javascript
const size = await calculateFolderSizeRecursive(folderId);
const filesCount = await calculateFolderFilesCountRecursive(folderId);
```

---

## 📚 مثال كامل للاستخدام

```javascript
// في أي controller
const {
    calculateFolderStatsRecursive
} = require('../services/backend_folder_calculation_service');

exports.someFunction = async (req, res) => {
    const folderId = req.params.id;
    
    // ✅ حساب الإحصائيات بشكل سريع
    const stats = await calculateFolderStatsRecursive(folderId);
    
    res.json({
        size: stats.size,
        filesCount: stats.filesCount
    });
};
```


