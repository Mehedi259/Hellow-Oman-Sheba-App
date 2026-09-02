import 'chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../chat/providers/chat_providers.dart';
import '../../data/models/chat_models.dart';
import '../auth/auth_provider.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'মেসেজ',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              // TODO: Implement message search
            },
          ),
        ],
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return const _EmptyMessagesView();
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(conversationsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 8, bottom: 100),
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return _ChatListItem(conversation: conversation);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error loading messages'),
              ElevatedButton(
                onPressed: () => ref.refresh(conversationsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatListItem extends ConsumerWidget {
  final ChatConversation conversation;

  const _ChatListItem({required this.conversation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authStateProvider);
    final currentUserId = userState.value?.id ?? 0;
    
    final otherParticipant = conversation.getOtherParticipant(currentUserId);
    final title = otherParticipant?.fullName ?? 'Unknown User';
    
    final lastMessageText = conversation.lastMessage?.text ?? 'Started a chat';
    
    // Formatting time
    String timeText = '';
    if (conversation.lastMessage != null) {
      final diff = DateTime.now().difference(conversation.lastMessage!.timestamp);
      if (diff.inDays > 0) {
        timeText = '${diff.inDays}d ago';
      } else if (diff.inHours > 0) {
        timeText = '${diff.inHours}h ago';
      } else if (diff.inMinutes > 0) {
        timeText = '${diff.inMinutes}m ago';
      } else {
        timeText = 'Just now';
      }
    }

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                title: title,
                conversationId: conversation.id,
              ),
            ),
          ).then((_) {
            // Refresh conversations when returning to update read status/last message
            ref.refresh(conversationsProvider);
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF0056D2).withOpacity(0.1),
                backgroundImage: otherParticipant?.profilePicture != null
                    ? NetworkImage(otherParticipant!.profilePicture!)
                    : null,
                child: otherParticipant?.profilePicture == null
                    ? Text(
                        title.isNotEmpty ? title[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Color(0xFF0056D2),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          timeText,
                          style: TextStyle(
                            fontSize: 12,
                            color: conversation.unreadCount > 0 ? const Color(0xFF0056D2) : const Color(0xFF94A3B8),
                            fontWeight: conversation.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            lastMessageText,
                            style: TextStyle(
                              fontSize: 14,
                              color: conversation.unreadCount > 0 ? const Color(0xFF334155) : const Color(0xFF64748B),
                              fontWeight: conversation.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (conversation.unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0056D2),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${conversation.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMessagesView extends StatelessWidget {
  const _EmptyMessagesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0056D2).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 64,
                color: const Color(0xFF0056D2).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'কোনো মেসেজ নেই',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'আপনার চ্যাট লিস্ট আপাতত ফাঁকা আছে। কারো সাথে যোগাযোগ করলে এখানে মেসেজ দেখতে পাবেন।',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
