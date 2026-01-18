/// endpoints للـ API
/// ⚠️ ملاحظة: جميع الـ endpoints تبدأ بـ /api/v1 لأن baseUrl لا يحتوي عليها

class ApiEndpoints {
  // Base path
  static const String _basePath = '/api/v1';
  
  // Auth endpoints
  static const String login = '$_basePath/auth/login';
  static const String register = '$_basePath/auth/registerUser';
  static const String logout = '$_basePath/users/logout';  // ✅ تصحيح: logout موجود في users
  static const String refreshToken = '$_basePath/auth/refresh';
  static const String forgotPassword = '$_basePath/auth/forgotPassword';
  static const String verifyResetCode = '$_basePath/auth/verifyResetCode';
  static const String resetPassword = '$_basePath/auth/resetPassword';
  static const String verifyEmail =
      '$_basePath/auth/verifyEmail'; // ✅ التحقق من كود البريد الإلكتروني
  static const String resendVerificationCode =
      '$_basePath/auth/resendVerificationCode'; // ✅ إعادة إرسال كود التحقق

  // Folders endpoints
  static const String folders = '$_basePath/folders/create';
  static String folderById(String id) => '$_basePath/folders/$id';
  static String folderFiles(String id) => '$_basePath/folders/$id/files';
  static String folderContents(String id) => '$_basePath/folders/$id/contents';
  static const String uploadFolder = '$_basePath/folders/upload';
  static const String allFolders = '$_basePath/folders';
  static const String allItems = '$_basePath/folders/all-items';
  static String updateFolder(String id) =>
      '$_basePath/folders/$id'; // ✅ endpoint لتحديث المجلد
  static String moveFolder(String id) =>
      '$_basePath/folders/$id/move'; // ✅ نقل مجلد من مجلد إلى آخر
  static String shareFolder(String id) =>
      '$_basePath/folders/$id/share'; // ✅ مشاركة المجلد
  static const String foldersSharedWithMe =
      '$_basePath/folders/shared-with-me'; // ✅ المجلدات المشتركة معي
  static String deleteFolder(String id) => '$_basePath/folders/$id'; // ✅ حذف مجلد
  static String restoreFolder(String id) =>
      '$_basePath/folders/$id/restore'; // ✅ استعادة مجلد
  static String deleteFolderPermanent(String id) =>
      '$_basePath/folders/$id/permanent'; // ✅ حذف نهائي لمجلد
  static const String trashFolders = '$_basePath/folders/trash'; // ✅ المجلدات المحذوفة
  static const String cleanExpiredFolders =
      '$_basePath/folders/clean-expired'; // ✅ تنظيف المجلدات المنتهية
  static String toggleStarFolder(String id) =>
      '$_basePath/folders/$id/star'; // ✅ إضافة/إزالة علامة النجمة من المجلد
  static const String starredFolders = '$_basePath/folders/starred'; // ✅ المجلدات المميزة
  static String folderSize(String id) =>
      '$_basePath/folders/$id/size'; // ✅ حساب حجم المجلد
  static String folderFilesCount(String id) =>
      '$_basePath/folders/$id/files-count'; // ✅ حساب عدد الملفات في المجلد
  static String folderStats(String id) =>
      '$_basePath/folders/$id/stats'; // ✅ حساب إحصائيات المجلد (الحجم + عدد الملفات)
  static String downloadFolder(String id) =>
      '$_basePath/folders/$id/download'; // ✅ تحميل مجلد كـ ZIP
  static const String recentFolders = '$_basePath/folders/recent'; // ✅ المجلدات الحديثة
  // 🔒 Folder Protection endpoints
  static String protectFolder(String id) =>
      '$_basePath/folders/$id/protect'; // ✅ قفل/تعيين حماية المجلد
  static String verifyFolderAccess(String id) =>
      '$_basePath/folders/$id/verify-access'; // ✅ التحقق من الوصول للمجلد
  static String removeFolderProtection(String id) =>
      '$_basePath/folders/$id/protect'; // ✅ إزالة حماية المجلد

  // Files endpoints
  static const String files = '$_basePath/files';
  static String fileById(String id) => '$_basePath/files/$id';
  static const String uploadFile = '$_basePath/files/upload';
  static const String uploadSingleFile = '$_basePath/files/upload-single';
  static const String uploadMultipleFiles = '$_basePath/files/upload-multiple';
  static String filesByCategory(String category) => '$_basePath/files/category/$category';
  static const String categoriesStats =
      '$_basePath/files/categories/stats'; // ✅ إحصائيات التصنيفات
  static const String rootCategoriesStats =
      '$_basePath/files/categories/stats/root'; // ✅ إحصائيات التصنيفات في الجذر فقط
  static String getFileDetails(String fileId) => "$_basePath/files/$fileId";
  static String updateFile(String fileId) => "$_basePath/files/$fileId";
  static String updateFileContent(String fileId) =>
      "$_basePath/files/$fileId/content"; // ✅ تحديث محتوى الملف
  static String moveFile(String fileId) =>
      "$_basePath/files/$fileId/move"; // ✅ نقل ملف من مجلد إلى آخر
  static String deleteFile(String fileId) => "$_basePath/files/$fileId";
  static String downloadFile(String fileId) => "$_basePath/files/$fileId/download";
  static String viewFile(String fileId) =>
      "$_basePath/files/$fileId/view"; // ✅ للفتح المباشر (inline)
  static const String starredFiles = '$_basePath/files/starred';
  static String toggleStarFile(String fileId) => "$_basePath/files/$fileId/star";
  static const String trashFiles = '$_basePath/files/trash';
  static String restoreTrashFile(String fileId) => "$_basePath/files/$fileId/restore";
  static String deleteFilePermanent(String fileId) =>
      "$_basePath/files/$fileId/permanent";
  static const String emptyTrash = '$_basePath/files/trash/empty';
  static const String recentFiles = '$_basePath/files/recent'; // ✅ الملفات الحديثة
  static const String storageInfo = '$_basePath/files/storage'; // ✅ معلومات المساحة التخزينية للمستخدم
  static const String totalStorageInfo = '$_basePath/files/storage/total'; // ✅ المساحة الإجمالية المستخدمة في التطبيق

