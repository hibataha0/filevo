import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:filevo/config/api_config.dart';
import 'package:filevo/services/storage_service.dart';

class SocketService {
  static SocketService? _instance;
  IO.Socket? _socket;
  bool _isConnected = false;

  SocketService._internal();

  factory SocketService() {
    _instance ??= SocketService._internal();
    return _instance!;
  }

  /// ✅ الاتصال بـ socket.io server
  Future<void> connect() async {
    if (_isConnected && _socket != null) {
      print('🔌 [SocketService] Already connected');
      return;
    }

    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        print('❌ [SocketService] No token available');
        return;
      }

      // ✅ بناء socket URL من baseUrl
      final baseUrl = ApiConfig.baseUrl.replaceAll('/api/v1', '');
      final socketUrl = baseUrl;

      print('🔌 [SocketService] Connecting to: $socketUrl');

      _socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .enableAutoConnect()
            .build(),
      );

      _socket!.onConnect((_) {
        print('✅ [SocketService] Connected to server');
        _isConnected = true;
      });

      _socket!.onDisconnect((_) {
        print('❌ [SocketService] Disconnected from server');
        _isConnected = false;
      });

      _socket!.onError((error) {
        print('❌ [SocketService] Error: $error');
        _isConnected = false;
      });

      _socket!.onConnectError((error) {
        print('❌ [SocketService] Connection error: $error');
        _isConnected = false;
      });
    } catch (e) {
      print('❌ [SocketService] Error connecting: $e');
      _isConnected = false;
    }
  }

  /// ✅ الانضمام إلى روم
  void joinRoom(String roomId) {
    if (_socket == null || !_isConnected) {
      print('⚠️ [SocketService] Socket not connected, connecting first...');
      connect().then((_) {
        if (_socket != null && _isConnected) {
          _socket!.emit('join_room', roomId);
          print('📥 [SocketService] Joining room: $roomId');
        }
      });
      return;
    }

    _socket!.emit('join_room', roomId);
    print('📥 [SocketService] Joining room: $roomId');
  }

  /// ✅ مغادرة روم
  void leaveRoom(String roomId) {
    if (_socket == null || !_isConnected) {
      return;
    }

    _socket!.emit('leave_room', roomId);
    print('👋 [SocketService] Left room: $roomId');
  }

  /// ✅ الاستماع لحدث new_file
  void onNewFile(Function(Map<String, dynamic>) callback) {
    if (_socket == null) {
      print('⚠️ [SocketService] Socket not initialized');
      return;
    }

    _socket!.on('new_file', (data) {
      print('📁 [SocketService] New file received: $data');
      if (data is Map<String, dynamic>) {
        callback(data);
      }
    });
  }

  /// ✅ الاستماع لحدث new_folder
  void onNewFolder(Function(Map<String, dynamic>) callback) {
    if (_socket == null) {
      print('⚠️ [SocketService] Socket not initialized');
      return;
    }

    _socket!.on('new_folder', (data) {
      print('📂 [SocketService] New folder received: $data');
      if (data is Map<String, dynamic>) {
        callback(data);
      }
    });
  }

  /// ✅ الاستماع لحدث new_comment
  void onNewComment(Function(Map<String, dynamic>) callback) {
    if (_socket == null) {
      print('⚠️ [SocketService] Socket not initialized');
      return;
    }

    _socket!.on('new_comment', (data) {
      print('💬 [SocketService] New comment received: $data');
      if (data is Map<String, dynamic>) {
        callback(data);
      }
    });
  }

  /// ✅ إزالة جميع المستمعين
  void removeAllListeners() {
    if (_socket == null) {
      return;
    }

    _socket!.clearListeners();
    print('🧹 [SocketService] All listeners removed');
  }

  /// ✅ قطع الاتصال
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      print('🔌 [SocketService] Disconnected');
    }
  }

  /// ✅ التحقق من حالة الاتصال
  bool get isConnected => _isConnected;

  /// ✅ الحصول على socket instance
  IO.Socket? get socket => _socket;
}
