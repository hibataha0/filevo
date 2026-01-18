const asyncHandler = require("express-async-handler");

const Folder = require("../models/folderModel");
const File = require("../models/fileModel");
const User = require("../models/userModel");
const ApiError = require("../utils/apiError");
const { getCategoryByExtension } = require("../utils/fileUtils");
const { logActivity } = require("./activityLogService");
const fs = require("fs");
const path = require("path");

// ✅ Helper function to generate unique folder name
async function generateUniqueFolderName(baseName, parentId, userId) {
  let finalName = baseName;
  let counter = 1;

  while (true) {
    const existingFolder = await Folder.findOne({
      name: finalName,
      parentId: parentId || null,
      userId: userId,
    });

    if (!existingFolder) {
      break;
    }

    const baseNameWithoutNumber = baseName.replace(/\(\d+\)$/, "");
    finalName = `${baseNameWithoutNumber} (${counter})`;
    counter++;
  }

  return finalName;
}

// ✅ Helper function to calculate folder size recursively
async function calculateFolderSizeRecursive(folderId) {
  try {
    const files = await File.find({
      parentFolderId: folderId,
      isDeleted: false,
    });
    let totalSize = files.reduce((sum, file) => sum + (file.size || 0), 0);

    const subfolders = await Folder.find({
      parentId: folderId,
      isDeleted: false,
    });
    for (const subfolder of subfolders) {
      const subfolderSize = await calculateFolderSizeRecursive(subfolder._id);
      totalSize += subfolderSize;
    }

    return totalSize;
  } catch (error) {
    console.error(`❌ Error calculating folder size for ${folderId}:`, error);
    return 0;
  }
}

// ✅ Helper function to calculate folder files count recursively
async function calculateFolderFilesCountRecursive(folderId) {
  try {
    const files = await File.find({
      parentFolderId: folderId,
      isDeleted: false,
    });
    let totalFiles = files.length;

    const subfolders = await Folder.find({
      parentId: folderId,
      isDeleted: false,
    });
    for (const subfolder of subfolders) {
      const subfolderFilesCount = await calculateFolderFilesCountRecursive(
        subfolder._id
      );
      totalFiles += subfolderFilesCount;
    }

    return totalFiles;
  } catch (error) {
    console.error(
      `❌ Error calculating folder files count for ${folderId}:`,
      error
    );
    return 0;
  }
}

// ✅ Helper function to calculate folder stats (size + files count) recursively - أكثر كفاءة
async function calculateFolderStatsRecursive(folderId) {
  try {
    const files = await File.find({
      parentFolderId: folderId,
      isDeleted: false,
    });
    let totalSize = files.reduce((sum, file) => sum + (file.size || 0), 0);
    let totalFiles = files.length;

    console.log(
      `   🔍 Folder ${folderId}: Direct files count: ${totalFiles}, Direct size: ${totalSize} bytes`
    );

    const subfolders = await Folder.find({
      parentId: folderId,
      isDeleted: false,
    });
    console.log(
      `   🔍 Folder ${folderId}: Subfolders count: ${subfolders.length}`
    );

    for (const subfolder of subfolders) {
      const subfolderStats = await calculateFolderStatsRecursive(subfolder._id);
      const subSize =
        subfolderStats && subfolderStats.size ? Number(subfolderStats.size) : 0;
      const subFiles =
        subfolderStats && subfolderStats.filesCount
          ? Number(subfolderStats.filesCount)
          : 0;
      totalSize += subSize;
      totalFiles += subFiles;
      console.log(
        `   🔍 Subfolder ${subfolder._id}: files=${subFiles}, size=${subSize}`
      );
    }

    const result = {
      size: Number(totalSize) || 0,
      filesCount: Number(totalFiles) || 0,
    };

    console.log(
      `   ✅ Final stats for ${folderId}: size=${result.size}, filesCount=${result.filesCount}`
    );

    return result;
  } catch (error) {
    console.error(`❌ Error calculating folder stats for ${folderId}:`, error);
    return {
      size: 0,
      filesCount: 0,
    };
  }
}

// ✅ Helper function to recursively delete folder and all its contents
async function deleteFolderRecursive(folderId, userId) {
  // Get folder info before deletion
  const folder = await Folder.findOne({ _id: folderId, userId: userId });
  if (!folder) {
    return; // Folder doesn't exist or doesn't belong to user
  }

  // Find all subfolders
  const subfolders = await Folder.find({ parentId: folderId, userId: userId });

  // Recursively delete each subfolder
  for (const subfolder of subfolders) {
    await deleteFolderRecursive(subfolder._id, userId);
  }

  // Find all files in this folder
  const files = await File.find({ parentFolderId: folderId, userId: userId });

  // Delete physical files from file system
  for (const file of files) {
    const filePath = path.join(__dirname, "..", file.path);
    if (fs.existsSync(filePath)) {
      try {
        fs.unlinkSync(filePath);
      } catch (err) {
        // If file doesn't exist or can't be deleted, continue
        console.error(`Error deleting file ${filePath}:`, err.message);
      }
    }
  }

  // Delete all files from database
  await File.deleteMany({ parentFolderId: folderId, userId: userId });

  // Delete all subfolders from database (should be empty now after recursive deletion)
  await Folder.deleteMany({ parentId: folderId, userId: userId });

  // Try to delete the physical folder if it exists
  const folderPath = path.join(__dirname, "..", folder.path);
  if (fs.existsSync(folderPath)) {
    try {
      // Use rmSync if available (Node.js 14.14.0+), otherwise use rmdirSync
      if (fs.rmSync) {
        fs.rmSync(folderPath, { recursive: true, force: true });
      } else {
        fs.rmdirSync(folderPath, { recursive: true });
      }
    } catch (err) {
      // If folder doesn't exist or can't be deleted, continue
      console.error(`Error deleting folder ${folderPath}:`, err.message);
    }
  }

  // Delete the folder itself from database (must be last)
  await Folder.findByIdAndDelete(folderId);
}