  // User endpoints
  static const String getMe = '$_basePath/users/getMe';
  static const String updateMe = '$_basePath/users/updateMe';
  static const String changeMyPassword = '$_basePath/users/changeMyPassword';
  static const String deleteMe = '$_basePath/users/deleteMe';
  static const String verifyEmailChange = '$_basePath/users/verifyEmailChange'; // ✅ التحقق من كود تغيير الإيميل

  // Shared files endpoints
  static const String sharedFiles = '$_basePath/files/shared';
  static String shareFile(String id) => '$_basePath/files/$id/share';
  static String unshareFile(String id) => '$_basePath/files/$id/share';
  static String getSharedFileDetailsInRoom(String id) =>
      '$_basePath/files/shared-in-room/$id';
  static String getSharedFolderDetailsInRoom(String id) =>
      '$_basePath/folders/shared-in-room/$id';

  // Rooms endpoints
  static const String rooms = '$_basePath/rooms';
  static String roomById(String id) => '$_basePath/rooms/$id';
  static String roomMembers(String id) => '$_basePath/rooms/$id/members';
  static String roomMemberById(String roomId, String memberId) =>
      '$_basePath/rooms/$roomId/members/$memberId';
  static String roomInvitations(String id) => '$_basePath/rooms/$id/invitations';
  static String sendInvitation(String roomId) => '$_basePath/rooms/$roomId/invite';
  static const String pendingInvitations = '$_basePath/rooms/invitations/pending';
  static String acceptInvitation(String invitationId) =>
      '$_basePath/rooms/invitations/$invitationId/accept';
  static String rejectInvitation(String invitationId) =>
      '$_basePath/rooms/invitations/$invitationId/reject';
  static const String cleanupInvitations = '$_basePath/rooms/invitations/cleanup';
  static const String invitationStats = '$_basePath/rooms/invitations/stats';
  static String shareFileWithRoom(String roomId) => '$_basePath/rooms/$roomId/share-file';
  static String shareFileWithRoomOneTime(String roomId) =>
      '$_basePath/rooms/$roomId/share-file-onetime';
  static String accessOneTimeFile(String roomId, String fileId) =>
      '$_basePath/rooms/$roomId/files/$fileId/access';
  static String viewRoomFile(String roomId, String fileId) =>
      '$_basePath/rooms/$roomId/files/$fileId/view';
  static String unshareFileFromRoom(String roomId, String fileId) =>
      '$_basePath/rooms/$roomId/files/$fileId';
  static String shareFolderWithRoom(String roomId) =>
      '$_basePath/rooms/$roomId/share-folder';
  static String unshareFolderFromRoom(String roomId, String folderId) =>
      '$_basePath/rooms/$roomId/folders/$folderId';
  static String roomComments(String roomId) => '$_basePath/rooms/$roomId/comments';
  static String deleteComment(String roomId, String commentId) =>
      '$_basePath/rooms/$roomId/comments/$commentId';
  static String leaveRoom(String roomId) => '$_basePath/rooms/$roomId/leave';
  static String saveFileFromRoom(String roomId, String fileId) =>
      '$_basePath/rooms/$roomId/files/$fileId/save';
  static String saveFolderFromRoom(String roomId, String folderId) =>
      '$_basePath/rooms/$roomId/folders/$folderId/save';
  static String downloadRoomFile(String roomId, String fileId) =>
      '$_basePath/rooms/$roomId/files/$fileId/download'; // ✅ تحميل ملف من الروم
  static String downloadRoomFolder(String roomId, String folderId) =>
      '$_basePath/rooms/$roomId/folders/$folderId/download'; // ✅ تحميل مجلد من الروم كـ ZIP

  // Search endpoints
  static const String search = '$_basePath/search';

  // Smart search endpoints
  static const String smartSearch = '$_basePath/rooms/search/smart';
  static String smartSearchInRoom(String roomId) =>
      '$_basePath/rooms/$roomId/search/smart';

  // AI Search endpoints (new backend)
  static const String aiSmartSearch = '$_basePath/search/smart';
  static const String aiSearchContent = '$_basePath/search/content';
  static const String aiSearchFilename = '$_basePath/search/filename';
  static const String aiSearchByTags = '$_basePath/search/tags';
  static String aiProcessFile(String fileId) => '$_basePath/search/process/$fileId';
  static String aiReprocessFile(String fileId) => '$_basePath/search/reprocess/$fileId';
  static const String aiHFStatus = '$_basePath/search/hf-status';

  // Activity log endpoints
  static const String activityLog = '$_basePath/activity-log';
  static const String activityStatistics = '$_basePath/activity-log/statistics';
  static const String clearOldActivityLogs = '$_basePath/activity-log/clear-old';
}
