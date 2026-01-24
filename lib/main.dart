import 'package:device_preview/device_preview.dart';
import 'package:filevo/controllers/ThemeController.dart';
import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:filevo/controllers/auth/auth_controller.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/controllers/profile/profile_controller.dart';
import 'package:filevo/controllers/ai_search_controller.dart';
import 'package:filevo/views/auth/login_view.dart';
import 'package:filevo/views/auth/signup_view.dart';
import 'package:filevo/views/folders/folders_view.dart';
import 'package:filevo/views/home/home_view.dart';
import 'package:filevo/views/main/main_view.dart';
import 'package:filevo/views/profile/profile_view.dart';
import 'package:filevo/views/settings/settings_view.dart';
import 'package:filevo/views/search/smart_search_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:filevo/services/storage_service.dart'; // ✅ إضافة خدمة التخزين
import 'package:filevo/services/notification_service.dart'; // ✅ إضافة خدمة الإشعارات
import 'package:filevo/utils/notification_navigation.dart'; // ✅ إضافة التنقل للإشعارات
import 'package:filevo/generated/l10n.dart';
import 'package:filevo/constants/app_colors.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'; // ✅ إضافة Splash Screen
import 'package:firebase_core/firebase_core.dart'; // ✅ إضافة مكتبة Firebase Core

void main() async {
  print('🚀 [Main] Starting application...');
  // ✅ تهيئة Flutter مع الحفاظ على Splash Screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // ✅ تهيئة Firebase
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Error initializing Firebase: $e');
  }

  // ✅ تهيئة خدمة الإشعارات
  try {
    await NotificationService().initialize();
  } catch (e) {
    print('❌ Error initializing NotificationService: $e');
  }

  runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  Future<bool>? _loginCheckFuture;

  @override
  void initState() {
    super.initState();
    // ✅ تحميل حالة تسجيل الدخول مرة واحدة فقط
    _loginCheckFuture = StorageService.isLoggedIn();
    
    // ✅ إزالة Splash Screen بعد تحميل التطبيق
    // يمكنك إضافة تأخير (delay) هنا إذا بدك Splash Screen يبقى أطول:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // عرض Splash Screen لمدة 2 ثانية إضافية (اختياري)
      Future.delayed(const Duration(seconds: 2), () {
        FlutterNativeSplash.remove();
      });
      
      // أو إزالته مباشرة (الافتراضي):
      // FlutterNativeSplash.remove();
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  // ✅ بناء Light Theme
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: false, // ✅ استخدام Material 2 لتجنب مشاكل الألوان
      brightness: Brightness.light,
      primaryColor: AppColors.lightAppBar,
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardColor: AppColors.lightCardBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightAppBar,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.lightTextPrimary),
        displayMedium: TextStyle(color: AppColors.lightTextPrimary),
        displaySmall: TextStyle(color: AppColors.lightTextPrimary),
        headlineLarge: TextStyle(color: AppColors.lightTextPrimary),
        headlineMedium: TextStyle(color: AppColors.lightTextPrimary),
        headlineSmall: TextStyle(color: AppColors.lightTextPrimary),
        titleLarge: TextStyle(color: AppColors.lightTextPrimary),
        titleMedium: TextStyle(color: AppColors.lightTextPrimary),
        titleSmall: TextStyle(color: AppColors.lightTextPrimary),
        bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
        bodyMedium: TextStyle(color: AppColors.lightTextPrimary),
        bodySmall: TextStyle(color: AppColors.lightTextSecondary),
        labelLarge: TextStyle(color: AppColors.lightTextPrimary),
        labelMedium: TextStyle(color: AppColors.lightTextPrimary),
        labelSmall: TextStyle(color: AppColors.lightTextSecondary),
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightAppBar,
        secondary: AppColors.accent,
        surface: AppColors.lightSurface,
        background: AppColors.lightBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        onBackground: AppColors.lightTextPrimary,
      ),
    );
  }

  // ✅ بناء Dark Theme
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: false, // ✅ استخدام Material 2 لتجنب مشاكل الألوان
      brightness: Brightness.dark,
      primaryColor: AppColors.darkPrimary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkCardBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkAppBar,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.darkTextPrimary),
        displayMedium: TextStyle(color: AppColors.darkTextPrimary),
        displaySmall: TextStyle(color: AppColors.darkTextPrimary),
        headlineLarge: TextStyle(color: AppColors.darkTextPrimary),
        headlineMedium: TextStyle(color: AppColors.darkTextPrimary),
        headlineSmall: TextStyle(color: AppColors.darkTextPrimary),
        titleLarge: TextStyle(color: AppColors.darkTextPrimary),
        titleMedium: TextStyle(color: AppColors.darkTextPrimary),
        titleSmall: TextStyle(color: AppColors.darkTextPrimary),
        bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
        bodyMedium: TextStyle(color: AppColors.darkTextPrimary),
        bodySmall: TextStyle(color: AppColors.darkTextSecondary),
        labelLarge: TextStyle(color: AppColors.darkTextPrimary),
        labelMedium: TextStyle(color: AppColors.darkTextPrimary),
        labelSmall: TextStyle(color: AppColors.darkTextSecondary),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.accent,
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
        onBackground: AppColors.darkTextPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => FileController()),
        ChangeNotifierProvider(
          create: (_) => ThemeController(),
        ), // ✅ ThemeController
        ChangeNotifierProvider(create: (_) => FolderController()),
        ChangeNotifierProvider(
          create: (_) => RoomController(),
        ), // ✅ RoomController
        ChangeNotifierProvider(
          create: (_) => ProfileController(),
        ), // ✅ ProfileController
        ChangeNotifierProvider(
          create: (_) => AiSearchController(),
        ), // ✅ AiSearchController
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          print(
            '🎨 Building MaterialApp with theme: ${themeController.isDarkMode ? "Dark" : "Light"}',
          );
          return MaterialApp(
            navigatorKey: NotificationNavigation.navigatorKey,
            locale: _locale ?? const Locale('en'),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: themeController.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            routes: {
              'LogInPage': (context) => const LoginPage(),
              'SignUpPage': (context) => const SignUpPage(),
              'Home': (context) => HomeView(),
              'Main': (context) => MainPage(),
              'Folders': (context) => FoldersPage(),
              'Profile': (context) => ProfilePage(),
              'Settings': (context) => SettingsPage(),
              'SmartSearch': (context) => SmartSearchPage(),
            },
            // ✅ استخدام FutureBuilder للتحقق من التوكن بشكل ديناميكي
            home: FutureBuilder<bool>(
              future: _loginCheckFuture,
              builder: (context, snapshot) {
                // أثناء التحميل، عرض شاشة تحميل
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                // التحقق من وجود التوكن
                final isLoggedIn = snapshot.data ?? false;
                print('🔑 [MyApp] Checking login status: $isLoggedIn');

                if (isLoggedIn) {
                  print('✅ [MyApp] User is logged in, navigating to Main');
                  return MainPage();
                } else {
                  print('❌ [MyApp] User is not logged in, navigating to Login');
                  return const LoginPage();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
