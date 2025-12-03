// ✅ إصلاح دالة moveFile - تحديث parentFolderId بشكل صحيح عند النقل من/إلى الجذر

const asyncHandler = require("express-async-handler");
const File = require("../models/fileModel");
const Folder = require("../models/folderModel");
const { logActivity } = require("./activityLogService");

// Helper function to update folder size (including subfolders)
async function updateFolderSize(folderId) {
  try {
    // Get all files directly in this folder
    const files = await File.find({ parentFolderId: folderId, isDeleted: false });
    let totalSize = files.reduce((sum, file) => sum + file.size, 0);
    
    // Get all subfolders and calculate their sizes recursively
    const subfolders = await Folder.find({ parentId: folderId, isDeleted: false });
    for (const subfolder of subfolders) {
      const subfolderSize = await calculateFolderSizeRecursive(subfolder._id);
      totalSize += subfolderSize;
    }
    
    await Folder.findByIdAndUpdate(folderId, { size: totalSize });
  } catch (error) {
    console.error('Error updating folder size:', error);
  }
}

// Helper function to calculate folder size recursively
async function calculateFolderSizeRecursive(folderId) {
  try {
    // Get all files directly in this folder
    const files = await File.find({ parentFolderId: folderId, isDeleted: false });
    let totalSize = files.reduce((sum, file) => sum + file.size, 0);
    
    // Get all subfolders and calculate their sizes recursively
    const subfolders = await Folder.find({ parentId: folderId, isDeleted: false });
    for (const subfolder of subfolders) {
      const subfolderSize = await calculateFolderSizeRecursive(subfolder._id);
      totalSize += subfolderSize;
    }
    
    return totalSize;
  } catch (error) {
    console.error('Error calculating folder size recursively:', error);
    return 0;
  }
}

// ✅ Move file to another folder - إصلاح تحديث parentFolderId
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

  // ✅ التحقق من أن parentFolderId تم تحديثه بشكل صحيح
  const actualParentFolderId = refreshedFile.parentFolderId ? refreshedFile.parentFolderId._id.toString() : null;
  
  // ✅ Log للتحقق (يمكن إزالته لاحقاً)
  console.log(`📁 File moved: ${file.name}`);
  console.log(`   From: ${oldParentFolderId || 'root'}`);
  console.log(`   To: ${targetFolderId || 'root'}`);
  console.log(`   Actual parentFolderId in DB: ${actualParentFolderId || 'null'}`);

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




