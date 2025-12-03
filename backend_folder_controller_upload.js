async function generateUniqueFolderName(baseName, parentId, userId) {
    let finalName = baseName;
    let counter = 1;
    
    while (true) {
        const existingFolder = await Folder.findOne({ 
            name: finalName, 
            parentId: parentId || null, 
            userId: userId 
        });
        
        if (!existingFolder) {
            break;
        }
        
        const baseNameWithoutNumber = baseName.replace(/\(\d+\)$/, '');
        finalName = `${baseNameWithoutNumber} (${counter})`;
        counter++;
    }
    
    return finalName;
}

// @desc    Create new empty folder
// @route   POST /api/folders/create
// @access  Private
exports.createFolder = asyncHandler(async (req, res, next) => {
    const { name, parentId } = req.body;
    const userId = req.user._id;

    if (!name) {
        return next(new ApiError('Folder name is required', 400));
    }

    const uniqueName = await generateUniqueFolderName(name, parentId, userId);

    const folder = await Folder.create({
        name: uniqueName,
        userId: userId,
        size: 0,
        path: `uploads/${uniqueName}`,
        parentId: parentId || null,
        isShared: false,
        sharedWith: []
    });

    await logActivity(userId, 'folder_created', 'folder', folder._id, folder.name, {}, {
        ipAddress: req.ip,
        userAgent: req.get('User-Agent')
    });

    res.status(201).json({ 
        message: "✅ Folder created successfully",
        folder: folder 
    });
});

