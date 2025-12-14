// // ignore: unused_import
// import 'package:intl/intl.dart' as intl;
// import 'l10n.dart';

// // ignore_for_file: type=lint

// /// The translations for Arabic (`ar`).
// class AppLocalizationsAr extends AppLocalizations {
//   AppLocalizationsAr([String locale = 'ar']) : super(locale);

//   @override
//   String get appTitle => 'فليڤو';

//   @override
//   String get loginSubtitle => 'سجّل الدخول إلى حسابك';

//   @override
//   String get usernameOrEmail => 'اسم المستخدم أو البريد الإلكتروني';

//   @override
//   String get password => 'كلمة المرور';

//   @override
//   String get forgotPassword => 'هل نسيت كلمة المرور؟';

//   @override
//   String get signIn => 'تسجيل الدخول';

//   @override
//   String get signInWith => 'تسجيل الدخول باستخدام';

//   @override
//   String get dontHaveAccount => 'ليس لديك حساب؟ ';

//   @override
//   String get signUp => 'إنشاء حساب';

//   @override
//   String get loginSuccessful => 'تم تسجيل الدخول بنجاح!';

//   @override
//   String get invalidCredentials => 'بيانات الاعتماد غير صحيحة';

//   @override
//   String get createAccount => 'إنشاء حساب';

//   @override
//   String get username => 'اسم المستخدم';

//   @override
//   String get email => 'البريد الإلكتروني';

//   @override
//   String get mobile => 'رقم الهاتف';

//   @override
//   String get confirmPassword => 'تأكيد كلمة المرور';

//   @override
//   String get create => 'إنشاء';

//   @override
//   String get signUpWith => 'إنشاء حساب باستخدام';

//   @override
//   String get alreadyHaveAccount => 'هل لديك حساب بالفعل؟ ';

//   @override
//   String get logIn => 'تسجيل الدخول';

//   @override
//   String get accountCreatedSuccessfully => 'تم إنشاء الحساب بنجاح!';

//   @override
//   String get enterUsernameOrEmail => 'الرجاء إدخال اسم المستخدم أو البريد الإلكتروني';

//   @override
//   String get invalidEmail => 'الرجاء إدخال بريد إلكتروني صالح';

//   @override
//   String get enterUsername => 'الرجاء إدخال اسم المستخدم';

//   @override
//   String get usernameMin => 'يجب أن يكون اسم المستخدم 3 أحرف على الأقل';

//   @override
//   String get usernameMax => 'يجب ألا يتجاوز اسم المستخدم 20 حرفًا';

//   @override
//   String get usernameAllowedChars => 'يمكن أن يحتوي اسم المستخدم على أحرف وأرقام وشرطة سفلية فقط';

//   @override
//   String get enterPassword => 'الرجاء إدخال كلمة المرور';

//   @override
//   String get passwordMin => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

//   @override
//   String get enterConfirmPassword => 'يرجى تأكيد كلمة المرور';

//   @override
//   String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

//   @override
//   String get enterPhone => 'الرجاء إدخال رقم الهاتف';

//   @override
//   String get invalidPhone => 'الرجاء إدخال رقم هاتف صالح (10-15 رقمًا)';

//   @override
//   String get recentFolders => 'المجلدات الحديثة';

//   @override
//   String get seeAll => 'عرض الكل';

//   @override
//   String get recentFiles => 'الملفات الحديثة';

//   @override
//   String get storageUsed => 'المستخدم';

//   @override
//   String get storageUsedValue => '60%';

//   @override
//   String get freeInternal => 'المساحة الداخلية المتاحة';

//   @override
//   String get freeInternalValue => '120.5 جيجابايت';

//   @override
//   String get usedStorageValue => '149.5 جيجابايت';

//   @override
//   String get searchHint => 'ابحث هنا عن أي شيء';

//   @override
//   String get all => 'الكل';

//   @override
//   String get myFiles => 'ملفاتي';

//   @override
//   String get shared => 'مشتركة';

//   @override
//   String get allItems => 'جميع العناصر';

//   @override
//   String get myFolders => 'مجلداتي';

//   @override
//   String get sharedFiles => 'الملفات المشتركة';

//   @override
//   String get sharedFilesContent => 'سيتم عرض الملفات المشتركة هنا';

//   @override
//   String get filter => 'تصفية';

//   @override
//   String get images => 'صور';

//   @override
//   String get videos => 'فيديوهات';

//   @override
//   String get audio => 'صوتيات';

//   @override
//   String get compressed => 'مضغوط';

//   @override
//   String get applications => 'تطبيقات';

//   @override
//   String get documents => 'مستندات';

//   @override
//   String get code => 'رمز/كود';

//   @override
//   String get other => 'أخرى';

//   @override
//   String get type => 'النوع';

//   @override
//   String get timeAndDate => 'الوقت والتاريخ';

//   @override
//   String get yesterday => 'أمس';

//   @override
//   String get last7Days => 'آخر 7 أيام';

//   @override
//   String get last30Days => 'آخر 30 يومًا';

//   @override
//   String get lastYear => 'العام الماضي';

//   @override
//   String get custom => 'مخصص';

//   @override
//   String get usedStorage => 'التخزين المستخدم:';

//   @override
//   String get storageOverview => 'نظرة عامة على التخزين';

//   @override
//   String get settings => 'الإعدادات';

//   @override
//   String get chooseLanguage => 'اختر اللغة';

//   @override
//   String get english => 'الإنجليزية';

//   @override
//   String get arabic => 'العربية';

//   @override
//   String get general => 'عام';

//   @override
//   String get generalSettings => 'إعدادات عامة';

//   @override
//   String get basicAppSettings => 'الإعدادات الأساسية للتطبيق';

//   @override
//   String get darkMode => 'الوضع الداكن';

//   @override
//   String get switchThemes => 'تبديل بين السمات';

