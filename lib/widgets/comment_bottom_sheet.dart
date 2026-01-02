import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';
import '../providers/current_user_provider.dart';
import '../theme/app_theme.dart';
import 'shared_ui.dart';
import '../utils/image_helper.dart';

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
  final FocusNode _focusNode = FocusNode();
  int? _replyingToIndex; // Index of the comment being replied to

  // Mock comments with replies
  final List<Map<String, dynamic>> _comments = [
    {
      'user': 'Sarah Johnson',
      'avatar': 'https://picsum.photos/seed/user1/150/150',
      'text': 'This looks amazing! 😍',
      'time': '2h',
      'likes': 12,
      'replies': <Map<String, dynamic>>[],
    },
    {
      'user': 'Mike Wilson',
      'avatar': 'https://picsum.photos/seed/user2/150/150',
      'text': 'Great shot! Where was this taken?',
      'time': '5h',
      'likes': 5,
      'replies': <Map<String, dynamic>>[
        {
          'user': 'Post Author',
          'avatar': currentUserProvider.currentUserOrDefault.avatarUrl,
          'text': 'At the national park! 🌲',
          'time': '1h',
          'likes': 2,
        }
      ],
    },
    {
      'user': 'Emily Davis',
      'avatar': 'https://picsum.photos/seed/user3/150/150',
      'text': 'Best vibes ever 🔥',
      'time': '1d',
      'likes': 24,
      'replies': <Map<String, dynamic>>[],
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleReply(int index) {
    setState(() {
      _replyingToIndex = index;
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToIndex = null;
    });
    _focusNode.unfocus();
  }

  void _submitComment() {
    if (_controller.text.isEmpty) return;

    setState(() {
      final newComment = {
        'user': currentUserProvider.currentUserOrDefault.name,
        'avatar': currentUserProvider.currentUserOrDefault.avatarUrl,
        'text': _controller.text,
        'time': 'Just now',
        'likes': 0,
        'replies': <Map<String, dynamic>>[],
      };

      if (_replyingToIndex != null) {
        // Add as reply
        _comments[_replyingToIndex!]['replies'].add(newComment);
        _replyingToIndex = null; // Reset
      } else {
        // Add as main comment
        _comments.add(newComment);
      }
      _controller.clear();
    });
  }

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
                return _buildCommentItem(context, _comments[index], index, isDark);
              },
            ),
          ),
          
          // Reply Banner
          if (_replyingToIndex != null)
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
               color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[200],
               child: Row(
                 children: [
                   Text(
                     'Replying to ${_comments[_replyingToIndex!]['user']}',
                     style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                   ),
                   const Spacer(),
                   GestureDetector(
                     onTap: _cancelReply,
                     child: const Icon(Icons.close, size: 16, color: Colors.grey),
                   )
                 ],
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
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              hintText: _replyingToIndex != null ? 'Write a reply...' : 'Write a comment...',
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
                            onSubmitted: (_) => _submitComment(),
                          ),
                        ),
                        // Emoji, GIF, Sticker icons
                        Icon(Icons.emoji_emotions_outlined, 
                          color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600], 
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.gif_box_outlined, 
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
                  onTap: _submitComment,
                  child: const Icon(
                    Icons.send,
                    color: AppTheme.facebookBlue,
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

  Widget _buildCommentItem(BuildContext context, Map<String, dynamic> comment, int index, bool isDark) {
    return Column(
      children: [
        // Main Comment
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: ImageHelper.getImageProvider(comment['avatar']),
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
                        GestureDetector(
                           onTap: () {}, // Like logic (simplified)
                           child: Text(
                            'Like',
                            style: TextStyle(
                              color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => _handleReply(index),
                          child: Text(
                            'Reply',
                            style: TextStyle(
                              color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
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
        ),
        
        // Replies
        if (comment['replies'] != null && (comment['replies'] as List).isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: listReplies(comment['replies'], isDark),
          ),
      ],
    );
  }

  Widget listReplies(List<dynamic> replies, bool isDark) {
     return Column(
       children: replies.map((reply) {
         return Padding(
           padding: const EdgeInsets.only(bottom: 12),
           child: Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               CircleAvatar(
                 radius: 12,
                 backgroundImage: ImageHelper.getImageProvider(reply['avatar']),
               ),
               const SizedBox(width: 8),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF3A3B3C) : const Color(0xFFF0F2F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reply['user'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isDark ? Colors.white : AppTheme.black,
                              ),
                            ),
                            Text(
                              reply['text'],
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white : AppTheme.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                         children: [
                            const SizedBox(width: 8),
                            Text(reply['time'], style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                            const SizedBox(width: 12),
                             Text('Like', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                            const SizedBox(width: 12),
                             Text('Reply', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                         ],
                      ),
                   ],
                 ),
               )
             ],
           ),
         );
       }).toList(),
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
