# ✅ التعديل النهائي: إرسال كود التحقق تلقائياً عند تسجيل الدخول

## ملخص التعديلات

تم تعديل دالة `login` في الباك إند لإرسال كود التحقق تلقائياً عند محاولة تسجيل الدخول بحساب غير مفعّل.

## التعديلات في الباك إند

### ملف: `services/authService.js`

#### دالة `login` - التعديل:

```javascript
exports.login = asyncHandler(async (req, res, next) => {
  const user = await User.findOne({ email: req.body.email });

  if (!user || !(await bcrypt.compare(req.body.password, user.password))) {
    return next(
      new ApiError("البريد الإلكتروني أو كلمة المرور غير صحيحة", 401)
    );
  }

  // ✅ التحقق من أن البريد الإلكتروني مفعّل
  if (!user.emailVerified) {
    // ✅ إذا كان الحساب غير مفعّل، إرسال كود التحقق تلقائياً
    const verificationCode = Math.floor(
      100000 + Math.random() * 900000
    ).toString();

    const hashedVerificationCode = crypto
      .createHash("sha256")
      .update(verificationCode)
      .digest("hex");

    // ✅ حفظ كود التحقق في قاعدة البيانات
    user.emailVerificationCode = hashedVerificationCode;
    user.emailVerificationExpires = Date.now() + 10 * 60 * 1000; // 10 دقائق
    await user.save();

    // ✅ إرسال كود التحقق عبر البريد الإلكتروني
    const message = `مرحباً ${user.name},\n\nتم محاولة تسجيل الدخول إلى حسابك في Filevo.\n\nكود التحقق من البريد الإلكتروني الخاص بك هو:\n${verificationCode}\n\nهذا الكود صالح لمدة 10 دقائق.\n\nيرجى إدخال هذا الكود لتفعيل حسابك وتسجيل الدخول.\n\nإذا لم تطلب هذا الكود، يمكنك تجاهل هذه الرسالة.\n\nشكراً لك،\nفريق Filevo`;

    try {
      await sendEmail({
        email: user.email,
        subject: "كود التحقق من البريد الإلكتروني - Filevo",
        message,
      });
    } catch (err) {
      // ✅ في حالة فشل إرسال البريد، حذف الكود
      user.emailVerificationCode = undefined;
      user.emailVerificationExpires = undefined;
      await user.save();
      return next(new ApiError("حدث خطأ في إرسال البريد الإلكتروني", 500));
    }

    // ✅ إرجاع رسالة تخبر المستخدم أنه تم إرسال الكود
    return res.status(403).json({
      success: false,
      message: "يرجى تفعيل حسابك أولاً. تم إرسال كود التحقق إلى بريدك الإلكتروني",
      email: user.email,
      requiresVerification: true,
    });
  }

  // ✅ إذا كان الحساب مفعّل، المتابعة بتسجيل الدخول العادي
  const token = createToken(user._id);
  delete user._doc.password;
  res.status(200).json({ data: user, token });
});
```

## التعديلات في Flutter

### ملف: `lib/controllers/auth/auth_controller.dart`

#### تحديث دالة `login`:

```dart
if (result['success'] == true) {
  // حفظ التوكن لو موجود
  if (result['token'] != null) {
    await StorageService.saveToken(result['token']);
  }
  return true;
} else {
  final errorMsg =
      result['error'] as String? ??
      result['message'] as String? ??
      'حدث خطأ غير معروف';

  // ✅ التحقق من requiresVerification في الـ response
  if (result['requiresVerification'] == true ||
      errorMsg.contains('تفعيل') ||
      errorMsg.contains('يرجى تفعيل')) {
    _needsEmailVerification = true;
    // ✅ استخدام email من الـ response إذا كان موجوداً
    _unverifiedEmail = result['email'] as String? ??
        (emailOrUsername.contains('@') ? emailOrUsername : null);
    
    if (_unverifiedEmail == null) {
      _unverifiedEmail = emailOrUsername;
    }
  }

  _setError(errorMsg);
  return false;
}
```

## سير العمل الكامل

### 1. المستخدم يحاول تسجيل الدخول بحساب غير مفعّل:

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

### 2. الباك إند يتحقق من:
- ✅ البريد الإلكتروني وكلمة المرور صحيحة
- ✅ الحساب غير مفعّل (`emailVerified: false`)

### 3. الباك إند يقوم بـ:
- ✅ توليد كود تحقق جديد (6 أرقام)
- ✅ حفظ الكود في قاعدة البيانات
- ✅ إرسال الكود إلى البريد الإلكتروني
- ✅ إرجاع response مع `requiresVerification: true`

### 4. Response من الباك إند:

```json
{
  "success": false,
  "message": "يرجى تفعيل حسابك أولاً. تم إرسال كود التحقق إلى بريدك الإلكتروني",
  "email": "user@example.com",
  "requiresVerification": true
}
```

### 5. Flutter يتعامل مع الـ response:
- ✅ يكتشف أن `requiresVerification: true`
- ✅ يحدد `needsEmailVerification = true`
- ✅ يحفظ `email` من الـ response
- ✅ يفتح صفحة إدخال كود التحقق تلقائياً

### 6. المستخدم يدخل الكود:
- ✅ يتم التحقق من الكود
- ✅ يتم تفعيل الحساب
- ✅ يتم حفظ token
- ✅ يتم تسجيل الدخول تلقائياً

## الميزات

### ✅ إرسال تلقائي للكود
- لا حاجة لطلب إعادة الإرسال يدوياً
- الكود يُرسل تلقائياً عند محاولة تسجيل الدخول

### ✅ تجربة مستخدم أفضل
- رسالة واضحة تخبر المستخدم أن الكود تم إرساله
- فتح صفحة التحقق تلقائياً

### ✅ أمان
- كود جديد في كل محاولة تسجيل دخول
- مدة صلاحية 10 دقائق
- حذف الكود في حالة فشل الإرسال

## التحقق من العمل

### 1. تحقق من Logs الباك إند:
```
📧 [sendEmail] Starting email sending process...
✅ [sendEmail] Email sent successfully
```

### 2. تحقق من Response:
```json
{
  "success": false,
  "requiresVerification": true,
  "email": "user@example.com"
}
```

### 3. تحقق من Flutter:
```
AuthController: Account needs email verification
AuthController: Unverified email: user@example.com
```

## ملاحظات مهمة

1. ✅ تأكد من أن `sendEmail` يعمل بشكل صحيح
2. ✅ تأكد من إعدادات SMTP في `.env`
3. ✅ تأكد من أن `requiresVerification` موجود في الـ response
4. ✅ تأكد من أن Flutter يتحقق من `requiresVerification`

## الخلاصة

✅ الباك إند: يرسل كود التحقق تلقائياً عند محاولة تسجيل الدخول بحساب غير مفعّل
✅ Flutter: يكتشف `requiresVerification` ويفتح صفحة التحقق تلقائياً
✅ تجربة مستخدم: سلسة وسهلة

التعديلات جاهزة للاستخدام! 🎉


