//   @override
//   String get language => 'اللغة';

//   @override
//   String get preferences => 'تفضيلات';

//   @override
//   String get notifications => 'الإشعارات';

//   @override
//   String get manageNotifications => 'إدارة الإشعارات';

//   @override
//   String get storage => 'التخزين';

//   @override
//   String get manageStorageSettings => 'إدارة إعدادات التخزين';

//   @override
//   String get privacySecurity => 'الخصوصية والأمان';

//   @override
//   String get privacySettings => 'إعدادات الخصوصية';

//   @override
//   String get support => 'الدعم';

//   @override
//   String get legalPolicies => 'القوانين والسياسات';

//   @override
//   String get termsPrivacyPolicy => 'شروط الخدمة وسياسة الخصوصية';

//   @override
//   String get helpSupport => 'المساعدة والدعم';

//   @override
//   String get getHelpSupport => 'الحصول على المساعدة والدعم';

//   @override
//   String get about => 'حول';

//   @override
//   String appVersion(Object version) {
//     return 'إصدار التطبيق $version';
//   }

//   @override
//   String get logout => 'تسجيل الخروج';

//   @override
//   String get signOut => 'تسجيل الخروج من حسابك';

//   @override
//   String get resetPassword => 'إعادة تعيين كلمة المرور';

//   @override
//   String get forgotPasswordTitle => 'هل نسيت كلمة المرور؟';

//   @override
//   String get forgotPasswordSubtitle => 'أدخل بريدك الإلكتروني وسنرسل لك رمزًا لإعادة تعيين كلمة المرور.';

//   @override
//   String get sendCode => 'إرسال الرمز';

//   @override
//   String get enterEmail => 'يرجى إدخال بريدك الإلكتروني';

//   @override
//   String get validEmail => 'يرجى إدخال بريد إلكتروني صالح';

//   @override
//   String get codeSent => 'تم إرسال الرمز بنجاح';

//   @override
//   String get failedSendCode => 'فشل في إرسال الرمز';

//   @override
//   String get backToLogin => 'العودة لتسجيل الدخول';

//   @override
//   String get verifyCodeTitle => 'التحقق من الرمز';

//   @override
//   String get enter6DigitCode => 'الرجاء إدخال رمز مكون من 6 أرقام';

//   @override
//   String enterCodeToEmail(Object email) {
//     return 'أدخل الرمز المكون من 6 أرقام المرسل إلى $email';
//   }

//   @override
//   String get verify => 'تحقق';

//   @override
//   String get resendCode => 'إعادة إرسال الرمز';

//   @override
//   String get codeVerified => 'تم التحقق من الرمز بنجاح';

//   @override
//   String get invalidOrExpiredCode => 'الرمز غير صالح أو منتهي الصلاحية';

//   @override
//   String get codeResent => 'تم إعادة إرسال الرمز بنجاح';

//   @override
//   String get failedResendCode => 'فشل في إعادة إرسال الرمز';

//   @override
//   String get mustLogin => 'يجب تسجيل الدخول أولاً';

//   @override
//   String get errorFetchingData => 'خطأ في جلب البيانات';

//   @override
//   String get loginRequiredToAccessFiles => 'يجب تسجيل الدخول للوصول إلى الملفات';

//   @override
//   String get retry => 'إعادة المحاولة';

//   @override
//   String get noFilesInCategory => 'لا توجد ملفات في هذا التصنيف.';

//   @override
//   String get updated => ' تحديث';

//   @override
//   String get numberOfFiles => 'عدد الملفات:';

//   @override
//   String get upload_success => 'تم رفع الملف بنجاح';

//   @override
//   String get createFolder => 'إنشاء مجلد';

//   @override
//   String get folderNameHint => 'اسم المجلد';

//   @override
//   String get enterFolderName => 'الرجاء إدخال اسم المجلد';

//   @override
//   String get fileIdNotAvailable => 'معرف الملف غير متوفر';

//   @override
//   String get fileAlreadyAccessed => 'لقد فتحت هذا الملف من قبل. الملف مشترك لمرة واحدة فقط.';

//   @override
//   String get oneTimeShareAccessRecorded => 'هذا الملف مشترك لمرة واحدة - تم تسجيل وصولك';

//   @override
//   String get cannotAccessFile => 'لا يمكن الوصول إلى الملف';

//   @override
//   String get errorAccessingFile => 'خطأ في الوصول إلى الملف';

//   @override
//   String get fileUrlNotAvailable => 'رابط الملف غير متوفر';

//   @override
//   String get invalidUrl => 'رابط غير صالح';

//   @override
//   String get unsupportedFile => 'ملف غير مدعوم';

//   @override
//   String get invalidPdfFile => 'هذا الملف ليس PDF صالح أو قد يكون تالفاً.';

//   @override
//   String get openAsText => 'فتح كنص';

//   @override
//   String get shareFileWithRoom => 'مشاركة الملف مع غرفة';

//   @override
//   String get chooseRoomToShare => 'اختر غرفة لمشاركة هذا الملف';

//   @override
//   String get noRoomsAvailable => 'لا توجد غرف متاحة';

//   @override
//   String get createRoomFirst => 'قم بإنشاء غرفة أولاً للمشاركة';

//   @override
//   String get oneTimeShare => 'مشاركة لمرة واحدة';

//   @override
//   String get oneTimeShareDescription => 'يمكن لكل مستخدم فتح الملف مرة واحدة فقط';

//   @override
//   String expiresInHours(Object hours) {
//     return 'ينتهي خلال $hours ساعة';
//   }

//   @override
//   String get enterHours => 'أدخل عدد الساعات';

//   @override
//   String get confirm => 'تأكيد';

//   @override
//   String get share => 'مشاركة';

//   @override
//   String get fileAlreadyShared => 'هذا الملف مشترك بالفعل مع هذه الغرفة';

