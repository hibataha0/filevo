import 'package:device_preview/device_preview.dart';
import 'package:filevo/generated/l10n.dart';
import 'package:filevo/views/auth/login_view.dart';
import 'package:filevo/views/auth/signup_view.dart';
import 'package:filevo/views/folders/folders_view.dart';
import 'package:filevo/views/home/home_view.dart';
import 'package:filevo/views/main/main_view.dart';
import 'package:filevo/views/profile/profile_view.dart';
import 'package:filevo/views/settings/settings_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  // دالة لتغيير اللغة من أي صفحة
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false; // الوضع الافتراضي: Light
  Locale? _locale; // اللغة الحالية

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale ?? const Locale('en'), // اللغة الحالية
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.blue,
      ),
      routes: {
        'LogInPage': (context) => const LoginPage(),
        'SignUpPage': (context) => const SignUpPage(),
        'Home': (context) => HomeView(),
        'Main': (context) => MainPage(),
        'Folders': (context) => FoldersPage(),
        'Profile': (context) => ProfilePage(),
        'Settings': (context) => SettingsPage(),
      },
      initialRoute: 'LogInPage',
    );
  }
}
