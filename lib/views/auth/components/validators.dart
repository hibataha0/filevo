import 'package:flutter/material.dart';
import 'package:filevo/generated/l10n.dart'; // استيراد ملف الترجمة

class Validators {
  // التحقق من البريد الإلكتروني أو اسم المستخدم
  static String? validateEmailOrUsername(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).enterUsernameOrEmail;
    }

    // إذا كان يحتوي على @ فهو بريد إلكتروني
    if (value.contains('@')) {
      return validateEmail(context, value);
    } else {
      return validateUsername(context, value);
    }
  }

  // التحقق من البريد الإلكتروني
  static String? validateEmail(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).enterEmail;
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(value)) {
      return S.of(context).invalidEmail;
    }

    return null;
  }

  // التحقق من اسم المستخدم
  static String? validateUsername(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).enterUsername;
    }

    if (value.length < 3) {
      return S.of(context).usernameMin;
    }

    if (value.length > 20) {
      return S.of(context).usernameMax;
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return S.of(context).usernameAllowedChars;
    }

    return null;
  }

  // التحقق من كلمة المرور
  static String? validatePassword(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).enterPassword;
    }

    if (value.length < 6) {
      return S.of(context).passwordMin;
    }

    return null;
  }

  // التحقق من رقم الهاتف
  static String? validatePhone(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).enterPhone;
    }

    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    final cleanedValue = value.replaceAll(RegExp(r'[-\s()]'), '');

    if (!phoneRegex.hasMatch(cleanedValue)) {
      return S.of(context).invalidPhone;
    }

    return null;
  }
}
