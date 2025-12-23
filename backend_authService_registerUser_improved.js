// ✅ تحسين دالة registerUser في services/authService.js
// ✅ إضافة logging أفضل ومعالجة أخطاء محسّنة

const asyncHandler = require("express-async-handler");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const ApiError = require("../utils/apiError");
const createToken = require("../utils/createToken");
const User = require("../models/userModel");
const sendEmail = require("../utils/sendEmail");

// @desc    Register new user
// @route   POST /api/v1/auth/register
// @access  Public
exports.registerUser = asyncHandler(async (req, res, next) => {
  console.log('📝 [registerUser] Starting registration process...');
  console.log('  - Name:', req.body.name);
  console.log('  - Email:', req.body.email);

  // ✅ إنشاء المستخدم مع emailVerified = false
  const user = await User.create({
    name: req.body.name,
    email: req.body.email,
    password: req.body.password,
    emailVerified: false, // ✅ الحساب غير مفعّل حتى الآن
  });

  console.log('✅ [registerUser] User created successfully');
  console.log('  - User ID:', user._id);

  // ✅ توليد كود تحقق من 6 أرقام
  const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
  const hashedVerificationCode = crypto
    .createHash("sha256")
    .update(verificationCode)
    .digest("hex");

  console.log('🔐 [registerUser] Verification code generated');
  console.log('  - Code:', verificationCode); // ✅ للاختبار - احذفه في الإنتاج
  console.log('  - Hashed:', hashedVerificationCode.substring(0, 20) + '...');

  // ✅ حفظ كود التحقق في قاعدة البيانات
  user.emailVerificationCode = hashedVerificationCode;
  // ✅ انتهاء صلاحية الكود بعد 10 دقائق
  user.emailVerificationExpires = Date.now() + 10 * 60 * 1000;
  await user.save();

  console.log('💾 [registerUser] Verification code saved to database');
  console.log('  - Expires at:', new Date(user.emailVerificationExpires).toLocaleString());

  // ✅ إرسال كود التحقق عبر البريد الإلكتروني
  const message = `مرحباً ${user.name},\n\nشكراً لك على التسجيل في Filevo!\n\nكود التحقق من البريد الإلكتروني الخاص بك هو:\n${verificationCode}\n\nهذا الكود صالح لمدة 10 دقائق.\n\nإذا لم تطلب هذا الكود، يمكنك تجاهل هذه الرسالة.\n\nشكراً لك،\nفريق Filevo`;

  console.log('📧 [registerUser] Attempting to send verification email...');
  console.log('  - To:', user.email);
  console.log('  - Subject: كود التحقق من البريد الإلكتروني - Filevo');

  try {
    const emailResult = await sendEmail({
      email: user.email,
      subject: "كود التحقق من البريد الإلكتروني - Filevo",
      message,
    });

    console.log('✅ [registerUser] Email sent successfully');
    console.log('  - Message ID:', emailResult?.messageId || 'N/A');
    console.log('  - Response:', emailResult?.response || 'N/A');

  } catch (err) {
    console.error('❌ [registerUser] Error sending email:', err);
    console.error('  - Error message:', err.message);
    console.error('  - Error code:', err.code);
    console.error('  - Error stack:', err.stack);

    // ✅ في حالة فشل إرسال البريد، حذف الكود
    user.emailVerificationCode = undefined;
    user.emailVerificationExpires = undefined;
    await user.save();

    console.log('🧹 [registerUser] Verification code removed due to email error');

    // ✅ إرجاع خطأ واضح
    return next(
      new ApiError(
        "حدث خطأ في إرسال البريد الإلكتروني. يرجى التحقق من إعدادات البريد الإلكتروني أو المحاولة مرة أخرى لاحقاً. الخطأ: " + err.message,
        500
      )
    );
  }

  console.log('✅ [registerUser] Registration completed successfully');

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






