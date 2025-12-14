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

  static String m1(folderName) =>
      "هل أنت متأكد من إزالة \"${folderName}\" من هذه الغرفة؟";

  static String m2(memberName) =>
      "هل أنت متأكد من إزالة ${memberName} من الغرفة؟";

  static String m3(roomName) =>
      "هل أنت متأكد من حذف \"${roomName}\"؟ سيتم حذف جميع البيانات المرتبطة بالغرفة.";

  static String m4(email) => "أدخل الرمز المكون من 6 أرقام المرسل إلى ${email}";

  static String m5(error) => "خطأ: ${error}";

  static String m6(error) => "خطأ في جلب المجلدات الفرعية: ${error}";

  static String m7(error) => "خطأ في تحميل الملف: ${error}";

  static String m8(error) => "خطأ في تحميل الملف النصي: ${error}";

  static String m9(error) => "خطأ في فتح الملف: ${error}";

  static String m10(error) => "خطأ في التحقق من الصورة: ${error}";

  static String m11(error) => "خطأ في التحقق من الفيديو: ${error}";

  static String m12(hours) => "ينتهي خلال ${hours} ساعة";

  static String m13(statusCode) => "فشل تحميل الملف الصوتي (${statusCode})";

  static String m14(statusCode) => "فشل تحميل الملف: ${statusCode}";

  static String m15(error) => "فشل تحميل ملف PDF: ${error}";

  static String m16(error) => "فشل تحميل PDF للعرض: ${error}";

  static String m17(statusCode) => "فشل تحميل الفيديو (${statusCode})";

  static String m18(error) => "فشل فتح الملف: ${error}";

  static String m19(statusCode) => "الملف غير متاح (خطأ ${statusCode})";

  static String m20(statusCode) => "الملف غير متاح (خطأ ${statusCode})";

  static String m21(folderName) => "تم إنشاء المجلد \"${folderName}\" بنجاح";

  static String m22(roomName) =>
      "هل أنت متأكد من مغادرة \"${roomName}\"؟ لن تتمكن من الوصول إلى هذه الغرفة بعد المغادرة.";

  static String m23(fileName) => "فتح الملف كنص: ${fileName}";

  static String m24(countdown) =>
      "يرجى الانتظار ${countdown} ثانية قبل إعادة الإرسال";

  static String m25(countdown) => "إعادة الإرسال (${countdown})";

  static String m26(roomName) => "${roomName}";

  static String m27(error) => "خطأ في البحث: ${error}";

  static String m28(folderName) => "اختيار \"${folderName}\"";

  static String m29(count) => "الملفات المشتركة (${count})";

  static String m30(email) =>
      "تم إرسال كود التحقق المكون من 6 أرقام إلى:\n${email}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("حول"),
    "accept": MessageLookupByLibrary.simpleMessage("قبول"),
    "accessTokenNotFound": MessageLookupByLibrary.simpleMessage(
      "لم يتم العثور على رمز الوصول",
    ),
    "accessed": MessageLookupByLibrary.simpleMessage("تم الوصول"),
    "accountActivatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "تم تفعيل الحساب بنجاح. يمكنك الآن تسجيل الدخول",
    ),
    "accountCreatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "تم إنشاء الحساب بنجاح!",
    ),
    "active": MessageLookupByLibrary.simpleMessage("نشط"),
    "activityLog": MessageLookupByLibrary.simpleMessage("سجل النشاط"),
    "addFile": MessageLookupByLibrary.simpleMessage("إضافة ملف"),
    "addFileToRoom": MessageLookupByLibrary.simpleMessage("إضافة ملف للغرفة"),
    "addFilesToFavorites": MessageLookupByLibrary.simpleMessage(
      "يمكنك إضافة الملفات إلى المفضلة من خلال القائمة",
    ),
    "addFolder": MessageLookupByLibrary.simpleMessage("إضافة مجلد"),
    "addFolderToRoom": MessageLookupByLibrary.simpleMessage(
      "إضافة مجلد للغرفة",
    ),
    "all": MessageLookupByLibrary.simpleMessage("الكل"),
    "allActivities": MessageLookupByLibrary.simpleMessage("الكل"),
    "allItems": MessageLookupByLibrary.simpleMessage("جميع العناصر"),
    "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage(
      "هل لديك حساب بالفعل؟ ",
    ),
    "appTitle": MessageLookupByLibrary.simpleMessage("فليڤو"),
    "appVersion": m0,
    "applications": MessageLookupByLibrary.simpleMessage("تطبيقات"),
    "apply": MessageLookupByLibrary.simpleMessage("تطبيق"),
    "arabic": MessageLookupByLibrary.simpleMessage("العربية"),
    "audio": MessageLookupByLibrary.simpleMessage("صوت"),
    "backToLogin": MessageLookupByLibrary.simpleMessage("العودة لتسجيل الدخول"),
    "basicAppSettings": MessageLookupByLibrary.simpleMessage(
      "الإعدادات الأساسية للتطبيق",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("إلغاء"),
    "cannotAccessFile": MessageLookupByLibrary.simpleMessage(
      "لا يمكن الوصول إلى الملف",
    ),
    "cannotAddSharedFilesToFavorites": MessageLookupByLibrary.simpleMessage(
      "لا يمكن إضافة الملفات المشتركة في الروم إلى المفضلة",
    ),
    "category": MessageLookupByLibrary.simpleMessage("التصنيف"),
    "changePassword": MessageLookupByLibrary.simpleMessage("تغيير كلمة المرور"),
    "chooseFileOrFolder": MessageLookupByLibrary.simpleMessage(
      "اختر ملف أو مجلد",
    ),
    "chooseLanguage": MessageLookupByLibrary.simpleMessage("اختر اللغة"),
    "chooseRoomToShare": MessageLookupByLibrary.simpleMessage(
      "اختر غرفة لمشاركة هذا الملف",
    ),
    "chooseTimeInSeconds": MessageLookupByLibrary.simpleMessage(
      "اختر الوقت بالثواني:",
    ),
    "chooseTimeToExtractImage": MessageLookupByLibrary.simpleMessage(
      "اختر الوقت لاستخراج الصورة",
    ),
    "code": MessageLookupByLibrary.simpleMessage("رمز/كود"),
    "codeResent": MessageLookupByLibrary.simpleMessage(
      "تم إعادة إرسال الرمز بنجاح",
    ),
    "codeSent": MessageLookupByLibrary.simpleMessage("تم إرسال الرمز بنجاح"),
    "codeVerified": MessageLookupByLibrary.simpleMessage(
      "تم التحقق من الرمز بنجاح",
    ),
    "commenter": MessageLookupByLibrary.simpleMessage("معلق"),
    "commenterDescription": MessageLookupByLibrary.simpleMessage(
      "يمكنه التعليق على الملفات",
    ),
    "comments": MessageLookupByLibrary.simpleMessage("التعليقات"),
    "completed": MessageLookupByLibrary.simpleMessage("اكتمل"),
    "compressed": MessageLookupByLibrary.simpleMessage("مضغوط"),
    "confirm": MessageLookupByLibrary.simpleMessage("تأكيد"),
    "confirmDeleteComment": MessageLookupByLibrary.simpleMessage(
      "هل أنت متأكد من حذف هذا التعليق؟",
    ),
    "confirmNewPassword": MessageLookupByLibrary.simpleMessage(
      "تأكيد كلمة المرور الجديدة",
    ),
    "confirmPassword": MessageLookupByLibrary.simpleMessage(
      "تأكيد كلمة المرور",
    ),
    "confirmRejectInvitation": MessageLookupByLibrary.simpleMessage(
      "هل أنت متأكد من رفض هذه الدعوة؟",
    ),
    "confirmRemoveFileFromRoom": MessageLookupByLibrary.simpleMessage(
      "هل أنت متأكد من إزالة هذا الملف من الروم؟",
    ),
    "confirmRemoveFolderFromRoom": MessageLookupByLibrary.simpleMessage(
      "هل أنت متأكد من إزالة هذا المجلد من الروم؟",
    ),
    "confirmRemoveFolderFromRoomWithName": m1,
    "confirmRemoveMember": m2,
    "copyContent": MessageLookupByLibrary.simpleMessage("نسخ المحتوى"),
    "create": MessageLookupByLibrary.simpleMessage("إنشاء"),
    "createAccount": MessageLookupByLibrary.simpleMessage("إنشاء حساب"),
    "createFolder": MessageLookupByLibrary.simpleMessage("إنشاء مجلد"),
    "createNewFolder": MessageLookupByLibrary.simpleMessage("إنشاء مجلد جديد"),
    "createNewShareRoom": MessageLookupByLibrary.simpleMessage(
      "إنشاء غرفة مشاركة جديدة",
    ),
    "createRoomFirst": MessageLookupByLibrary.simpleMessage(
      "قم بإنشاء غرفة أولاً للمشاركة",
    ),
    "createdAt": MessageLookupByLibrary.simpleMessage("أنشئت في"),
    "creationDate": MessageLookupByLibrary.simpleMessage("تاريخ الإنشاء"),
    "currentPassword": MessageLookupByLibrary.simpleMessage(
      "كلمة المرور الحالية",
    ),
    "currentPasswordRequired": MessageLookupByLibrary.simpleMessage(
      "كلمة المرور الحالية مطلوبة",
    ),
    "currentVersionSupports": MessageLookupByLibrary.simpleMessage(
      "الإصدار الحالي يدعم:",
    ),
    "custom": MessageLookupByLibrary.simpleMessage("مخصص"),
    "darkMode": MessageLookupByLibrary.simpleMessage("الوضع الداكن"),
    "delete": MessageLookupByLibrary.simpleMessage("حذف"),
    "deleteComment": MessageLookupByLibrary.simpleMessage("حذف التعليق"),
    "deleteFile": MessageLookupByLibrary.simpleMessage("حذف ملف"),
    "deleteRoom": MessageLookupByLibrary.simpleMessage("حذف الغرفة"),
    "deleteRoomConfirm": m3,
    "deletedFiles": MessageLookupByLibrary.simpleMessage("الملفات المحذوفة"),
    "deletedFolders": MessageLookupByLibrary.simpleMessage("المجلدات المحذوفة"),
    "description": MessageLookupByLibrary.simpleMessage("الوصف"),
    "didNotReceiveCode": MessageLookupByLibrary.simpleMessage(
      "لم تستلم الكود؟",
    ),
    "document": MessageLookupByLibrary.simpleMessage("مستند"),
    "documents": MessageLookupByLibrary.simpleMessage("مستندات"),
    "dontHaveAccount": MessageLookupByLibrary.simpleMessage("ليس لديك حساب؟ "),
    "download": MessageLookupByLibrary.simpleMessage("تحميل"),
    "downloadFile": MessageLookupByLibrary.simpleMessage("تحميل ملف"),
    "edit": MessageLookupByLibrary.simpleMessage("تحرير"),
    "editEmail": MessageLookupByLibrary.simpleMessage(
      "تعديل البريد الإلكتروني",
    ),
    "editFile": MessageLookupByLibrary.simpleMessage("تعديل الملف"),
    "editImage": MessageLookupByLibrary.simpleMessage("تعديل الصورة"),
    "editText": MessageLookupByLibrary.simpleMessage("تعديل النص"),
    "editUsername": MessageLookupByLibrary.simpleMessage("تعديل اسم المستخدم"),
    "editor": MessageLookupByLibrary.simpleMessage("محرر"),
    "editorDescription": MessageLookupByLibrary.simpleMessage(
      "يمكنه تعديل الملفات",
    ),
    "email": MessageLookupByLibrary.simpleMessage("البريد الإلكتروني"),
    "emailVerification": MessageLookupByLibrary.simpleMessage(
      "التحقق من البريد الإلكتروني",
    ),
    "english": MessageLookupByLibrary.simpleMessage("الإنجليزية"),
    "enter6DigitCode": MessageLookupByLibrary.simpleMessage(
      "الرجاء إدخال رمز مكون من 6 أرقام",
    ),
    "enterCodeToEmail": m4,
    "enterConfirmPassword": MessageLookupByLibrary.simpleMessage(
      "يرجى تأكيد كلمة المرور",
    ),
    "enterEmail": MessageLookupByLibrary.simpleMessage(
      "يرجى إدخال بريدك الإلكتروني",
    ),
    "enterFolderName": MessageLookupByLibrary.simpleMessage(
      "الرجاء إدخال اسم المجلد",
    ),
    "enterHours": MessageLookupByLibrary.simpleMessage("أدخل عدد الساعات"),
    "enterPassword": MessageLookupByLibrary.simpleMessage(
      "الرجاء إدخال كلمة المرور",
    ),
    "enterPhone": MessageLookupByLibrary.simpleMessage(
      "الرجاء إدخال رقم الهاتف",
    ),
    "enterSearchText": MessageLookupByLibrary.simpleMessage("أدخل نص البحث"),
    "enterUsername": MessageLookupByLibrary.simpleMessage(
      "الرجاء إدخال اسم المستخدم",
    ),
    "enterUsernameOrEmail": MessageLookupByLibrary.simpleMessage(
      "الرجاء إدخال اسم المستخدم أو البريد الإلكتروني",
    ),
    "error": m5,
    "errorAccessingFile": MessageLookupByLibrary.simpleMessage(
      "خطأ في الوصول إلى الملف",
    ),
    "errorFetchingData": MessageLookupByLibrary.simpleMessage(
      "خطأ في جلب البيانات",
    ),
    "errorFetchingSubfolders": m6,
    "errorLoadingFile": m7,
    "errorLoadingFileData": MessageLookupByLibrary.simpleMessage(
      "حدث خطأ في تحميل بيانات الملف",
    ),
    "errorLoadingRoomDetails": MessageLookupByLibrary.simpleMessage(
      "خطأ في تحميل تفاصيل الغرفة",
    ),
    "errorLoadingTextFile": m8,
    "errorOpeningFile": m9,
    "errorVerifyingImage": m10,
    "errorVerifyingVideo": m11,
    "exit": MessageLookupByLibrary.simpleMessage("خروج"),
    "expiresInHours": m12,
    "extension": MessageLookupByLibrary.simpleMessage("الامتداد"),
    "extractText": MessageLookupByLibrary.simpleMessage("استخراج النص"),
    "extractingImage": MessageLookupByLibrary.simpleMessage(
      "جاري استخراج الصورة...",
    ),
    "extractingText": MessageLookupByLibrary.simpleMessage(
      "جارٍ استخراج النص...",
    ),
    "extractingTextFromPdf": MessageLookupByLibrary.simpleMessage(
      "جارٍ استخراج النص من PDF...",
    ),
    "failedResendCode": MessageLookupByLibrary.simpleMessage(
      "فشل في إعادة إرسال الرمز",
    ),
    "failedSendCode": MessageLookupByLibrary.simpleMessage(
      "فشل في إرسال الرمز",
    ),
    "failedToCreateFolder": MessageLookupByLibrary.simpleMessage(
      "فشل إنشاء المجلد",
    ),
    "failedToCreateTempFile": MessageLookupByLibrary.simpleMessage(
      "فشل في إنشاء الملف المؤقت",
    ),
    "failedToExtractImage": MessageLookupByLibrary.simpleMessage(
      "فشل استخراج الصورة",
    ),
    "failedToFetchFolderInfo": MessageLookupByLibrary.simpleMessage(
      "فشل جلب معلومات المجلد",
    ),
    "failedToLoadAudio": m13,
    "failedToLoadAudioFile": MessageLookupByLibrary.simpleMessage(
      "فشل تحميل الملف الصوتي",
    ),
    "failedToLoadBaseAudio": MessageLookupByLibrary.simpleMessage(
      "فشل تحميل الملف الصوتي الأساسي",
    ),
    "failedToLoadFile": MessageLookupByLibrary.simpleMessage("فشل تحميل الملف"),
    "failedToLoadFileData": MessageLookupByLibrary.simpleMessage(
      "فشل في تحميل بيانات الملف",
    ),
    "failedToLoadFileStatus": m14,
    "failedToLoadImage": MessageLookupByLibrary.simpleMessage(
      "فشل تحميل الصورة",
    ),
    "failedToLoadPdf": MessageLookupByLibrary.simpleMessage(
      "فشل تحميل ملف PDF",
    ),
    "failedToLoadPdfFile": m15,
    "failedToLoadPdfForDisplay": m16,
    "failedToLoadPreview": MessageLookupByLibrary.simpleMessage(
      "تعذر تحميل المعاينة",
    ),
    "failedToLoadRoomData": MessageLookupByLibrary.simpleMessage(
      "فشل تحميل بيانات الغرفة",
    ),
    "failedToLoadRoomDetails": MessageLookupByLibrary.simpleMessage(
      "فشل تحميل تفاصيل الغرفة",
    ),
    "failedToLoadVideo": m17,
    "failedToMergeVideos": MessageLookupByLibrary.simpleMessage(
      "فشل دمج المقاطع",
    ),
    "failedToOpenFile": m18,
    "failedToResendCode": MessageLookupByLibrary.simpleMessage(
      "فشل في إعادة إرسال كود التحقق",
    ),
    "failedToSaveFile": MessageLookupByLibrary.simpleMessage("فشل حفظ الملف"),
    "failedToSaveTempAudio": MessageLookupByLibrary.simpleMessage(
      "فشل حفظ الملف الصوتي المؤقت",
    ),
    "failedToSaveTempImage": MessageLookupByLibrary.simpleMessage(
      "فشل حفظ الصورة المؤقتة",
    ),
    "failedToSaveTempVideo": MessageLookupByLibrary.simpleMessage(
      "فشل حفظ الفيديو المؤقت",
    ),
    "favoriteFiles": MessageLookupByLibrary.simpleMessage("الملفات المفضلة"),
    "featureUnderDevelopment": MessageLookupByLibrary.simpleMessage(
      "ميزة المعلومات قيد التطوير",
    ),
    "fieldRequired": MessageLookupByLibrary.simpleMessage("هذا الحقل مطلوب"),
    "file": MessageLookupByLibrary.simpleMessage("ملف"),
    "fileAlreadyAccessed": MessageLookupByLibrary.simpleMessage(
      "لقد فتحت هذا الملف من قبل. الملف مشترك لمرة واحدة فقط.",
    ),
    "fileAlreadyShared": MessageLookupByLibrary.simpleMessage(
      "هذا الملف مشترك بالفعل مع هذه الغرفة",
    ),
    "fileIdNotAvailable": MessageLookupByLibrary.simpleMessage(
      "معرف الملف غير متوفر",
    ),
    "fileInfo": MessageLookupByLibrary.simpleMessage("معلومات الملف"),
    "fileIsEmpty": MessageLookupByLibrary.simpleMessage("الملف فارغ"),
    "fileLinkNotAvailable": MessageLookupByLibrary.simpleMessage(
      "رابط الملف غير متوفر",
    ),
    "fileLinkNotAvailableNoPath": MessageLookupByLibrary.simpleMessage(
      "رابط الملف غير متوفر - لا يوجد path أو _id",
    ),
    "fileNotAvailable": m19,
    "fileNotAvailableError": m20,
    "fileNotLoaded": MessageLookupByLibrary.simpleMessage("لم يتم تحميل الملف"),
    "fileNotValidPdf": MessageLookupByLibrary.simpleMessage(
      "هذا الملف ليس PDF صالح أو قد يكون تالفاً.",
    ),
    "fileSavedAndUploaded": MessageLookupByLibrary.simpleMessage(
      "تم حفظ الملف ورفعه إلى السيرفر بنجاح",
    ),
    "fileSavedLocallyOnly": MessageLookupByLibrary.simpleMessage(
      "تم حفظ الملف محلياً فقط. يرجى المحاولة مرة أخرى لرفعه على السيرفر",
    ),
    "fileSavedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "تم حفظ الملف بنجاح",
    ),
    "fileUrlNotAvailable": MessageLookupByLibrary.simpleMessage(
      "رابط الملف غير متوفر",
    ),
    "fileWithoutName": MessageLookupByLibrary.simpleMessage("ملف بدون اسم"),
    "files": MessageLookupByLibrary.simpleMessage("ملفات"),
    "filesCount": MessageLookupByLibrary.simpleMessage("عدد الملفات"),
    "filter": MessageLookupByLibrary.simpleMessage("تصفية"),
    "filterActivity": MessageLookupByLibrary.simpleMessage("تصفية النشاط"),
    "folder": MessageLookupByLibrary.simpleMessage("مجلد"),
    "folderCreatedSuccessfully": m21,
    "folderIdNotAvailable": MessageLookupByLibrary.simpleMessage(
      "معرف المجلد غير متوفر",
    ),
    "folderInfo": MessageLookupByLibrary.simpleMessage("معلومات المجلد"),
    "folderNameHint": MessageLookupByLibrary.simpleMessage("اسم المجلد"),
    "folderWithoutName": MessageLookupByLibrary.simpleMessage("مجلد بدون اسم"),
    "folders": MessageLookupByLibrary.simpleMessage("مجلدات"),
    "forAdvancedSearchFeature": MessageLookupByLibrary.simpleMessage(
      "للاستفادة من ميزة البحث المتقدمة، نوصي باستخدام:",
    ),
    "forgotPassword": MessageLookupByLibrary.simpleMessage(
      "هل نسيت كلمة المرور؟",
    ),
    "forgotPasswordSubtitle": MessageLookupByLibrary.simpleMessage(
      "أدخل بريدك الإلكتروني وسنرسل لك رمزًا لإعادة تعيين كلمة المرور.",
    ),
    "forgotPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "هل نسيت كلمة المرور؟",
    ),
    "freeInternal": MessageLookupByLibrary.simpleMessage(
      "المساحة الداخلية المتاحة",
    ),
    "freeInternalValue": MessageLookupByLibrary.simpleMessage("120.5 جيجابايت"),
    "general": MessageLookupByLibrary.simpleMessage("عام"),
    "generalSettings": MessageLookupByLibrary.simpleMessage("إعدادات عامة"),
    "getHelpSupport": MessageLookupByLibrary.simpleMessage(
      "الحصول على المساعدة والدعم",
    ),
    "helpSupport": MessageLookupByLibrary.simpleMessage("المساعدة والدعم"),
    "highlightSelectedText": MessageLookupByLibrary.simpleMessage(
      "تظليل النص المحدد",
    ),
    "highlights": MessageLookupByLibrary.simpleMessage("تظليل"),
    "image": MessageLookupByLibrary.simpleMessage("صورة"),
    "imageEdited": MessageLookupByLibrary.simpleMessage("تم تعديل الصورة"),
    "imageExtracted": MessageLookupByLibrary.simpleMessage("تم استخراج الصورة"),
    "images": MessageLookupByLibrary.simpleMessage("صور"),
    "invalidCredentials": MessageLookupByLibrary.simpleMessage(
      "بيانات الاعتماد غير صحيحة",
    ),
    "invalidEmail": MessageLookupByLibrary.simpleMessage(
      "الرجاء إدخال بريد إلكتروني صالح",
    ),
    "invalidOrExpiredCode": MessageLookupByLibrary.simpleMessage(
      "الرمز غير صالح أو منتهي الصلاحية",
    ),
    "invalidPdfFile": MessageLookupByLibrary.simpleMessage(
      "الملف PDF غير صالح",
    ),
    "invalidPhone": MessageLookupByLibrary.simpleMessage(
      "الرجاء إدخال رقم هاتف صالح (10-15 رقمًا)",
    ),
    "invalidUrl": MessageLookupByLibrary.simpleMessage("رابط غير صالح"),
    "invalidVerificationCode": MessageLookupByLibrary.simpleMessage(
      "كود التحقق غير صحيح",
    ),
    "item": MessageLookupByLibrary.simpleMessage("عنصر"),
    "items": MessageLookupByLibrary.simpleMessage("عناصر"),
    "language": MessageLookupByLibrary.simpleMessage("اللغة"),
    "last30Days": MessageLookupByLibrary.simpleMessage("آخر 30 يومًا"),
    "last7Days": MessageLookupByLibrary.simpleMessage("آخر 7 أيام"),
    "lastModified": MessageLookupByLibrary.simpleMessage("آخر تعديل"),
    "lastYear": MessageLookupByLibrary.simpleMessage("العام الماضي"),
    "leave": MessageLookupByLibrary.simpleMessage("مغادرة"),
    "leaveRoom": MessageLookupByLibrary.simpleMessage("مغادرة الغرفة"),
    "leaveRoomConfirm": m22,
    "legalPolicies": MessageLookupByLibrary.simpleMessage("القوانين والسياسات"),
    "loadMore": MessageLookupByLibrary.simpleMessage("تحميل المزيد"),
    "loadedAudioIsEmpty": MessageLookupByLibrary.simpleMessage(
      "الملف الصوتي المحمل فارغ",
    ),
    "loadedImageIsEmpty": MessageLookupByLibrary.simpleMessage(
      "الصورة المحملة فارغة",
    ),
    "loadedVideoIsEmpty": MessageLookupByLibrary.simpleMessage(
      "الفيديو المحمل فارغ",
    ),
    "loadingFile": MessageLookupByLibrary.simpleMessage("جاري تحميل الملف..."),
    "loadingFileData": MessageLookupByLibrary.simpleMessage(
      "جاري تحميل بيانات الملف...",
    ),
    "loadingVideo": MessageLookupByLibrary.simpleMessage(
      "جاري تحميل الفيديو...",
    ),
    "logIn": MessageLookupByLibrary.simpleMessage("تسجيل الدخول"),
    "login": MessageLookupByLibrary.simpleMessage("تسجيل الدخول"),
    "loginRequiredToAccessFiles": MessageLookupByLibrary.simpleMessage(
      "يجب تسجيل الدخول للوصول إلى الملفات",
    ),
    "loginSubtitle": MessageLookupByLibrary.simpleMessage(
      "سجّل الدخول إلى حسابك",
    ),
    "loginSuccessful": MessageLookupByLibrary.simpleMessage(
      "تم تسجيل الدخول بنجاح!",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("تسجيل الخروج"),
    "logoutSuccess": MessageLookupByLibrary.simpleMessage(
      "تم تسجيل الخروج بنجاح",
    ),
    "manageNotifications": MessageLookupByLibrary.simpleMessage(
      "إدارة الإشعارات",
    ),
    "manageStorageSettings": MessageLookupByLibrary.simpleMessage(
      "إدارة إعدادات التخزين",
    ),
    "members": MessageLookupByLibrary.simpleMessage("أعضاء"),
    "mergingAudioFiles": MessageLookupByLibrary.simpleMessage(
      "جاري دمج الملفات الصوتية... قد يستغرق بعض الوقت",
    ),
    "mergingVideos": MessageLookupByLibrary.simpleMessage(
      "جاري دمج المقاطع... قد يستغرق بعض الوقت",
    ),
    "microphonePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "إذن الميكروفون مطلوب",
    ),
    "mobile": MessageLookupByLibrary.simpleMessage("رقم الهاتف"),
    "modified": MessageLookupByLibrary.simpleMessage("عدل"),
    "moveFolderToRoot": MessageLookupByLibrary.simpleMessage(
      "نقل المجلد إلى المجلد الرئيسي",
    ),
    "moveToRoot": MessageLookupByLibrary.simpleMessage("نقل إلى الجذر"),
    "moveToThisFolder": MessageLookupByLibrary.simpleMessage(
      "نقل إلى هذا المجلد",
    ),
    "movingFile": MessageLookupByLibrary.simpleMessage("جاري نقل الملف..."),
    "movingFolder": MessageLookupByLibrary.simpleMessage("جاري نقل المجلد..."),
    "mustAllowMicrophoneAccess": MessageLookupByLibrary.simpleMessage(
      "يجب السماح بالوصول إلى الميكروفون للبحث بالصوت.",
    ),
    "mustLogin": MessageLookupByLibrary.simpleMessage("يجب تسجيل الدخول أولاً"),
    "mustLoginFirst": MessageLookupByLibrary.simpleMessage(
      "يجب تسجيل الدخول أولاً",
    ),
    "mustSelectAtLeastTwoAudioFiles": MessageLookupByLibrary.simpleMessage(
      "يجب اختيار ملفين صوتيين على الأقل للدمج",
    ),
    "myFiles": MessageLookupByLibrary.simpleMessage("ملفاتي"),
    "myFolders": MessageLookupByLibrary.simpleMessage("مجلداتي"),
    "newPassword": MessageLookupByLibrary.simpleMessage("كلمة المرور الجديدة"),
    "newPasswordRequired": MessageLookupByLibrary.simpleMessage(
      "كلمة المرور الجديدة مطلوبة",
    ),
    "next": MessageLookupByLibrary.simpleMessage("التالي"),
    "noFavoriteFiles": MessageLookupByLibrary.simpleMessage(
      "لا توجد ملفات مفضلة",
    ),
    "noFilesInCategory": MessageLookupByLibrary.simpleMessage(
      "لا توجد ملفات في هذا التصنيف.",
    ),
    "noItems": MessageLookupByLibrary.simpleMessage("لا توجد عناصر"),
    "noMembers": MessageLookupByLibrary.simpleMessage("لا يوجد أعضاء"),
    "noName": MessageLookupByLibrary.simpleMessage("بدون اسم"),
    "noRecentFiles": MessageLookupByLibrary.simpleMessage(
      "لا توجد ملفات حديثة",
    ),
    "noRecentFolders": MessageLookupByLibrary.simpleMessage(
      "لا توجد مجلدات حديثة",
    ),
    "noRoomsAvailable": MessageLookupByLibrary.simpleMessage(
      "لا توجد غرف متاحة",
    ),
    "noSharedFiles": MessageLookupByLibrary.simpleMessage(
      "لا توجد ملفات مشتركة",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("الإشعارات"),
    "numberOfFiles": MessageLookupByLibrary.simpleMessage("عدد الملفات:"),
    "ok": MessageLookupByLibrary.simpleMessage("حسناً"),
    "oneItem": MessageLookupByLibrary.simpleMessage("عنصر واحد"),
    "oneTimeShare": MessageLookupByLibrary.simpleMessage("مشاركة لمرة واحدة"),
    "oneTimeShareAccessRecorded": MessageLookupByLibrary.simpleMessage(
      "هذا الملف مشترك لمرة واحدة - تم تسجيل وصولك",
    ),
    "oneTimeShareDescription": MessageLookupByLibrary.simpleMessage(
      "يمكن لكل مستخدم فتح الملف مرة واحدة فقط",
    ),
    "onlyOwnerCanDelete": MessageLookupByLibrary.simpleMessage(
      "فقط مالك الغرفة يمكنه حذفها",
    ),
    "openAsText": MessageLookupByLibrary.simpleMessage("فتح كنص"),
    "openFileAsText": m23,
    "openFileDetailsToShare": MessageLookupByLibrary.simpleMessage(
      "يرجى فتح صفحة تفاصيل الملف ومشاركته مع الغرفة من هناك",
    ),
    "openFolderDetailsToShare": MessageLookupByLibrary.simpleMessage(
      "يرجى فتح صفحة تفاصيل المجلد ومشاركته مع الغرفة من هناك",
    ),
    "openImageEditor": MessageLookupByLibrary.simpleMessage("فتح محرر الصور"),
    "openSettings": MessageLookupByLibrary.simpleMessage("فتح الإعدادات"),
    "openTextEditor": MessageLookupByLibrary.simpleMessage("فتح محرر النص"),
    "other": MessageLookupByLibrary.simpleMessage("أخرى"),
    "owner": MessageLookupByLibrary.simpleMessage("المالك"),
    "ownerCannotLeave": MessageLookupByLibrary.simpleMessage(
      "مالك الغرفة لا يمكنه مغادرتها. يرجى حذف الغرفة بدلاً من ذلك",
    ),
    "password": MessageLookupByLibrary.simpleMessage("كلمة المرور"),
    "passwordConfirmationRequired": MessageLookupByLibrary.simpleMessage(
      "تأكيد كلمة المرور مطلوب",
    ),
    "passwordMin": MessageLookupByLibrary.simpleMessage(
      "يجب أن تكون كلمة المرور 6 أحرف على الأقل",
    ),
    "passwordMinLength": MessageLookupByLibrary.simpleMessage(
      "يجب أن تكون كلمة المرور 6 أحرف على الأقل",
    ),
    "passwordUpdateFailed": MessageLookupByLibrary.simpleMessage(
      "فشل تحديث كلمة المرور",
    ),
    "passwordUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "تم تحديث كلمة المرور بنجاح",
    ),
    "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage(
      "كلمتا المرور غير متطابقتين",
    ),
    "pdfTextExtractionNote": MessageLookupByLibrary.simpleMessage(
      "ملاحظة: قد لا يكون استخراج النص متاحاً لجميع ملفات PDF.",
    ),
    "pdfTextExtractionNote2": MessageLookupByLibrary.simpleMessage(
      "يمكنك تحديد النص وتظليله بعد الاستخراج.",
    ),
    "pendingInvitations": MessageLookupByLibrary.simpleMessage(
      "الدعوات المعلقة",
    ),
    "permissionDenied": MessageLookupByLibrary.simpleMessage(
      "تم رفض الإذن. يجب السماح بالوصول إلى الميكروفون للبحث بالصوت.",
    ),
    "pleaseEnter6DigitCode": MessageLookupByLibrary.simpleMessage(
      "يرجى إدخال كود التحقق المكون من 6 أرقام",
    ),
    "pleaseEnterComment": MessageLookupByLibrary.simpleMessage(
      "يرجى إدخال تعليق",
    ),
    "pleaseEnterFolderName": MessageLookupByLibrary.simpleMessage(
      "الرجاء إدخال اسم المجلد",
    ),
    "pleaseEnterRoomName": MessageLookupByLibrary.simpleMessage(
      "يرجى إدخال اسم للغرفة",
    ),
    "pleaseLoginAgain": MessageLookupByLibrary.simpleMessage(
      "يرجى إعادة تسجيل الدخول",
    ),
    "pleaseSelectFileOrFolder": MessageLookupByLibrary.simpleMessage(
      "يرجى اختيار ملف/مجلد للتعليق عليه",
    ),
    "pleaseWaitBeforeResend": m24,
    "preferences": MessageLookupByLibrary.simpleMessage("تفضيلات"),
    "previous": MessageLookupByLibrary.simpleMessage("السابق"),
    "privacySecurity": MessageLookupByLibrary.simpleMessage("الخصوصية والأمان"),
    "privacySettings": MessageLookupByLibrary.simpleMessage("إعدادات الخصوصية"),
    "profile": MessageLookupByLibrary.simpleMessage("الملف الشخصي"),
    "recentFiles": MessageLookupByLibrary.simpleMessage("الملفات الحديثة"),
    "recentFolders": MessageLookupByLibrary.simpleMessage("المجلدات الحديثة"),
    "reject": MessageLookupByLibrary.simpleMessage("رفض"),
    "rejectInvitation": MessageLookupByLibrary.simpleMessage("رفض الدعوة"),
    "reloadOriginalImage": MessageLookupByLibrary.simpleMessage(
      "إعادة تحميل الصورة الأصلية",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("إزالة"),
    "removeAllHighlights": MessageLookupByLibrary.simpleMessage(
      "إزالة جميع التظليلات",
    ),
    "removeFileFromRoom": MessageLookupByLibrary.simpleMessage(
      "إزالة الملف من الروم",
    ),
    "removeFolderFromRoom": MessageLookupByLibrary.simpleMessage(
      "إزالة المجلد من الروم",
    ),
    "removeMember": MessageLookupByLibrary.simpleMessage("إزالة عضو"),
    "resend": MessageLookupByLibrary.simpleMessage("إعادة الإرسال"),
    "resendCode": MessageLookupByLibrary.simpleMessage("إعادة إرسال الرمز"),
    "resendWithCountdown": m25,
    "reset": MessageLookupByLibrary.simpleMessage("إعادة تعيين"),
    "resetPassword": MessageLookupByLibrary.simpleMessage(
      "إعادة تعيين كلمة المرور",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("إعادة المحاولة"),
    "room": MessageLookupByLibrary.simpleMessage("الروم"),
    "roomDetails": MessageLookupByLibrary.simpleMessage("تفاصيل الغرفة"),
    "roomInfo": MessageLookupByLibrary.simpleMessage("معلومات الغرفة"),
    "roomLabel": MessageLookupByLibrary.simpleMessage("غرفة"),
    "roomMembers": MessageLookupByLibrary.simpleMessage("أعضاء الغرفة"),
    "roomName": m26,
    "roomNamePlaceholder": MessageLookupByLibrary.simpleMessage("بدون اسم"),
    "save": MessageLookupByLibrary.simpleMessage("حفظ"),
    "saveThisImage": MessageLookupByLibrary.simpleMessage(
      "هل تريد حفظ هذه الصورة؟",
    ),
    "saveToMyAccount": MessageLookupByLibrary.simpleMessage("حفظ في حسابي"),
    "saveToRoot": MessageLookupByLibrary.simpleMessage("حفظ في الجذر"),
    "savingFolder": MessageLookupByLibrary.simpleMessage("جاري حفظ المجلد..."),
    "searchError": m27,
    "searchHint": MessageLookupByLibrary.simpleMessage("ابحث هنا عن أي شيء"),
    "searchInPdf": MessageLookupByLibrary.simpleMessage("البحث في PDF"),
    "searchInPdfNotAvailableMessage": MessageLookupByLibrary.simpleMessage(
      "البحث في PDF غير متاح حالياً. يمكنك فتح الملف في تطبيق خارجي للبحث.",
    ),
    "seeAll": MessageLookupByLibrary.simpleMessage("عرض الكل"),
    "selectFolder": m28,
    "sendCode": MessageLookupByLibrary.simpleMessage("إرسال الرمز"),
    "sendInvitation": MessageLookupByLibrary.simpleMessage("إرسال دعوة"),
    "settings": MessageLookupByLibrary.simpleMessage("الإعدادات"),
    "share": MessageLookupByLibrary.simpleMessage("مشاركة"),
    "shareFeatureComingSoon": MessageLookupByLibrary.simpleMessage(
      "ميزة المشاركة قريباً",
    ),
    "shareFile": MessageLookupByLibrary.simpleMessage("مشاركة ملف"),
    "shareFileWithRoom": MessageLookupByLibrary.simpleMessage(
      "مشاركة الملف مع غرفة",
    ),
    "shareFilesWithRoom": MessageLookupByLibrary.simpleMessage(
      "قم بمشاركة ملفات مع هذه الغرفة",
    ),
    "shareFolderWithRoom": MessageLookupByLibrary.simpleMessage(
      "مشاركة المجلد مع غرفة",
    ),
    "shareWithRoom": MessageLookupByLibrary.simpleMessage("مشاركة مع غرفة"),
    "shareWithThisRoom": MessageLookupByLibrary.simpleMessage(
      "مشاركة مع هذه الغرفة",
    ),
    "shared": MessageLookupByLibrary.simpleMessage("مشتركة"),
    "sharedBy": MessageLookupByLibrary.simpleMessage("شاركه"),
    "sharedFile": MessageLookupByLibrary.simpleMessage("ملف مشترك"),
    "sharedFiles": MessageLookupByLibrary.simpleMessage("الملفات المشتركة"),
    "sharedFilesContent": MessageLookupByLibrary.simpleMessage(
      "سيتم عرض الملفات المشتركة هنا",
    ),
    "sharedFilesCount": m29,
    "signIn": MessageLookupByLibrary.simpleMessage("تسجيل الدخول"),
    "signInWith": MessageLookupByLibrary.simpleMessage("تسجيل الدخول باستخدام"),
    "signOut": MessageLookupByLibrary.simpleMessage("تسجيل الخروج من حسابك"),
    "signUp": MessageLookupByLibrary.simpleMessage("إنشاء حساب"),
    "signUpWith": MessageLookupByLibrary.simpleMessage("إنشاء حساب باستخدام"),
    "size": MessageLookupByLibrary.simpleMessage("الحجم"),
    "smartSearch": MessageLookupByLibrary.simpleMessage("البحث الذكي"),
    "speechRecognitionNotAvailable": MessageLookupByLibrary.simpleMessage(
      "خدمة التعرف على الصوت غير متاحة",
    ),
    "startTimeMustBeBeforeEndTime": MessageLookupByLibrary.simpleMessage(
      "وقت البداية يجب أن يكون قبل وقت النهاية",
    ),
    "status": MessageLookupByLibrary.simpleMessage("الحالة"),
    "storage": MessageLookupByLibrary.simpleMessage("التخزين"),
    "storageOverview": MessageLookupByLibrary.simpleMessage(
      "نظرة عامة على التخزين",
    ),
    "storageUsed": MessageLookupByLibrary.simpleMessage("المستخدم"),
    "storageUsedValue": MessageLookupByLibrary.simpleMessage("60%"),
    "subfoldersCount": MessageLookupByLibrary.simpleMessage(
      "عدد المجلدات الفرعية",
    ),
    "support": MessageLookupByLibrary.simpleMessage("الدعم"),
    "switchThemes": MessageLookupByLibrary.simpleMessage("تبديل بين السمات"),
    "system": MessageLookupByLibrary.simpleMessage("نظام"),
    "tags": MessageLookupByLibrary.simpleMessage("الوسوم"),
    "termsPrivacyPolicy": MessageLookupByLibrary.simpleMessage(
      "شروط الخدمة وسياسة الخصوصية",
    ),
    "textEdited": MessageLookupByLibrary.simpleMessage("تم تعديل النص"),
    "textHighlighted": MessageLookupByLibrary.simpleMessage(
      "تم تظليل النص المحدد",
    ),
    "textNotExtractedYet": MessageLookupByLibrary.simpleMessage(
      "لم يتم استخراج النص بعد",
    ),
    "timeAndDate": MessageLookupByLibrary.simpleMessage("الوقت والتاريخ"),
    "tokenNotFound": MessageLookupByLibrary.simpleMessage(
      "لم يتم العثور على التوكن",
    ),
    "trash": MessageLookupByLibrary.simpleMessage("المحذوفات"),
    "type": MessageLookupByLibrary.simpleMessage("النوع"),
    "typeLabel": MessageLookupByLibrary.simpleMessage("النوع"),
    "unclassified": MessageLookupByLibrary.simpleMessage("غير مصنف"),
    "unknownFile": MessageLookupByLibrary.simpleMessage("ملف غير معروف"),
    "unsavedChanges": MessageLookupByLibrary.simpleMessage(
      "تغييرات غير محفوظة",
    ),
    "unsavedChangesMessage": MessageLookupByLibrary.simpleMessage(
      "لديك تغييرات غير محفوظة. هل تريد الخروج دون حفظ؟",
    ),
    "unshare": MessageLookupByLibrary.simpleMessage("إلغاء المشاركة"),
    "unshareFile": MessageLookupByLibrary.simpleMessage("إلغاء مشاركة الملف"),
    "unshareFileConfirm": MessageLookupByLibrary.simpleMessage(
      "هل أنت متأكد من إلغاء مشاركة هذا الملف مع جميع المستخدمين؟",
    ),
    "unsupportedFile": MessageLookupByLibrary.simpleMessage("ملف غير مدعوم"),
    "updateFailed": MessageLookupByLibrary.simpleMessage("فشل التحديث"),
    "updated": MessageLookupByLibrary.simpleMessage(" تحديث"),
    "updatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "تم التحديث بنجاح",
    ),
    "updating": MessageLookupByLibrary.simpleMessage("جاري التحديث..."),
    "uploadFile": MessageLookupByLibrary.simpleMessage("رفع ملف"),
    "upload_success": MessageLookupByLibrary.simpleMessage(
      "تم رفع الملف بنجاح",
    ),
    "used": MessageLookupByLibrary.simpleMessage("المستخدمة"),
    "usedStorage": MessageLookupByLibrary.simpleMessage("التخزين المستخدم:"),
    "usedStorageValue": MessageLookupByLibrary.simpleMessage("149.5 جيجابايت"),
    "user": MessageLookupByLibrary.simpleMessage("مستخدم"),
    "userLabel": MessageLookupByLibrary.simpleMessage("مستخدم"),
    "username": MessageLookupByLibrary.simpleMessage("اسم المستخدم"),
    "usernameAllowedChars": MessageLookupByLibrary.simpleMessage(
      "يمكن أن يحتوي اسم المستخدم على أحرف وأرقام وشرطة سفلية فقط",
    ),
    "usernameMax": MessageLookupByLibrary.simpleMessage(
      "يجب ألا يتجاوز اسم المستخدم 20 حرفًا",
    ),
    "usernameMin": MessageLookupByLibrary.simpleMessage(
      "يجب أن يكون اسم المستخدم 3 أحرف على الأقل",
    ),
    "usernameOrEmail": MessageLookupByLibrary.simpleMessage(
      "اسم المستخدم أو البريد الإلكتروني",
    ),
    "validEmail": MessageLookupByLibrary.simpleMessage(
      "يرجى إدخال بريد إلكتروني صالح",
    ),
    "validEmailRequired": MessageLookupByLibrary.simpleMessage(
      "يرجى إدخال بريد إلكتروني صالح",
    ),
    "verificationCodeSent": MessageLookupByLibrary.simpleMessage(
      "تم إرسال كود التحقق إلى بريدك الإلكتروني",
    ),
    "verificationCodeSentTo": m30,
    "verify": MessageLookupByLibrary.simpleMessage("التحقق"),
    "verifyCodeTitle": MessageLookupByLibrary.simpleMessage("التحقق من الرمز"),
    "video": MessageLookupByLibrary.simpleMessage("فيديو"),
    "videos": MessageLookupByLibrary.simpleMessage("فيديوهات"),
    "viewAll": MessageLookupByLibrary.simpleMessage("عرض الكل"),
    "viewOnly": MessageLookupByLibrary.simpleMessage("عرض فقط"),
    "viewOnlyDescription": MessageLookupByLibrary.simpleMessage(
      "يمكنه عرض الملفات فقط",
    ),
    "viewedByAll": MessageLookupByLibrary.simpleMessage("شوهد من الجميع"),
    "yesterday": MessageLookupByLibrary.simpleMessage("أمس"),
    "youAreOwner": MessageLookupByLibrary.simpleMessage("أنت المالك"),
  };
}
