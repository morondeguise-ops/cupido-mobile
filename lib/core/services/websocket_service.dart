import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

import '../config/app_config.dart';
import 'api_service.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final ApiService _api;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _readReceiptController = StreamController<Map<String, dynamic>>.broadcast();
  bool _isConnected = false;

  WebSocketService(this._api);

  // Connect to WebSocket (CppServer protocol)
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      final token = await _api.getToken();
      if (token == null) {
        throw Exception('No auth token available');
      }

      // Connect to CppServer WebSocket (no token in URL)
      _channel = WebSocketChannel.connect(
        Uri.parse(AppConfig.webSocketUrl),
      );

      // Listen to incoming messages
      _channel!.stream.listen(
        (data) {
          _handleMessage(data, token);
        },
        onError: (error) {
          _isConnected = false;
          // Attempt to reconnect
          Future.delayed(const Duration(seconds: 5), () => connect());
        },
        onDone: () {
          _isConnected = false;
          // Attempt to reconnect
          Future.delayed(const Duration(seconds: 5), () => connect());
        },
      );

      print('[WebSocket] Connected to ${AppConfig.webSocketUrl}');
    } catch (e) {
      _isConnected = false;
      rethrow;
    }
  }

  // Disconnect from WebSocket
  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
  }

  // Send message
  void sendMessage(Map<String, dynamic> message) {
    if (!_isConnected) {
      throw Exception('WebSocket not connected');
    }

    _channel?.sink.add(json.encode(message));
  }

  // Send typing indicator
  void sendTyping(int matchId, bool isTyping) {
    sendMessage({
      'event': AppConfig.typingEvent,
      'match_id': matchId,
      'is_typing': isTyping,
    });
  }

  // Send read receipt
  void sendReadReceipt(int matchId, int messageId) {
    sendMessage({
      'event': AppConfig.readReceiptEvent,
      'match_id': matchId,
      'message_id': messageId,
    });
  }

  // Handle incoming messages (CppServer protocol)
  void _handleMessage(dynamic data, String token) {
    try {
      final message = json.decode(data) as Map<String, dynamic>;
      final type = message['type'] as String?;

      print('[WebSocket] Received: $type');

      // Handle CppServer authentication flow
      if (type == 'auth_required' && !_isConnected) {
        // Server is requesting authentication, send JWT token
        print('[WebSocket] Authenticating...');
        _channel?.sink.add(json.encode({
          'type': 'auth',
          'token': token,
        }));
        return;
      }

      if (type == 'success' && !_isConnected) {
        // Successfully authenticated
        _isConnected = true;
        print('[WebSocket] Authenticated successfully');
        return;
      }

      if (type == 'error') {
        // Error from server
        print('[WebSocket] Error: ${message['message']}');
        return;
      }

      // Handle application events
      if (type == 'new_message') {
        _messageController.add(message['data']);
      } else if (type == 'user_typing') {
        _typingController.add(message['data']);
      } else if (type == 'new_match') {
        _messageController.add(message['data']);
      } else if (type == 'read_receipt') {
        _readReceiptController.add(message['data']);
      }
    } catch (e) {
      print('[WebSocket] Parse error: $e');
    }
  }

  // Streams
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get readReceiptStream =>
      _readReceiptController.stream;

  bool get isConnected => _isConnected;

  // Dispose
  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _readReceiptController.close();
  }
}
