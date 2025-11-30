# 🔧 إصلاح مشكلة نقل الملفات (moveFile)

## المشكلة
عند نقل ملف من الجذر إلى مجلد أو العكس، لا يتم تحديث `parentFolderId` بشكل صحيح في قاعدة البيانات:
- عند النقل من الجذر إلى مجلد: الملف لا يزال يظهر في الجذر
- عند النقل من مجلد إلى الجذر: `parentFolderId` لا يتغير إلى `null` في قاعدة البيانات

## الحل

### الخطوة 1: افتح ملف fileController.js
افتح ملف `fileController.js` في مجلد `controllers` في Backend.

### الخطوة 2: ابحث عن دالة `moveFile`
ابحث عن دالة `exports.moveFile` في الملف.

### الخطوة 3: استبدل الكود

استبدل دالة `moveFile` بالكود التالي:

```javascript
// ✅ Move file to another folder
// @desc    Move file to another folder
// @route   PUT /api/files/:id/move
// @access  Private
exports.moveFile = asyncHandler(async (req, res) => {
  const fileId = req.params.id;
  const userId = req.user._id;
  let { targetFolderId } = req.body; // null للجذر أو folderId للمجلد

  // ✅ معالجة targetFolderId - إذا كان "null" أو "" أو undefined، اجعله null
  if (targetFolderId === "null" || targetFolderId === "" || targetFolderId === undefined) {
    targetFolderId = null;
  }

  // Find file
  const file = await File.findOne({ _id: fileId, userId: userId });
  
  if (!file) {
    return res.status(404).json({ message: "File not found" });
  }

  // If targetFolderId is provided, verify it exists and belongs to user
  if (targetFolderId) {
    const targetFolder = await Folder.findOne({ _id: targetFolderId, userId: userId });
    if (!targetFolder) {
      return res.status(404).json({ message: "Target folder not found" });
    }
    
    // Check if file is already in this folder
    if (file.parentFolderId && file.parentFolderId.toString() === targetFolderId.toString()) {
      return res.status(400).json({ message: "File is already in this folder" });
    }
  } else {
    // Moving to root - check if already in root
    if (!file.parentFolderId || file.parentFolderId === null) {
      return res.status(400).json({ message: "File is already in root" });
    }
  }

  // Store old parent folder ID
  const oldParentFolderId = file.parentFolderId ? file.parentFolderId.toString() : null;
  
  // ✅ إصلاح: تحديث parentFolderId بشكل صحيح
  // ✅ استخدام save() بدلاً من findByIdAndUpdate لضمان التحديث الصحيح مع null
  file.parentFolderId = targetFolderId;
  await file.save();

  // ✅ إعادة جلب الملف مع populate للتأكد من أن البيانات محدثة
  const refreshedFile = await File.findById(fileId)
    .populate('parentFolderId', 'name');

  if (!refreshedFile) {
    return res.status(404).json({ message: "File not found after update" });
  }

  // Update folder sizes
  if (oldParentFolderId) {
    await updateFolderSize(oldParentFolderId);
  }
  if (targetFolderId) {
    await updateFolderSize(targetFolderId);
  }

  // Log activity
  await logActivity(userId, 'file_moved', 'file', refreshedFile._id, refreshedFile.name, {
    fromFolder: oldParentFolderId || 'root',
    toFolder: targetFolderId || 'root',
    originalSize: refreshedFile.size,
    type: refreshedFile.type,
    category: refreshedFile.category
  }, {
    ipAddress: req.ip,
    userAgent: req.get('User-Agent')
  });

  res.status(200).json({
    message: "✅ File moved successfully",
    file: refreshedFile,
    fromFolder: oldParentFolderId || null,
    toFolder: targetFolderId || null
  });
});
```

## التغييرات الرئيسية

### قبل (الكود القديم):
```javascript
// ❌ المشكلة: findByIdAndUpdate قد لا يحدّث null بشكل صحيح
const updateData = { parentFolderId: targetFolderId };
const updatedFile = await File.findByIdAndUpdate(
  fileId,
  { $set: updateData },
  { new: true, runValidators: true }
);
```

### بعد (الكود الجديد):
```javascript
// ✅ الحل: استخدام save() يضمن تحديث null بشكل صحيح
file.parentFolderId = targetFolderId;
await file.save();
```

## لماذا هذا الحل يعمل؟

1. **`save()` يعمل بشكل أفضل مع `null`**: 
   - `findByIdAndUpdate` مع `$set: { parentFolderId: null }` قد لا يعمل بشكل صحيح في بعض الحالات
   - `save()` يضمن أن Mongoose يحدّث القيمة بشكل صحيح

2. **تحديث مباشر للكائن**:
   - `file.parentFolderId = targetFolderId;` ثم `await file.save();`
   - هذا يضمن أن Mongoose يحدّث القيمة بشكل صحيح في قاعدة البيانات

3. **إعادة جلب الملف**:
   - للتأكد من أن البيانات محدثة في الاستجابة

## التحقق من الإصلاح

بعد تطبيق الإصلاح:

1. أعد تشغيل Backend
2. جرب نقل ملف من الجذر إلى مجلد
3. تحقق من أن الملف لم يعد يظهر في الجذر
4. جرب نقل ملف من مجلد إلى الجذر
5. تحقق من أن الملف يظهر في الجذر وأن `parentFolderId` هو `null` في قاعدة البيانات

## ملاحظات

- ✅ هذا الحل يعمل بشكل صحيح مع `null` و `ObjectId`
- ✅ يضمن تحديث قاعدة البيانات بشكل صحيح
- ✅ يحافظ على جميع الوظائف الأخرى (تحديث حجم المجلد، تسجيل النشاط، إلخ)
- ✅ لا يحتاج إلى تغييرات في Frontend

