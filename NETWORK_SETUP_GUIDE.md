# 🌐 دليل إعداد الشبكة - Network Setup Guide

## 📋 جدول المحتويات
1. [فهم المشكلة](#فهم-المشكلة)
2. [الحل 1: ngrok (موصى به)](#الحل-1-ngrok-موصى-به)
3. [الحل 2: IP محلي (نفس الشبكة)](#الحل-2-ip-محلي-نفس-الشبكة)
4. [الحل 3: Android Emulator](#الحل-3-android-emulator)
5. [استكشاف الأخطاء](#استكشاف-الأخطاء)

---

## 🔍 فهم المشكلة

### المشكلة الأساسية:
عند تطوير تطبيق Flutter مع Backend (Node.js/Express):
- ❌ **localhost** لا يعمل على التلفون (localhost = الجهاز نفسه)
- ❌ **IP ثابت** لا يعمل على أجهزة مختلفة
- ❌ **نقل الكود** لجهاز آخر يحتاج تعديل IP في كل مرة

### الحلول المتاحة:

| الحل | متى تستخدمه | سهولة الاستخدام |
|-----|-------------|-----------------|
| **ngrok** | اختبار على أي جهاز (حتى خارج الشبكة) | ⭐⭐⭐⭐⭐ |
| **IP محلي** | اختبار على نفس الشبكة WiFi فقط | ⭐⭐⭐ |
| **Emulator** | اختبار على Android Emulator فقط | ⭐⭐⭐⭐ |

---

## 🚀 الحل 1: ngrok (موصى به)

### ✅ المميزات:
- يعمل على **أي جهاز** (حتى خارج الشبكة المحلية)
- لا يحتاج تعديل الكود عند نقله لجهاز آخر
- سهل التشغيل والاستخدام
- **مجاني** للاستخدام الشخصي

### 📥 خطوة 1: تحميل ngrok

1. اذهب إلى: https://ngrok.com/download
2. حمّل ngrok لنظام Windows
3. فك الضغط عن الملف واحفظه في مكان سهل (مثال: `C:\ngrok\`)

### 🔑 خطوة 2: إعداد Auth Token

1. سجل حساب مجاني على: https://ngrok.com/signup
2. بعد التسجيل، انسخ الـ **Auth Token** من Dashboard
3. افتح CMD (Command Prompt) واكتب:

```bash
cd C:\ngrok
ngrok config add-authtoken YOUR_AUTH_TOKEN_HERE
```

### 🎯 خطوة 3: تشغيل ngrok

في CMD، اكتب:

```bash
ngrok http 8000
```

**⚠️ ملاحظة**: إذا Backend شغّال على بورت مختلف، غيّر `8000` للبورت الصحيح.

**ستظهر لك شاشة مثل هذه:**

```
Session Status                online
Account                       your-email@gmail.com
Version                       3.x.x
Region                        United States (us)
Latency                       45ms
Web Interface                 http://127.0.0.1:4040
Forwarding                    https://abc123.ngrok-free.app -> http://localhost:8000

Connections                   ttl     opn     rt1     rt5     p50     p90
                              0       0       0.00    0.00    0.00    0.00
```

**✨ انسخ الـ URL**: `https://abc123.ngrok-free.app`

### 🔧 خطوة 4: تعديل Flutter Code

افتح: `lib/config/api_config.dart`

1. ابحث عن السطر:
```dart
static const String _ngrokURL = 'https://your-url-here.ngrok-free.app';
```

2. غيّره لـ:
```dart
static const String _ngrokURL = 'https://abc123.ngrok-free.app';
```
(استخدم الـ URL اللي ngrok عطاك إياه)

3. ابحث عن السطر:
```dart
static const bool _useNgrok = false;
```

4. غيّره لـ:
```dart
static const bool _useNgrok = true;
```

### ✅ خطوة 5: اختبار

1. تأكد أن Backend شغّال:
```bash
cd C:\Users\youse\Downloads\Filevo_Backend
node server.js
```

2. تأكد أن ngrok شغّال (CMD مفتوح ويعرض Forwarding)

3. شغل Flutter App:
```bash
flutter run
```

4. افتح التطبيق على التلفون - يجب أن يعمل! 🎉

### 📝 ملاحظات مهمة:

#### ⚠️ ngrok URL يتغير كل مرة
- عند إعادة تشغيل ngrok، ستحصل على URL جديد
- لازم تعدل `_ngrokURL` في الكود كل مرة
- **الحل**: استخدم ngrok مدفوع للحصول على URL ثابت (اختياري)

#### ⚠️ ngrok Warning Screen
بعض المتصفحات قد تظهر شاشة تحذير من ngrok:
- اضغط "Visit Site" للمتابعة
- هذا طبيعي للحسابات المجانية

---

## 📱 الحل 2: IP محلي (نفس الشبكة)

### متى تستخدمه؟
- عندما الكمبيوتر والتلفون على **نفس الشبكة WiFi**
- للاختبار السريع المحلي فقط
- **لا يعمل** إذا كان التلفون على شبكة مختلفة

### 🔍 خطوة 1: اكتشف IP جهازك

#### على Windows:
```bash
ipconfig
```

ابحث عن:
```
Wireless LAN adapter Wi-Fi:
   IPv4 Address. . . . . . . . . . . : 192.168.0.81
```

#### على Mac:
```bash
ifconfig | grep "inet "
```

#### على Linux:
```bash
hostname -I
```

### 🔧 خطوة 2: تعديل Flutter Code

افتح: `lib/config/api_config.dart`

1. ابحث عن:
```dart
static const String _localIP = '192.168.0.81';
```

2. غيّره لـ IP جهازك:
```dart
static const String _localIP = '192.168.1.100';  // مثال
```

3. تأكد أن:
```dart
static const bool _useNgrok = false;
static const bool _useEmulator = false;
```

### 🔥 خطوة 3: إعدادات Firewall

على Windows، لازم تسمح للتطبيق بالاتصال:

1. ابحث عن "Windows Defender Firewall"
2. اختر "Allow an app through firewall"
3. ابحث عن "Node.js" أو "node.exe"
4. فعّل الخيارات:
   - ✅ Private networks
   - ✅ Public networks

### ✅ خطوة 4: اختبار

1. تأكد أن الكمبيوتر والتلفون على **نفس WiFi**
2. شغل Backend:
```bash
node server.js
```
3. شغل Flutter:
```bash
flutter run
```

### 📝 ملاحظات:

#### ⚠️ IP يتغير
- إذا أعدت تشغيل الراوتر، قد يتغير IP
- لازم تتحقق من IP كل مرة بـ `ipconfig`

#### ⚠️ لا يعمل على شبكات مختلفة
- إذا التلفون على Mobile Data → لن يعمل
- إذا التلفون على WiFi مختلف → لن يعمل
- **استخدم ngrok** في هذه الحالات

---

## 🖥️ الحل 3: Android Emulator

### متى تستخدمه؟
- للاختبار على Android Emulator فقط (ليس تلفون حقيقي)
- الأسهل للتطوير السريع

### 🔧 خطوة 1: تعديل Flutter Code

افتح: `lib/config/api_config.dart`

غيّر:
```dart
static const bool _useEmulator = true;
```

### 💡 الشرح:
- Android Emulator يستخدم IP خاص: `10.0.2.2`
- هذا الـ IP يشير إلى `localhost` على جهازك الحقيقي

---

## 🔧 استكشاف الأخطاء

### ❌ Connection Refused / Connection Timeout

**المشكلة**: التطبيق لا يستطيع الوصول للـ Backend

**الحلول:**

1. **تحقق من Backend**:
```bash
# تأكد أنه شغّال
curl http://localhost:8000/api/v1/
```

2. **تحقق من Firewall**:
   - Windows: أضف Node.js للـ firewall exceptions
   - Mac: System Preferences → Security & Privacy → Firewall

3. **تحقق من الشبكة**:
   - الكمبيوتر والتلفون على نفس WiFi؟
   - الـ IP صحيح؟ (جرب `ping 192.168.0.81` من التلفون)

### ❌ 404 Not Found

**المشكلة**: الـ URL غير صحيح

**الحل**:
- تأكد أن `baseUrl` في `api_config.dart` **لا يحتوي** على `/api/v1`
- الصحيح: `http://192.168.0.81:8000`
- الخطأ: `http://192.168.0.81:8000/api/v1`

### ❌ ngrok Warning Screen

**المشكلة**: يظهر تحذير عند فتح ngrok URL

**الحل**:
- اضغط "Visit Site"
- أو استخدم ngrok مدفوع (يزيل التحذير)

---

## 📊 جدول مقارنة الحلول

| الميزة | ngrok | IP محلي | Emulator |
|-------|------|---------|---------|
| سهولة الإعداد | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| يعمل خارج الشبكة | ✅ | ❌ | ❌ |
| يعمل على نفس الشبكة | ✅ | ✅ | ❌ |
| لا يحتاج تعديل عند نقل الكود | ⚠️ (URL يتغير) | ❌ (IP يتغير) | ✅ |
| سرعة الاتصال | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| مجاني | ✅ | ✅ | ✅ |

---

## 🎯 التوصيات

### للتطوير اليومي:
- استخدم **Android Emulator** (الأسرع والأسهل)
- أو استخدم **IP محلي** إذا كنت تختبر على تلفون حقيقي

### للاختبار مع فريق:
- استخدم **ngrok** (يسمح للجميع بالوصول)

### للإنتاج:
- استخدم **domain حقيقي** (مثل: api.yourapp.com)
- استضف Backend على خادم حقيقي (AWS, DigitalOcean, etc.)

---

## 📞 الدعم

إذا واجهتك مشاكل:
1. تأكد من البورت الصحيح (`8000` أو غيره)
2. تأكد من Firewall settings
3. جرب `ping` للـ IP من التلفون
4. تحقق من Flutter logs: `flutter run -v`

---

**آخر تحديث**: 2026-01-18
