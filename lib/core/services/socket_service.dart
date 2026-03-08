import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:hive/hive.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      // Get token from Hive
      final authBox = Hive.box('auth_box');
      final token = authBox.get('token');

      if (token == null) {
        print('❌ No token found for socket connection');
        return;
      }

      _socket = IO.io(
        'http://10.0.2.2:5050', // Your backend URL
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .build(),
      );

      _socket!.connect();

      _socket!.onConnect((_) {
        print('✅ Socket connected');
        _isConnected = true;
      });

      _socket!.onDisconnect((_) {
        print('❌ Socket disconnected');
        _isConnected = false;
      });

      _socket!.onConnectError((data) {
        print('❌ Socket connection error: $data');
      });

      _socket!.on('connected', (data) {
        print('✅ Socket authenticated: $data');
      });
    } catch (e) {
      print('❌ Socket connection failed: $e');
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  void emit(String event, dynamic data) {
    if (_isConnected && _socket != null) {
      _socket!.emit(event, data);
    }
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }
}
