import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:filevo/services/storage_service.dart';
import 'package:filevo/config/api_config.dart';

/// ✅ خدمة Socket.IO للاتصال بالسيرفر والاستماع للأحداث المباشرة
class SocketService {
  static SocketService? _instance;
  IO.Socket? _socket;
  bool _isConnected = false;
  bool _isConnecting = false;

  // ✅ Map لتخزين الـ callbacks للتعليقات الجديدة: roomId -> callback
  final Map<String, Function(Map<String, dynamic>)> _commentCallbacks = {};

  SocketService._();

  static SocketService get instance {
    _instance ??= SocketService._();
    return _instance!;
  }

  /// ✅ الحصول على Socket URL
  String _getSocketUrl() {
    // استخراج الـ base URL من ApiConfig
    final apiUrl = ApiConfig.baseUrl;
    // إزالة /api/v1 من النهاية
    String baseUrl = apiUrl.replaceAll('/api/v1', '');
    
    // إذا كان baseUrl يحتوي على http:// أو https://، استخدمه مباشرة
    if (baseUrl.startsWith('http://') || baseUrl.startsWith('https://')) {
      return baseUrl;
    }
    
    // افتراضي
    return 'http://192.168.0.81:8000';
  }

  /// ✅ الاتصال بالسيرفر
  Future<bool> connect() async {
    if (_isConnected && _socket != null && _socket!.connected) {
      print('✅ [SocketService] Already connected');
      return true;
    }

    if (_isConnecting) {
      print('⏳ [SocketService] Connection in progress...');
      return false;
    }

    try {
      _isConnecting = true;
      final token = await StorageService.getToken();
      
      if (token == null || token.isEmpty) {
        print('❌ [SocketService] No token available');
        _isConnecting = false;
        return false;
      }

      final socketUrl = _getSocketUrl();
      print('🔌 [SocketService] Connecting to: $socketUrl');

      _socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setAuth({'token': token})
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(5)
            .build(),
      );

      // ✅ معالجة الأحداث
      _socket!.onConnect((_) {
        print('✅ [SocketService] Connected to server');
        _isConnected = true;
        _isConnecting = false;
      });

      _socket!.onDisconnect((_) {
        print('❌ [SocketService] Disconnected from server');
        _isConnected = false;
      });

      _socket!.onConnectError((error) {
        print('❌ [SocketService] Connection error: $error');
        _isConnecting = false;
      });

      _socket!.onError((error) {
        print('❌ [SocketService] Socket error: $error');
      });

      // ✅ الاستماع للتعليقات الجديدة
      _socket!.on('new_comment', (data) {
        print('📢 [SocketService] New comment received: $data');
        final roomId = data['roomId']?.toString();
        final comment = data['comment'];
        
        if (roomId != null && comment != null) {
          // ✅ استدعاء جميع الـ callbacks المسجلة لهذه الغرفة
          if (_commentCallbacks.containsKey(roomId)) {
            _commentCallbacks[roomId]!(comment);
          }
        }
      });

      // ✅ الاستماع لأحداث أخرى
      _socket!.on('joined_room', (data) {
        print('✅ [SocketService] Joined room: ${data['roomId']}');
      });

      _socket!.on('left_room', (data) {
        print('👋 [SocketService] Left room: ${data['roomId']}');
      });

      _socket!.on('error', (data) {
        print('❌ [SocketService] Error event: $data');
      });

      // ✅ انتظار الاتصال
      await Future.delayed(Duration(milliseconds: 500));
      
      if (_socket!.connected) {
        _isConnected = true;
        _isConnecting = false;
        return true;
      } else {
        _isConnecting = false;
        return false;
      }
    } catch (e) {
      print('❌ [SocketService] Error connecting: $e');
      _isConnecting = false;
      return false;
    }
  }

  /// ✅ الانضمام لغرفة
  Future<void> joinRoom(String roomId) async {
    if (!_isConnected || _socket == null || !_socket!.connected) {
      print('⚠️ [SocketService] Not connected, attempting to connect...');
      final connected = await connect();
      if (!connected) {
        print('❌ [SocketService] Failed to connect, cannot join room');
        return;
      }
    }

    print('🚪 [SocketService] Joining room: $roomId');
    _socket!.emit('join_room', roomId);
  }

  /// ✅ مغادرة غرفة
  void leaveRoom(String roomId) {
    if (_socket != null && _socket!.connected) {
      print('👋 [SocketService] Leaving room: $roomId');
      _socket!.emit('leave_room', roomId);
    }
  }

  /// ✅ تسجيل callback للتعليقات الجديدة في غرفة معينة
  void onNewComment(String roomId, Function(Map<String, dynamic>) callback) {
    _commentCallbacks[roomId] = callback;
    print('📝 [SocketService] Registered comment callback for room: $roomId');
  }

  /// ✅ إلغاء تسجيل callback للتعليقات
  void offNewComment(String roomId) {
    _commentCallbacks.remove(roomId);
    print('📝 [SocketService] Unregistered comment callback for room: $roomId');
  }

  /// ✅ قطع الاتصال
  void disconnect() {
    if (_socket != null) {
      print('🔌 [SocketService] Disconnecting...');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _commentCallbacks.clear();
    }
  }

  /// ✅ التحقق من حالة الاتصال
  bool get isConnected => _isConnected && _socket != null && _socket!.connected;

  /// ✅ الحصول على Socket instance (للحالات الخاصة)
  IO.Socket? get socket => _socket;
}
