import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import 'shared_ui.dart';

class CommentBottomSheet extends StatefulWidget {
  final PostModel post;

  const CommentBottomSheet({
    super.key,
    required this.post,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  // Mock comments
  final List<Map<String, dynamic>> _comments = [
    {
      'user': 'Sarah Johnson',
      'avatar': 'https://picsum.photos/seed/user1/150/150',
      'text': 'This looks amazing! 😍',
      'time': '2h',
      'likes': 12,
    },
    {
      'user': 'Mike Wilson',
      'avatar': 'https://picsum.photos/seed/user2/150/150',
      'text': 'Great shot! Where was this taken?',
      'time': '5h',
      'likes': 5,
    },
    {
      'user': 'Emily Davis',
      'avatar': 'https://picsum.photos/seed/user3/150/150',
      'text': 'Best vibes ever 🔥',
      'time': '1d',
      'likes': 24,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242526) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle Bar
          const BottomSheetHandle(),
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 50),
                Row(
                  children: [
                    _buildReactionIcon(Icons.thumb_up, AppTheme.facebookBlue),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.post.likesCount}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_right, color: Colors.grey, size: 20),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Comments List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: CachedNetworkImageProvider(comment['avatar']),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF3A3B3C) : const Color(0xFFF0F2F5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment['user'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isDark ? Colors.white : AppTheme.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    comment['text'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? Colors.white : AppTheme.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  comment['time'],
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Like',
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Reply',
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (comment['likes'] > 0) ...[
                                  const Spacer(),
                                  Text(
                                    '${comment['likes']}',
                                    style: TextStyle(
                                      color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.facebookBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.thumb_up, color: Colors.white, size: 8),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Input Field
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + keyboardHeight),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF242526) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Camera Icon (left)
                IconButton(
                  icon: Icon(Icons.camera_alt_outlined, 
                    color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                    size: 22,
                  ),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                // Text Input
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3A3B3C) : const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Write a comment...',
                              hintStyle: TextStyle(
                                color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : AppTheme.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        // Emoji, GIF, Sticker icons inside input
                        Icon(Icons.emoji_emotions_outlined, 
                          color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600], 
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.gif_box_outlined, 
                          color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600], 
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.sticky_note_2_outlined, 
                          color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600], 
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Send Button
                GestureDetector(
                  onTap: () {
                    if (_controller.text.isNotEmpty) {
                      setState(() {
                         _comments.add({
                            'user': DummyData.currentUser.name,
                            'avatar': DummyData.currentUser.avatarUrl,
                            'text': _controller.text,
                            'time': 'Just now',
                            'likes': 0,
                         });
                         _controller.clear();
                      });
                    }
                  },
                  child: Icon(
                    Icons.send,
                    color: _controller.text.isNotEmpty ? AppTheme.facebookBlue : Colors.grey,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionIcon(IconData icon, Color color) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(icon, color: Colors.white, size: 10),
    );
  }
}