//   @override
//   String get roomDetails => 'تفاصيل الغرفة';

//   @override
//   String get onlyOwnerCanDelete => 'فقط مالك الغرفة يمكنه حذفها';

//   @override
//   String get ownerCannotLeave => 'مالك الغرفة لا يمكنه مغادرتها. يرجى حذف الغرفة بدلاً من ذلك';

//   @override
//   String get deleteRoom => 'حذف الغرفة';

//   @override
//   String get leaveRoom => 'مغادرة الغرفة';

//   @override
//   String roomName(Object roomName) {
//     return '$roomName';
//   }

//   @override
//   String get roomNamePlaceholder => 'بدون اسم';

//   @override
//   String get leave => 'مغادرة';

//   @override
//   String get owner => 'المالك';

//   @override
//   String get members => 'أعضاء';

//   @override
//   String get files => 'ملفات';

//   @override
//   String get folders => 'مجلدات';

//   @override
//   String get sendInvitation => 'إرسال دعوة';

//   @override
//   String get comments => 'التعليقات';

//   @override
//   String get roomInfo => 'معلومات الغرفة';

//   @override
//   String get createdAt => 'أنشئت في';

//   @override
//   String get lastModified => 'آخر تعديل';

//   @override
//   String get viewAll => 'عرض الكل';

//   @override
//   String get noMembers => 'لا يوجد أعضاء';

//   @override
//   String sharedFilesCount(Object count) {
//     return 'الملفات المشتركة ($count)';
//   }

//   @override
//   String get addFile => 'إضافة ملف';

//   @override
//   String get addFileToRoom => 'إضافة ملف للغرفة';

//   @override
//   String get addFolder => 'إضافة مجلد';

//   @override
//   String get addFolderToRoom => 'إضافة مجلد للغرفة';

//   @override
//   String get selectFolder => 'اختيار \"null\"';

//   @override
//   String get noFoldersAvailable => 'لا توجد مجلدات متاحة';

//   @override
//   String get noSubfolders => 'لا توجد مجلدات فرعية';

//   @override
//   String get errorLoadingSubfolders => 'خطأ في تحميل المجلدات الفرعية';

//   @override
//   String get open => 'فتح';

//   @override
//   String get viewDetails => 'عرض التفاصيل';

//   @override
//   String get removeFromFavorites => 'إزالة من المفضلة';

//   @override
//   String get addToFavorites => 'إضافة إلى المفضلة';

//   @override
//   String get removeFromRoom => 'إزالة من الغرفة';

//   @override
//   String get viewInfo => 'عرض المعلومات';

//   @override
//   String get edit => 'تحرير';

//   @override
//   String get move => 'نقل';

//   @override
//   String get delete => 'حذف';

//   @override
//   String get download => 'تحميل';

//   @override
//   String get saveToMyAccount => 'حفظ في حسابي';

//   @override
//   String get cannotAddSharedFilesToFavorites => 'لا يمكن إضافة الملفات المشتركة في الروم إلى المفضلة';

//   @override
//   String get noName => 'بدون اسم';

//   @override
//   String get fileWithoutName => 'ملف بدون اسم';

//   @override
//   String get noRecentFolders => 'لا توجد مجلدات حديثة';

//   @override
//   String get noRecentFiles => 'لا توجد ملفات حديثة';

//   @override
//   String get folder => 'مجلد';

//   @override
//   String get noItems => 'لا توجد عناصر';

//   @override
//   String get oneItem => 'عنصر واحد';

//   @override
//   String get item => 'عنصر';

//   @override
//   String get items => 'عناصر';

//   @override
//   String get fileSavedSuccessfully => 'تم حفظ الملف بنجاح';

//   @override
//   String get fileSavedAndUploaded => 'تم حفظ الملف ورفعه إلى السيرفر بنجاح';

//   @override
//   String get fileSavedLocallyOnly => 'تم حفظ الملف محلياً فقط. يرجى المحاولة مرة أخرى لرفعه على السيرفر';

//   @override
//   String get failedToSaveFile => 'فشل حفظ الملف';

//   @override
//   String get unsavedChanges => 'تغييرات غير محفوظة';

//   @override
//   String get unsavedChangesMessage => 'لديك تغييرات غير محفوظة. هل تريد الخروج دون حفظ؟';

//   @override
//   String get exit => 'خروج';

//   @override
//   String get copyContent => 'نسخ المحتوى';

//   @override
//   String get accessTokenNotFound => 'لم يتم العثور على رمز الوصول';

//   @override
//   String get fileIsEmpty => 'الملف فارغ';

//   @override
//   String get loadingFileData => 'جاري تحميل بيانات الملف...';

//   @override
//   String get failedToLoadFileData => 'فشل في تحميل بيانات الملف';

//   @override
//   String get fileInfo => 'معلومات الملف';

//   @override
//   String get extension => 'الامتداد';

//   @override
//   String get size => 'الحجم';

//   @override
//   String get description => 'الوصف';

//   @override
//   String get tags => 'الوسوم';

//   @override
//   String get shareWithRoom => 'مشاركة مع غرفة';

//   @override
//   String get shareFeatureComingSoon => 'ميزة المشاركة قريباً';

//   @override
//   String get image => 'صورة';

//   @override
//   String get video => 'فيديو';

//   @override
//   String get document => 'مستند';

//   @override
//   String get unclassified => 'غير مصنف';

//   @override
//   String get extractingTextFromPdf => 'جارٍ استخراج النص من PDF...';

//   @override
//   String error(String error) {
//     return 'خطأ: $error';
//   }

//   @override
//   String get status => 'الحالة';

//   @override
//   String get youAreOwner => 'أنت المالك';

//   @override
//   String get sharedFile => 'ملف مشترك';

//   @override
//   String get unshareFile => 'إلغاء مشاركة الملف';