// @desc    Upload folder with nested structure
// @route   POST /api/folders/upload
// @access  Private
exports.uploadFolder = asyncHandler(async (req, res, next) => {
    const files = req.files;
    const userId = req.user._id;
    const folderName = req.body.folderName || 'Uploaded Folder';
    const parentFolderId = req.body.parentFolderId || null;
    
    console.log('📁 Uploading folder:', folderName, 'for user:', userId);
    console.log('📁 Files count:', files ? files.length : 0);
    
    // ✅ دعم طرق مختلفة لإرسال relativePaths
    // يدعم: req.body.relativePaths أو req.body['relativePaths[]']
    let relativePaths = req.body.relativePaths;
    
    // ✅ إذا كانت undefined، حاول الحصول عليها من relativePaths[]
    if (!relativePaths && req.body['relativePaths[]']) {
        relativePaths = req.body['relativePaths[]'];
    }
    
    // ✅ إذا كانت string (JSON string)، حولها إلى array
    if (typeof relativePaths === 'string') {
        try {
            // ✅ محاولة parse كـ JSON أولاً
            relativePaths = JSON.parse(relativePaths);
        } catch (e) {
            // ✅ إذا فشل parse، اعتبرها string مفرد
            relativePaths = [relativePaths];
        }
    }
    
    // ✅ التأكد من أن relativePaths هو array
    if (!Array.isArray(relativePaths)) {
        relativePaths = [];
    }
    
    if (!files || files.length === 0) {
        return next(new ApiError('No files uploaded', 400));
    }
    
    // ✅ التحقق من أن relativePaths تطابق عدد الملفات
    if (relativePaths.length !== files.length) {
        console.warn(`⚠️ relativePaths count (${relativePaths.length}) != files count (${files.length})`);
        console.warn('⚠️ Fixing relativePaths - using file names...');
        
        // ✅ إصلاح: استخدام أسماء الملفات كـ relativePaths
        relativePaths = files.map(file => file.originalname);
        console.log('✅ Fixed relativePaths count:', relativePaths.length);
    }

    try {
        const uniqueFolderName = await generateUniqueFolderName(folderName, parentFolderId, userId);

        const rootFolder = await Folder.create({
            name: uniqueFolderName,
            userId: userId,
            size: 0,
            path: `uploads/${uniqueFolderName}`,
            parentId: parentFolderId,
            isShared: false,
            sharedWith: []
        });

        const folderMap = new Map();
        folderMap.set('', rootFolder._id);

        const createdFiles = [];
        const createdFolders = [rootFolder];

        for (let i = 0; i < files.length; i++) {
            const file = files[i];
            const relativePath = relativePaths[i];

            // ✅ التحقق من أن relativePath موجود وصالح
            if (!relativePath || typeof relativePath !== 'string') {
                console.warn(`⚠️ Invalid relativePath at index ${i}, using file name: ${file.originalname}`);
                // ✅ استخدام اسم الملف كـ relativePath
                const fileName = file.originalname;
                const category = getCategoryByExtension(file.originalname, file.mimetype);

                const newFile = await File.create({
                    name: file.originalname,
                    type: file.mimetype,
                    size: file.size,
                    path: file.path,
                    userId: userId,
                    parentFolderId: rootFolder._id, // ✅ وضع الملف مباشرة في المجلد الجذر
                    category: category
                });

                createdFiles.push(newFile);
                continue;
            }

            // ✅ التحقق إذا كان relativePath يحتوي على مسار نسبي (مثل "subfolder/file.pdf")
            // أو فقط اسم ملف (مثل "file.pdf")
            const hasSubfolder = relativePath.includes('/') && relativePath.split('/').length > 1;
            
            let currentParentFolderId = rootFolder._id;

            if (hasSubfolder) {
                // ✅ الحالة 1: relativePath يحتوي على مسار نسبي (مثل "subfolder/file.pdf")
                // ✅ إنشاء المجلدات الفرعية
                const pathParts = relativePath.split('/').filter(part => part.length > 0);
                const fileName = pathParts.pop() || file.originalname;
                const folderPath = pathParts.join('/');

                if (folderPath) {
                    if (!folderMap.has(folderPath)) {
                        const parts = folderPath.split('/').filter(part => part.length > 0);
                        let current = '';

                        for (let part of parts) {
                            const currPath = current ? `${current}/${part}` : part;

                            if (!folderMap.has(currPath)) {
                                const parentId = current ? folderMap.get(current) : rootFolder._id;
                                const uniqueSubFolderName = await generateUniqueFolderName(part, parentId, userId);

                                const newFolder = await Folder.create({
                                    name: uniqueSubFolderName,
                                    userId: userId,
                                    size: 0,
                                    path: `uploads/${uniqueFolderName}/${currPath}`,
                                    parentId: parentId
                                });

                                folderMap.set(currPath, newFolder._id);
                                createdFolders.push(newFolder);
                            }

                            current = currPath;
                        }
                    }

                    currentParentFolderId = folderMap.get(folderPath);
                }

                const category = getCategoryByExtension(file.originalname, file.mimetype);

                const newFile = await File.create({
                    name: fileName, // ✅ استخدام اسم الملف من المسار
                    type: file.mimetype,
                    size: file.size,
                    path: file.path,
                    userId: userId,
                    parentFolderId: currentParentFolderId,
                    category: category
                });

                createdFiles.push(newFile);
            } else {
                // ✅ الحالة 2: relativePath هو فقط اسم ملف (مثل "file.pdf")
                // ✅ وضع الملف مباشرة في المجلد الجذر بدون إنشاء مجلدات فرعية
                const category = getCategoryByExtension(file.originalname, file.mimetype);

                const newFile = await File.create({
                    name: file.originalname,
                    type: file.mimetype,
                    size: file.size,
                    path: file.path,
                    userId: userId,
                    parentFolderId: rootFolder._id, // ✅ وضع الملف مباشرة في المجلد الجذر
                    category: category
                });

                createdFiles.push(newFile);
            }
        }

        // ✅ تحديث حجم المجلدات
        for (const folder of createdFolders) {
            const folderSize = await calculateFolderSizeRecursive(folder._id);
            await Folder.findByIdAndUpdate(folder._id, { size: folderSize });
        }

        const rootFolderSize = await calculateFolderSizeRecursive(rootFolder._id);

        res.status(201).json({
            message: 'Folder uploaded successfully',
            folder: rootFolder,
            filesCount: createdFiles.length,
            foldersCount: createdFolders.length,
            totalSize: rootFolderSize
        });

    } catch (error) {
        console.error('❌ Error uploading folder:', error);
        return next(new ApiError('Error uploading folder: ' + error.message, 500));
    }
});











