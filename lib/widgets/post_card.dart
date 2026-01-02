import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';
import '../theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'comment_bottom_sheet.dart';
import '../screens/photo_viewer_screen.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  ReactionType? _currentReaction;
  bool _showReactions = false;
  bool _isTextExpanded = false;
  bool _showHeartAnimation = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _heartScaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentReaction = widget.post.userReaction;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _heartScaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() => _showHeartAnimation = false);
            _animationController.reset();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      color: isDark ? const Color(0xFF242526) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundImage: CachedNetworkImageProvider(
                    widget.post.author.avatarUrl,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.author.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? Colors.white : AppTheme.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            widget.post.timeAgo,
                            style: TextStyle(
                              color: isDark 
                                  ? const Color(0xFFB0B3B8) 
                                  : AppTheme.mediumGrey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? const Color(0xFFB0B3B8) 
                                  : AppTheme.mediumGrey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.public,
                            size: 13,
                            color: isDark 
                                ? const Color(0xFFB0B3B8) 
                                : AppTheme.mediumGrey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: isDark ? Colors.white : AppTheme.black,
                  ),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark ? const Color(0xFFB0B3B8) : AppTheme.mediumGrey,
                    size: 22,
                  ),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Content
          if (widget.post.backgroundColor != null)
            Container(
              width: double.infinity,
              height: 250,
              padding: const EdgeInsets.all(30),
              color: widget.post.backgroundColor,
              alignment: Alignment.center,
              child: Text(
                widget.post.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else if (widget.post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final textSpan = TextSpan(
                    text: widget.post.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white : AppTheme.black,
                      height: 1.3,
                    ),
                  );
                  final textPainter = TextPainter(
                    text: textSpan,
                    maxLines: 3,
                    textDirection: TextDirection.ltr,
                  );
                  textPainter.layout(maxWidth: constraints.maxWidth);
                  final isOverflowing = textPainter.didExceedMaxLines;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.content,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white : AppTheme.black,
                          height: 1.3,
                        ),
                        maxLines: _isTextExpanded ? null : 3,
                        overflow: _isTextExpanded ? null : TextOverflow.ellipsis,
                      ),
                      if (isOverflowing && !_isTextExpanded)
                        GestureDetector(
                          onTap: () => setState(() => _isTextExpanded = true),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'See more',
                              style: TextStyle(
                                color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          
          // Shared Post Content
          if (widget.post.sharedPost != null) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shared Post Header
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: CachedNetworkImageProvider(
                            widget.post.sharedPost!.author.avatarUrl,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.sharedPost!.author.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark ? Colors.white : AppTheme.black,
                              ),
                            ),
                            Text(
                              widget.post.sharedPost!.timeAgo,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark 
                                    ? const Color(0xFFB0B3B8) 
                                    : AppTheme.mediumGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Shared Content
                  if (widget.post.sharedPost!.content.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        widget.post.sharedPost!.content,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : AppTheme.black,
                        ),
                      ),
                    ),
                  if (widget.post.sharedPost!.imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: widget.post.sharedPost!.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                ],
              ),
            ),
          ],
          
          // Images
          if (widget.post.imagesUrl != null && widget.post.imagesUrl!.isNotEmpty)
            _buildImageGrid(widget.post.imagesUrl!, isDark)
          else if (widget.post.imageUrl != null) 
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhotoViewerScreen(
                      imageUrl: widget.post.imageUrl!,
                      post: widget.post,
                    ),
                  ),
                );
              },
              onDoubleTap: () {
                setState(() {
                  _currentReaction = ReactionType.like;
                  _showHeartAnimation = true;
                });
                _animationController.forward();
                HapticFeedback.lightImpact();
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.post.imageUrl!,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 300,
                      color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 300,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                  // Heart Animation Overlay
                  if (_showHeartAnimation)
                    ScaleTransition(
                      scale: _heartScaleAnimation,
                      child: const Icon(
                        Icons.favorite,
                        size: 100,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 20),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          // Reaction counts
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                if (widget.post.likesCount > 0) ...[
                  _buildReactionIcons(),
                  const SizedBox(width: 6),
                  Text(
                    _formatCount(widget.post.likesCount),
                    style: TextStyle(
                      color: isDark 
                          ? const Color(0xFFB0B3B8) 
                          : AppTheme.mediumGrey,
                      fontSize: 14,
                    ),
                  ),
                ],
                const Spacer(),
                if (widget.post.commentsCount > 0)
                  Text(
                    '${_formatCount(widget.post.commentsCount)} comments',
                    style: TextStyle(
                      color: isDark 
                          ? const Color(0xFFB0B3B8) 
                          : AppTheme.mediumGrey,
                      fontSize: 14,
                    ),
                  ),
                if (widget.post.sharesCount > 0) ...[
                  Text(
                    '  ·  ',
                    style: TextStyle(
                      color: isDark 
                          ? const Color(0xFFB0B3B8) 
                          : AppTheme.mediumGrey,
                    ),
                  ),
                  Text(
                    '${_formatCount(widget.post.sharesCount)} shares',
                    style: TextStyle(
                      color: isDark 
                          ? const Color(0xFFB0B3B8) 
                          : AppTheme.mediumGrey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Divider(
              height: 1,
              color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[300],
            ),
          ),
          // Action buttons
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onLongPress: () {
                          setState(() => _showReactions = true);
                        },
                        onLongPressEnd: (_) {
                          setState(() => _showReactions = false);
                        },
                        child: _buildActionButton(
                          icon: _getReactionIcon(_currentReaction),
                          label: _getReactionLabel(_currentReaction),
                          color: _getReactionColor(_currentReaction),
                          onTap: () {
                            setState(() {
                              if (_currentReaction != null) {
                                _currentReaction = null;
                              } else {
                                _currentReaction = ReactionType.like;
                              }
                            });
                            _animationController.forward().then((_) {
                              _animationController.reverse();
                            });
                             // Feature #1 (Polish): Haptic Feedback on Like
                            HapticFeedback.lightImpact();
                          },
                          isDark: isDark,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.chat_bubble_outline,
                        label: 'Comment',
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: CommentBottomSheet(post: widget.post),
                            ),
                          );
                        },
                        isDark: isDark,
                      ),
                    ),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.share_outlined,
                        label: 'Share',
                        onTap: () {},
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
              // Reaction popup
              if (_showReactions)
                Positioned(
                  left: 8,
                  bottom: 48,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3A3B3C) : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildReactionEmoji('👍', ReactionType.like),
                        _buildReactionEmoji('❤️', ReactionType.love),
                        _buildReactionEmoji('😂', ReactionType.haha),
                        _buildReactionEmoji('😮', ReactionType.wow),
                        _buildReactionEmoji('😢', ReactionType.sad),
                        _buildReactionEmoji('😡', ReactionType.angry),
                      ],
                    ),
                  ),
                ),
            ],
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
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppTheme.facebookBlue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(
                Icons.thumb_up,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: 15,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppTheme.loveRed,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Center(
                child: Text('❤️', style: TextStyle(fontSize: 11)),
              ),
            ),
          ),
          Positioned(
            left: 30,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppTheme.hahaYellow,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Center(
                child: Text('😂', style: TextStyle(fontSize: 11)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final buttonColor = color ?? (isDark ? const Color(0xFFB0B3B8) : AppTheme.mediumGrey);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: label == 'Like' || label == _getReactionLabel(_currentReaction) 
                    ? _scaleAnimation 
                    : const AlwaysStoppedAnimation(1.0),
                child: Icon(icon, size: 20, color: buttonColor),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: buttonColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReactionEmoji(String emoji, ReactionType type) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentReaction = type;
          _showReactions = false;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 30),
        ),
      ),
    );
  }

  IconData _getReactionIcon(ReactionType? reaction) {
    switch (reaction) {
      case ReactionType.like:
        return Icons.thumb_up;
      case ReactionType.love:
        return Icons.favorite;
      case ReactionType.haha:
      case ReactionType.wow:
      case ReactionType.sad:
      case ReactionType.angry:
        return Icons.emoji_emotions;
      default:
        return Icons.thumb_up_outlined;
    }
  }

  String _getReactionLabel(ReactionType? reaction) {
    switch (reaction) {
      case ReactionType.like:
        return 'Like';
      case ReactionType.love:
        return 'Love';
      case ReactionType.haha:
        return 'Haha';
      case ReactionType.wow:
        return 'Wow';
      case ReactionType.sad:
        return 'Sad';
      case ReactionType.angry:
        return 'Angry';
      default:
        return 'Like';
    }
  }

  Color _getReactionColor(ReactionType? reaction) {
    switch (reaction) {
      case ReactionType.like:
        return AppTheme.facebookBlue;
      case ReactionType.love:
        return AppTheme.loveRed;
      case ReactionType.haha:
      case ReactionType.wow:
      case ReactionType.sad:
        return AppTheme.hahaYellow;
      case ReactionType.angry:
        return AppTheme.angryOrange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildImageGrid(List<String> images, bool isDark) {
    if (images.length == 1) {
      return CachedNetworkImage(
        imageUrl: images[0],
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
      );
    }
    
    return AspectRatio(
      aspectRatio: 1,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _buildGridImage(images[0], isDark),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: _buildGridImage(images[1], isDark),
                ),
              ],
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _buildGridImage(images[2], isDark),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildGridImage(images[3], isDark),
                      if (images.length > 4)
                        Container(
                          color: Colors.black54,
                          alignment: Alignment.center,
                          child: Text(
                            '+${images.length - 4}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  Widget _buildGridImage(String url, bool isDark) {
    return GestureDetector(
      onTap: () {
         Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoViewerScreen(
              imageUrl: url,
              post: widget.post,
            ),
          ),
        );
      },
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(
          color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[200],
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
