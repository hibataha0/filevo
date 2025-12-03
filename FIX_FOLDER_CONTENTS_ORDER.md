# 🔧 إصلاح ترتيب عرض محتويات المجلد - المجلدات أولاً ثم الملفات

## المشكلة
عند عرض محتويات المجلد، الترتيب غير صحيح. يجب أن تكون المجلدات أولاً ثم الملفات.

## الحل في Backend

افتح ملف `folderController.js` في Backend وابحث عن دالة `getFolderContents`.

### التعديل المطلوب

تأكد من أن الكود يدمج المجلدات أولاً ثم الملفات:

```javascript
// ✅ دمج subfolders و files مع إضافة type - المجلدات أولاً ثم الملفات
const allContents = [
    ...allSubfolders.map(f => ({ ...f.toObject(), type: 'folder' })),
    ...allFiles.map(f => ({ ...f.toObject(), type: 'file' }))
];
```

هذا الكود صحيح بالفعل! لكن إذا كان هناك مشكلة، يمكن إضافة ترتيب إضافي:

```javascript
// ✅ ترتيب: المجلدات أولاً ثم الملفات
const allContents = [
    ...allSubfolders.map(f => ({ ...f.toObject(), type: 'folder' })),
    ...allFiles.map(f => ({ ...f.toObject(), type: 'file' }))
].sort((a, b) => {
    // ✅ المجلدات دائماً قبل الملفات
    if (a.type === 'folder' && b.type === 'file') return -1;
    if (a.type === 'file' && b.type === 'folder') return 1;
    // ✅ إذا كان نفس النوع، ترتيب حسب createdAt
    return new Date(b.createdAt) - new Date(a.createdAt);
});
```

## الحل في Frontend

إذا كانت المشكلة في Frontend، تأكد من أن `folder_contents_page.dart` يعرض البيانات بالترتيب الصحيح:

```dart
// ✅ في _loadFolderContents
if (result['contents'] != null) {
  newContents = List<Map<String, dynamic>>.from(result['contents']);
  
  // ✅ ترتيب: المجلدات أولاً ثم الملفات
  newContents.sort((a, b) {
    final aType = a['type'] as String?;
    final bType = b['type'] as String?;
    
    // ✅ المجلدات دائماً قبل الملفات
    if (aType == 'folder' && bType == 'file') return -1;
    if (aType == 'file' && bType == 'folder') return 1;
    
    // ✅ إذا كان نفس النوع، ترتيب حسب createdAt
    final aDate = a['createdAt'];
    final bDate = b['createdAt'];
    if (aDate != null && bDate != null) {
      return DateTime.parse(bDate.toString()).compareTo(DateTime.parse(aDate.toString()));
    }
    return 0;
  });
}
```

## الكود الكامل المحدث للـ Backend

```javascript
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
    
    // ✅ دمج subfolders و files مع إضافة type - المجلدات أولاً ثم الملفات
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
});
```




