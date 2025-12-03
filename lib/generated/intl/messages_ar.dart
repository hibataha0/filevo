// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ar';

  static String m0(version) => "إصدار التطبيق ${version}";

  static String m1(roomName) =>
      "هل أنت متأكد من حذف \"${roomName}\"؟ سيتم حذف جميع البيانات المرتبطة بالغرفة.";

  static String m2(email) => "أدخل الرمز المكون من 6 أرقام المرسل إلى ${email}";

  static String m3(hours) => "ينتهي خلال ${hours} ساعة";

  static String m4(statusCode) => "الملف غير متاح (خطأ ${statusCode})";

  static String m5(count) => "${count}";

  static String m6(roomName) =>
      "هل أنت متأكد من مغادرة \"${roomName}\"؟ لن تتمكن من الوصول إلى هذه الغرفة بعد المغادرة.";

  static String m7(roomName) => "${roomName}";

  static String m8(count) => "الملفات المشتركة (${count})";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("حول"),
        "accessed": MessageLookupByLibrary.simpleMessage("تم الوصول"),
        "accountCreatedSuccessfully":
            MessageLookupByLibrary.simpleMessage("تم إنشاء الحساب بنجاح!"),
        "active": MessageLookupByLibrary.simpleMessage("نشط"),
        "addFile": MessageLookupByLibrary.simpleMessage("إضافة ملف"),
        "addFileToRoom":
            MessageLookupByLibrary.simpleMessage("إضافة ملف للغرفة"),
        "addFolder": MessageLookupByLibrary.simpleMessage("إضافة مجلد"),
        "addFolderToRoom":
            MessageLookupByLibrary.simpleMessage("إضافة مجلد للغرفة"),
        "all": MessageLookupByLibrary.simpleMessage("الكل"),
        "allItems": MessageLookupByLibrary.simpleMessage("جميع العناصر"),
        "alreadyHaveAccount":
            MessageLookupByLibrary.simpleMessage("هل لديك حساب بالفعل؟ "),
        "appTitle": MessageLookupByLibrary.simpleMessage("فليڤو"),
        "appVersion": m0,
        "applications": MessageLookupByLibrary.simpleMessage("تطبيقات"),
        "arabic": MessageLookupByLibrary.simpleMessage("العربية"),
        "audio": MessageLookupByLibrary.simpleMessage("صوتيات"),
        "backToLogin":
            MessageLookupByLibrary.simpleMessage("العودة لتسجيل الدخول"),
        "basicAppSettings":
            MessageLookupByLibrary.simpleMessage("الإعدادات الأساسية للتطبيق"),
        "cancel": MessageLookupByLibrary.simpleMessage("إلغاء"),
        "cannotAccessFile":
            MessageLookupByLibrary.simpleMessage("لا يمكن الوصول إلى الملف"),
        "changePassword":
            MessageLookupByLibrary.simpleMessage("تغيير كلمة المرور"),
        "chooseLanguage": MessageLookupByLibrary.simpleMessage("اختر اللغة"),
        "chooseRoomToShare":
            MessageLookupByLibrary.simpleMessage("اختر غرفة لمشاركة هذا الملف"),
        "code": MessageLookupByLibrary.simpleMessage("رمز/كود"),
        "codeResent":
            MessageLookupByLibrary.simpleMessage("تم إعادة إرسال الرمز بنجاح"),
        "codeSent":
            MessageLookupByLibrary.simpleMessage("تم إرسال الرمز بنجاح"),
        "codeVerified":
            MessageLookupByLibrary.simpleMessage("تم التحقق من الرمز بنجاح"),
        "comments": MessageLookupByLibrary.simpleMessage("التعليقات"),
        "completed": MessageLookupByLibrary.simpleMessage("اكتمل"),
        "compressed": MessageLookupByLibrary.simpleMessage("مضغوط"),
        "confirm": MessageLookupByLibrary.simpleMessage("تأكيد"),
        "confirmNewPassword":
            MessageLookupByLibrary.simpleMessage("تأكيد كلمة المرور الجديدة"),
        "confirmPassword":
            MessageLookupByLibrary.simpleMessage("تأكيد كلمة المرور"),
        "create": MessageLookupByLibrary.simpleMessage("إنشاء"),
        "createAccount": MessageLookupByLibrary.simpleMessage("إنشاء حساب"),
        "createFolder": MessageLookupByLibrary.simpleMessage("إنشاء مجلد"),
        "createRoomFirst": MessageLookupByLibrary.simpleMessage(
            "قم بإنشاء غرفة أولاً للمشاركة"),
        "createdAt": MessageLookupByLibrary.simpleMessage("أنشئت في"),
        "currentPassword":
            MessageLookupByLibrary.simpleMessage("كلمة المرور الحالية"),
        "currentPasswordRequired":
            MessageLookupByLibrary.simpleMessage("كلمة المرور الحالية مطلوبة"),
        "custom": MessageLookupByLibrary.simpleMessage("مخصص"),
        "darkMode": MessageLookupByLibrary.simpleMessage("الوضع الداكن"),
        "deleteRoom": MessageLookupByLibrary.simpleMessage("حذف الغرفة"),
        "deleteRoomConfirm": m1,
        "deletedFiles":
            MessageLookupByLibrary.simpleMessage("الملفات المحذوفة"),
        "deletedFolders":
            MessageLookupByLibrary.simpleMessage("المجلدات المحذوفة"),
        "documents": MessageLookupByLibrary.simpleMessage("مستندات"),
        "dontHaveAccount":
            MessageLookupByLibrary.simpleMessage("ليس لديك حساب؟ "),
        "editEmail":
            MessageLookupByLibrary.simpleMessage("تعديل البريد الإلكتروني"),
        "editUsername":
            MessageLookupByLibrary.simpleMessage("تعديل اسم المستخدم"),
        "email": MessageLookupByLibrary.simpleMessage("البريد الإلكتروني"),
        "english": MessageLookupByLibrary.simpleMessage("الإنجليزية"),
        "enter6DigitCode": MessageLookupByLibrary.simpleMessage(
            "الرجاء إدخال رمز مكون من 6 أرقام"),
        "enterCodeToEmail": m2,
        "enterConfirmPassword":
            MessageLookupByLibrary.simpleMessage("يرجى تأكيد كلمة المرور"),
        "enterEmail":
            MessageLookupByLibrary.simpleMessage("يرجى إدخال بريدك الإلكتروني"),
        "enterFolderName":
            MessageLookupByLibrary.simpleMessage("الرجاء إدخال اسم المجلد"),
        "enterHours": MessageLookupByLibrary.simpleMessage("أدخل عدد الساعات"),
        "enterPassword":
            MessageLookupByLibrary.simpleMessage("الرجاء إدخال كلمة المرور"),
        "enterPhone":
            MessageLookupByLibrary.simpleMessage("الرجاء إدخال رقم الهاتف"),
        "enterUsername":
            MessageLookupByLibrary.simpleMessage("الرجاء إدخال اسم المستخدم"),
        "enterUsernameOrEmail": MessageLookupByLibrary.simpleMessage(
            "الرجاء إدخال اسم المستخدم أو البريد الإلكتروني"),
        "errorAccessingFile":
            MessageLookupByLibrary.simpleMessage("خطأ في الوصول إلى الملف"),
        "errorFetchingData":
            MessageLookupByLibrary.simpleMessage("خطأ في جلب البيانات"),
        "errorLoadingFile":
            MessageLookupByLibrary.simpleMessage("خطأ في تحميل الملف"),
        "errorLoadingRoomDetails":
            MessageLookupByLibrary.simpleMessage("خطأ في تحميل تفاصيل الغرفة"),
        "errorOpeningFile":
            MessageLookupByLibrary.simpleMessage("خطأ في فتح الملف"),
        "expiresInHours": m3,
        "failedResendCode":
            MessageLookupByLibrary.simpleMessage("فشل في إعادة إرسال الرمز"),
        "failedSendCode":
            MessageLookupByLibrary.simpleMessage("فشل في إرسال الرمز"),
        "failedToLoadRoomDetails":
            MessageLookupByLibrary.simpleMessage("فشل تحميل تفاصيل الغرفة"),
        "fieldRequired":
            MessageLookupByLibrary.simpleMessage("هذا الحقل مطلوب"),
        "file": MessageLookupByLibrary.simpleMessage("ملف"),
        "fileAlreadyAccessed": MessageLookupByLibrary.simpleMessage(
            "لقد فتحت هذا الملف من قبل. الملف مشترك لمرة واحدة فقط."),
        "fileAlreadyShared": MessageLookupByLibrary.simpleMessage(
            "هذا الملف مشترك بالفعل مع هذه الغرفة"),
        "fileIdNotAvailable":
            MessageLookupByLibrary.simpleMessage("معرف الملف غير متوفر"),
        "fileNotAvailable": m4,
        "fileUrlNotAvailable":
            MessageLookupByLibrary.simpleMessage("رابط الملف غير متوفر"),
        "files": MessageLookupByLibrary.simpleMessage("ملفات"),
        "filesCount": m5,
        "filter": MessageLookupByLibrary.simpleMessage("تصفية"),
        "folderIdNotAvailable":
            MessageLookupByLibrary.simpleMessage("خطأ: معرف المجلد غير موجود"),
        "folderNameHint": MessageLookupByLibrary.simpleMessage("اسم المجلد"),
        "folders": MessageLookupByLibrary.simpleMessage("مجلدات"),
        "forgotPassword":
            MessageLookupByLibrary.simpleMessage("هل نسيت كلمة المرور؟"),
        "forgotPasswordSubtitle": MessageLookupByLibrary.simpleMessage(
            "أدخل بريدك الإلكتروني وسنرسل لك رمزًا لإعادة تعيين كلمة المرور."),
        "forgotPasswordTitle":
            MessageLookupByLibrary.simpleMessage("هل نسيت كلمة المرور؟"),
        "freeInternal":
            MessageLookupByLibrary.simpleMessage("المساحة الداخلية المتاحة"),
        "freeInternalValue":
            MessageLookupByLibrary.simpleMessage("120.5 جيجابايت"),
        "general": MessageLookupByLibrary.simpleMessage("عام"),
        "generalSettings": MessageLookupByLibrary.simpleMessage("إعدادات عامة"),
        "getHelpSupport":
            MessageLookupByLibrary.simpleMessage("الحصول على المساعدة والدعم"),
        "helpSupport": MessageLookupByLibrary.simpleMessage("المساعدة والدعم"),
        "images": MessageLookupByLibrary.simpleMessage("صور"),
        "invalidCredentials":
            MessageLookupByLibrary.simpleMessage("بيانات الاعتماد غير صحيحة"),
        "invalidEmail": MessageLookupByLibrary.simpleMessage(
            "الرجاء إدخال بريد إلكتروني صالح"),
        "invalidOrExpiredCode": MessageLookupByLibrary.simpleMessage(
            "الرمز غير صالح أو منتهي الصلاحية"),
        "invalidPdfFile": MessageLookupByLibrary.simpleMessage(
            "هذا الملف ليس PDF صالح أو قد يكون تالفاً."),
        "invalidPhone": MessageLookupByLibrary.simpleMessage(
            "الرجاء إدخال رقم هاتف صالح (10-15 رقمًا)"),
        "invalidUrl": MessageLookupByLibrary.simpleMessage("رابط غير صالح"),
        "language": MessageLookupByLibrary.simpleMessage("اللغة"),
        "last30Days": MessageLookupByLibrary.simpleMessage("آخر 30 يومًا"),
        "last7Days": MessageLookupByLibrary.simpleMessage("آخر 7 أيام"),
        "lastModified": MessageLookupByLibrary.simpleMessage("آخر تعديل"),
        "lastYear": MessageLookupByLibrary.simpleMessage("العام الماضي"),
        "leave": MessageLookupByLibrary.simpleMessage("مغادرة"),
        "leaveRoom": MessageLookupByLibrary.simpleMessage("مغادرة الغرفة"),
        "leaveRoomConfirm": m6,
        "legalPolicies":
            MessageLookupByLibrary.simpleMessage("القوانين والسياسات"),
        "logIn": MessageLookupByLibrary.simpleMessage("تسجيل الدخول"),
        "loginRequiredToAccessFiles": MessageLookupByLibrary.simpleMessage(
            "يجب تسجيل الدخول للوصول إلى الملفات"),
        "loginSubtitle":
            MessageLookupByLibrary.simpleMessage("سجّل الدخول إلى حسابك"),
        "loginSuccessful":
            MessageLookupByLibrary.simpleMessage("تم تسجيل الدخول بنجاح!"),
        "logout": MessageLookupByLibrary.simpleMessage("تسجيل الخروج"),
        "logoutSuccess":
            MessageLookupByLibrary.simpleMessage("تم تسجيل الخروج بنجاح"),
        "manageNotifications":
            MessageLookupByLibrary.simpleMessage("إدارة الإشعارات"),
        "manageStorageSettings":
            MessageLookupByLibrary.simpleMessage("إدارة إعدادات التخزين"),
        "members": MessageLookupByLibrary.simpleMessage("أعضاء"),
        "mobile": MessageLookupByLibrary.simpleMessage("رقم الهاتف"),
        "modified": MessageLookupByLibrary.simpleMessage("عدل"),
        "mustLogin":
            MessageLookupByLibrary.simpleMessage("يجب تسجيل الدخول أولاً"),
        "myFiles": MessageLookupByLibrary.simpleMessage("ملفاتي"),
        "myFolders": MessageLookupByLibrary.simpleMessage("مجلداتي"),
        "newPassword":
            MessageLookupByLibrary.simpleMessage("كلمة المرور الجديدة"),
        "newPasswordRequired":
            MessageLookupByLibrary.simpleMessage("كلمة المرور الجديدة مطلوبة"),
        "noFilesInCategory": MessageLookupByLibrary.simpleMessage(
            "لا توجد ملفات في هذا التصنيف."),
        "noMembers": MessageLookupByLibrary.simpleMessage("لا يوجد أعضاء"),
        "noRoomsAvailable":
            MessageLookupByLibrary.simpleMessage("لا توجد غرف متاحة"),
        "noSharedFiles":
            MessageLookupByLibrary.simpleMessage("لا توجد ملفات مشتركة"),
        "notifications": MessageLookupByLibrary.simpleMessage("الإشعارات"),
        "numberOfFiles": MessageLookupByLibrary.simpleMessage("عدد الملفات:"),
        "ok": MessageLookupByLibrary.simpleMessage("موافق"),
        "oneTimeShare":
            MessageLookupByLibrary.simpleMessage("مشاركة لمرة واحدة"),
        "oneTimeShareAccessRecorded": MessageLookupByLibrary.simpleMessage(
            "هذا الملف مشترك لمرة واحدة - تم تسجيل وصولك"),
        "oneTimeShareDescription": MessageLookupByLibrary.simpleMessage(
            "يمكن لكل مستخدم فتح الملف مرة واحدة فقط"),
        "onlyOwnerCanDelete":
            MessageLookupByLibrary.simpleMessage("فقط مالك الغرفة يمكنه حذفها"),
        "openAsText": MessageLookupByLibrary.simpleMessage("فتح كنص"),
        "openFileDetailsToShare": MessageLookupByLibrary.simpleMessage(
            "يرجى فتح صفحة تفاصيل الملف ومشاركته مع الغرفة من هناك"),
        "openFolderDetailsToShare": MessageLookupByLibrary.simpleMessage(
            "يرجى فتح صفحة تفاصيل المجلد ومشاركته مع الغرفة من هناك"),
        "other": MessageLookupByLibrary.simpleMessage("أخرى"),
        "owner": MessageLookupByLibrary.simpleMessage("المالك"),
        "ownerCannotLeave": MessageLookupByLibrary.simpleMessage(
            "مالك الغرفة لا يمكنه مغادرتها. يرجى حذف الغرفة بدلاً من ذلك"),
        "password": MessageLookupByLibrary.simpleMessage("كلمة المرور"),
        "passwordConfirmationRequired":
            MessageLookupByLibrary.simpleMessage("تأكيد كلمة المرور مطلوب"),
        "passwordMin": MessageLookupByLibrary.simpleMessage(
            "يجب أن تكون كلمة المرور 6 أحرف على الأقل"),
        "passwordMinLength": MessageLookupByLibrary.simpleMessage(
            "يجب أن تكون كلمة المرور 6 أحرف على الأقل"),
        "passwordUpdateFailed":
            MessageLookupByLibrary.simpleMessage("فشل تحديث كلمة المرور"),
        "passwordUpdatedSuccessfully":
            MessageLookupByLibrary.simpleMessage("تم تحديث كلمة المرور بنجاح"),
        "passwordsDoNotMatch":
            MessageLookupByLibrary.simpleMessage("كلمتا المرور غير متطابقتين"),
        "preferences": MessageLookupByLibrary.simpleMessage("تفضيلات"),
        "privacySecurity":
            MessageLookupByLibrary.simpleMessage("الخصوصية والأمان"),
        "privacySettings":
            MessageLookupByLibrary.simpleMessage("إعدادات الخصوصية"),
        "profile": MessageLookupByLibrary.simpleMessage("الملف الشخصي"),
        "recentFiles": MessageLookupByLibrary.simpleMessage("الملفات الحديثة"),
        "recentFolders":
            MessageLookupByLibrary.simpleMessage("المجلدات الحديثة"),
        "resendCode": MessageLookupByLibrary.simpleMessage("إعادة إرسال الرمز"),
        "resetPassword":
            MessageLookupByLibrary.simpleMessage("إعادة تعيين كلمة المرور"),
        "retry": MessageLookupByLibrary.simpleMessage("إعادة المحاولة"),
        "roomDetails": MessageLookupByLibrary.simpleMessage("تفاصيل الغرفة"),
        "roomInfo": MessageLookupByLibrary.simpleMessage("معلومات الغرفة"),
        "roomName": m7,
        "roomNamePlaceholder": MessageLookupByLibrary.simpleMessage("بدون اسم"),
        "searchHint":
            MessageLookupByLibrary.simpleMessage("ابحث هنا عن أي شيء"),
        "seeAll": MessageLookupByLibrary.simpleMessage("عرض الكل"),
        "sendCode": MessageLookupByLibrary.simpleMessage("إرسال الرمز"),
        "sendInvitation": MessageLookupByLibrary.simpleMessage("إرسال دعوة"),
        "settings": MessageLookupByLibrary.simpleMessage("الإعدادات"),
        "share": MessageLookupByLibrary.simpleMessage("مشاركة"),
        "shareFileWithRoom":
            MessageLookupByLibrary.simpleMessage("مشاركة الملف مع غرفة"),
        "shareFilesWithRoom": MessageLookupByLibrary.simpleMessage(
            "قم بمشاركة ملفات مع هذه الغرفة"),
        "shared": MessageLookupByLibrary.simpleMessage("مشتركة"),
        "sharedBy": MessageLookupByLibrary.simpleMessage("شاركه"),
        "sharedFiles": MessageLookupByLibrary.simpleMessage("الملفات المشتركة"),
        "sharedFilesContent": MessageLookupByLibrary.simpleMessage(
            "سيتم عرض الملفات المشتركة هنا"),
        "sharedFilesCount": m8,
        "signIn": MessageLookupByLibrary.simpleMessage("تسجيل الدخول"),
        "signInWith":
            MessageLookupByLibrary.simpleMessage("تسجيل الدخول باستخدام"),
        "signOut":
            MessageLookupByLibrary.simpleMessage("تسجيل الخروج من حسابك"),
        "signUp": MessageLookupByLibrary.simpleMessage("إنشاء حساب"),
        "signUpWith":
            MessageLookupByLibrary.simpleMessage("إنشاء حساب باستخدام"),
        "storage": MessageLookupByLibrary.simpleMessage("التخزين"),
        "storageOverview":
            MessageLookupByLibrary.simpleMessage("نظرة عامة على التخزين"),
        "storageUsed": MessageLookupByLibrary.simpleMessage("المستخدم"),
        "storageUsedValue": MessageLookupByLibrary.simpleMessage("60%"),
        "support": MessageLookupByLibrary.simpleMessage("الدعم"),
        "switchThemes":
            MessageLookupByLibrary.simpleMessage("تبديل بين السمات"),
        "termsPrivacyPolicy":
            MessageLookupByLibrary.simpleMessage("شروط الخدمة وسياسة الخصوصية"),
        "timeAndDate": MessageLookupByLibrary.simpleMessage("الوقت والتاريخ"),
        "tokenNotFound":
            MessageLookupByLibrary.simpleMessage("لم يتم العثور على التوكن"),
        "trash": MessageLookupByLibrary.simpleMessage("المحذوفات"),
        "type": MessageLookupByLibrary.simpleMessage("النوع"),
        "unknownFile": MessageLookupByLibrary.simpleMessage("ملف غير معروف"),
        "unsupportedFile":
            MessageLookupByLibrary.simpleMessage("ملف غير مدعوم"),
        "updateFailed": MessageLookupByLibrary.simpleMessage("فشل التحديث"),
        "updated": MessageLookupByLibrary.simpleMessage(" تحديث"),
        "updatedSuccessfully":
            MessageLookupByLibrary.simpleMessage("تم التحديث بنجاح"),
        "upload_success":
            MessageLookupByLibrary.simpleMessage("تم رفع الملف بنجاح"),
        "used": MessageLookupByLibrary.simpleMessage("المستخدمة"),
        "usedStorage":
            MessageLookupByLibrary.simpleMessage("التخزين المستخدم:"),
        "usedStorageValue":
            MessageLookupByLibrary.simpleMessage("149.5 جيجابايت"),
        "user": MessageLookupByLibrary.simpleMessage("مستخدم"),
        "username": MessageLookupByLibrary.simpleMessage("اسم المستخدم"),
        "usernameAllowedChars": MessageLookupByLibrary.simpleMessage(
            "يمكن أن يحتوي اسم المستخدم على أحرف وأرقام وشرطة سفلية فقط"),
        "usernameMax": MessageLookupByLibrary.simpleMessage(
            "يجب ألا يتجاوز اسم المستخدم 20 حرفًا"),
        "usernameMin": MessageLookupByLibrary.simpleMessage(
            "يجب أن يكون اسم المستخدم 3 أحرف على الأقل"),
        "usernameOrEmail": MessageLookupByLibrary.simpleMessage(
            "اسم المستخدم أو البريد الإلكتروني"),
        "validEmail": MessageLookupByLibrary.simpleMessage(
            "يرجى إدخال بريد إلكتروني صالح"),
        "validEmailRequired": MessageLookupByLibrary.simpleMessage(
            "يرجى إدخال بريد إلكتروني صالح"),
        "verify": MessageLookupByLibrary.simpleMessage("تحقق"),
        "verifyCodeTitle":
            MessageLookupByLibrary.simpleMessage("التحقق من الرمز"),
        "videos": MessageLookupByLibrary.simpleMessage("فيديوهات"),
        "viewAll": MessageLookupByLibrary.simpleMessage("عرض الكل"),
        "viewedByAll": MessageLookupByLibrary.simpleMessage("شوهد من الجميع"),
        "yesterday": MessageLookupByLibrary.simpleMessage("أمس")
      };
}