// @desc    Create new empty folder
// @route   POST /api/folders/create
// @access  Private
exports.createFolder = asyncHandler(async (req, res, next) => {
  const { name, parentId } = req.body;
  const userId = req.user._id;

  if (!name) {
    return next(new ApiError("Folder name is required", 400));
  }

  const uniqueName = await generateUniqueFolderName(name, parentId, userId);

  const folder = await Folder.create({
    name: uniqueName,
    userId: userId,
    size: 0,
    path: `uploads/${uniqueName}`,
    parentId: parentId || null,
    isShared: false,
    sharedWith: [],
  });

  await logActivity(
    userId,
    "folder_created",
    "folder",
    folder._id,
    folder.name,
    {},
    {
      ipAddress: req.ip,
      userAgent: req.get("User-Agent"),
    }
  );

  res.status(201).json({
    message: "✅ Folder created successfully",
    folder: folder,
  });
});

// @desc    Upload folder with nested structure
// @route   POST /api/folders/upload
// @access  Private
exports.uploadFolder = asyncHandler(async (req, res, next) => {
  const files = req.files;
  const userId = req.user._id;
  const folderName = req.body.folderName || "Uploaded Folder";
  const parentFolderId = req.body.parentFolderId || null;

  console.log("📁 Uploading folder:", folderName, "for user:", userId);
  console.log("📁 Files count:", files ? files.length : 0);

  // ✅ دعم طرق مختلفة لإرسال relativePaths
  let relativePaths = req.body.relativePaths;

  if (!relativePaths && req.body["relativePaths[]"]) {
    relativePaths = req.body["relativePaths[]"];
  }

  if (typeof relativePaths === "string") {
    try {
      relativePaths = JSON.parse(relativePaths);
    } catch (e) {
      relativePaths = [relativePaths];
    }
  }

  if (!Array.isArray(relativePaths)) {
    relativePaths = [];
  }

  if (!files || files.length === 0) {
    return next(new ApiError("No files uploaded", 400));
  }

  if (relativePaths.length !== files.length) {
    console.warn(
      `⚠️ relativePaths count (${relativePaths.length}) != files count (${files.length})`
    );
    console.warn("⚠️ Fixing relativePaths - using file names...");
    relativePaths = files.map((file) => file.originalname);
    console.log("✅ Fixed relativePaths count:", relativePaths.length);
  }

  try {
    const uniqueFolderName = await generateUniqueFolderName(
      folderName,
      parentFolderId,
      userId
    );

    const rootFolder = await Folder.create({
      name: uniqueFolderName,
      userId: userId,
      size: 0,
      path: `uploads/${uniqueFolderName}`,
      parentId: parentFolderId,
      isShared: false,
      sharedWith: [],
    });

    const folderMap = new Map();
    folderMap.set("", rootFolder._id);

    const createdFiles = [];
    const createdFolders = [rootFolder];

    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      const relativePath = relativePaths[i];

      if (!relativePath || typeof relativePath !== "string") {
        console.warn(
          `⚠️ Invalid relativePath at index ${i}, using file name: ${file.originalname}`
        );
        const category = getCategoryByExtension(
          file.originalname,
          file.mimetype
        );

        const newFile = await File.create({
          name: file.originalname,
          type: file.mimetype,
          size: file.size,
          path: file.path,
          userId: userId,
          parentFolderId: rootFolder._id,
          category: category,
        });

        createdFiles.push(newFile);
        continue;
      }

      const hasSubfolder =
        relativePath.includes("/") && relativePath.split("/").length > 1;
      let currentParentFolderId = rootFolder._id;

      if (hasSubfolder) {
        // ✅ الحالة 1: relativePath يحتوي على مسار نسبي
        const pathParts = relativePath
          .split("/")
          .filter((part) => part.length > 0);
        const fileName = pathParts.pop() || file.originalname;
        const folderPath = pathParts.join("/");

        if (folderPath) {
          if (!folderMap.has(folderPath)) {
            const parts = folderPath
              .split("/")
              .filter((part) => part.length > 0);
            let current = "";

            for (let part of parts) {
              const currPath = current ? `${current}/${part}` : part;

              if (!folderMap.has(currPath)) {
                const parentId = current
                  ? folderMap.get(current)
                  : rootFolder._id;
                const uniqueSubFolderName = await generateUniqueFolderName(
                  part,
                  parentId,
                  userId
                );

                const newFolder = await Folder.create({
                  name: uniqueSubFolderName,
                  userId: userId,
                  size: 0,
                  path: `uploads/${uniqueFolderName}/${currPath}`,
                  parentId: parentId,
                });

                folderMap.set(currPath, newFolder._id);
                createdFolders.push(newFolder);
              }

              current = currPath;
            }
          }

          currentParentFolderId = folderMap.get(folderPath);
        }

        const category = getCategoryByExtension(
          file.originalname,
          file.mimetype
        );

        const newFile = await File.create({
          name: fileName,
          type: file.mimetype,
          size: file.size,
          path: file.path,
          userId: userId,
          parentFolderId: currentParentFolderId,
          category: category,
        });

        createdFiles.push(newFile);
      } else {
        // ✅ الحالة 2: relativePath هو فقط اسم ملف
        const category = getCategoryByExtension(
          file.originalname,
          file.mimetype
        );

        const newFile = await File.create({
          name: file.originalname,
          type: file.mimetype,
          size: file.size,
          path: file.path,
          userId: userId,
          parentFolderId: rootFolder._id,
          category: category,
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
      message: "Folder uploaded successfully",
      folder: rootFolder,
      filesCount: createdFiles.length,
      foldersCount: createdFolders.length,
      totalSize: rootFolderSize,
    });
  } catch (error) {
    console.error("❌ Error uploading folder:", error);
    return next(new ApiError("Error uploading folder: " + error.message, 500));
  }
});

// @desc    Get folder details
// @route   GET /api/folders/:id
// @access  Private
exports.getFolderDetails = asyncHandler(async (req, res, next) => {
  const folderId = req.params.id;
  const userId = req.user._id;
  const Room = require("../models/roomModel");
  const User = require("../models/userModel");

  // ✅ تشغيل folder query و count queries بشكل متوازي
  // ✅ استخدام req.folder من checkFolderAccess middleware (يحتوي على معلومات الحماية)
  const folderFromMiddleware = req.folder;
  const [folderDoc, subfoldersCount, directFilesCount] = await Promise.all([
    Folder.findById(folderId)
      .select(
        "name path size filesCount description tags isShared isStarred parentId userId sharedWith createdAt updatedAt isProtected protectionType"
      )
      .populate("userId", "name email")
      .populate("sharedWith.user", "name email"),
    Folder.countDocuments({
      parentId: folderId,
      isDeleted: false,
    }),
    File.countDocuments({
      parentFolderId: folderId,
      isDeleted: false,
    }),
  ]);

  if (!folderDoc) {
    return next(new ApiError("Folder not found", 404));
  }

  const folder = folderDoc.toObject();

  // Check if user has access
  const isOwner =
    (folder.userId._id || folder.userId).toString() === userId.toString();
  const isSharedWith =
    folder.sharedWith && folder.sharedWith.some
      ? folder.sharedWith.some((sw) => {
          const userIdInShared =
            sw.user && sw.user._id
              ? sw.user._id.toString()
              : sw.user
                ? sw.user.toString()
                : null;
          return userIdInShared === userId.toString();
        })
      : false;

  // Check if folder is shared in a room where user is a member
  let isSharedInRoom = false;
  let roomInfo = null;
  let sharedInRoomInfo = null;
  let parentFolder = null;

  // ✅ تشغيل Room query و parentFolder query بشكل متوازي
  const parallelQueries = [];

  if (!isOwner && !isSharedWith) {
    parallelQueries.push(
      Room.findOne({
        "folders.folderId": folderId,
        "members.user": userId,
        isActive: true,
      })
        .select("name description folders")
        .lean()
    );
  }

  if (folder.parentId) {
    parallelQueries.push(
      Folder.findById(folder.parentId).select("name").lean()
    );
  }

  const parallelResults = await Promise.all(parallelQueries);

  if (!isOwner && !isSharedWith) {
    const room = parallelResults[0];
    isSharedInRoom = !!room;

    if (room) {
      const folderInRoom =
        room.folders && room.folders.find
          ? room.folders.find(
              (f) => (f.folderId ? f.folderId.toString() : null) === folderId
            )
          : null;
      roomInfo = {
        _id: room._id,
        name: room.name,
        description: room.description,
      };

      if (folderInRoom && folderInRoom.sharedBy) {
        const sharedByUser = await User.findById(folderInRoom.sharedBy)
          .select("name email")
          .lean();

        sharedInRoomInfo = {
          sharedAt: folderInRoom.sharedAt,
          sharedBy: sharedByUser
            ? {
                _id: sharedByUser._id,
                name: sharedByUser.name,
                email: sharedByUser.email,
              }
            : null,
          room: roomInfo,
        };
      } else if (folderInRoom) {
        sharedInRoomInfo = {
          sharedAt: folderInRoom.sharedAt,
          sharedBy: null,
          room: roomInfo,
        };
      }
    }

    if (!isSharedInRoom) {
      return next(new ApiError("Folder not found", 404));
    }
  }

  if (folder.parentId) {
    parentFolder = parallelResults[!isOwner && !isSharedWith ? 1 : 0];
  }

  // ✅ نعرض جميع المجلدات الفرعية بما فيها المحمية (يتم طلب كلمة السر عند فتحها)
  const finalSubfoldersCount = subfoldersCount;

  // ✅ استخدام الحقول المحفوظة مباشرة بدلاً من الحساب recursive
  const totalSize = folder.size || 0;
  const totalFilesCount = folder.filesCount || 0;

  const formatBytes = (bytes) => {
    if (bytes === 0) return "0 Bytes";
    const k = 1024;
    const sizes = ["Bytes", "KB", "MB", "GB"];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
  };

  // Build response object
  const folderResponse = {
    _id: folder._id,
    name: folder.name,
    type: "folder",
    size: totalSize, // ✅ الحجم الكلي (recursive)
    sizeFormatted: formatBytes(totalSize),
    path: folder.path,
    description: folder.description || "",
    tags: folder.tags || [],
    owner: {
      _id: folder.userId._id,
      name: folder.userId.name,
      email: folder.userId.email,
    },
    parentFolder: parentFolder
      ? {
          _id: parentFolder._id,
          name: parentFolder.name,
        }
      : null,
    isShared: folder.isShared,
    sharedWith: folder.sharedWith,
    sharedWithCount: folder.sharedWith.length,
    subfoldersCount: finalSubfoldersCount,
    filesCount: totalFilesCount, // ✅ عدد الملفات الكلي (recursive)
    totalItems: finalSubfoldersCount + directFilesCount, // ✅ العناصر المباشرة فقط
    isStarred: folder.isStarred,
    isProtected: folder.isProtected || false, // ✅ إضافة معلومات الحماية
    protectionType: folder.protectionType || "none", // ✅ إضافة نوع الحماية
    createdAt: folder.createdAt,
    updatedAt: folder.updatedAt,
    lastModified: folder.updatedAt,
  };

  // Add room sharing info if shared in room
  if (isSharedInRoom && sharedInRoomInfo) {
    folderResponse.sharedInRoom = {
      room: sharedInRoomInfo.room,
      sharedAt: sharedInRoomInfo.sharedAt,
      lastModified: folder.updatedAt,
    };
  }

  res.status(200).json({
    message: "Folder details retrieved successfully",
    folder: folderResponse,
  });
});

// @desc    Get folder contents (with pagination)
// @route   GET /api/folders/:id/contents
// @access  Private
exports.getFolderContents = asyncHandler(async (req, res, next) => {
  const folderId = req.params.id;
  const userId = req.user._id;
  const roomId = req.query.roomId; // ✅ معامل اختياري للغرفة

  // ✅ Pagination parameters
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 20;
  const skip = (page - 1) * limit;

  let folder;

  // ✅ إذا كان roomId موجوداً، تحقق من أن المجلد مشترك في الروم
  if (roomId) {
    const Room = require("../models/roomModel");

    // ✅ التحقق من أن المستخدم عضو في الغرفة أولاً
    const room = await Room.findOne({
      _id: roomId,
      "members.user": userId,
      isActive: true,
    });

    if (!room) {
      return next(new ApiError("Room not found or you are not a member", 404));
    }

    // ✅ التحقق من أن المجلد مشترك في هذه الغرفة
    // ✅ التعامل مع folderId سواء كان ObjectId أو string أو object مملوء
    const folderInRoom = room.folders.find((f) => {
      if (!f.folderId) return false;

      // ✅ إذا كان folderId object مملوء (مثل { _id: ..., name: ... })
      if (typeof f.folderId === "object" && f.folderId._id) {
        return String(f.folderId._id) === String(folderId);
      }

      // ✅ إذا كان folderId ObjectId أو string
      const folderIdStr =
        typeof f.folderId === "object" && f.folderId.toString
          ? f.folderId.toString()
          : String(f.folderId);
      return folderIdStr === String(folderId);
    });

    if (!folderInRoom) {
      return next(new ApiError("Folder not found in room", 404));
    }

    // ✅ جلب المجلد مباشرة (حتى لو لم يكن مملوكاً من قبل المستخدم)
    folder = await Folder.findOne({ _id: folderId, isDeleted: false });
    if (!folder) {
      return next(new ApiError("Folder not found", 404));
    }
  } else {
    // ✅ البحث عن المجلدات التي يملكها المستخدم فقط
    folder = await Folder.findOne({ _id: folderId, userId: userId });
    if (!folder) {
      return next(new ApiError("Folder not found", 404));
    }
  }

  // ✅ جلب جميع subfolders و files (بدون pagination أولاً)
  const allSubfolders = await Folder.find({
    parentId: folderId,
    isDeleted: false,
  }).sort({ createdAt: -1 });

  const allFiles = await File.find({
    parentFolderId: folderId,
    isDeleted: false,
  }).sort({ createdAt: -1 });

  const totalSubfolders = allSubfolders.length;
  const totalFiles = allFiles.length;

  // ✅ دمج subfolders و files مع إضافة type
  // ✅ التأكد من أن _id يتم تحويله إلى string بشكل صحيح
  const allContents = [
    ...allSubfolders.map((f) => {
      const obj = f.toObject();
      // ✅ التأكد من أن _id موجود كـ string
      if (obj._id && typeof obj._id !== "string") {
        obj._id = obj._id.toString();
      }
      return { ...obj, type: "folder" };
    }),
    ...allFiles.map((f) => {
      const obj = f.toObject();
      // ✅ التأكد من أن _id موجود كـ string
      if (obj._id && typeof obj._id !== "string") {
        obj._id = obj._id.toString();
      }
      // ✅ التأكد من أن path موجود
      if (!obj.path) {
        console.log(
          "⚠️ [getFolderContents] File missing path:",
          obj._id,
          obj.name
        );
      }
      return { ...obj, type: "file" };
    }),
  ];

  // ✅ تطبيق pagination على المدمج
  const totalItems = allContents.length;
  const paginatedContents = allContents.slice(skip, skip + limit);

  // ✅ فصل subfolders و files من النتائج المصفاة
  const subfolders = paginatedContents.filter((item) => item.type === "folder");
  const files = paginatedContents.filter((item) => item.type === "file");

  // ✅ Logging للتحقق من البيانات
  if (roomId && files.length > 0) {
    console.log(
      "📂 [getFolderContents] Room folder - Files count:",
      files.length
    );
    console.log("📂 [getFolderContents] First file sample:", {
      _id: files[0]._id,
      name: files[0].name,
      path: files[0].path,
      hasId: !!files[0]._id,
      hasPath: !!files[0].path,
    });
  }

  // ✅ حساب الحجم وعدد الملفات للمجلدات الفرعية المعروضة
  const subfoldersWithDetails = await Promise.all(
    subfolders.map(async (subfolder) => {
      const subfolderObj = { ...subfolder };

      // ✅ حساب الحجم وعدد الملفات بشكل recursive
      const size = await calculateFolderSizeRecursive(subfolder._id);
      const filesCount = await calculateFolderFilesCountRecursive(
        subfolder._id
      );

      // ✅ تحديث القيم
      subfolderObj.size = size;
      subfolderObj.filesCount = filesCount;

      return subfolderObj;
    })
  );

  // ✅ تحديث paginatedContents مع القيم المحسوبة
  const updatedPaginatedContents = paginatedContents.map((item) => {
    if (item.type === "folder") {
      const updatedSubfolder = subfoldersWithDetails.find(
        (s) => s._id.toString() === item._id.toString()
      );
      return updatedSubfolder || item;
    }
    return item;
  });

  res.status(200).json({
    message: "Folder contents retrieved successfully",
    folder: folder,
    contents: updatedPaginatedContents,
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
      hasPrev: page > 1,
    },
  });
});

