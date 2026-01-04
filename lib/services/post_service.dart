import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import 'notification_service.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // Get posts stream (real-time updates)
  Stream<List<PostModel>> getPostsStream({String? currentUserId}) {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .asyncMap((snapshot) async {
          List<PostModel> posts = [];
          for (var doc in snapshot.docs) {
            final data = doc.data();
            
            // 1. Fetch author data
            final authorId = data['authorId'];
            UserModel author;
            
            if (authorId != null) {
              final authorDoc = await _firestore
                  .collection('users')
                  .doc(authorId)
                  .get();
              
              author = authorDoc.exists
                  ? UserModel.fromMap(authorDoc.data()!)
                  : UserModel(id: authorId, name: 'Unknown User', avatarUrl: '');
            } else {
              author = UserModel(id: 'unknown', name: 'Unknown User', avatarUrl: '');
            }

            // 2. Check if current user liked this post
            ReactionType? userReaction;
            if (currentUserId != null) {
              final likeDoc = await _firestore
                  .collection('posts')
                  .doc(doc.id)
                  .collection('likes')
                  .doc(currentUserId)
                  .get();
              if (likeDoc.exists) {
                final data = likeDoc.data();
                if (data != null && data.containsKey('reaction')) {
                   // Parse string to enum
                   final reactionStr = data['reaction'] as String;
                   userReaction = ReactionType.values.firstWhere(
                     (e) => e.name == reactionStr, 
                     orElse: () => ReactionType.like
                   );
                } else {
                  userReaction = ReactionType.like; // Backward compatibility
                }
              }
            }

            // 3. Fetch Shared Post if applicable
            PostModel? sharedPost;
            bool isShared = data['sharedPostId'] != null;
            
            if (isShared) {
              final sharedDoc = await _firestore.collection('posts').doc(data['sharedPostId']).get();
              if (sharedDoc.exists) {
                final sharedData = sharedDoc.data()!;
                // Fetch shared post author
                final sharedAuthorDoc = await _firestore.collection('users').doc(sharedData['authorId']).get();
                final sharedAuthor = sharedAuthorDoc.exists
                    ? UserModel.fromMap(sharedAuthorDoc.data()!)
                    : UserModel(id: sharedData['authorId'], name: 'Unknown', avatarUrl: '');

                sharedPost = PostModel(
                  id: sharedDoc.id,
                  author: sharedAuthor,
                  content: sharedData['content'] ?? '',
                  imageUrl: sharedData['imageUrl'],
                  imagesUrl: sharedData['imagesUrl'] != null 
                      ? List<String>.from(sharedData['imagesUrl']) 
                      : null,
                  createdAt: (sharedData['createdAt'] as Timestamp).toDate(),
                  likesCount: sharedData['likesCount'] ?? 0,
                  commentsCount: sharedData['commentsCount'] ?? 0,
                  sharesCount: sharedData['sharesCount'] ?? 0,
                );
              }
            }
            
            posts.add(PostModel(
              id: doc.id,
              author: author,
              content: data['content'] ?? '',
              imageUrl: data['imageUrl'],
              imagesUrl: data['imagesUrl'] != null 
                  ? List<String>.from(data['imagesUrl']) 
                  : null,
              videoUrl: data['videoUrl'],
              likesCount: data['likesCount'] ?? 0,
              commentsCount: data['commentsCount'] ?? 0,
              sharesCount: data['sharesCount'] ?? 0,
              createdAt: (data['createdAt'] as Timestamp).toDate(),
              userReaction: userReaction,
              isShared: isShared,
              sharedPost: sharedPost,
              type: data['type'] ?? 'regular',
            ));
          }
          return posts;
        });
  }


  // Get posts for a specific user
  Stream<List<PostModel>> getUserPostsStream(String userId, {String? currentUserId}) {
    return _firestore
        .collection('posts')
        .where('authorId', isEqualTo: userId)
        // .orderBy('createdAt', descending: true) // Removed to avoid composite index requirement
        .snapshots()
        .asyncMap((snapshot) async {
          List<PostModel> posts = [];
          for (var doc in snapshot.docs) {
            final data = doc.data();
            
            // 1. Fetch author data
            final authorId = data['authorId'];
            UserModel author;
            
            if (authorId != null) {
              final authorDoc = await _firestore
                  .collection('users')
                  .doc(authorId)
                  .get();
              
              author = authorDoc.exists
                  ? UserModel.fromMap(authorDoc.data()!)
                  : UserModel(id: authorId, name: 'Unknown User', avatarUrl: '');
            } else {
              author = UserModel(id: 'unknown', name: 'Unknown User', avatarUrl: '');
            }

            // 2. Check if current user liked this post
            ReactionType? userReaction;
            if (currentUserId != null) {
              final likeDoc = await _firestore
                  .collection('posts')
                  .doc(doc.id)
                  .collection('likes')
                  .doc(currentUserId)
                  .get();
              if (likeDoc.exists) {
                final data = likeDoc.data();
                if (data != null && data.containsKey('reaction')) {
                   final reactionStr = data['reaction'] as String;
                   userReaction = ReactionType.values.firstWhere(
                     (e) => e.name == reactionStr, 
                     orElse: () => ReactionType.like
                   );
                } else {
                  userReaction = ReactionType.like;
                }
              }
            }

            // 3. Fetch Shared Post if applicable
            PostModel? sharedPost;
            bool isShared = data['sharedPostId'] != null;
            
            if (isShared) {
              final sharedDoc = await _firestore.collection('posts').doc(data['sharedPostId']).get();
              if (sharedDoc.exists) {
                final sharedData = sharedDoc.data()!;
                final sharedAuthorDoc = await _firestore.collection('users').doc(sharedData['authorId']).get();
                final sharedAuthor = sharedAuthorDoc.exists
                    ? UserModel.fromMap(sharedAuthorDoc.data()!)
                    : UserModel(id: sharedData['authorId'], name: 'Unknown', avatarUrl: '');

                sharedPost = PostModel(
                  id: sharedDoc.id,
                  author: sharedAuthor,
                  content: sharedData['content'] ?? '',
                  imageUrl: sharedData['imageUrl'],
                  imagesUrl: sharedData['imagesUrl'] != null 
                      ? List<String>.from(sharedData['imagesUrl']) 
                      : null,
                  createdAt: (sharedData['createdAt'] as Timestamp).toDate(),
                  likesCount: sharedData['likesCount'] ?? 0,
                  commentsCount: sharedData['commentsCount'] ?? 0,
                  sharesCount: sharedData['sharesCount'] ?? 0,
                );
              }
            }
            
            posts.add(PostModel(
              id: doc.id,
              author: author,
              content: data['content'] ?? '',
              imageUrl: data['imageUrl'],
              imagesUrl: data['imagesUrl'] != null 
                  ? List<String>.from(data['imagesUrl']) 
                  : null,
              videoUrl: data['videoUrl'],
              likesCount: data['likesCount'] ?? 0,
              commentsCount: data['commentsCount'] ?? 0,
              sharesCount: data['sharesCount'] ?? 0,
              createdAt: (data['createdAt'] as Timestamp).toDate(),
              userReaction: userReaction,
              isShared: isShared,
              sharedPost: sharedPost,
              type: data['type'] ?? 'regular',
            ));
          }
          
          // Client-side sorting
          posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          return posts;
        });
  }

  // Create a new post
  Future<String?> createPost({
    required String authorId,
    required String content,
    String? imageUrl,
    List<String>? imagesUrl,
    String? videoUrl,
    String? sharedPostId,
    String type = 'regular',
  }) async {
    try {
      final data = {
        'authorId': authorId,
        'content': content,
        'imageUrl': imageUrl,
        'imagesUrl': imagesUrl,
        'videoUrl': videoUrl,
        'sharedPostId': sharedPostId,
        'type': type,
        'likesCount': 0,
        'commentsCount': 0,
        'sharesCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      final docRef = await _firestore.collection('posts').add(data);
      
      // If sharing, increment shares count on original post
      if (sharedPostId != null) {
        await _firestore.collection('posts').doc(sharedPostId).update({
          'sharesCount': FieldValue.increment(1),
        });
      }

      return docRef.id;
    } catch (e) {
      debugPrint('Create Post Error: $e');
      return null;
    }
  }

  // Update reaction (null means remove)
  Future<void> updateReaction({
    required String postId,
    required String userId,
    required String postAuthorId,
    required ReactionType? reactionType,
  }) async {
    final likeRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId);

    if (reactionType == null) {
      // Remove reaction
      final doc = await likeRef.get();
      if (doc.exists) {
        await likeRef.delete();
        await _firestore.collection('posts').doc(postId).update({
          'likesCount': FieldValue.increment(-1),
        });
      }
    } else {
      // Add or Update reaction
      final doc = await likeRef.get();
      if (doc.exists) {
        final currentData = doc.data();
        final currentReactionStr = currentData?['reaction'] as String?;
        if (currentReactionStr != reactionType.name) {
             await likeRef.update({
              'reaction': reactionType.name,
              'createdAt': FieldValue.serverTimestamp(),
            });
        }
      } else {
        // New reaction
        await likeRef.set({
          'reaction': reactionType.name,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await _firestore.collection('posts').doc(postId).update({
          'likesCount': FieldValue.increment(1),
        });

        // Send Notification
        if (userId != postAuthorId) {
          final likerDoc = await _firestore.collection('users').doc(userId).get();
          final likerName = likerDoc.data()?['name'] ?? 'Someone';
          final likerAvatar = likerDoc.data()?['avatarUrl'] ?? '';

          await _notificationService.createNotification(
            forUserId: postAuthorId,
            type: 'like', // Could map reactionType to specific notification icons if model supported it
            avatarUrl: likerAvatar,
            title: likerName,
            body: 'reacted ${reactionType.name} to your post',
          );
        }
      }
    }
  }

  // Add comment
  Future<void> addComment({
    required String postId,
    required String userId,
    required String content,
    required String postAuthorId,
  }) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
      'userId': userId,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    await _firestore.collection('posts').doc(postId).update({
      'commentsCount': FieldValue.increment(1),
    });

    // Send Notification (if not commenting on own post)
    if (userId != postAuthorId) {
      // Fetch commenter details
      final commenterDoc = await _firestore.collection('users').doc(userId).get();
      final commenterName = commenterDoc.data()?['name'] ?? 'Someone';
      final commenterAvatar = commenterDoc.data()?['avatarUrl'] ?? '';

      await _notificationService.createNotification(
        forUserId: postAuthorId,
        type: 'comment',
        avatarUrl: commenterAvatar,
        title: commenterName,
        body: 'commented on your post: "$content"',
      );
    }
  }

  // Get comments for a post
  Stream<QuerySnapshot> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      debugPrint('Delete Post Error: $e');
      rethrow;
    }
  }
}
