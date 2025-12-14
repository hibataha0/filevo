// ✅ إضافة Route لتحديث محتوى الملف
// @desc    Add this route to your fileRoutes.js file
// @note    يجب إضافة هذا الكود إلى ملف routes/fileRoutes.js في الباك إند

const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/authMiddleware");
const fileController = require("../controllers/fileController");
const { uploadSingle } = require("../config/multerConfig"); // ✅ تأكد من المسار الصحيح

// ✅ Route لتحديث محتوى الملف (يجب وضعه قبل route /files/:id العام)
// PUT /api/files/:id/content
router.put(
  "/files/:id/content",
  protect,
  uploadSingle,
  fileController.updateFileContent
);

module.exports = router;

// ✅ ملاحظات مهمة:
// 1. تأكد من أن هذا route يقع قبل أي route ديناميكي آخر مثل:
//    router.get('/files/:id', ...)
//    router.delete('/files/:id', ...)
//
// 2. تأكد من استيراد uploadSingle من multer config بشكل صحيح
//
// 3. تأكد من أن middleware protect موجود ويعمل
//
// 4. تأكد من أن fileController.updateFileContent موجود في controller
