import 'dart:async';
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

  // ✅ استخدام Completer لانتظار الاتصال الحقيقي
  Completer<void>? _connectionCompleter;

  /// ✅ الاتصال بـ socket.io server
  Future<void> connect() async {
    if (_isConnected && _socket != null) {
      print('🔌 [SocketService] Already connected');
      return;
    }

    if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
      print('🔌 [SocketService] Connection already in progress...');
      return _connectionCompleter!.future;
    }

    _connectionCompleter = Completer<void>();

    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        print('❌ [SocketService] No token available');
        _connectionCompleter!.completeError('No token');
        return;
      }

      // ✅ بناء socket URL من baseUrl
      final baseUrl = ApiConfig.baseUrl.replaceAll('/api/v1', '');
      final socketUrl = baseUrl;

      print('🔌 [SocketService] Starting connection to: $socketUrl');

      _socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling']) // ✅ تفعيل polling كاحتياط
            .setAuth({'token': token})
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(5000)
            .build(),
      );

      _socket!.onConnect((_) {
        print('✅ [SocketService] Socket connected successfully');
        _isConnected = true;
        if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
          _connectionCompleter!.complete();
        }
      });

      _socket!.onConnectError((error) {
        print('❌ [SocketService] Connection error: $error');
        _isConnected = false;
        // لا نغلق الـ completer هنا للسماح بإعادة المحاولة التلقائية
      });

      _socket!.onDisconnect((reason) {
        print('❌ [SocketService] Disconnected: $reason');
        _isConnected = false;
        // إعادة تهيئة الـ completer للاتصال القادم
        _connectionCompleter = null;
      });

      _socket!.onError((error) {
        print('❌ [SocketService] Error: $error');
      });

      return _connectionCompleter!.future;
    } catch (e) {
      print('❌ [SocketService] Exception during connect: $e');
      _isConnected = false;
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        _connectionCompleter!.completeError(e);
      }
      rethrow;
    }
  }

  /// ✅ الانضمام إلى روم (مع انتظار الاتصال)
  void joinRoom(String roomId) async {
    try {
      if (!_isConnected) {
        print('⏳ [SocketService] Waiting for connection before joining room $roomId...');
        await connect();
      }
      
      if (_socket != null && _isConnected) {
        _socket!.emit('join_room', roomId);
        print('📥 [SocketService] Sent join_room for: $roomId');
      }
    } catch (e) {
      print('❌ [SocketService] Failed to join room: $e');
    }
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
      print('📁 [SocketService] New file event raw data: $data');
      
      Map<String, dynamic>? fileData;
      
      try {
        if (data is Map<String, dynamic>) {
          // ✅ السيرفر يبعث: { file: {...}, roomId: "...", sharedBy: "...", timestamp: "..." }
          if (data.containsKey('file') && data['file'] is Map<String, dynamic>) {
            fileData = Map<String, dynamic>.from(data['file']);
          } else {
            // في حالة البيانات جاية مباشرة
            fileData = data;
          }
        } else if (data is List && data.isNotEmpty) {
          final first = data[0];
          if (first is Map<String, dynamic>) {
            if (first.containsKey('file') && first['file'] is Map<String, dynamic>) {
              fileData = Map<String, dynamic>.from(first['file']);
            } else {
              fileData = first;
            }
          }
        }
      } catch (e) {
        print('❌ [SocketService] Failed to parse new_file event: $e');
      }

      if (fileData != null) {
        print('✅ [SocketService] Parsed file data successfully');
        callback(fileData);
      } else {
        print('⚠️ [SocketService] Could not extract file data from event');
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
      print('📂 [SocketService] New folder event raw data: $data');
      
      Map<String, dynamic>? folderData;
      
      try {
        if (data is Map<String, dynamic>) {
          // ✅ السيرفر يبعث: { folder: {...}, roomId: "...", sharedBy: "...", timestamp: "..." }
          if (data.containsKey('folder') && data['folder'] is Map<String, dynamic>) {
            folderData = Map<String, dynamic>.from(data['folder']);
          } else {
            // في حالة البيانات جاية مباشرة
            folderData = data;
          }
        } else if (data is List && data.isNotEmpty) {
          final first = data[0];
          if (first is Map<String, dynamic>) {
            if (first.containsKey('folder') && first['folder'] is Map<String, dynamic>) {
              folderData = Map<String, dynamic>.from(first['folder']);
            } else {
              folderData = first;
            }
          }
        }
      } catch (e) {
        print('❌ [SocketService] Failed to parse new_folder event: $e');
      }

      if (folderData != null) {
        print('✅ [SocketService] Parsed folder data successfully');
        callback(folderData);
      } else {
        print('⚠️ [SocketService] Could not extract folder data from event');
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
      print('💬 [SocketService] New comment event raw data: $data');
      
      Map<String, dynamic>? commentData;
      
      try {
        if (data is Map<String, dynamic>) {
          // ✅ السيرفر يبعث: { comment: {...}, roomId: "...", timestamp: "..." }
          if (data.containsKey('comment') && data['comment'] is Map<String, dynamic>) {
            commentData = Map<String, dynamic>.from(data['comment']);
          } else {
            // في حالة البيانات جاية مباشرة
            commentData = data;
          }
        } else if (data is List && data.isNotEmpty) {
          final first = data[0];
          if (first is Map<String, dynamic>) {
            if (first.containsKey('comment') && first['comment'] is Map<String, dynamic>) {
              commentData = Map<String, dynamic>.from(first['comment']);
            } else {
              commentData = first;
            }
          }
        }
      } catch (e) {
        print('❌ [SocketService] Failed to parse new_comment event: $e');
      }

      if (commentData != null) {
        print('✅ [SocketService] Parsed comment data successfully');
        callback(commentData);
      } else {
        print('⚠️ [SocketService] Could not extract comment data from event');
      }
    });
  }

  /// ✅ إزالة مستمع لحدث معين دون مسح الكل
  void off(String event) {
    if (_socket == null) return;
    _socket!.off(event);
    print('🧹 [SocketService] Removed listeners for event: $event');
  }

  /// ✅ إزالة جميع المستمعين (للطوارئ فقط)
  void removeAllListeners() {
    if (_socket == null) return;
    // لا نمسح onConnect و onDisconnect لأنهم ضروريين لحالة الخدمة
    _socket!.off('new_file');
    _socket!.off('new_folder');
    _socket!.off('new_comment');
    print('🧹 [SocketService] Domain-specific listeners removed');
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
