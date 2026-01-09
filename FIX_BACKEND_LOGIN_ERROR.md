# 🔧 إصلاح خطأ تسجيل الدخول في Backend

## المشكلة
```
Cannot set property query of #<IncomingMessage> which has only a getter
at express-mongo-sanitize\index.js:113:18
```

## السبب
المشكلة في `express-mongo-sanitize` - يحاول تعديل `req.query` لكن في إصدارات حديثة من Express، `query` هو getter فقط.

## الحلول

### الحل 1: تحديث express-mongo-sanitize (موصى به)

1. افتح terminal في مجلد Backend:
```bash
cd C:\Users\youse\Downloads\Filevo_Backend
```

2. قم بتحديث express-mongo-sanitize:
```bash
npm update express-mongo-sanitize
```

أو قم بتثبيت أحدث إصدار:
```bash
npm install express-mongo-sanitize@latest
```

### الحل 2: تغيير ترتيب الـ Middleware

في ملف server.js أو app.js الرئيسي، تأكد من أن `express-mongo-sanitize` يأتي **بعد** `body-parser`:

```javascript
const express = require('express');
const mongoSanitize = require('express-mongo-sanitize');
const bodyParser = require('body-parser');

const app = express();

// ✅ ترتيب صحيح:
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(mongoSanitize()); // ✅ بعد body-parser

// ❌ ترتيب خاطئ:
// app.use(mongoSanitize()); // ❌ قبل body-parser
// app.use(bodyParser.json());
```

### الحل 3: استخدام إصدار محدد

إذا استمرت المشكلة، استخدم إصدار محدد يعمل:

```bash
npm install express-mongo-sanitize@2.2.0
```

### الحل 4: إزالة express-mongo-sanitize مؤقتاً (للاختبار فقط)

إذا كنت تريد اختبار سريع، يمكنك تعطيله مؤقتاً:

```javascript
// في server.js أو app.js
// app.use(mongoSanitize()); // ✅ علق هذا السطر مؤقتاً
```

**⚠️ تحذير:** لا تتركه معطلاً في الإنتاج! هذا فقط للاختبار.

## التحقق من الإصلاح

بعد تطبيق أي حل:

1. أعد تشغيل الـ Backend:
```bash
npm start
```

2. جرب تسجيل الدخول من Flutter app

3. تحقق من الـ console - يجب ألا يظهر الخطأ

## ملاحظات

- تأكد من أن جميع الـ dependencies محدثة:
```bash
npm update
```

- إذا استمرت المشكلة، تحقق من إصدار Express:
```bash
npm list express
```



















