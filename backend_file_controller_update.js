// ✅ تحديث getAllFiles ليعرض فقط الملفات بدون parentFolder
// ✅ مع إضافة filter حسب category و pagination

const asyncHandler = require('express-async-handler');
const File = require('../models/fileModel');
const Folder = require('../models/folderModel');
const mongoose = require('mongoose');

exports.getAllFiles = asyncHandler(async (req, res) => {
  const userId = req.user._id;
  
  // ✅ فقط الملفات بدون parentFolder (null)
  // الملفات التي لها parentFolder تعرض في getFolderContents
  const parentFolderId = null; // ✅ دائماً null - فقط الملفات بدون مجلد أب
  
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const skip = (page - 1) * limit;
  
  // ✅ Filter حسب category (اختياري)
  const category = req.query.category || null;
  
  // Sorting parameters
  const sortBy = req.query.sortBy || 'createdAt'; // name, size, createdAt, updatedAt, type, category
  const sortOrder = req.query.sortOrder || 'desc'; // asc, desc
  
  // Build query
  const query = { 
    userId, 
    isDeleted: false,
    parentFolderId: null // ✅ فقط الملفات بدون parentFolder
  };
  
  // ✅ إضافة filter حسب category إذا كان موجوداً
  if (category && category !== 'all' && category !== '') {
    query.category = category;
  }
  
  // Build sort object
  const sortObj = {};
  switch (sortBy) {
    case 'name':
      sortObj.name = sortOrder === 'asc' ? 1 : -1;
      break;
    case 'size':
      sortObj.size = sortOrder === 'asc' ? 1 : -1;
      break;
    case 'type':
      sortObj.type = sortOrder === 'asc' ? 1 : -1;
      break;
    case 'category':
      sortObj.category = sortOrder === 'asc' ? 1 : -1;
      break;
    case 'updatedAt':
      sortObj.updatedAt = sortOrder === 'asc' ? 1 : -1;
      break;
    case 'createdAt':
    default:
      sortObj.createdAt = sortOrder === 'asc' ? 1 : -1;
      break;
  }
  
  const files = await File.find(query)
    .skip(skip)
    .limit(limit)
    .sort(sortObj);
  
  const totalFiles = await File.countDocuments(query);
  
  res.status(200).json({
    message: "Files retrieved successfully",
    files: files,
    pagination: {
      currentPage: page,
      totalPages: Math.ceil(totalFiles / limit),
      totalFiles: totalFiles,
      hasNext: page < Math.ceil(totalFiles / limit),
      hasPrev: page > 1
    },
    sorting: {
      sortBy,
      sortOrder
    },
    filter: {
      category: category || 'all' // ✅ إرجاع category المستخدم في filter
    }
  });
});

// ✅ getFolderContents - يعرض محتويات المجلد مع pagination
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
    
    // ✅ دمج subfolders و files مع إضافة type
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

    res.status(200).json({
        message: 'Folder contents retrieved successfully',
        folder: folder,
        contents: paginatedContents,
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
});

// ✅ getAllFolders - يعرض فقط المجلدات بدون parent (parentId = null)
exports.getAllFolders = asyncHandler(async (req, res, next) => {
    const userId = req.user._id;
    
    // ✅ فقط المجلدات بدون parent (null)
    // المجلدات التي لها parent تعرض في getFolderContents
    const parentId = null; // ✅ دائماً null - فقط المجلدات بدون مجلد أب
    
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const query = { 
        userId, 
        isDeleted: false,
        parentId: null // ✅ فقط المجلدات بدون parent
    };

    const folders = await Folder.find(query)
        .skip(skip)
        .limit(limit)
        .sort({ createdAt: -1 });

    const totalFolders = await Folder.countDocuments(query);

    res.status(200).json({
        message: 'Folders retrieved successfully',
        folders: folders,
        pagination: {
            currentPage: page,
            totalPages: Math.ceil(totalFolders / limit),
            totalFolders: totalFolders,
            hasNext: page < Math.ceil(totalFolders / limit),
            hasPrev: page > 1
        }
    });
});

