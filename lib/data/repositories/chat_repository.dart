import '../models/chat_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/auth/auth_provider.dart';
import '../../core/api/api_client.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(apiClientProvider));
});

class ChatRepository {
  final ApiClient _apiClient;

  ChatRepository(this._apiClient);

  Future<List<ChatConversation>> getConversations() async {
    try {
      final response = await _apiClient.dio.get('/chat/conversations/');
      final dynamic responseData = response.data;
      final List data = responseData is Map ? (responseData['results'] ?? []) : responseData;
      return data.map((json) => ChatConversation.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching conversations: $e');
      throw Exception('Failed to load conversations: $e');
    }
  }

  Future<List<ChatMessage>> getMessages(int conversationId) async {
    try {
      final response = await _apiClient.dio.get('/chat/conversations/$conversationId/messages/');
      final dynamic responseData = response.data;
      final List data = responseData is Map ? (responseData['results'] ?? []) : responseData;
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching messages: $e');
      throw Exception('Failed to load messages: $e');
    }
  }

  Future<ChatConversation> initiateConversation({
    required int userId,
    String? relatedObjectType,
    int? relatedObjectId,
  }) async {
    try {
      final response = await _apiClient.dio.post('/chat/conversations/initiate/',
        data: {
          'user_id': userId,
          if (relatedObjectType != null) 'related_object_type': relatedObjectType,
          if (relatedObjectId != null) 'related_object_id': relatedObjectId,
        },
      );
      return ChatConversation.fromJson(response.data);
    } catch (e) {
      print('Error initiating conversation: $e');
      throw Exception('Failed to start chat: $e');
    }
  }
}
