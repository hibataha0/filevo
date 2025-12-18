// ✅ تحسين دالة sendEmail في utils/sendEmail.js
// ✅ إضافة logging ومعالجة أخطاء محسّنة

const nodemailer = require('nodemailer');

const sendEmail = async (options) => {
  console.log('📧 [sendEmail] Starting email sending process...');
  console.log('  - To:', options.email);
  console.log('  - Subject:', options.subject);
  console.log('  - Host:', process.env.EMAIL_HOST);
  console.log('  - Port:', process.env.EMAIL_PORT);
  console.log('  - User:', process.env.EMAIL_USER);
  console.log('  - From:', process.env.EMAIL_FROM);

  // ✅ التحقق من وجود متغيرات البيئة
  if (!process.env.EMAIL_HOST || !process.env.EMAIL_USER || !process.env.EMAIL_PASSWORD) {
    const error = new Error('Email configuration is missing. Please check your .env file.');
    console.error('❌ [sendEmail] Configuration error:', error.message);
    throw error;
  }

  // ✅ إنشاء transporter
  const transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: process.env.EMAIL_PORT || 587,
    secure: false, // true for 465, false for other ports
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASSWORD,
    },
    // ✅ إضافة timeout
    connectionTimeout: 10000, // 10 seconds
    greetingTimeout: 10000,
    socketTimeout: 10000,
  });

  console.log('🔌 [sendEmail] Transporter created');

  // ✅ التحقق من الاتصال بـ SMTP
  try {
    console.log('🔍 [sendEmail] Verifying SMTP connection...');
    await transporter.verify();
    console.log('✅ [sendEmail] SMTP connection verified successfully');
  } catch (error) {
    console.error('❌ [sendEmail] SMTP verification failed');
    console.error('  - Error:', error.message);
    console.error('  - Code:', error.code);
    console.error('  - Command:', error.command);
    
    throw new Error(`SMTP connection failed: ${error.message}. Please check your email configuration.`);
  }

  // ✅ خيارات البريد الإلكتروني
  const mailOptions = {
    from: `Filevo <${process.env.EMAIL_FROM || process.env.EMAIL_USER}>`,
    to: options.email,
    subject: options.subject,
    text: options.message,
    html: options.html || options.message.replace(/\n/g, '<br>'), // ✅ تحويل النص إلى HTML
  };

  console.log('📨 [sendEmail] Sending email...');
  console.log('  - From:', mailOptions.from);
  console.log('  - To:', mailOptions.to);
  console.log('  - Subject:', mailOptions.subject);

  // ✅ إرسال البريد الإلكتروني
  try {
    const info = await transporter.sendMail(mailOptions);
    
    console.log('✅ [sendEmail] Email sent successfully');
    console.log('  - Message ID:', info.messageId);
    console.log('  - Response:', info.response);
    console.log('  - Accepted:', info.accepted);
    console.log('  - Rejected:', info.rejected);
    
    return info;
  } catch (error) {
    console.error('❌ [sendEmail] Error sending email');
    console.error('  - Error message:', error.message);
    console.error('  - Error code:', error.code);
    console.error('  - Error command:', error.command);
    console.error('  - Error response:', error.response);
    console.error('  - Error responseCode:', error.responseCode);
    
    throw new Error(`Failed to send email: ${error.message}`);
  }
};

module.exports = sendEmail;





