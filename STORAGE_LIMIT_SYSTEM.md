# نظام المساحة التخزينية - Storage Limit System

## 📋 نظرة عامة
تم تطبيق نظام المساحة التخزينية بحيث:
- كل مستخدم لديه **10 جيجابايت** مساحة تخزينية افتراضية
- عند الوصول للحد الأقصى، لا يمكن رفع ملفات جديدة
- يمكن للمستخدم شراء مساحة إضافية أو حذف ملفات لتحرير مساحة

## ✅ الملفات المطلوبة

### 1. User Model (`models/userModel.js`)
تأكد من إضافة الحقول التالية:

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

### 2. File Controller (`controllers/fileController.js` أو `services/fileService.js`)

#### أ. الدوال المساعدة:

```javascript
// ✅ حساب المساحة المستخدمة للمستخدم
async function calculateUserStorageUsed(userId) {
  try {
    const result = await File.aggregate([
      {
        $match: {
          userId: userId,
          isDeleted: false,
        },
      },
      {
        $group: {
          _id: null,
          totalSize: { $sum: "$size" },
        },
      },
    ]);

    const totalSize = result.length > 0 ? result[0].totalSize : 0;
    return totalSize;
  } catch (error) {
    console.error("Error calculating user storage used:", error);
    return 0;
  }
}

// ✅ تحديث المساحة المستخدمة للمستخدم
async function updateUserStorageUsed(userId) {
  try {
    const storageUsed = await calculateUserStorageUsed(userId);
    await User.findByIdAndUpdate(userId, { storageUsed });
    return storageUsed;
  } catch (error) {
    console.error("Error updating user storage used:", error);
    return 0;
  }
}

// ✅ التحقق من المساحة المتاحة قبل الرفع
async function checkStorageLimit(userId, fileSize) {
  const user = await User.findById(userId).select("storageLimit storageUsed");
  if (!user) {
    throw new ApiError("User not found", 404);
  }

  const currentUsed = user.storageUsed || 0;
  const limit = user.storageLimit || 10 * 1024 * 1024 * 1024; // Default 10 GB
  const available = limit - currentUsed;

  if (fileSize > available) {
    const formatBytes = (bytes) => {
      if (bytes === 0) return "0 Bytes";
      const k = 1024;
      const sizes = ["Bytes", "KB", "MB", "GB", "TB"];
      const i = Math.floor(Math.log(bytes) / Math.log(k));
      return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
    };

    throw new ApiError(
      `Storage limit exceeded. Available: ${formatBytes(available)}, Required: ${formatBytes(fileSize)}. Please delete files or upgrade your storage.`,
      403
    );
  }

  return true;
}

// ✅ تصدير الدوال للاستخدام في ملفات أخرى
exports.checkStorageLimit = checkStorageLimit;
exports.calculateUserStorageUsed = calculateUserStorageUsed;
exports.updateUserStorageUsed = updateUserStorageUsed;
```

#### ب. تحديث `uploadSingleFile`:

```javascript
exports.uploadSingleFile = asyncHandler(async (req, res) => {
  const file = req.file;
  const userId = req.user._id;
  let parentFolderId = req.body.parentFolderId || null;

  if (!file) {
    res.status(400).json({ message: "No file uploaded" });
    return;
  }

  // ✅ التحقق من المساحة التخزينية قبل رفع الملف
  await checkStorageLimit(userId, file.size);

  // ... باقي الكود

  // ✅ تحديث المساحة المستخدمة للمستخدم بعد الرفع الناجح
  await User.findByIdAndUpdate(userId, {
    $inc: { storageUsed: newFile.size },
  });

  res.status(201).json({
    message: "✅ File uploaded successfully",
    file: newFile,
  });
});
```

#### ج. تحديث `uploadMultipleFiles`:

```javascript
exports.uploadMultipleFiles = asyncHandler(async (req, res) => {
  const files = req.files;
  const userId = req.user._id;
  let parentFolderId = req.body.parentFolderId || null;

  if (!files || files.length === 0) {
    res.status(400).json({ message: "No files uploaded" });
    return;
  }

  try {
    // ✅ التحقق من المساحة التخزينية قبل رفع الملفات
    const totalSize = files.reduce((sum, file) => sum + (file.size || 0), 0);
    await checkStorageLimit(userId, totalSize);

    // ... باقي الكود لرفع الملفات

    // ✅ تحديث المساحة المستخدمة للمستخدم بعد الرفع الناجح
    const uploadedTotalSize = uploadedFiles.reduce(
      (sum, file) => sum + file.size,
      0
    );
    await User.findByIdAndUpdate(userId, {
      $inc: { storageUsed: uploadedTotalSize },
    });

    res.status(200).json({
      message: `${uploadedFiles.length} files uploaded successfully`,
      files: uploadedFiles,
      errors: errors,
      totalFiles: uploadedFiles.length,
      totalSize: uploadedFiles.reduce((sum, file) => sum + file.size, 0),
    });
  } catch (error) {
    res.status(500).json({
      message: "Error uploading files",
      error: error.message,
    });
  }
});
```

#### د. تحديث `deleteFilePermanent`:

