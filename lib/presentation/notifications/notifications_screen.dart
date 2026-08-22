import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notifications for UI parity
    final notifications = [
      'Your post was approved.',
      'New job posted in your favorite category.',
      'Emergency alert: Road block near Downtown.',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notifications.isEmpty
          ? const Center(child: Text('No new notifications.'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.teal),
                  title: Text(notifications[index]),
                  subtitle: const Text('Just now'),
                );
              },
            ),
    );
  }
}
