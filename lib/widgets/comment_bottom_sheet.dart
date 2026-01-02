import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../providers/current_user_provider.dart';
import '../theme/app_theme.dart';
import 'shared_ui.dart';
import '../utils/image_helper.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitComment() async {
    if (_controller.text.isEmpty) return;
    
    final userId = currentUserProvider.userId;
    if (userId == null) return;

    final content = _controller.text;
    _controller.clear();
    _focusNode.unfocus();

    await PostService().addComment(
      postId: widget.post.id,
      userId: userId,
      content: content,
    );
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
            child: StreamBuilder<QuerySnapshot>(
              stream: PostService().getCommentsStream(widget.post.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final comments = snapshot.data!.docs;

                if (comments.isEmpty) {
                  return Center(
                    child: Text(
                      'No comments yet. Be the first!',
                      style: TextStyle(
                        color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final doc = comments[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    return FutureBuilder<UserModel?>(
                      future: UserService().getUserById(data['userId']),
                      builder: (context, userSnapshot) {
                         if (!userSnapshot.hasData) return const SizedBox.shrink();
                         final user = userSnapshot.data!;
                         return _buildRealCommentItem(context, user, data, isDark);
                      },
                    );
                  },
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
                            onSubmitted: (_) => _submitComment(),
                          ),
                        ),
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

  Widget _buildRealCommentItem(BuildContext context, UserModel user, Map<String, dynamic> data, bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: ImageHelper.getImageProvider(user.avatarUrl),
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
                            user.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? Colors.white : AppTheme.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            data['content'] ?? '',
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
                          'Now', // Simple time
                          style: TextStyle(
                            color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