```javascript
exports.deleteFilePermanent = asyncHandler(async (req, res) => {
  const fileId = req.params.id;
  const userId = req.user._id;
  const fs = require("fs");
  const path = require("path");

  // Find file
  const file = await File.findOne({ _id: fileId, userId: userId });

  if (!file) {
    return res.status(404).json({ message: "File not found" });
  }

  // Delete physical file
  const filePath = path.join(__dirname, "..", file.path);
  if (fs.existsSync(filePath)) {
    fs.unlinkSync(filePath);
  }

  const fileSize = file.size || 0;

  // Delete from database
  await File.findByIdAndDelete(fileId);

  // ✅ تحديث المساحة المستخدمة للمستخدم (تقليل المساحة عند الحذف الدائم)
  await User.findByIdAndUpdate(userId, {
    $inc: { storageUsed: -fileSize },
  });

  // ... باقي الكود

  res.status(200).json({
    message: "✅ File deleted permanently",
  });
});
```

#### هـ. تحديث `updateFileContent`:

```javascript
exports.updateFileContent = asyncHandler(async (req, res) => {
  const fileId = req.params.id;
  const userId = req.user._id;
  const newFile = req.file;

  if (!newFile) {
    return res.status(400).json({ message: "No file uploaded" });
  }

  // Find existing file
  const existingFile = await File.findOne({ _id: fileId, userId: userId });

  if (!existingFile) {
    if (fs.existsSync(newFile.path)) {
      fs.unlinkSync(newFile.path);
    }
    return res.status(404).json({ message: "File not found" });
  }

  // ✅ التحقق من المساحة التخزينية (الفرق بين الحجم القديم والجديد)
  const oldSize = existingFile.size || 0;
  const newSize = newFile.size || 0;
  const sizeDifference = newSize - oldSize;

  if (sizeDifference > 0) {
    // إذا كان الملف الجديد أكبر، تحقق من المساحة المتاحة
    await checkStorageLimit(userId, sizeDifference);
  }

  // ... باقي الكود لتحديث الملف

  // ✅ تحديث المساحة المستخدمة للمستخدم (الفرق بين الحجم القديم والجديد)
  if (sizeDifference !== 0) {
    await User.findByIdAndUpdate(userId, {
      $inc: { storageUsed: sizeDifference },
    });
  }

  res.status(200).json({
    message: "✅ File content updated successfully",
    file: existingFile,
  });
});
```

#### و. Endpoint جديد للحصول على معلومات المساحة:

```javascript
// @desc    Get user storage information
// @route   GET /api/files/storage
// @access  Private
exports.getStorageInfo = asyncHandler(async (req, res) => {
  const userId = req.user._id;

  const user = await User.findById(userId).select("storageLimit storageUsed");
  if (!user) {
    return res.status(404).json({ message: "User not found" });
  }

  // Calculate actual used storage from files
  const actualStorageUsed = await calculateUserStorageUsed(userId);

  // Update user storage if there's a discrepancy
  if (Math.abs(actualStorageUsed - (user.storageUsed || 0)) > 1024) {
    // If difference is more than 1KB, update it
    await User.findByIdAndUpdate(userId, { storageUsed: actualStorageUsed });
    user.storageUsed = actualStorageUsed;
  }

  const storageLimit = user.storageLimit || 10 * 1024 * 1024 * 1024; // Default 10 GB
  const storageUsed = user.storageUsed || 0;
  const storageAvailable = storageLimit - storageUsed;
  const storagePercentage = (storageUsed / storageLimit) * 100;

  // Format bytes to readable format
  const formatBytes = (bytes) => {
    if (bytes === 0) return "0 Bytes";
    const k = 1024;
    const sizes = ["Bytes", "KB", "MB", "GB", "TB"];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
  };

  res.status(200).json({
    message: "Storage information retrieved successfully",
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
});
```

### 3. تحديث `saveFileFromRoom` في `roomService.js`:

```javascript
exports.saveFileFromRoom = asyncHandler(async (req, res, next) => {
  // ... الكود الحالي

  // ✅ التحقق من المساحة التخزينية قبل حفظ الملف
  const { checkStorageLimit } = require("./fileService");
  await checkStorageLimit(userId, originalFile.size);

  // ... باقي الكود

  // ✅ تحديث المساحة المستخدمة للمستخدم
  const User = require("../models/userModel");
  await User.findByIdAndUpdate(userId, {
    $inc: { storageUsed: originalFile.size },
  });

  // ... باقي الكود
});
```

## 📝 ملاحظات مهمة:

1. **الحذف إلى Trash**: عند حذف ملف إلى trash (`isDeleted: true`)، لا تتغير المساحة لأن الملف ما زال موجوداً. المساحة تتغير فقط عند الحذف الدائم.

2. **استعادة الملف**: عند استعادة ملف من trash، لا نحتاج لتحديث المساحة لأنها لم تتغير أصلاً عند الحذف إلى trash.

3. **تحديث محتوى الملف**: عند تحديث محتوى الملف، نحسب الفرق بين الحجم القديم والجديد ونحدث المساحة بناءً على هذا الفرق.

4. **شراء مساحة إضافية**: (للمستقبل) يمكن إضافة endpoint لتحديث `storageLimit` للمستخدم بعد شراء مساحة إضافية.

## ✅ التحقق من العمل:

1. تأكد من أن جميع المستخدمين لديهم `storageLimit: 10 * 1024 * 1024 * 1024` (10 GB)
2. عند رفع ملف، يجب التحقق من المساحة المتاحة قبل الرفع
3. عند الوصول للحد الأقصى، يجب إرجاع رسالة خطأ واضحة
4. عند حذف ملف بشكل دائم، يجب تقليل `storageUsed`
5. عند تحديث محتوى ملف بملف أكبر، يجب التحقق من المساحة المتاحة

## 🔗 Routes المطلوبة:

```javascript
// في fileRoutes.js
router.get("/storage", protect, fileController.getStorageInfo);
```



