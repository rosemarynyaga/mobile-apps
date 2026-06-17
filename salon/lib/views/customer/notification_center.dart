import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/salon_provider.dart';

class NotificationCenter extends ConsumerWidget {
  const NotificationCenter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsStream = ref.watch(supabaseServiceProvider).getNotifications();

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<Map<String, String>>>(
        stream: notificationsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final notifications = snapshot.data!;

          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final n = notifications[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFC2185B),
                  child: Icon(Icons.notifications, color: Colors.white),
                ),
                title: Text(n['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n['body']!),
                    const SizedBox(height: 4),
                    Text(n['time']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
