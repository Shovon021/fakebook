import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';

class WatchScreen extends StatelessWidget {
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListView(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Watch',
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
                      Icons.person_outline,
                      color: isDark ? Colors.white : AppTheme.black,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
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
        // Categories
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildCategoryChip('For You', true, isDark),
              _buildCategoryChip('Live', false, isDark),
              _buildCategoryChip('Gaming', false, isDark),
              _buildCategoryChip('Following', false, isDark),
              _buildCategoryChip('Reels', false, isDark),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Video posts
        ...List.generate(5, (index) => _buildVideoPost(context, index, isDark)),
      ],
    );
  }

  Widget _buildCategoryChip(String label, bool isActive, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        backgroundColor: isActive 
            ? AppTheme.facebookBlue 
            : (isDark ? const Color(0xFF3A3B3C) : AppTheme.lightGrey),
        labelStyle: TextStyle(
          color: isActive 
              ? Colors.white 
              : (isDark ? Colors.white : AppTheme.black),
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildVideoPost(BuildContext context, int index, bool isDark) {
    final user = DummyData.users[index % DummyData.users.length];
    final videoImages = [
      'https://picsum.photos/seed/video1/800/450',
      'https://picsum.photos/seed/video2/800/450',
      'https://picsum.photos/seed/video3/800/450',
      'https://picsum.photos/seed/video4/800/450',
      'https://picsum.photos/seed/video5/800/450',
    ];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? const Color(0xFF242526) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: CachedNetworkImageProvider(user.avatarUrl),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.black,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${(index + 1) * 234}K views',
                            style: TextStyle(
                              color: isDark 
                                  ? const Color(0xFFB0B3B8) 
                                  : AppTheme.mediumGrey,
                              fontSize: 12,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? const Color(0xFFB0B3B8) 
                                  : AppTheme.mediumGrey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            '${index + 1}h ago',
                            style: TextStyle(
                              color: isDark 
                                  ? const Color(0xFFB0B3B8) 
                                  : AppTheme.mediumGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.facebookBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Follow',
                    style: TextStyle(
                      color: AppTheme.facebookBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.more_horiz,
                  color: isDark ? Colors.white : AppTheme.black,
                ),
              ],
            ),
          ),
          // Video thumbnail
          Stack(
            alignment: Alignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: videoImages[index % videoImages.length],
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 250,
                  color: Colors.grey[300],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              // Duration
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(index + 1) * 2}:${(index + 3) * 7 % 60}'.padLeft(4, '0'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Video title
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Amazing video content #${index + 1} - Check this out! 🔥',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : AppTheme.black,
              ),
            ),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(Icons.thumb_up_outlined, 'Like', isDark),
                _buildActionButton(Icons.chat_bubble_outline, 'Comment', isDark),
                _buildActionButton(Icons.share_outlined, 'Share', isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          color: isDark ? const Color(0xFFB0B3B8) : AppTheme.mediumGrey,
          size: 20,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: isDark ? const Color(0xFFB0B3B8) : AppTheme.mediumGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
