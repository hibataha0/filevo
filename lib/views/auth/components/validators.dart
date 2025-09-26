class Validators {
  // التحقق من البريد الإلكتروني أو اسم المستخدم
  static String? validateEmailOrUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username or email';
    }
    
    // إذا كان يحتوي على @ فهو بريد إلكتروني
    if (value.contains('@')) {
      return validateEmail(value);
    } else {
      return validateUsername(value);
    }
  }

  // التحقق من البريد الإلكتروني
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // التحقق من اسم المستخدم
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    
    if (value.length > 20) {
      return 'Username cannot exceed 20 characters';
    }
    
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers and underscore';
    }
    
    return null;
  }

  // التحقق من كلمة المرور
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  // التحقق من رقم الهاتف
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    
    // تحقق من صيغة رقم الهاتف (أرقام فقط، من 10 إلى 15 رقم)
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    final cleanedValue = value.replaceAll(RegExp(r'[-\s()]'), '');
    
    if (!phoneRegex.hasMatch(cleanedValue)) {
      return 'Please enter a valid phone number (10-15 digits)';
    }
    
    return null;
  }
}