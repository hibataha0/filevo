import 'package:flutter/material.dart';
import 'package:filevo/services/folder_protection_service.dart';
import 'package:filevo/views/folders/folder_protection_dialogs.dart';

/// ✅ Helper للتحقق من كلمة السر قبل أي عملية على المجلد المحمي
class FolderProtectionHelper {
  /// ✅ التحقق من كلمة السر قبل تنفيذ عملية
  /// يعيد true إذا كان المجلد غير محمي أو تم التحقق بنجاح
  /// يعيد false إذا فشل التحقق أو ألغى المستخدم
  static Future<bool> verifyAccessBeforeAction({
    required BuildContext context,
    required Map<String, dynamic> folder,
    required String actionName, // اسم العملية (مثل: "عرض التفاصيل", "تعديل", "نقل", "حذف")
  }) async {
    // ✅ التحقق من أن المجلد محمي
    final folderData = folder['folderData'] ?? folder;
    final isProtected = FolderProtectionService.isFolderProtected(folderData);
    
    if (!isProtected) {
      // ✅ المجلد غير محمي، السماح بالعملية
      return true;
    }

    // ✅ المجلد محمي، طلب كلمة السر
    final folderId = folder['folderId'] as String? ??
        folder['_id']?.toString() ??
        folder['id']?.toString();
    final folderName = folder['title']?.toString() ??
        folder['name']?.toString() ??
        'المجلد';
    final protectionType = FolderProtectionService.getProtectionType(folderData);

    if (folderId == null) {
      final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
      if (scaffoldMessenger != null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('❌ معرف المجلد غير متوفر'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    // ✅ عرض Dialog للتحقق من كلمة السر
    final hasAccess = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => VerifyFolderAccessDialog(
        folderId: folderId,
        folderName: folderName,
        protectionType: protectionType,
      ),
    );

    return hasAccess == true;
  }
}


