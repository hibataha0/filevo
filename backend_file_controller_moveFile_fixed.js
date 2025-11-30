// ✅ إصلاح دالة moveFile - تحديث parentFolderId بشكل صحيح عند النقل من/إلى الجذر

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
  
  // ✅ إصلاح: استخدام $set مع null بشكل صحيح، أو $unset لإزالة الحقل
  // ✅ هذا يضمن تحديث parentFolderId إلى null بشكل صحيح في قاعدة البيانات
  let updateData = {};
  
  if (targetFolderId === null) {
    // ✅ عند النقل إلى الجذر، استخدم $unset لإزالة الحقل أو $set مع null
    // ✅ استخدام $set مع null يعمل بشكل صحيح في MongoDB
    updateData = { $set: { parentFolderId: null } };
  } else {
    // ✅ عند النقل إلى مجلد، استخدم $set مع folderId
    updateData = { $set: { parentFolderId: targetFolderId } };
  }
  
  // ✅ تحديث الملف باستخدام findByIdAndUpdate
  const updatedFile = await File.findByIdAndUpdate(
    fileId,
    updateData,
    { new: true, runValidators: true }
  );

  if (!updatedFile) {
    return res.status(404).json({ message: "File not found after update" });
  }

  // ✅ إعادة جلب الملف مع populate للتأكد من أن البيانات محدثة
  const refreshedFile = await File.findById(fileId)
    .populate('parentFolderId', 'name')
    .lean(); // ✅ استخدام lean() للحصول على plain object

  // ✅ التحقق من أن parentFolderId تم تحديثه بشكل صحيح
  const actualParentFolderId = refreshedFile.parentFolderId ? refreshedFile.parentFolderId._id.toString() : null;
  
  // ✅ إذا كان targetFolderId هو null، يجب أن يكون actualParentFolderId أيضاً null
  // ✅ إذا كان targetFolderId موجوداً، يجب أن يكون actualParentFolderId مطابقاً له
  if (targetFolderId === null && actualParentFolderId !== null) {
    console.error('⚠️ Warning: parentFolderId was not set to null correctly');
    // ✅ محاولة إصلاح المشكلة مرة أخرى باستخدام $unset
    await File.findByIdAndUpdate(fileId, { $unset: { parentFolderId: "" } });
    // ✅ إعادة جلب الملف
    const fixedFile = await File.findById(fileId).populate('parentFolderId', 'name').lean();
    refreshedFile.parentFolderId = fixedFile.parentFolderId;
  } else if (targetFolderId !== null && actualParentFolderId !== targetFolderId.toString()) {
    console.error('⚠️ Warning: parentFolderId was not updated correctly');
    return res.status(500).json({ message: "Error updating file parent folder" });
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

