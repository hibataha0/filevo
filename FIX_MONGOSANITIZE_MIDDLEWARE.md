# 🔧 إصلاح ملف mongoSanitize.js في Backend

## المشكلة
الخطأ يحدث في:
```
C:\Users\youse\Downloads\Filevo_Backend\middlewares\mongoSanitize.js:89:3
```

الخطأ: `Cannot set property query of #<IncomingMessage> which has only a getter`

## السبب
الملف `middlewares\mongoSanitize.js` يحاول تعديل `req.query` مباشرة، لكن في إصدارات حديثة من Express، `query` هو getter فقط ولا يمكن تعديله.

## الحل

### الخطوة 1: افتح ملف mongoSanitize.js

افتح الملف:
```
C:\Users\youse\Downloads\Filevo_Backend\middlewares\mongoSanitize.js
```

### الخطوة 2: ابحث عن السطر الذي يحاول تعديل req.query

ابحث عن شيء مثل:
```javascript
req.query = sanitizedQuery; // ❌ هذا خطأ
```

أو:
```javascript
Object.keys(req.query).forEach(key => {
  req.query[key] = sanitizedValue; // ❌ هذا خطأ
});
```

### الخطوة 3: استبدل الكود بالحل الصحيح

**الحل 1: استخدام Object.assign (موصى به)**

```javascript
// ❌ بدلاً من:
req.query = sanitizedQuery;

// ✅ استخدم:
Object.assign(req.query, sanitizedQuery);
```

**الحل 2: إنشاء كائن جديد (إذا كان الحل 1 لا يعمل)**

```javascript
// ❌ بدلاً من:
req.query = sanitizedQuery;

// ✅ استخدم:
const originalQuery = req.query;
req.query = Object.assign({}, originalQuery, sanitizedQuery);
```

**الحل 3: استخدام Object.defineProperty (للحالات المعقدة)**

```javascript
// إذا كان الكود معقد، استخدم:
const sanitized = {};
Object.keys(req.query).forEach(key => {
  sanitized[key] = sanitizeValue(req.query[key]);
});

// بدلاً من تعديل req.query مباشرة، استخدم:
Object.keys(sanitized).forEach(key => {
  if (req.query.hasOwnProperty(key)) {
    Object.defineProperty(req.query, key, {
      value: sanitized[key],
      writable: true,
      enumerable: true,
      configurable: true
    });
  }
});
```

### الخطوة 4: مثال كامل للملف

إذا كان الملف يبدو هكذا:

```javascript
// ❌ الكود القديم (خطأ)
module.exports = function mongoSanitize(req, res, next) {
  const sanitizedQuery = {};
  Object.keys(req.query).forEach(key => {
    sanitizedQuery[key] = sanitize(req.query[key]);
  });
  req.query = sanitizedQuery; // ❌ خطأ هنا
  next();
};
```

استبدله بـ:

```javascript
// ✅ الكود الجديد (صحيح)
module.exports = function mongoSanitize(req, res, next) {
  const sanitizedQuery = {};
  Object.keys(req.query).forEach(key => {
    sanitizedQuery[key] = sanitize(req.query[key]);
  });
  
  // ✅ حل صحيح - استخدام Object.assign
  Object.assign(req.query, sanitizedQuery);
  
  // أو إذا كان req.query فارغاً في البداية:
  // Object.keys(sanitizedQuery).forEach(key => {
  //   req.query[key] = sanitizedQuery[key];
  // });
  
  next();
};
```

### الخطوة 5: بديل - استخدام express-mongo-sanitize مباشرة

إذا كان الملف معقد، يمكنك استخدام المكتبة مباشرة:

```javascript
const mongoSanitize = require('express-mongo-sanitize');

module.exports = mongoSanitize({
  replaceWith: '_',
  onSanitize: ({ req, key }) => {
    console.warn(`This request[${key}] is not allowed!`);
  },
});
```

## التحقق من الإصلاح

1. احفظ الملف
2. أعد تشغيل الـ Backend:
```bash
npm start
```
3. جرب تسجيل الدخول من Flutter app

## ملاحظات مهمة

- **لا تحذف الملف** - فقط أصلح السطر الذي يعدل `req.query`
- إذا كان الملف كبير ومعقد، ابحث عن جميع الأماكن التي تحتوي على `req.query =`
- تأكد من أن `next()` موجود بعد التعديل






