// ✅ إصلاح ترتيب محتويات المجلد - المجلدات أولاً ثم الملفات
// نسخ هذا الكود ولصقه في Backend في ملف folderController.js

// @desc    Get folder contents (with pagination)
// @route   GET /api/folders/:id/contents
// @access  Private
exports.getFolderContents = asyncHandler(async (req, res, next) => {
    const folderId = req.params.id;
    const userId = req.user._id;
    
    // ✅ Pagination parameters
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const folder = await Folder.findOne({ _id: folderId, userId: userId });
    if (!folder) {
        return next(new ApiError('Folder not found', 404));
    }

    // ✅ جلب جميع subfolders و files (بدون pagination أولاً)
    const allSubfolders = await Folder.find({ parentId: folderId, isDeleted: false })
        .sort({ createdAt: -1 });
    
    const allFiles = await File.find({ parentFolderId: folderId, isDeleted: false })
        .sort({ createdAt: -1 });
    
    const totalSubfolders = allSubfolders.length;
    const totalFiles = allFiles.length;
    
    // ✅ دمج subfolders و files مع إضافة type - المجلدات أولاً ثم الملفات
    // ✅ هذا يضمن أن المجلدات دائماً تظهر قبل الملفات
    const allContents = [
        ...allSubfolders.map(f => ({ ...f.toObject(), type: 'folder' })),
        ...allFiles.map(f => ({ ...f.toObject(), type: 'file' }))
    ];
    
    // ✅ تطبيق pagination على المدمج
    const totalItems = allContents.length;
    const paginatedContents = allContents.slice(skip, skip + limit);
    
    // ✅ فصل subfolders و files من النتائج المصفاة
    const subfolders = paginatedContents.filter(item => item.type === 'folder');
    const files = paginatedContents.filter(item => item.type === 'file');
    
    // ✅ حساب الحجم وعدد الملفات للمجلدات الفرعية المعروضة (إذا كانت الدوال موجودة)
    let subfoldersWithDetails = subfolders;
    if (typeof calculateFolderSizeRecursive === 'function' && typeof calculateFolderFilesCountRecursive === 'function') {
        subfoldersWithDetails = await Promise.all(
            subfolders.map(async (subfolder) => {
                const subfolderObj = { ...subfolder };
                
                // ✅ حساب الحجم وعدد الملفات بشكل recursive
                const size = await calculateFolderSizeRecursive(subfolder._id);
                const filesCount = await calculateFolderFilesCountRecursive(subfolder._id);
                
                // ✅ تحديث القيم
                subfolderObj.size = size;
                subfolderObj.filesCount = filesCount;
                
                return subfolderObj;
            })
        );
        
        // ✅ تحديث paginatedContents مع القيم المحسوبة
        const updatedPaginatedContents = paginatedContents.map(item => {
            if (item.type === 'folder') {
                const updatedSubfolder = subfoldersWithDetails.find(s => s._id.toString() === item._id.toString());
                return updatedSubfolder || item;
            }
            return item;
        });
        
        res.status(200).json({
            message: 'Folder contents retrieved successfully',
            folder: folder,
            contents: updatedPaginatedContents, // ✅ المجلدات أولاً ثم الملفات
            subfolders: subfoldersWithDetails,
            files: files,
            totalItems: totalItems,
            pagination: {
                currentPage: page,
                totalPages: Math.ceil(totalItems / limit),
                totalItems: totalItems,
                totalSubfolders: totalSubfolders,
                totalFiles: totalFiles,
                hasNext: page < Math.ceil(totalItems / limit),
                hasPrev: page > 1
            }
        });
    } else {
        // ✅ إذا لم تكن الدوال موجودة، إرجاع البيانات بدون حساب الحجم
        res.status(200).json({
            message: 'Folder contents retrieved successfully',
            folder: folder,
            contents: paginatedContents, // ✅ المجلدات أولاً ثم الملفات
            subfolders: subfolders,
            files: files,
            totalItems: totalItems,
            pagination: {
                currentPage: page,
                totalPages: Math.ceil(totalItems / limit),
                totalItems: totalItems,
                totalSubfolders: totalSubfolders,
                totalFiles: totalFiles,
                hasNext: page < Math.ceil(totalItems / limit),
                hasPrev: page > 1
            }
        });
    }
});




