import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import '../my_listings/navigation_utils.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<dynamic>? _notifications;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final list = await ref.read(authRepositoryProvider).getNotifications();
      if (mounted) {
        setState(() {
          _notifications = list;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('নোটিফিকেশন', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)], // sky-500 to blue-600
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Builder(
        builder: (context) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_error != null && (_notifications == null || _notifications!.isEmpty)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text('নোটিফিকেশন লোড করতে সমস্যা হয়েছে', style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      _fetchNotifications();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('আবার চেষ্টা করুন'),
                  ),
                ],
              ),
            );
          }

          final notifications = _notifications ?? [];

          if (notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: _fetchNotifications,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 80),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.notifications_active_outlined, size: 80, color: Colors.blue.shade300),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'কোনো নতুন নোটিফিকেশন নেই',
                              style: TextStyle(fontSize: 20, color: Colors.blueGrey.shade800, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'নতুন কোনো আপডেট আসলে এখানে দেখতে পাবেন',
                              style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade400),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _fetchNotifications,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final isRead = notif['read'] == true;

                return InkWell(
                  onTap: () async {
                    final notifId = notif['id'] ?? 0;
                    if (!isRead) {
                      setState(() {
                        notif['read'] = true;
                      });
                      ref.read(authRepositoryProvider).markNotificationRead(notifId);
                    }
                    if (notif is Map<String, dynamic>) {
                      await navigateToNotificationItem(context, ref, notif);
                    } else if (notif is Map) {
                      await navigateToNotificationItem(
                        context,
                        ref,
                        Map<String, dynamic>.from(notif),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isRead ? Colors.white : const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isRead ? Colors.grey.shade200 : const Color(0xFFBAE6FD),
                        width: isRead ? 1 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isRead ? Colors.black.withValues(alpha: 0.02) : const Color(0xFF0284C7).withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isRead ? Colors.grey.shade100 : const Color(0xFFE0F2FE),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                            color: isRead ? Colors.grey.shade500 : const Color(0xFF0284C7),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif['title'] ?? 'Notification',
                                style: TextStyle(
                                  fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                  fontSize: 15,
                                  color: isRead ? const Color(0xFF334155) : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif['message'] ?? notif['content'] ?? '',
                                style: TextStyle(
                                  color: isRead ? Colors.grey.shade600 : const Color(0xFF475569),
                                  fontSize: 13.5,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade400),
                                  const SizedBox(width: 4),
                                  Text(
                                    notif['created_at'] != null
                                        ? _formatDate(notif['created_at'])
                                        : 'মাত্রই',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                  if (!isRead) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF0284C7),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: isRead ? Colors.grey.shade300 : const Color(0xFF0284C7),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final difference = DateTime.now().difference(date);
      if (difference.inDays > 0) return '${difference.inDays} দিন আগে';
      if (difference.inHours > 0) return '${difference.inHours} ঘণ্টা আগে';
      if (difference.inMinutes > 0) return '${difference.inMinutes} মিনিট আগে';
      return 'মাত্রই';
    } catch (e) {
      return dateString;
    }
  }
}
