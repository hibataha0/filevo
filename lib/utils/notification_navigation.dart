import 'package:flutter/material.dart';

class NotificationNavigation {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void navigateToRoom(String roomId) {
    print('🚀 Navigating to room: $roomId');
  }

  static void navigateToFile(String fileId) {
    print('🚀 Navigating to file: $fileId');
  }

  static void navigateToMain() {
    navigatorKey.currentState?.pushReplacementNamed('Main');
  }
}
