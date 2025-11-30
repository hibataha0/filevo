// ✅ إصلاح دالة moveFolder - نسخ هذا الكود ولصقه في Backend

exports.moveFolder = asyncHandler(async (req, res, next) => {
    const folderId = req.params.id;
    const userId = req.user._id;
    let { targetFolderId } = req.body; // null للجذر أو folderId للمجلد

    // ✅ معالجة targetFolderId - إذا كان "null" أو "" أو undefined، اجعله null
    if (targetFolderId === "null" || targetFolderId === "" || targetFolderId === undefined) {
        targetFolderId = null;
    }

    // Find folder
    const folder = await Folder.findOne({ _id: folderId, userId: userId });

    if (!folder) {
        return next(new ApiError('Folder not found', 404));
    }

    // If targetFolderId is provided, verify it exists and belongs to user
    if (targetFolderId) {
        const targetFolder = await Folder.findOne({ _id: targetFolderId, userId: userId });
        if (!targetFolder) {
            return next(new ApiError('Target folder not found', 404));
        }
        
        // ✅ منع نقل المجلد إلى نفسه
        if (folderId.toString() === targetFolderId.toString()) {
            return next(new ApiError('Cannot move folder to itself', 400));
        }
        
        // ✅ منع نقل المجلد إلى أحد أبنائه (لتجنب الحلقات)
        async function isDescendant(parentId, childId) {
            const children = await Folder.find({ parentId: parentId, userId: userId, isDeleted: false });
            for (const child of children) {
                if (child._id.toString() === childId.toString()) {
                    return true;
                }
                if (await isDescendant(child._id, childId)) {
                    return true;
                }
            }
            return false;
        }
        
        if (await isDescendant(folderId, targetFolderId)) {
            return next(new ApiError('Cannot move folder into its own subfolder', 400));
        }
        
        // Check if folder is already in this folder
        if (folder.parentId && folder.parentId.toString() === targetFolderId.toString()) {
            return next(new ApiError('Folder is already in this location', 400));
        }
    } else {
        // Moving to root - check if already in root
        if (!folder.parentId || folder.parentId === null) {
            return next(new ApiError('Folder is already in root', 400));
        }
    }

    // Store old parent folder ID
    const oldParentFolderId = folder.parentId ? folder.parentId.toString() : null;
    
    // ✅ إصلاح: تحديث parentId بشكل صحيح
    // ✅ استخدام save() بدلاً من findByIdAndUpdate لضمان التحديث الصحيح مع null
    folder.parentId = targetFolderId;
    await folder.save();

    // ✅ إعادة جلب المجلد مع populate للتأكد من أن البيانات محدثة
    const refreshedFolder = await Folder.findById(folderId).populate('parentId', 'name');

    if (!refreshedFolder) {
        return next(new ApiError('Folder not found after update', 404));
    }

    // ✅ تحديث أحجام المجلدات
    if (oldParentFolderId) {
        const oldParentSize = await calculateFolderSizeRecursive(oldParentFolderId);
        await Folder.findByIdAndUpdate(oldParentFolderId, { size: oldParentSize });
    }
    if (targetFolderId) {
        const newParentSize = await calculateFolderSizeRecursive(targetFolderId);
        await Folder.findByIdAndUpdate(targetFolderId, { size: newParentSize });
    }
    
    // ✅ تحديث حجم المجلد المنقول
    const movedFolderSize = await calculateFolderSizeRecursive(folderId);
    await Folder.findByIdAndUpdate(folderId, { size: movedFolderSize });

    // Log activity
    await logActivity(userId, 'folder_moved', 'folder', refreshedFolder._id, refreshedFolder.name, {
        fromFolder: oldParentFolderId || 'root',
        toFolder: targetFolderId || 'root',
        originalSize: refreshedFolder.size
    }, {
        ipAddress: req.ip,
        userAgent: req.get('User-Agent')
    });

    res.status(200).json({
        message: '✅ Folder moved successfully',
        folder: refreshedFolder,
        fromFolder: oldParentFolderId || null,
        toFolder: targetFolderId || null
    });
});

