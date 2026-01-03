class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String avatarUrl;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.avatarUrl,
    required this.createdAt,
    this.isRead = false,
    required this.type,
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> data) {
    return NotificationModel(
      id: id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      type: NotificationType.values.firstWhere(
        (e) => e.name == (data['type'] ?? 'like'),
        orElse: () => NotificationType.like,
      ),
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

enum NotificationType {
  like,
  comment,
  share,
  friendRequest,
  birthday,
  memory,
  tag,
  groupActivity,
}
