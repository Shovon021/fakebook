import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Added
import '../models/post_model.dart';
import '../providers/current_user_provider.dart';
import '../theme/app_theme.dart';
import 'shared_ui.dart';
import '../utils/image_helper.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../utils/reaction_assets.dart'; // Added

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
  String? _replyingToUserId;
  String? _replyingToUserName;
  final Set<String> _likedComments = {};

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
    
    // Clear reply state
    setState(() {
      _replyingToUserId = null;
      _replyingToUserName = null;
    });

    await PostService().addComment(
      postId: widget.post.id,
      userId: userId,
      content: content,
      postAuthorId: widget.post.author.id,
    );
    
    HapticFeedback.lightImpact();
  }

  void _startReply(String userId, String userName) {
    setState(() {
      _replyingToUserId = userId;
      _replyingToUserName = userName;
    });
    _focusNode.requestFocus();
    HapticFeedback.selectionClick();
  }

  void _cancelReply() {
    setState(() {
      _replyingToUserId = null;
      _replyingToUserName = null;
    });
  }

  void _toggleLikeComment(String commentId) {
    setState(() {
      if (_likedComments.contains(commentId)) {
        _likedComments.remove(commentId);
      } else {
        _likedComments.add(commentId);
        HapticFeedback.lightImpact();
      }
    });
  }

  String _getTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'now';
    final diff = DateTime.now().difference(timestamp.toDate());
    if (diff.inSeconds < 60) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Row(
                  children: [
                    _buildReactionIcons(),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.post.likesCount}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppTheme.black,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
                    ),
                  ],
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: isDark ? Colors.grey : Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No comments yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Be the first to comment!',
                          style: TextStyle(
                            color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                          ),
                        ),
                      ],
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
                         return _buildCommentItem(
                           context, 
                           doc.id,
                           user, 
                           data, 
                           isDark,
                         );
                      },
                    );
                  },
                );
              },
            ),
          ),
          
          // Reply indicator
          if (_replyingToUserName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[100],
              child: Row(
                children: [
                  Icon(Icons.reply, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to $_replyingToUserName',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[700],
                        fontSize: 13,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: Icon(Icons.close, size: 18, color: Colors.grey[600]),
                  ),
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
                CircleAvatar(
                  radius: 16,
                  backgroundImage: ImageHelper.getImageProvider(
                    currentUserProvider.currentUserOrDefault.avatarUrl,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3A3B3C) : const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              hintText: _replyingToUserName != null 
                                  ? 'Reply to $_replyingToUserName...'
                                  : 'Write a comment...',
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
                        GestureDetector(
                          onTap: () {},
                          child: Icon(Icons.emoji_emotions_outlined, 
                            color: Colors.grey[500], 
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {},
                          child: Icon(Icons.camera_alt_outlined, 
                            color: Colors.grey[500], 
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _submitComment,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppTheme.facebookBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(
    BuildContext context, 
    String commentId,
    UserModel user, 
    Map<String, dynamic> data, 
    bool isDark,
  ) {
    final isLiked = _likedComments.contains(commentId);
    final timeAgo = _getTimeAgo(data['createdAt'] as Timestamp?);
    
    return Padding(
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
                // Comment bubble
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3A3B3C) : const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(18),
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
                          fontSize: 15,
                          color: isDark ? Colors.white : AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Action row
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(
                    children: [
                      Text(
                        timeAgo,
                        style: TextStyle(
                          color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _toggleLikeComment(commentId),
                        child: Text(
                          'Like',
                          style: TextStyle(
                            color: isLiked ? AppTheme.facebookBlue : (isDark ? const Color(0xFFB0B3B8) : Colors.grey[700]),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _startReply(user.id, user.name),
                        child: Text(
                          'Reply',
                          style: TextStyle(
                            color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (isLiked)
                        Row(
                          children: [
                            const Icon(Icons.thumb_up, size: 12, color: AppTheme.facebookBlue),
                            const SizedBox(width: 4),
                            Text(
                              '1',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.grey[600],
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
      ),
    );
  }

  Widget _buildReactionIcons() {
    return SizedBox(
      width: 56,
      height: 22,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: _buildReactionBubble(ReactionType.like, Colors.blue),
          ),
          Positioned(
            left: 15,
            child: _buildReactionBubble(ReactionType.love, Colors.red),
          ),
          Positioned(
            left: 30,
            child: _buildReactionBubble(ReactionType.haha, Colors.amber),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionBubble(ReactionType type, Color color) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
           imageUrl: ReactionAssets.getReactionIcon(type),
           placeholder: (context, url) => Container(color: Colors.grey[200]),
           errorWidget: (context, url, err) => Container(color: color),
           fit: BoxFit.cover,
        ),
      ),
    );
  }
}
