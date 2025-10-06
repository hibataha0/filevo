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

void main()
{
  runApp(DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => MyApp(), // Wrap your app
  ),);
  
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false; // الوضع الافتراضي: Light

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }
    @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: [
        
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      routes: {
        'LogInPage': (context) => const LoginPage(),
        'SignUpPage': (context) => const SignUpPage(),
        'Home': (context) =>  HomeView(),
        'Main': (context) =>  MainPage(),
        'Folders': (context) =>  FoldersPage(),
        'Profile': (context) =>  ProfilePage(),
        'Settings': (context) =>  SettingsPage(),

      },
      initialRoute: 'LogInPage', // الصفحة الرئيسية اللي بتفتح أول ما بتشغل التطبيق
      
    );
  }
}