// @desc    Get all folders for user (without parent - parentId = null)
// @route   GET /api/folders
// @access  Private
exports.getAllFolders = asyncHandler(async (req, res, next) => {
  const userId = req.user._id;

  // ✅ فقط المجلدات بدون parent (null)
  const parentId = null;

  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const skip = (page - 1) * limit;

  const query = {
    userId,
    isDeleted: false,
    parentId: null, // ✅ فقط المجلدات بدون parent
  };

  const folders = await Folder.find(query)
    .skip(skip)
    .limit(limit)
    .sort({ createdAt: -1 });

  const totalFolders = await Folder.countDocuments(query);

  // ✅ حساب الحجم وعدد الملفات لكل مجلد
  // ✅ استخدام calculateFolderStatsRecursive لأنها أكثر كفاءة (تحسب كل شيء في مرة واحدة)
  const foldersWithDetails = await Promise.all(
    folders.map(async (folder) => {
      // ✅ تحويل إلى plain object أولاً
      const folderObj = folder.toObject ? folder.toObject() : { ...folder };

      // ✅ حساب الإحصائيات بشكل recursive (أكثر كفاءة - يحسب الحجم والعدد معاً)
      const stats = await calculateFolderStatsRecursive(folder._id);

      // ✅ التأكد من أن stats موجود وأنه object
      if (!stats || typeof stats !== "object") {
        console.error(`❌ Invalid stats for folder ${folder._id}:`, stats);
        folderObj.size = 0;
        folderObj.filesCount = 0;
        return folderObj;
      }

      // ✅ استخراج القيم مع قيم افتراضية
      const size = Number(stats.size) || 0;
      const filesCount = Number(stats.filesCount) || 0;

      // ✅ Log للتحقق من القيم المحسوبة
      console.log(`📁 Folder: ${folder.name} (${folder._id})`);
      console.log(`   ✅ Stats object:`, JSON.stringify(stats));
      console.log(
        `   ✅ Calculated Size: ${size} bytes (${(size / 1024 / 1024).toFixed(
          2
        )} MB)`
      );
      console.log(`   ✅ Calculated Files Count: ${filesCount}`);

      // ✅ إنشاء object جديد مع القيم المحدثة - للتأكد من تضمينها في JSON
      const updatedFolderObj = {
        ...folderObj,
        size: size,
        filesCount: filesCount,
      };

      // ✅ Log للتحقق من القيم بعد الإضافة
      console.log(
        `   ✅ After update - size: ${updatedFolderObj.size}, filesCount: ${updatedFolderObj.filesCount}`
      );
      console.log(
        `   ✅ Has filesCount key: ${"filesCount" in updatedFolderObj}`
      );
      console.log(
        `   ✅ Final object sample:`,
        JSON.stringify({
          _id: updatedFolderObj._id,
          name: updatedFolderObj.name,
          size: updatedFolderObj.size,
          filesCount: updatedFolderObj.filesCount,
        })
      );

      return updatedFolderObj;
    })
  );

  // ✅ التحقق النهائي من القيم قبل الإرسال
  console.log("📦 Final folders with details:");
  foldersWithDetails.forEach((folder, index) => {
    console.log(`   Folder ${index + 1}: ${folder.name}`);
    console.log(`      size: ${folder.size} (type: ${typeof folder.size})`);
    console.log(
      `      filesCount: ${
        folder.filesCount
      } (type: ${typeof folder.filesCount})`
    );
  });

  res.status(200).json({
    message: "Folders retrieved successfully",
    folders: foldersWithDetails,
    pagination: {
      currentPage: page,
      totalPages: Math.ceil(totalFolders / limit),
      totalFolders: totalFolders,
      hasNext: page < Math.ceil(totalFolders / limit),
      hasPrev: page > 1,
    },
  });
});

