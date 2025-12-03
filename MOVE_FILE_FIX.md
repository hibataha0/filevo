# 🔧 إصلاح دالة moveFile - تحديث parentFolderId بشكل صحيح

## المشكلة
عند نقل ملف من الجذر إلى مجلد أو العكس، لا يتم تحديث `parentFolderId` بشكل صحيح في قاعدة البيانات.

## الحل

استبدل دالة `moveFile` في ملف `fileController.js` بالكود التالي:

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
  // ✅ استخدام save() بدلاً من findByIdAndUpdate لضمان التحديث الصحيح
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

1. **استخدام `save()` بدلاً من `findByIdAndUpdate`**: 
   - هذا يضمن تحديث `parentFolderId` إلى `null` بشكل صحيح
   - `save()` يعمل بشكل أفضل مع القيم `null` في Mongoose

2. **تحديث مباشر للكائن**:
   - `file.parentFolderId = targetFolderId;` ثم `await file.save();`
   - هذا يضمن أن Mongoose يحدّث القيمة بشكل صحيح

3. **إعادة جلب الملف بعد التحديث**:
   - للتأكد من أن البيانات محدثة في الاستجابة

## ملاحظات

- ✅ هذا الحل يعمل بشكل صحيح مع `null` و `ObjectId`
- ✅ يضمن تحديث قاعدة البيانات بشكل صحيح
- ✅ يحافظ على جميع الوظائف الأخرى (تحديث حجم المجلد، تسجيل النشاط، إلخ)




