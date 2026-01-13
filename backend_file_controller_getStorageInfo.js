// ✅ Controller للحصول على معلومات المساحة التخزينية
// يجب إضافة هذا الكود إلى ملف fileController.js في الباك إند

const asyncHandler = require('express-async-handler');
const File = require('../models/fileModel');
const User = require('../models/userModel');

// ✅ دالة مساعدة لحساب المساحة المستخدمة للمستخدم
async function calculateUserStorageUsed(userId) {
  try {
    // ✅ تحويل userId إلى ObjectId إذا كان string
    const mongoose = require('mongoose');
    const userIdObject = mongoose.Types.ObjectId.isValid(userId) 
      ? new mongoose.Types.ObjectId(userId) 
      : userId;

    const result = await File.aggregate([
      {
        $match: {
          userId: userIdObject,
          isDeleted: false, // ✅ فقط الملفات غير المحذوفة
        },
      },
      {
        $group: {
          _id: null,
          totalSize: { $sum: '$size' },
        },
      },
    ]);

    const totalSize = result.length > 0 ? result[0].totalSize : 0;
    return totalSize || 0;
  } catch (error) {
    console.error('❌ Error calculating user storage used:', error);
    console.error('❌ Error stack:', error.stack);
    return 0;
  }
}

// @desc    Get user storage information
// @route   GET /api/v1/files/storage
// @access  Private
exports.getStorageInfo = asyncHandler(async (req, res) => {
  try {
    // ✅ التحقق من وجود المستخدم
    if (!req.user || !req.user._id) {
      return res.status(401).json({ 
        success: false,
        message: 'Unauthorized. Please login first.' 
      });
    }

    const userId = req.user._id;

    // ✅ جلب بيانات المستخدم
    const user = await User.findById(userId).select('storageLimit storageUsed');
    if (!user) {
      return res.status(404).json({ 
        success: false,
        message: 'User not found' 
      });
    }

    // ✅ حساب المساحة المستخدمة الفعلية من الملفات
    const actualStorageUsed = await calculateUserStorageUsed(userId);

    // ✅ تحديث المساحة المستخدمة إذا كان هناك فرق (أكثر من 1KB)
    if (Math.abs(actualStorageUsed - (user.storageUsed || 0)) > 1024) {
      await User.findByIdAndUpdate(userId, { 
        storageUsed: actualStorageUsed 
      });
      user.storageUsed = actualStorageUsed;
    }

    // ✅ حساب المساحة المتاحة والنسبة المئوية
    const storageLimit = user.storageLimit || (10 * 1024 * 1024 * 1024); // Default 10 GB
    const storageUsed = user.storageUsed || 0;
    const storageAvailable = storageLimit - storageUsed;
    const storagePercentage = storageLimit > 0 
      ? (storageUsed / storageLimit) * 100 
      : 0;

    // ✅ دالة لتنسيق البايت
    const formatBytes = (bytes) => {
      if (!bytes || bytes === 0 || isNaN(bytes)) return '0 Bytes';
      const k = 1024;
      const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
      const i = Math.floor(Math.log(bytes) / Math.log(k));
      return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    };

    // ✅ إرجاع النتيجة
    // ✅ استخدام data بدلاً من storage للتوافق مع الفرونت إند
    res.status(200).json({
      success: true,
      message: 'Storage information retrieved successfully',
      data: {
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
  } catch (error) {
    console.error('❌ Error in getStorageInfo:', error);
    console.error('❌ Error stack:', error.stack);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: process.env.NODE_ENV === 'development' 
        ? error.message 
        : 'Failed to retrieve storage information',
    });
  }
});

// ✅ Export الدالة المساعدة أيضاً (في حالة الحاجة إليها في ملفات أخرى)
exports.calculateUserStorageUsed = calculateUserStorageUsed;

