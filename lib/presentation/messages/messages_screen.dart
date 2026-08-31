import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dummy data for chat list
    final List<Map<String, dynamic>> dummyChats = [
      {
        'name': 'Hasan Ali',
        'avatar': 'HA',
        'lastMessage': 'আমি আগামীকাল আপনার সাথে দেখা করতে পারি।',
        'time': '10:30 AM',
        'unread': 2,
        'isOnline': true,
      },
      {
        'name': 'Kamrul Islam',
        'avatar': 'KI',
        'lastMessage': 'জব অফারটি সম্পর্কে বিস্তারিত বলবেন কি?',
        'time': 'Yesterday',
        'unread': 0,
        'isOnline': false,
      },
      {
        'name': 'Sheba Support',
        'avatar': 'SS',
        'lastMessage': 'আপনার পেমেন্টটি সফলভাবে সম্পন্ন হয়েছে।',
        'time': 'Monday',
        'unread': 1,
        'isOnline': true,
      },
    ];

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
      body: dummyChats.isEmpty
          ? const _EmptyMessagesView()
          : ListView.separated(
              padding: const EdgeInsets.only(top: 8, bottom: 100), // padding for bottom nav
              itemCount: dummyChats.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final chat = dummyChats[index];
                return _ChatListItem(chat: chat);
              },
            ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final Map<String, dynamic> chat;

  const _ChatListItem({required this.chat});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          // TODO: Open chat details screen
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFF0056D2).withOpacity(0.1),
                    child: Text(
                      chat['avatar'],
                      style: const TextStyle(
                        color: Color(0xFF0056D2),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (chat['isOnline'] == true)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981), // Green
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
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
                          chat['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          chat['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: chat['unread'] > 0 ? const Color(0xFF0056D2) : const Color(0xFF94A3B8),
                            fontWeight: chat['unread'] > 0 ? FontWeight.bold : FontWeight.normal,
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
                            chat['lastMessage'],
                            style: TextStyle(
                              fontSize: 14,
                              color: chat['unread'] > 0 ? const Color(0xFF334155) : const Color(0xFF64748B),
                              fontWeight: chat['unread'] > 0 ? FontWeight.w600 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (chat['unread'] > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0056D2),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${chat['unread']}',
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