// @desc    Get all items (files + folders) without parent
// @route   GET /api/folders/all-items
// @access  Private
exports.getAllItems = asyncHandler(async (req, res, next) => {
  const userId = req.user._id;

  // ✅ فقط المجلدات والملفات بدون parent (null)
  const parentId = null;

  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 20;
  const skip = (page - 1) * limit;

  const folderQuery = {
    userId,
    isDeleted: false,
    parentId: null, // ✅ فقط المجلدات بدون parent
  };

  const fileQuery = {
    userId,
    isDeleted: false,
    parentFolderId: null, // ✅ فقط الملفات بدون parent
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

  // ✅ حساب الحجم وعدد الملفات لكل مجلد
  const foldersWithDetails = await Promise.all(
    folders.map(async (folder) => {
      const folderObj = folder.toObject();

      // ✅ حساب الحجم وعدد الملفات بشكل recursive
      const size = await calculateFolderSizeRecursive(folder._id);
      const filesCount = await calculateFolderFilesCountRecursive(folder._id);

      folderObj.size = size;
      folderObj.filesCount = filesCount;

      return { ...folderObj, type: "folder" };
    })
  );

  const allItems = [
    ...foldersWithDetails,
    ...files.map((file) => ({ ...file.toObject(), type: "file" })),
  ];

  const totalItems = totalFolders + totalFiles;

  res.status(200).json({
    message: "All items retrieved successfully",
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
      hasPrev: page > 1,
    },
  });
});

