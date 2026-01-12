// ✅ Route لإضافة endpoint المساحة التخزينية
// يجب إضافة هذا الكود إلى ملف routes/fileRoutes.js في الباك إند

const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const fileController = require('../controllers/fileController');

// ✅ يجب أن يكون هذا route قبل route /:id الديناميكي
// ✅ هذا مهم جداً لتجنب التعارض!
router.get('/storage', protect, fileController.getStorageInfo);

// ✅ مثال على باقي الـ routes (إذا لم تكن موجودة):
// router.get('/:id', protect, fileController.getFileDetails);
// router.get('/:id/download', protect, fileController.downloadFile);
// router.post('/upload', protect, upload.single('file'), fileController.uploadFile);
// router.delete('/:id', protect, fileController.deleteFile);

module.exports = router;


