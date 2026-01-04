# 🔧 إصلاح مشكلة عدم وصول كود التحقق من البريد الإلكتروني

## المشكلة
كود التحقق من البريد الإلكتروني لا يصل إلى المستخدم بعد التسجيل.

## الأسباب المحتملة

### 1. **مشكلة في إعدادات SMTP**
البريد الإلكتروني غير مُعد بشكل صحيح في الباك إند.

### 2. **مشكلة في دالة sendEmail**
دالة إرسال البريد الإلكتروني لا تعمل بشكل صحيح.

### 3. **مشكلة في متغيرات البيئة**
متغيرات البيئة (Environment Variables) غير مُعدة بشكل صحيح.

## الحلول

### الحل 1: التحقق من إعدادات SMTP

في ملف `.env` في الباك إند، تأكد من وجود:

```env
# إعدادات البريد الإلكتروني
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-password
EMAIL_FROM=noreply@filevo.com
```

**ملاحظات مهمة:**
- إذا كنت تستخدم Gmail، يجب استخدام **App Password** وليس كلمة المرور العادية
- يجب تفعيل **2-Step Verification** في Gmail أولاً
- ثم إنشاء App Password من: Google Account → Security → App passwords

### الحل 2: التحقق من دالة sendEmail

في ملف `utils/sendEmail.js` أو `services/emailService.js`:

```javascript
const nodemailer = require('nodemailer');

const sendEmail = async (options) => {
  // ✅ إنشاء transporter
  const transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: process.env.EMAIL_PORT,
    secure: false, // true for 465, false for other ports
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASSWORD,
    },
  });

  // ✅ خيارات البريد الإلكتروني
  const mailOptions = {
    from: `Filevo <${process.env.EMAIL_FROM}>`,
    to: options.email,
    subject: options.subject,
    text: options.message,
    html: options.html || options.message, // ✅ دعم HTML
  };

  // ✅ إرسال البريد الإلكتروني
  try {
    const info = await transporter.sendMail(mailOptions);
    console.log('✅ Email sent successfully:', info.messageId);
    return info;
  } catch (error) {
    console.error('❌ Error sending email:', error);
    throw error;
  }
};

module.exports = sendEmail;
```

### الحل 3: إضافة معالجة أفضل للأخطاء

في ملف `services/authService.js` في دالة `registerUser`:

```javascript
exports.registerUser = asyncHandler(async (req, res, next) => {
  // ✅ إنشاء المستخدم مع emailVerified = false
  const user = await User.create({
    name: req.body.name,
    email: req.body.email,
    password: req.body.password,
    emailVerified: false,
  });

  // ✅ توليد كود تحقق من 6 أرقام
  const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
  const hashedVerificationCode = crypto
    .createHash("sha256")
    .update(verificationCode)
    .digest("hex");

  // ✅ حفظ كود التحقق في قاعدة البيانات
  user.emailVerificationCode = hashedVerificationCode;
  user.emailVerificationExpires = Date.now() + 10 * 60 * 1000; // 10 دقائق
  await user.save();

  // ✅ إرسال كود التحقق عبر البريد الإلكتروني
  const message = `مرحباً ${user.name},\n\nشكراً لك على التسجيل في Filevo!\n\nكود التحقق من البريد الإلكتروني الخاص بك هو:\n${verificationCode}\n\nهذا الكود صالح لمدة 10 دقائق.\n\nإذا لم تطلب هذا الكود، يمكنك تجاهل هذه الرسالة.\n\nشكراً لك،\nفريق Filevo`;

  try {
    await sendEmail({
      email: user.email,
      subject: "كود التحقق من البريد الإلكتروني - Filevo",
      message,
    });
    
    console.log('✅ Verification code sent to:', user.email);
    console.log('📧 Verification code:', verificationCode); // ✅ للاختبار فقط - احذفه في الإنتاج
    
  } catch (err) {
    console.error('❌ Error sending email:', err);
    
    // ✅ في حالة فشل إرسال البريد، حذف الكود
    user.emailVerificationCode = undefined;
    user.emailVerificationExpires = undefined;
    await user.save();
    
    // ✅ إرجاع خطأ واضح
    return next(
      new ApiError(
        "حدث خطأ في إرسال البريد الإلكتروني. يرجى التحقق من إعدادات البريد الإلكتروني أو المحاولة مرة أخرى لاحقاً",
        500
      )
    );
  }

  // ✅ إرجاع رسالة نجاح بدون token (لأن الحساب غير مفعّل)
  res.status(201).json({
    success: true,
    message: "تم إنشاء الحساب بنجاح. يرجى التحقق من بريدك الإلكتروني لإدخال كود التحقق",
    userId: user._id,
    email: user.email,
    // ✅ للاختبار فقط - احذفه في الإنتاج
    // verificationCode: verificationCode,
  });
});
```