//   @override
//   String get unshare => 'إلغاء المشاركة';

//   @override
//   String get mustLoginFirst => 'يجب تسجيل الدخول أولاً';

//   @override
//   String get editFile => 'تعديل الملف';

//   @override
//   String get editImage => 'تعديل الصورة';

//   @override
//   String get openImageEditor => 'فتح محرر الصور';

//   @override
//   String get imageEdited => 'تم تعديل الصورة';

//   @override
//   String get reloadOriginalImage => 'إعادة تحميل الصورة الأصلية';

//   @override
//   String get editText => 'تعديل النص';

//   @override
//   String get openTextEditor => 'فتح محرر النص';

//   @override
//   String get textEdited => 'تم تعديل النص';

//   @override
//   String get failedToLoadImage => 'فشل تحميل الصورة';

//   @override
//   String get failedToSaveTempImage => 'فشل حفظ الصورة المؤقتة';

//   @override
//   String get loadedImageIsEmpty => 'الصورة المحملة فارغة';

//   @override
//   String errorVerifyingImage(String error) {
//     return 'خطأ في التحقق من الصورة: $error';
//   }

//   @override
//   String get loadingVideo => 'جاري تحميل الفيديو...';

//   @override
//   String failedToLoadVideo(int statusCode) {
//     return 'فشل تحميل الفيديو ($statusCode)';
//   }

//   @override
//   String get failedToSaveTempVideo => 'فشل حفظ الفيديو المؤقت';

//   @override
//   String get loadedVideoIsEmpty => 'الفيديو المحمل فارغ';

//   @override
//   String errorVerifyingVideo(String error) {
//     return 'خطأ في التحقق من الفيديو: $error';
//   }

//   @override
//   String get extractingImage => 'جاري استخراج الصورة...';

//   @override
//   String get imageExtracted => 'تم استخراج الصورة';

//   @override
//   String get saveThisImage => 'هل تريد حفظ هذه الصورة؟';

//   @override
//   String get failedToExtractImage => 'فشل استخراج الصورة';

//   @override
//   String get mergingVideos => 'جاري دمج المقاطع... قد يستغرق بعض الوقت';

//   @override
//   String get failedToMergeVideos => 'فشل دمج المقاطع';

//   @override
//   String failedToLoadAudio(int statusCode) {
//     return 'فشل تحميل الملف الصوتي ($statusCode)';
//   }

//   @override
//   String get failedToSaveTempAudio => 'فشل حفظ الملف الصوتي المؤقت';

//   @override
//   String get loadedAudioIsEmpty => 'الملف الصوتي المحمل فارغ';

//   @override
//   String get startTimeMustBeBeforeEndTime => 'وقت البداية يجب أن يكون قبل وقت النهاية';

//   @override
//   String get failedToLoadAudioFile => 'فشل تحميل الملف الصوتي';

//   @override
//   String get failedToLoadBaseAudio => 'فشل تحميل الملف الصوتي الأساسي';

//   @override
//   String get mustSelectAtLeastTwoAudioFiles => 'يجب اختيار ملفين صوتيين على الأقل للدمج';

//   @override
//   String get mergingAudioFiles => 'جاري دمج الملفات الصوتية... قد يستغرق بعض الوقت';

//   @override
//   String pdfLoadFailed(int statusCode) {
//     return 'فشل تحميل ملف PDF ($statusCode)';
//   }

//   @override
//   String get failedToLoadPdf => 'فشل تحميل ملف PDF';

//   @override
//   String get failedToLoadFile => 'فشل تحميل الملف';

//   @override
//   String get imageEditedSuccessfully => '✅ تم تعديل الصورة بنجاح';

//   @override
//   String get editedImageIsEmpty => '⚠️ الصورة المعدلة فارغة';

//   @override
//   String get failedToSaveEditedImage => '⚠️ فشل حفظ الصورة المعدلة';

//   @override
//   String get textEditedSuccessfully => '✅ تم تعديل النص بنجاح. اضغط على \"حفظ التغييرات\" لرفعه على السيرفر';

//   @override
//   String get saveOptions => 'خيارات الحفظ';

//   @override
//   String get saveOptionsDescription => 'كيف تريد حفظ الصورة المعدلة؟\n\n• حفظ نسخة جديدة: سيتم حفظ الصورة المعدلة كملف جديد\n• استبدال النسخة القديمة: سيتم حذف الملف القديم واستبداله بالصورة المعدلة';

//   @override
//   String get saveNewCopy => 'حفظ نسخة جديدة';

//   @override
//   String get replaceOldVersion => 'استبدال النسخة القديمة';

//   @override
//   String get extract => 'استخراج';

//   @override
//   String get trimAudio => 'قص الصوت';

//   @override
//   String totalDuration(String duration) {
//     return 'المدة الكلية: $duration';
//   }

//   @override
//   String get trim => 'قص';

//   @override
//   String get adjustVolume => 'تعديل مستوى الصوت';

//   @override
//   String get apply => 'تطبيق';

//   @override
//   String get convertFormat => 'تحويل الصيغة';

//   @override
//   String get chooseOutputFormat => 'اختر صيغة الإخراج:';

//   @override
//   String get wavFormat => 'WAV';

//   @override
//   String get wavDescription => 'جودة عالية، حجم كبير';

//   @override
//   String get mp3Format => 'MP3';

//   @override
//   String get mp3Description => 'جودة جيدة، حجم صغير';

//   @override
//   String get aacFormat => 'AAC';

//   @override
//   String get aacDescription => 'جودة جيدة جداً';

//   @override
//   String get addTextAnnotation => 'إضافة نص (Annotation)';

//   @override
//   String positionX(String x) {
//     return 'الموضع X: $x';
//   }

//   @override
//   String positionY(String y) {
//     return 'الموضع Y: $y';
//   }

