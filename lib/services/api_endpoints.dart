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
  static const String uploadFolder = '/folders/upload';
  
  // Files endpoints
  static const String files = '/files';
  static String fileById(String id) => '/files/$id';
  static const String uploadFile = '/files/upload';
  static const String uploadSingleFile = '/files/upload-single';
  static const String uploadMultipleFiles = '/files/upload-multiple';
  static String filesByCategory(String category) => '/files/category/$category';
   static String getFileDetails(String fileId) => "/files/$fileId";
  static String updateFile(String fileId) => "/files/$fileId";
  static String deleteFile(String fileId) => "/files/$fileId";
  static String downloadFile(String fileId) => "/files/$fileId/download";
 static const String starredFiles = '/files/starred'; 
  static String toggleStarFile(String fileId) => "/files/$fileId/star";
  static const String trashFiles = '/files/trash';
  static String restoreTrashFile(String fileId) => "/files/$fileId/restore";
  static String deleteFilePermanent(String fileId) => "/files/$fileId/permanent";
  static const String emptyTrash = '/files/trash/empty';



  // User endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String changePassword = '/user/change-password';
  
  // Shared files endpoints
  static const String sharedFiles = '/files/shared';
  static String shareFile(String id) => '/files/$id/share';
  
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
  static String shareFolderWithRoom(String roomId) => '/rooms/$roomId/share-folder';
  static String roomComments(String roomId) => '/rooms/$roomId/comments';
  static String deleteComment(String roomId, String commentId) => '/rooms/$roomId/comments/$commentId';
  
  // Search endpoints
  static const String search = '/search';
  
}