### الحل 4: استخدام خدمة بريد إلكتروني بديلة

إذا كان Gmail لا يعمل، يمكنك استخدام:

#### أ) **SendGrid**
```javascript
const sgMail = require('@sendgrid/mail');
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

const msg = {
  to: options.email,
  from: process.env.EMAIL_FROM,
  subject: options.subject,
  text: options.message,
  html: options.html || options.message,
};

await sgMail.send(msg);
```

#### ب) **Mailgun**
```javascript
const formData = require('form-data');
const Mailgun = require('mailgun.js');
const mailgun = new Mailgun(formData);

const mg = mailgun.client({
  username: 'api',
  key: process.env.MAILGUN_API_KEY,
});

await mg.messages.create(process.env.MAILGUN_DOMAIN, {
  from: process.env.EMAIL_FROM,
  to: [options.email],
  subject: options.subject,
  text: options.message,
  html: options.html || options.message,
});
```

#### ج) **Nodemailer مع SMTP آخر**
```javascript
// ✅ استخدام SMTP من مزود آخر مثل Outlook
const transporter = nodemailer.createTransport({
  host: 'smtp-mail.outlook.com',
  port: 587,
  secure: false,
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD,
  },
});
```

### الحل 5: إضافة Logging للتحقق

أضف logging في دالة `sendEmail`:

```javascript
const sendEmail = async (options) => {
  console.log('📧 Attempting to send email...');
  console.log('  - To:', options.email);
  console.log('  - Subject:', options.subject);
  console.log('  - Host:', process.env.EMAIL_HOST);
  console.log('  - Port:', process.env.EMAIL_PORT);
  console.log('  - User:', process.env.EMAIL_USER);
  
  const transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: process.env.EMAIL_PORT,
    secure: false,
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASSWORD,
    },
  });

  // ✅ التحقق من الاتصال
  try {
    await transporter.verify();
    console.log('✅ SMTP connection verified');
  } catch (error) {
    console.error('❌ SMTP verification failed:', error);
    throw new Error('SMTP connection failed: ' + error.message);
  }

  const mailOptions = {
    from: `Filevo <${process.env.EMAIL_FROM}>`,
    to: options.email,
    subject: options.subject,
    text: options.message,
    html: options.html || options.message,
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    console.log('✅ Email sent successfully');
    console.log('  - Message ID:', info.messageId);
    console.log('  - Response:', info.response);
    return info;
  } catch (error) {
    console.error('❌ Error sending email:', error);
    console.error('  - Error code:', error.code);
    console.error('  - Error command:', error.command);
    throw error;
  }
};
```

## خطوات التحقق

### 1. تحقق من متغيرات البيئة
```bash
# في terminal الباك إند
echo $EMAIL_HOST
echo $EMAIL_USER
echo $EMAIL_PASSWORD
```

### 2. اختبر إرسال بريد إلكتروني مباشرة
أنشئ ملف `test-email.js`:

```javascript
require('dotenv').config();
const sendEmail = require('./utils/sendEmail');

sendEmail({
  email: 'your-test-email@gmail.com',
  subject: 'Test Email',
  message: 'This is a test email',
})
  .then(() => console.log('✅ Email sent successfully'))
  .catch((err) => console.error('❌ Error:', err));
```

### 3. تحقق من Logs
راقب logs الباك إند عند التسجيل:
- هل يتم استدعاء `sendEmail`؟
- هل هناك أخطاء في SMTP؟
- هل يتم حفظ الكود في قاعدة البيانات؟

### 4. تحقق من Spam Folder
تأكد من فحص مجلد الرسائل غير المرغوب فيها (Spam).

## حلول سريعة للاختبار

### الحل السريع 1: طباعة الكود في Console
للاختبار فقط، يمكنك طباعة الكود في console:

```javascript
console.log('📧 Verification code:', verificationCode);
```

### الحل السريع 2: إرجاع الكود في Response (للاختبار فقط)
```javascript
res.status(201).json({
  success: true,
  message: "تم إنشاء الحساب بنجاح",
  userId: user._id,
  email: user.email,
  verificationCode: verificationCode, // ✅ للاختبار فقط
});
```

**⚠️ تحذير:** احذف هذا في الإنتاج!

## الخلاصة

1. ✅ تحقق من إعدادات SMTP في `.env`
2. ✅ تأكد من استخدام App Password إذا كنت تستخدم Gmail
3. ✅ أضف logging للتحقق من الأخطاء
4. ✅ اختبر إرسال بريد إلكتروني مباشرة
5. ✅ تحقق من logs الباك إند

إذا استمرت المشكلة، جرب استخدام خدمة بريد إلكتروني بديلة مثل SendGrid أو Mailgun.