//   @override
//   String fontSize(String size) {
//     return 'حجم الخط: $size';
//   }

//   @override
//   String page(String pageNumber) {
//     return 'الصفحة: $pageNumber';
//   }

//   @override
//   String get add => 'إضافة';

//   @override
//   String get selectImagePosition => 'تحديد موضع الصورة';

//   @override
//   String width(String width) {
//     return 'العرض: $width';
//   }

//   @override
//   String height(String height) {
//     return 'الارتفاع: $height';
//   }

//   @override
//   String get highlightText => 'تظليل النص (Highlight)';

//   @override
//   String get color => 'اللون:';

//   @override
//   String get highlight => 'تظليل';

//   @override
//   String get videoEditedSuccessfully => '✅ تم تعديل الفيديو بنجاح';

//   @override
//   String get editedVideoIsEmpty => '⚠️ الفيديو المعدل فارغ';

//   @override
//   String get failedToSaveEditedVideo => '⚠️ فشل حفظ الفيديو المعدل';

//   @override
//   String get videoMergedSuccessfully => '✅ تم دمج المقاطع بنجاح';

//   @override
//   String get textAddedSuccessfully => '✅ تم إضافة النص بنجاح';

//   @override
//   String get imageAddedSuccessfully => '✅ تم إضافة الصورة بنجاح';

//   @override
//   String get textHighlightedSuccessfully => '✅ تم تظليل النص بنجاح';

//   @override
//   String get fileUpdatedSuccessfully => '✅ تم تحديث الملف بنجاح';

//   @override
//   String get fileReplacedSuccessfully => '✅ تم استبدال الملف بنجاح';

//   @override
//   String get newCopySavedSuccessfully => '✅ تم حفظ النسخة الجديدة بنجاح';

//   @override
//   String get changesSavedSuccessfully => '✅ تم حفظ التغييرات بنجاح';

//   @override
//   String errorOccurred(String error) {
//     return '❌ خطأ: $error';
//   }

//   @override
//   String get imageExtractedSuccessfully => '✅ تم استخراج الصورة بنجاح';

//   @override
//   String get editedFileNotFound => 'الملف المعدل غير موجود. يرجى إعادة التعديل';

//   @override
//   String errorAccessingEditedFile(String error) {
//     return 'خطأ في الوصول للملف المعدل: $error';
//   }

//   @override
//   String get chooseTimeToExtractImage => 'اختر الوقت لاستخراج الصورة';

//   @override
//   String get chooseTimeInSeconds => 'اختر الوقت بالثواني:';

//   @override
//   String get save => 'حفظ';

//   @override
//   String get cancel => 'إلغاء';

//   @override
//   String get editFileMetadata => 'تعديل الملف';

//   @override
//   String get fileName => 'اسم الملف';

//   @override
//   String get fileDescription => 'الوصف';

//   @override
//   String get tagsSeparatedByComma => 'الوسوم (افصل بينها بفاصلة)';

//   @override
//   String get changesSaveFailed => '❌ فشل حفظ التعديلات';

//   @override
//   String confirmDeleteFile(String fileName) {
//     return 'هل أنت متأكد من حذف الملف \'$fileName\'؟';
//   }

//   @override
//   String get noTokenError => '❌ خطأ: لا يوجد توكن.';

//   @override
//   String fileDeletedSuccessfully(String fileName) {
//     return '✅ تم حذف الملف \'$fileName\' بنجاح';
//   }

//   @override
//   String errorDeletingFile(String error) {
//     return '❌ حدث خطأ أثناء حذف الملف: $error';
//   }

//   @override
//   String get noUsersSharedWith => 'لا يوجد مستخدمون مشارك معهم الملف';

//   @override
//   String get cannotIdentifyUsers => 'لا يمكن تحديد المستخدمين لإلغاء المشاركة';

//   @override
//   String get unshareFileSuccess => '✅ تم إلغاء مشاركة الملف';

//   @override
//   String get unshareFailed => 'فشل إلغاء المشاركة';

//   @override
//   String get fileAddedToFavorites => '✅ تم إضافة الملف إلى المفضلة';

//   @override
//   String get fileRemovedFromFavorites => '✅ تم إزالة الملف من المفضلة';

//   @override
//   String get errorUpdating => '❌ حدث خطأ أثناء التحديث';

//   @override
//   String get downloadingFile => 'جاري تحميل الملف...';

//   @override
//   String fileDownloadedSuccessfully(String fileName) {
//     return '✅ تم تحميل الملف بنجاح: $fileName';
//   }

//   @override
//   String get failedToDownloadFile => 'فشل تحميل الملف';

//   @override
//   String errorDownloadingFile(String error) {
//     return '❌ خطأ في تحميل الملف: $error';
//   }

//   @override
//   String get cannotIdentifyFile => 'لا يمكن تحديد الملف';

//   @override
//   String get shareRequestSent => '✅ تم إرسال طلب المشاركة للغرفة';

//   @override
//   String get unshareFileConfirm => 'هل أنت متأكد من إلغاء مشاركة هذا الملف مع جميع المستخدمين؟';

//   @override
//   String get updating => 'جاري التحديث...';

//   @override
//   String get deleteFile => 'حذف ملف';

//   @override
//   String get saveChanges => 'حفظ التعديلات';

//   @override
//   String get mustLoginFirstError => 'خطأ: يجب تسجيل الدخول أولاً';

//   @override
//   String errorLoadingFileData(String error) {
//     return 'حدث خطأ في تحميل بيانات الملف: $error';
//   }

//   @override
//   String get file => 'ملف';

//   @override
//   String get failedToLoadPreview => 'تعذر تحميل المعاينة';

//   @override
//   String get modified => 'عدل';

//   @override
//   String failedToLoadPdfFile(String error) {
//     return 'فشل تحميل ملف PDF: $error';
//   }

