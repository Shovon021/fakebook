import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

class WatchScreen extends StatefulWidget {
  const WatchScreen({super.key});

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  int _playingIndex = 0;

  @override
  void initState() {
    super.initState();
    // Simulate auto-scrolling execution/auto-play switch every 6 seconds
    Future.delayed(const Duration(seconds: 2), () => _autoPlayLoop());
  }

  void _autoPlayLoop() async {
    if (!mounted) return;
    await Future.delayed(const Duration(seconds: 6));
    if (mounted) {
      setState(() {
        _playingIndex = (_playingIndex + 1) % 5;
      });
      _autoPlayLoop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch tab is always dark in this "immersive" mode
    const isDark = true;
    
    return Container(
      color: const Color(0xFF18191A), // Always dark background for Watch
      child: ListView(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Watch',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3A3B3C),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3A3B3C),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
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
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isActive, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        backgroundColor: isActive 
            ? AppTheme.facebookBlue 
            : const Color(0xFF3A3B3C),
        labelStyle: const TextStyle(
          color: Colors.white,
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
    // Use placeholder users for now
    final placeholderUsers = [
      UserModel(id: '1', name: 'Video Creator', avatarUrl: 'https://picsum.photos/seed/vid1/150'),
      UserModel(id: '2', name: 'Content Producer', avatarUrl: 'https://picsum.photos/seed/vid2/150'),
      UserModel(id: '3', name: 'Film Maker', avatarUrl: 'https://picsum.photos/seed/vid3/150'),
    ];
    final user = placeholderUsers[index % placeholderUsers.length];
    final videoImages = [
      'https://picsum.photos/seed/video1/800/450',
      'https://picsum.photos/seed/video2/800/450',
      'https://picsum.photos/seed/video3/800/450',
      'https://picsum.photos/seed/video4/800/450',
      'https://picsum.photos/seed/video5/800/450',
    ];
    
    final isPlaying = index == _playingIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFF242526),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${(index + 1) * 234}K views',
                            style: const TextStyle(
                              color: Color(0xFFB0B3B8),
                              fontSize: 12,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: Color(0xFFB0B3B8),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            '${index + 1}h ago',
                            style: const TextStyle(
                              color: Color(0xFFB0B3B8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {}, 
                  child: const Text('Follow', style: TextStyle(color: AppTheme.facebookBlue)),
                ),
                const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          // Video title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              'Amazing video content #${index + 1} - Check this out! 🔥',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Video thumbnail / Player
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
                  color: const Color(0xFF3A3B3C),
                ),
              ),
              if (!isPlaying)
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
              if (isPlaying)
                 Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 150, // Simulated progress
                        color: Colors.red,
                      ),
                    ),
                 ),
              // Duration
              if (!isPlaying)
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
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
