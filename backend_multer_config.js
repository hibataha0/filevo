// ✅ إعدادات multer لرفع الملفات مع زيادة حد حجم الملف
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// ✅ إنشاء مجلد uploads إذا لم يكن موجوداً
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// ✅ إعداد storage
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, uploadDir);
    },
    filename: function (req, file, cb) {
        // ✅ إنشاء اسم فريد للملف
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
    }
});

// ✅ إعداد limits - زيادة حد حجم الملف
// ✅ 500MB لكل ملف (500 * 1024 * 1024 bytes)
// ✅ 5GB للطلب الكامل (5 * 1024 * 1024 * 1024 bytes)
const limits = {
    fileSize: 500 * 1024 * 1024, // 500MB per file
    fieldSize: 10 * 1024 * 1024, // 10MB for fields
    files: 100, // Maximum 100 files
    fields: 50, // Maximum 50 fields
    headerPairs: 2000 // Maximum 2000 header pairs
};

// ✅ إعداد multer
const upload = multer({
    storage: storage,
    limits: limits,
    fileFilter: function (req, file, cb) {
        // ✅ قبول جميع أنواع الملفات
        cb(null, true);
    }
});

// ✅ Middleware لرفع ملف واحد
const uploadSingle = upload.single('file');

// ✅ Middleware لرفع عدة ملفات (للمجلدات)
const uploadMultiple = upload.array('files', 100); // ✅ حتى 100 ملف

// ✅ Error handler مخصص
const handleMulterError = (err, req, res, next) => {
    if (err instanceof multer.MulterError) {
        if (err.code === 'LIMIT_FILE_SIZE') {
            return res.status(400).json({
                status: 'error',
                message: 'الملف كبير جداً. الحد الأقصى هو 500MB لكل ملف.',
                error: {
                    code: err.code,
                    field: err.field,
                    limit: limits.fileSize
                }
            });
        }
        if (err.code === 'LIMIT_FILE_COUNT') {
            return res.status(400).json({
                status: 'error',
                message: 'عدد الملفات كبير جداً. الحد الأقصى هو 100 ملف.',
                error: {
                    code: err.code,
                    limit: limits.files
                }
            });
        }
        if (err.code === 'LIMIT_FIELD_COUNT') {
            return res.status(400).json({
                status: 'error',
                message: 'عدد الحقول كبير جداً.',
                error: {
                    code: err.code,
                    limit: limits.fields
                }
            });
        }
        return res.status(400).json({
            status: 'error',
            message: `خطأ في رفع الملف: ${err.message}`,
            error: {
                code: err.code,
                field: err.field
            }
        });
    }
    next(err);
};

module.exports = {
    upload,
    uploadSingle,
    uploadMultiple,
    handleMulterError,
    limits
};