//   @override
//   String failedToOpenFile(String error) {
//     return 'فشل فتح الملف: $error';
//   }

//   @override
//   String failedToLoadPdfForDisplay(String error) {
//     return 'فشل تحميل PDF للعرض: $error';
//   }

//   @override
//   String get pdfTextExtractionNote => 'ملاحظة: قد لا يكون استخراج النص متاحاً لجميع ملفات PDF.';

//   @override
//   String get pdfTextExtractionNote2 => 'يمكنك تحديد النص وتظليله بعد الاستخراج.';

//   @override
//   String get failedToExtractTextFromPdf => 'فشل استخراج النص من PDF';

//   @override
//   String get canViewPdfAndSearch => 'يمكنك عرض PDF والبحث فيه';

//   @override
//   String get textHighlighted => 'تم تظليل النص المحدد';

//   @override
//   String get searchInPdfNotAvailableMessage => 'البحث في PDF غير متاح حالياً. يمكنك فتح الملف في تطبيق خارجي للبحث.';

//   @override
//   String get searchInPdf => 'البحث في PDF';

//   @override
//   String get forAdvancedSearchFeature => 'للاستفادة من ميزة البحث المتقدمة، نوصي باستخدام:';

//   @override
//   String get currentVersionSupports => 'الإصدار الحالي يدعم:';

//   @override
//   String get ok => 'موافق';

//   @override
//   String get loadingFile => 'جاري تحميل الملف...';

//   @override
//   String get fileNotLoaded => 'لم يتم تحميل الملف';

//   @override
//   String get extractingText => 'جارٍ استخراج النص...';

//   @override
//   String get highlightSelectedText => 'تظليل النص المحدد';

//   @override
//   String get removeAllHighlights => 'إزالة جميع التظليلات';

//   @override
//   String get highlights => 'تظليل';

//   @override
//   String get textNotExtractedYet => 'لم يتم استخراج النص بعد';

//   @override
//   String get extractText => 'استخراج النص';

//   @override
//   String get removeFileFromRoom => 'إزالة الملف من الروم';

//   @override
//   String removeFileFromRoomConfirm(String fileName) {
//     return 'هل أنت متأكد من إزالة \"$fileName\" من هذه الغرفة؟';
//   }

//   @override
//   String get remove => 'إزالة';

//   @override
//   String get fileRemovedFromRoom => 'تم إزالة الملف من الغرفة بنجاح';

//   @override
//   String get failedToRemoveFile => 'فشل إزالة الملف من الغرفة';

//   @override
//   String get fileIdNotFound => 'File ID not found';

//   @override
//   String get movingFile => 'جاري نقل الملف...';

//   @override
//   String get fileMovedSuccessfully => 'تم نقل الملف بنجاح';

//   @override
//   String get failedToMoveFile => 'فشل نقل الملف';

//   @override
//   String get noFiles => 'لا توجد ملفات';

//   @override
//   String get startAddingFiles => 'ابدأ بإضافة ملفات جديدة';

//   @override
//   String get viewedByAll => 'شوهد من الجميع';

//   @override
//   String get active => 'نشط';

//   @override
//   String get accessed => 'تم الوصول';

//   @override
//   String get completed => 'اكتمل';

//   @override
//   String get sharedBy => 'شاركه';

//   @override
//   String get moveToRoot => 'نقل إلى الجذر';

//   @override
//   String get moveToRootDescription => 'نقل المجلد إلى المجلد الرئيسي';

//   @override
//   String get selectFolderDescription => 'نقل إلى هذا المجلد';

//   @override
//   String get deleteFolder => 'حذف المجلد';

//   @override
//   String confirmDeleteFolder(String folderName) {
//     return 'هل أنت متأكد من حذف المجلد \'$folderName\'؟ سيتم حذف جميع الملفات والمجلدات الفرعية أيضاً.';
//   }

//   @override
//   String get folderIdNotAvailable => '❌ خطأ: معرف المجلد غير متوفر.';

//   @override
//   String folderDeletedSuccessfully(String folderName) {
//     return '✅ تم حذف المجلد \'$folderName\' بنجاح';
//   }

//   @override
//   String get errorDeletingFolder => '❌ حدث خطأ أثناء حذف المجلد';

//   @override
//   String errorDeletingFolderWithError(String error) {
//     return '❌ حدث خطأ أثناء حذف المجلد: $error';
//   }

//   @override
//   String folderRestoredSuccessfully(String folderName) {
//     return '✅ تم استعادة المجلد \'$folderName\' بنجاح';
//   }

//   @override
//   String get errorRestoringFolder => '❌ حدث خطأ أثناء استعادة المجلد';

//   @override
//   String errorRestoringFolderWithError(String error) {
//     return '❌ حدث خطأ أثناء استعادة المجلد: $error';
//   }

//   @override
//   String get confirmPermanentDelete => 'تأكيد الحذف النهائي';

//   @override
//   String confirmPermanentDeleteFolder(String folderName) {
//     return 'هل أنت متأكد من الحذف النهائي للمجلد \'$folderName\'؟ لا يمكن التراجع عن هذا الإجراء. سيتم حذف جميع الملفات والمجلدات الفرعية نهائياً.';
//   }

//   @override
//   String get permanentDelete => 'حذف نهائي';

//   @override
//   String folderPermanentlyDeletedSuccessfully(String folderName) {
//     return '✅ تم الحذف النهائي للمجلد \'$folderName\' بنجاح';
//   }

//   @override
//   String get errorPermanentlyDeletingFolder => '❌ حدث خطأ أثناء الحذف النهائي للمجلد';

//   @override
//   String errorPermanentlyDeletingFolderWithError(String error) {
//     return '❌ حدث خطأ أثناء الحذف النهائي للمجلد: $error';
//   }

//   @override
//   String get cannotIdentifyFolder => '❌ خطأ: لا يمكن تحديد المجلد';

