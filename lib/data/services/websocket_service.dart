import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_models.dart';

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService();
});

class WebSocketService {
  WebSocketChannel? _channel;
  Function(ChatMessage)? onMessageReceived;

  Future<void> connect(int conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    // The server handles routing WebSocket requests via ASGI
    final wsUrl = Uri.parse('ws://188.245.212.240/ws/chat/$conversationId/?token=$token');

    _channel = WebSocketChannel.connect(wsUrl);

    _channel?.stream.listen(
      (message) {
        final data = jsonDecode(message);
        if (data != null && data['message'] != null) {
          final chatMessage = ChatMessage(
            id: data['id'] ?? 0,
            conversationId: conversationId,
            senderId: data['sender_id'],
            text: data['message'],
            isRead: false,
            timestamp: data['timestamp'] != null ? DateTime.parse(data['timestamp']).toLocal() : DateTime.now(),
          );
          
          if (onMessageReceived != null) {
            onMessageReceived!(chatMessage);
          }
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket closed. Code: ${_channel?.closeCode}, Reason: ${_channel?.closeReason}');
      },
    );
  }

  void sendMessage(String text) {
    if (_channel != null) {
      final data = jsonEncode({'message': text});
      _channel?.sink.add(data);
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
