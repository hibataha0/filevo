# 🔧 حل مشكلة عرض بيانات مستخدم خاطئ في Profile

## 🔍 المشكلة

عند تسجيل الدخول بمستخدم ثاني، صفحة البروفايل تعرض بيانات **المستخدم الأول** بدلاً من المستخدم الحالي.

---

## ✅ الحل الكامل (خطوة بخطوة)

### الخطوة 1️⃣: امسح كل البيانات القديمة

**على Android Emulator/تلفون:**

```bash
# امسح كل بيانات التطبيق
adb shell pm clear com.example.filevo

# أو يدوياً:
Settings → Apps → Filevo → Storage → Clear Data
```

**على iOS Simulator:**

```bash
# امسح التطبيق وأعد تثبيته
flutter clean
flutter run
```

---

### الخطوة 2️⃣: أعد تشغيل التطبيق

```bash
# أوقف التطبيق
q

# نظف
flutter clean

# أعد التشغيل
flutter run
```

---

### الخطوة 3️⃣: سجل دخول بالمستخدم الأول

1. افتح التطبيق
2. سجل دخول بالمستخدم الأول (مثلاً: `user1@example.com`)
3. افتح صفحة Profile
4. **راقب الـ Logs** في Terminal:

```
🎯 AuthController: Login successful! Starting cleanup...
🧹 [Step 1/5] Clearing old user cache...
🧹 [Step 2/5] Deleting old token...
🧹 [Step 3/5] Deleting old userId...
💾 [Step 4/5] Saving new token (length: 176)...
✅ [Step 5/5] New token verified and saved correctly!
```

5. **تحقق من البيانات** في Profile:

```
✅ ProfileController: User data extracted successfully!
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   📋 Full User Data:
   User ID: 693d973a4ef625acf0c899c5
   Name: user1
   Email: user1@example.com
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

✅ إذا ظهرت بيانات **user1** صحيحة → ممتاز! روح للخطوة التالية.

❌ إذا ظهرت بيانات **خاطئة** → شيك الـ logs وابحث عن أخطاء.

---

### الخطوة 4️⃣: سجل خروج

1. اذهب إلى **Settings**
2. اضغط **Logout**
3. **راقب الـ Logs**:

```
🧹 AuthController: Clearing user cache on logout...
🧹 [UserCacheService] Clearing cache...
   - Old cached data: exists
   - Old cache age: 2 minutes
✅ [UserCacheService] Cache cleared successfully!
🗑️ [StorageService] Deleting token...
   - Old token exists (length: 176)
✅ [StorageService] Token deleted successfully
🗑️ [StorageService] Deleting userId...
   - Old userId exists: 693d973a4e...
✅ [StorageService] UserId deleted successfully
🧹 AuthService: Token and userId deleted on logout
✅ AuthController: Logout completed
POST /api/v1/users/logout 200 - (الباك يرجع 200 ✅)
```

✅ إذا كل الـ logs صحيحة → ممتاز! روح للخطوة التالية.

❌ إذا Backend يرجع **404** أو **401** → المشكلة في الـ Backend endpoint.

---

### الخطوة 5️⃣: سجل دخول بالمستخدم الثاني

1. سجل دخول بالمستخدم الثاني (مثلاً: `user2@example.com`)
2. **راقب الـ Logs**:

```
🎯 AuthController: Login successful! Starting cleanup...
🧹 [Step 1/5] Clearing old user cache...
   - Old cached data: null  ← يجب أن يكون null!
🧹 [Step 2/5] Deleting old token...
✅ [Step 3/5] Old token deleted (or was already null)
🧹 [Step 4/5] Deleting old userId...
✅ [Step 5/5] Old userId deleted (or was already null)
💾 [Step 6/6] Saving new token (length: 180)...
✅ New token verified and saved correctly!
```

3. افتح صفحة **Profile**
4. **راقب الـ Logs**:

```
🔑 [UserService] Getting token from storage...
✅ [UserService] Token found (length: 180)
   Token preview: eyJhbGciOiJIUzI1NiIs...
📡 [UserService] Calling API: /api/v1/users/getMe
✅ [UserService] API returned user data:
   User ID: 6a1b2c3d4e5f6a7b8c9d0e1f  ← يجب أن يكون ID المستخدم الثاني!
   User Name: user2                    ← يجب أن يكون اسم المستخدم الثاني!
```

5. **تحقق من UI**:
   - الاسم المعروض: `user2` ✅
   - الإيميل المعروض: `user2@example.com` ✅

---

## 🔍 استكشاف الأخطاء

### ❌ المشكلة 1: Token لا يُحفظ

**Logs:**
```
⚠️ WARNING: No token in login response!
```

**الحل:**
- تأكد من أن الـ Backend يرجع `token` في الـ response
- تحقق من endpoint: `/api/v1/auth/login`

---

### ❌ المشكلة 2: Backend يرجع بيانات خاطئة

**Logs:**
```
✅ [UserService] API returned user data:
   User ID: 693d973a4ef625acf0c899c5  ← هذا ID المستخدم الأول!
   User Name: user1                    ← هذا اسم المستخدم الأول!
```

**الحل:**
- المشكلة في الـ **Backend**!
- تحقق من:
  1. التوكن يُفك بشكل صحيح (decode JWT)
  2. `req.user` يشير للمستخدم الصحيح
  3. Middleware `protect` يعمل صح

---

### ❌ المشكلة 3: Logout endpoint يرجع 404

**Logs:**
```
POST /api/v1/auth/logout 404
```

**الحل:**
- تأكد من أن الـ endpoint صحيح: `/api/v1/users/logout` (مش `/auth/logout`)
- أو عدّل `api_endpoints.dart`:
  ```dart
  static const String logout = '$_basePath/users/logout';
  ```

---

### ❌ المشكلة 4: Cache لا يُمسح

**Logs:**
```
🧹 [UserCacheService] Clearing cache...
   - Old cached data: exists  ← يجب أن يُمسح!
```

**الحل:**
- تأكد من أن `clearCache()` يُستدعى في:
  1. `login()` - قبل حفظ التوكن الجديد
  2. `logout()` - قبل حذف التوكن
- أعد تشغيل التطبيق من الصفر

---

## 📊 النتيجة النهائية

### ✅ المتوقع:

| الحالة | المستخدم المعروض |
|--------|------------------|
| Login User 1 | ✅ User 1 |
| Logout | - |
| Login User 2 | ✅ User 2 |
| Logout | - |
| Login User 1 | ✅ User 1 |

### ❌ المشكلة (قبل الحل):

| الحالة | المستخدم المعروض |
|--------|------------------|
| Login User 1 | ✅ User 1 |
| Logout | - |
| Login User 2 | ❌ User 1 (خطأ!) |

---

## 🆘 إذا لسه في مشكلة

**أرسل الـ Logs الكاملة** من:
1. عند تسجيل الدخول (من `🎯 AuthController` إلى `✅ New token verified`)
2. عند تسجيل الخروج (من `🧹 Clearing cache` إلى `POST /api/v1/users/logout`)
3. عند فتح Profile (من `🔑 Getting token` إلى `✅ User data extracted`)

---

**آخر تحديث**: 2026-01-18
