import 'dart:convert';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/services/user_service.dart';
import 'package:filevo/utils/notification_navigation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final UserService _userService = UserService();

  // Initialize notification service
  Future<void> initialize() async {
    print('🔔 [NotificationService] Initializing...');
    // Initialize local notifications
    await _initializeLocalNotifications();

    // Request permissions
    await _requestPermissions();

    // Setup message handlers
    _setupMessageHandlers();

    // Get and update FCM token
    final token = await getFCMToken();
    if (token != null) {
      print('📱 FCM Token: $token');
      if (await StorageService.isLoggedIn()) {
        await updateTokenOnServer(token);
      }
    }

    // Listen for token refresh
    listenToTokenRefresh();
  }

  // Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  // Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'filevo_messages',
      'Filevo Notifications',
      description: 'Notifications for rooms and file shares',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('✅ User granted provisional notification permission');
    } else {
      print('❌ User declined or has not accepted notification permission');
    }
  }

  // Setup message handlers
  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessageOpenedApp(message);
      }
    });
  }

  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (message.notification != null) {
      await _showLocalNotification(
        id: message.hashCode,
        title: message.notification!.title ?? 'Filevo',
        body: message.notification!.body ?? 'You have a new notification',
        payload: jsonEncode(message.data),
      );
    }
  }

  // Handle message opened app
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    _processMessageNavigation(message.data);
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _processMessageNavigation(data);
      } catch (e) {
        print('❌ Error parsing notification payload: $e');
      }
    }
  }

  // Common navigation processing
  void _processMessageNavigation(Map<String, dynamic> data) {
    if (data['type'] == 'room_invitation' || data['type'] == 'room_activity') {
      final roomId = data['roomId'];
      if (roomId != null) {
        NotificationNavigation.navigateToRoom(roomId);
      }
    } else if (data['type'] == 'file_share') {
      final fileId = data['fileId'];
      if (fileId != null) {
        NotificationNavigation.navigateToFile(fileId);
      }
    }
  }

  // Show local notification
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'filevo_messages',
          'Filevo Notifications',
          channelDescription: 'Notifications for rooms and file shares',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  // Get FCM token
  Future<String?> getFCMToken() async {
    try {
      print('🔍 [NotificationService] Requesting FCM Token from Firebase...');
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('✅ [NotificationService] Token received: ${token.substring(0, min(15, token.length))}...');
        await StorageService.saveFCMToken(token);
      } else {
        print('⚠️ [NotificationService] Firebase returned null token');
      }
      return token;
    } catch (e) {
      print('❌ [NotificationService] Error getting FCM token: $e');
      return null;
    }
  }

  // Update token on server
  Future<void> updateTokenOnServer(String fcmToken) async {
    try {
      final result = await _userService.updateFCMToken(fcmToken: fcmToken);
      if (result['success']) {
        print('✅ FCM Token updated on server');
      } else {
        print('❌ Failed to update FCM Token on server: ${result['error']}');
      }
    } catch (e) {
      print('❌ Error updating FCM Token on server: $e');
    }
  }

  // Listen for token refresh
  void listenToTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      await StorageService.saveFCMToken(newToken);
      if (await StorageService.isLoggedIn()) {
        await updateTokenOnServer(newToken);
      }
    });
  }
}
