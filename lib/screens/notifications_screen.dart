import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/notification_model.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';
import '../providers/current_user_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    // Notifications will come from stream
  }

  void _markAsRead(NotificationModel notification) {
    setState(() {
      final index = _notifications.indexOf(notification);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: notification.id,
          type: notification.type,
          avatarUrl: notification.avatarUrl,
          title: notification.title,
          body: notification.body,
          createdAt: notification.createdAt,
          isRead: true, 
        );
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => NotificationModel(
          id: n.id,
          type: n.type,
          avatarUrl: n.avatarUrl,
          title: n.title,
          body: n.body,
          createdAt: n.createdAt,
          isRead: true,
      )).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final newNotifications = _notifications.where((n) => !n.isRead).toList();
    final earlierNotifications = _notifications.where((n) => n.isRead).toList();
    
    return ListView(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.black,
                ),
              ),
              Row(
                children: [
                   Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3A3B3C) : AppTheme.lightGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search,
                      color: isDark ? Colors.white : AppTheme.black,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Mark all as read button
        if (newNotifications.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: _markAllAsRead,
              child: Row(
                children: [
                  Icon(
                    Icons.done_all,
                    color: AppTheme.facebookBlue,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mark all as read',
                    style: TextStyle(
                      color: AppTheme.facebookBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        // New section
        if (newNotifications.isNotEmpty) ...[
           _buildSectionHeader('New', isDark),
           ...newNotifications.map((n) => _buildNotificationTile(n, isDark)),
        ],
        // Earlier section
        if (earlierNotifications.isNotEmpty) ...[
           _buildSectionHeader('Earlier', isDark),
           ...earlierNotifications.map((n) => _buildNotificationTile(n, isDark)),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppTheme.black,
        ),
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notification, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: notification.isRead 
            ? Colors.transparent 
            : (isDark 
                ? AppTheme.facebookBlue.withValues(alpha: 0.15)
                : AppTheme.facebookBlue.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: CachedNetworkImageProvider(
                notification.avatarUrl,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: _getNotificationIconColor(notification.type),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF242526) : Colors.white,
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white : AppTheme.black,
              height: 1.3,
            ),
            children: [
              TextSpan(
                text: notification.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' ${notification.body}'),
            ],
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: const BoxDecoration(
                    color: AppTheme.facebookBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              Text(
                notification.timeAgo,
                style: TextStyle(
                  color: notification.isRead 
                      ? (isDark ? const Color(0xFFB0B3B8) : AppTheme.mediumGrey)
                      : AppTheme.facebookBlue,
                  fontSize: 13,
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.more_horiz,
            color: isDark ? const Color(0xFFB0B3B8) : AppTheme.mediumGrey,
          ),
          onPressed: () {},
        ),
        onTap: () {
          _markAsRead(notification);
          // Navigate to content if needed
        },
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return Icons.thumb_up;
      case NotificationType.comment:
        return Icons.chat_bubble;
      case NotificationType.share:
        return Icons.share;
      case NotificationType.friendRequest:
        return Icons.person_add;
      case NotificationType.birthday:
        return Icons.cake;
      case NotificationType.memory:
        return Icons.photo_library;
      case NotificationType.tag:
        return Icons.local_offer;
      case NotificationType.groupActivity:
        return Icons.group;
    }
  }

  Color _getNotificationIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return AppTheme.facebookBlue;
      case NotificationType.comment:
        return Colors.green;
      case NotificationType.share:
        return Colors.orange;
      case NotificationType.friendRequest:
        return AppTheme.facebookBlue;
      case NotificationType.birthday:
        return Colors.pink;
      case NotificationType.memory:
        return Colors.purple;
      case NotificationType.tag:
        return Colors.teal;
      case NotificationType.groupActivity:
        return AppTheme.facebookBlue;
    }
  }
}
