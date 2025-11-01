/// ملف يحتوي على جميع endpoints للـ API
/// يمكنك إضافة المزيد حسب احتياجك

class ApiEndpoints {
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/registerUser';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  
  // Folders endpoints
  static const String folders = '/folders';
  static String folderById(String id) => '/folders/$id';
  static String folderFiles(String id) => '/folders/$id/files';
  
  // Files endpoints
  static const String files = '/files';
  static String fileById(String id) => '/files/$id';
  static const String uploadFile = '/files/upload';
  
  // User endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String changePassword = '/user/change-password';
  
  // Shared files endpoints
  static const String sharedFiles = '/files/shared';
  static String shareFile(String id) => '/files/$id/share';
  
  // Search endpoints
  static const String search = '/search';
  
  // يمكنك إضافة المزيد حسب احتياجك
}

