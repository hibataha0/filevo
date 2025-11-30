// ✅ إصلاح دالة getFilesByCategory - نسخ هذا الكود ولصقه في Backend

// @desc    Get files by category (for logged-in user only)
// @route   GET /api/files/category/:category
// @access  Private
exports.getFilesByCategory = asyncHandler(async (req, res) => {
  const { category } = req.params; // File category from URL
  const userId = req.user._id;
  const parentFolderId = req.query.parentFolderId || null;

  // ✅ Build query - إصلاح: إضافة parentFolderId: null عند طلب الملفات من الجذر
  const query = { 
    category, 
    userId, 
    isDeleted: false 
  };
  
  // ✅ إصلاح: إضافة parentFolderId إلى الـ query دائماً
  // إذا كان parentFolderId موجوداً، استخدمه
  // إذا كان null أو undefined، استخدم null (الجذر فقط)
  if (parentFolderId && parentFolderId !== 'null' && parentFolderId !== '') {
    query.parentFolderId = parentFolderId;
  } else {
    // ✅ عند طلب الملفات من الجذر، يجب إضافة parentFolderId: null
    // هذا يضمن عرض فقط الملفات بدون مجلد أب
    query.parentFolderId = null;
  }

  // جلب الملفات الخاصة بالمستخدم في نفس الفئة
  const files = await File.find(query);

  if (!files || files.length === 0) {
    return res.status(201).json({
      message: `No files found for user in category: ${category}`,
      files: []
    });
  }

  res.status(200).json({
    message: `Files in category: ${category}`,
    count: files.length,
    files,
  });
});