// @desc    Get recent folders
// @route   GET /api/folders/recent
// @access  Private
exports.getRecentFolders = asyncHandler(async (req, res, next) => {
  const userId = req.user._id;
  const limit = parseInt(req.query.limit) || 10;

  const folders = await Folder.find({ userId, isDeleted: false })
    .sort({ createdAt: -1 })
    .limit(limit);

  // ✅ حساب الحجم وعدد الملفات لكل مجلد
  const foldersWithDetails = await Promise.all(
    folders.map(async (folder) => {
      const folderObj = folder.toObject();

      // ✅ حساب الحجم وعدد الملفات بشكل recursive
      const size = await calculateFolderSizeRecursive(folder._id);
      const filesCount = await calculateFolderFilesCountRecursive(folder._id);

      folderObj.size = size;
      folderObj.filesCount = filesCount;

      return folderObj;
    })
  );

  res.status(200).json({
    message: "Recent folders retrieved successfully",
    folders: foldersWithDetails,
  });
});

// @desc    Update folder
// @route   PUT /api/folders/:id
// @access  Private
exports.updateFolder = asyncHandler(async (req, res, next) => {
  const folderId = req.params.id;
  const userId = req.user._id;
  const { name, description, tags } = req.body;

  const folder = await Folder.findOne({ _id: folderId, userId: userId });

  if (!folder) {
    return next(new ApiError("Folder not found", 404));
  }

  if (name) folder.name = name;
  if (description !== undefined) folder.description = description;
  if (tags !== undefined) folder.tags = tags;

  await folder.save();

  res.status(200).json({
    message: "✅ Folder updated successfully",
    folder: folder,
  });
});

