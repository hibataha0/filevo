import 'package:device_preview/device_preview.dart';
import 'package:filevo/controllers/ThemeController.dart';
import 'package:filevo/controllers/folders/files_controller.dart';
import 'package:filevo/controllers/auth/auth_controller.dart';
import 'package:filevo/controllers/folders/folders_controller.dart';
import 'package:filevo/controllers/folders/room_controller.dart';
import 'package:filevo/controllers/profile/profile_controller.dart';
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
import 'package:provider/provider.dart';
import 'package:filevo/services/storage_service.dart'; // ✅ إضافة خدمة التخزين
import 'package:filevo/generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool loggedIn = await StorageService.isLoggedIn();

  runApp(DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => MyApp(isLoggedIn: loggedIn),
  ));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => FileController()),
        ChangeNotifierProvider(create: (_) => ThemeController()), // ✅ ThemeController
        ChangeNotifierProvider(create: (_) => FolderController()),
        ChangeNotifierProvider(create: (_) => RoomController()), // ✅ RoomController
        ChangeNotifierProvider(create: (_) => ProfileController()), // ✅ ProfileController
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return MaterialApp(
            locale: _locale ?? const Locale('en'),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light, // 🔹 استخدام ThemeController
            routes: {
              'LogInPage': (context) => const LoginPage(),
              'SignUpPage': (context) => const SignUpPage(),
              'Home': (context) => HomeView(),
              'Main': (context) => MainPage(),
              'Folders': (context) => FoldersPage(),
              'Profile': (context) => ProfilePage(),
              'Settings': (context) => SettingsPage(),
            },
            initialRoute: widget.isLoggedIn ? 'Main' : 'LogInPage',
          );
        },
      ),
    );
  }
}
