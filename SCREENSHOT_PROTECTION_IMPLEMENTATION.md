# 🔒 تطبيق حماية السكرين شوت للملفات المشتركة لمرة واحدة

## ✅ التغييرات المطبقة

### 1️⃣ **إضافة parameter `isOneTimeShare` للـ Viewers:**

#### ✅ ImageViewer
**الملف:** `lib/views/fileViewer/imageViewer.dart`
- ✅ أضفنا `final bool isOneTimeShare` parameter
- ✅ في `initState()`: تفعيل الحماية إذا `isOneTimeShare == true`
- ✅ في `dispose()`: إلغاء الحماية

```dart
if (widget.isOneTimeShare) {
  ScreenProtectionService.enableProtection();
}
```

#### ✅ OfficeFileViewer
**الملف:** `lib/views/fileViewer/office_file_viewer.dart`
- ✅ أضفنا `final bool isOneTimeShare` parameter
- ✅ في `initState()`: تفعيل الحماية إذا `isOneTimeShare == true`
- ✅ في `dispose()`: إلغاء الحماية

---

### 2️⃣ **تمرير `isOneTimeShare` عند فتح الملفات:**

#### ✅ في `room_files_page.dart`

**في دالة `_openFileViaEndpoint()` (السطر 238-309):**
- ✅ استخراج `isOneTimeShare` من `fileData`
- ✅ تمريره لـ:
  - `PdfViewerPage` (السطر 247)
  - `VideoViewer` (السطر 259)
  - `ImageViewer` (السطر 277) ← **تم إلغاء الـ comment!**
  - `TextViewerPage` (السطر 292)
  - `AudioPlayerPage` (السطر 304)

**في دالة `_openFile()` (السطر 396 وما بعد):**
- ✅ استخراج `isOneTimeShare` من `fileEntry`
- ✅ تمريره لـ:
  - `PdfViewerPage` (السطر 646)
  - `VideoViewer` (السطر 656)
  - `ImageViewer` (السطر 680)
  - `TextViewerPage` (السطر 704)
  - `AudioPlayerPage` (السطر 721)

---

#### ✅ في `room_details_page.dart`

**في دالة `_openFileViaEndpoint()` (السطر 1807-1871):**
- ✅ استخراج `isOneTimeShare` من `fileData`
- ✅ تمريره لـ:
  - `PdfViewerPage` (السطر 1814)
  - `VideoViewer` (السطر 1823)
  - `ImageViewer` (السطر 1837)
  - `TextViewerPage` (السطر 1852)
  - `AudioPlayerPage` (السطر 1862)

**في دالة `_openAsTextFile()` (السطر 2134):**
- ✅ إضافة parameter `bool isOneTimeShare = false`
- ✅ تمريره لـ `TextViewerPage`

---

## 📊 ملخص الـ Viewers المحمية:

| Viewer | الملف | حماية السكرين شوت |
|--------|------|------------------|
| **📄 PDF Viewer** | `pdfViewer.dart` | ✅ محمي (قبل التحديث) |
| **📝 Text Viewer** | `textViewer.dart` | ✅ محمي (قبل التحديث) |
| **🎥 Video Viewer** | `VideoViewer.dart` | ✅ محمي (قبل التحديث) |
| **🎵 Audio Player** | `audioPlayer.dart` | ✅ محمي (قبل التحديث) |
| **🖼️ Image Viewer** | `imageViewer.dart` | ✅ محمي (بعد التحديث) |
| **📊 Office Viewer** | `office_file_viewer.dart` | ✅ محمي (بعد التحديث) |

---

## 🔧 كيف تعمل الحماية؟

### الـ Backend:
1. عند مشاركة ملف في روم، يتم تحديد إذا كان `isOneTimeShare: true`
2. الـ Backend يتتبع `accessedBy` (من فتح الملف)
3. الملف يُحذف تلقائياً بعد أن يفتحه كل الأعضاء أو بعد انتهاء المدة

### الـ Frontend:
1. عند فتح ملف من الروم، يتم استخراج `isOneTimeShare` من `fileData`
2. يتم تمرير `isOneTimeShare` للـ Viewer
3. إذا كان `true`، الـ Viewer يستدعي `ScreenProtectionService.enableProtection()`
4. هذا يفعّل `FLAG_SECURE` في Android → **يمنع السكرين شوت والريكورد**
5. عند إغلاق الـ Viewer، يتم استدعاء `ScreenProtectionService.disableProtection()`

---

## 📱 المكتبة المستخدمة:

```yaml
dependencies:
  flutter_windowmanager: ^0.2.0
```

**ملاحظة:** هذه المكتبة تعمل **فقط على Android**. على iOS، يحتاج تطبيق native code إضافي.

---

## ✅ النتيجة النهائية:

- ✅ **كل الـ Viewers** (PDF, Text, Video, Audio, Image, Office) الآن محمية من السكرين شوت
- ✅ الحماية تعمل **فقط** للملفات المشتركة لمرة واحدة (`isOneTimeShare: true`)
- ✅ الملفات العادية تبقى قابلة لأخذ screenshot بشكل طبيعي
- ✅ الكود organized ومتناسق في كل الـ viewers

---

**آخر تحديث:** 2026-01-18
