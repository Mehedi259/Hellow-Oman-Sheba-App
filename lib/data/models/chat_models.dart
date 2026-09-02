class ChatUser {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? profilePicture;

  ChatUser({
    required this.id,
    this.firstName,
    this.lastName,
    this.profilePicture,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profilePicture: json['profile_picture'],
    );
  }

  String get fullName {
    if (firstName == null && lastName == null) return 'User $id';
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }
}

class ChatMessage {
  final int id;
  final int conversationId;
  final int senderId;
  final String text;
  final bool isRead;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.isRead,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      conversationId: json['conversation'],
      senderId: json['sender_id'],
      text: json['text'],
      isRead: json['is_read'] ?? false,
      timestamp: DateTime.parse(json['timestamp']).toLocal(),
    );
  }
}

class ChatConversation {
  final int id;
  final List<ChatUser> participants;
  final String? relatedObjectType;
  final int? relatedObjectId;
  final DateTime updatedAt;
  final ChatMessage? lastMessage;
  final int unreadCount;

  ChatConversation({
    required this.id,
    required this.participants,
    this.relatedObjectType,
    this.relatedObjectId,
    required this.updatedAt,
    this.lastMessage,
    required this.unreadCount,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      participants: (json['participants'] as List?)
              ?.map((p) => ChatUser.fromJson(p))
              .toList() ??
          [],
      relatedObjectType: json['related_object_type'],
      relatedObjectId: json['related_object_id'],
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
      lastMessage: json['last_message'] != null
          ? ChatMessage.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
    );
  }

  ChatUser? getOtherParticipant(int currentUserId) {
    try {
      return participants.firstWhere((p) => p.id != currentUserId);
    } catch (e) {
      return null;
    }
  }
}