// @desc    Delete folder (soft delete)
// @route   DELETE /api/folders/:id
// @access  Private
exports.deleteFolder = asyncHandler(async (req, res, next) => {
  const folderId = req.params.id;
  const userId = req.user._id;

  const folder = await Folder.findOne({ _id: folderId, userId: userId });

  if (!folder) {
    return next(new ApiError("Folder not found", 404));
  }

  // Mark folder as deleted
  folder.isDeleted = true;
  folder.deletedAt = new Date();
  await folder.save();

  // Recursively mark all subfolders as deleted
  async function markSubfoldersAsDeleted(parentId) {
    const subfolders = await Folder.find({
      parentId: parentId,
      userId: userId,
      isDeleted: false,
    });

    for (const subfolder of subfolders) {
      subfolder.isDeleted = true;
      subfolder.deletedAt = new Date();
      await subfolder.save();
      // Recursively mark children
      await markSubfoldersAsDeleted(subfolder._id);
    }
  }

  // Mark all subfolders as deleted recursively
  await markSubfoldersAsDeleted(folderId);

  // Mark all files in this folder and subfolders as deleted
  // Get all folder IDs including subfolders
  async function getAllSubfolderIds(parentId) {
    const folderIds = [parentId];
    const subfolders = await Folder.find({
      parentId: parentId,
      userId: userId,
    });

    for (const subfolder of subfolders) {
      const childIds = await getAllSubfolderIds(subfolder._id);
      folderIds.push(...childIds);
    }

    return folderIds;
  }

  const allFolderIds = await getAllSubfolderIds(folderId);

  await File.updateMany(
    { parentFolderId: { $in: allFolderIds }, userId: userId },
    { isDeleted: true, deletedAt: new Date() }
  );

  res.status(200).json({
    message: "✅ Folder deleted successfully",
    folder: folder,
  });
});

// @desc    Restore folder
// @route   PUT /api/folders/:id/restore
// @access  Private
exports.restoreFolder = asyncHandler(async (req, res, next) => {
  const folderId = req.params.id;
  const userId = req.user._id;

  const folder = await Folder.findOne({ _id: folderId, userId: userId });

  if (!folder) {
    return next(new ApiError("Folder not found", 404));
  }

  folder.isDeleted = false;
  folder.deletedAt = null;
  await folder.save();

  res.status(200).json({
    message: "✅ Folder restored successfully",
    folder: folder,
  });
});

// @desc    Delete folder permanently
// @route   DELETE /api/folders/:id/permanent
// @access  Private
exports.deleteFolderPermanent = asyncHandler(async (req, res, next) => {
  const folderId = req.params.id;
  const userId = req.user._id;

  const folder = await Folder.findOne({ _id: folderId, userId: userId });

  if (!folder) {
    return next(new ApiError("Folder not found", 404));
  }

  // Recursively delete folder and all its contents
  await deleteFolderRecursive(folderId, userId);

  // Log activity
  await logActivity(
    userId,
    "folder_permanently_deleted",
    "folder",
    folderId,
    folder.name,
    {
      originalSize: folder.size,
    },
    {
      ipAddress: req.ip,
      userAgent: req.get("User-Agent"),
    }
  );

  res.status(200).json({
    message: "✅ Folder and all its contents deleted permanently",
  });
});

// @desc    Get trash folders
// @route   GET /api/folders/trash
// @access  Private
exports.getTrashFolders = asyncHandler(async (req, res, next) => {
  const userId = req.user._id;
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 20;
  const skip = (page - 1) * limit;

  const folders = await Folder.find({ userId, isDeleted: true })
    .sort({ deletedAt: -1 })
    .skip(skip)
    .limit(limit);

  const totalFolders = await Folder.countDocuments({ userId, isDeleted: true });

  // ✅ حساب الحجم وعدد الملفات لكل مجلد (حتى المحذوفة، إذا كانت البيانات موجودة)
  const foldersWithDetails = await Promise.all(
    folders.map(async (folder) => {
      const folderObj = folder.toObject();

      // ✅ حساب الحجم وعدد الملفات بشكل recursive (حتى لو كانت محذوفة)
      const size = await calculateFolderSizeRecursive(folder._id);
      const filesCount = await calculateFolderFilesCountRecursive(folder._id);

      folderObj.size = size;
      folderObj.filesCount = filesCount;

      return folderObj;
    })
  );

  res.status(200).json({
    message: "Trash folders retrieved successfully",
    folders: foldersWithDetails,
    pagination: {
      currentPage: page,
      totalPages: Math.ceil(totalFolders / limit),
      totalFolders: totalFolders,
      hasNext: page < Math.ceil(totalFolders / limit),
      hasPrev: page > 1,
    },
  });
});

// @desc    Clean expired folders
// @route   DELETE /api/folders/clean-expired
// @access  Private
exports.cleanExpiredFolders = asyncHandler(async (req, res, next) => {
  // Implementation for cleaning expired folders
  res.status(200).json({
    message: "Clean expired folders",
  });
});

// @desc    Star/Unstar folder
// @route   PUT /api/folders/:id/star
// @access  Private
exports.toggleStarFolder = asyncHandler(async (req, res, next) => {
  const folderId = req.params.id;
  const userId = req.user._id;

  const folder = await Folder.findOne({ _id: folderId, userId: userId });

  if (!folder) {
    return next(new ApiError("Folder not found", 404));
  }

  folder.isStarred = !folder.isStarred;
  await folder.save();

  res.status(200).json({
    message: folder.isStarred ? "✅ Folder starred" : "✅ Folder unstarred",
    folder: folder,
  });
});

// @desc    Get starred folders
// @route   GET /api/folders/starred
// @access  Private
exports.getStarredFolders = asyncHandler(async (req, res, next) => {
  const userId = req.user._id;
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 20;
  const skip = (page - 1) * limit;

  const folders = await Folder.find({
    userId,
    isStarred: true,
    isDeleted: false,
  })
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limit);

  const totalFolders = await Folder.countDocuments({
    userId,
    isStarred: true,
    isDeleted: false,
  });

  // ✅ حساب الحجم وعدد الملفات لكل مجلد
  const foldersWithDetails = await Promise.all(
    folders.map(async (folder) => {
      const folderObj = folder.toObject();

      // ✅ حساب الحجم وعدد الملفات بشكل recursive
      const size = await calculateFolderSizeRecursive(folder._id);
      const filesCount = await calculateFolderFilesCountRecursive(folder._id);

      folderObj.size = size;
      folderObj.filesCount = filesCount;

      return folderObj;
    })
  );

  res.status(200).json({
    message: "Starred folders retrieved successfully",
    folders: foldersWithDetails,
    pagination: {
      currentPage: page,
      totalPages: Math.ceil(totalFolders / limit),
      totalFolders: totalFolders,
      hasNext: page < Math.ceil(totalFolders / limit),
      hasPrev: page > 1,
    },
  });
});

// ✅ SHARING FUNCTIONS - Folder Sharing

