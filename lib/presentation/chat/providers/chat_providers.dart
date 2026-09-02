import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/chat_models.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/services/websocket_service.dart';
import '../../auth/auth_provider.dart';

final conversationsProvider = FutureProvider<List<ChatConversation>>((ref) async {
  final repository = ref.read(chatRepositoryProvider);
  return repository.getConversations();
});

class ChatNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final int conversationId;
  final Ref ref;
  late final ChatRepository _repository;
  late final WebSocketService _wsService;

  ChatNotifier(this.conversationId, this.ref) : super(const AsyncValue.loading()) {
    _repository = ref.read(chatRepositoryProvider);
    _wsService = ref.read(webSocketServiceProvider);
    _init();
  }

  Future<void> _init() async {
    try {
      final messages = await _repository.getMessages(conversationId);
      state = AsyncValue.data(messages);

      _wsService.onMessageReceived = (message) {
        state.whenData((currentMessages) {
          state = AsyncValue.data([...currentMessages, message]);
        });
      };
      
      await _wsService.connect(conversationId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    final tempMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      conversationId: conversationId,
      senderId: ref.read(authStateProvider).value?.id ?? 0,
      text: text,
      isRead: false,
      timestamp: DateTime.now(),
    );

    // Optimistically add to state
    state.whenData((currentMessages) {
      state = AsyncValue.data([...currentMessages, tempMessage]);
    });

    _wsService.sendMessage(text);
  }

  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }
}

final chatNotifierProvider = StateNotifierProvider.autoDispose.family<ChatNotifier, AsyncValue<List<ChatMessage>>, int>((ref, conversationId) {
  return ChatNotifier(
    conversationId,
    ref,
  );
});
