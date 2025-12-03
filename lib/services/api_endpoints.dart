/// endpoints للـ API

class ApiEndpoints {
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/registerUser';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgotPassword';
  static const String verifyResetCode = '/auth/verifyResetCode';
  static const String resetPassword = '/auth/resetPassword';
  
  // Folders endpoints
  static const String folders = '/folders/create';
  static String folderById(String id) => '/folders/$id';
  static String folderFiles(String id) => '/folders/$id/files';
  static String folderContents(String id) => '/folders/$id/contents';
  static const String uploadFolder = '/folders/upload';
  static const String allFolders = '/folders';
  static const String allItems = '/folders/all-items';
  static String updateFolder(String id) => '/folders/$id'; // ✅ endpoint لتحديث المجلد
  static String moveFolder(String id) => '/folders/$id/move'; // ✅ نقل مجلد من مجلد إلى آخر
  static String shareFolder(String id) => '/folders/$id/share'; // ✅ مشاركة المجلد
  static const String foldersSharedWithMe = '/folders/shared-with-me'; // ✅ المجلدات المشتركة معي
  static String deleteFolder(String id) => '/folders/$id'; // ✅ حذف مجلد
  static String restoreFolder(String id) => '/folders/$id/restore'; // ✅ استعادة مجلد
  static String deleteFolderPermanent(String id) => '/folders/$id/permanent'; // ✅ حذف نهائي لمجلد
  static const String trashFolders = '/folders/trash'; // ✅ المجلدات المحذوفة
  static const String cleanExpiredFolders = '/folders/clean-expired'; // ✅ تنظيف المجلدات المنتهية
  static String toggleStarFolder(String id) => '/folders/$id/star'; // ✅ إضافة/إزالة علامة النجمة من المجلد
  static const String starredFolders = '/folders/starred'; // ✅ المجلدات المميزة
  static String folderSize(String id) => '/folders/$id/size'; // ✅ حساب حجم المجلد
  static String folderFilesCount(String id) => '/folders/$id/files-count'; // ✅ حساب عدد الملفات في المجلد
  static String folderStats(String id) => '/folders/$id/stats'; // ✅ حساب إحصائيات المجلد (الحجم + عدد الملفات)
  
  // Files endpoints
  static const String files = '/files';
  static String fileById(String id) => '/files/$id';
  static const String uploadFile = '/files/upload';
  static const String uploadSingleFile = '/files/upload-single';
  static const String uploadMultipleFiles = '/files/upload-multiple';
  static String filesByCategory(String category) => '/files/category/$category';
  static const String categoriesStats = '/files/categories/stats'; // ✅ إحصائيات التصنيفات
static const String rootCategoriesStats = '/files/categories/stats/root'; // ✅ إحصائيات التصنيفات في الجذر فقط
   static String getFileDetails(String fileId) => "/files/$fileId";
  static String updateFile(String fileId) => "/files/$fileId";
  static String moveFile(String fileId) => "/files/$fileId/move"; // ✅ نقل ملف من مجلد إلى آخر
  static String deleteFile(String fileId) => "/files/$fileId";
  static String downloadFile(String fileId) => "/files/$fileId/download";
 static const String starredFiles = '/files/starred'; 
  static String toggleStarFile(String fileId) => "/files/$fileId/star";
  static const String trashFiles = '/files/trash';
  static String restoreTrashFile(String fileId) => "/files/$fileId/restore";
  static String deleteFilePermanent(String fileId) => "/files/$fileId/permanent";
  static const String emptyTrash = '/files/trash/empty';



  // User endpoints
  static const String getMe = '/users/getMe';
  static const String updateMe = '/users/updateMe';
  static const String changeMyPassword = '/users/changeMyPassword';
  static const String deleteMe = '/users/deleteMe';
  
  // Shared files endpoints
  static const String sharedFiles = '/files/shared';
  static String shareFile(String id) => '/files/$id/share';
  static String unshareFile(String id) => '/files/$id/share';
  static String getSharedFileDetailsInRoom(String id) => '/files/shared-in-room/$id';
  static String getSharedFolderDetailsInRoom(String id) => '/folders/shared-in-room/$id';
  
  // Rooms endpoints
  static const String rooms = '/rooms';
  static String roomById(String id) => '/rooms/$id';
  static String roomMembers(String id) => '/rooms/$id/members';
  static String roomMemberById(String roomId, String memberId) => '/rooms/$roomId/members/$memberId';
  static String roomInvitations(String id) => '/rooms/$id/invitations';
  static String sendInvitation(String roomId) => '/rooms/$roomId/invite';
  static const String pendingInvitations = '/rooms/invitations/pending';
  static String acceptInvitation(String invitationId) => '/rooms/invitations/$invitationId/accept';
  static String rejectInvitation(String invitationId) => '/rooms/invitations/$invitationId/reject';
  static const String cleanupInvitations = '/rooms/invitations/cleanup';
  static const String invitationStats = '/rooms/invitations/stats';
  static String shareFileWithRoom(String roomId) => '/rooms/$roomId/share-file';
  static String shareFileWithRoomOneTime(String roomId) => '/rooms/$roomId/share-file-onetime';
  static String accessOneTimeFile(String roomId, String fileId) => '/rooms/$roomId/files/$fileId/access';
  static String unshareFileFromRoom(String roomId, String fileId) => '/rooms/$roomId/share-file/$fileId';
  static String shareFolderWithRoom(String roomId) => '/rooms/$roomId/share-folder';
  static String unshareFolderFromRoom(String roomId, String folderId) => '/rooms/$roomId/share-folder/$folderId';
  static String roomComments(String roomId) => '/rooms/$roomId/comments';
  static String deleteComment(String roomId, String commentId) => '/rooms/$roomId/comments/$commentId';
  static String leaveRoom(String roomId) => '/rooms/$roomId/leave';
  
  // Search endpoints
  static const String search = '/search';
  
  // Smart search endpoints
  static const String smartSearch = '/rooms/search/smart';
  static String smartSearchInRoom(String roomId) => '/rooms/$roomId/search/smart';
  
}