//   @override
//   String get downloadingFolder => 'جاري تحميل المجلد...';

//   @override
//   String folderDownloadedSuccessfully(String fileName) {
//     return '✅ تم تحميل المجلد بنجاح: $fileName';
//   }

//   @override
//   String get failedToDownloadFolder => 'فشل تحميل المجلد';

//   @override
//   String errorDownloadingFolder(String error) {
//     return '❌ خطأ في تحميل المجلد: $error';
//   }

//   @override
//   String get pleaseEnter6DigitCode => 'الرجاء إدخال رمز التحقق المكون من 6 أرقام';

//   @override
//   String get accountActivatedSuccessfully => '✅ تم تفعيل الحساب بنجاح';

//   @override
//   String get invalidVerificationCode => 'رمز التحقق غير صحيح';

//   @override
//   String pleaseWaitBeforeResend(int seconds) {
//     return 'الرجاء الانتظار $seconds ثانية قبل إعادة الإرسال';
//   }

//   @override
//   String get verificationCodeSent => '✅ تم إرسال رمز التحقق بنجاح';

//   @override
//   String get failedToResendCode => '❌ فشل إعادة إرسال رمز التحقق';

//   @override
//   String get emailVerification => 'التحقق من البريد الإلكتروني';

//   @override
//   String verificationCodeSentTo(String email) {
//     return 'تم إرسال رمز التحقق إلى $email';
//   }

//   @override
//   String get didNotReceiveCode => 'لم تستلم الرمز؟';

//   @override
//   String resendWithCountdown(int seconds) {
//     return 'إعادة الإرسال ($seconds)';
//   }

//   @override
//   String get resend => 'إعادة الإرسال';

//   @override
//   String get openFileAsText => 'فتح الملف كنص';

//   @override
//   String get fileLinkNotAvailable => 'رابط الملف غير متوفر';

//   @override
//   String get failedToCreateTempFile => 'فشل إنشاء ملف مؤقت';

//   @override
//   String failedToLoadFileStatus(String error) {
//     return 'فشل تحميل حالة الملف: $error';
//   }

//   @override
//   String errorOpeningFile(String error) {
//     return 'خطأ في فتح الملف: $error';
//   }

//   @override
//   String fileNotAvailableError(String error) {
//     return 'الملف غير متوفر: $error';
//   }

//   @override
//   String errorLoadingFile(String error) {
//     return 'خطأ في تحميل الملف: $error';
//   }

//   @override
//   String get fileNotValidPdf => 'الملف ليس ملف PDF صالح';

//   @override
//   String get createNewShareRoom => 'إنشاء غرفة مشاركة جديدة';

//   @override
//   String get pleaseEnterRoomName => 'الرجاء إدخال اسم الغرفة';

//   @override
//   String searchError(String error) {
//     return 'خطأ في البحث: $error';
//   }

//   @override
//   String get folderInfo => 'معلومات المجلد';

//   @override
//   String get loadMore => 'تحميل المزيد';

//   @override
//   String get filesCount => 'عدد الملفات';

//   @override
//   String get subfoldersCount => 'عدد المجلدات الفرعية';

//   @override
//   String get creationDate => 'تاريخ الإنشاء';

//   @override
//   String get featureUnderDevelopment => 'هذه الميزة قيد التطوير';

//   @override
//   String get folderWithoutName => 'مجلد بدون اسم';

//   @override
//   String get movingFolder => 'جاري نقل المجلد...';

//   @override
//   String errorFetchingSubfolders(String error) {
//     return 'خطأ في جلب المجلدات الفرعية: $error';
//   }

//   @override
//   String get moveFolderToRoot => 'نقل المجلد إلى الجذر';

//   @override
//   String get rejectInvitation => 'رفض الدعوة';

//   @override
//   String get confirmRejectInvitation => 'هل أنت متأكد من رفض هذه الدعوة؟';

//   @override
//   String get reject => 'رفض';

//   @override
//   String get pendingInvitations => 'الدعوات المعلقة';

//   @override
//   String get accept => 'قبول';

//   @override
//   String get pleaseSelectFileOrFolder => 'الرجاء اختيار ملف أو مجلد';

//   @override
//   String get deleteComment => 'حذف التعليق';

//   @override
//   String get confirmDeleteComment => 'هل أنت متأكد من حذف هذا التعليق؟';

//   @override
//   String get room => 'الغرفة';

//   @override
//   String get errorLoadingRoomDetails => 'خطأ في تحميل تفاصيل الغرفة';

//   @override
//   String get failedToLoadRoomDetails => 'فشل تحميل تفاصيل الغرفة';

//   @override
//   String get pleaseLoginAgain => 'يرجى إعادة تسجيل الدخول';

//   @override
//   String get deleteRoomConfirm => 'هل أنت متأكد من حذف هذه الغرفة؟ سيتم حذف جميع الملفات والمجلدات المشتركة أيضاً.';

//   @override
//   String get confirmRemoveFileFromRoom => 'هل أنت متأكد من إزالة هذا الملف من الغرفة؟';

//   @override
//   String get removeFolderFromRoom => 'إزالة المجلد من الغرفة';

//   @override
//   String get confirmRemoveFolderFromRoom => 'هل أنت متأكد من إزالة هذا المجلد من الغرفة؟';

//   @override
//   String confirmRemoveFolderFromRoomWithName(String folderName) {
//     return 'هل أنت متأكد من إزالة المجلد \'$folderName\' من الغرفة؟';
//   }

//   @override
//   String get savingFolder => 'جاري حفظ المجلد...';

//   @override
//   String get saveToRoot => 'حفظ في الجذر';

//   @override
//   String get failedToLoadRoomData => 'فشل تحميل بيانات الغرفة';

//   @override
//   String get noSharedFiles => 'لا توجد ملفات مشتركة';