// @desc    Share folder with users
// @route   POST /api/folders/:id/share
// @access  Private
exports.shareFolder = asyncHandler(async (req, res, next) => {
  const folderId = req.params.id;
  const userId = req.user._id;
  const { users, permission } = req.body;

  if (!users || !Array.isArray(users) || users.length === 0) {
    return next(new ApiError("Users array is required", 400));
  }

  if (!permission || !["view", "edit", "delete"].includes(permission)) {
    return next(new ApiError("Valid permission is required", 400));
  }

  const folder = await Folder.findOne({ _id: folderId, userId: userId });

  if (!folder) {
    return next(new ApiError("Folder not found", 404));
  }

  const userDocuments = await User.find({ _id: { $in: users } });

  if (userDocuments.length !== users.length) {
    return next(new ApiError("One or more users not found", 400));
  }

  const usersToShare = users.filter(
    (id) => id.toString() !== userId.toString()
  );

  if (usersToShare.length === 0) {
    return next(new ApiError("Cannot share with yourself", 400));
  }

  const alreadyShared = folder.sharedWith.map((sw) => sw.user.toString());
  const newUsers = usersToShare.filter(
    (id) => !alreadyShared.includes(id.toString())
  );

  for (const userIdToAdd of newUsers) {
    folder.sharedWith.push({
      user: userIdToAdd,
      permission: permission,
      sharedAt: new Date(),
    });
  }

  folder.isShared = folder.sharedWith.length > 0;
  await folder.save();

  await folder.populate("sharedWith.user", "name email");

  await logActivity(
    userId,
    "folder_shared",
    "folder",
    folder._id,
    folder.name,
    {
      sharedUsers: newUsers,
      permission: permission,
    },
    {
      ipAddress: req.ip,
      userAgent: req.get("User-Agent"),
    }
  );

  res.status(200).json({
    message: "✅ Folder shared successfully",
    folder: folder,
    newlyShared: newUsers.length,
  });
});

// @desc    Update folder permissions
// @route   PUT /api/folders/:id/share
// @access  Private
exports.updateFolderPermissions = asyncHandler(async (req, res, next) => {
  const folderId = req.params.id;
  const userId = req.user._id;
  const { userPermissions } = req.body;

  if (!userPermissions || !Array.isArray(userPermissions)) {
    return next(new ApiError("userPermissions array is required", 400));
  }

  const folder = await Folder.findOne({ _id: folderId, userId: userId });

  if (!folder) {
    return next(new ApiError("Folder not found", 404));
  }

  let updatedCount = 0;

  for (const { userId: targetUserId, permission } of userPermissions) {
    if (!["view", "edit", "delete"].includes(permission)) continue;

    const sharedEntry = folder.sharedWith.find(
      (sw) => sw.user.toString() === targetUserId.toString()
    );

    if (sharedEntry) {
      sharedEntry.permission = permission;
      updatedCount++;
    }
  }

  if (updatedCount === 0) {
    return next(new ApiError("No valid permissions to update", 400));
  }

  await folder.save();
  await folder.populate("sharedWith.user", "name email");

  res.status(200).json({
    message: `✅ Permissions updated for ${updatedCount} user(s)`,
    folder: folder,
  });
});

// @desc    Unshare folder
// @route   DELETE /api/folders/:id/share
// @access  Private
exports.unshareFolder = asyncHandler(async (req, res, next) => {
  const folderId = req.params.id;
  const userId = req.user._id;
  const { users } = req.body;

  if (!users || !Array.isArray(users)) {
    return next(new ApiError("Users array is required", 400));
  }

  const folder = await Folder.findOne({ _id: folderId, userId: userId });

  if (!folder) {
    return next(new ApiError("Folder not found", 404));
  }

  const initialCount = folder.sharedWith.length;
  folder.sharedWith = folder.sharedWith.filter(
    (sw) => !users.includes(sw.user.toString())
  );
  folder.isShared = folder.sharedWith.length > 0;
  await folder.save();

  const removedCount = initialCount - folder.sharedWith.length;

  res.status(200).json({
    message: `✅ ${removedCount} user(s) removed from sharing`,
    folder: folder,
  });
});

// @desc    Get folders shared with me
// @route   GET /api/folders/shared-with-me
// @access  Private
exports.getFoldersSharedWithMe = asyncHandler(async (req, res, next) => {
  const userId = req.user._id;
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const skip = (page - 1) * limit;

  const folders = await Folder.find({
    "sharedWith.user": userId,
    isDeleted: false,
  })
    .populate("userId", "name email")
    .skip(skip)
    .limit(limit)
    .sort({ createdAt: -1 });

  const totalFolders = await Folder.countDocuments({
    "sharedWith.user": userId,
    isDeleted: false,
  });

  // ✅ حساب الحجم وعدد الملفات لكل مجلد مشترك
  const formattedFolders = await Promise.all(
    folders.map(async (folder) => {
      const folderObj = folder.toObject();
      const sharedEntry = folder.sharedWith.find(
        (sw) => sw.user.toString() === userId.toString()
      );

      // ✅ حساب الحجم وعدد الملفات بشكل recursive
      const size = await calculateFolderSizeRecursive(folder._id);
      const filesCount = await calculateFolderFilesCountRecursive(folder._id);

      return {
        ...folderObj,
        size: size, // ✅ الحجم الكلي (recursive)
        filesCount: filesCount, // ✅ عدد الملفات الكلي (recursive)
        myPermission: sharedEntry ? sharedEntry.permission : null,
      };
    })
  );

  res.status(200).json({
    message: "Folders shared with me retrieved successfully",
    folders: formattedFolders,
    pagination: {
      currentPage: page,
      totalPages: Math.ceil(totalFolders / limit),
      totalFolders: totalFolders,
      hasNext: page < Math.ceil(totalFolders / limit),
      hasPrev: page > 1,
    },
  });
});