// ✅ getAllItems - يعرض فقط المجلدات والملفات بدون parent
exports.getAllItems = asyncHandler(async (req, res, next) => {
    const userId = req.user._id;
    
    // ✅ فقط المجلدات والملفات بدون parent (null)
    const parentId = null; // ✅ دائماً null
    
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const folderQuery = { 
        userId, 
        isDeleted: false,
        parentId: null // ✅ فقط المجلدات بدون parent
    };
    
    const fileQuery = { 
        userId, 
        isDeleted: false,
        parentFolderId: null // ✅ فقط الملفات بدون parent
    };

    const folders = await Folder.find(folderQuery)
        .skip(skip)
        .limit(limit)
        .sort({ createdAt: -1 });
    
    const files = await File.find(fileQuery)
        .skip(skip)
        .limit(limit)
        .sort({ createdAt: -1 });

    const totalFolders = await Folder.countDocuments(folderQuery);
    const totalFiles = await File.countDocuments(fileQuery);

    const allItems = [
        ...folders.map(folder => ({ ...folder.toObject(), type: 'folder' })),
        ...files.map(file => ({ ...file.toObject(), type: 'file' }))
    ];
    
    const totalItems = totalFolders + totalFiles;

    res.status(200).json({
        message: 'All items retrieved successfully',
        items: allItems,
        folders: folders,
        files: files,
        pagination: {
            currentPage: page,
            totalPages: Math.ceil(totalItems / limit),
            totalItems: totalItems,
            totalFolders: totalFolders,
            totalFiles: totalFiles,
            hasNext: page < Math.ceil(totalItems / limit),
            hasPrev: page > 1
        }
    });
});

// ✅ Get categories statistics (count and size for each category)
// @desc    Get categories statistics - يحسب حجم جميع الملفات وعددهم بناءً على التصنيف
// @route   GET /api/files/categories/stats
// @access  Private
exports.getCategoriesStats = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    
    // ✅ قائمة التصنيفات (بأحرف صغيرة لتطابق Flutter والكود الحالي)
    // ✅ ترتيب التصنيفات يجب أن يطابق ترتيبها في Flutter
    const categories = ['images', 'videos', 'audio', 'compressed', 'applications', 'documents', 'code', 'other'];
    
    // ✅ استخدام MongoDB Aggregation Pipeline لحساب جميع الإحصائيات في query واحد (أكثر كفاءة)
    // ✅ إصلاح: حساب فقط الملفات بدون مجلد أب (parentFolderId: null) - الملفات في الجذر فقط
    const userIdObjectId = mongoose.Types.ObjectId.isValid(userId) ? new mongoose.Types.ObjectId(userId) : userId;
    
    // ✅ Aggregation واحد لحساب جميع التصنيفات - فقط الملفات من الجذر
    // ✅ استخدام $regex للتطابق غير الحساس لحالة الأحرف (case-insensitive)
    const aggregationResult = await File.aggregate([
        {
            $match: {
                userId: userIdObjectId,
                isDeleted: false,
                $or: [
                    { parentFolderId: null },
                    { parentFolderId: { $exists: false } },
                    { parentFolderId: '' }
                ] // ✅ فقط الملفات بدون مجلد أب (من الجذر) - التحقق من null أو عدم وجود الحقل أو string فارغ
            }
        },
        {
            $addFields: {
                categoryLower: { 
                    $toLower: { $ifNull: ['$category', 'other'] }
                }
            }
        },
        {
            $group: {
                _id: '$categoryLower', // ✅ استخدام categoryLower مباشرة كـ string
                filesCount: { $sum: 1 },
                totalSize: { $sum: '$size' }
            }
        }
    ]);
    
    // ✅ تحويل النتيجة إلى Map لتسهيل البحث
    const statsMap = new Map();
    aggregationResult.forEach(item => {
        // ✅ item._id الآن string مباشر (بعد استخدام $addFields)
        const categoryKey = item._id ? String(item._id).toLowerCase() : '';
        if (categoryKey) {
            statsMap.set(categoryKey, {
                filesCount: Number(item.filesCount) || 0,
                totalSize: Number(item.totalSize) || 0
            });
        }
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