//   @override
//   String get shareFilesWithRoom => 'مشاركة الملفات مع الغرفة';

//   @override
//   String get createNewFolder => 'إنشاء مجلد جديد';

//   @override
//   String get pleaseEnterFolderName => 'الرجاء إدخال اسم المجلد';

//   @override
//   String folderCreatedSuccessfully(String folderName) {
//     return 'تم إنشاء المجلد بنجاح: $folderName';
//   }

//   @override
//   String get failedToCreateFolder => 'فشل إنشاء المجلد';

//   @override
//   String get removeMember => 'إزالة العضو';

//   @override
//   String get confirmRemoveMember => 'هل أنت متأكد من إزالة هذا العضو من الغرفة؟';

//   @override
//   String get roomMembers => 'أعضاء الغرفة';

//   @override
//   String get viewOnly => 'عرض فقط';

//   @override
//   String get viewOnlyDescription => 'يمكن للمستخدم عرض الملفات فقط';

//   @override
//   String get editor => 'محرر';

//   @override
//   String get editorDescription => 'يمكن للمستخدم تحرير الملفات';

//   @override
//   String get commenter => 'معلق';

//   @override
//   String get commenterDescription => 'يمكن للمستخدم التعليق على الملفات';

//   @override
//   String get shareFolderWithRoom => 'مشاركة المجلد مع الغرفة';

//   @override
//   String get shareWithThisRoom => 'مشاركة مع هذه الغرفة';

//   @override
//   String get mustAllowPhotosAccess => 'يجب السماح بالوصول إلى الصور';

//   @override
//   String get profileImageUploadedSuccessfully => '✅ تم رفع صورة الملف الشخصي بنجاح';

//   @override
//   String get failedToUploadProfileImage => '❌ فشل رفع صورة الملف الشخصي';

//   @override
//   String errorUploadingProfileImage(String error) {
//     return '❌ خطأ في رفع صورة الملف الشخصي: $error';
//   }

//   @override
//   String get mustAllowCameraAccess => 'يجب السماح بالوصول إلى الكاميرا';

//   @override
//   String get unknownError => 'خطأ غير معروف';

//   @override
//   String get chooseFromGallery => 'اختر من المعرض';

//   @override
//   String get takePhotoFromCamera => 'التقط صورة من الكاميرا';

//   @override
//   String get used => 'مستخدم';

//   @override
//   String get microphonePermissionRequired => 'إذن الميكروفون مطلوب';

//   @override
//   String get openSettings => 'فتح الإعدادات';

//   @override
//   String get permissionDenied => 'تم رفض الإذن';

//   @override
//   String get mustAllowMicrophoneAccess => 'يجب السماح بالوصول إلى الميكروفون';

//   @override
//   String get speechRecognitionNotAvailable => 'التعرف على الصوت غير متاح';

//   @override
//   String get enterSearchText => 'أدخل نص البحث';

//   @override
//   String get smartSearch => 'البحث الذكي';

//   @override
//   String get fileLinkNotAvailableNoPath => 'رابط الملف غير متوفر (لا يوجد مسار)';

//   @override
//   String errorLoadingTextFile(String error) {
//     return 'خطأ في تحميل ملف النص: $error';
//   }

//   @override
//   String get activityLog => 'سجل النشاط';

//   @override
//   String get previous => 'السابق';

//   @override
//   String get next => 'التالي';

//   @override
//   String get filterActivity => 'تصفية النشاط';

//   @override
//   String get allActivities => 'جميع الأنشطة';

//   @override
//   String get uploadFile => 'رفع ملف';

//   @override
//   String get downloadFile => 'تحميل ملف';

//   @override
//   String get shareFile => 'مشاركة ملف';

//   @override
//   String get login => 'تسجيل الدخول';

//   @override
//   String get userLabel => 'المستخدم';

//   @override
//   String get system => 'النظام';

//   @override
//   String get roomLabel => 'الغرفة';

//   @override
//   String get reset => 'إعادة تعيين';

//   @override
//   String get logoutSuccess => '✅ تم تسجيل الخروج بنجاح';

//   @override
//   String get tokenNotFound => '❌ خطأ: لم يتم العثور على الرمز المميز';

//   @override
//   String get trash => 'المهملات';

//   @override
//   String get deletedFiles => 'الملفات المحذوفة';

//   @override
//   String get deletedFolders => 'المجلدات المحذوفة';

//   @override
//   String get profile => 'الملف الشخصي';

//   @override
//   String get editUsername => 'تعديل اسم المستخدم';

//   @override
//   String get editEmail => 'تعديل البريد الإلكتروني';

//   @override
//   String get fieldRequired => 'هذا الحقل مطلوب';

//   @override
//   String get validEmailRequired => 'البريد الإلكتروني غير صحيح';

//   @override
//   String get updatedSuccessfully => '✅ تم التحديث بنجاح';

//   @override
//   String get changePassword => 'تغيير كلمة المرور';

//   @override
//   String get currentPassword => 'كلمة المرور الحالية';

//   @override
//   String get currentPasswordRequired => 'كلمة المرور الحالية مطلوبة';

//   @override
//   String get newPassword => 'كلمة المرور الجديدة';

//   @override
//   String get newPasswordRequired => 'كلمة المرور الجديدة مطلوبة';

//   @override
//   String get passwordMinLength => 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';

//   @override
//   String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

//   @override
//   String get passwordConfirmationRequired => 'تأكيد كلمة المرور مطلوب';

//   @override
//   String get passwordUpdatedSuccessfully => '✅ تم تحديث كلمة المرور بنجاح';

//   @override
//   String get favoriteFiles => 'الملفات المفضلة';

//   @override
//   String get noFavoriteFiles => 'لا توجد ملفات مفضلة';

//   @override
//   String get addFilesToFavorites => 'أضف الملفات إلى المفضلة';
// }
