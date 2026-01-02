import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A reusable empty state widget with illustration and call-to-action
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container with background
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.facebookBlue).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 56,
                color: iconColor ?? AppTheme.facebookBlue,
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.facebookBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(buttonText!, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pre-configured empty states for common scenarios
class EmptyStates {
  static Widget noFriends({VoidCallback? onFindFriends}) => EmptyStateWidget(
    icon: Icons.people_outline,
    title: 'No friends yet',
    subtitle: 'Connect with people you know and build your network',
    buttonText: 'Find Friends',
    onButtonPressed: onFindFriends,
    iconColor: Colors.green,
  );

  static Widget noNotifications() => const EmptyStateWidget(
    icon: Icons.notifications_none,
    title: 'No notifications',
    subtitle: 'When you have notifications, they\'ll appear here',
    iconColor: Colors.purple,
  );

  static Widget noMessages({VoidCallback? onStartChat}) => EmptyStateWidget(
    icon: Icons.chat_bubble_outline,
    title: 'No messages yet',
    subtitle: 'Start a conversation with your friends',
    buttonText: 'Start a Chat',
    onButtonPressed: onStartChat,
    iconColor: Colors.blue,
  );

  static Widget noPosts({VoidCallback? onCreatePost}) => EmptyStateWidget(
    icon: Icons.article_outlined,
    title: 'No posts yet',
    subtitle: 'Share what\'s on your mind with your friends',
    buttonText: 'Create Post',
    onButtonPressed: onCreatePost,
    iconColor: Colors.orange,
  );

  static Widget noPhotos() => const EmptyStateWidget(
    icon: Icons.photo_library_outlined,
    title: 'No photos yet',
    subtitle: 'Photos you share will appear here',
    iconColor: Colors.teal,
  );

  static Widget noReels() => const EmptyStateWidget(
    icon: Icons.video_library_outlined,
    title: 'No reels yet',
    subtitle: 'Create and share short videos',
    iconColor: Colors.red,
  );

  static Widget noResults() => const EmptyStateWidget(
    icon: Icons.search_off,
    title: 'No results found',
    subtitle: 'Try searching with different keywords',
    iconColor: Colors.grey,
  );

  static Widget noMarketplaceItems({VoidCallback? onCreateListing}) => EmptyStateWidget(
    icon: Icons.storefront_outlined,
    title: 'No items yet',
    subtitle: 'Be the first to list an item for sale',
    buttonText: 'Sell Something',
    onButtonPressed: onCreateListing,
    iconColor: Colors.indigo,
  );
}
