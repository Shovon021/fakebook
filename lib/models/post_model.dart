import 'package:flutter/material.dart';
import 'user_model.dart';

enum ReactionType { like, love, care, haha, wow, sad, angry }

class PostModel {
  final String id;
  final UserModel author;
  final String content;
  final String? imageUrl; // Kept for backward compatibility
  final List<String>? imagesUrl; // New: Multiple images
  final String? videoUrl; // New: Video posts
  final Color? backgroundColor; // New: Colored backgrounds
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final ReactionType? userReaction;
  final bool isShared;
  final PostModel? sharedPost;

  final String type; // 'regular', 'profile_picture', 'cover_photo'

  PostModel({
    required this.id,
    required this.author,
    required this.content,
    this.imageUrl,
    this.imagesUrl, // New
    this.videoUrl, // New
    this.backgroundColor, // New
    this.type = 'regular', // New
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.userReaction,
    this.isShared = false,
    this.sharedPost,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }
}
