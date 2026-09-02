import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../messages/chat_screen.dart';
import '../../auth/auth_provider.dart';

class ChatInitiatorButton extends ConsumerStatefulWidget {
  final int targetUserId;
  final String title; // Usually the property title or job title
  final String? initialMessage;
  final String? relatedObjectType;
  final int? relatedObjectId;
  final Widget? icon;
  final String label;
  final Color backgroundColor;

  const ChatInitiatorButton({
    super.key,
    required this.targetUserId,
    required this.title,
    this.initialMessage,
    this.relatedObjectType,
    this.relatedObjectId,
    this.icon,
    this.label = 'মেসেজ',
    this.backgroundColor = const Color(0xFF25D366),
  });

  @override
  ConsumerState<ChatInitiatorButton> createState() => _ChatInitiatorButtonState();
}

class _ChatInitiatorButtonState extends ConsumerState<ChatInitiatorButton> {
  bool _isLoading = false;

  Future<void> _initiateChat() async {
    final userState = ref.read(authStateProvider);
    if (userState.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে লগইন করুন')),
      );
      return;
    }

    if (userState.value!.id == widget.targetUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('আপনি নিজেকে মেসেজ দিতে পারবেন না')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(chatRepositoryProvider);
      final conversation = await repository.initiateConversation(
        userId: widget.targetUserId,
        relatedObjectType: widget.relatedObjectType,
        relatedObjectId: widget.relatedObjectId,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            title: widget.title,
            conversationId: conversation.id,
            initialMessage: widget.initialMessage,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('চ্যাট শুরু করতে সমস্যা হয়েছে')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        label: const Text('অপেক্ষা করুন...'),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor.withOpacity(0.5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: _initiateChat,
      icon: widget.icon ?? const Icon(Icons.chat_rounded),
      label: Text(widget.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.backgroundColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}
