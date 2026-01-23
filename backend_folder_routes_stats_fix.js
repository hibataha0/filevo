// ✅ إضافة Route لإحصائيات المجلد (الحجم وعدد الملفات)
// يجب إضافة هذا الكود إلى ملف routes/folderRoutes.js في الباك إند

const express = require('express');
const router = express.Router();
const folderController = require('../controllers/folderController'); // تأكد من المسار الصحيح
const { protect } = require('../middleware/authMiddleware');

// ✅ أضف هذا الـ route قبل routes المعرفات الديناميكية مثل /:id
// GET /api/v1/folders/:id/stats
router.get('/:id/stats', protect, folderController.getFolderStats);

module.exports = router;

// ⚠️ ملاحظة: تأكد من أن الترتيب في ملف folderRoutes.js هو:
// 1. router.get('/starred', ...)
// 2. router.get('/:id/stats', protect, folderController.getFolderStats); // ✅ هنا
// 3. router.get('/:id', protect, folderController.getFolderDetails);