// @desc    Get shared folder details in room
// @route   GET /api/folders/shared-in-room/:id
// @access  Private
exports.getSharedFolderDetailsInRoom = asyncHandler(async (req, res, next) => {
  const folderId = req.params.id;
  const userId = req.user._id;

  const Room = require("../models/roomModel");

  // Find room where folder is shared and user is a member
  const room = await Room.findOne({
    "folders.folderId": folderId,
    "members.user": userId,
    isActive: true,
  })
    .populate("owner", "name email")
    .populate("members.user", "name email");

  if (!room) {
    return next(
      new ApiError("Folder not found in any room you're a member of", 404)
    );
  }

  // Get folder from room
  const folderInRoom = room.folders.find(
    (f) => f.folderId.toString() === folderId
  );
  if (!folderInRoom) {
    return next(new ApiError("Folder not found in room", 404));
  }

  // Get folder details
  const folder = await Folder.findById(folderId).populate(
    "userId",
    "name email"
  );

  if (!folder) {
    return next(new ApiError("Folder not found", 404));
  }

  // Get sharedBy user info
  let sharedByUser = null;
  if (folderInRoom.sharedBy) {
    sharedByUser = await User.findById(folderInRoom.sharedBy).select(
      "name email"
    );
  }

  // Calculate readable size
  const formatBytes = (bytes) => {
    if (bytes === 0) return "0 Bytes";
    const k = 1024;
    const sizes = ["Bytes", "KB", "MB", "GB"];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
  };

  // Get subfolders and files count
  const subfoldersCount = await Folder.countDocuments({
    parentId: folderId,
    isDeleted: false,
  });

  // ✅ حساب الحجم وعدد الملفات بشكل recursive
  const totalSize = await calculateFolderSizeRecursive(folderId);
  const totalFilesCount = await calculateFolderFilesCountRecursive(folderId);
  const directFilesCount = await File.countDocuments({
    parentFolderId: folderId,
    isDeleted: false,
  });

  res.status(200).json({
    message: "Shared folder details retrieved successfully",
    folder: {
      _id: folder._id,
      name: folder.name,
      category: "folder", // Folders don't have category, but we can set it as 'folder'
      size: totalSize, // ✅ الحجم الكلي (recursive)
      sizeFormatted: formatBytes(totalSize),
      filesCount: totalFilesCount, // ✅ عدد الملفات الكلي (recursive)
      sharedAt: folderInRoom.sharedAt,
      lastModified: folder.updatedAt,
      sharedBy: sharedByUser
        ? {
            _id: sharedByUser._id,
            name: sharedByUser.name,
            email: sharedByUser.email,
          }
        : null,
      room: {
        _id: room._id,
        name: room.name,
        description: room.description,
      },
      owner: {
        _id: folder.userId._id,
        name: folder.userId.name,
        email: folder.userId.email,
      },
      subfoldersCount: subfoldersCount,
      filesCount: filesCount,
      totalItems: subfoldersCount + filesCount,
      isProtected: folder.isProtected || false, // ✅ إضافة معلومات الحماية
      protectionType: folder.protectionType || "none", // ✅ إضافة نوع الحماية
    },
  });
});

// ✅ ========================================
// ✅ Endpoints لحساب حجم المجلد وعدد الملفات
// ✅ ========================================

/**
 * @desc    حساب حجم مجلد معين
 * @route   GET /api/folders/:id/size
 * @access  Private
 */
exports.getFolderSize = asyncHandler(async (req, res, next) => {
  const folderId = req.params.id;
  const userId = req.user._id;

  // ✅ التحقق من وجود المجلد وأنه يخص المستخدم
  const folder = await Folder.findOne({
    _id: folderId,
    userId: userId,
    isDeleted: false,
  });

  if (!folder) {
    return next(new ApiError("Folder not found", 404));
  }

  // ✅ حساب الحجم بشكل recursive
  const totalSize = await calculateFolderSizeRecursive(folderId);

  // ✅ تنسيق الحجم
  const formatBytes = (bytes) => {
    if (bytes === 0) return "0 Bytes";
    const k = 1024;
    const sizes = ["Bytes", "KB", "MB", "GB", "TB"];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
  };

  res.status(200).json({
    message: "Folder size calculated successfully",
    folder: {
      _id: folder._id,
      name: folder.name,
    },
    size: totalSize,
    sizeFormatted: formatBytes(totalSize),
  });
});

/**
 * @desc    حساب عدد الملفات في مجلد معين
 * @route   GET /api/folders/:id/files-count
 * @access  Private
 */
exports.getFolderFilesCount = asyncHandler(async (req, res, next) => {
  const folderId = req.params.id;
  const userId = req.user._id;

  // ✅ التحقق من وجود المجلد وأنه يخص المستخدم
  const folder = await Folder.findOne({
    _id: folderId,
    userId: userId,
    isDeleted: false,
  });

  if (!folder) {
    return next(new ApiError("Folder not found", 404));
  }

  // ✅ حساب عدد الملفات بشكل recursive
  const totalFilesCount = await calculateFolderFilesCountRecursive(folderId);

  res.status(200).json({
    message: "Folder files count calculated successfully",
    folder: {
      _id: folder._id,
      name: folder.name,
    },
    filesCount: totalFilesCount,
  });
});

/**
 * @desc    حساب إحصائيات المجلد (الحجم وعدد الملفات) - الأكثر كفاءة
 * @route   GET /api/folders/:id/stats
 * @access  Private
 */
exports.getFolderStats = asyncHandler(async (req, res, next) => {
  const folderId = req.params.id;
  const userId = req.user._id;

  // ✅ التحقق من وجود المجلد وأنه يخص المستخدم
  const folder = await Folder.findOne({
    _id: folderId,
    userId: userId,
    isDeleted: false,
  });

  if (!folder) {
    return next(new ApiError("Folder not found", 404));
  }

  // ✅ حساب الإحصائيات بشكل recursive (أكثر كفاءة - يحسب كل شيء في مرة واحدة)
  const stats = await calculateFolderStatsRecursive(folderId);

  // ✅ تنسيق الحجم
  const formatBytes = (bytes) => {
    if (bytes === 0) return "0 Bytes";
    const k = 1024;
    const sizes = ["Bytes", "KB", "MB", "GB", "TB"];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
  };

  res.status(200).json({
    message: "Folder statistics calculated successfully",
    folder: {
      _id: folder._id,
      name: folder.name,
    },
    stats: {
      size: stats.size,
      sizeFormatted: formatBytes(stats.size),
      filesCount: stats.filesCount,
    },
  });
});
