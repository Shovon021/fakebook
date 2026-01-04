import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/post_model.dart';
import '../theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../utils/image_helper.dart';
import '../utils/reaction_assets.dart'; // Added import
import 'comment_bottom_sheet.dart';
import 'share_bottom_sheet.dart';
import '../screens/photo_viewer_screen.dart';
import '../screens/profile_screen.dart';
import 'reactions/reaction_button.dart';
import '../services/post_service.dart';
import '../providers/current_user_provider.dart';

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
  bool _isTextExpanded = false; // Removed _showReactions
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

  void _showOptions(BuildContext context) {
    final currentUser = currentUserProvider.currentUserOrDefault;
    final isAuthor = currentUser.id == widget.post.author.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF242526) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (isAuthor)
              ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: isDark ? const Color(0xFF3A3B3C) : Colors.grey[200],
                  child: Icon(Icons.delete, color: isDark ? Colors.white : Colors.black, size: 22),
                ),
                title: Text(
                  'Move to Trash',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Items in your trash are deleted after 30 days',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context); // Close sheet
                  // Confirm dialog
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: isDark ? const Color(0xFF242526) : Colors.white,
                      title: Text('Move to Trash?', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                      content: Text('Do you really want to delete this post?', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800])),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Move', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                     await PostService().deletePost(widget.post.id);
                  }
                },
              )
            else
               ListTile(
                 leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: isDark ? const Color(0xFF3A3B3C) : Colors.grey[200],
                  child: Icon(Icons.bookmark_border, color: isDark ? Colors.white : Colors.black, size: 22),
                ),
                 title: Text(
                   'Save Post',
                   style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                 ),
                 subtitle: Text(
                  'Add this to your saved items.',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                 onTap: () { Navigator.pop(context); },
               ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242526) : Colors.white,
        // Only apply standard FB shadow in light mode, or none for flat look depending on preference. 
        // Modern FB mobile is slightly elevated or flat with spacer.
        // Let's go with flat but separated by Spacer (handled by margin)
        // But the user requested "glowcy" so we add a subtle shadow
        boxShadow: isDark ? null : AppTheme.cardShadow, 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => ProfileScreen(user: widget.post.author))
                  ),
                  child: CircleAvatar(
                    radius: 21,
                    backgroundImage: ImageHelper.getImageProvider(
                      widget.post.author.avatarUrl,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => ProfileScreen(user: widget.post.author))
                        ),
                        child: Text(
                          widget.post.author.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? Colors.white : AppTheme.black,
                          ),
                        ),
                      ),
                      if (widget.post.type == 'profile_picture')
                        Text(
                          'updated their profile picture.',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 14,
                          ),
                        )
                      else if (widget.post.type == 'cover_photo')
                        Text(
                          'updated their cover photo.',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 14,
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
                  onPressed: () => _showOptions(context),
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
                    ImageHelper.getNetworkImage(
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
                   if (widget.post.type == 'profile_picture')
                     SizedBox(
                      height: 350,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Blurred Background
                          Positioned.fill(
                            child: ImageHelper.getNetworkImage(
                              imageUrl: widget.post.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                             child: Container(
                               color: Colors.white.withValues(alpha: 0.85), // Light overlay to soft blur look
                             ),
                           ),
                           if (isDark)
                            Positioned.fill(
                             child: Container(
                               color: Colors.black.withValues(alpha: 0.7), // Dark overlay for dark mode
                             ),
                           ),
                          
                          // Circular Profile Picture
                          Container(
                            padding: const EdgeInsets.all(4), // White border spacing
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? const Color(0xFF242526) : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                              ]
                            ),
                            child: CircleAvatar(
                              radius: 140,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: ImageHelper.getImageProvider(widget.post.imageUrl!),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    if (widget.post.videoUrl != null)
                      _FeedVideoPlayer(videoUrl: widget.post.videoUrl!)
                    else
                      ImageHelper.getNetworkImage(
                        imageUrl: widget.post.imageUrl!,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),

          // Reaction counts
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              color: isDark ? const Color(0xFF3E4042) : const Color(0xFFCED0D4), // Polished divider color
              thickness: 0.5,
            ),
          ),
          // Action buttons
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4), // Better vertical spacing
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Better distribution
                  children: [
                    Expanded(
                      child: ReactionButton(
                        initialReaction: _currentReaction,
                        onReactionChanged: (reaction) async {
                          final userId = currentUserProvider.userId;
                          if (userId == null) return;

                          // Optimistic update
                          setState(() {
                             _currentReaction = reaction;
                             if (reaction == ReactionType.like) {
                              _showHeartAnimation = true;
                              _animationController.forward();
                             }
                          });

                          // Call service
                          await PostService().updateReaction(
                            postId: widget.post.id, 
                            userId: userId,
                            postAuthorId: widget.post.author.id,
                            reactionType: reaction,
                          );
                        },
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
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context) => ShareBottomSheet(post: widget.post),
                          );
                        },
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReactionIcons() {
    // We want to show a stack of icons. 
    // If user reacted, show their reaction first.
    // Then show Like and Love as defaults if we have enough counts.
    
    final reactionsToShow = <ReactionType>[];
    
    // 1. User's reaction
    if (_currentReaction != null) {
      reactionsToShow.add(_currentReaction!);
    }
    
    // 2. Add defaults if not present
    if (!reactionsToShow.contains(ReactionType.like)) reactionsToShow.add(ReactionType.like);
    if (!reactionsToShow.contains(ReactionType.love)) reactionsToShow.add(ReactionType.love);
    
    // Take top 3
    final visibleReactions = reactionsToShow.take(3).toList();
    
    return SizedBox(
      width: 18.0 * visibleReactions.length + 4, // Dynamic width
      height: 20,
      child: Stack(
        children: List.generate(visibleReactions.length, (index) {
          final type = visibleReactions[index];
          return Positioned(
            left: index * 16.0,
            child: Container(
              width: 18, // Slightly smaller icons for sharper look
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFF242526) 
                      : Colors.white, 
                  width: 1.5
                ), // Cutout effect matching bg
                color: Colors.white,
              ),
              child: ClipOval(
                child: SvgPicture.network(
                  ReactionAssets.getReactionIcon(type),
                  width: 16,
                  height: 16,
                  fit: BoxFit.cover,
                  placeholderBuilder: (context) => Text(
                    ReactionAssets.getReactionEmoji(type),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ),
          );
        }).reversed.toList(), // Reverse to make first item on top
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
      child: Hero(
        tag: url,
        child: ImageHelper.getNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
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

  String _getReactionLabel(ReactionType? reaction) {
    switch (reaction) {
      case ReactionType.like: return 'Like';
      case ReactionType.love: return 'Love';
      case ReactionType.care: return 'Care';
      case ReactionType.haha: return 'Haha';
      case ReactionType.wow: return 'Wow';
      case ReactionType.sad: return 'Sad';
      case ReactionType.angry: return 'Angry';
      default: return 'Like';
    }
  }
}

// Helper widget for playing videos in the feed
class _FeedVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const _FeedVideoPlayer({required this.videoUrl});

  @override
  State<_FeedVideoPlayer> createState() => _FeedVideoPlayerState();
}

class _FeedVideoPlayerState extends State<_FeedVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller.initialize();
      _controller.setLooping(true);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Video player error: $e');
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  void _togglePlay() {
    if (!_isInitialized) return;

    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _controller.play();
      } else {
        _controller.pause();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 300,
        color: Colors.grey[900],
        child: const Center(
            child: Icon(Icons.error_outline, color: Colors.white, size: 40)),
      );
    }

    if (!_isInitialized) {
      return Container(
        height: 300,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.facebookBlue),
        ),
      );
    }

    return GestureDetector(
      onTap: _togglePlay,
      child: Container(
        color: Colors.black,
        height: 300, // Fixed height for feed consistency
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            if (!_isPlaying)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              
            // Sound icon (mute/unmute placeholder for now)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volume_up, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
