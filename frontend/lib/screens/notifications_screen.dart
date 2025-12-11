// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../providers/user_provider.dart';
import '../models/notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _filter = 'all'; // all, unread, appointment, result, alert

  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    final userNotifications = notificationService
        .getNotificationsForUser(userProvider.currentUserId ?? '')
        .where((n) {
          if (_filter == 'all') return true;
          if (_filter == 'unread') return !n.isRead;
          return n.type == _filter;
        })
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (notificationService.unreadCount > 0)
            IconButton(
              icon: Badge(
                label: Text(notificationService.unreadCount.toString()),
                child: const Icon(Icons.notifications),
              ),
              onPressed: () {
                notificationService.markAllAsRead();
                setState(() {});
              },
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _filter = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Toutes')),
              const PopupMenuItem(value: 'unread', child: Text('Non lues')),
              const PopupMenuItem(value: 'appointment', child: Text('Rendez-vous')),
              const PopupMenuItem(value: 'result', child: Text('Résultats')),
              const PopupMenuItem(value: 'alert', child: Text('Alertes')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres rapides
          _buildFilterChips(),
          
          // Liste des notifications
          Expanded(
            child: userNotifications.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Aucune notification',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: userNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = userNotifications[index];
                        return _buildNotificationCard(notification);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('Toutes'),
              selected: _filter == 'all',
              onSelected: (_) => setState(() => _filter = 'all'),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Non lues'),
              selected: _filter == 'unread',
              onSelected: (_) => setState(() => _filter = 'unread'),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Rendez-vous'),
              selected: _filter == 'appointment',
              onSelected: (_) => setState(() => _filter = 'appointment'),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Résultats'),
              selected: _filter == 'result',
              onSelected: (_) => setState(() => _filter = 'result'),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Alertes'),
              selected: _filter == 'alert',
              onSelected: (_) => setState(() => _filter = 'alert'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(MedicalNotification notification) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.color.withOpacity(0.2),
          child: Icon(notification.icon, color: notification.color),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              notification.formattedTime,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : const Icon(Icons.circle, size: 10, color: Colors.blue),
        onTap: () {
          Provider.of<NotificationService>(context, listen: false)
              .markAsRead(notification.id);
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  void _handleNotificationTap(MedicalNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notification.message),
              const SizedBox(height: 16),
              Text(
                notification.formattedTime,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}